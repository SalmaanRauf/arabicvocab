import 'dart:async';

import 'package:just_audio/just_audio.dart';

import 'segment.dart';

/// Base URL for verse audio from EveryAyah CDN (Mishary al-Afasy reciter).
/// Format: {surahNumber padded to 3 digits}{ayahNumber padded to 3 digits}.mp3
const String _audioBaseUrl =
    'https://everyayah.com/data/Alafasy_128kbps/';

class AudioManager {
  AudioManager() {
    _subscription = _player.positionStream.listen(_handlePosition);
  }

  final AudioPlayer _player = AudioPlayer();
  final StreamController<int?> _activeWordController =
      StreamController<int?>.broadcast();
  StreamSubscription<Duration>? _subscription;
  List<Segment> _segments = [];
  int _offsetMs = 0;
  int? _lastEmittedWordId;
  int? _loadedSurahId;
  int _loadedAyahCount = 0;
  Map<int, List<Segment>> _segmentsByAyah = const {};

  Stream<int?> get activeWordStream => _activeWordController.stream;

  static String buildAyahUrl(int surahId, int ayahNumber) {
    final surahPadded = surahId.toString().padLeft(3, '0');
    final ayahPadded = ayahNumber.toString().padLeft(3, '0');
    return '$_audioBaseUrl$surahPadded$ayahPadded.mp3';
  }

  static List<String> buildSurahUrls(int surahId, int ayahCount) {
    return List.generate(
      ayahCount,
      (index) => buildAyahUrl(surahId, index + 1),
    );
  }

  Future<void> setSource({
    required String url,
    required List<Segment> segments,
  }) async {
    _segments = segments;
    _loadedSurahId = null;
    _loadedAyahCount = 0;
    _segmentsByAyah = const {};
    await _player.setUrl(url);
  }

  /// Convenience method to load audio for a specific ayah.
  /// Uses EveryAyah CDN with Mishary al-Afasy reciter.
  /// 
  /// [surahId] - Surah number (1-114)
  /// [ayahNumber] - Ayah number within the surah
  /// [segments] - Optional word timing segments for karaoke highlighting
  Future<void> loadAyahAudio({
    required int surahId,
    required int ayahNumber,
    List<Segment> segments = const [],
  }) async {
    final url = buildAyahUrl(surahId, ayahNumber);
    await setSource(url: url, segments: segments);
  }

  Future<void> loadSurahAudio({
    required int surahId,
    required int ayahCount,
    Map<int, List<Segment>> segmentsByAyah = const {},
  }) async {
    final urls = buildSurahUrls(surahId, ayahCount);
    final source = ConcatenatingAudioSource(
      children: urls
          .map((url) => AudioSource.uri(Uri.parse(url)))
          .toList(),
    );
    _segments = [];
    _loadedSurahId = surahId;
    _loadedAyahCount = ayahCount;
    _segmentsByAyah = segmentsByAyah;
    await _player.setAudioSource(source);
  }

  void setOffsetMs(int offsetMs) {
    _offsetMs = offsetMs;
  }

  Future<void> play() => _player.play();
  Future<void> pause() => _player.pause();

  Future<void> playAyah({
    required int surahId,
    required int ayahNumber,
  }) async {
    if (_loadedSurahId != surahId) return;
    if (ayahNumber < 1 || ayahNumber > _loadedAyahCount) return;
    _segments = _segmentsByAyah[ayahNumber] ?? const [];
    if (_lastEmittedWordId != null) {
      _lastEmittedWordId = null;
      _activeWordController.add(null);
    }
    await _player.seek(Duration.zero, index: ayahNumber - 1);
    await _player.play();
  }

  void _handlePosition(Duration position) {
    if (_segments.isEmpty) {
      if (_lastEmittedWordId != null) {
        _lastEmittedWordId = null;
        _activeWordController.add(null);
      }
      return;
    }
    final adjustedMs = position.inMilliseconds + _offsetMs;
    final wordId = _findWordIdAt(adjustedMs);
    if (wordId != _lastEmittedWordId) {
      _lastEmittedWordId = wordId;
      _activeWordController.add(wordId);
    }
  }

  int? _findWordIdAt(int ms) {
    int low = 0;
    int high = _segments.length - 1;
    while (low <= high) {
      final mid = (low + high) >> 1;
      final seg = _segments[mid];
      if (ms < seg.startMs) {
        high = mid - 1;
      } else if (ms > seg.endMs) {
        low = mid + 1;
      } else {
        return seg.wordId;
      }
    }
    return null;
  }

  static bool shouldStopAtEnd(List<Segment> segments, int positionMs) {
    if (segments.isEmpty) return false;
    final lastEnd = segments.last.endMs;
    return positionMs >= lastEnd;
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
    await _player.dispose();
    await _activeWordController.close();
  }
}
