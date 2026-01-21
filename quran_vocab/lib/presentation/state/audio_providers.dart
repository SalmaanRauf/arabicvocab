import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/db/quran_dao.dart';
import '../../services/audio/audio_manager.dart';
import '../../services/audio/segment.dart';
import 'quran_providers.dart';

final audioManagerProvider = Provider<AudioManager>((ref) {
  final manager = AudioManager();
  ref.onDispose(manager.dispose);
  return manager;
});

final audioUrlProvider = StateProvider<String>((ref) => '');

final audioSegmentsProvider = FutureProvider<List<Segment>>((ref) async {
  final surahId = ref.watch(selectedSurahIdProvider);
  if (surahId == null) {
    return const <Segment>[];
  }
  final db = await ref.watch(databaseProvider.future);
  return QuranDao(db).fetchSegmentsForSurah(surahId);
});

final audioOffsetMsProvider = StateProvider<int>((ref) => 0);

final activeWordIdProvider = StreamProvider<int?>((ref) {
  final manager = ref.watch(audioManagerProvider);
  final offset = ref.watch(audioOffsetMsProvider);
  manager.setOffsetMs(offset);
  return manager.activeWordStream;
});
