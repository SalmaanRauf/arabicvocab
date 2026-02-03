# Audio Sync Highlight Fix Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Restore visible word highlighting during audio playback and stop playback at the end of the selected ayah.

**Architecture:** Keep quran-align as the timing source. Introduce a tiny pure helper to map `Segment` + ms → `wordId` (testable). Add a stop-at-end guard in `AudioManager` based on the last segment’s end time. Ensure highlighted words are visibly styled in the UI.

**Tech Stack:** Flutter Web, Dart, Riverpod, just_audio, flutter_test.

---

### Task 1: Add a pure segment matcher + failing unit test

**Files:**
- Create: `quran_vocab/lib/services/audio/segment_matcher.dart`
- Test: `quran_vocab/test/segment_matcher_test.dart`

**Step 1: Write the failing test**

```dart
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
```

**Step 2: Run test to verify it fails**

Run:
```
/Users/salmaanrauf/Documents/arabicapp/arabicvocab/tools/flutter/bin/flutter test test/segment_matcher_test.dart
```

Expected: FAIL (helper not implemented or returns null).

**Step 3: Write minimal implementation**

```dart
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
```

**Step 4: Run test to verify it passes**

Run:
```
/Users/salmaanrauf/Documents/arabicapp/arabicvocab/tools/flutter/bin/flutter test test/segment_matcher_test.dart
```

Expected: PASS

**Step 5: Commit**

```
git add quran_vocab/lib/services/audio/segment_matcher.dart quran_vocab/test/segment_matcher_test.dart

git commit -m "test: add segment matcher helper"
```

---

### Task 2: Add stop-at-end guard with failing test

**Files:**
- Modify: `quran_vocab/lib/services/audio/audio_manager.dart`
- Test: `quran_vocab/test/audio_stop_guard_test.dart`

**Step 1: Write the failing test**

```dart
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
```

**Step 2: Run test to verify it fails**

Run:
```
/Users/salmaanrauf/Documents/arabicapp/arabicvocab/tools/flutter/bin/flutter test test/audio_stop_guard_test.dart
```

Expected: FAIL (method missing or returns false).

**Step 3: Write minimal implementation**

```dart
static bool shouldStopAtEnd(List<Segment> segments, int positionMs) {
  if (segments.isEmpty) return false;
  final lastEnd = segments.last.endMs;
  return positionMs >= lastEnd;
}
```

**Step 4: Run test to verify it passes**

Run:
```
/Users/salmaanrauf/Documents/arabicapp/arabicvocab/tools/flutter/bin/flutter test test/audio_stop_guard_test.dart
```

Expected: PASS

**Step 5: Commit**

```
git add quran_vocab/lib/services/audio/audio_manager.dart quran_vocab/test/audio_stop_guard_test.dart

git commit -m "test: add stop-at-end guard"
```

---

### Task 3: Wire matcher + stop guard into AudioManager

**Files:**
- Modify: `quran_vocab/lib/services/audio/audio_manager.dart`

**Step 1: Update AudioManager to use matcher helper**

```dart
import 'segment_matcher.dart';
```

Replace `_findWordIdAt` usage with the helper:

```dart
final wordId = findWordIdAt(_segments, adjustedMs);
```

**Step 2: Add stop-at-end handling**

Add state to track stop window for current ayah:

```dart
int? _stopAtMs;
```

Set it in `playAyah`:

```dart
_stopAtMs = _segments.isEmpty ? null : _segments.last.endMs;
```

In `_handlePosition` before emitting word:

```dart
if (_stopAtMs != null && adjustedMs >= _stopAtMs!) {
  _stopAtMs = null;
  _player.pause();
  return;
}
```

**Step 3: Run focused tests**

Run:
```
/Users/salmaanrauf/Documents/arabicapp/arabicvocab/tools/flutter/bin/flutter test test/segment_matcher_test.dart
/Users/salmaanrauf/Documents/arabicapp/arabicvocab/tools/flutter/bin/flutter test test/audio_stop_guard_test.dart
```

Expected: PASS

