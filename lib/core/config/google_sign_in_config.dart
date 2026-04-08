/// Web OAuth client ID (`….apps.googleusercontent.com`) from the same Firebase/GCP project.
///
/// **Android:** Required for a Firebase **ID token** unless `google-services.json` contains
/// a non-empty `oauth_client` (add **SHA-1** in Firebase → Project settings → Android app,
/// then re-download `google-services.json`).
///
/// Find the Web client: Firebase → Project settings → add a **Web** app if needed → config,
/// or Google Cloud → APIs & Credentials → OAuth 2.0 Client IDs → **Web application**.
///
/// **iOS / macOS:** OAuth client ID for application type **iOS** (same GCP project, bundle
/// ID `com.example.mealmorph`). Prefer `GOOGLE_IOS_CLIENT_ID` in Dart **or** real values in
/// `ios/Flutter/GoogleSignIn.xcconfig` (not the `YOUR_PART` placeholder).
///
/// Run (both recommended for Google + Firebase Auth):
/// `flutter run --dart-define=GOOGLE_WEB_CLIENT_ID=...apps.googleusercontent.com --dart-define=GOOGLE_IOS_CLIENT_ID=...apps.googleusercontent.com`
///
/// If Auth returns `CONFIGURATION_NOT_FOUND`, enable **Identity Toolkit API** in Google Cloud
/// for this Firebase project and check API key restrictions.
const String kGoogleWebOAuthClientId = String.fromEnvironment(
  'GOOGLE_WEB_CLIENT_ID',
  defaultValue: '',
);

const String kGoogleIosOAuthClientId = String.fromEnvironment(
  'GOOGLE_IOS_CLIENT_ID',
  defaultValue: '',
);
