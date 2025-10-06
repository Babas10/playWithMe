import '../../data/models/user_model.dart';

abstract class UserRepository {
  /// Get current authenticated user
  Stream<UserModel?> get currentUser;

  /// Get user by ID
  Future<UserModel?> getUserById(String uid);

  /// Get multiple users by IDs
  Future<List<UserModel>> getUsersByIds(List<String> uids);

  /// Create or update user profile
  Future<void> createOrUpdateUser(UserModel user);

  /// Update user profile
  Future<void> updateUserProfile(String uid, {
    String? displayName,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? location,
    String? bio,
    DateTime? dateOfBirth,
  });

  /// Update user preferences
  Future<void> updateUserPreferences(String uid, {
    bool? notificationsEnabled,
    bool? emailNotifications,
    bool? pushNotifications,
  });

  /// Update user privacy settings
  Future<void> updateUserPrivacy(String uid, {
    UserPrivacyLevel? privacyLevel,
    bool? showEmail,
    bool? showPhoneNumber,
  });

  /// Join a group
  Future<void> joinGroup(String uid, String groupId);

  /// Leave a group
  Future<void> leaveGroup(String uid, String groupId);

  /// Add game participation
  Future<void> addGameParticipation(String uid, String gameId, {
    bool won = false,
    int score = 0,
  });

  /// Search users by display name or email
  Future<List<UserModel>> searchUsers(String query, {int limit = 20});

  /// Get users in a group
  Future<List<UserModel>> getUsersInGroup(String groupId);

  /// Delete user account
  Future<void> deleteUser(String uid);

  /// Check if user exists
  Future<bool> userExists(String uid);
}