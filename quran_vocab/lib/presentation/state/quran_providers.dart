import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/db/quran_database.dart';
import '../../data/db/quran_dao.dart';
import '../../data/models/ayah.dart';
import '../../data/models/surah.dart';
import '../../data/models/word.dart';

final databaseProvider = FutureProvider((ref) async {
  return QuranDatabase.open();
});

final surahsProvider = FutureProvider<List<Surah>>((ref) async {
  final db = await ref.watch(databaseProvider.future);
  return QuranDao(db).fetchSurahs();
});

final selectedSurahIdProvider = StateProvider<int?>((ref) => null);

final ayahsProvider = FutureProvider<List<Ayah>>((ref) async {
  final surahId = ref.watch(selectedSurahIdProvider);
  if (surahId == null) {
    return const <Ayah>[];
  }
  final db = await ref.watch(databaseProvider.future);
  return QuranDao(db).fetchAyahsForSurah(surahId);
});

final wordsForAyahProvider =
    FutureProvider.family<List<Word>, int>((ref, int ayahId) async {
  final db = await ref.watch(databaseProvider.future);
  return QuranDao(db).fetchWordsForAyah(ayahId);
});

final searchQueryProvider = StateProvider<String>((ref) => '');

final searchResultsProvider = FutureProvider<List<Word>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  if (query.trim().isEmpty) {
    return const <Word>[];
  }
  final db = await ref.watch(databaseProvider.future);
  return QuranDao(db).searchWords(query);
});
