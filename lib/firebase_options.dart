// Generated from android/app/google-services.json and ios/Runner/GoogleService-Info.plist.
// Web: add a Web app in Firebase Console, run `flutterfire configure`, and replace the [web] block.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with [Firebase.initializeApp].
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      // TODO: Add a Web app in Firebase Console → Project Settings → Your apps → Add app (Web).
      // Then run `flutterfire configure` and replace this with the generated `web` options.
      // For now, throwing makes the problem obvious rather than silently using wrong config.
      throw UnsupportedError(
        'Web platform: no Firebase web config yet. '
        'Add a Web app in Firebase Console and run `flutterfire configure`.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      default:
        throw UnsupportedError('Unsupported platform: $defaultTargetPlatform');
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCT_azDbqzg8uF3IWzS4NX4W03OzWduzpQ',
    appId: '1:85195271653:android:041f31f07302449f4a130c',
    messagingSenderId: '85195271653',
    projectId: 'mealmorph-b281f',
    authDomain: 'mealmorph-b281f.firebaseapp.com',
    storageBucket: 'mealmorph-b281f.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyD_w5sKKFlJ1g6igsjIU4gkcMMKI08g1qA',
    appId: '1:85195271653:ios:945181516061fe824a130c',
    messagingSenderId: '85195271653',
    projectId: 'mealmorph-b281f',
    authDomain: 'mealmorph-b281f.firebaseapp.com',
    storageBucket: 'mealmorph-b281f.firebasestorage.app',
    iosBundleId: 'com.example.mealmorph',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyD_w5sKKFlJ1g6igsjIU4gkcMMKI08g1qA',
    appId: '1:85195271653:ios:945181516061fe824a130c',
    messagingSenderId: '85195271653',
    projectId: 'mealmorph-b281f',
    authDomain: 'mealmorph-b281f.firebaseapp.com',
    storageBucket: 'mealmorph-b281f.firebasestorage.app',
    iosBundleId: 'com.example.mealmorph',
  );
}
