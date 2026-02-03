import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/surah.dart';
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
  bool _isAudioLoading = false;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final surahsAsync = ref.watch(surahsProvider);
    final ayahsAsync = ref.watch(ayahsProvider);
    final selectedSurahId = ref.watch(selectedSurahIdProvider);
    final loadedSurahId = ref.watch(loadedSurahIdProvider);
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
                      isAudioReady: selectedSurahId != null &&
                          loadedSurahId == selectedSurahId,
                      onPlayAyah: selectedSurahId == null
                          ? null
                          : () => ref.read(audioManagerProvider).playAyah(
                                surahId: selectedSurahId,
                                ayahNumber: ayah.ayahNumber,
                              ),
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

  Widget _buildAudioControls() {
    final selectedSurahId = ref.watch(selectedSurahIdProvider) ?? 1;
    final loadedSurahId = ref.watch(loadedSurahIdProvider);
    final ayahsAsync = ref.watch(ayahsProvider);
    final isLoaded = loadedSurahId == selectedSurahId;

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
                    icon: _isAudioLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.download),
                    label: Text(isLoaded ? 'Audio Loaded' : 'Load Audio'),
                    onPressed: _isAudioLoading || isLoaded
                        ? null
                        : () async {
                            setState(() => _isAudioLoading = true);
                            try {
                              final manager = ref.read(audioManagerProvider);
                              await manager.loadSurahAudio(
                                surahId: selectedSurahId,
                                ayahCount: ayahCount,
                              );
                              ref
                                  .read(loadedSurahIdProvider.notifier)
                                  .state = selectedSurahId;
                            } finally {
                              setState(() => _isAudioLoading = false);
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
                ref.read(loadedSurahIdProvider.notifier).state = null;
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
