import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform;

import '../firebase_options.dart';

/// Initializes Firebase once.
///
/// On Android and iOS the native SDK already creates `[DEFAULT]` from
/// `google-services.json` / `GoogleService-Info.plist`. Calling
/// [Firebase.initializeApp] **without** options lets FlutterFire attach to that
/// app. Passing [DefaultFirebaseOptions] when native options differ triggers
/// `[core/duplicate-app]`.
Future<void> ensureFirebaseInitialized() async {
  if (Firebase.apps.isNotEmpty) {
    return;
  }

  if (!kIsWeb) {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
      case TargetPlatform.iOS:
        try {
          await Firebase.initializeApp();
          return;
        } on FirebaseException catch (e) {
          if (e.code == 'duplicate-app') {
            return;
          }
          if (e.code != 'not-initialized') {
            rethrow;
          }
        }
      default:
        break;
    }
  }

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } on FirebaseException catch (e) {
    if (e.code == 'duplicate-app') {
      return;
    }
    rethrow;
  }
}
