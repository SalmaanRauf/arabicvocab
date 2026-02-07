import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quran_vocab/presentation/theme/app_theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  test('AppTheme.light uses calm parchment background', () {
    final theme = AppTheme.light();
    expect(theme.scaffoldBackgroundColor, const Color(0xFFF7F4EF));
  });

  test('AppTheme.dark uses deep noir background', () {
    final theme = AppTheme.dark();
    expect(theme.scaffoldBackgroundColor, const Color(0xFF141413));
  });
}
