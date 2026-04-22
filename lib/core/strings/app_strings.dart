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
    required this.recipes,
    required this.profile,
    required this.scan,
    required this.addToFridge,
  });

  final AppTitleStrings app;
  final ExpiryPriorityOnboardingStrings expiryPriorityOnboarding;
  final SnapFridgeOnboardingStrings snapFridgeOnboarding;
  final LoginScreenStrings login;
  final FridgeScreenStrings fridge;
  final RecipesScreenStrings recipes;
  final ProfileScreenStrings profile;
  final ScanScreenStrings scan;
  final AddToFridgeStrings addToFridge;

  static const String defaultAssetPath = 'assets/strings/text.json';

  static Future<AppStrings> load({String assetPath = defaultAssetPath}) async {
    final raw = await rootBundle.loadString(assetPath);
    return AppStrings.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  factory AppStrings.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> section(String key) =>
        (json[key] as Map<String, dynamic>?) ?? const {};

    final onboarding = section('onboarding');
    final auth = section('auth');

    return AppStrings(
      app: AppTitleStrings(title: section('app')['title'] as String? ?? 'MealMorph'),
      expiryPriorityOnboarding: ExpiryPriorityOnboardingStrings.fromJson(
        (onboarding['expiryPriority'] as Map<String, dynamic>?) ?? const {},
      ),
      snapFridgeOnboarding: SnapFridgeOnboardingStrings.fromJson(
        (onboarding['snapFridge'] as Map<String, dynamic>?) ?? const {},
      ),
      login: LoginScreenStrings.fromJson(
        (auth['login'] as Map<String, dynamic>?) ?? const {},
      ),
      fridge: FridgeScreenStrings.fromJson(section('fridge')),
      recipes: RecipesScreenStrings.fromJson(section('recipes')),
      profile: ProfileScreenStrings.fromJson(section('profile')),
      scan: ScanScreenStrings.fromJson(section('scan')),
      addToFridge: AddToFridgeStrings.fromJson(section('addToFridge')),
    );
  }
}

class AppTitleStrings {
  const AppTitleStrings({required this.title});

  final String title;
}

