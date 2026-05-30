import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

// --- [Providers] ---

/// Provides the FirebaseAuth instance
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

/// Streams the authentication state (logged in / logged out)
final authStateChangesProvider = StreamProvider<User?>((ref) {
  return ref.watch(firebaseAuthProvider).authStateChanges();
});

// --- [Controller] ---

/// Exposes the AuthController to the UI
final authControllerProvider = NotifierProvider<AuthController, AsyncValue<User?>>(() {
  return AuthController();
});

class AuthController extends Notifier<AsyncValue<User?>> {
  @override
  AsyncValue<User?> build() {
    return ref.watch(authStateChangesProvider);
  }

  /// Handles the Google Sign-In flow.
  /// Throws exceptions on failure (e.g., user cancellation, network error, unsupported platform).
  Future<void> signInWithGoogle() async {
    final googleSignIn = GoogleSignIn.instance;
    await googleSignIn.initialize();

    // Trigger the authentication flow. 
    // This will throw if canceled or if running on unsupported platforms like Windows.
    final GoogleSignInAccount googleUser = await googleSignIn.authenticate();
    final GoogleSignInAuthentication googleAuth = googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
    );

    await ref.read(firebaseAuthProvider).signInWithCredential(credential);
  }

  /// Handles the Sign-Out flow.
  Future<void> signOut() async {
    await GoogleSignIn.instance.signOut();
    await ref.read(firebaseAuthProvider).signOut();
  }
}