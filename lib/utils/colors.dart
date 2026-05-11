import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary colors (original)
  static const Color primary = Color(0xFF009688); // Teal
  static const Color primaryDark = Color(0xFF00796B);

  // Background colors (from BerandaScreen._C and LoginScreen)
  static const Color bgBottom = Color(0xFF081815);
  static const Color bgTop = Color(0xFF0d2b26);

  // Glass/card colors
  static const Color cardBackground = Color(0x12FFFFFF); // semi-transparent white
  static const Color cardBorder = Color(0x1AFFFFFF);

  // Accent colors
  static const Color accent = Color(0xFFE05A2B); // orange-red
  static const Color accentDark = Color(0xFFC0391A);

  // Category/button colors
  static const Color green = Color(0xFF4da154);
  static const Color blue = Color(0xFF3762e2);
  static const Color gray = Color(0xFF68748a);

  // Basic colors
  static const Color white = Colors.white;

  // Text colors
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0x80FFFFFF); // 50% white
  static const Color textHint = Color(0x47FFFFFF); // 28% white

  // Status colors
  static const Color completed = Color(0xFF9CA3AF);
  static const Color error = Color(0xFFFF6B6B); // from LoginScreen
}
