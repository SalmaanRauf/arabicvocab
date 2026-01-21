import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/db/quran_dao.dart';
import '../../data/models/root.dart';
import '../../data/models/user_progress.dart';
import '../../services/srs/fsrs.dart';
import 'quran_providers.dart';

final fsrsProvider = Provider<FSRS>((ref) => FSRS());

final dueProgressProvider = FutureProvider<List<UserProgress>>((ref) async {
  final db = await ref.watch(databaseProvider.future);
  return QuranDao(db).fetchDueProgress(DateTime.now());
});

final currentSrsIndexProvider = StateProvider<int>((ref) => 0);

final currentProgressProvider = Provider<UserProgress?>((ref) {
  final dueAsync = ref.watch(dueProgressProvider);
  final index = ref.watch(currentSrsIndexProvider);
  return dueAsync.maybeWhen(
    data: (items) {
      if (items.isEmpty || index >= items.length) {
        return null;
      }
      return items[index];
    },
    orElse: () => null,
  );
});

final currentRootProvider = FutureProvider<Root?>((ref) async {
  final progress = ref.watch(currentProgressProvider);
  if (progress == null) {
    return null;
  }
  final db = await ref.watch(databaseProvider.future);
  return QuranDao(db).fetchRootById(progress.rootId);
});
