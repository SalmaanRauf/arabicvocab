import 'package:flutter_test/flutter_test.dart';
import 'package:quran_vocab/services/audio/segment.dart';
import 'package:quran_vocab/services/audio/segment_matcher.dart';

void main() {
  test('findWordIdAt returns matching wordId for a timestamp', () {
    const segments = [
      Segment(wordId: 10, startMs: 0, endMs: 100),
      Segment(wordId: 11, startMs: 110, endMs: 200),
    ];

    expect(findWordIdAt(segments, 50), 10);
    expect(findWordIdAt(segments, 150), 11);
    expect(findWordIdAt(segments, 250), isNull);
  });
}
