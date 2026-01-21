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
    // Just pump a few frames, don't wait for settle (async data loading)
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    
    // App should show loading or home view
    expect(find.byType(QuranVocabApp), findsOneWidget);
  });
}
