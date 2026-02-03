import 'dart:convert';

import 'package:flutter/services.dart';

import '../services/audio/segment.dart';
import 'models/word.dart';

class RawSegment {
  const RawSegment({
    required this.wordStart,
    required this.wordEnd,
    required this.startMs,
    required this.endMs,
  });

  final int wordStart;
  final int wordEnd;
  final int startMs;
  final int endMs;
}

class AudioAlignmentLoader {
  AudioAlignmentLoader._();
  static final AudioAlignmentLoader instance = AudioAlignmentLoader._();

  Map<int, Map<int, List<RawSegment>>>? _segmentsBySurah;

  Future<void> load() async {
    if (_segmentsBySurah != null) return;
    final jsonString =
        await rootBundle.loadString('assets/data/audio_align/Alafasy_128kbps.json');
    final list = (jsonDecode(jsonString) as List).cast<Map<String, dynamic>>();
    final map = <int, Map<int, List<RawSegment>>>{};

    for (final entry in list) {
      final surah = entry['surah'] as int;
      final ayah = entry['ayah'] as int;
      final segments = (entry['segments'] as List)
          .map<List<int>>((e) => (e as List).cast<int>())
          .map(
            (s) => RawSegment(
              wordStart: s[0],
              wordEnd: s[1],
              startMs: s[2],
              endMs: s[3],
            ),
          )
          .toList();

      map.putIfAbsent(surah, () => {})[ayah] = segments;
    }

    _segmentsBySurah = map;
  }

  List<RawSegment> getRawSegments(int surahId, int ayahNumber) {
    return _segmentsBySurah?[surahId]?[ayahNumber] ?? const <RawSegment>[];
  }

  static List<Segment> buildSegmentsForAyah(
    List<Word> words,
    List<RawSegment> rawSegments,
  ) {
    final segments = <Segment>[];
    for (final raw in rawSegments) {
      final wordCount = raw.wordEnd - raw.wordStart;
      final duration = raw.endMs - raw.startMs;
      if (wordCount <= 0 || duration <= 0) {
        continue;
      }
      final perWord = duration / wordCount;
      for (int i = 0; i < wordCount; i++) {
        final wordIndex = raw.wordStart + i;
        if (wordIndex < 0 || wordIndex >= words.length) {
          continue;
        }
        final start = (raw.startMs + perWord * i).round();
        final end = (raw.startMs + perWord * (i + 1)).round();
        segments.add(
          Segment(
            wordId: words[wordIndex].id,
            startMs: start,
            endMs: end,
          ),
        );
      }
    }
    segments.sort((a, b) => a.startMs.compareTo(b.startMs));
    return segments;
  }
}
