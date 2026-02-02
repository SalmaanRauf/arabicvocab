import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/user_progress.dart';
import '../../services/storage/progress_storage.dart';

/// Storage service instance.
final progressStorageProvider = Provider((ref) => ProgressStorage());

/// All user progress entries.
final userProgressMapProvider = FutureProvider<Map<int, UserProgress>>((ref) {
  final storage = ref.watch(progressStorageProvider);
  return storage.load();
});

/// Count of words learned (past the 'new' stage).
final wordsLearnedProvider = Provider<int>((ref) {
  final progressAsync = ref.watch(userProgressMapProvider);
  return progressAsync.when(
    loading: () => 0,
    error: (_, __) => 0,
    data: (map) => map.values
        .where((p) => p.stage != SrsStage.newlyIntroduced)
        .length,
  );
});

/// Target vocabulary count for 80% coverage.
const int targetVocabularyCount = 500;

/// Quran coverage percentage (simplified: learned words / target).
final quranCoverageProvider = Provider<double>((ref) {
  final learned = ref.watch(wordsLearnedProvider);
  return (learned / targetVocabularyCount).clamp(0.0, 1.0);
});

/// Current streak count.
final streakProvider = FutureProvider<int>((ref) async {
  final storage = ref.watch(progressStorageProvider);
  return storage.loadStreak();
});

/// Last review date.
final lastReviewDateProvider = FutureProvider<DateTime?>((ref) async {
  final storage = ref.watch(progressStorageProvider);
  return storage.loadLastReviewDate();
});

/// Count of reviews completed today.
final todayReviewsProvider = Provider<int>((ref) {
  final progressAsync = ref.watch(userProgressMapProvider);
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  return progressAsync.when(
    loading: () => 0,
    error: (_, __) => 0,
    data: (map) => map.values.where((p) {
      // If the next review is scheduled after today, it was reviewed today
      // This is a simplification; a more accurate approach would track
      // actual review timestamps
      final reviewDay = DateTime(
        p.nextReviewDate.year,
        p.nextReviewDate.month,
        p.nextReviewDate.day,
      );
      return reviewDay.isAfter(today) && p.stage != SrsStage.newlyIntroduced;
    }).length,
  );
});

/// Words due for review now.
final wordsDueProvider = Provider<int>((ref) {
  final progressAsync = ref.watch(userProgressMapProvider);
  final now = DateTime.now();

  return progressAsync.when(
    loading: () => 0,
    error: (_, __) => 0,
    data: (map) => map.values
        .where((p) => p.nextReviewDate.isBefore(now))
        .length,
  );
});
