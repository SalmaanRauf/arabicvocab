import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:quran_vocab/presentation/state/daily_lesson_providers.dart';

void main() {
  test('todayDayIndexProvider computes day offset', () async {
    final container = ProviderContainer(
      overrides: [
        nowProvider.overrideWithValue(DateTime(2026, 2, 4)),
        dailyStartDateProvider.overrideWithProvider(
          FutureProvider<DateTime>((ref) async => DateTime(2026, 2, 1)),
        ),
      ],
    );
    addTearDown(container.dispose);

    await container.read(dailyStartDateProvider.future);
    final dayIndex = container.read(todayDayIndexProvider);
    expect(dayIndex, 3);
  });
}
