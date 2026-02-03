import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_vocab/presentation/widgets/word_chip.dart';
import 'package:quran_vocab/data/models/word.dart';

void main() {
  testWidgets('highlighted WordChip uses a non-transparent background', (tester) async {
    const word = Word(
      id: 1,
      ayahId: 1,
      position: 1,
      textUthmani: 'بِسْمِ',
      textIndopak: 'بِسۡمِ',
      translationEn: 'In the name',
      transliteration: 'bismi',
      rootId: null,
      lemmaId: null,
      audioStartMs: null,
      audioEndMs: null,
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Material(
          child: WordChip(word: word, isHighlighted: true),
        ),
      ),
    );

    final container = tester.widget<Container>(find.byType(Container).first);
    final decoration = container.decoration as BoxDecoration?;
    expect(decoration, isNotNull);
    expect(decoration!.color, isNotNull);
  });
}
