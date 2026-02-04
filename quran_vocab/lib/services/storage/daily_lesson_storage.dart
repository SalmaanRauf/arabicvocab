import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class DailyLessonStorage {
  static const _startDateKey = 'daily_start_date';
  static const _completedKey = 'daily_completed';
  static const _savedKey = 'daily_saved';
  static const _streakKey = 'daily_streak';
  static const _lastCompletedKey = 'daily_last_completed_date';

  Future<DateTime> getStartDate() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_startDateKey);
    if (raw != null) {
      final parsed = DateTime.tryParse(raw);
      if (parsed != null) {
        return parsed;
      }
    }
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    await prefs.setString(_startDateKey, start.toIso8601String());
    return start;
  }

  Future<Set<String>> loadCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_completedKey);
    if (raw == null || raw.isEmpty) {
      return {};
    }
    try {
      final list = (jsonDecode(raw) as List).cast<String>();
      return list.toSet();
    } catch (_) {
      return {};
    }
  }

  Future<void> saveCompleted(Set<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_completedKey, jsonEncode(ids.toList()));
  }

  Future<Set<String>> loadSaved() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_savedKey);
    if (raw == null || raw.isEmpty) {
      return {};
    }
    try {
      final list = (jsonDecode(raw) as List).cast<String>();
      return list.toSet();
    } catch (_) {
      return {};
    }
  }

  Future<void> saveSaved(Set<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_savedKey, jsonEncode(ids.toList()));
  }

  Future<void> toggleCompleted(String id) async {
    final current = await loadCompleted();
    if (current.contains(id)) {
      current.remove(id);
    } else {
      current.add(id);
    }
    await saveCompleted(current);
  }

  Future<void> toggleSaved(String id) async {
    final current = await loadSaved();
    if (current.contains(id)) {
      current.remove(id);
    } else {
      current.add(id);
    }
    await saveSaved(current);
  }

  Future<int> loadStreak() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_streakKey) ?? 0;
  }

  Future<void> saveStreak(int streak) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_streakKey, streak);
  }

  Future<DateTime?> loadLastCompletedDate() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_lastCompletedKey);
    if (raw == null) return null;
    return DateTime.tryParse(raw);
  }

  Future<void> saveLastCompletedDate(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastCompletedKey, date.toIso8601String());
  }
}
