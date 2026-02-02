import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/user_progress.dart';

/// Persists user progress to localStorage via shared_preferences.
class ProgressStorage {
  static const _key = 'user_progress';
  static const _streakKey = 'streak_count';
  static const _lastReviewKey = 'last_review_date';

  Future<Map<int, UserProgress>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_key);
    if (json == null || json.isEmpty) {
      return {};
    }
    try {
      final list = jsonDecode(json) as List;
      final map = <int, UserProgress>{};
      for (final item in list) {
        final progress = UserProgress.fromMap(item as Map<String, dynamic>);
        map[progress.rootId] = progress;
      }
      return map;
    } catch (e) {
      return {};
    }
  }

  Future<void> save(Map<int, UserProgress> progress) async {
    final prefs = await SharedPreferences.getInstance();
    final list = progress.values.map((p) => p.toMap()).toList();
    await prefs.setString(_key, jsonEncode(list));
  }

  Future<void> upsert(UserProgress progress) async {
    final current = await load();
    current[progress.rootId] = progress;
    await save(current);
  }

  // Streak tracking methods

  Future<int> loadStreak() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_streakKey) ?? 0;
  }

  Future<void> saveStreak(int count) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_streakKey, count);
  }

  Future<DateTime?> loadLastReviewDate() async {
    final prefs = await SharedPreferences.getInstance();
    final dateStr = prefs.getString(_lastReviewKey);
    if (dateStr == null) return null;
    return DateTime.tryParse(dateStr);
  }

  Future<void> saveLastReviewDate(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastReviewKey, date.toIso8601String());
  }

  /// Updates streak based on review activity.
  /// Call this after each review session.
  Future<int> updateStreakOnReview() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastReview = await loadLastReviewDate();
    int streak = await loadStreak();

    if (lastReview == null) {
      // First review ever
      streak = 1;
    } else {
      final lastDay = DateTime(lastReview.year, lastReview.month, lastReview.day);
      final daysDiff = today.difference(lastDay).inDays;
      
      if (daysDiff == 0) {
        // Same day, streak unchanged
      } else if (daysDiff == 1) {
        // Consecutive day, increment streak
        streak += 1;
      } else {
        // Streak broken, reset to 1
        streak = 1;
      }
    }

    await saveStreak(streak);
    await saveLastReviewDate(now);
    return streak;
  }
}

