// This is a basic Flutter widget test.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:quran_vocab/app.dart';

void main() {
  testWidgets('App boots without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: QuranVocabApp(),
      ),
    );
    await tester.pumpAndSettle();
    // App should boot and show the home view title
    expect(find.text('Quranic Vocabulary'), findsOneWidget);
  });
}
