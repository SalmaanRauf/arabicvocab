import 'package:sqflite/sqflite.dart';

import '../models/ayah.dart';
import '../models/root.dart';
import '../models/surah.dart';
import '../models/word.dart';

class QuranDao {
  const QuranDao(this.db);

  final Database db;

  Future<List<Surah>> fetchSurahs() async {
    final rows = await db.query(
      'surahs',
      orderBy: 'id ASC',
    );
    return rows.map(Surah.fromMap).toList();
  }

  Future<List<Ayah>> fetchAyahsForSurah(int surahId) async {
    final rows = await db.query(
      'ayahs',
      where: 'surah_id = ?',
      whereArgs: [surahId],
      orderBy: 'ayah_number ASC',
    );
    return rows.map(Ayah.fromMap).toList();
  }

  Future<List<Word>> fetchWordsForAyah(int ayahId) async {
    final rows = await db.query(
      'words',
      where: 'ayah_id = ?',
      whereArgs: [ayahId],
      orderBy: 'position ASC',
    );
    return rows.map(Word.fromMap).toList();
  }

  Future<List<Root>> searchRootsByMeaning(String query) async {
    if (query.trim().isEmpty) {
      return [];
    }
    final rows = await db.query(
      'roots',
      where: 'meaning_short LIKE ? OR meaning_long LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'frequency_count DESC',
    );
    return rows.map(Root.fromMap).toList();
  }

  Future<List<Word>> searchWords(String query) async {
    if (query.trim().isEmpty) {
      return [];
    }
    final results = await db.rawQuery(
      'SELECT word_id FROM word_search WHERE word_search MATCH ?',
      [query],
    );
    final ids = results.map((row) => row['word_id']).whereType<int>().toList();
    if (ids.isEmpty) {
      return [];
    }
    final rows = await db.query(
      'words',
      where: 'id IN (${List.filled(ids.length, '?').join(',')})',
      whereArgs: ids,
      orderBy: 'id ASC',
    );
    return rows.map(Word.fromMap).toList();
  }
}
