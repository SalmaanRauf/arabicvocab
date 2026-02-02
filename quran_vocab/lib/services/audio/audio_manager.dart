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

  Stream<int?> get activeWordStream => _activeWordController.stream;

  Future<void> setSource({
    required String url,
    required List<Segment> segments,
  }) async {
    _segments = segments;
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
    final surahPadded = surahId.toString().padLeft(3, '0');
    final ayahPadded = ayahNumber.toString().padLeft(3, '0');
    final url = '$_audioBaseUrl$surahPadded$ayahPadded.mp3';
    await setSource(url: url, segments: segments);
  }

  void setOffsetMs(int offsetMs) {
    _offsetMs = offsetMs;
  }

  Future<void> play() => _player.play();
  Future<void> pause() => _player.pause();

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

  Future<void> dispose() async {
    await _subscription?.cancel();
    await _player.dispose();
    await _activeWordController.close();
  }
}

