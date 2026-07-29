import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_text_styles.dart';

/// High-contrast variant of "Day Focus" — spec.md section 14: pure black
/// text on pure white, and a visible card border since maximal-contrast
/// surfaces can otherwise look flat without elevation cues.
abstract final class AppThemeHighContrastLight {
  static ThemeData get theme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: Colors.white,
      onSurface: Colors.black,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: Colors.white,
      textTheme: TextTheme(
        displayLarge: AppTextStyles.displayLarge.copyWith(color: Colors.black),
        headlineMedium: AppTextStyles.headlineMedium.copyWith(color: Colors.black),
        titleMedium: AppTextStyles.titleMedium.copyWith(color: Colors.black),
        bodyLarge: AppTextStyles.bodyLarge.copyWith(color: Colors.black),
        bodyMedium: AppTextStyles.bodyMedium.copyWith(color: Colors.black),
        labelSmall: AppTextStyles.labelSmall.copyWith(color: Colors.black),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.buttonPrimary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Colors.black, width: 2),
          ),
          textStyle: AppTextStyles.titleMedium,
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Colors.black, width: 2),
        ),
      ),
    );
  }
}
