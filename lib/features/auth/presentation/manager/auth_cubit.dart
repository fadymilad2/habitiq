import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:habit_iq/core/data/services/hive_service.dart';
import 'package:habit_iq/features/auth/presentation/manager/auth_state.dart';
import 'package:habit_iq/features/sync/data/sync_repository.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:habit_iq/features/habit/data/models/habit_model.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(const AuthInitial());

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    // The web client ID from google-services.json (client_type: 3).
    // Required by google_sign_in v6+ to authenticate with Firebase on Android.
    serverClientId:
        '933760355804-17t21r2l7mqnkehv4jdveojt9lhsj0ef.apps.googleusercontent.com',
  );

  /// Checks once at app startup whether a Firebase session already exists.
  ///
  /// We intentionally use [currentUser] (a one-time snapshot) rather than
  /// [authStateChanges] (a stream) to avoid race conditions where Firebase
  /// delivers stale stream events after explicit sign-out/sign-in sequences
  /// inside methods like [signInAsGuest].
  void checkAuthStatus() {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      emit(AuthAuthenticated(user));
    } else {
      emit(const AuthUnauthenticated());
    }
  }

  /// Logs in a user using Email and Password.
  Future<void> loginWithEmail(String email, String password) async {
    emit(const AuthLoading());
    try {
      final credentials = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (credentials.user != null) {
        if (!credentials.user!.emailVerified) {
          // Send verification again just in case they lost it
          await credentials.user!.sendEmailVerification();
          await _firebaseAuth.signOut();
          emit(
            const AuthError(
              'Please verify your email to log in. A new link has been sent to your inbox.',
            ),
          );
          return;
        }
        await SyncRepository.pullFromCloud(
          credentials.user!.uid,
          Hive.box<HabitModel>('habitsBox'),
          userBox: HiveService.userBox,
        );
        emit(AuthAuthenticated(credentials.user!));
      } else {
        emit(const AuthError('Login failed. Please try again.'));
      }
    } on FirebaseAuthException catch (e) {
      emit(AuthError(_handleAuthException(e)));
    } catch (e) {
      log('Login Error: $e');
      emit(AuthError('An unexpected error occurred: $e'));
    }
  }

  /// Registers a new user using Email and Password.
  Future<void> registerWithEmail(
    String name,
    String email,
    String password,
  ) async {
    emit(const AuthLoading());
    try {
      final credentials = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (credentials.user != null) {
        // Update display name and reload so the User object has it populated.
        await credentials.user!.updateDisplayName(name);
        await credentials.user!.reload();
        final refreshedUser = _firebaseAuth.currentUser!;

        // Prevent immediate access and send verification email
        await refreshedUser.sendEmailVerification();
        await _firebaseAuth.signOut();

        emit(AuthVerificationSent(email));
      } else {
        emit(const AuthError('Registration failed. Please try again.'));
      }
    } on FirebaseAuthException catch (e) {
      emit(AuthError(_handleAuthException(e)));
    } catch (e) {
      log('Register Error: $e');
      emit(AuthError('An unexpected error occurred: $e'));
    }
  }

  /// Sends a password reset email to the given [email].
  /// Throws an exception if the request fails, which the UI should catch.
  Future<void> resetPassword(String email) async {
    emit(const AuthLoading());
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      // Revert to unauthenticated so the login screen reappears normally
      emit(const AuthUnauthenticated());
    } on FirebaseAuthException catch (e) {
      emit(const AuthUnauthenticated());
      throw Exception(_handleAuthException(e));
    } catch (e) {
      emit(const AuthUnauthenticated());
      log('Reset Password Error: $e');
      throw Exception('An unexpected error occurred. Please try again.');
    }
  }

  /// Signs in the user securely using Google.
  Future<void> signInWithGoogle() async {
    emit(const AuthLoading());
    try {
      // Trigger the Google Sign In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      // If the user canceled the sign-in
      if (googleUser == null) {
        emit(const AuthUnauthenticated());
        return;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final UserCredential userCredential = await _firebaseAuth
          .signInWithCredential(credential);

      if (userCredential.user != null) {
        await SyncRepository.pullFromCloud(
          userCredential.user!.uid,
          Hive.box<HabitModel>('habitsBox'),
          userBox: HiveService.userBox,
        );
        emit(AuthAuthenticated(userCredential.user!));
      } else {
        emit(const AuthError('Google Sign-In failed.'));
      }
    } on FirebaseAuthException catch (e) {
      emit(AuthError(_handleAuthException(e)));
    } catch (e) {
      log('Google Sign-In Error: $e');
      emit(AuthError('An unexpected error occurred during Google Sign-In.'));
    }
  }

  /// Logs in securely as an Anonymous Guest.
  /// Signs out first so Firebase creates a brand-new anonymous user.
  Future<void> signInAsGuest() async {
    emit(const AuthLoading());
    try {
      await _firebaseAuth.signOut();
      final userCredential = await _firebaseAuth.signInAnonymously();
      if (userCredential.user != null) {
        emit(AuthAuthenticated(userCredential.user!));
      } else {
        emit(const AuthError('Guest Sign-In failed.'));
      }
    } on FirebaseAuthException catch (e) {
      emit(AuthError(_handleAuthException(e)));
    } catch (e) {
      log('Guest Sign-In Error: $e');
      emit(AuthError('An unexpected error occurred: $e'));
    }
  }

  /// Signs the current user out and clears all local data.
  Future<void> logout() async {
    emit(const AuthLoading());
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null && !user.isAnonymous) {
        try {
          await SyncRepository.pushToCloud(
            user.uid,
            Hive.box<HabitModel>('habitsBox').values.toList(),
            userModel: HiveService.userBox.get('currentUser'),
          );
        } catch (e) {
          log('Logout Sync Error: Failed to push data before logout $e');
        }
      }

      await _googleSignIn.signOut();
      await _firebaseAuth.signOut();
      await HiveService.clearAllUserData();
      emit(const AuthUnauthenticated());
    } catch (e) {
      log('Logout Error: $e');
      emit(AuthError('Failed to log out: $e'));
    }
  }

  /// Parses Firebase Auth errors into user-friendly messages.
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'An account already exists for that email.';
      case 'invalid-email':
        return 'The email address is improperly formatted.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'invalid-credential':
        return 'Invalid credentials. Please check your email and password.';
      default:
        return e.message ?? 'An unknown authentication error occurred.';
    }
  }
}