**Step 4: Commit**

```
git add quran_vocab/lib/services/audio/audio_manager.dart

git commit -m "feat: stop playback at end of selected ayah"
```

---

### Task 4: Make highlight visibly distinct in the UI

**Files:**
- Modify: `quran_vocab/lib/presentation/widgets/word_chip.dart`
- Test: `quran_vocab/test/word_chip_highlight_test.dart`

**Step 1: Write the failing test**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_vocab/presentation/widgets/word_chip.dart';
import 'package:quran_vocab/data/models/word.dart';

void main() {
  testWidgets('highlighted WordChip uses a non-transparent background', (tester) async {
    const word = Word(
      id: 1,
      ayahId: 1,
      position: 1,
      textUthmani: 'بِسْمِ',
      textIndopak: 'بِسۡمِ',
      translationEn: 'In the name',
      transliteration: 'bismi',
      rootId: null,
      lemmaId: null,
      audioStartMs: null,
      audioEndMs: null,
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Material(
          child: WordChip(word: word, isHighlighted: true),
        ),
      ),
    );

    final container = tester.widget<Container>(find.byType(Container).first);
    final decoration = container.decoration as BoxDecoration?;
    expect(decoration, isNotNull);
    expect(decoration!.color, isNotNull);
  });
}
```

**Step 2: Run test to verify it fails**

Run:
```
/Users/salmaanrauf/Documents/arabicapp/arabicvocab/tools/flutter/bin/flutter test test/word_chip_highlight_test.dart
```

Expected: FAIL (no Container background yet).

**Step 3: Write minimal implementation**

Replace `Ink` with a `Container` so background always paints:

```dart
return InkWell(
  onTap: onTap,
  borderRadius: BorderRadius.circular(10),
  child: Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: isHighlighted
          ? theme.colorScheme.primary.withOpacity(0.15)
          : Colors.transparent,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Text(
      text,
      textDirection: TextDirection.rtl,
      style: textStyle,
    ),
  ),
);
```

**Step 4: Run test to verify it passes**

Run:
```
/Users/salmaanrauf/Documents/arabicapp/arabicvocab/tools/flutter/bin/flutter test test/word_chip_highlight_test.dart
```

Expected: PASS

**Step 5: Commit**

```
git add quran_vocab/lib/presentation/widgets/word_chip.dart quran_vocab/test/word_chip_highlight_test.dart

git commit -m "feat: make highlighted words visually distinct"
```

---

### Task 5: Manual verification in UI (Playwright)

**Files:**
- None

**Step 1: Run the web app**

```
nohup env FLUTTER_SUPPRESS_ANALYTICS=true CI=true \
  /Users/salmaanrauf/Documents/arabicapp/arabicvocab/tools/flutter/bin/flutter run \
  -d web-server --web-port 8080 --web-hostname 0.0.0.0 \
  > /tmp/flutter_run.log 2>&1 &
```

**Step 2: Use Playwright to verify**
- Load `http://localhost:8080/`
- Load audio for Surah 1
- Press play on Ayah 1
- Confirm words highlight in sync
- Confirm playback stops at end of the ayah (does not continue)

**Step 3: Commit (if needed)**
- No code changes expected.

---

### Task 6: Final test sweep

Run:
```
/Users/salmaanrauf/Documents/arabicapp/arabicvocab/tools/flutter/bin/flutter test test/segment_matcher_test.dart
/Users/salmaanrauf/Documents/arabicapp/arabicvocab/tools/flutter/bin/flutter test test/audio_stop_guard_test.dart
/Users/salmaanrauf/Documents/arabicapp/arabicvocab/tools/flutter/bin/flutter test test/word_chip_highlight_test.dart
```

Expected: PASS

---

## Notes
- Flutter SDK is present at `arabicvocab/tools/flutter/` (not tracked), so use absolute path from the worktree.
- Tests may be slow; prefer running the specific test files listed above.
- If UI still doesn’t highlight, add a temporary debug `ref.listen(activeWordIdProvider, ...)` log and remove after confirming.

