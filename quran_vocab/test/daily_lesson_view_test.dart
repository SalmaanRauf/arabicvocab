import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:quran_vocab/data/models/ayah.dart';
import 'package:quran_vocab/data/models/daily_lesson.dart';
import 'package:quran_vocab/presentation/state/audio_providers.dart';
import 'package:quran_vocab/presentation/state/daily_lesson_providers.dart';
import 'package:quran_vocab/presentation/state/quran_providers.dart';
import 'package:quran_vocab/presentation/views/daily_lesson_view.dart';

void main() {
  testWidgets('DailyLessonView renders title and actions', (tester) async {
    final lesson = DailyLesson(
      id: 'DL-000001',
      dayIndex: 0,
      surahId: 1,
      ayahStart: 1,
      ayahEnd: 1,
      verseKeys: const ['1:1'],
      title: 'Test Lesson',
      bodyShort: 'Short body.',
      bodyFull: 'Full body.',
      takeaways: const ['Takeaway 1'],
      tags: const ['general'],
      source: const LessonSource(
        work: 'Abridged Explanation of the Quran',
        author: 'Al-Mukhtasar Committee',
        dataset: 'QUL',
        version: 'qul-abridged-v1',
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          lessonByDayProvider.overrideWithProvider(
            (int _) => FutureProvider<DailyLesson?>((ref) async => lesson),
          ),
          dailyLessonHistoryProvider.overrideWithProvider(
            FutureProvider<DailyLessonHistory>(
              (ref) async => const DailyLessonHistory(
                recent: [],
                catchUp: [],
              ),
            ),
          ),
          todayDayIndexProvider.overrideWithProvider(
            Provider<int>((ref) => 0),
          ),
          dailyLessonStreakProvider.overrideWithProvider(
            Provider<int>((ref) => 2),
          ),
          dailyCompletionProvider.overrideWithProvider(
            (String _) => Provider<bool>((ref) => false),
          ),
          dailySavedProvider.overrideWithProvider(
            (String _) => Provider<bool>((ref) => false),
          ),
          ayahsForSurahProvider.overrideWithProvider(
            (int _) => FutureProvider<List<Ayah>>((ref) async => const []),
          ),
          activeWordIdProvider.overrideWith(
            (ref) => Stream<int?>.value(null),
          ),
        ],
        child: const MaterialApp(
          home: DailyLessonView(),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Test Lesson'), findsOneWidget);
    expect(find.text('Mark complete'), findsOneWidget);
    expect(find.text('Save'), findsOneWidget);
  });
}
