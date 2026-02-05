import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/surah.dart';
import '../routes/app_router.dart';
import '../state/dashboard_provider.dart';
import '../state/daily_lesson_providers.dart';
import '../state/quran_providers.dart';
import '../state/settings_providers.dart';

class HomeView extends ConsumerWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final surahsAsync = ref.watch(surahsProvider);
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: Icon(
              themeMode == ThemeMode.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            tooltip: 'Toggle theme',
            onPressed: () {
              ref.read(themeModeProvider.notifier).state =
                  themeMode == ThemeMode.dark
                      ? ThemeMode.light
                      : ThemeMode.dark;
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
            onPressed: () => context.go(AppRouter.settingsPath),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHeader(context),
          const SizedBox(height: 16),
          const _DailyLessonCard(),
          const SizedBox(height: 16),
          _ContinueReadingCard(surahsAsync: surahsAsync),
          const SizedBox(height: 16),
          const _QuickActions(),
          const SizedBox(height: 16),
          const _ProgressSnapshot(),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? const [
                  Color(0xFF2A1E10),
                  Color(0xFF7B4C1B),
                  Color(0xFFD97757),
                ]
              : const [
                  Color(0xFFFFF2E5),
                  Color(0xFFF7E3D6),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: scheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Learn Quranic Arabic',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: isDark ? scheme.onPrimary : scheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Build a consistent daily habit with short lessons, word-by-word study, and review.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: isDark ? scheme.onPrimary.withOpacity(0.9) : scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _DailyLessonCard extends ConsumerWidget {
  const _DailyLessonCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lessonAsync = ref.watch(todayLessonProvider);
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: lessonAsync.when(
            data: (lesson) {
              if (lesson == null) {
                return const Text('Daily lesson unavailable.');
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Today\'s Lesson',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    lesson.title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Surah ${lesson.surahId}, Ayah ${lesson.ayahStart}-${lesson.ayahEnd}',
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: FilledButton(
                      onPressed: () => context.go(AppRouter.dailyLessonPath),
                      child: const Text('Open lesson'),
                    ),
                  ),
                ],
              );
            },
            loading: () => const LinearProgressIndicator(),
            error: (err, _) => Text('Failed to load lesson: $err'),
          ),
        ),
      ),
    );
  }
}

class _ContinueReadingCard extends ConsumerWidget {
  const _ContinueReadingCard({required this.surahsAsync});

  final AsyncValue<List<Surah>> surahsAsync;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: surahsAsync.when(
          loading: () => const LinearProgressIndicator(),
          error: (err, _) => Text('Failed to load surahs: $err'),
          data: (surahs) {
            if (surahs.isEmpty) {
              return const Text('No surahs available.');
            }
            final selectedId = ref.watch(selectedSurahIdProvider);
            final surah = surahs.firstWhere(
              (s) => s.id == selectedId,
              orElse: () => surahs.first,
            );
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Continue Reading',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  surah.nameEnglish,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  surah.nameArabic,
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: FilledButton(
                    onPressed: () {
                      ref.read(selectedSurahIdProvider.notifier).state =
                          surah.id;
                      context.go(AppRouter.readerPath);
                    },
                    child: const Text('Resume'),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _ActionTile(
              icon: Icons.today,
              label: 'Daily',
              onTap: () => context.go(AppRouter.dailyLessonPath),
            ),
            _ActionTile(
              icon: Icons.menu_book,
              label: 'Quran',
              onTap: () => context.go(AppRouter.quranPath),
            ),
            _ActionTile(
              icon: Icons.school,
              label: 'Review',
              onTap: () => context.go(AppRouter.reviewPath),
            ),
            _ActionTile(
              icon: Icons.bar_chart,
              label: 'Progress',
              onTap: () => context.go(AppRouter.progressPath),
            ),
          ],
        ),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        width: 140,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: scheme.outline),
        ),
        child: Row(
          children: [
            Icon(icon, color: scheme.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressSnapshot extends ConsumerWidget {
  const _ProgressSnapshot();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coverage = ref.watch(quranCoverageProvider);
    final wordsDue = ref.watch(wordsDueProvider);
    final streakAsync = ref.watch(streakProvider);
    final scheme = Theme.of(context).colorScheme;
    final percentText = (coverage * 100).toStringAsFixed(0);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Progress Snapshot',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _StatTile(
                    label: 'Coverage',
                    value: '$percentText%',
                    icon: Icons.pie_chart,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: streakAsync.when(
                    data: (streak) => _StatTile(
                      label: 'Streak',
                      value: '$streak days',
                      icon: Icons.local_fire_department,
                    ),
                    loading: () => const _StatTile(
                      label: 'Streak',
                      value: '--',
                      icon: Icons.local_fire_department,
                    ),
                    error: (_, __) => const _StatTile(
                      label: 'Streak',
                      value: '--',
                      icon: Icons.local_fire_department,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: scheme.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.schedule, color: scheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    '$wordsDue words due for review',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: scheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