String _s(Map<String, dynamic> json, String key, [String fallback = '']) =>
    json[key] as String? ?? fallback;

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
    return ExpiryPriorityOnboardingStrings(
      heroImageUrl: _s(json, 'heroImageUrl'),
      brand: _s(json, 'brand', 'MealMorph'),
      kicker: _s(json, 'kicker'),
      headline: _s(json, 'headline'),
      body: _s(json, 'body'),
      next: _s(json, 'next', 'Next'),
      skip: _s(json, 'skip', 'Skip'),
      chipExpiringSoon: _s(json, 'chipExpiringSoon'),
      chipUseWithin: _s(json, 'chipUseWithin'),
      smartScanTitle: _s(json, 'smartScanTitle'),
      smartScanSubtitle: _s(json, 'smartScanSubtitle'),
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
    return SnapFridgeOnboardingStrings(
      heroImageUrl: _s(json, 'heroImageUrl'),
      brand: _s(json, 'brand', 'MealMorph'),
      kicker: _s(json, 'kicker'),
      headlineLine1: _s(json, 'headlineLine1'),
      headlineAccent: _s(json, 'headlineAccent'),
      body: _s(json, 'body'),
      getStarted: _s(json, 'getStarted', 'Get Started'),
      signIn: _s(json, 'signIn', 'Sign In'),
      floatAiTitle: _s(json, 'floatAiTitle'),
      floatAiSubtitle: _s(json, 'floatAiSubtitle'),
      floatEcoTitle: _s(json, 'floatEcoTitle'),
      floatEcoSubtitle: _s(json, 'floatEcoSubtitle'),
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
    return LoginScreenStrings(
      headlineLine1: _s(json, 'headlineLine1', 'Welcome Back, '),
      headlineAccent: _s(json, 'headlineAccent', 'Chef!'),
      subtitle: _s(json, 'subtitle', 'Your kitchen is waiting for you.'),
      subtitleRegister: _s(
        json,
        'subtitleRegister',
        'Create an account to sync your kitchen.',
      ),
      emailLabel: _s(json, 'emailLabel', 'EMAIL ADDRESS'),
      emailPlaceholder: _s(json, 'emailPlaceholder', 'chef@mealmorph.com'),
      passwordLabel: _s(json, 'passwordLabel', 'PASSWORD'),
      forgotPassword: _s(json, 'forgotPassword', 'Forgot Password?'),
      login: _s(json, 'login', 'Login'),
      signUpCta: _s(json, 'signUpCta', 'Create account'),
      orContinueWith: _s(json, 'orContinueWith', 'OR CONTINUE WITH'),
      googleSignIn: _s(json, 'googleSignIn', 'Continue with Google'),
      noAccountPrompt: _s(
        json,
        'noAccountPrompt',
        "Don't have an account yet? ",
      ),
      createAccount: _s(json, 'createAccount', 'Create an Account'),
      alreadyHaveAccountPrompt: _s(
        json,
        'alreadyHaveAccountPrompt',
        'Already have an account? ',
      ),
      signInLink: _s(json, 'signInLink', 'Sign in'),
      enterCredentials: _s(
        json,
        'enterCredentials',
        'Enter your email and password.',
      ),
      resetEmailSent: _s(
        json,
        'resetEmailSent',
        'If that email is registered, you will receive a reset link.',
      ),
      signedInAs: _s(json, 'signedInAs', 'Signed in as {email}'),
      cornerImageUrl: _s(json, 'cornerImageUrl'),
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
    return FridgeScreenStrings(
      pageTitle: _s(json, 'pageTitle', 'My Fridge'),
      pageSubtitle: _s(
        json,
        'pageSubtitle',
        'A digital snapshot of your current fresh ingredients.',
      ),
      itemsStoredLabel: _s(json, 'itemsStoredLabel', 'Items Stored'),
      expiringSoonLabel: _s(json, 'expiringSoonLabel', 'Expiring Soon'),
      scanReceiptTitle: _s(json, 'scanReceiptTitle', 'Scan Receipt'),
      scanReceiptSubtitle: _s(json, 'scanReceiptSubtitle', 'Bulk add from grocery run'),
      manualEntryTitle: _s(json, 'manualEntryTitle', 'Manual Entry'),
      manualEntrySubtitle: _s(json, 'manualEntrySubtitle', 'Add one item at a time'),
      identifiedIngredients: _s(json, 'identifiedIngredients', 'Identified Ingredients'),
      unnamedItem: _s(json, 'unnamedItem', 'Ingredient'),
      fromCameraNote: _s(json, 'fromCameraNote', 'From camera'),
      morphIngredients: _s(json, 'morphIngredients', 'Morph Ingredients'),
      addItemsFromCameraFirst: _s(
        json,
        'addItemsFromCameraFirst',
        'Capture ingredients with the camera first.',
      ),
      morphPlaceholder: _s(
        json,
        'morphPlaceholder',
        'Recipe ideas will use your captured items.',
      ),
      navHome: _s(json, 'navHome', 'Home'),
      navRecipes: _s(json, 'navRecipes', 'Recipes'),
      navScan: _s(json, 'navScan', 'Scan'),
      navProfile: _s(json, 'navProfile', 'Profile'),
      comingSoon: _s(json, 'comingSoon', 'Coming soon'),
      captureDialogTitle: _s(json, 'captureDialogTitle', 'Describe this capture'),
      nameOptionalHint: _s(json, 'nameOptionalHint', 'Name (optional)'),
      detailOptionalHint: _s(json, 'detailOptionalHint', 'Note (optional)'),
      markExpiringSoon: _s(json, 'markExpiringSoon', 'Expiring soon'),
      save: _s(json, 'save', 'Save'),
      cancel: _s(json, 'cancel', 'Cancel'),
      cameraUnavailable: _s(json, 'cameraUnavailable', 'Could not open the camera.'),
      removeItem: _s(json, 'removeItem', 'Remove'),
      emptyListHint: _s(
        json,
        'emptyListHint',
        'Capture from the camera using Scan Receipt, Manual Entry, or the Scan tab.',
      ),
    );
  }
}

class RecipesScreenStrings {
  const RecipesScreenStrings({
    required this.pageTitle,
    required this.pageSubtitle,
    required this.chipAll,
    required this.generateCta,
    required this.startCookingCta,
    required this.featuredLabel,
    required this.morphActiveLabel,
    required this.minutesSuffix,
    required this.emptyTitle,
    required this.emptySubtitle,
    required this.loadingTitle,
    required this.loadingSubtitle,
    required this.errorTitle,
    required this.errorRetry,
    required this.scanReceiptBanner,
    required this.scanReceiptCta,
    required this.usesPrefix,
    required this.usesSuffix,
    required this.difficultyBeginner,
    required this.difficultyIntermediate,
    required this.difficultyPro,
  });

  final String pageTitle;
  final String pageSubtitle;
  final String chipAll;
  final String generateCta;
  final String startCookingCta;
  final String featuredLabel;
  final String morphActiveLabel;
  final String minutesSuffix;
  final String emptyTitle;
  final String emptySubtitle;
  final String loadingTitle;
  final String loadingSubtitle;
  final String errorTitle;
  final String errorRetry;
  final String scanReceiptBanner;
  final String scanReceiptCta;
  final String usesPrefix;
  final String usesSuffix;
  final String difficultyBeginner;
  final String difficultyIntermediate;
  final String difficultyPro;

  factory RecipesScreenStrings.fromJson(Map<String, dynamic> json) {
    final diff = (json['difficulty'] as Map<String, dynamic>?) ?? const {};
    return RecipesScreenStrings(
      pageTitle: _s(json, 'pageTitle', 'Recipes for Your Fridge.'),
      pageSubtitle: _s(
        json,
        'pageSubtitle',
        'We found creative ways to use your ingredients before they expire.',
      ),
      chipAll: _s(json, 'chipAll', 'All Ingredients'),
      generateCta: _s(json, 'generateCta', 'Morph Ingredients'),
      startCookingCta: _s(json, 'startCookingCta', 'Start Cooking'),
      featuredLabel: _s(json, 'featuredLabel', 'Featured'),
      morphActiveLabel: _s(json, 'morphActiveLabel', 'MORPH ACTIVE'),
      minutesSuffix: _s(json, 'minutesSuffix', 'min'),
      emptyTitle: _s(json, 'emptyTitle', 'Nothing in the fridge yet.'),
      emptySubtitle: _s(
        json,
        'emptySubtitle',
        'Add a few ingredients and tap Morph Ingredients to conjure recipes.',
      ),
      loadingTitle: _s(json, 'loadingTitle', 'Morphing ingredients'),
      loadingSubtitle: _s(
        json,
        'loadingSubtitle',
        "Curating recipes tuned to what's about to expire.",
      ),
      errorTitle: _s(json, 'errorTitle', "Couldn't reach the kitchen brain."),
      errorRetry: _s(json, 'errorRetry', 'Retry'),
      scanReceiptBanner: _s(
        json,
        'scanReceiptBanner',
        'Scan your grocery receipt to update your ingredient list automatically.',
      ),
      scanReceiptCta: _s(json, 'scanReceiptCta', 'Scan Receipt'),
      usesPrefix: _s(json, 'usesPrefix', 'Uses'),
      usesSuffix: _s(json, 'usesSuffix', 'of your items'),
      difficultyBeginner: _s(diff, 'beginner', 'Beginner'),
      difficultyIntermediate: _s(diff, 'intermediate', 'Intermediate'),
      difficultyPro: _s(diff, 'pro', 'Pro'),
    );
  }
}

class ProfileScreenStrings {
  const ProfileScreenStrings({
    required this.pageTitle,
    required this.roleLabel,
    required this.accountDetailsTitle,
    required this.accountDetailsSubtitle,
    required this.cookingSkillTitle,
    required this.cookingSkillNovice,
    required this.cookingSkillIntermediate,
    required this.cookingSkillMaster,
    required this.notificationsTitle,
    required this.logoutCta,
    required this.deleteAccountCta,
    required this.confirmDeleteTitle,
    required this.confirmDeleteBody,
    required this.confirmDeleteCancel,
    required this.confirmDeleteConfirm,
    required this.deleteAccountSuccess,
    required this.deleteRequiresRecentLogin,
    required this.defaultName,
  });

  final String pageTitle;

  /// `{year}` placeholder is substituted at render time.
  final String roleLabel;
  final String accountDetailsTitle;
  final String accountDetailsSubtitle;
  final String cookingSkillTitle;
  final String cookingSkillNovice;
  final String cookingSkillIntermediate;
  final String cookingSkillMaster;
  final String notificationsTitle;
  final String logoutCta;
  final String deleteAccountCta;
  final String confirmDeleteTitle;
  final String confirmDeleteBody;
  final String confirmDeleteCancel;
  final String confirmDeleteConfirm;
  final String deleteAccountSuccess;
  final String deleteRequiresRecentLogin;
  final String defaultName;

  factory ProfileScreenStrings.fromJson(Map<String, dynamic> json) {
    return ProfileScreenStrings(
      pageTitle: _s(json, 'pageTitle', 'Profile'),
      roleLabel: _s(json, 'roleLabel', 'Home Chef since {year}'),
      accountDetailsTitle: _s(json, 'accountDetailsTitle', 'Account Details'),
      accountDetailsSubtitle: _s(
        json,
        'accountDetailsSubtitle',
        'Manage your personal information and subscription preferences.',
      ),
      cookingSkillTitle: _s(json, 'cookingSkillTitle', 'Cooking Skill Level'),
      cookingSkillNovice: _s(json, 'cookingSkillNovice', 'Novice'),
      cookingSkillIntermediate: _s(json, 'cookingSkillIntermediate', 'Intermediate'),
      cookingSkillMaster: _s(json, 'cookingSkillMaster', 'Master'),
      notificationsTitle: _s(json, 'notificationsTitle', 'Notification Settings'),
      logoutCta: _s(json, 'logoutCta', 'Logout'),
      deleteAccountCta: _s(json, 'deleteAccountCta', 'Delete Account'),
      confirmDeleteTitle: _s(json, 'confirmDeleteTitle', 'Delete your account?'),
      confirmDeleteBody: _s(
        json,
        'confirmDeleteBody',
        'This will permanently remove your kitchen data. This cannot be undone.',
      ),
      confirmDeleteCancel: _s(json, 'confirmDeleteCancel', 'Cancel'),
      confirmDeleteConfirm: _s(json, 'confirmDeleteConfirm', 'Delete'),
      deleteAccountSuccess: _s(json, 'deleteAccountSuccess', 'Account deleted.'),
      deleteRequiresRecentLogin: _s(
        json,
        'deleteRequiresRecentLogin',
        'Please sign in again before deleting your account.',
      ),
      defaultName: _s(json, 'defaultName', 'Chef'),
    );
  }
}

class ScanScreenStrings {
  const ScanScreenStrings({
    required this.pageTitle,
    required this.alignReceiptInstruction,
    required this.fridgeMode,
    required this.receiptMode,
    required this.capture,
    required this.retake,
    required this.addAll,
    required this.scanningProgress,
    required this.itemsFound,
    required this.cameraUnavailable,
    required this.analysing,
    required this.addedSnack,
    required this.modeInstructionsFridge,
    required this.modeInstructionsReceipt,
    required this.noItemsFound,
    required this.liveBadge,
    required this.mockBadge,
  });

  final String pageTitle;
  final String alignReceiptInstruction;
  final String fridgeMode;
  final String receiptMode;
  final String capture;
  final String retake;
  final String addAll;
  final String scanningProgress;

  /// `{count}` substituted at render time.
  final String itemsFound;
  final String cameraUnavailable;
  final String analysing;

  /// `{count}` substituted at render time.
  final String addedSnack;
  final String modeInstructionsFridge;
  final String modeInstructionsReceipt;
  final String noItemsFound;
  final String liveBadge;
  final String mockBadge;

  factory ScanScreenStrings.fromJson(Map<String, dynamic> json) {
    return ScanScreenStrings(
      pageTitle: _s(json, 'pageTitle', 'Scan'),
      alignReceiptInstruction: _s(
        json,
        'alignReceiptInstruction',
        'Align the receipt within the frame',
      ),
      fridgeMode: _s(json, 'fridgeMode', 'Fridge'),
      receiptMode: _s(json, 'receiptMode', 'Receipt'),
      capture: _s(json, 'capture', 'Capture'),
      retake: _s(json, 'retake', 'Retake'),
      addAll: _s(json, 'addAll', 'Add all to fridge'),
      scanningProgress: _s(json, 'scanningProgress', 'SCANNING PROGRESS'),
      itemsFound: _s(json, 'itemsFound', '{count} Items Found'),
      cameraUnavailable: _s(json, 'cameraUnavailable', "Couldn't open the camera."),
      analysing: _s(json, 'analysing', 'Analysing your scan…'),
      addedSnack: _s(json, 'addedSnack', '{count} items added to your fridge.'),
      modeInstructionsFridge: _s(
        json,
        'modeInstructionsFridge',
        'Point the camera at your open fridge or countertop. AI will identify every visible ingredient.',
      ),
      modeInstructionsReceipt: _s(
        json,
        'modeInstructionsReceipt',
        'Align a grocery receipt within the frame. AI will parse each food item.',
      ),
      noItemsFound: _s(
        json,
        'noItemsFound',
        'No ingredients identified. Try again with better lighting.',
      ),
      liveBadge: _s(json, 'live', 'Live AI'),
      mockBadge: _s(json, 'mock', 'Demo mode'),
    );
  }
}

class AddToFridgeStrings {
  const AddToFridgeStrings({
    required this.pageTitle,
    required this.pageSubtitle,
    required this.searchHint,
    required this.quickCategoriesTitle,
    required this.viewAll,
    required this.quantityLabel,
    required this.unitPieces,
    required this.unitWeight,
    required this.unitVolume,
    required this.expiryTitle,
    required this.bestBefore,
    required this.shortLife,
    required this.shortLifeLabel,
    required this.longLife,
    required this.longLifeLabel,
    required this.commonlyAddedTitle,
    required this.commonlyAddedEmpty,
    required this.commonlyAddedLastAdded,
    required this.confirmCta,
    required this.clearCta,
    required this.selectCategoryPrompt,
    required this.missingName,
    required this.savedSnack,
  });

  final String pageTitle;
  final String pageSubtitle;
  final String searchHint;
  final String quickCategoriesTitle;
  final String viewAll;
  final String quantityLabel;
  final String unitPieces;
  final String unitWeight;
  final String unitVolume;
  final String expiryTitle;
  final String bestBefore;
  final String shortLife;
  final String shortLifeLabel;
  final String longLife;
  final String longLifeLabel;
  final String commonlyAddedTitle;
  final String commonlyAddedEmpty;

  /// `{days}` substituted at render time.
  final String commonlyAddedLastAdded;
  final String confirmCta;
  final String clearCta;
  final String selectCategoryPrompt;
  final String missingName;
  final String savedSnack;

  factory AddToFridgeStrings.fromJson(Map<String, dynamic> json) {
    return AddToFridgeStrings(
      pageTitle: _s(json, 'pageTitle', 'Add to Fridge'),
      pageSubtitle: _s(
        json,
        'pageSubtitle',
        "Let's keep your digital pantry organized. Search or select a category to begin.",
      ),
      searchHint: _s(json, 'searchHint', 'Search ingredients (e.g. Avocado, Milk…)'),
      quickCategoriesTitle: _s(json, 'quickCategoriesTitle', 'Quick Categories'),
      viewAll: _s(json, 'viewAll', 'View All'),
      quantityLabel: _s(json, 'quantityLabel', 'QUANTITY'),
      unitPieces: _s(json, 'unitPieces', 'Pieces'),
      unitWeight: _s(json, 'unitWeight', 'Weight'),
      unitVolume: _s(json, 'unitVolume', 'Volume'),
      expiryTitle: _s(json, 'expiryTitle', 'ESTIMATED EXPIRY'),
      bestBefore: _s(json, 'bestBefore', 'Best before'),
      shortLife: _s(json, 'shortLife', '+3 Days'),
      shortLifeLabel: _s(json, 'shortLifeLabel', 'Short Life'),
      longLife: _s(json, 'longLife', '+10 Days'),
      longLifeLabel: _s(json, 'longLifeLabel', 'Long Life'),
      commonlyAddedTitle: _s(json, 'commonlyAddedTitle', 'Commonly Added'),
      commonlyAddedEmpty: _s(
        json,
        'commonlyAddedEmpty',
        'Your go-to items will appear here after a few adds.',
      ),
      commonlyAddedLastAdded: _s(
        json,
        'commonlyAddedLastAdded',
        'Last added {days} days ago',
      ),
      confirmCta: _s(json, 'confirmCta', 'Confirm Entry'),
      clearCta: _s(json, 'clearCta', 'Clear all fields'),
      selectCategoryPrompt: _s(
        json,
        'selectCategoryPrompt',
        'Select a category or type to continue.',
      ),
      missingName: _s(json, 'missingName', 'Give this ingredient a name first.'),
      savedSnack: _s(json, 'savedSnack', 'Added to your fridge.'),
    );
  }
}
