import 'package:flutter/material.dart';

class AppColors {
  static const background = Color(0xFF0B0F16);
  static const panel = Color(0xFF0F1724);
  static const card = Color(0xFF111827);
  static const muted = Color(0xFF94A3B8);
  static const accent = Color(0xFF5B7CFF);
  static const danger = Color(0xFF7F1D1D);
  static const surface = Color(0xFF0B1220);
}

class AppTheme {
  static ThemeData dark() {
    final base = ThemeData.dark();
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: base.colorScheme.copyWith(
        primary: AppColors.card,
        secondary: AppColors.accent,
      ),
      cardColor: AppColors.card,
      textTheme: base.textTheme.apply(
        bodyColor: Colors.white,
        displayColor: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}
