import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:quran_vocab/data/models/ayah.dart';
import 'package:quran_vocab/data/models/surah.dart';
import 'package:quran_vocab/data/models/word.dart';
import 'package:quran_vocab/presentation/state/audio_providers.dart';
import 'package:quran_vocab/presentation/state/quran_providers.dart';
import 'package:quran_vocab/presentation/views/reader_view.dart';

void main() {
  testWidgets('ReaderView hides search and shows audio controls', (tester) async {
    final surah = Surah(
      id: 1,
      nameArabic: 'الفاتحة',
      nameEnglish: 'Al-Fatiha',
      verseCount: 7,
      type: 'Meccan',
    );
    final ayah = Ayah(
      id: 1,
      surahId: 1,
      ayahNumber: 1,
      textUthmani: 'ٱلْحَمْدُ',
      textIndopak: 'اَلۡحَمۡدُ',
      translationEn: 'All praise is due to Allah.',
    );
    final words = [
      Word(
        id: 1,
        ayahId: 1,
        position: 1,
        textUthmani: 'ٱلْحَمْدُ',
        textIndopak: 'اَلۡحَمۡدُ',
        translationEn: '',
        transliteration: '',
        rootId: null,
        lemmaId: null,
        audioStartMs: null,
        audioEndMs: null,
      ),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          surahsProvider.overrideWithProvider(
            FutureProvider<List<Surah>>((ref) async => [surah]),
          ),
          ayahsProvider.overrideWithProvider(
            FutureProvider<List<Ayah>>((ref) async => [ayah]),
          ),
          wordsForAyahProvider.overrideWithProvider(
            (int _) => FutureProvider<List<Word>>((ref) async => words),
          ),
          selectedSurahIdProvider.overrideWithProvider(
            StateProvider<int?>((ref) => 1),
          ),
          activeWordIdProvider.overrideWithProvider(
            StreamProvider<int?>((ref) => Stream<int?>.value(null)),
          ),
        ],
        child: const MaterialApp(
          home: ReaderView(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Search'), findsNothing);
    expect(find.text('Load Audio'), findsOneWidget);
    expect(find.byTooltip('Play ayah'), findsOneWidget);
  });
}
