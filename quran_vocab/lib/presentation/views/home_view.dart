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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primaryContainer,
            Theme.of(context).colorScheme.primary.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Learn Quranic Arabic',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Master the top 80% most frequent vocabulary through word-by-word study and spaced repetition.',
            style: Theme.of(context).textTheme.bodyLarge,
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
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            child: Text(
              '${surah.id}',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
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
        );
      },
    );
  }
}
