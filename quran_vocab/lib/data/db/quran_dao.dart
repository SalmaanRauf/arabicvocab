import 'package:sqflite/sqflite.dart';

import '../models/ayah.dart';
import '../models/root.dart';
import '../models/surah.dart';
import '../models/user_progress.dart';
import '../models/word.dart';
import '../../services/audio/segment.dart';

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

  Future<List<Segment>> fetchSegmentsForSurah(int surahId) async {
    final rows = await db.rawQuery(
      '''
      SELECT words.id AS word_id, words.audio_start_ms, words.audio_end_ms
      FROM words
      INNER JOIN ayahs ON ayahs.id = words.ayah_id
      WHERE ayahs.surah_id = ?
        AND words.audio_start_ms IS NOT NULL
        AND words.audio_end_ms IS NOT NULL
      ORDER BY words.audio_start_ms ASC
      ''',
      [surahId],
    );
    return rows
        .map(
          (row) => Segment(
            wordId: row['word_id'] as int,
            startMs: row['audio_start_ms'] as int,
            endMs: row['audio_end_ms'] as int,
          ),
        )
        .toList();
  }

  Future<List<UserProgress>> fetchDueProgress(DateTime now) async {
    final rows = await db.query(
      'user_progress',
      where: 'next_review_date <= ?',
      whereArgs: [now.toIso8601String()],
      orderBy: 'next_review_date ASC',
    );
    return rows.map(UserProgress.fromMap).toList();
  }

  Future<void> upsertUserProgress(UserProgress progress) async {
    await db.insert(
      'user_progress',
      progress.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Root?> fetchRootById(int rootId) async {
    final rows = await db.query(
      'roots',
      where: 'id = ?',
      whereArgs: [rootId],
      limit: 1,
    );
    if (rows.isEmpty) {
      return null;
    }
    return Root.fromMap(rows.first);
  }
}
