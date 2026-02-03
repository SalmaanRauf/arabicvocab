import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_vocab/presentation/views/settings_view.dart';

void main() {
  testWidgets('Settings shows theme toggle', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: SettingsView()),
      ),
    );
    expect(find.text('Appearance'), findsOneWidget);
    expect(find.byType(Switch), findsOneWidget);
  });
}
