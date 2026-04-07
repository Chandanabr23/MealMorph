import 'package:flutter/material.dart';

import '../core/strings/app_strings.dart';
import '../core/strings/app_strings_scope.dart';
import '../core/theme/app_theme.dart';
import '../features/onboarding/presentation/screens/expiry_priority_onboarding_screen.dart';

class MealMorphApp extends StatelessWidget {
  const MealMorphApp({super.key, required this.strings});

  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: strings.app.title,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      builder: (context, child) {
        return AppStringsScope(
          strings: strings,
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: const ExpiryPriorityOnboardingScreen(),
    );
  }
}
