import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/ayah.dart';
import '../../data/models/daily_lesson.dart';
import '../state/audio_providers.dart';
import '../state/daily_lesson_providers.dart';
import '../state/quran_providers.dart';
import '../widgets/ayah_widget.dart';

class DailyLessonView extends ConsumerStatefulWidget {
  const DailyLessonView({super.key});

  @override
  ConsumerState<DailyLessonView> createState() => _DailyLessonViewState();
}

class _DailyLessonViewState extends ConsumerState<DailyLessonView> {
  int? _selectedDayIndex;
  bool _showFull = false;
  bool _isAudioLoading = false;

  @override
  Widget build(BuildContext context) {
    final todayIndex = ref.watch(todayDayIndexProvider);
    final activeDayIndex = _selectedDayIndex ?? todayIndex;
    final lessonAsync = ref.watch(lessonByDayProvider(activeDayIndex));
    final historyAsync = ref.watch(dailyLessonHistoryProvider);
    final streak = ref.watch(dailyLessonStreakProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Lesson'),
        actions: [
          if (_selectedDayIndex != null)
            TextButton(
              onPressed: () => setState(() => _selectedDayIndex = null),
              child: const Text('Today'),
            ),
        ],
      ),
      body: lessonAsync.when(
        data: (lesson) {
          if (lesson == null) {
            return const Center(child: Text('No lesson available.'));
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _HeaderCard(
                lesson: lesson,
                dayIndex: activeDayIndex,
                streak: streak,
              ),
              const SizedBox(height: 16),
              _LessonActions(lesson: lesson),
              const SizedBox(height: 16),
              _AudioCard(
                lesson: lesson,
                isLoading: _isAudioLoading,
                onLoadingChanged: (value) {
                  setState(() => _isAudioLoading = value);
                },
              ),
              const SizedBox(height: 16),
              _VerseSection(lesson: lesson),
              const SizedBox(height: 16),
              _ReflectionSection(
                lesson: lesson,
                showFull: _showFull,
                onToggle: () => setState(() => _showFull = !_showFull),
              ),
              const SizedBox(height: 16),
              _TakeawaySection(takeaways: lesson.takeaways),
              const SizedBox(height: 16),
              _SourceSection(source: lesson.source),
              const SizedBox(height: 24),
              historyAsync.when(
                data: (history) => _HistorySection(
                  history: history,
                  onSelectDay: (dayIndex) {
                    setState(() {
                      _selectedDayIndex = dayIndex;
                      _showFull = false;
                    });
                  },
                ),
                loading: () => const LinearProgressIndicator(),
                error: (err, _) => Text('Failed to load history: $err'),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Failed to load lesson: $err')),
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({
    required this.lesson,
    required this.dayIndex,
    required this.streak,
  });

  final DailyLesson lesson;
  final int dayIndex;
  final int streak;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Day ${dayIndex + 1}',
              style: theme.textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            Text(
              lesson.title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.local_fire_department,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 6),
                Text(
                  '$streak day streak',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LessonActions extends ConsumerWidget {
  const _LessonActions({required this.lesson});

  final DailyLesson lesson;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isCompleted = ref.watch(dailyCompletionProvider(lesson.id));
    final isSaved = ref.watch(dailySavedProvider(lesson.id));
    final storage = ref.watch(dailyLessonStorageProvider);

    return Row(
      children: [
        Expanded(
          child: FilledButton.icon(
            icon: Icon(isCompleted ? Icons.check : Icons.done_all),
            label: Text(isCompleted ? 'Completed' : 'Mark complete'),
            onPressed: () async {
              await ref
                  .read(dailyCompletedNotifierProvider.notifier)
                  .toggle(lesson.id);
              final updatedStreak = ref.read(dailyLessonStreakProvider);
              await storage.saveStreak(updatedStreak);
              final nowCompleted =
                  ref.read(dailyCompletionProvider(lesson.id));
              if (nowCompleted) {
                await storage.saveLastCompletedDate(ref.read(nowProvider));
              }
            },
          ),
        ),
        const SizedBox(width: 12),
        OutlinedButton.icon(
          icon: Icon(isSaved ? Icons.bookmark : Icons.bookmark_border),
          label: const Text('Save'),
          onPressed: () async {
            await ref
                .read(dailySavedNotifierProvider.notifier)
                .toggle(lesson.id);
          },
        ),
      ],
    );
  }
}

class _AudioCard extends ConsumerWidget {
  const _AudioCard({
    required this.lesson,
    required this.isLoading,
    required this.onLoadingChanged,
  });

  final DailyLesson lesson;
  final bool isLoading;
  final ValueChanged<bool> onLoadingChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ayahsAsync = ref.watch(ayahsForSurahProvider(lesson.surahId));
    final loadedSurahId = ref.watch(loadedSurahIdProvider);
    final isLoaded = loadedSurahId == lesson.surahId;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Audio (Mishary al-Afasy)',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Text(
              isLoaded
                  ? 'Audio loaded for this surah.'
                  : 'Load audio to enable ayah playback.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            ayahsAsync.when(
              data: (ayahs) {
                final ayahCount = ayahs.length;
                if (ayahCount == 0) return const SizedBox.shrink();
                return Align(
                  alignment: Alignment.centerLeft,
                  child: ElevatedButton.icon(
                    icon: isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.download),
                    label: Text(isLoaded ? 'Audio Loaded' : 'Load Audio'),
                    onPressed: isLoading || isLoaded
                        ? null
                        : () async {
                            onLoadingChanged(true);
                            try {
                              final manager = ref.read(audioManagerProvider);
                              final segmentsByAyah = await ref
                                  .read(audioSegmentsBySurahProvider(lesson.surahId).future);
                              await manager.loadSurahAudio(
                                surahId: lesson.surahId,
                                ayahCount: ayahCount,
                                segmentsByAyah: segmentsByAyah,
                              );
                              ref.read(loadedSurahIdProvider.notifier).state =
                                  lesson.surahId;
                            } finally {
                              onLoadingChanged(false);
                            }
                          },
                  ),
                );
              },
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text('Error: $e'),
            ),
          ],
        ),
      ),
    );
  }
}

