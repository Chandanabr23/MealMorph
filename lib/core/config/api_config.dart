/// Backend base URL for MealMorph AI services.
///
/// Override at build time with `--dart-define=MEALMORPH_API_BASE=<url>`.
/// Default: `http://localhost:8787`. On Android, pair this with
/// `adb reverse tcp:8787 tcp:8787` so the phone/emulator's localhost tunnels
/// to the host machine.
abstract final class ApiConfig {
  static const String _override = String.fromEnvironment('MEALMORPH_API_BASE');

  static String get baseUrl {
    if (_override.isNotEmpty) return _override;
    return 'http://localhost:8787';
  }
}
