import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_vocab/data/models/daily_lesson.dart';
import 'package:quran_vocab/data/models/surah.dart';
import 'package:quran_vocab/presentation/state/dashboard_provider.dart';
import 'package:quran_vocab/presentation/state/daily_lesson_providers.dart';
import 'package:quran_vocab/presentation/state/quran_providers.dart';
import 'package:quran_vocab/presentation/views/home_view.dart';

void main() {
  testWidgets('Home dashboard shows key sections', (tester) async {
    final lesson = DailyLesson(
      id: 'DL-000001',
      dayIndex: 0,
      surahId: 1,
      ayahStart: 1,
      ayahEnd: 3,
      verseKeys: const ['1:1', '1:2', '1:3'],
      title: 'Opening in Allah\'s Name',
      bodyShort: 'Short reflection.',
      bodyFull: 'Full reflection.',
      takeaways: const ['Takeaway'],
      tags: const ['general'],
      source: const LessonSource(
        work: 'Abridged Explanation',
        author: 'Author',
        dataset: 'QUL',
        version: 'v1',
      ),
    );

    final surah = Surah(
      id: 1,
      nameArabic: 'الفاتحة',
      nameEnglish: 'Al-Fatiha',
      verseCount: 7,
      type: 'Meccan',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          quranCoverageProvider.overrideWithProvider(
            Provider<double>((ref) => 0.3),
          ),
          wordsDueProvider.overrideWithProvider(
            Provider<int>((ref) => 5),
          ),
          streakProvider.overrideWithProvider(
            FutureProvider<int>((ref) async => 2),
          ),
          todayLessonProvider.overrideWithProvider(
            FutureProvider<DailyLesson?>((ref) async => lesson),
          ),
          surahsProvider.overrideWithProvider(
            FutureProvider<List<Surah>>((ref) async => [surah]),
          ),
        ],
        child: const MaterialApp(home: HomeView()),
      ),
    );

    await tester.pump();

    expect(find.text('Today\'s Lesson'), findsOneWidget);
    expect(find.text('Continue Reading'), findsOneWidget);
    expect(find.text('Quick Actions'), findsOneWidget);
  });
}
