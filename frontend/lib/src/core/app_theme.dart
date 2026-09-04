import 'package:flutter/material.dart';

class AppColors {
  const AppColors._();

  static const ink = Color(0xff1f2a2a);
  static const muted = Color(0xff68706e);
  static const canvas = Color(0xfff6f3ee);
  static const surface = Color(0xfffffcf7);
  static const primary = Color(0xff275c5a);
  static const accent = Color(0xffa35d38);
  static const border = Color(0xffe1ddd4);
  static const fieldBorder = Color(0xffd6d1c8);
  static const selected = Color(0xffe7f0ed);
  static const track = Color(0xffe6e0d7);
}

class AppTheme {
  const AppTheme._();

  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.canvas,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        secondary: AppColors.accent,
        surface: AppColors.surface,
      ),
      textTheme: Typography.material2021().black.apply(
            bodyColor: AppColors.ink,
            displayColor: AppColors.ink,
          ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: _fieldBorder(),
        enabledBorder: _fieldBorder(),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: AppColors.border),
        ),
      ),
    );
  }

  static OutlineInputBorder _fieldBorder() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: AppColors.fieldBorder),
    );
  }
}
