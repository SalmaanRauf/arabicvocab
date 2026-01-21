import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/data_loader.dart';
import '../../data/models/root.dart';
import '../../data/models/user_progress.dart';
import '../../services/srs/fsrs.dart';
import '../../services/storage/progress_storage.dart';
import 'quran_providers.dart';

final fsrsProvider = Provider<FSRS>((ref) => FSRS());

final progressStorageProvider = Provider<ProgressStorage>((ref) => ProgressStorage());

/// User progress storage with persistence.
class UserProgressNotifier extends StateNotifier<Map<int, UserProgress>> {
  UserProgressNotifier(this._storage) : super({});

  final ProgressStorage _storage;
  bool _loaded = false;

  Future<void> loadFromStorage() async {
    if (_loaded) return;
    state = await _storage.load();
    _loaded = true;
  }

  Future<void> upsert(UserProgress progress) async {
    state = {...state, progress.rootId: progress};
    await _storage.upsert(progress);
  }

  List<UserProgress> getDue(DateTime now) {
    return state.values
        .where((p) => p.nextReviewDate.isBefore(now))
        .toList();
  }
}

final userProgressNotifierProvider =
    StateNotifierProvider<UserProgressNotifier, Map<int, UserProgress>>(
  (ref) {
    final storage = ref.watch(progressStorageProvider);
    return UserProgressNotifier(storage);
  },
);

final dueProgressProvider = FutureProvider<List<UserProgress>>((ref) async {
  await ref.watch(dataLoaderProvider.future);
  final notifier = ref.watch(userProgressNotifierProvider.notifier);
  await notifier.loadFromStorage();

  // Get due items from storage
  final dueItems = notifier.getDue(DateTime.now());

  // If no items due, seed with some initial roots for review
  if (dueItems.isEmpty && ref.read(userProgressNotifierProvider).isEmpty) {
    final loader = DataLoader.instance;
    final roots = loader.roots.take(10).toList(); // Start with 10 high-frequency roots
    for (final root in roots) {
      final progress = UserProgress(
        rootId: root.id,
        stage: SrsStage.newlyIntroduced,
        stability: 1.0,
        difficulty: 5.0,
        nextReviewDate: DateTime.now(),
      );
      await notifier.upsert(progress);
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
