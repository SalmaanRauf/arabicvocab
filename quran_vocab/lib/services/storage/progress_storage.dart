import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/user_progress.dart';

/// Persists user progress to localStorage via shared_preferences.
class ProgressStorage {
  static const _key = 'user_progress';

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
}
