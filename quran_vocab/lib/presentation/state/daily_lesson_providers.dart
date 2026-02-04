import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/daily_lesson.dart';
import '../../services/storage/daily_lesson_storage.dart';
import 'quran_providers.dart';

class DailyLessonHistoryEntry {
  const DailyLessonHistoryEntry({
    required this.lesson,
    required this.dayIndex,
    required this.date,
    required this.isCompleted,
  });

  final DailyLesson lesson;
  final int dayIndex;
  final DateTime date;
  final bool isCompleted;
}

class DailyLessonHistory {
  const DailyLessonHistory({
    required this.recent,
    required this.catchUp,
  });

  final List<DailyLessonHistoryEntry> recent;
  final List<DailyLessonHistoryEntry> catchUp;
}

final nowProvider = Provider<DateTime>((ref) => DateTime.now());

final dailyLessonStorageProvider = Provider<DailyLessonStorage>((ref) {
  return DailyLessonStorage();
});

final dailyLessonsProvider = FutureProvider<List<DailyLesson>>((ref) async {
  final loader = await ref.watch(dataLoaderProvider.future);
  return loader.dailyLessons;
});

final dailyLessonProvider = dailyLessonsProvider;

final dailyStartDateProvider = FutureProvider<DateTime>((ref) async {
  final storage = ref.watch(dailyLessonStorageProvider);
  return storage.getStartDate();
});

final todayDayIndexProvider = Provider<int>((ref) {
  final now = ref.watch(nowProvider);
  final startAsync = ref.watch(dailyStartDateProvider);
  return startAsync.maybeWhen(
    data: (start) {
      final startDay = DateTime(start.year, start.month, start.day);
      final nowDay = DateTime(now.year, now.month, now.day);
      final diff = nowDay.difference(startDay).inDays;
      return diff < 0 ? 0 : diff;
    },
    orElse: () => 0,
  );
});

final selectedLessonDayIndexProvider = StateProvider<int?>((ref) => null);

final activeLessonDayIndexProvider = Provider<int>((ref) {
  final selected = ref.watch(selectedLessonDayIndexProvider);
  return selected ?? ref.watch(todayDayIndexProvider);
});

final lessonByDayProvider = FutureProvider.family<DailyLesson?, int>((
  ref,
  int dayIndex,
) async {
  final loader = await ref.watch(dataLoaderProvider.future);
  final lessons = loader.dailyLessons;
  if (dayIndex < 0 || dayIndex >= lessons.length) {
    return null;
  }
  return lessons[dayIndex];
});

final todayLessonProvider = FutureProvider<DailyLesson?>((ref) async {
  final dayIndex = ref.watch(todayDayIndexProvider);
  return ref.watch(lessonByDayProvider(dayIndex).future);
});

class DailyCompletedNotifier extends StateNotifier<Set<String>> {
  DailyCompletedNotifier(this._storage) : super({}) {
    _load();
  }

  final DailyLessonStorage _storage;

  Future<void> _load() async {
    state = await _storage.loadCompleted();
  }

  Future<void> toggle(String id) async {
    final next = {...state};
    if (next.contains(id)) {
      next.remove(id);
    } else {
      next.add(id);
    }
    state = next;
    await _storage.saveCompleted(next);
  }
}

class DailySavedNotifier extends StateNotifier<Set<String>> {
  DailySavedNotifier(this._storage) : super({}) {
    _load();
  }

  final DailyLessonStorage _storage;

  Future<void> _load() async {
    state = await _storage.loadSaved();
  }

  Future<void> toggle(String id) async {
    final next = {...state};
    if (next.contains(id)) {
      next.remove(id);
    } else {
      next.add(id);
    }
    state = next;
    await _storage.saveSaved(next);
  }
}

final dailyCompletedNotifierProvider =
    StateNotifierProvider<DailyCompletedNotifier, Set<String>>((ref) {
  final storage = ref.watch(dailyLessonStorageProvider);
  return DailyCompletedNotifier(storage);
});

final dailySavedNotifierProvider =
    StateNotifierProvider<DailySavedNotifier, Set<String>>((ref) {
  final storage = ref.watch(dailyLessonStorageProvider);
  return DailySavedNotifier(storage);
});

final dailyCompletionProvider = Provider.family<bool, String>((ref, id) {
  final completed = ref.watch(dailyCompletedNotifierProvider);
  return completed.contains(id);
});

final dailySavedProvider = Provider.family<bool, String>((ref, id) {
  final saved = ref.watch(dailySavedNotifierProvider);
  return saved.contains(id);
});

String lessonIdForDay(int dayIndex) {
  return 'DL-${(dayIndex + 1).toString().padLeft(6, '0')}';
}

final dailyLessonStreakProvider = Provider<int>((ref) {
  final completed = ref.watch(dailyCompletedNotifierProvider);
  final todayIndex = ref.watch(todayDayIndexProvider);
  int streak = 0;
  for (int i = todayIndex; i >= 0; i--) {
    if (completed.contains(lessonIdForDay(i))) {
      streak += 1;
    } else {
      break;
    }
  }
  return streak;
});

final dailyLessonHistoryProvider =
    FutureProvider<DailyLessonHistory>((ref) async {
  final lessons = await ref.watch(dailyLessonsProvider.future);
  final startDate = await ref.watch(dailyStartDateProvider.future);
  final completed = ref.watch(dailyCompletedNotifierProvider);
  final todayIndex = ref.watch(todayDayIndexProvider);

  final recent = <DailyLessonHistoryEntry>[];
  final startRecent = todayIndex - 6 < 0 ? 0 : todayIndex - 6;
  for (int i = startRecent; i <= todayIndex; i++) {
    if (i < 0 || i >= lessons.length) continue;
    final lesson = lessons[i];
    final date = startDate.add(Duration(days: i));
    recent.add(
      DailyLessonHistoryEntry(
        lesson: lesson,
        dayIndex: i,
        date: date,
        isCompleted: completed.contains(lesson.id),
      ),
    );
  }

  final catchUp = <DailyLessonHistoryEntry>[];
  for (int i = startRecent - 1; i >= 0 && catchUp.length < 3; i--) {
    if (i >= lessons.length) continue;
    final lesson = lessons[i];
    if (completed.contains(lesson.id)) {
      continue;
    }
    final date = startDate.add(Duration(days: i));
    catchUp.add(
      DailyLessonHistoryEntry(
        lesson: lesson,
        dayIndex: i,
        date: date,
        isCompleted: false,
      ),
    );
  }

  return DailyLessonHistory(recent: recent, catchUp: catchUp);
});
