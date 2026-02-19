import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:play_with_me/features/auth/domain/entities/user_entity.dart';
import 'package:play_with_me/features/auth/domain/repositories/auth_repository.dart';

class MockAuthRepository implements AuthRepository {
  final StreamController<UserEntity?> _authStateController = StreamController<UserEntity?>.broadcast();
  UserEntity? _currentUser;
  Stream<UserEntity?>? _authStateStream;

  // Call tracking for testing
  int _signOutCallCount = 0;

  // Make controller accessible for testing
  StreamController<UserEntity?> get authStateController => _authStateController;

  // Call tracking getters
  int get signOutCallCount => _signOutCallCount;

  // Reset call counters for testing
  void resetCallCounts() {
    _signOutCallCount = 0;
  }

  @override
  UserEntity? get currentUser => _currentUser;

  @override
  Stream<UserEntity?> get authStateChanges {
    // Create a stream that immediately emits the current user when subscribed to
    _authStateStream ??= _authStateController.stream.asBroadcastStream(
      onListen: (subscription) {
        // Immediately emit the current user when someone subscribes
        debugPrint('🧪 MockAuthRepository: New subscriber, emitting current user: ${_currentUser?.email ?? 'null'}');
        Future.microtask(() {
          if (!_authStateController.isClosed) {
            _authStateController.add(_currentUser);
          }
        });
      },
    );
    return _authStateStream!;
  }

  // Helper methods for testing
  void setCurrentUser(UserEntity? user) {
    debugPrint('🧪 MockAuthRepository: Setting current user to ${user?.email ?? 'null'}');
    _currentUser = user;
    // Only add to stream if controller is not closed
    if (!_authStateController.isClosed) {
      _authStateController.add(user);
      debugPrint('🧪 MockAuthRepository: Emitted user state to stream');
    } else {
      debugPrint('🧪 MockAuthRepository: Cannot emit - controller is closed');
    }
  }

  void emitAuthStateChange(UserEntity? user) {
    if (!_authStateController.isClosed) {
      _authStateController.add(user);
    }
  }

  void dispose() {
    _authStateController.close();
    _authStateStream = null;
  }

  // Configurable behaviors for tests with default implementations
  Future<UserEntity> Function({required String email, required String password}) _signInWithEmailAndPasswordBehavior =
    ({required String email, required String password}) async => TestUserData.testUser;

  Future<UserEntity> Function({required String email, required String password}) _createUserWithEmailAndPasswordBehavior =
    ({required String email, required String password}) async => TestUserData.testUser;

  Future<UserEntity> Function() _signInAnonymouslyBehavior =
    () async => TestUserData.anonymousUser;

  Future<void> Function({required String email}) _sendPasswordResetEmailBehavior =
    ({required String email}) async {};

  Future<void> Function() _sendEmailVerificationBehavior =
    () async {};

  Future<void> Function() _reloadUserBehavior =
    () async {};

  Future<void> Function() _signOutBehavior =
    () async {};

  Future<void> Function({String? displayName, String? photoUrl}) _updateUserProfileBehavior =
    ({String? displayName, String? photoUrl}) async {};

  Future<void> Function({required String firstName, required String lastName}) _updateUserNamesBehavior =
    ({required String firstName, required String lastName}) async {};

  // Configure behaviors for testing
  void setSignInWithEmailAndPasswordBehavior(Future<UserEntity> Function({required String email, required String password}) behavior) {
    _signInWithEmailAndPasswordBehavior = behavior;
  }

  void setCreateUserWithEmailAndPasswordBehavior(Future<UserEntity> Function({required String email, required String password}) behavior) {
    _createUserWithEmailAndPasswordBehavior = behavior;
  }

  void setSignInAnonymouslyBehavior(Future<UserEntity> Function() behavior) {
    _signInAnonymouslyBehavior = behavior;
  }

  void setSendPasswordResetEmailBehavior(Future<void> Function({required String email}) behavior) {
    _sendPasswordResetEmailBehavior = behavior;
  }

  void setSendEmailVerificationBehavior(Future<void> Function() behavior) {
    _sendEmailVerificationBehavior = behavior;
  }

  void setReloadUserBehavior(Future<void> Function() behavior) {
    _reloadUserBehavior = behavior;
  }

  void setSignOutBehavior(Future<void> Function() behavior) {
    _signOutBehavior = behavior;
  }

  void setUpdateUserProfileBehavior(Future<void> Function({String? displayName, String? photoUrl}) behavior) {
    _updateUserProfileBehavior = behavior;
  }

  void setUpdateUserNamesBehavior(Future<void> Function({required String firstName, required String lastName}) behavior) {
    _updateUserNamesBehavior = behavior;
  }

  @override
  Future<UserEntity> signInWithEmailAndPassword({required String email, required String password}) {
    return _signInWithEmailAndPasswordBehavior(email: email, password: password);
  }

  @override
  Future<UserEntity> createUserWithEmailAndPassword({required String email, required String password}) {
    return _createUserWithEmailAndPasswordBehavior(email: email, password: password);
  }

  @override
  Future<UserEntity> signInAnonymously() {
    return _signInAnonymouslyBehavior();
  }

  @override
  Future<void> sendPasswordResetEmail({required String email}) {
    return _sendPasswordResetEmailBehavior(email: email);
  }

  @override
  Future<void> sendEmailVerification() {
    return _sendEmailVerificationBehavior();
  }

  @override
  Future<void> reloadUser() {
    return _reloadUserBehavior();
  }

  @override
  Future<void> signOut() {
    _signOutCallCount++;
    return _signOutBehavior();
  }

  @override
  Future<void> updateUserProfile({String? displayName, String? photoUrl}) {
    return _updateUserProfileBehavior(displayName: displayName, photoUrl: photoUrl);
  }

  @override
  Future<void> updateUserNames({required String firstName, required String lastName}) {
    return _updateUserNamesBehavior(firstName: firstName, lastName: lastName);
  }
}

// Test data helpers
class TestUserData {
  static const testUser = UserEntity(
    uid: 'test-uid-123',
    email: 'test@example.com',
    displayName: 'Test User',
    photoUrl: null,
    isEmailVerified: true,
    createdAt: null,
    lastSignInAt: null,
    isAnonymous: false,
  );

  static const anonymousUser = UserEntity(
    uid: 'anon-uid-456',
    email: '',
    displayName: null,
    photoUrl: null,
    isEmailVerified: false,
    createdAt: null,
    lastSignInAt: null,
    isAnonymous: true,
  );

  static const unverifiedUser = UserEntity(
    uid: 'unverified-uid-789',
    email: 'unverified@example.com',
    displayName: 'Unverified User',
    photoUrl: null,
    isEmailVerified: false,
    createdAt: null,
    lastSignInAt: null,
    isAnonymous: false,
  );
}