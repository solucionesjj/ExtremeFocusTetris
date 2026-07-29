import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_text_styles.dart';

/// High-contrast variant of "Night Focus" — spec.md section 14: pure white
/// text on pure black, and a visible card border since maximal-contrast
/// surfaces can otherwise look flat without elevation cues.
abstract final class AppThemeHighContrastDark {
  static ThemeData get theme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: Colors.black,
      onSurface: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: Colors.black,
      textTheme: TextTheme(
        displayLarge: AppTextStyles.displayLarge.copyWith(color: Colors.white),
        headlineMedium: AppTextStyles.headlineMedium.copyWith(color: Colors.white),
        titleMedium: AppTextStyles.titleMedium.copyWith(color: Colors.white),
        bodyLarge: AppTextStyles.bodyLarge.copyWith(color: Colors.white),
        bodyMedium: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
        labelSmall: AppTextStyles.labelSmall.copyWith(color: Colors.white),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.buttonPrimary,
          foregroundColor: Colors.black,
          minimumSize: const Size.fromHeight(56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Colors.white, width: 2),
          ),
          textStyle: AppTextStyles.titleMedium,
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.black,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Colors.white, width: 2),
        ),
      ),
    );
  }
}
