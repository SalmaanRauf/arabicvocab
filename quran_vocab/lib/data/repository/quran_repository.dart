import '../db/quran_dao.dart';
import '../models/ayah.dart';
import '../models/surah.dart';
import '../models/word.dart';

class QuranRepository {
  const QuranRepository(this.dao);

  final QuranDao dao;

  Future<List<Surah>> getSurahs() => dao.fetchSurahs();

  Future<List<Ayah>> getAyahsForSurah(int surahId) =>
      dao.fetchAyahsForSurah(surahId);

  Future<List<Word>> getWordsForAyah(int ayahId) =>
      dao.fetchWordsForAyah(ayahId);

  Future<List<Word>> searchWords(String query) => dao.searchWords(query);
}
