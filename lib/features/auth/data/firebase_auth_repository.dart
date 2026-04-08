import 'dart:developer' as developer;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart'
    show kDebugMode, kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:flutter/services.dart' show PlatformException;
import 'package:google_sign_in/google_sign_in.dart';

import '../../../core/config/google_sign_in_config.dart';

/// Shown when Google returns no ID token (common on Android without Web client ID / SHA-1).
class GoogleSignInConfigurationException implements Exception {
  GoogleSignInConfigurationException(this.message);
  final String message;

  @override
  String toString() => message;
}

GoogleSignIn _defaultGoogleSignIn() {
  final String? clientId;
  final String? serverClientId;

  if (kIsWeb) {
    clientId = null;
    serverClientId = null;
  } else {
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        clientId = kGoogleIosOAuthClientId.isEmpty
            ? null
            : kGoogleIosOAuthClientId;
        serverClientId = null;
      case TargetPlatform.android:
        clientId = null;
        serverClientId = kGoogleWebOAuthClientId.isEmpty
            ? null
            : kGoogleWebOAuthClientId;
      default:
        clientId = null;
        serverClientId = null;
    }
  }

  return GoogleSignIn(
    scopes: const <String>['email', 'profile'],
    clientId: clientId,
    serverClientId: serverClientId,
  );
}

String _googleSignInPlatformMessage(PlatformException e) {
  switch (e.code) {
    case GoogleSignIn.kSignInCanceledError:
      return 'Sign-in was canceled.';
    case GoogleSignIn.kNetworkError:
      return 'Google Sign-In network error. Check your connection.';
    case GoogleSignIn.kSignInFailedError:
      return e.message?.isNotEmpty == true
          ? e.message!
          : 'Google Sign-In failed. Check iOS URL scheme (REVERSED_CLIENT_ID) and OAuth client IDs.';
    default:
      final detail = e.message?.trim();
      if (detail != null && detail.isNotEmpty) {
        return 'Google Sign-In: $detail';
      }
      return 'Google Sign-In failed (${e.code}).';
  }
}

/// Firebase email/password and Google sign-in.
class FirebaseAuthRepository {
  FirebaseAuthRepository({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  })  : _auth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? _defaultGoogleSignIn();

  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;

  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) {
    return _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<UserCredential> createUserWithEmail({
    required String email,
    required String password,
  }) {
    return _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<void> sendPasswordResetEmail(String email) {
    return _auth.sendPasswordResetEmail(email: email.trim());
  }

  /// Returns null if the user closed the Google picker.
  Future<UserCredential?> signInWithGoogle() async {
    GoogleSignInAccount? account;
    try {
      account = await _googleSignIn.signIn();
    } on PlatformException catch (e) {
      if (e.code == GoogleSignIn.kSignInCanceledError) {
        return null;
      }
      throw GoogleSignInConfigurationException(_googleSignInPlatformMessage(e));
    }
    if (account == null) return null;

    GoogleSignInAuthentication googleAuth;
    try {
      googleAuth = await account.authentication;
    } on PlatformException catch (e) {
      throw GoogleSignInConfigurationException(_googleSignInPlatformMessage(e));
    }

    if (googleAuth.idToken == null || googleAuth.idToken!.isEmpty) {
      throw GoogleSignInConfigurationException(
        'Google Sign-In did not provide an ID token. '
        'Android: add your app’s SHA-1 in Firebase → Project settings → Your Android app, '
        're-download google-services.json (until `oauth_client` is non-empty), '
        'or run with --dart-define=GOOGLE_WEB_CLIENT_ID=<Web OAuth client>.apps.googleusercontent.com. '
        'iOS/macOS: set --dart-define=GOOGLE_IOS_CLIENT_ID=<iOS OAuth client>.apps.googleusercontent.com '
        'and in ios/Flutter/GoogleSignIn.xcconfig set REVERSED_GOOGLE_CLIENT_ID to the '
        'REVERSED_CLIENT_ID from a full GoogleService-Info.plist (or '
        'com.googleusercontent.apps.<prefix> where <prefix> is the client id before ".apps…").',
      );
    }

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    return _auth.signInWithCredential(credential);
  }
}

bool _firebaseAuthMentionsConfigurationNotFound(FirebaseAuthException e) {
  final blob = '${e.message ?? ''}\n${e.toString()}';
  return blob.toUpperCase().contains('CONFIGURATION_NOT_FOUND');
}

String firebaseAuthErrorMessage(Object error) {
  if (error is GoogleSignInConfigurationException) {
    return error.message;
  }
  if (error is FirebaseAuthException) {
    if (_firebaseAuthMentionsConfigurationNotFound(error)) {
      return 'Firebase Auth is not available for this app (CONFIGURATION_NOT_FOUND). '
          'In Google Cloud Console, open the same project as Firebase → enable the Identity Toolkit API '
          '(APIs & Services → Library → “Identity Toolkit API”). '
          'If the Firebase API key is restricted, allow Identity Toolkit or relax key restrictions for testing. '
          'Re-download Firebase config if the project was wrong.';
    }
    switch (error.code) {
      case 'invalid-email':
        return 'That email address looks invalid.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
        return 'No account found for that email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'An account already exists with that email.';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'invalid-credential':
        return 'Wrong email or password, or this account uses a different sign-in method.';
      case 'account-exists-with-different-credential':
        return 'An account already exists with the same email using a different sign-in method. '
            'Sign in with the original method first, or link accounts in Firebase Console.';
      case 'network-request-failed':
        return 'Network error. Check your connection.';
      case 'operation-not-allowed':
        return 'This sign-in method is turned off in Firebase Console (Authentication → Sign-in method).';
      case 'too-many-requests':
        return 'Too many attempts. Wait a few minutes and try again.';
      case 'internal-error':
        if (kDebugMode) {
          developer.log(
            'FirebaseAuthException: code=${error.code}, message=${error.message}',
            name: 'firebase_auth',
          );
        }
        final detail = error.message?.trim();
        const hint =
            'If logs show CONFIGURATION_NOT_FOUND: Google Cloud Console → APIs & Services → '
            'Library → enable Identity Toolkit API for this Firebase project; check API key restrictions. '
            'Otherwise enable sign-in providers in Firebase → Authentication. For Google on Android: '
            'SHA-1 + fresh google-services.json or GOOGLE_WEB_CLIENT_ID; iOS: REVERSED_CLIENT_ID in Info.plist '
            'and GOOGLE_IOS_CLIENT_ID / xcconfig.';
        if (detail != null && detail.isNotEmpty) {
          return '$detail $hint';
        }
        return 'Firebase sign-in failed. $hint';
      case 'invalid-api-key':
        return 'Invalid Firebase configuration. Re-check google-services.json / Firebase options.';
      case 'app-not-authorized':
        return 'This app is not authorized to use Firebase Authentication.';
      default:
        return error.message?.isNotEmpty == true
            ? error.message!
            : 'Something went wrong. Try again.';
    }
  }
  if (error is PlatformException) {
    return _googleSignInPlatformMessage(error);
  }
  return 'Something went wrong. Try again.';
}
