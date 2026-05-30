import 'dart:io' show Platform;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

// --- Desktop specific imports ---
import 'package:googleapis_auth/auth_io.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

// --- [Providers] ---

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final authStateChangesProvider = StreamProvider<User?>((ref) {
  return ref.watch(firebaseAuthProvider).authStateChanges();
});

// --- [Controller] ---

final authControllerProvider = NotifierProvider<AuthController, AsyncValue<User?>>(() {
  return AuthController();
});

class AuthController extends Notifier<AsyncValue<User?>> {
  @override
  AsyncValue<User?> build() {
    return ref.watch(authStateChangesProvider);
  }

  /// Handles the Google Sign-In flow across all platforms.
  Future<void> signInWithGoogle() async {
    final firebaseAuth = ref.read(firebaseAuthProvider);

    // 1. Check if we are running on Desktop (Windows, macOS, Linux)
    if (!kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux)) {
      
      // Fetch credentials injected during compile-time
      const desktopClientId = String.fromEnvironment('DESKTOP_CLIENT_ID');
      const desktopClientSecret = String.fromEnvironment('DESKTOP_CLIENT_SECRET');
      
      // Safety check to ensure credentials are provided
      if (desktopClientId.isEmpty || desktopClientSecret.isEmpty) {
        throw StateError(
          'Missing OAuth credentials. Please run the app with --dart-define-from-file=env.json',
        );
      }

      final scopes = ['email', 'profile', 'openid'];
      final httpClient = http.Client();
      
      // Use the securely injected credentials
      final clientId = ClientId(desktopClientId, desktopClientSecret);

      try {
        final AccessCredentials credentials = await obtainAccessCredentialsViaUserConsent(
          clientId,
          scopes,
          httpClient,
          (String url) async {
            final uri = Uri.parse(url);
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri);
            } else {
              throw Exception('Could not launch browser for login.');
            }
          },
        );

        final credential = GoogleAuthProvider.credential(
          idToken: credentials.idToken,
          accessToken: credentials.accessToken.data,
        );

        await firebaseAuth.signInWithCredential(credential);
      } finally {
        httpClient.close();
      }

    }
    // 2. Standard flow for Mobile (Android/iOS) and Web
    else {
      final googleSignIn = GoogleSignIn.instance;
      await googleSignIn.initialize();

      final GoogleSignInAccount googleUser = await googleSignIn.authenticate();
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      await firebaseAuth.signInWithCredential(credential);
    }
  }

  /// Handles the Sign-Out flow.
  Future<void> signOut() async {
    // If not desktop, sign out from the official google_sign_in package
    if (kIsWeb || (!Platform.isWindows && !Platform.isMacOS && !Platform.isLinux)) {
      await GoogleSignIn.instance.signOut();
    }
    // Sign out from Firebase
    await ref.read(firebaseAuthProvider).signOut();
  }
}