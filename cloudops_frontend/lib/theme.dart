import 'package:flutter/material.dart';

/// Glassmorphism color palette for Apple-inspired liquid glass UI
class GlassColors {
  // Dark mode palette
  static const darkBg = Color(0xFF0F172A); // deep navy background
  static const darkSurface = Color(0xFF1A2847); // slightly lighter surface
  static const darkGlass = Color(
    0x1AF5F5F5,
  ); // frosted white overlay (10% opaque)
  static const darkGlassLight = Color(
    0x2DF5F5F5,
  ); // frosted white light (18% opaque)
  static const darkBorder = Color(
    0x4DF5F5F5,
  ); // subtle frosted border (30% opaque)

  // Light mode palette
  static const lightBg = Color(0xFFF8FAFF); // very light blue-tinted white
  static const lightSurface = Color(0xFFF0F5FF); // soft light background
  static const lightGlass = Color(0x26FFFFFF); // frosted glass (15% opaque)
  static const lightGlassLight = Color(
    0x4DFFFFFF,
  ); // frosted glass light (30% opaque)
  static const lightBorder = Color(0x80E0E5FF); // subtle frosted border

  // Accent colors (work in both modes)
  static const accent = Color(0xFF5B7CFF); // vibrant blue
  static const accentLight = Color(0xFF7B9FFF); // lighter blue
  static const success = Color(0xFF34C759); // iOS green
  static const warning = Color(0xFFFF9500); // iOS orange
  static const danger = Color(0xFFFF3B30); // iOS red
  static const muted = Color(0xFF94A3B8);
}

class AppTheme {
  static ThemeData dark() {
    return ThemeData.dark().copyWith(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: GlassColors.darkBg,
      colorScheme: ColorScheme.dark(
        primary: GlassColors.accent,
        secondary: GlassColors.accentLight,
        surface: GlassColors.darkSurface,
      ),
      cardColor: GlassColors.darkGlass,
      textTheme: ThemeData.dark().textTheme.apply(
        bodyColor: Colors.white,
        displayColor: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: GlassColors.accent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: GlassColors.accent,
          side: const BorderSide(color: GlassColors.darkBorder, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  static ThemeData light() {
    return ThemeData.light().copyWith(
      brightness: Brightness.light,
      scaffoldBackgroundColor: GlassColors.lightBg,
      colorScheme: ColorScheme.light(
        primary: GlassColors.accent,
        secondary: GlassColors.accentLight,
        surface: GlassColors.lightSurface,
      ),
      cardColor: GlassColors.lightGlass,
      textTheme: ThemeData.light().textTheme.apply(
        bodyColor: Colors.black87,
        displayColor: Colors.black87,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: GlassColors.accent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: GlassColors.accent,
          side: const BorderSide(color: GlassColors.lightBorder, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
