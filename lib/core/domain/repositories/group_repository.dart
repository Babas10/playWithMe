import '../../data/models/group_model.dart';

abstract class GroupRepository {
  /// Get group by ID
  Future<GroupModel?> getGroupById(String groupId);

  /// Get multiple groups by IDs
  Future<List<GroupModel>> getGroupsByIds(List<String> groupIds);

  /// Get groups for a user
  Stream<List<GroupModel>> getGroupsForUser(String userId);

  /// Create a new group
  Future<String> createGroup(GroupModel group);

  /// Update group information
  Future<void> updateGroupInfo(String groupId, {
    String? name,
    String? description,
    String? photoUrl,
    String? location,
  });

  /// Update group settings
  Future<void> updateGroupSettings(String groupId, {
    GroupPrivacy? privacy,
    bool? requiresApproval,
    int? maxMembers,
    bool? allowMembersToCreateGames,
    bool? allowMembersToInviteOthers,
    bool? notifyMembersOfNewGames,
  });

  /// Add member to group
  Future<void> addMember(String groupId, String userId);

  /// Remove member from group
  Future<void> removeMember(String groupId, String userId);

  /// Promote member to admin
  Future<void> promoteToAdmin(String groupId, String userId);

  /// Demote admin to regular member
  Future<void> demoteFromAdmin(String groupId, String userId);

  /// Add game to group
  Future<void> addGame(String groupId, String gameId);

  /// Remove game from group
  Future<void> removeGame(String groupId, String gameId);

  /// Update group activity timestamp
  Future<void> updateActivity(String groupId);

  /// Search public groups
  Future<List<GroupModel>> searchPublicGroups(String query, {int limit = 20});

  /// Get group members
  Future<List<String>> getGroupMembers(String groupId);

  /// Get group admins
  Future<List<String>> getGroupAdmins(String groupId);

  /// Check if user can join group
  Future<bool> canUserJoinGroup(String groupId, String userId);

  /// Delete group
  Future<void> deleteGroup(String groupId);

  /// Check if group exists
  Future<bool> groupExists(String groupId);

  /// Get group statistics
  Future<Map<String, dynamic>> getGroupStats(String groupId);
}