import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// PulseIQ typography, mapped onto Material 3's full 15-style TextTheme.
///
/// Using "Plus Jakarta Sans" instead of the Flutter-default Roboto —
/// wanted the app to feel like an intentional product, not a default
/// Flutter tutorial. All 15 M3 styles are defined (not just the 3-4
/// actually used right now) so nothing crashes later if a new screen
/// reaches for a style like bodySmall that wasn't used yet.
class AppTextStyles {
  AppTextStyles._();

  static TextTheme textTheme({required bool isDark}) {
    final primaryText = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;
    final secondaryText = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;
    // Small local helper so every style below isn't a repeated 5-line
    // GoogleFonts.plusJakartaSans(...) call — one place to change the
    // font later if needed.
    TextStyle style(
      double size,
      FontWeight weight, {
      Color? color,
      double? height,
    }) {
      return GoogleFonts.plusJakartaSans(
        fontSize: size,
        fontWeight: weight,
        color: color ?? primaryText,
        height: height,
      );
    }

    return TextTheme(
      displayLarge: style(48, FontWeight.w700, height: 1.1),
      displayMedium: style(40, FontWeight.w700, height: 1.15),
      displaySmall: style(34, FontWeight.w700, height: 1.15),
      headlineLarge: style(28, FontWeight.w700, height: 1.2),
      headlineMedium: style(24, FontWeight.w600, height: 1.2),
      headlineSmall: style(22, FontWeight.w600, height: 1.2),
      titleLarge: style(18, FontWeight.w600),
      titleMedium: style(16, FontWeight.w600),
      titleSmall: style(14, FontWeight.w600),
      bodyLarge: style(16, FontWeight.w400, height: 1.4),
      bodyMedium: style(14, FontWeight.w400, color: secondaryText, height: 1.4),
      bodySmall: style(12, FontWeight.w400, color: secondaryText, height: 1.3),
      labelLarge: style(14, FontWeight.w500),
      labelMedium: style(12, FontWeight.w500, color: secondaryText),
      labelSmall: style(11, FontWeight.w500, color: secondaryText),
    );
  }
}
