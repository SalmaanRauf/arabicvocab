import 'segment.dart';

int? findWordIdAt(List<Segment> segments, int ms) {
  int low = 0;
  int high = segments.length - 1;
  while (low <= high) {
    final mid = (low + high) >> 1;
    final seg = segments[mid];
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
