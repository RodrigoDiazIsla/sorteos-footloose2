import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData getThemeLight() => ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF6F359C), // Morado Footloose
        secondary: Color(0xFFD4AF37), // Dorado Acento
        surface: Color(0xFFFFFFFF),
        error: Color(0xFFEF4444), // Rojo Alerta
        onPrimary: Colors.white,
        onSecondary: Colors.black,
        onSurface: Color(0xFF1F2937), // Gris Texto Principal
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: const Color(0xFFFFFFFF),
      dividerColor: const Color(0xFFE5E7EB),
      textTheme: TextTheme(
        titleSmall: GoogleFonts.outfit(
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF9CA3AF)),
        ),
        titleMedium: // Count participants
            GoogleFonts.outfit(textStyle: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF6F359C))),
        titleLarge:
            GoogleFonts.outfit(textStyle: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1F2937))),
        bodyMedium:
            GoogleFonts.outfit(textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Color(0xFF1F2937))),
        bodySmall:
            GoogleFonts.outfit(textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xFF9CA3AF))),
        labelMedium: // Text basic
            GoogleFonts.outfit(textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.w400, color: Color(0xFF1F2937))),
        labelSmall: // Number picker
            GoogleFonts.outfit(textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF1F2937))),
      ));
}
