import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../core/nav/mealmorph_messenger.dart';
import '../core/strings/app_strings.dart';
import '../core/strings/app_strings_scope.dart';
import '../core/theme/app_theme.dart';
import '../features/fridge/presentation/screens/my_fridge_screen.dart';
import '../features/onboarding/presentation/screens/expiry_priority_onboarding_screen.dart';

class MealMorphApp extends StatelessWidget {
  const MealMorphApp({
    super.key,
    required this.strings,
    this.authStateChanges,
  });

  final AppStrings strings;

  /// For tests; defaults to [FirebaseAuth.authStateChanges].
  final Stream<User?>? authStateChanges;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: strings.app.title,
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: mealMorphMessengerKey,
      theme: AppTheme.light(),
      builder: (context, child) {
        return AppStringsScope(
          strings: strings,
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: _AuthGate(
        authStateChanges:
            authStateChanges ?? FirebaseAuth.instance.authStateChanges(),
      ),
    );
  }
}

class _AuthGate extends StatelessWidget {
  const _AuthGate({required this.authStateChanges});

  final Stream<User?> authStateChanges;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.data != null) {
          return const MyFridgeScreen();
        }
        return const ExpiryPriorityOnboardingScreen();
      },
    );
  }
}
