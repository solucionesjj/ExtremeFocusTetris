import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_text_styles.dart';

/// "Day Focus" theme — spec.md section 4.3.
abstract final class AppThemeLight {
  static ThemeData get theme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: AppColors.surfaceLight,
      onSurface: AppColors.textOnLight,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.backgroundLight,
      textTheme: TextTheme(
        displayLarge: AppTextStyles.displayLarge.copyWith(color: AppColors.textOnLight),
        headlineMedium: AppTextStyles.headlineMedium.copyWith(color: AppColors.textOnLight),
        titleMedium: AppTextStyles.titleMedium.copyWith(color: AppColors.textOnLight),
        bodyLarge: AppTextStyles.bodyLarge.copyWith(color: AppColors.textOnLight),
        bodyMedium: AppTextStyles.bodyMedium.copyWith(color: AppColors.textOnLight),
        labelSmall: AppTextStyles.labelSmall.copyWith(color: AppColors.textOnLight),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.buttonPrimary,
          foregroundColor: AppColors.textOnDark,
          minimumSize: const Size.fromHeight(56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: AppTextStyles.titleMedium,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceLight,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}
