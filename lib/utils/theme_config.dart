import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color fixedRed   = Color(0xFFE53935);
  static const Color fixedGreen = Color(0xFF43A047);
  static const Color fixedBlue  = Color(0xFF1E88E5);
  static const Color fixedGray  = Color(0xFF757575);

  final String name;
  final bool isDark;
  final Color? bgTop;
  final Color? bgBottom;
  final List<Color>? gradientColors;
  final Color? bgSolid;
  final Color accentColor;
  final Color successColor;
  final Color errorColor;
  final Color overdueColor;
  final Color textPrimary;
  final Color textSecondary;
  final Color textHint;
  final Color cardBg;
  final Color cardBorder;
  final bool hasStarField;

  const AppTheme({
    required this.name,
    required this.isDark,
    this.bgTop,
    this.bgBottom,
    this.gradientColors,
    this.bgSolid,
    required this.accentColor,
    required this.successColor,
    required this.errorColor,
    required this.overdueColor,
    required this.textPrimary,
    required this.textSecondary,
    required this.textHint,
    required this.cardBg,
    required this.cardBorder,
    required this.hasStarField,
  });

  ThemeData get materialTheme {
    return ThemeData(
      brightness: isDark ? Brightness.dark : Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: accentColor,
        brightness: isDark ? Brightness.dark : Brightness.light,
      ),
      textTheme: GoogleFonts.interTextTheme(
        isDark ? ThemeData.dark().textTheme : ThemeData.light().textTheme,
      ),
      primaryTextTheme: GoogleFonts.plusJakartaSansTextTheme(
        isDark ? ThemeData.dark().primaryTextTheme : ThemeData.light().primaryTextTheme,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: textPrimary,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        elevation: 0,
      ),
      useMaterial3: true,
      scaffoldBackgroundColor: bgSolid ?? (bgBottom ?? const Color(0xFF1C2B22)),
    );
  }
}

final List<AppTheme> allThemes = [
  AppTheme(
    name: 'Clean White',
    isDark: false,
    bgSolid: const Color(0xFFF5F5F5),
    accentColor: const Color(0xFF757575),
    successColor: const Color(0xFF43A047),
    errorColor: const Color(0xFFE53935),
    overdueColor: const Color(0xFFFF5252),
    textPrimary: const Color(0xFF2B2B2B),
    textSecondary: const Color(0xFF757575),
    textHint: const Color(0xFFBDBDBD),
    cardBg: Colors.white,
    cardBorder: const Color(0xFFE0E0E0),
    hasStarField: false,
  ),

  AppTheme(
    name: 'Carbon Mint',
    isDark: true,
    bgSolid: const Color(0xFF181E1E),
    accentColor: const Color(0xFF2BBFA8),
    successColor: const Color(0xFF2BBFA8),
    errorColor: const Color(0xFFE53935),
    overdueColor: const Color(0xFFFF5252),
    textPrimary: Colors.white,
    textSecondary: const Color(0xB3FFFFFF),
    textHint: const Color(0x80FFFFFF),
    cardBg: const Color(0xFF232D2D),
    cardBorder: const Color(0xFF2E3A3A),
    hasStarField: false,
  ),

  AppTheme(
    name: 'Slate Blue',
    isDark: true,
    bgSolid: const Color(0xFF1A2332),
    accentColor: const Color(0xFF4A90D9),
    successColor: const Color(0xFF4DB6AC),
    errorColor: const Color(0xFFE53935),
    overdueColor: const Color(0xFFFF5252),
    textPrimary: Colors.white,
    textSecondary: const Color(0xB3FFFFFF),
    textHint: const Color(0x80FFFFFF),
    cardBg: const Color(0xFF253347),
    cardBorder: const Color(0xFF304055),
    hasStarField: false,
  ),
];