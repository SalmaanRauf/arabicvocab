import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../routes/app_router.dart';
import '../state/quran_providers.dart';

class QuranHubView extends ConsumerWidget {
  const QuranHubView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final surahsAsync = ref.watch(surahsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quran'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
            onPressed: () => context.go(AppRouter.settingsPath),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Browse',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: const InputDecoration(
                hintText: 'Search surah name or number',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                // Placeholder for future search behavior.
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _TabChip(label: 'Surahs', isActive: true),
                const SizedBox(width: 8),
                const _TabChip(label: 'Juz', isActive: false),
                const SizedBox(width: 8),
                const _TabChip(label: 'Bookmarks', isActive: false),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: surahsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(child: Text('Error: $err')),
                data: (surahs) => ListView.separated(
                  itemCount: surahs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final surah = surahs[index];
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                              theme.colorScheme.surfaceVariant,
                          child: Text(
                            '${surah.id}',
                            style: TextStyle(
                              color: theme.colorScheme.onSurface,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                surah.nameEnglish,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Text(
                              surah.nameArabic,
                              textDirection: TextDirection.rtl,
                              style: const TextStyle(
                                fontFamily: 'Amiri',
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                        subtitle: Text(
                          '${surah.verseCount} verses • ${surah.type}',
                          style: theme.textTheme.bodySmall,
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          ref.read(selectedSurahIdProvider.notifier).state =
                              surah.id;
                          context.go(AppRouter.readerPath);
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabChip extends StatelessWidget {
  const _TabChip({required this.label, required this.isActive});

  final String label;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? scheme.primary : scheme.surfaceVariant,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isActive ? scheme.onPrimary : scheme.onSurfaceVariant,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
