import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract final class AppTheme {
  static ThemeData light() => ThemeData(
        useMaterial3: true,
        colorScheme: _lightColorScheme,
        textTheme: _textTheme(Brightness.light),
        navigationBarTheme: _navBarTheme(_lightColorScheme),
        inputDecorationTheme: _inputTheme(_lightColorScheme),
        cardTheme: _cardTheme(),
      );

  static ThemeData dark() => ThemeData(
        useMaterial3: true,
        colorScheme: _darkColorScheme,
        textTheme: _textTheme(Brightness.dark),
        navigationBarTheme: _navBarTheme(_darkColorScheme),
        inputDecorationTheme: _inputTheme(_darkColorScheme),
        cardTheme: _cardTheme(),
      );

  static const _lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFF1B8C5E),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFC2F0DC),
    onPrimaryContainer: Color(0xFF00361F),
    secondary: Color(0xFF3D5A8A),
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: Color(0xFFD9E3FF),
    onSecondaryContainer: Color(0xFF001550),
    tertiary: Color(0xFFF59E0B),
    onTertiary: Color(0xFFFFFFFF),
    tertiaryContainer: Color(0xFFFFE4A0),
    onTertiaryContainer: Color(0xFF3D2800),
    error: Color(0xFFDC2626),
    onError: Color(0xFFFFFFFF),
    errorContainer: Color(0xFFFFDAD6),
    onErrorContainer: Color(0xFF410002),
    surface: Color(0xFFF6FAF8),
    onSurface: Color(0xFF0D1F17),
    surfaceContainerHighest: Color(0xFFE8F0EC),
    onSurfaceVariant: Color(0xFF4A6358),
    outline: Color(0xFFA0B4AC),
    outlineVariant: Color(0xFFD0DDD8),
    inverseSurface: Color(0xFF1E3329),
    onInverseSurface: Color(0xFFEAF3EE),
    inversePrimary: Color(0xFF5ECFA0),
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    surfaceTint: Color(0xFF1B8C5E),
  );

  static const _darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFF5ECFA0),
    onPrimary: Color(0xFF00391E),
    primaryContainer: Color(0xFF006640),
    onPrimaryContainer: Color(0xFFA0EBCA),
    secondary: Color(0xFFA8C0FF),
    onSecondary: Color(0xFF002780),
    secondaryContainer: Color(0xFF264190),
    onSecondaryContainer: Color(0xFFD9E3FF),
    tertiary: Color(0xFFFFBD2E),
    onTertiary: Color(0xFF3D2800),
    tertiaryContainer: Color(0xFF593C00),
    onTertiaryContainer: Color(0xFFFFE4A0),
    error: Color(0xFFFFB4AB),
    onError: Color(0xFF690005),
    errorContainer: Color(0xFF93000A),
    onErrorContainer: Color(0xFFFFDAD6),
    surface: Color(0xFF0C1A14),
    onSurface: Color(0xFFDBF0E7),
    surfaceContainerHighest: Color(0xFF162A20),
    onSurfaceVariant: Color(0xFF8BADA0),
    outline: Color(0xFF4A6358),
    outlineVariant: Color(0xFF223B30),
    inverseSurface: Color(0xFFDBF0E7),
    onInverseSurface: Color(0xFF0D1F17),
    inversePrimary: Color(0xFF1B8C5E),
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    surfaceTint: Color(0xFF5ECFA0),
  );

  static TextTheme _textTheme(Brightness brightness) {
    final base = brightness == Brightness.light
        ? ThemeData.light().textTheme
        : ThemeData.dark().textTheme;
    return GoogleFonts.interTextTheme(base).copyWith(
      displaySmall: GoogleFonts.inter(fontSize: 36, fontWeight: FontWeight.w400, height: 44 / 36),
      headlineMedium: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w600, height: 36 / 28),
      headlineSmall: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w600, height: 32 / 24),
      titleLarge: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w600, height: 28 / 22),
      titleMedium: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, height: 24 / 16),
      titleSmall: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, height: 20 / 14),
      bodyLarge: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w400, height: 24 / 16),
      bodyMedium: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400, height: 20 / 14),
      bodySmall: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w400, height: 16 / 12),
      labelLarge: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, height: 20 / 14),
      labelSmall: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500, height: 16 / 11),
    );
  }

  static NavigationBarThemeData _navBarTheme(ColorScheme scheme) =>
      NavigationBarThemeData(
        backgroundColor: scheme.surface,
        indicatorColor: scheme.primaryContainer,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: scheme.onPrimaryContainer);
          }
          return IconThemeData(color: scheme.onSurfaceVariant);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final style = GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600);
          if (states.contains(WidgetState.selected)) {
            return style.copyWith(color: scheme.onSurface);
          }
          return style.copyWith(color: scheme.onSurfaceVariant);
        }),
      );

  static InputDecorationTheme _inputTheme(ColorScheme scheme) =>
      InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.error, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      );

  static CardThemeData _cardTheme() => CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        clipBehavior: Clip.antiAlias,
      );
}
