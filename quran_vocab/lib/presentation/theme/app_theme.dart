import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static bool get _useGoogleFonts => GoogleFonts.config.allowRuntimeFetching;

  static TextTheme _loraTextTheme(TextTheme base) {
    return _useGoogleFonts ? GoogleFonts.loraTextTheme(base) : base;
  }

  static TextStyle _soraTextStyle([TextStyle? base]) {
    return _useGoogleFonts
        ? GoogleFonts.sora(textStyle: base)
        : (base ?? const TextStyle());
  }

  static ThemeData light() {
    final scheme = ColorScheme(
      brightness: Brightness.light,
      primary: const Color(0xFF2E8B7E),
      onPrimary: Colors.white,
      primaryContainer: const Color(0xFFD9F2EC),
      onPrimaryContainer: const Color(0xFF0E2C27),
      secondary: const Color(0xFFC8A25E),
      onSecondary: const Color(0xFF2B1E08),
      secondaryContainer: const Color(0xFFF4E8D0),
      onSecondaryContainer: const Color(0xFF3D2B10),
      tertiary: const Color(0xFF6A8A7A),
      onTertiary: const Color(0xFF0F1F1B),
      tertiaryContainer: const Color(0xFFDBE7E2),
      onTertiaryContainer: const Color(0xFF22322C),
      error: const Color(0xFFB3261E),
      onError: Colors.white,
      background: const Color(0xFFF7F4EF),
      onBackground: const Color(0xFF1E1E1E),
      surface: const Color(0xFFFFFFFF),
      onSurface: const Color(0xFF1E1E1E),
      surfaceVariant: const Color(0xFFF0ECE6),
      onSurfaceVariant: const Color(0xFF5A5A5A),
      outline: const Color(0xFFE6E2DA),
      outlineVariant: const Color(0xFFEDE6DB),
      shadow: const Color(0x14000000),
      scrim: const Color(0x66000000),
      inverseSurface: const Color(0xFF1B1712),
      onInverseSurface: const Color(0xFFF5EFE6),
      inversePrimary: const Color(0xFF2E8B7E),
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
      primary: const Color(0xFF3FAE9A),
      onPrimary: const Color(0xFF0F1F1C),
      primaryContainer: const Color(0xFF1C4A43),
      onPrimaryContainer: const Color(0xFFD4F0EA),
      secondary: const Color(0xFFD5B36C),
      onSecondary: const Color(0xFF2A1D09),
      secondaryContainer: const Color(0xFF4A3A1C),
      onSecondaryContainer: const Color(0xFFF4E7C6),
      tertiary: const Color(0xFF7C9E90),
      onTertiary: const Color(0xFF12201D),
      tertiaryContainer: const Color(0xFF2A3A34),
      onTertiaryContainer: const Color(0xFFD7E4DE),
      error: const Color(0xFFCF6679),
      onError: const Color(0xFF260003),
      background: const Color(0xFF141413),
      onBackground: const Color(0xFFF8F5EF),
      surface: const Color(0xFF1E1D1B),
      onSurface: const Color(0xFFF8F5EF),
      surfaceVariant: const Color(0xFF2A2723),
      onSurfaceVariant: const Color(0xFFB6B2A9),
      outline: const Color(0xFF2C2A26),
      outlineVariant: const Color(0xFF3A3328),
      shadow: const Color(0x22000000),
      scrim: const Color(0x66000000),
      inverseSurface: const Color(0xFFFAF9F5),
      onInverseSurface: const Color(0xFF141413),
      inversePrimary: const Color(0xFF3FAE9A),
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
    final textTheme = _loraTextTheme(base.textTheme);
    return base.copyWith(
      textTheme: textTheme.copyWith(
        displayLarge: _soraTextStyle(textTheme.displayLarge),
        displayMedium: _soraTextStyle(textTheme.displayMedium),
        displaySmall: _soraTextStyle(textTheme.displaySmall),
        headlineLarge: _soraTextStyle(textTheme.headlineLarge),
        headlineMedium: _soraTextStyle(textTheme.headlineMedium),
        headlineSmall: _soraTextStyle(textTheme.headlineSmall),
        titleLarge: _soraTextStyle(textTheme.titleLarge),
        titleMedium: _soraTextStyle(textTheme.titleMedium),
        titleSmall: _soraTextStyle(textTheme.titleSmall),
      ),
    );
  }

  static CardThemeData _cardTheme(ColorScheme scheme) {
    return CardThemeData(
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
      titleTextStyle: _soraTextStyle(
        TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: scheme.onBackground,
        ),
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
        textStyle: _soraTextStyle(
          const TextStyle(fontWeight: FontWeight.w600),
        ),
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
        textStyle: _soraTextStyle(
          const TextStyle(fontWeight: FontWeight.w600),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  static TextButtonThemeData _textButtonTheme(ColorScheme scheme) {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: scheme.primary,
        textStyle: _soraTextStyle(
          const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
