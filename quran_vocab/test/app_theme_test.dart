import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_vocab/presentation/theme/app_theme.dart';

void main() {
  test('AppTheme.light uses parchment background', () {
    final theme = AppTheme.light();
    expect(theme.scaffoldBackgroundColor, const Color(0xFFFAF9F5));
  });

  test('AppTheme.dark uses warm noir background', () {
    final theme = AppTheme.dark();
    expect(theme.scaffoldBackgroundColor, const Color(0xFF141413));
  });
}
