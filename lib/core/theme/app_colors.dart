import 'package:flutter/material.dart';

/// MealMorph color tokens and shared shadows.
abstract final class AppColors {
  static const Color surface = Color(0xFFFCF9F8);
  static const Color primary = Color(0xFF006E1C);
  static const Color primaryContainer = Color(0xFF4CAF50);

  /// Accent on dark hero backgrounds.
  static const Color primaryFixed = Color(0xFF94F990);
  static const Color onPrimaryFixed = Color(0xFF002204);
  static const Color secondary = Color(0xFF8B5000);
  static const Color secondaryContainer = Color(0xFFFF9800);
  static const Color onSecondaryContainer = Color(0xFF653900);
  static const Color onSurface = Color(0xFF1B1C1C);
  static const Color onSurfaceVariant = Color(0xFF3F4A3C);
  static const Color surfaceContainerLow = Color(0xFFF6F3F2);
  static const Color surfaceContainerHighest = Color(0xFFE5E2E1);

  /// Soft elevated shadow (12px offset, 24px blur, ~6% on-surface).
  static BoxShadow get editorialShadow => BoxShadow(
    color: onSurface.withValues(alpha: 0.06),
    offset: const Offset(0, 12),
    blurRadius: 24,
  );
}
