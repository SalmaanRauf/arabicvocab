import 'dart:convert';

import 'package:flutter/services.dart';

import 'models/ayah.dart';
import 'models/root.dart';
import 'models/surah.dart';
import 'models/word.dart';

/// Loads Quran data from bundled JSON assets.
class DataLoader {
  DataLoader._();
  static final DataLoader instance = DataLoader._();

  List<Surah>? _surahs;
  List<Ayah>? _ayahs;
  List<Word>? _words;
  List<Root>? _roots;
  Map<int, Root>? _rootsById;

  bool get isLoaded => _surahs != null;

  Future<void> load() async {
    if (isLoaded) return;

    final surahsJson = await rootBundle.loadString('assets/data/surahs.json');
    final ayahsJson =
        await rootBundle.loadString('assets/data/ayahs_sample.json');
    final wordsJson =
        await rootBundle.loadString('assets/data/words_sample.json');
    final rootsJson = await rootBundle.loadString('assets/data/roots.json');

    final surahsList = (jsonDecode(surahsJson) as List).cast<Map<String, dynamic>>();
    final ayahsList = (jsonDecode(ayahsJson) as List).cast<Map<String, dynamic>>();
    final wordsList = (jsonDecode(wordsJson) as List).cast<Map<String, dynamic>>();
    final rootsList = (jsonDecode(rootsJson) as List).cast<Map<String, dynamic>>();

    _surahs = surahsList.map((e) => Surah.fromJson(e)).toList();

    int ayahId = 1;
    _ayahs = ayahsList.map((e) {
      return Ayah(
        id: ayahId++,
        surahId: e['surah_id'] as int,
        ayahNumber: e['ayah_number'] as int,
        textUthmani: e['text_uthmani'] as String,
        textIndopak: e['text_indopak'] as String,
        translationEn: e['translation_en'] as String,
      );
    }).toList();

    _roots = rootsList.map((e) => Root.fromJson(e)).toList();
    _rootsById = {for (final r in _roots!) r.id: r};

    int wordId = 1;
    _words = wordsList.map((e) {
      final rootText = e['root'] as String? ?? '';
      final rootMatch = _roots!.where((r) => r.rootText == rootText).toList();
      return Word(
        id: wordId++,
        ayahId: _ayahs!
            .firstWhere(
              (a) =>
                  a.surahId == (e['surah_id'] as int) &&
                  a.ayahNumber == (e['ayah_number'] as int),
              orElse: () => _ayahs!.first,
            )
            .id,
        position: e['position'] as int,
        textUthmani: e['text_uthmani'] as String,
        textIndopak: e['text_uthmani'] as String,
        translationEn: e['translation_en'] as String,
        transliteration: e['transliteration'] as String,
        rootId: rootMatch.isNotEmpty ? rootMatch.first.id : null,
        lemmaId: null,
        audioStartMs: null,
        audioEndMs: null,
      );
    }).toList();
  }

  List<Surah> get surahs => _surahs ?? [];
  List<Ayah> get ayahs => _ayahs ?? [];
  List<Word> get words => _words ?? [];
  List<Root> get roots => _roots ?? [];

  Surah? getSurah(int id) => _surahs?.where((s) => s.id == id).firstOrNull;

  List<Ayah> getAyahsForSurah(int surahId) =>
      _ayahs?.where((a) => a.surahId == surahId).toList() ?? [];

  List<Word> getWordsForAyah(int ayahId) =>
      _words?.where((w) => w.ayahId == ayahId).toList() ?? [];

  Root? getRootById(int? id) => id == null ? null : _rootsById?[id];

  Root? getRootByText(String text) =>
      _roots?.where((r) => r.rootText == text).firstOrNull;

  List<Word> searchWords(String query) {
    if (query.isEmpty) return [];
    final q = query.toLowerCase();
    return _words
            ?.where((w) =>
                w.translationEn.toLowerCase().contains(q) ||
                w.transliteration.toLowerCase().contains(q))
            .toList() ??
        [];
  }
}
