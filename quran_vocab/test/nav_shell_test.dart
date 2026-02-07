import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_vocab/data/models/daily_lesson.dart';
import 'package:quran_vocab/data/models/surah.dart';
import 'package:quran_vocab/presentation/routes/app_router.dart';
import 'package:quran_vocab/presentation/state/dashboard_provider.dart';
import 'package:quran_vocab/presentation/state/daily_lesson_providers.dart';
import 'package:quran_vocab/presentation/state/quran_providers.dart';

void main() {
  testWidgets('App shell shows bottom navigation destinations', (tester) async {
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
            Provider<double>((ref) => 0.25),
          ),
          wordsDueProvider.overrideWithProvider(
            Provider<int>((ref) => 4),
          ),
          streakProvider.overrideWithProvider(
            FutureProvider<int>((ref) async => 1),
          ),
          surahsProvider.overrideWithProvider(
            FutureProvider<List<Surah>>((ref) async => [surah]),
          ),
          todayLessonProvider.overrideWithProvider(
            FutureProvider<DailyLesson?>((ref) async => lesson),
          ),
          dailyLessonStreakProvider.overrideWithProvider(
            Provider<int>((ref) => 3),
          ),
        ],
        child: MaterialApp.router(routerConfig: AppRouter.router),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.widgetWithText(NavigationDestination, 'Home'), findsOneWidget);
    expect(find.widgetWithText(NavigationDestination, 'Quran'), findsOneWidget);
    expect(find.widgetWithText(NavigationDestination, 'Daily'), findsOneWidget);
    expect(find.widgetWithText(NavigationDestination, 'Review'), findsOneWidget);
    expect(find.widgetWithText(NavigationDestination, 'Progress'),
        findsOneWidget);
  });
}
