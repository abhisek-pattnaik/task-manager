import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color background = Color(0xFFF7F7F9);
  static const Color darkCard = Color(0xFF141519);
  static const Color limeAccent = Color(0xFFE2F952);
  static const Color limeLight = Color(0xFFF2FCD0);
  static const Color lavender = Color(0xFFD6DBFD);
  static const Color lavenderLight = Color(0xFFEEF0FD);
  static const Color softGrey = Color(0xFFECEEF1);
  static const Color mint = Color(0xFFE3EDDE);
  
  static const Color textDark = Color(0xFF111215);
  static const Color textMuted = Color(0xFF7E8088);
  static const Color textLight = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE7E8EB);
  static const Color divider = Color(0xFFEEEEF2);
  
  static const Color priorityHigh = Color(0xFFFF5252);
  static const Color priorityNormal = Color(0xFF7E8088);
  static const Color priorityLow = Color(0xFF4CAF50);
}

class AppTheme {
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
      textTheme: GoogleFonts.plusJakartaSansTextTheme().copyWith(
        displayLarge: const TextStyle(
          color: AppColors.textDark,
          fontWeight: FontWeight.w700,
          fontSize: 28,
          letterSpacing: -0.5,
        ),
        titleLarge: const TextStyle(
          color: AppColors.textDark,
          fontWeight: FontWeight.w700,
          fontSize: 20,
          letterSpacing: -0.3,
        ),
        titleMedium: const TextStyle(
          color: AppColors.textDark,
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
        bodyLarge: const TextStyle(
          color: AppColors.textDark,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        bodyMedium: const TextStyle(
          color: AppColors.textMuted,
          fontSize: 13,
          fontWeight: FontWeight.w400,
        ),
      ),
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.limeAccent,
        surface: AppColors.background,
        primary: AppColors.darkCard,
        secondary: AppColors.limeAccent,
      ),
    );
  }
}
