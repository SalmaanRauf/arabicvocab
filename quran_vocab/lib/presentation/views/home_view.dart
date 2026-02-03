import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../routes/app_router.dart';
import '../state/quran_providers.dart';

class HomeView extends ConsumerWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final surahsAsync = ref.watch(surahsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quranic Vocabulary'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            tooltip: 'Progress',
            onPressed: () => context.go(AppRouter.dashboardPath),
          ),
          IconButton(
            icon: const Icon(Icons.menu_book),
            tooltip: 'Learning Path',
            onPressed: () => context.go(AppRouter.curriculumPath),
          ),
          IconButton(
            icon: const Icon(Icons.school),
            tooltip: 'Review',
            onPressed: () => context.go(AppRouter.reviewPath),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
            onPressed: () => context.go(AppRouter.settingsPath),
          ),
        ],
      ),
      body: surahsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (surahs) => Column(
          children: [
            _buildHeader(context),
            Expanded(child: _buildSurahList(context, ref, surahs)),
          ],
        ),
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
            'Master the top 80% most frequent vocabulary through word-by-word study and spaced repetition.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: isDark ? scheme.onPrimary.withOpacity(0.9) : scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSurahList(
      BuildContext context, WidgetRef ref, List surahs) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: surahs.length,
      itemBuilder: (context, index) {
        final surah = surahs[index];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                child: Text(
                  '${surah.id}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Row(
                children: [
                  Expanded(
                    child: Text(
                      surah.nameEnglish,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Text(
                    surah.nameArabic,
                    style: const TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 18,
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                ],
              ),
              subtitle: Text(
                '${surah.verseCount} verses • ${surah.type}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                ref.read(selectedSurahIdProvider.notifier).state = surah.id;
                context.go(AppRouter.readerPath);
              },
            ),
          ),
        );
      },
    );
  }
}
