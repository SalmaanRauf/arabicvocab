import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData light() {
    final scheme = ColorScheme(
      brightness: Brightness.light,
      primary: const Color(0xFFD97757),
      onPrimary: const Color(0xFF141413),
      primaryContainer: const Color(0xFFF7E3D6),
      onPrimaryContainer: const Color(0xFF4B2A1B),
      secondary: const Color(0xFF6A9BCC),
      onSecondary: Colors.white,
      secondaryContainer: const Color(0xFFDDE9F6),
      onSecondaryContainer: const Color(0xFF24435F),
      tertiary: const Color(0xFF788C5D),
      onTertiary: Colors.white,
      tertiaryContainer: const Color(0xFFE5EBD9),
      onTertiaryContainer: const Color(0xFF2E3A23),
      error: const Color(0xFFB3261E),
      onError: Colors.white,
      background: const Color(0xFFFAF9F5),
      onBackground: const Color(0xFF141413),
      surface: const Color(0xFFFFF7EC),
      onSurface: const Color(0xFF141413),
      surfaceVariant: const Color(0xFFF7F0E4),
      onSurfaceVariant: const Color(0xFF6E675E),
      outline: const Color(0xFFE8E0D3),
      outlineVariant: const Color(0xFFEDE6DB),
      shadow: const Color(0x14000000),
      scrim: const Color(0x66000000),
      inverseSurface: const Color(0xFF1B1712),
      onInverseSurface: const Color(0xFFF5EFE6),
      inversePrimary: const Color(0xFFD97757),
    );

    final base = ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
    );

    return _applyTypography(base).copyWith(
      scaffoldBackgroundColor: scheme.background,
      cardTheme: _cardTheme(scheme),
      appBarTheme: _appBarTheme(scheme, Brightness.light),
      inputDecorationTheme: _inputDecorationTheme(scheme),
      dividerTheme: DividerThemeData(color: scheme.outline),
      filledButtonTheme: _filledButtonTheme(scheme),
      outlinedButtonTheme: _outlinedButtonTheme(scheme),
      textButtonTheme: _textButtonTheme(scheme),
    );
  }

  static ThemeData dark() {
    final scheme = ColorScheme(
      brightness: Brightness.dark,
      primary: const Color(0xFFD97757),
      onPrimary: const Color(0xFF141413),
      primaryContainer: const Color(0xFF4B2A1B),
      onPrimaryContainer: const Color(0xFFF7E3D6),
      secondary: const Color(0xFF6A9BCC),
      onSecondary: const Color(0xFF0F1B27),
      secondaryContainer: const Color(0xFF243749),
      onSecondaryContainer: const Color(0xFFDDE9F6),
      tertiary: const Color(0xFF788C5D),
      onTertiary: const Color(0xFF192016),
      tertiaryContainer: const Color(0xFF2E3A23),
      onTertiaryContainer: const Color(0xFFE5EBD9),
      error: const Color(0xFFF2B8B5),
      onError: const Color(0xFF601410),
      background: const Color(0xFF141413),
      onBackground: const Color(0xFFF5EFE6),
      surface: const Color(0xFF1B1712),
      onSurface: const Color(0xFFF5EFE6),
      surfaceVariant: const Color(0xFF221C16),
      onSurfaceVariant: const Color(0xFFC7BBAA),
      outline: const Color(0xFF2F281F),
      outlineVariant: const Color(0xFF3A3328),
      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: const Color(0xFFFAF9F5),
      onInverseSurface: const Color(0xFF141413),
      inversePrimary: const Color(0xFFD97757),
    );

    final base = ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
    );

    return _applyTypography(base).copyWith(
      scaffoldBackgroundColor: scheme.background,
      cardTheme: _cardTheme(scheme),
      appBarTheme: _appBarTheme(scheme, Brightness.dark),
      inputDecorationTheme: _inputDecorationTheme(scheme),
      dividerTheme: DividerThemeData(color: scheme.outline),
      filledButtonTheme: _filledButtonTheme(scheme),
      outlinedButtonTheme: _outlinedButtonTheme(scheme),
      textButtonTheme: _textButtonTheme(scheme),
    );
  }

  static ThemeData _applyTypography(ThemeData base) {
    final textTheme = GoogleFonts.loraTextTheme(base.textTheme);
    return base.copyWith(
      textTheme: textTheme.copyWith(
        displayLarge: GoogleFonts.poppins(textStyle: textTheme.displayLarge),
        displayMedium: GoogleFonts.poppins(textStyle: textTheme.displayMedium),
        displaySmall: GoogleFonts.poppins(textStyle: textTheme.displaySmall),
        headlineLarge: GoogleFonts.poppins(textStyle: textTheme.headlineLarge),
        headlineMedium: GoogleFonts.poppins(textStyle: textTheme.headlineMedium),
        headlineSmall: GoogleFonts.poppins(textStyle: textTheme.headlineSmall),
        titleLarge: GoogleFonts.poppins(textStyle: textTheme.titleLarge),
        titleMedium: GoogleFonts.poppins(textStyle: textTheme.titleMedium),
        titleSmall: GoogleFonts.poppins(textStyle: textTheme.titleSmall),
      ),
    );
  }

  static CardTheme _cardTheme(ColorScheme scheme) {
    return CardTheme(
      color: scheme.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: scheme.outline),
      ),
      margin: const EdgeInsets.all(0),
    );
  }

  static AppBarTheme _appBarTheme(ColorScheme scheme, Brightness brightness) {
    return AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: scheme.background,
      foregroundColor: scheme.onBackground,
      centerTitle: true,
      titleTextStyle: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: scheme.onBackground,
      ),
      iconTheme: IconThemeData(color: scheme.onBackground),
    );
  }

  static InputDecorationTheme _inputDecorationTheme(ColorScheme scheme) {
    return InputDecorationTheme(
      filled: true,
      fillColor: scheme.surfaceVariant,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: scheme.outline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: scheme.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: scheme.primary, width: 1.5),
      ),
    );
  }

  static FilledButtonThemeData _filledButtonTheme(ColorScheme scheme) {
    return FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  static OutlinedButtonThemeData _outlinedButtonTheme(ColorScheme scheme) {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: scheme.onSurface,
        side: BorderSide(color: scheme.outline),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  static TextButtonThemeData _textButtonTheme(ColorScheme scheme) {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: scheme.primary,
        textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
      ),
    );
  }
}
