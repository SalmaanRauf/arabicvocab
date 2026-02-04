import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:quran_vocab/services/storage/daily_lesson_storage.dart';

void main() {
  test('getStartDate sets and reuses the same start date', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = DailyLessonStorage();

    final first = await storage.getStartDate();
    final second = await storage.getStartDate();

    final now = DateTime.now();
    expect(first.year, now.year);
    expect(first.month, now.month);
    expect(first.day, now.day);
    expect(second.toIso8601String(), first.toIso8601String());
  });

  test('toggleCompleted and toggleSaved persist state', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = DailyLessonStorage();

    await storage.toggleCompleted('DL-000001');
    var completed = await storage.loadCompleted();
    expect(completed.contains('DL-000001'), true);

    await storage.toggleCompleted('DL-000001');
    completed = await storage.loadCompleted();
    expect(completed.contains('DL-000001'), false);

    await storage.toggleSaved('DL-000001');
    var saved = await storage.loadSaved();
    expect(saved.contains('DL-000001'), true);
  });
}
