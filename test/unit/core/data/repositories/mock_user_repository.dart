// Mock repository for UserRepository used in testing
import 'dart:async';

import 'package:play_with_me/core/data/models/rating_history_entry.dart';
import 'package:play_with_me/core/data/models/user_model.dart';
import 'package:play_with_me/core/domain/repositories/user_repository.dart';

class MockUserRepository implements UserRepository {
  final StreamController<UserModel?> _currentUserController = StreamController<UserModel?>.broadcast();
  final Map<String, UserModel> _users = {};

  StreamController<UserModel?> get currentUserController => _currentUserController;

  @override
  Stream<UserModel?> get currentUser => _currentUserController.stream;

  // Helper methods for testing
  void setCurrentUser(UserModel? user) {
    print('🧪 MockUserRepository: Setting current user to ${user?.email ?? 'null'}');
    if (!_currentUserController.isClosed) {
      _currentUserController.add(user);
    }
  }

  void setCurrentUserValue(UserModel? user) {
    print('🧪 MockUserRepository: Setting current user value to ${user?.email ?? 'null'}');
    // Emit immediately in the next microtask to ensure listeners are set up
    scheduleMicrotask(() {
      if (!_currentUserController.isClosed) {
        _currentUserController.add(user);
      }
    });
  }

  void setCurrentUserError(String error) {
    print('🧪 MockUserRepository: Setting current user stream error: $error');
    // Emit immediately in the next microtask to ensure listeners are set up
    scheduleMicrotask(() {
      if (!_currentUserController.isClosed) {
        _currentUserController.addError(Exception(error));
      }
    });
  }

  void addUser(UserModel user) {
    _users[user.uid] = user;
  }

  void clearUsers() {
    _users.clear();
  }

  void dispose() {
    _currentUserController.close();
  }

  // Repository methods
  @override
  Future<UserModel?> getUserById(String uid) async {
    return _users[uid];
  }

  @override
  Stream<UserModel?> getUserStream(String uid) {
    return Stream.value(_users[uid]);
  }

  @override
  Future<List<UserModel>> getUsersByIds(List<String> uids) async {
    return uids
        .map((uid) => _users[uid])
        .where((user) => user != null)
        .cast<UserModel>()
        .toList();
  }

  @override
  Future<void> createOrUpdateUser(UserModel user) async {
    _users[user.uid] = user;
  }

  @override
  Future<void> updateUserProfile(String uid, {
    String? displayName,
    String? photoUrl,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? location,
    String? bio,
    DateTime? dateOfBirth,
  }) async {
    final user = _users[uid];
    if (user == null) throw Exception('User not found');

    final updatedUser = user.updateProfile(
      displayName: displayName,
      photoUrl: photoUrl,
      firstName: firstName,
      lastName: lastName,
      phoneNumber: phoneNumber,
      location: location,
      bio: bio,
      dateOfBirth: dateOfBirth,
    );

    _users[uid] = updatedUser;
  }

  @override
  Future<void> updateUserPreferences(String uid, {
    bool? notificationsEnabled,
    bool? emailNotifications,
    bool? pushNotifications,
  }) async {
    final user = _users[uid];
    if (user == null) throw Exception('User not found');

    final updatedUser = user.updatePreferences(
      notificationsEnabled: notificationsEnabled,
      emailNotifications: emailNotifications,
      pushNotifications: pushNotifications,
    );

    _users[uid] = updatedUser;
  }

  @override
  Future<void> updateUserPrivacy(String uid, {
    UserPrivacyLevel? privacyLevel,
    bool? showEmail,
    bool? showPhoneNumber,
  }) async {
    final user = _users[uid];
    if (user == null) throw Exception('User not found');

    final updatedUser = user.updatePrivacy(
      privacyLevel: privacyLevel,
      showEmail: showEmail,
      showPhoneNumber: showPhoneNumber,
    );

    _users[uid] = updatedUser;
  }

  @override
  Future<void> joinGroup(String uid, String groupId) async {
    final user = _users[uid];
    if (user == null) throw Exception('User not found');

    final updatedUser = user.joinGroup(groupId);
    _users[uid] = updatedUser;
  }

  @override
  Future<void> leaveGroup(String uid, String groupId) async {
    final user = _users[uid];
    if (user == null) throw Exception('User not found');

    final updatedUser = user.leaveGroup(groupId);
    _users[uid] = updatedUser;
  }

  @override
  Future<void> addGameParticipation(String uid, String gameId, {
    bool won = false,
    int score = 0,
  }) async {
    final user = _users[uid];
    if (user == null) throw Exception('User not found');

    final updatedUser = user.addGame(gameId, won: won, score: score);
    _users[uid] = updatedUser;
  }

  @override
  Future<List<UserModel>> searchUsers(String query, {int limit = 20}) async {
    final queryLower = query.toLowerCase();
    return _users.values
        .where((user) =>
            user.displayName?.toLowerCase().contains(queryLower) == true ||
            user.email.toLowerCase().contains(queryLower))
        .take(limit)
        .toList();
  }

  @override
  Future<List<UserModel>> getUsersInGroup(String groupId) async {
    return _users.values
        .where((user) => user.groupIds.contains(groupId))
        .toList();
  }

  @override
  Future<void> deleteUser(String uid) async {
    _users.remove(uid);
  }

  @override
  Future<bool> userExists(String uid) async {
    return _users.containsKey(uid);
  }

  @override
  Stream<List<RatingHistoryEntry>> getRatingHistory(
    String userId, {
    int limit = 20,
  }) {
    // Return an empty stream for testing - can be customized per test if needed
    return Stream.value([]);
  }
}

// Test data helpers
class TestUserData {
  static final testUser = UserModel(
    uid: 'test-uid-123',
    email: 'test@example.com',
    displayName: 'Test User',
    photoUrl: null,
    isEmailVerified: true,
    createdAt: DateTime.now(),
    lastSignInAt: DateTime.now(),
    updatedAt: DateTime.now(),
    isAnonymous: false,
    firstName: 'Test',
    lastName: 'User',
    phoneNumber: '+1234567890',
    location: 'Test City',
    bio: 'Test user bio',
    groupIds: ['group1', 'group2'],
    gameIds: ['game1', 'game2'],
    gamesPlayed: 10,
    gamesWon: 7,
    totalScore: 150,
  );

  static final anonymousUser = UserModel(
    uid: 'anon-uid-456',
    email: 'anonymous@temp.com',
    displayName: null,
    photoUrl: null,
    isEmailVerified: false,
    createdAt: DateTime.now(),
    lastSignInAt: DateTime.now(),
    updatedAt: DateTime.now(),
    isAnonymous: true,
  );

  static final anotherUser = UserModel(
    uid: 'user-uid-789',
    email: 'another@example.com',
    displayName: 'Another User',
    photoUrl: null,
    isEmailVerified: true,
    createdAt: DateTime.now(),
    lastSignInAt: DateTime.now(),
    updatedAt: DateTime.now(),
    isAnonymous: false,
    firstName: 'Another',
    lastName: 'User',
    groupIds: ['group1'],
    gameIds: ['game1'],
    gamesPlayed: 5,
    gamesWon: 2,
    totalScore: 75,
  );
}