import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

/// Builds the two ThemeData objects the app switches between.
///  Screens never build a ThemeData/ColorScheme themselves — they only
/// ever read Theme.of(context), which resolves to whichever of these
/// two is active (controlled by the user's choice in Profile settings).
class AppTheme {
  AppTheme._();

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.backgroundLight,
      colorScheme: ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.surfaceLight,
        // Wired in on Day 6 — borderLight/borderDark existed since Day 1
        // but sat unused until the Home dashboard cards actually needed
        // a themed border color instead of a hardcoded one.
        outlineVariant: AppColors.borderLight,
        error: AppColors.warning,
      ),
      textTheme: AppTextStyles.textTheme(isDark: false),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.backgroundLight,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
    );
  }

  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.backgroundDark,
      colorScheme: ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.surfaceDark,
        outlineVariant: AppColors.borderDark,
        error: AppColors.warning,
      ),
      textTheme: AppTextStyles.textTheme(isDark: true),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.backgroundDark,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
    );
  }
}
