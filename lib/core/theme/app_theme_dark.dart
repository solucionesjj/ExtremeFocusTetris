import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_text_styles.dart';

/// "Night Focus" theme — spec.md section 4.3.
abstract final class AppThemeDark {
  static ThemeData get theme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: AppColors.surfaceDark,
      onSurface: AppColors.textOnDark,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.backgroundDark,
      textTheme: TextTheme(
        displayLarge: AppTextStyles.displayLarge.copyWith(color: AppColors.textOnDark),
        headlineMedium: AppTextStyles.headlineMedium.copyWith(color: AppColors.textOnDark),
        titleMedium: AppTextStyles.titleMedium.copyWith(color: AppColors.textOnDark),
        bodyLarge: AppTextStyles.bodyLarge.copyWith(color: AppColors.textOnDark),
        bodyMedium: AppTextStyles.bodyMedium.copyWith(color: AppColors.textOnDark),
        labelSmall: AppTextStyles.labelSmall.copyWith(color: AppColors.textOnDark),
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
        color: AppColors.surfaceDark,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}
