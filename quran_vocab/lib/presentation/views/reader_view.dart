import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/surah.dart';
import '../../data/models/word.dart';
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
  final TextEditingController _audioUrlController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    _audioUrlController.dispose();
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
    return Consumer(
      builder: (context, ref, _) {
        final manager = ref.watch(audioManagerProvider);
        final segmentsAsync = ref.watch(audioSegmentsProvider);
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Audio',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _audioUrlController,
                  decoration: const InputDecoration(
                    hintText: 'Paste MP3 URL',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                segmentsAsync.when(
                  data: (segments) => Wrap(
                    spacing: 12,
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          final url = _audioUrlController.text.trim();
                          if (url.isEmpty) {
                            return;
                          }
                          await manager.setSource(
                            url: url,
                            segments: segments,
                          );
                        },
                        child: const Text('Load audio'),
                      ),
                      OutlinedButton(
                        onPressed: manager.play,
                        child: const Text('Play'),
                      ),
                      OutlinedButton(
                        onPressed: manager.pause,
                        child: const Text('Pause'),
                      ),
                    ],
                  ),
                  loading: () => const LinearProgressIndicator(),
                  error: (error, _) => Text('Audio segments error: $error'),
                ),
              ],
            ),
          ),
        );
      },
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
