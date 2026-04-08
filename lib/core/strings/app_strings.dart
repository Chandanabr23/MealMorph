import 'dart:convert';

import 'package:flutter/services.dart';

/// Copy loaded from [assetPath] (default `assets/strings/text.json`).
class AppStrings {
  AppStrings({
    required this.app,
    required this.expiryPriorityOnboarding,
    required this.snapFridgeOnboarding,
    required this.login,
    required this.fridge,
  });

  final AppTitleStrings app;
  final ExpiryPriorityOnboardingStrings expiryPriorityOnboarding;
  final SnapFridgeOnboardingStrings snapFridgeOnboarding;
  final LoginScreenStrings login;
  final FridgeScreenStrings fridge;

  static const String defaultAssetPath = 'assets/strings/text.json';

  static Future<AppStrings> load({String assetPath = defaultAssetPath}) async {
    final raw = await rootBundle.loadString(assetPath);
    return AppStrings.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  factory AppStrings.fromJson(Map<String, dynamic> json) {
    final appJson = json['app'] as Map<String, dynamic>? ?? {};
    final onboarding = json['onboarding'] as Map<String, dynamic>? ?? {};
    final ep = onboarding['expiryPriority'] as Map<String, dynamic>? ?? {};
    final sf = onboarding['snapFridge'] as Map<String, dynamic>? ?? {};
    final auth = json['auth'] as Map<String, dynamic>? ?? {};
    final loginJson = auth['login'] as Map<String, dynamic>? ?? {};
    final fridgeJson = json['fridge'] as Map<String, dynamic>? ?? {};
    return AppStrings(
      app: AppTitleStrings(title: appJson['title'] as String? ?? 'MealMorph'),
      expiryPriorityOnboarding: ExpiryPriorityOnboardingStrings.fromJson(ep),
      snapFridgeOnboarding: SnapFridgeOnboardingStrings.fromJson(sf),
      login: LoginScreenStrings.fromJson(loginJson),
      fridge: FridgeScreenStrings.fromJson(fridgeJson),
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

class SnapFridgeOnboardingStrings {
  const SnapFridgeOnboardingStrings({
    required this.heroImageUrl,
    required this.brand,
    required this.kicker,
    required this.headlineLine1,
    required this.headlineAccent,
    required this.body,
    required this.getStarted,
    required this.signIn,
    required this.floatAiTitle,
    required this.floatAiSubtitle,
    required this.floatEcoTitle,
    required this.floatEcoSubtitle,
  });

  final String heroImageUrl;
  final String brand;
  final String kicker;
  final String headlineLine1;
  final String headlineAccent;
  final String body;
  final String getStarted;
  final String signIn;
  final String floatAiTitle;
  final String floatAiSubtitle;
  final String floatEcoTitle;
  final String floatEcoSubtitle;

  factory SnapFridgeOnboardingStrings.fromJson(Map<String, dynamic> json) {
    String s(String key, [String fallback = '']) =>
        json[key] as String? ?? fallback;

    return SnapFridgeOnboardingStrings(
      heroImageUrl: s('heroImageUrl'),
      brand: s('brand', 'MealMorph'),
      kicker: s('kicker'),
      headlineLine1: s('headlineLine1'),
      headlineAccent: s('headlineAccent'),
      body: s('body'),
      getStarted: s('getStarted', 'Get Started'),
      signIn: s('signIn', 'Sign In'),
      floatAiTitle: s('floatAiTitle'),
      floatAiSubtitle: s('floatAiSubtitle'),
      floatEcoTitle: s('floatEcoTitle'),
      floatEcoSubtitle: s('floatEcoSubtitle'),
    );
  }
}

class LoginScreenStrings {
  const LoginScreenStrings({
    required this.headlineLine1,
    required this.headlineAccent,
    required this.subtitle,
    required this.subtitleRegister,
    required this.emailLabel,
    required this.emailPlaceholder,
    required this.passwordLabel,
    required this.forgotPassword,
    required this.login,
    required this.signUpCta,
    required this.orContinueWith,
    required this.googleSignIn,
    required this.noAccountPrompt,
    required this.createAccount,
    required this.alreadyHaveAccountPrompt,
    required this.signInLink,
    required this.enterCredentials,
    required this.resetEmailSent,
    required this.signedInAs,
    required this.cornerImageUrl,
  });

  final String headlineLine1;
  final String headlineAccent;
  final String subtitle;
  final String subtitleRegister;
  final String emailLabel;
  final String emailPlaceholder;
  final String passwordLabel;
  final String forgotPassword;
  final String login;
  final String signUpCta;
  final String orContinueWith;
  final String googleSignIn;
  final String noAccountPrompt;
  final String createAccount;
  final String alreadyHaveAccountPrompt;
  final String signInLink;
  final String enterCredentials;
  final String resetEmailSent;
  /// Use `{email}` as placeholder for the signed-in address.
  final String signedInAs;
  final String cornerImageUrl;

  factory LoginScreenStrings.fromJson(Map<String, dynamic> json) {
    String s(String key, [String fallback = '']) =>
        json[key] as String? ?? fallback;

    return LoginScreenStrings(
      headlineLine1: s('headlineLine1', 'Welcome Back, '),
      headlineAccent: s('headlineAccent', 'Chef!'),
      subtitle: s('subtitle', 'Your kitchen is waiting for you.'),
      subtitleRegister: s(
        'subtitleRegister',
        'Create an account to sync your kitchen.',
      ),
      emailLabel: s('emailLabel', 'EMAIL ADDRESS'),
      emailPlaceholder: s('emailPlaceholder', 'chef@mealmorph.com'),
      passwordLabel: s('passwordLabel', 'PASSWORD'),
      forgotPassword: s('forgotPassword', 'Forgot Password?'),
      login: s('login', 'Login'),
      signUpCta: s('signUpCta', 'Create account'),
      orContinueWith: s('orContinueWith', 'OR CONTINUE WITH'),
      googleSignIn: s('googleSignIn', 'Continue with Google'),
      noAccountPrompt: s('noAccountPrompt', "Don't have an account yet? "),
      createAccount: s('createAccount', 'Create an Account'),
      alreadyHaveAccountPrompt: s(
        'alreadyHaveAccountPrompt',
        'Already have an account? ',
      ),
      signInLink: s('signInLink', 'Sign in'),
      enterCredentials: s(
        'enterCredentials',
        'Enter your email and password.',
      ),
      resetEmailSent: s(
        'resetEmailSent',
        'If that email is registered, you will receive a reset link.',
      ),
      signedInAs: s('signedInAs', 'Signed in as {email}'),
      cornerImageUrl: s('cornerImageUrl'),
    );
  }
}

class FridgeScreenStrings {
  const FridgeScreenStrings({
    required this.pageTitle,
    required this.pageSubtitle,
    required this.itemsStoredLabel,
    required this.expiringSoonLabel,
    required this.scanReceiptTitle,
    required this.scanReceiptSubtitle,
    required this.manualEntryTitle,
    required this.manualEntrySubtitle,
    required this.identifiedIngredients,
    required this.unnamedItem,
    required this.fromCameraNote,
    required this.morphIngredients,
    required this.addItemsFromCameraFirst,
    required this.morphPlaceholder,
    required this.navHome,
    required this.navRecipes,
    required this.navScan,
    required this.navProfile,
    required this.comingSoon,
    required this.captureDialogTitle,
    required this.nameOptionalHint,
    required this.detailOptionalHint,
    required this.markExpiringSoon,
    required this.save,
    required this.cancel,
    required this.cameraUnavailable,
    required this.removeItem,
    required this.emptyListHint,
  });

  final String pageTitle;
  final String pageSubtitle;
  final String itemsStoredLabel;
  final String expiringSoonLabel;
  final String scanReceiptTitle;
  final String scanReceiptSubtitle;
  final String manualEntryTitle;
  final String manualEntrySubtitle;
  final String identifiedIngredients;
  final String unnamedItem;
  final String fromCameraNote;
  final String morphIngredients;
  final String addItemsFromCameraFirst;
  final String morphPlaceholder;
  final String navHome;
  final String navRecipes;
  final String navScan;
  final String navProfile;
  final String comingSoon;
  final String captureDialogTitle;
  final String nameOptionalHint;
  final String detailOptionalHint;
  final String markExpiringSoon;
  final String save;
  final String cancel;
  final String cameraUnavailable;
  final String removeItem;
  final String emptyListHint;

  factory FridgeScreenStrings.fromJson(Map<String, dynamic> json) {
    String s(String key, [String fallback = '']) =>
        json[key] as String? ?? fallback;

    return FridgeScreenStrings(
      pageTitle: s('pageTitle', 'My Fridge'),
      pageSubtitle: s(
        'pageSubtitle',
        'A digital snapshot of your current fresh ingredients.',
      ),
      itemsStoredLabel: s('itemsStoredLabel', 'Items Stored'),
      expiringSoonLabel: s('expiringSoonLabel', 'Expiring Soon'),
      scanReceiptTitle: s('scanReceiptTitle', 'Scan Receipt'),
      scanReceiptSubtitle: s('scanReceiptSubtitle', 'Bulk add from grocery run'),
      manualEntryTitle: s('manualEntryTitle', 'Manual Entry'),
      manualEntrySubtitle: s('manualEntrySubtitle', 'Add one item at a time'),
      identifiedIngredients: s('identifiedIngredients', 'Identified Ingredients'),
      unnamedItem: s('unnamedItem', 'Ingredient'),
      fromCameraNote: s('fromCameraNote', 'From camera'),
      morphIngredients: s('morphIngredients', 'Morph Ingredients'),
      addItemsFromCameraFirst: s(
        'addItemsFromCameraFirst',
        'Capture ingredients with the camera first.',
      ),
      morphPlaceholder: s(
        'morphPlaceholder',
        'Recipe ideas will use your captured items.',
      ),
      navHome: s('navHome', 'Home'),
      navRecipes: s('navRecipes', 'Recipes'),
      navScan: s('navScan', 'Scan'),
      navProfile: s('navProfile', 'Profile'),
      comingSoon: s('comingSoon', 'Coming soon'),
      captureDialogTitle: s('captureDialogTitle', 'Describe this capture'),
      nameOptionalHint: s('nameOptionalHint', 'Name (optional)'),
      detailOptionalHint: s('detailOptionalHint', 'Note (optional)'),
      markExpiringSoon: s('markExpiringSoon', 'Expiring soon'),
      save: s('save', 'Save'),
      cancel: s('cancel', 'Cancel'),
      cameraUnavailable: s(
        'cameraUnavailable',
        'Could not open the camera.',
      ),
      removeItem: s('removeItem', 'Remove'),
      emptyListHint: s(
        'emptyListHint',
        'Capture from the camera using Scan Receipt, Manual Entry, or the Scan tab.',
      ),
    );
  }
}
