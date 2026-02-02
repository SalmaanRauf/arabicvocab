import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../routes/app_router.dart';
import '../state/curriculum_provider.dart';
import '../state/quran_providers.dart';
import '../widgets/word_chip.dart';

class LessonDetailView extends ConsumerWidget {
  const LessonDetailView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lesson = ref.watch(currentLessonProvider);

    if (lesson == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Lesson')),
        body: const Center(child: Text('No lesson selected')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(lesson.title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRouter.curriculumPath),
        ),
      ),
      body: Column(
        children: [
          _buildHeader(context, lesson.description, lesson.wordCount),
          Expanded(
            child: lesson.isSurahBased
                ? _SurahBasedContent(
                    surahId: lesson.surahId!,
                    ayahRange: lesson.ayahRange!,
                  )
                : _VocabularyContent(vocabulary: lesson.vocabulary ?? []),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(context, ref, lesson.id),
    );
  }

  Widget _buildHeader(BuildContext context, String description, int wordCount) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            description,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.book_outlined, size: 16),
              const SizedBox(width: 4),
              Text(
                '$wordCount words',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, WidgetRef ref, int lessonId) {
    final isCompleted = ref.watch(completedLessonsProvider).contains(lessonId);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.school),
                label: const Text('Practice'),
                onPressed: () => context.go(AppRouter.reviewPath),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: FilledButton.icon(
                icon: Icon(isCompleted ? Icons.check : Icons.done_all),
                label: Text(isCompleted ? 'Completed' : 'Mark Complete'),
                onPressed: () {
                  if (isCompleted) {
                    ref.read(completedLessonsProvider.notifier).markIncomplete(lessonId);
                  } else {
                    ref.read(completedLessonsProvider.notifier).markComplete(lessonId);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SurahBasedContent extends ConsumerWidget {
  const _SurahBasedContent({
    required this.surahId,
    required this.ayahRange,
  });

  final int surahId;
  final List<int> ayahRange;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ayahsAsync = ref.watch(ayahsForSurahProvider(surahId));

    return ayahsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Error: $err')),
      data: (allAyahs) {
        // Filter to only ayahs in the range
        final ayahs = allAyahs.where((a) {
          return a.ayahNumber >= ayahRange[0] && a.ayahNumber <= ayahRange[1];
        }).toList();

        if (ayahs.isEmpty) {
          return const Center(child: Text('No ayahs found for this range'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: ayahs.length,
          itemBuilder: (context, index) {
            final ayah = ayahs[index];
            final wordsAsync = ref.watch(wordsForAyahProvider(ayah.id));

            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${ayah.ayahNumber}',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  const SizedBox(height: 4),
                  wordsAsync.when(
                    loading: () => const SizedBox(
                      height: 40,
                      child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                    ),
                    error: (e, _) => Text('Error: $e'),
                    data: (words) => Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      textDirection: TextDirection.rtl,
                      children: words.map((word) => WordChip(word: word)).toList(),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _VocabularyContent extends StatelessWidget {
  const _VocabularyContent({required this.vocabulary});

  final List<String> vocabulary;

  @override
  Widget build(BuildContext context) {
    if (vocabulary.isEmpty || vocabulary.first == 'review') {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.auto_awesome, size: 64, color: Colors.amber),
              SizedBox(height: 16),
              Text(
                'Coming Soon',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'This lesson will be populated with vocabulary based on themes.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: vocabulary.length,
      itemBuilder: (context, index) {
        return Card(
          child: ListTile(
            leading: CircleAvatar(
              child: Text('${index + 1}'),
            ),
            title: Text(
              vocabulary[index],
              style: const TextStyle(fontFamily: 'monospace'),
            ),
            subtitle: const Text('Tap to see usage'),
          ),
        );
      },
    );
  }
}
