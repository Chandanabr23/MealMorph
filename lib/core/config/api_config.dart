import 'package:flutter/foundation.dart';

/// Backend base URL for MealMorph AI services.
///
/// Override at build time with `--dart-define=MEALMORPH_API_BASE=<url>`.
/// Default picks a sensible localhost per platform:
///   - Android emulator: http://10.0.2.2:8787 (host loopback)
///   - Everything else:  http://localhost:8787
abstract final class ApiConfig {
  static const String _override = String.fromEnvironment('MEALMORPH_API_BASE');

  static String get baseUrl {
    if (_override.isNotEmpty) return _override;
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8787';
    }
    return 'http://localhost:8787';
  }
}
