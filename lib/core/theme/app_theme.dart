import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

abstract final class AppTheme {
  static ThemeData light() {
    final baseText = GoogleFonts.beVietnamProTextTheme();
    final displayText = GoogleFonts.plusJakartaSansTextTheme();

    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: Colors.white,
        primaryContainer: AppColors.primaryContainer,
        secondary: AppColors.secondary,
        onSecondary: Colors.white,
        secondaryContainer: AppColors.secondaryContainer,
        onSecondaryContainer: AppColors.onSecondaryContainer,
        surface: AppColors.surface,
        onSurface: AppColors.onSurface,
      ),
      scaffoldBackgroundColor: AppColors.surface,
      textTheme: baseText.copyWith(
        displayLarge: displayText.displayLarge,
        displayMedium: displayText.displayMedium,
        displaySmall: displayText.displaySmall,
        headlineLarge: displayText.headlineLarge,
        headlineMedium: displayText.headlineMedium,
        headlineSmall: displayText.headlineSmall,
        titleLarge: displayText.titleLarge,
        titleMedium: displayText.titleMedium,
        titleSmall: displayText.titleSmall,
      ),
    );
  }
}
