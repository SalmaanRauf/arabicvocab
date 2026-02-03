import 'package:flutter_test/flutter_test.dart';
import 'package:quran_vocab/services/audio/segment.dart';
import 'package:quran_vocab/services/audio/audio_manager.dart';

void main() {
  test('shouldStopAtEnd returns true once position exceeds last segment', () {
    const segments = [
      Segment(wordId: 1, startMs: 0, endMs: 100),
      Segment(wordId: 2, startMs: 120, endMs: 300),
    ];

    expect(AudioManager.shouldStopAtEnd(segments, 299), isFalse);
    expect(AudioManager.shouldStopAtEnd(segments, 300), isTrue);
    expect(AudioManager.shouldStopAtEnd(segments, 350), isTrue);
  });
}
