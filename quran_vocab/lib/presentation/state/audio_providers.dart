import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/audio_alignment_loader.dart';
import '../../services/audio/audio_manager.dart';
import '../../services/audio/segment.dart';
import 'quran_providers.dart';

final audioManagerProvider = Provider<AudioManager>((ref) {
  final manager = AudioManager();
  ref.onDispose(manager.dispose);
  return manager;
});

final audioUrlProvider = StateProvider<String>((ref) => '');

final audioOffsetMsProvider = StateProvider<int>((ref) => 0);

final loadedSurahIdProvider = StateProvider<int?>((ref) => null);

final audioAlignmentProvider = FutureProvider<AudioAlignmentLoader>((ref) async {
  final loader = AudioAlignmentLoader.instance;
  await loader.load();
  return loader;
});

final audioSegmentsBySurahProvider =
    FutureProvider.family<Map<int, List<Segment>>, int>((ref, surahId) async {
  final loader = await ref.watch(dataLoaderProvider.future);
  final alignment = await ref.watch(audioAlignmentProvider.future);
  final ayahs = loader.getAyahsForSurah(surahId);
  final segmentsByAyah = <int, List<Segment>>{};

  for (final ayah in ayahs) {
    final raw = alignment.getRawSegments(surahId, ayah.ayahNumber);
    final words = loader.getWordsForAyah(ayah.id);
    segmentsByAyah[ayah.ayahNumber] =
        AudioAlignmentLoader.buildSegmentsForAyah(words, raw);
  }

  return segmentsByAyah;
});

final activeWordIdProvider = StreamProvider<int?>((ref) {
  final manager = ref.watch(audioManagerProvider);
  final offset = ref.watch(audioOffsetMsProvider);
  manager.setOffsetMs(offset);
  return manager.activeWordStream;
});
