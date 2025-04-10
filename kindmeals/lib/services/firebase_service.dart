import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:developer' as developer;

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'profile',
    ],
  );

  // Authentication methods
  Future<UserCredential> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      developer.log('Attempting to sign in with email: $email');
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      developer.log('Successfully signed in user: ${userCredential.user?.uid}');
      return userCredential;
    } on FirebaseAuthException catch (e) {
      developer.log('Firebase Auth Error: ${e.code} - ${e.message}');
      switch (e.code) {
        case 'user-not-found':
          throw Exception('No user found with this email.');
        case 'wrong-password':
          throw Exception('Wrong password provided.');
        case 'invalid-email':
          throw Exception('The email address is not valid.');
        case 'user-disabled':
          throw Exception('This user has been disabled.');
        case 'too-many-requests':
          throw Exception('Too many attempts. Please try again later.');
        default:
          throw Exception('Login failed: ${e.message}');
      }
    } catch (e) {
      developer.log('Unexpected error during sign in: $e');
      throw Exception('An unexpected error occurred. Please try again.');
    }
  }

  Future<UserCredential> signUpWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      developer.log('Attempting to sign up with email: $email');
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      developer.log('Successfully created user: ${userCredential.user?.uid}');
      return userCredential;
    } catch (e) {
      developer.log('Error during sign up: $e');
      throw Exception('Failed to sign up: $e');
    }
  }

  Future<UserCredential> signInWithGoogle() async {
    try {
      developer.log('Starting Google Sign In flow');
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        developer.log('Google sign in was cancelled by user');
        throw Exception('Google sign in was cancelled');
      }

      developer.log('Google user signed in: ${googleUser.email}');
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      developer.log('Obtained Google auth tokens');

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      developer.log('Signing in to Firebase with Google credential');
      final userCredential = await _auth.signInWithCredential(credential);
      developer.log(
          'Successfully signed in to Firebase with Google: ${userCredential.user?.uid}');
      return userCredential;
    } on FirebaseAuthException catch (e) {
      developer.log(
          'Firebase Auth Error during Google sign in: ${e.code} - ${e.message}');
      switch (e.code) {
        case 'account-exists-with-different-credential':
          throw Exception(
              'An account already exists with the same email but different sign-in credentials.');
        case 'invalid-credential':
          throw Exception('The credential is invalid or has expired.');
        case 'operation-not-allowed':
          throw Exception('Google sign-in is not enabled.');
        case 'user-disabled':
          throw Exception('This user has been disabled.');
        case 'user-not-found':
          throw Exception('No user found with this email.');
        default:
          throw Exception('Google sign in failed: ${e.message}');
      }
    } catch (e) {
      developer.log('Unexpected error during Google sign in: $e');
      throw Exception('An unexpected error occurred during Google sign in.');
    }
  }

  Future<void> signOut() async {
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (e) {
      throw Exception('Failed to sign out: $e');
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'invalid-email':
          throw Exception('The email address is not valid.');
        case 'user-not-found':
          throw Exception('No user found with this email.');
        default:
          throw Exception('Failed to send password reset email: ${e.message}');
      }
    } catch (e) {
      throw Exception(
          'An unexpected error occurred while sending password reset email.');
    }
  }

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();
}
