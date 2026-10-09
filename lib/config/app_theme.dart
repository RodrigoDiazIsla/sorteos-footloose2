import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color purple = Color(0xFF6F359C);
  static const Color deepPurple = Color(0xFF3B0764);
  static const Color gold = Color(0xFFD4AF37);
  static const Color ink = Color(0xFF1F2937);
  static const Color muted = Color(0xFF6B7280);
  static const Color line = Color(0xFFE5E7EB);
  static const Color softPurple = Color(0xFFF4F0F9);
  static const Color page = Color(0xFFF7F5FA);

  static ThemeData getThemeLight() => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: const ColorScheme.light(
          primary: purple,
          secondary: gold,
          surface: Colors.white,
          error: Color(0xFFEF4444),
          onPrimary: Colors.white,
          onSecondary: ink,
          onSurface: ink,
          onError: Colors.white,
        ),
        scaffoldBackgroundColor: page,
        dividerColor: line,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: line),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: line),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: purple, width: 1.6),
          ),
        ),
        textTheme: TextTheme(
          titleSmall: GoogleFonts.outfit(
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: muted),
          ),
          titleMedium: GoogleFonts.outfit(
            textStyle: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: purple),
          ),
          titleLarge: GoogleFonts.outfit(
            textStyle: const TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: ink),
          ),
          bodyMedium: GoogleFonts.outfit(
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: ink),
          ),
          bodySmall: GoogleFonts.outfit(
            textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: muted),
          ),
          labelMedium: GoogleFonts.outfit(
            textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: ink),
          ),
          labelSmall: GoogleFonts.outfit(
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: ink),
          ),
        ),
      );
}
