import '../../data/models/rating_history_entry.dart';
import '../../data/models/user_model.dart';
import '../../data/models/teammate_stats.dart';
import '../../data/models/head_to_head_stats.dart';
import '../../data/models/best_elo_record.dart';
import '../entities/time_period.dart';

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

  /// Get ELO history for a specific time period (Story 302.1)
  /// Returns a stream of rating history entries within the specified time period
  Stream<List<RatingHistoryEntry>> getRatingHistoryByPeriod(
    String userId,
    TimePeriod period,
  );

  /// Get best ELO within a time period (Story 302.1)
  /// Returns the highest ELO rating achieved within the specified time period
  Future<BestEloRecord?> getBestEloInPeriod(
    String userId,
    TimePeriod period,
  );

  /// Get teammate statistics for a specific partner (Story 304)
  Future<TeammateStats?> getTeammateStats(String userId, String teammateId);

  /// Get all teammate statistics for a user (Story 304)
  /// Returns a stream of teammate stats ordered by games played descending
  Stream<List<TeammateStats>> getAllTeammateStats(String userId);

  /// Get head-to-head statistics against a specific opponent (Story 304)
  Future<HeadToHeadStats?> getHeadToHeadStats(String userId, String opponentId);

  /// Get all head-to-head statistics for a user (Story 304)
  /// Returns a stream of H2H stats ordered by games played descending
  Stream<List<HeadToHeadStats>> getAllHeadToHeadStats(String userId);
}