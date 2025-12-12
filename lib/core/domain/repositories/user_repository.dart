import '../../data/models/rating_history_entry.dart';
import '../../data/models/user_model.dart';

abstract class UserRepository {
  /// Get current authenticated user
  Stream<UserModel?> get currentUser;

  /// Get user by ID
  Future<UserModel?> getUserById(String uid);

  /// Stream user by ID
  Stream<UserModel?> getUserStream(String uid);

  /// Get multiple users by IDs
  Future<List<UserModel>> getUsersByIds(List<String> uids);

  /// Create or update user profile
  Future<void> createOrUpdateUser(UserModel user);

  /// Update user profile
  Future<void> updateUserProfile(String uid, {
    String? displayName,
    String? photoUrl,
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

  /// Get user's ELO rating history (Story 14.5.3)
  /// Returns a stream of rating history entries ordered by timestamp descending
  Stream<List<RatingHistoryEntry>> getRatingHistory(String userId, {int limit});
}