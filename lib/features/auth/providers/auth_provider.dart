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
      try {
        // ==========================================
        // PLATFORM FORK: The Ultimate Solution
        // ==========================================
        if (kIsWeb) {
          // WEB PLATFORM: Completely bypass the restrictive google_sign_in package.
          // Firebase Auth natively handles the Web OAuth popup securely, 
          // allowing our custom Flutter button to work perfectly without UnimplementedErrors.
          final googleProvider = GoogleAuthProvider();
          googleProvider.addScope('email');
          googleProvider.addScope('profile');
          
          // Automatically uses the Web Client ID configured in your FirebaseOptions (main.dart)
          await firebaseAuth.signInWithPopup(googleProvider);
          
        } else {
          // MOBILE PLATFORM: Use the strict v7 google_sign_in package flow.
          final googleSignIn = GoogleSignIn.instance;
          
          // Mobile usually relies on google-services.json for the Client ID.
          await googleSignIn.initialize(); 

          // Throws exception if user cancels
          final googleUser = await googleSignIn.authenticate();
          
          // idToken is retrieved synchronously
          final googleAuth = googleUser.authentication;

          // Request specific scopes dynamically to obtain the Access Token
          final clientAuth = await googleUser.authorizationClient.authorizeScopes([
            'email', 
            'profile',
          ]);

          // Build the Firebase credential
          final credential = GoogleAuthProvider.credential(
            accessToken: clientAuth.accessToken,
            idToken: googleAuth.idToken,
          );

          await firebaseAuth.signInWithCredential(credential);
        }
      } catch (e) {
        throw Exception('Google Sign-In process was aborted or failed: $e');
      }
    }
  }

  /// Handles the Sign-Out flow.
  Future<void> signOut() async {
    // If not desktop, sign out from the official google_sign_in package
    if (kIsWeb) {
        // Firebase handles Web session cleanup automatically via firebaseAuth.signOut()
      } else if (!Platform.isWindows && !Platform.isMacOS && !Platform.isLinux) {
        // Mobile still needs the GoogleSignIn package to clear local cached accounts
        await GoogleSignIn.instance.signOut();
      }
  }
}