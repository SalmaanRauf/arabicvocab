import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

class QuranDatabase {
  QuranDatabase._();

  static Database? _db;
  static const int _dbVersion = 1;
  static const String dbName = 'quran.db';

  static Future<Database> open() async {
    if (_db != null) {
      return _db!;
    }
    if (kIsWeb) {
      databaseFactory = databaseFactoryFfiWeb;
    }
    final dbPath = await _resolvePath();
    _db = await openDatabase(
      dbPath,
      version: _dbVersion,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, version) async {
        await _createSchema(db);
      },
    );
    return _db!;
  }

  static Future<void> close() async {
    final db = _db;
    _db = null;
    if (db != null) {
      await db.close();
    }
  }

  static Future<String> _resolvePath() async {
    if (kIsWeb) {
      return dbName;
    }
    final dir = await getDatabasesPath();
    return path.join(dir, dbName);
  }

  static Future<void> _createSchema(Database db) async {
    await db.execute('''
      CREATE TABLE surahs (
        id INTEGER PRIMARY KEY,
        name_arabic TEXT NOT NULL,
        name_english TEXT NOT NULL,
        verse_count INTEGER NOT NULL,
        type TEXT NOT NULL
      );
    ''');

    await db.execute('''
      CREATE TABLE ayahs (
        id INTEGER PRIMARY KEY,
        surah_id INTEGER NOT NULL,
        ayah_number INTEGER NOT NULL,
        text_uthmani TEXT NOT NULL,
        text_indopak TEXT NOT NULL,
        translation_en TEXT NOT NULL,
        FOREIGN KEY (surah_id) REFERENCES surahs(id) ON DELETE CASCADE
      );
    ''');

    await db.execute('''
      CREATE TABLE roots (
        id INTEGER PRIMARY KEY,
        root_text TEXT NOT NULL,
        frequency_count INTEGER NOT NULL,
        meaning_short TEXT NOT NULL,
        meaning_long TEXT NOT NULL
      );
    ''');

    await db.execute('''
      CREATE TABLE lemmas (
        id INTEGER PRIMARY KEY,
        lemma_text TEXT NOT NULL,
        root_id INTEGER,
        frequency_rank INTEGER NOT NULL,
        FOREIGN KEY (root_id) REFERENCES roots(id) ON DELETE SET NULL
      );
    ''');

    await db.execute('''
      CREATE TABLE words (
        id INTEGER PRIMARY KEY,
        ayah_id INTEGER NOT NULL,
        position INTEGER NOT NULL,
        text_uthmani TEXT NOT NULL,
        text_indopak TEXT NOT NULL,
        translation_en TEXT NOT NULL,
        transliteration TEXT NOT NULL,
        root_id INTEGER,
        lemma_id INTEGER,
        audio_start_ms INTEGER,
        audio_end_ms INTEGER,
        FOREIGN KEY (ayah_id) REFERENCES ayahs(id) ON DELETE CASCADE,
        FOREIGN KEY (root_id) REFERENCES roots(id) ON DELETE SET NULL,
        FOREIGN KEY (lemma_id) REFERENCES lemmas(id) ON DELETE SET NULL
      );
    ''');

    await db.execute('''
      CREATE TABLE user_progress (
        root_id INTEGER PRIMARY KEY,
        srs_stage TEXT NOT NULL,
        stability REAL NOT NULL,
        difficulty REAL NOT NULL,
        next_review_date TEXT NOT NULL,
        FOREIGN KEY (root_id) REFERENCES roots(id) ON DELETE CASCADE
      );
    ''');

    await db.execute('''
      CREATE TABLE curriculum (
        id INTEGER PRIMARY KEY,
        lesson_id INTEGER NOT NULL,
        root_id INTEGER NOT NULL,
        order_index INTEGER NOT NULL,
        FOREIGN KEY (root_id) REFERENCES roots(id) ON DELETE CASCADE
      );
    ''');

    await db.execute('''
      CREATE VIRTUAL TABLE word_search USING fts5(
        content,
        word_id UNINDEXED
      );
    ''');

    await db.execute('CREATE INDEX idx_ayahs_surah ON ayahs(surah_id);');
    await db.execute('CREATE INDEX idx_words_ayah ON words(ayah_id);');
    await db.execute('CREATE INDEX idx_words_root ON words(root_id);');
  }
}
