import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/lesson.dart';
import '../routes/app_router.dart';
import '../state/curriculum_provider.dart';

class CurriculumView extends ConsumerWidget {
  const CurriculumView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final curriculumAsync = ref.watch(curriculumProvider);
    final completedLessons = ref.watch(completedLessonsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Learning Path'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRouter.homePath),
        ),
      ),
      body: curriculumAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (units) => _buildUnitList(context, ref, units, completedLessons),
      ),
    );
  }

  Widget _buildUnitList(
    BuildContext context,
    WidgetRef ref,
    List<Unit> units,
    Set<int> completedLessons,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: units.length,
      itemBuilder: (context, index) {
        final unit = units[index];
        return _UnitCard(unit: unit, completedLessons: completedLessons);
      },
    );
  }
}

class _UnitCard extends ConsumerWidget {
  const _UnitCard({
    required this.unit,
    required this.completedLessons,
  });

  final Unit unit;
  final Set<int> completedLessons;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final completedCount =
        unit.lessons.where((l) => completedLessons.contains(l.id)).length;
    final progress = unit.lessons.isEmpty
        ? 0.0
        : completedCount / unit.lessons.length;
    final scheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: scheme.surfaceVariant,
          child: Text(
            '${unit.id}',
            style: TextStyle(
              color: scheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          unit.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              unit.description,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: scheme.surfaceVariant,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '$completedCount/${unit.lessons.length}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
        children: unit.lessons.map((lesson) {
          return _LessonTile(lesson: lesson);
        }).toList(),
      ),
    );
  }
}

class _LessonTile extends ConsumerWidget {
  const _LessonTile({required this.lesson});

  final Lesson lesson;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isUnlocked = ref.watch(lessonUnlockedProvider(lesson.id));
    final isCompleted = ref.watch(completedLessonsProvider).contains(lesson.id);
    final scheme = Theme.of(context).colorScheme;

    return ListTile(
      leading: Icon(
        isCompleted
            ? Icons.check_circle
            : isUnlocked
                ? Icons.play_circle_outline
                : Icons.lock_outline,
        color: isCompleted
            ? scheme.tertiary
            : isUnlocked
                ? scheme.primary
                : scheme.onSurfaceVariant,
      ),
      title: Text(
        lesson.title,
        style: TextStyle(
          color: isUnlocked ? null : scheme.onSurfaceVariant,
        ),
      ),
      subtitle: Text(
        '${lesson.wordCount} words',
        style: Theme.of(context).textTheme.bodySmall,
      ),
      trailing: isUnlocked ? const Icon(Icons.chevron_right) : null,
      enabled: isUnlocked,
      onTap: isUnlocked
          ? () {
              ref.read(currentLessonIdProvider.notifier).state = lesson.id;
              context.go(AppRouter.lessonPath);
            }
          : null,
    );
  }
}
