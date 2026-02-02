import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/lesson.dart';

/// Loads curriculum data from assets/data/lessons.json.
final curriculumProvider = FutureProvider<List<Unit>>((ref) async {
  final jsonString = await rootBundle.loadString('assets/data/lessons.json');
  final data = jsonDecode(jsonString) as Map<String, dynamic>;
  final unitsList = data['units'] as List<dynamic>;
  return unitsList
      .map((u) => Unit.fromJson(u as Map<String, dynamic>))
      .toList();
});

/// Tracks the currently selected lesson ID (for navigation).
final currentLessonIdProvider = StateProvider<int?>((ref) => null);

/// Returns the current lesson if one is selected.
final currentLessonProvider = Provider<Lesson?>((ref) {
  final lessonId = ref.watch(currentLessonIdProvider);
  if (lessonId == null) return null;

  final curriculumAsync = ref.watch(curriculumProvider);
  return curriculumAsync.whenOrNull(
    data: (units) {
      for (final unit in units) {
        for (final lesson in unit.lessons) {
          if (lesson.id == lessonId) return lesson;
        }
      }
      return null;
    },
  );
});

/// Lesson completion status (stored lesson IDs that are fully reviewed).
final completedLessonsProvider = StateNotifierProvider<CompletedLessonsNotifier, Set<int>>(
  (ref) => CompletedLessonsNotifier(),
);

class CompletedLessonsNotifier extends StateNotifier<Set<int>> {
  CompletedLessonsNotifier() : super({});

  void markComplete(int lessonId) {
    state = {...state, lessonId};
  }

  void markIncomplete(int lessonId) {
    state = {...state}..remove(lessonId);
  }

  bool isComplete(int lessonId) => state.contains(lessonId);
}

/// Check if a lesson is unlocked (first lesson always unlocked,
/// subsequent lessons unlocked if previous is complete).
final lessonUnlockedProvider = Provider.family<bool, int>((ref, lessonId) {
  final curriculumAsync = ref.watch(curriculumProvider);
  final completed = ref.watch(completedLessonsProvider);

  return curriculumAsync.when(
    loading: () => false,
    error: (_, __) => false,
    data: (units) {
      // Find this lesson and the one before it
      int? previousLessonId;
      for (final unit in units) {
        for (final lesson in unit.lessons) {
          if (lesson.id == lessonId) {
            // First lesson is always unlocked
            if (previousLessonId == null) return true;
            // Otherwise check if previous is complete
            return completed.contains(previousLessonId);
          }
          previousLessonId = lesson.id;
        }
      }
      return false;
    },
  );
});
