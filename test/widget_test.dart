import 'package:flutter_test/flutter_test.dart';

import 'package:mealmorph/app/mealmorph_app.dart';
import 'package:mealmorph/core/strings/app_strings.dart';

void main() {
  final testStrings = AppStrings.fromJson({
    'app': {'title': 'MealMorph'},
    'onboarding': {
      'expiryPriority': {
        'heroImageUrl': '',
        'brand': 'MealMorph',
        'kicker': 'EXPIRY PRIORITY',
        'headline': 'Prioritize What Matters.',
        'body':
            'We intelligently surface recipes using ingredients closest to their expiry date, saving you money and reducing waste.',
        'next': 'Next',
        'skip': 'Skip',
        'chipExpiringSoon': 'Expiring Soon: Spinach',
        'chipUseWithin': 'Use within 2 days: Salmon',
        'smartScanTitle': 'SMART SCAN',
        'smartScanSubtitle': 'Tracking 12 items in pantry',
      },
      'snapFridge': {
        'heroImageUrl': '',
        'brand': 'MealMorph',
        'kicker': 'Snap Your Fridge',
        'headlineLine1': 'Stop Wasting,',
        'headlineAccent': 'Start Morphing.',
        'body': 'Snap a photo.',
        'getStarted': 'Get Started',
        'signIn': 'Sign In',
        'floatAiTitle': 'AI Scanning...',
        'floatAiSubtitle': 'Detected: Spinach',
        'floatEcoTitle': 'Zero Waste',
        'floatEcoSubtitle': 'Saved 2.4kg',
      },
    },
  });

  testWidgets('Onboarding shows headline and actions', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(MealMorphApp(strings: testStrings));

    expect(find.text('MealMorph'), findsWidgets);
    expect(find.text('Prioritize What Matters.'), findsOneWidget);
    expect(find.text('Next'), findsOneWidget);
    expect(find.text('Skip'), findsOneWidget);
  });
}
