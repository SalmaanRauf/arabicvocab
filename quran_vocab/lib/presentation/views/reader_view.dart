import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/surah.dart';
import '../../data/models/word.dart';
import '../routes/app_router.dart';
import '../state/audio_providers.dart';
import '../state/quran_providers.dart';
import '../widgets/ayah_widget.dart';

class ReaderView extends ConsumerStatefulWidget {
  const ReaderView({super.key});

  @override
  ConsumerState<ReaderView> createState() => _ReaderViewState();
}

class _ReaderViewState extends ConsumerState<ReaderView> {
  final TextEditingController _searchController = TextEditingController();
  int _currentAyahForAudio = 1;
  bool _isAudioLoading = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final surahsAsync = ref.watch(surahsProvider);
    final ayahsAsync = ref.watch(ayahsProvider);
    final searchResultsAsync = ref.watch(searchResultsProvider);
    final selectedSurahId = ref.watch(selectedSurahIdProvider);
    final activeWordId = ref.watch(activeWordIdProvider).value;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRouter.homePath),
        ),
        title: const Text('Reader'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSearchCard(searchResultsAsync),
          const SizedBox(height: 16),
          _buildAudioControls(),
          const SizedBox(height: 16),
          _buildSurahPicker(
            surahsAsync: surahsAsync,
            selectedSurahId: selectedSurahId,
          ),
          const SizedBox(height: 16),
          ayahsAsync.when(
            data: (ayahs) {
              if (ayahs.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Text('Select a surah to begin.'),
                  ),
                );
              }
              return Column(
                children: [
                  for (final ayah in ayahs)
                    AyahWidget(
                      ayah: ayah,
                      highlightWordId: activeWordId,
                    ),
                ],
              );
            },
            loading: () => const Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, _) => Padding(
              padding: const EdgeInsets.all(24),
              child: Text('Failed to load ayahs: $error'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchCard(AsyncValue<List<Word>> searchResultsAsync) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Search',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search English meaning',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                ref.read(searchQueryProvider.notifier).state = value;
              },
            ),
            const SizedBox(height: 12),
            searchResultsAsync.when(
              data: (words) {
                if (words.isEmpty) {
                  return const Text('No results yet.');
                }
                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final word in words.take(12))
                      Chip(
                        label: Text(word.textUthmani),
                      ),
                  ],
                );
              },
              loading: () => const LinearProgressIndicator(),
              error: (error, _) => Text('Search failed: $error'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAudioControls() {
    final selectedSurahId = ref.watch(selectedSurahIdProvider) ?? 1;
    final ayahsAsync = ref.watch(ayahsProvider);

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
            ayahsAsync.when(
              data: (ayahs) {
                if (ayahs.isEmpty) return const SizedBox.shrink();
                // Ensure current ayah is valid for this surah
                final maxAyah = ayahs.length;
                if (_currentAyahForAudio > maxAyah) {
                  _currentAyahForAudio = 1;
                }
                return Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        value: _currentAyahForAudio,
                        decoration: const InputDecoration(
                          labelText: 'Ayah',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: List.generate(
                          maxAyah,
                          (i) => DropdownMenuItem(
                            value: i + 1,
                            child: Text('Ayah ${i + 1}'),
                          ),
                        ),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _currentAyahForAudio = value;
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      icon: _isAudioLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.download),
                      label: const Text('Load'),
                      onPressed: _isAudioLoading
                          ? null
                          : () async {
                              setState(() => _isAudioLoading = true);
                              try {
                                final manager = ref.read(audioManagerProvider);
                                await manager.loadAyahAudio(
                                  surahId: selectedSurahId,
                                  ayahNumber: _currentAyahForAudio,
                                );
                              } finally {
                                setState(() => _isAudioLoading = false);
                              }
                            },
                    ),
                  ],
                );
              },
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text('Error: $e'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                OutlinedButton.icon(
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Play'),
                  onPressed: () => ref.read(audioManagerProvider).play(),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  icon: const Icon(Icons.pause),
                  label: const Text('Pause'),
                  onPressed: () => ref.read(audioManagerProvider).pause(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSurahPicker({
    required AsyncValue<List<Surah>> surahsAsync,
    required int? selectedSurahId,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: surahsAsync.when(
          data: (surahs) {
            if (surahs.isEmpty) {
              return const Text('No surahs loaded yet.');
            }
            if (selectedSurahId == null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ref.read(selectedSurahIdProvider.notifier).state =
                    surahs.first.id;
              });
            }
            return DropdownButtonFormField<int>(
              value: selectedSurahId ?? surahs.first.id,
              decoration: const InputDecoration(
                labelText: 'Surah',
                border: OutlineInputBorder(),
              ),
              items: surahs
                  .map<DropdownMenuItem<int>>(
                    (surah) => DropdownMenuItem<int>(
                      value: surah.id,
                      child: Text('${surah.id}. ${surah.nameEnglish}'),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                ref.read(selectedSurahIdProvider.notifier).state = value;
              },
            );
          },
          loading: () => const LinearProgressIndicator(),
          error: (error, _) => Text('Failed to load surahs: $error'),
        ),
      ),
    );
  }
}
