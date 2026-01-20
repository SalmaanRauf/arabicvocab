import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData light() {
    final base = ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
      useMaterial3: true,
    );

    return base.copyWith(
      textTheme: GoogleFonts.amiriTextTheme(base.textTheme),
      scaffoldBackgroundColor: const Color(0xFFF8F7F4),
    );
  }
}
