import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/db/quran_dao.dart';
import '../../data/models/user_progress.dart';
import '../state/quran_providers.dart';
import '../state/srs_providers.dart';

class ReviewView extends ConsumerWidget {
  const ReviewView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dueAsync = ref.watch(dueProgressProvider);
    final progress = ref.watch(currentProgressProvider);
    final rootAsync = ref.watch(currentRootProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Review'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: dueAsync.when(
          data: (items) {
            if (items.isEmpty) {
              return const Center(child: Text('No reviews due right now.'));
            }
            if (progress == null) {
              return const Center(child: Text('Session complete.'));
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Card ${ref.watch(currentSrsIndexProvider) + 1} of ${items.length}',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: rootAsync.when(
                      data: (root) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            root?.rootText ?? 'Root ${progress.rootId}',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            root?.meaningShort ?? 'Meaning not loaded yet.',
                          ),
                        ],
                      ),
                      loading: () => const LinearProgressIndicator(),
                      error: (error, _) =>
                          Text('Failed to load root: $error'),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 12,
                  children: [
                    _ReviewButton(
                      label: 'Again',
                      onTap: () => _handleReview(ref, progress, 1),
                    ),
                    _ReviewButton(
                      label: 'Hard',
                      onTap: () => _handleReview(ref, progress, 2),
                    ),
                    _ReviewButton(
                      label: 'Good',
                      onTap: () => _handleReview(ref, progress, 3),
                    ),
                    _ReviewButton(
                      label: 'Easy',
                      onTap: () => _handleReview(ref, progress, 4),
                    ),
                  ],
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(child: Text('Review load failed: $error')),
        ),
      ),
    );
  }

  Future<void> _handleReview(
    WidgetRef ref,
    UserProgress progress,
    int rating,
  ) async {
    final fsrs = ref.read(fsrsProvider);
    final now = DateTime.now();
    final elapsedDays = now.difference(progress.nextReviewDate).inDays;
    final review = fsrs.review(
      stability: progress.stability,
      difficulty: progress.difficulty,
      rating: rating,
      elapsedDays: (elapsedDays <= 0 ? 1 : elapsedDays).toDouble(),
    );
    final nextDate = now.add(Duration(days: review.nextIntervalDays));
    final updated = UserProgress(
      rootId: progress.rootId,
      stage: rating <= 2 ? SrsStage.learning : SrsStage.review,
      stability: review.stability,
      difficulty: review.difficulty,
      nextReviewDate: nextDate,
    );
    final db = await ref.read(databaseProvider.future);
    await QuranDao(db).upsertUserProgress(updated);
    ref.read(currentSrsIndexProvider.notifier).state++;
    ref.invalidate(dueProgressProvider);
    ref.invalidate(currentRootProvider);
  }
}

class _ReviewButton extends StatelessWidget {
  const _ReviewButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      child: Text(label),
    );
  }
}