class _VerseSection extends ConsumerWidget {
  const _VerseSection({required this.lesson});

  final DailyLesson lesson;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ayahsAsync = ref.watch(ayahsForSurahProvider(lesson.surahId));
    final activeWordId = ref.watch(activeWordIdProvider).value;
    final loadedSurahId = ref.watch(loadedSurahIdProvider);

    return ayahsAsync.when(
      data: (ayahs) {
        final selected = ayahs.where((a) {
          return a.ayahNumber >= lesson.ayahStart &&
              a.ayahNumber <= lesson.ayahEnd;
        }).toList();
        if (selected.isEmpty) {
          return const Text('No verses found for this lesson.');
        }
        return Column(
          children: [
            for (final ayah in selected)
              AyahWidget(
                ayah: ayah,
                highlightWordId: activeWordId,
                isAudioReady: loadedSurahId == lesson.surahId,
                onPlayAyah: () => ref.read(audioManagerProvider).playAyah(
                      surahId: lesson.surahId,
                      ayahNumber: ayah.ayahNumber,
                    ),
              ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Text('Failed to load verses: $err'),
    );
  }
}

class _ReflectionSection extends StatelessWidget {
  const _ReflectionSection({
    required this.lesson,
    required this.showFull,
    required this.onToggle,
  });

  final DailyLesson lesson;
  final bool showFull;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = showFull ? lesson.bodyFull : lesson.bodyShort;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Reflection',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              text,
              style: theme.textTheme.bodyMedium,
            ),
            if (lesson.bodyFull.isNotEmpty &&
                lesson.bodyFull != lesson.bodyShort)
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: onToggle,
                  child: Text(showFull ? 'Read less' : 'Read more'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _TakeawaySection extends StatelessWidget {
  const _TakeawaySection({required this.takeaways});

  final List<String> takeaways;

  @override
  Widget build(BuildContext context) {
    if (takeaways.isEmpty) {
      return const SizedBox.shrink();
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Takeaways',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            for (final item in takeaways)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text('- $item'),
              ),
          ],
        ),
      ),
    );
  }
}

class _SourceSection extends StatelessWidget {
  const _SourceSection({required this.source});

  final LessonSource source;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ExpansionTile(
        title: const Text('About this lesson'),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          Text('Work: ${source.work}'),
          Text('Author: ${source.author}'),
          Text('Dataset: ${source.dataset}'),
          Text('Version: ${source.version}'),
        ],
      ),
    );
  }
}

class _HistorySection extends StatelessWidget {
  const _HistorySection({
    required this.history,
    required this.onSelectDay,
  });

  final DailyLessonHistory history;
  final ValueChanged<int> onSelectDay;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Past lessons',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        for (final entry in history.recent)
          _HistoryTile(entry: entry, onSelectDay: onSelectDay),
        if (history.catchUp.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            'Catch up',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          for (final entry in history.catchUp)
            _HistoryTile(entry: entry, onSelectDay: onSelectDay),
        ],
      ],
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({
    required this.entry,
    required this.onSelectDay,
  });

  final DailyLessonHistoryEntry entry;
  final ValueChanged<int> onSelectDay;

  @override
  Widget build(BuildContext context) {
    final dateLabel =
        '${entry.date.year}-${entry.date.month.toString().padLeft(2, '0')}-${entry.date.day.toString().padLeft(2, '0')}';
    return Card(
      child: ListTile(
        title: Text(entry.lesson.title),
        subtitle: Text(dateLabel),
        trailing: entry.isCompleted
            ? const Icon(Icons.check_circle, color: Colors.green)
            : const Icon(Icons.chevron_right),
        onTap: () => onSelectDay(entry.dayIndex),
      ),
    );
  }
}
