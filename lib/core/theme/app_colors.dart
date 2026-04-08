import 'package:flutter/material.dart';

/// MealMorph color tokens and shared shadows.
abstract final class AppColors {
  static const Color surface = Color(0xFFFCF9F8);
  static const Color primary = Color(0xFF006E1C);
  static const Color primaryContainer = Color(0xFF4CAF50);
  static const Color onPrimaryContainer = Color(0xFF003C0B);

  /// Accent on dark hero backgrounds.
  static const Color primaryFixed = Color(0xFF94F990);
  static const Color onPrimaryFixed = Color(0xFF002204);
  static const Color secondary = Color(0xFF8B5000);
  static const Color secondaryContainer = Color(0xFFFF9800);
  static const Color onSecondaryContainer = Color(0xFF653900);
  static const Color onSurface = Color(0xFF1B1C1C);
  static const Color onSurfaceVariant = Color(0xFF3F4A3C);
  static const Color surfaceContainerLow = Color(0xFFF6F3F2);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerHigh = Color(0xFFEAE7E7);
  static const Color surfaceContainerHighest = Color(0xFFE5E2E1);
  static const Color outline = Color(0xFF6F7A6B);
  static const Color outlineVariant = Color(0xFFBEC9B9);

  /// Soft elevated shadow (12px offset, 24px blur, ~6% on-surface).
  static BoxShadow get editorialShadow => BoxShadow(
    color: onSurface.withValues(alpha: 0.06),
    offset: const Offset(0, 12),
    blurRadius: 24,
  );
}
