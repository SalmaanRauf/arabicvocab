import 'dart:convert';

import 'package:flutter/services.dart';

import 'models/ayah.dart';
import 'models/daily_lesson.dart';
import 'models/root.dart';
import 'models/surah.dart';
import 'models/word.dart';

/// Loads Quran data from bundled JSON assets.
class DataLoader {
  DataLoader._();
  static final DataLoader instance = DataLoader._();

  List<Surah>? _surahs;
  List<Ayah>? _ayahs;
  Map<int, List<Word>>? _wordsByAyahId;
  List<Word>? _allWords;
  List<Root>? _roots;
  Map<int, Root>? _rootsById;
  List<DailyLesson>? _dailyLessons;
  Map<int, DailyLesson>? _dailyLessonsByDay;
  Map<String, DailyLesson>? _dailyLessonsById;

  bool get isLoaded => _surahs != null;

  Future<void> load() async {
    if (isLoaded) return;

    final surahsJson = await rootBundle.loadString('assets/data/surahs.json');
    final ayahsJson = await rootBundle.loadString('assets/data/ayahs_full.json');
    final wordsJson = await rootBundle.loadString('assets/data/words_full.json');
    final rootsJson = await rootBundle.loadString('assets/data/roots.json');
    final dailyLessonsJson =
        await rootBundle.loadString('assets/data/daily_lessons.json');

    final surahsList = (jsonDecode(surahsJson) as List).cast<Map<String, dynamic>>();
    final ayahsList = (jsonDecode(ayahsJson) as List).cast<Map<String, dynamic>>();
    final wordsList = (jsonDecode(wordsJson) as List).cast<Map<String, dynamic>>();
    final rootsList = (jsonDecode(rootsJson) as List).cast<Map<String, dynamic>>();
    final dailyLessonsList =
        (jsonDecode(dailyLessonsJson) as List).cast<Map<String, dynamic>>();

    _surahs = surahsList.map((e) => Surah.fromJson(e)).toList();
    _roots = rootsList.map((e) => Root.fromJson(e)).toList();
    _rootsById = {for (final r in _roots!) r.id: r};
    _dailyLessons = dailyLessonsList.map(DailyLesson.fromJson).toList();
    _dailyLessonsByDay = {
      for (final lesson in _dailyLessons!) lesson.dayIndex: lesson,
    };
    _dailyLessonsById = {
      for (final lesson in _dailyLessons!) lesson.id: lesson,
    };

    // Build ayahs with sequential IDs
    int ayahId = 1;
    final ayahIdMap = <String, int>{}; // "surah:ayah" -> ayahId
    _ayahs = ayahsList.map((e) {
      final surahId = e['surah_id'] as int;
      final ayahNumber = e['ayah_number'] as int;
      final key = '$surahId:$ayahNumber';
      ayahIdMap[key] = ayahId;
      return Ayah(
        id: ayahId++,
        surahId: surahId,
        ayahNumber: ayahNumber,
        textUthmani: e['text_uthmani'] as String,
        textIndopak: e['text_indopak'] as String? ?? e['text_uthmani'] as String,
        translationEn: e['translation_en'] as String,
      );
    }).toList();

    // Build words from sample data
    _wordsByAyahId = {};
    _allWords = [];
    int wordId = 1;

    // First, load explicit word data from words_sample.json
    final explicitWords = <String, List<Word>>{}; // "surah:ayah" -> words
    for (final e in wordsList) {
      final surahId = e['surah_id'] as int;
      final ayahNumber = e['ayah_number'] as int;
      final key = '$surahId:$ayahNumber';
      final aId = ayahIdMap[key];
      if (aId == null) continue;

      final rootText = e['root'] as String? ?? '';
      final rootMatch = _roots!.where((r) => r.rootText == rootText).toList();

      final word = Word(
        id: wordId++,
        ayahId: aId,
        position: e['position'] as int,
        textUthmani: e['text_uthmani'] as String,
        textIndopak: e['text_indopak'] as String? ?? e['text_uthmani'] as String,
        translationEn: e['translation_en'] as String,
        transliteration: e['transliteration'] as String,
        rootId: rootMatch.isNotEmpty ? rootMatch.first.id : null,
        lemmaId: null,
        audioStartMs: null,
        audioEndMs: null,
      );

      explicitWords.putIfAbsent(key, () => []).add(word);
      _allWords!.add(word);
    }

    // For each ayah, use explicit words if available, otherwise split text
    for (final ayah in _ayahs!) {
      final key = '${ayah.surahId}:${ayah.ayahNumber}';
      if (explicitWords.containsKey(key)) {
        _wordsByAyahId![ayah.id] = explicitWords[key]!;
      } else {
        // Generate basic words by splitting Arabic text (both Uthmani and IndoPak)
        final uthmaniWords = ayah.textUthmani.split(' ').where((w) => w.isNotEmpty).toList();
        final indopakWords = ayah.textIndopak.split(' ').where((w) => w.isNotEmpty).toList();
        final generatedWords = <Word>[];
        for (int i = 0; i < uthmaniWords.length; i++) {
          // Use corresponding IndoPak word if available, otherwise fallback to Uthmani
          final indopakWord = i < indopakWords.length ? indopakWords[i] : uthmaniWords[i];
          final word = Word(
            id: wordId++,
            ayahId: ayah.id,
            position: i + 1,
            textUthmani: uthmaniWords[i],
            textIndopak: indopakWord,
            translationEn: '', // No translation for auto-split words
            transliteration: '',
            rootId: null,
            lemmaId: null,
            audioStartMs: null,
            audioEndMs: null,
          );
          generatedWords.add(word);
          _allWords!.add(word);
        }
        _wordsByAyahId![ayah.id] = generatedWords;
      }
    }
  }

  List<Surah> get surahs => _surahs ?? [];
  List<Ayah> get ayahs => _ayahs ?? [];
  List<Word> get words => _allWords ?? [];
  List<Root> get roots => _roots ?? [];
  List<DailyLesson> get dailyLessons => _dailyLessons ?? [];

  Surah? getSurah(int id) => _surahs?.where((s) => s.id == id).firstOrNull;

  List<Ayah> getAyahsForSurah(int surahId) =>
      _ayahs?.where((a) => a.surahId == surahId).toList() ?? [];

  List<Word> getWordsForAyah(int ayahId) => _wordsByAyahId?[ayahId] ?? [];

  List<Word> getWordsForSurah(int surahId) {
    final surahAyahs = getAyahsForSurah(surahId);
    final words = <Word>[];
    for (final ayah in surahAyahs) {
      words.addAll(getWordsForAyah(ayah.id));
    }
    return words;
  }

  Root? getRootById(int? id) => id == null ? null : _rootsById?[id];

  Root? getRootByText(String text) =>
      _roots?.where((r) => r.rootText == text).firstOrNull;

  DailyLesson? getLessonByDay(int dayIndex) => _dailyLessonsByDay?[dayIndex];

  DailyLesson? getLessonById(String id) => _dailyLessonsById?[id];

  List<Word> searchWords(String query) {
    if (query.isEmpty) return [];
    final q = query.toLowerCase();
    // Only search words that have translations (from explicit word data)
    return _allWords
            ?.where((w) =>
                w.translationEn.isNotEmpty &&
                (w.translationEn.toLowerCase().contains(q) ||
                    w.transliteration.toLowerCase().contains(q)))
            .toList() ??
        [];
  }
}
