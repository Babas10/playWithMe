import 'dart:async';

import 'package:mockito/mockito.dart';
import 'package:play_with_me/features/auth/domain/entities/user_entity.dart';
import 'package:play_with_me/features/auth/domain/repositories/auth_repository.dart';

class MockAuthRepository extends Mock implements AuthRepository {
  final StreamController<UserEntity?> _authStateController = StreamController<UserEntity?>.broadcast();
  UserEntity? _currentUser;

  // Make controller accessible for testing
  StreamController<UserEntity?> get authStateController => _authStateController;

  @override
  UserEntity? get currentUser => _currentUser;

  @override
  Stream<UserEntity?> get authStateChanges => _authStateController.stream;

  // Helper methods for testing
  void setCurrentUser(UserEntity? user) {
    _currentUser = user;
    _authStateController.add(user);
  }

  void emitAuthStateChange(UserEntity? user) {
    _authStateController.add(user);
  }

  void dispose() {
    _authStateController.close();
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