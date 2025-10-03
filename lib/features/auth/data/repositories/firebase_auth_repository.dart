import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:play_with_me/features/auth/data/models/user_model.dart';
import 'package:play_with_me/features/auth/domain/entities/user_entity.dart';
import 'package:play_with_me/features/auth/domain/repositories/auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  final FirebaseAuth _firebaseAuth;

  FirebaseAuthRepository({FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  @override
  UserEntity? get currentUser {
    final user = _firebaseAuth.currentUser;
    if (user == null) return null;
    return UserModel.fromFirebaseUser(user).toEntity();
  }

  @override
  Stream<UserEntity?> get authStateChanges {
    return _firebaseAuth.authStateChanges().map((user) {
      if (user == null) return null;
      return UserModel.fromFirebaseUser(user).toEntity();
    });
  }

  @override
  Future<UserEntity> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw Exception('Sign in failed: User is null');
      }

      debugPrint('✅ Successfully signed in user: ${credential.user!.email}');
      return UserModel.fromFirebaseUser(credential.user!).toEntity();
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ Firebase Auth Error during sign in: ${e.code} - ${e.message}');
      throw _mapFirebaseAuthException(e);
    } catch (e) {
      debugPrint('❌ Unexpected error during sign in: $e');
      throw Exception('Sign in failed: $e');
    }
  }

  @override
  Future<UserEntity> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw Exception('User creation failed: User is null');
      }

      debugPrint('✅ Successfully created user: ${credential.user!.email}');
      return UserModel.fromFirebaseUser(credential.user!).toEntity();
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ Firebase Auth Error during registration: ${e.code} - ${e.message}');
      throw _mapFirebaseAuthException(e);
    } catch (e) {
      debugPrint('❌ Unexpected error during registration: $e');
      throw Exception('User creation failed: $e');
    }
  }

  @override
  Future<UserEntity> signInAnonymously() async {
    try {
      final credential = await _firebaseAuth.signInAnonymously();

      if (credential.user == null) {
        throw Exception('Anonymous sign in failed: User is null');
      }

      debugPrint('✅ Successfully signed in anonymously');
      return UserModel.fromFirebaseUser(credential.user!).toEntity();
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ Firebase Auth Error during anonymous sign in: ${e.code} - ${e.message}');
      throw _mapFirebaseAuthException(e);
    } catch (e) {
      debugPrint('❌ Unexpected error during anonymous sign in: $e');
      throw Exception('Anonymous sign in failed: $e');
    }
  }

  @override
  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      debugPrint('✅ Password reset email sent to: $email');
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ Firebase Auth Error sending password reset: ${e.code} - ${e.message}');
      throw _mapFirebaseAuthException(e);
    } catch (e) {
      debugPrint('❌ Unexpected error sending password reset: $e');
      throw Exception('Failed to send password reset email: $e');
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw Exception('No user is currently signed in');
    }

    try {
      await user.sendEmailVerification();
      debugPrint('✅ Email verification sent to: ${user.email}');
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ Firebase Auth Error sending email verification: ${e.code} - ${e.message}');
      throw _mapFirebaseAuthException(e);
    } catch (e) {
      debugPrint('❌ Unexpected error sending email verification: $e');
      throw Exception('Failed to send email verification: $e');
    }
  }

  @override
  Future<void> reloadUser() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw Exception('No user is currently signed in');
    }

    try {
      await user.reload();
      debugPrint('✅ User data reloaded');
    } catch (e) {
      debugPrint('❌ Error reloading user data: $e');
      throw Exception('Failed to reload user data: $e');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
      debugPrint('✅ Successfully signed out');
    } catch (e) {
      debugPrint('❌ Error during sign out: $e');
      throw Exception('Sign out failed: $e');
    }
  }

  @override
  Future<void> updateUserProfile({
    String? displayName,
    String? photoUrl,
  }) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw Exception('No user is currently signed in');
    }

    try {
      await user.updateDisplayName(displayName);
      if (photoUrl != null) {
        await user.updatePhotoURL(photoUrl);
      }
      await user.reload();
      debugPrint('✅ User profile updated');
    } catch (e) {
      debugPrint('❌ Error updating user profile: $e');
      throw Exception('Failed to update user profile: $e');
    }
  }

  /// Map Firebase Auth exceptions to more user-friendly messages
  Exception _mapFirebaseAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return Exception('No user found with this email address.');
      case 'wrong-password':
        return Exception('Wrong password provided.');
      case 'email-already-in-use':
        return Exception('An account already exists with this email address.');
      case 'weak-password':
        return Exception('The password provided is too weak.');
      case 'invalid-email':
        return Exception('The email address is not valid.');
      case 'user-disabled':
        return Exception('This user account has been disabled.');
      case 'too-many-requests':
        return Exception('Too many requests. Please try again later.');
      case 'operation-not-allowed':
        return Exception('This sign-in method is not allowed.');
      case 'invalid-credential':
        return Exception('The provided credentials are invalid.');
      case 'network-request-failed':
        return Exception('Network error. Please check your connection.');
      default:
        return Exception('Authentication failed: ${e.message}');
    }
  }
}