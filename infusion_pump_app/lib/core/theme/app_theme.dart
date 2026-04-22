import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Medical Blue design system for the infusion pump app.
/// Dark blue background with white text and light blue accents.
class AppTheme {
  AppTheme._();

  // ── Color Palette ──
  static const Color background = Color(0xFF0A1628);      // Deep dark navy blue
  static const Color surface = Color(0xFF122240);          // Dark blue surface
  static const Color primary = Color(0xFF1E88E5);          // Medical blue
  static const Color primaryLight = Color(0x331E88E5);     // Semi-transparent blue
  static const Color accent = Color(0xFF42A5F5);           // Light blue accent
  static const Color onSurface = Color(0xFFF0F4FA);        // Near white
  static const Color muted = Color(0xFF7B8FA8);            // Muted blue-gray
  static const Color success = Color(0xFF2ECC71);
  static const Color warning = Color(0xFFE67E22);
  static const Color info = Color(0xFF64B5F6);             // Soft info blue
  static const Color error = Color(0xFFE84855);            // Red for errors/alarms

  // ── Card Decoration ──
  static BoxDecoration get cardDecoration => BoxDecoration(
        color: const Color(0x1A1E88E5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x441E88E5), width: 0.8),
      );

  static BoxDecoration get alarmActiveDecoration => BoxDecoration(
        color: const Color(0x33E84855),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: error, width: 1.5),
      );

  static BoxDecoration get alarmOkDecoration => BoxDecoration(
        color: const Color(0x1A2ECC71),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x442ECC71), width: 0.8),
      );

  // ── Theme Data ──
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      primaryColor: primary,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: accent,
        surface: surface,
        error: error,
        onPrimary: onSurface,
        onSecondary: onSurface,
        onSurface: onSurface,
        onError: onSurface,
      ),
      cardColor: surface,
      textTheme: GoogleFonts.interTextTheme(
        const TextTheme(
          displayLarge: TextStyle(
            color: onSurface,
            fontWeight: FontWeight.w500,
            letterSpacing: 1.2,
          ),
          displayMedium: TextStyle(
            color: onSurface,
            fontWeight: FontWeight.w500,
            letterSpacing: 1.0,
          ),
          headlineLarge: TextStyle(
            color: onSurface,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.8,
          ),
          headlineMedium: TextStyle(
            color: onSurface,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.6,
          ),
          titleLarge: TextStyle(
            color: onSurface,
            fontWeight: FontWeight.w600,
          ),
          titleMedium: TextStyle(
            color: onSurface,
            fontWeight: FontWeight.w500,
          ),
          bodyLarge: TextStyle(color: onSurface),
          bodyMedium: TextStyle(color: onSurface),
          bodySmall: TextStyle(color: muted),
          labelLarge: TextStyle(
            color: onSurface,
            fontWeight: FontWeight.w600,
          ),
          labelMedium: TextStyle(color: muted),
          labelSmall: TextStyle(color: muted, fontSize: 10),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        foregroundColor: onSurface,
        elevation: 0,
        centerTitle: true,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: background,
        selectedItemColor: accent,
        unselectedItemColor: muted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: onSurface,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          minimumSize: const Size(double.infinity, 56),
          side: const BorderSide(color: primary, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0x1A1E88E5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0x441E88E5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0x441E88E5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: error, width: 1.5),
        ),
        labelStyle: const TextStyle(color: muted),
        hintStyle: const TextStyle(color: muted),
        errorStyle: const TextStyle(color: error, fontSize: 12),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      dividerColor: const Color(0x441E88E5),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0x441E88E5)),
        ),
        textStyle: const TextStyle(color: onSurface, fontSize: 12),
      ),
    );
  }
}
