import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/user_progress.dart';
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
              return const Center(child: Text('Session complete!'));
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
                          if (root != null) ...[
                            Text(
                              root.rootText,
                              textDirection: TextDirection.rtl,
                              style: Theme.of(context)
                                  .textTheme
                                  .displaySmall
                                  ?.copyWith(fontFamily: 'Amiri'),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              root.meaningShort,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              root.meaningLong,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Appears ${root.frequencyCount} times in Quran',
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                          ] else
                            Text('Root ${progress.rootId}'),
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
                  runSpacing: 12,
                  children: [
                    _ReviewButton(
                      label: 'Again',
                      color: Colors.red,
                      onTap: () => _handleReview(ref, progress, 1),
                    ),
                    _ReviewButton(
                      label: 'Hard',
                      color: Colors.orange,
                      onTap: () => _handleReview(ref, progress, 2),
                    ),
                    _ReviewButton(
                      label: 'Good',
                      color: Colors.green,
                      onTap: () => _handleReview(ref, progress, 3),
                    ),
                    _ReviewButton(
                      label: 'Easy',
                      color: Colors.blue,
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

  void _handleReview(
    WidgetRef ref,
    UserProgress progress,
    int rating,
  ) {
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

    // Update in-memory storage
    ref.read(userProgressNotifierProvider.notifier).upsert(updated);
    ref.read(currentSrsIndexProvider.notifier).state++;
    ref.invalidate(dueProgressProvider);
    ref.invalidate(currentRootProvider);
  }
}

class _ReviewButton extends StatelessWidget {
  const _ReviewButton({
    required this.label,
    required this.onTap,
    required this.color,
  });

  final String label;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
      ),
      child: Text(label),
    );
  }
}
