import 'package:flutter_test/flutter_test.dart';

import 'package:quran_vocab/data/audio_alignment_loader.dart';
import 'package:quran_vocab/data/models/word.dart';

void main() {
  test('buildSegmentsForAyah splits a segment across words', () {
    final words = [
      Word(
        id: 10,
        ayahId: 1,
        position: 1,
        textUthmani: 'a',
        textIndopak: 'a',
        translationEn: '',
        transliteration: '',
        rootId: null,
        lemmaId: null,
        audioStartMs: null,
        audioEndMs: null,
      ),
      Word(
        id: 11,
        ayahId: 1,
        position: 2,
        textUthmani: 'b',
        textIndopak: 'b',
        translationEn: '',
        transliteration: '',
        rootId: null,
        lemmaId: null,
        audioStartMs: null,
        audioEndMs: null,
      ),
      Word(
        id: 12,
        ayahId: 1,
        position: 3,
        textUthmani: 'c',
        textIndopak: 'c',
        translationEn: '',
        transliteration: '',
        rootId: null,
        lemmaId: null,
        audioStartMs: null,
        audioEndMs: null,
      ),
    ];

    final raw = [
      RawSegment(wordStart: 0, wordEnd: 3, startMs: 0, endMs: 300),
    ];

    final segments = AudioAlignmentLoader.buildSegmentsForAyah(words, raw);
    expect(segments.length, 3);
    expect(segments[0].wordId, 10);
    expect(segments[0].startMs, 0);
    expect(segments[0].endMs, 100);
    expect(segments[1].wordId, 11);
    expect(segments[1].startMs, 100);
    expect(segments[1].endMs, 200);
    expect(segments[2].wordId, 12);
    expect(segments[2].startMs, 200);
    expect(segments[2].endMs, 300);
  });
}
