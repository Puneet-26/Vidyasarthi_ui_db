import 'package:flutter/material.dart';

class AppColors {
  // Primary purple palette from VIDYASARATHI
  static const Color primary = Color(0xFF7C5CBF);
  static const Color primaryLight = Color(0xFF9B7FD4);
  static const Color primaryDark = Color(0xFF5A3E9B);
  static const Color accent = Color(0xFFD4AAFF);

  // Gradient colors (pink-to-purple mesh)
  static const Color gradStart = Color(0xFFF5D0FF);
  static const Color gradMid = Color(0xFFE8C4F8);
  static const Color gradEnd = Color(0xFFB89EE8);

  static const Color bgLight = Color(0xFFFAF5FF);
  static const Color cardWhite = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF2D1B69);
  static const Color textMid = Color(0xFF6B5B95);
  static const Color textLight = Color(0xFF9D8EC7);
  static const Color divider = Color(0xFFEDE5FF);

  // Role accent colors
  static const Color studentAccent = Color(0xFF7C5CBF);
  static const Color teacherAccent = Color(0xFF5B8DEF);
  static const Color parentAccent = Color(0xFF2EC4B6);
  static const Color adminAccent = Color(0xFFFF6B6B);

  // Status colors
  static const Color success = Color(0xFF4CAF82);
  static const Color warning = Color(0xFFFFB347);
  static const Color error = Color(0xFFFF6B6B);
  static const Color info = Color(0xFF64B5F6);
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: AppColors.bgLight,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.textDark,
        ),
        iconTheme: IconThemeData(color: AppColors.textDark),
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardWhite,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        shadowColor: AppColors.primary.withOpacity(0.1),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}
