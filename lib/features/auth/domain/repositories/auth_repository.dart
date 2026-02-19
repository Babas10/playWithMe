import 'package:play_with_me/features/auth/domain/entities/user_entity.dart';

abstract class AuthRepository {
  /// Get current authenticated user
  UserEntity? get currentUser;

  /// Stream of authentication state changes
  Stream<UserEntity?> get authStateChanges;

  /// Sign in with email and password
  Future<UserEntity> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  /// Create user with email and password
  Future<UserEntity> createUserWithEmailAndPassword({
    required String email,
    required String password,
  });

  /// Sign in anonymously
  Future<UserEntity> signInAnonymously();

  /// Send password reset email
  Future<void> sendPasswordResetEmail({required String email});

  /// Send email verification
  Future<void> sendEmailVerification();

  /// Reload user data
  Future<void> reloadUser();

  /// Sign out
  Future<void> signOut();

  /// Update user profile
  Future<void> updateUserProfile({
    String? displayName,
    String? photoUrl,
  });

  /// Update user's first and last name in Firestore via Cloud Function
  Future<void> updateUserNames({
    required String firstName,
    required String lastName,
  });
}