import 'dart:convert';

import 'package:flutter/services.dart';

/// Copy loaded from [assetPath] (default `assets/strings/text.json`).
class AppStrings {
  AppStrings({required this.app, required this.expiryPriorityOnboarding});

  final AppTitleStrings app;
  final ExpiryPriorityOnboardingStrings expiryPriorityOnboarding;

  static const String defaultAssetPath = 'assets/strings/text.json';

  static Future<AppStrings> load({String assetPath = defaultAssetPath}) async {
    final raw = await rootBundle.loadString(assetPath);
    return AppStrings.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  factory AppStrings.fromJson(Map<String, dynamic> json) {
    final appJson = json['app'] as Map<String, dynamic>? ?? {};
    final onboarding = json['onboarding'] as Map<String, dynamic>? ?? {};
    final ep = onboarding['expiryPriority'] as Map<String, dynamic>? ?? {};
    return AppStrings(
      app: AppTitleStrings(title: appJson['title'] as String? ?? 'MealMorph'),
      expiryPriorityOnboarding: ExpiryPriorityOnboardingStrings.fromJson(ep),
    );
  }
}

class AppTitleStrings {
  const AppTitleStrings({required this.title});

  final String title;
}

class ExpiryPriorityOnboardingStrings {
  const ExpiryPriorityOnboardingStrings({
    required this.heroImageUrl,
    required this.brand,
    required this.kicker,
    required this.headline,
    required this.body,
    required this.next,
    required this.skip,
    required this.chipExpiringSoon,
    required this.chipUseWithin,
    required this.smartScanTitle,
    required this.smartScanSubtitle,
  });

  final String heroImageUrl;
  final String brand;
  final String kicker;
  final String headline;
  final String body;
  final String next;
  final String skip;
  final String chipExpiringSoon;
  final String chipUseWithin;
  final String smartScanTitle;
  final String smartScanSubtitle;

  factory ExpiryPriorityOnboardingStrings.fromJson(Map<String, dynamic> json) {
    String s(String key, [String fallback = '']) =>
        json[key] as String? ?? fallback;

    return ExpiryPriorityOnboardingStrings(
      heroImageUrl: s('heroImageUrl'),
      brand: s('brand', 'MealMorph'),
      kicker: s('kicker'),
      headline: s('headline'),
      body: s('body'),
      next: s('next', 'Next'),
      skip: s('skip', 'Skip'),
      chipExpiringSoon: s('chipExpiringSoon'),
      chipUseWithin: s('chipUseWithin'),
      smartScanTitle: s('smartScanTitle'),
      smartScanSubtitle: s('smartScanSubtitle'),
    );
  }
}
