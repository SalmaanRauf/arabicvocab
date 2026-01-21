import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/data_loader.dart';
import '../../data/models/ayah.dart';
import '../../data/models/root.dart';
import '../../data/models/surah.dart';
import '../../data/models/word.dart';

final dataLoaderProvider = FutureProvider((ref) async {
  final loader = DataLoader.instance;
  await loader.load();
  return loader;
});

final surahsProvider = FutureProvider<List<Surah>>((ref) async {
  final loader = await ref.watch(dataLoaderProvider.future);
  return loader.surahs;
});

final selectedSurahIdProvider = StateProvider<int?>((ref) => 1);

final selectedSurahProvider = FutureProvider<Surah?>((ref) async {
  final loader = await ref.watch(dataLoaderProvider.future);
  final surahId = ref.watch(selectedSurahIdProvider);
  if (surahId == null) return null;
  return loader.getSurah(surahId);
});

final ayahsProvider = FutureProvider<List<Ayah>>((ref) async {
  final loader = await ref.watch(dataLoaderProvider.future);
  final surahId = ref.watch(selectedSurahIdProvider);
  if (surahId == null) {
    return const <Ayah>[];
  }
  return loader.getAyahsForSurah(surahId);
});

final wordsForAyahProvider =
    FutureProvider.family<List<Word>, int>((ref, int ayahId) async {
  final loader = await ref.watch(dataLoaderProvider.future);
  return loader.getWordsForAyah(ayahId);
});

final rootByIdProvider =
    FutureProvider.family<Root?, int?>((ref, int? rootId) async {
  if (rootId == null) return null;
  final loader = await ref.watch(dataLoaderProvider.future);
  return loader.getRootById(rootId);
});

final searchQueryProvider = StateProvider<String>((ref) => '');

final searchResultsProvider = FutureProvider<List<Word>>((ref) async {
  final loader = await ref.watch(dataLoaderProvider.future);
  final query = ref.watch(searchQueryProvider);
  if (query.trim().isEmpty) {
    return const <Word>[];
  }
  return loader.searchWords(query);
});
