import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/data_loader.dart';
import '../../data/models/root.dart';
import '../../data/models/user_progress.dart';
import '../../services/srs/fsrs.dart';
import 'quran_providers.dart';

final fsrsProvider = Provider<FSRS>((ref) => FSRS());

/// In-memory user progress storage for web.
/// In a production app, this would persist to IndexedDB or similar.
class UserProgressNotifier extends StateNotifier<Map<int, UserProgress>> {
  UserProgressNotifier() : super({});

  void upsert(UserProgress progress) {
    state = {...state, progress.rootId: progress};
  }

  List<UserProgress> getDue(DateTime now) {
    return state.values
        .where((p) => p.nextReviewDate.isBefore(now))
        .toList();
  }
}

final userProgressNotifierProvider =
    StateNotifierProvider<UserProgressNotifier, Map<int, UserProgress>>(
  (ref) => UserProgressNotifier(),
);

final dueProgressProvider = FutureProvider<List<UserProgress>>((ref) async {
  await ref.watch(dataLoaderProvider.future);
  final notifier = ref.watch(userProgressNotifierProvider.notifier);

  // Get due items from in-memory storage
  final dueItems = notifier.getDue(DateTime.now());

  // If no items due, seed with some initial roots for review
  if (dueItems.isEmpty) {
    final loader = DataLoader.instance;
    final roots = loader.roots.take(5).toList();
    for (final root in roots) {
      final progress = UserProgress(
        rootId: root.id,
        stage: SrsStage.newlyIntroduced,
        stability: 1.0,
        difficulty: 5.0,
        nextReviewDate: DateTime.now(),
      );
      notifier.upsert(progress);
    }
    return notifier.getDue(DateTime.now().add(const Duration(seconds: 1)));
  }
  return dueItems;
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
  final loader = await ref.watch(dataLoaderProvider.future);
  return loader.getRootById(progress.rootId);
});
