import 'package:play_with_me/core/domain/entities/friendship_entity.dart';
import 'package:play_with_me/core/domain/entities/friendship_status_result.dart';
import 'package:play_with_me/core/domain/entities/user_search_result.dart';
import 'package:play_with_me/features/auth/domain/entities/user_entity.dart';

/// Repository for managing friend relationships
abstract class FriendRepository {
  /// Send a friend request to a user
  /// Returns the friendshipId of the created friendship
  /// Throws [FriendshipException] on error
  Future<String> sendFriendRequest(String targetUserId);

  /// Accept a friend request
  /// Throws [FriendshipException] on error
  Future<void> acceptFriendRequest(String friendshipId);

  /// Decline a friend request
  /// Throws [FriendshipException] on error
  Future<void> declineFriendRequest(String friendshipId);

  /// Remove a friend (delete friendship)
  /// Throws [FriendshipException] on error
  Future<void> removeFriend(String friendshipId);

  /// Get list of accepted friends (one-time fetch)
  /// Returns list of UserEntity with friend details
  /// Throws [FriendshipException] on error
  Future<List<UserEntity>> getFriends(String userId);

  /// Get pending friend requests (sent or received)
  /// Throws [FriendshipException] on error
  Future<List<FriendshipEntity>> getPendingRequests({
    required FriendRequestType type,
  });

  /// Check friendship status with a specific user
  /// Throws [FriendshipException] on error
  Future<FriendshipStatusResult> checkFriendshipStatus(String userId);

  /// Search for a user by email
  /// Returns UserEntity if found with friendship status information
  /// Throws [FriendshipException] on error
  Future<UserSearchResult> searchUserByEmail(String email);
}

/// Type of friend request to filter by
enum FriendRequestType {
  /// Requests sent by current user
  sent,

  /// Requests received by current user
  received,
}

/// Custom exception for friendship-related errors
class FriendshipException implements Exception {
  final String message;
  final String? code;

  FriendshipException(this.message, {this.code});

  @override
  String toString() => message;
}
