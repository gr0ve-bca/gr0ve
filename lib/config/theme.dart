import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract final class Gr0veColors {
  static const Color grover = Color(0xFF298D74);
  static const Color aspen = Color(0xFFFFCD2E);
  static const Color rowan = Color(0xFFDC5818);
  static const Color sakura = Color(0xFFF5B4FF);
  static const Color abies = Color(0xFF00C8FF);
  static const Color cedite = Color(0xFFA870EF);
  static const Color ash = Color(0xFFCC4D4D);

  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFF7F7F7);
  static const Color textPrimary = Color(0xFF141414);
  static const Color textSecondary = Color(0xFF666666);
  static const Color border = Color(0xFFE2E2E2);
  static const Color error = Color(0xFFCC4D4D);
  static const Color success = Color(0xFF298D74);
}

class GroveTheme {
  GroveTheme._();

  static ThemeData light() {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: Gr0veColors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Gr0veColors.grover,
        primary: Gr0veColors.grover,
        onPrimary: Colors.white,
        secondary: Gr0veColors.grover.withOpacity(0.1),
        onSecondary: Gr0veColors.grover,
        surface: Gr0veColors.background,
        onSurface: Gr0veColors.textPrimary,
        error: Gr0veColors.error,
        onError: Colors.white,
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.jetBrainsMono(
          fontSize: 48,
          fontWeight: FontWeight.w800,
          color: Gr0veColors.grover,
          letterSpacing: 2.0,
        ),
        headlineLarge: GoogleFonts.jetBrainsMono(
          fontSize: 34,
          fontWeight: FontWeight.w700,
          color: Gr0veColors.textPrimary,
          letterSpacing: -0.5,
        ),
        headlineMedium: GoogleFonts.jetBrainsMono(
          fontSize: 26,
          fontWeight: FontWeight.w700,
          color: Gr0veColors.textPrimary,
        ),
        titleLarge: GoogleFonts.jetBrainsMono(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: Gr0veColors.textPrimary,
        ),
        titleMedium: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Gr0veColors.textPrimary,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: Gr0veColors.textPrimary,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: Gr0veColors.textSecondary,
        ),
        bodySmall: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: Gr0veColors.textSecondary,
        ),
        labelLarge: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          letterSpacing: 0.5,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Gr0veColors.grover,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: Gr0veColors.grover,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          side: const BorderSide(color: Gr0veColors.grover, width: 2),
          textStyle: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Gr0veColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Gr0veColors.border, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Gr0veColors.grover, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Gr0veColors.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Gr0veColors.error, width: 2),
        ),
        hintStyle: GoogleFonts.inter(
          color: Gr0veColors.textSecondary,
          fontSize: 15,
        ),
        labelStyle: GoogleFonts.inter(
          color: Gr0veColors.textSecondary,
          fontSize: 15,
        ),
        errorStyle: GoogleFonts.inter(color: Gr0veColors.error, fontSize: 12),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Gr0veColors.background,
        foregroundColor: Gr0veColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.jetBrainsMono(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Gr0veColors.textPrimary,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: Gr0veColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      dividerTheme: const DividerThemeData(
        color: Gr0veColors.border,
        thickness: 1,
      ),
    );
  }
}
