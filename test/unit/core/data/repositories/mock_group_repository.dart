// Mock repository for GroupRepository used in testing
import 'dart:async';

import 'package:play_with_me/core/data/models/group_model.dart';
import 'package:play_with_me/core/domain/repositories/group_repository.dart';
import 'package:rxdart/rxdart.dart';

class MockGroupRepository implements GroupRepository {
  // Use BehaviorSubject for synchronous, deterministic emissions
  final BehaviorSubject<List<GroupModel>> _groupsController = BehaviorSubject<List<GroupModel>>.seeded([]);
  final Map<String, GroupModel> _groups = {};
  String _lastCreatedGroupId = '';

  MockGroupRepository();

  BehaviorSubject<List<GroupModel>> get groupsController => _groupsController;

  // Synchronous method to get current groups for a user (for deterministic testing)
  List<GroupModel> getCurrentGroupsForUser(String userId) {
    return _groupsController.value
        .where((group) => group.memberIds.contains(userId))
        .toList();
  }

  // Helper methods for testing
  void addGroup(GroupModel group) {
    _groups[group.id] = group;
    _emitGroupsForUser();
  }

  void clearGroups() {
    _groups.clear();
    _emitGroupsForUser();
  }

  void _emitGroupsForUser() {
    if (!_groupsController.isClosed) {
      _groupsController.add(_groups.values.toList());
    }
  }

  void dispose() {
    _groupsController.close();
  }

  // Repository methods
  @override
  Future<GroupModel?> getGroupById(String groupId) async {
    return _groups[groupId];
  }

  @override
  Stream<GroupModel?> watchGroupById(String groupId) {
    return _groupsController.stream.map((_) => _groups[groupId]);
  }

  @override
  Future<List<GroupModel>> getGroupsByIds(List<String> groupIds) async {
    return groupIds
        .map((id) => _groups[id])
        .where((group) => group != null)
        .cast<GroupModel>()
        .toList();
  }

  @override
  Stream<List<GroupModel>> getGroupsForUser(String userId) async* {
    // Immediately yield the current value from BehaviorSubject
    yield _groupsController.value
        .where((group) => group.memberIds.contains(userId))
        .toList();

    // Then continue listening for future updates
    yield* _groupsController.stream.map(
      (groups) => groups.where((group) => group.memberIds.contains(userId)).toList(),
    );
  }

  @override
  Future<String> createGroup(GroupModel group) async {
    final groupId = 'group-${DateTime.now().millisecondsSinceEpoch}';
    final groupWithId = group.copyWith(id: groupId);
    _groups[groupId] = groupWithId;
    _lastCreatedGroupId = groupId;
    _emitGroupsForUser();
    return groupId;
  }

  String get lastCreatedGroupId => _lastCreatedGroupId;

  @override
  Future<void> updateGroupInfo(String groupId, {
    String? name,
    String? description,
    String? photoUrl,
    String? location,
  }) async {
    final group = _groups[groupId];
    if (group == null) throw Exception('Group not found');

    final updatedGroup = group.updateInfo(
      name: name,
      description: description,
      photoUrl: photoUrl,
      location: location,
    );

    _groups[groupId] = updatedGroup;
    _emitGroupsForUser();
  }

  @override
  Future<void> updateGroupSettings(String groupId, {
    GroupPrivacy? privacy,
    bool? requiresApproval,
    int? maxMembers,
    bool? allowMembersToCreateGames,
    bool? allowMembersToInviteOthers,
    bool? notifyMembersOfNewGames,
  }) async {
    final group = _groups[groupId];
    if (group == null) throw Exception('Group not found');

    final updatedGroup = group.updateSettings(
      privacy: privacy,
      requiresApproval: requiresApproval,
      maxMembers: maxMembers,
      allowMembersToCreateGames: allowMembersToCreateGames,
      allowMembersToInviteOthers: allowMembersToInviteOthers,
      notifyMembersOfNewGames: notifyMembersOfNewGames,
    );

    _groups[groupId] = updatedGroup;
    _emitGroupsForUser();
  }

  @override
  Future<void> addMember(String groupId, String userId) async {
    final group = _groups[groupId];
    if (group == null) throw Exception('Group not found');

    final updatedGroup = group.addMember(userId);
    _groups[groupId] = updatedGroup;
    _emitGroupsForUser();
  }

  @override
  Future<void> removeMember(String groupId, String userId) async {
    final group = _groups[groupId];
    if (group == null) throw Exception('Group not found');

    final updatedGroup = group.removeMember(userId);
    _groups[groupId] = updatedGroup;
    _emitGroupsForUser();
  }

  @override
  Future<void> leaveGroup(String groupId) async {
    // In mock, leaveGroup doesn't need userId since it's implied
    // This is just a stub for testing - real implementation uses Cloud Function
    throw UnimplementedError('leaveGroup should be mocked in tests that use it');
  }

  @override
  Future<void> promoteToAdmin(String groupId, String userId) async {
    final group = _groups[groupId];
    if (group == null) throw Exception('Group not found');

    final updatedGroup = group.promoteToAdmin(userId);
    _groups[groupId] = updatedGroup;
    _emitGroupsForUser();
  }

  @override
  Future<void> demoteFromAdmin(String groupId, String userId) async {
    final group = _groups[groupId];
    if (group == null) throw Exception('Group not found');

    final updatedGroup = group.demoteFromAdmin(userId);
    _groups[groupId] = updatedGroup;
    _emitGroupsForUser();
  }

  @override
  Future<void> addGame(String groupId, String gameId) async {
    final group = _groups[groupId];
    if (group == null) throw Exception('Group not found');

    final updatedGroup = group.addGame(gameId);
    _groups[groupId] = updatedGroup;
    _emitGroupsForUser();
  }

  @override
  Future<void> removeGame(String groupId, String gameId) async {
    final group = _groups[groupId];
    if (group == null) throw Exception('Group not found');

    final updatedGroup = group.removeGame(gameId);
    _groups[groupId] = updatedGroup;
    _emitGroupsForUser();
  }

  @override
  Future<void> updateActivity(String groupId) async {
    final group = _groups[groupId];
    if (group == null) throw Exception('Group not found');

    final updatedGroup = group.updateActivity();
    _groups[groupId] = updatedGroup;
    _emitGroupsForUser();
  }

  @override
  Future<List<GroupModel>> searchPublicGroups(String query, {int limit = 20}) async {
    final queryLower = query.toLowerCase();
    return _groups.values
        .where((group) =>
            group.privacy == GroupPrivacy.public &&
            group.name.toLowerCase().contains(queryLower))
        .take(limit)
        .toList();
  }

  @override
  Future<List<String>> getGroupMembers(String groupId) async {
    final group = _groups[groupId];
    return group?.memberIds ?? [];
  }

  @override
  Future<List<String>> getGroupAdmins(String groupId) async {
    final group = _groups[groupId];
    return group?.adminIds ?? [];
  }

  @override
  Future<bool> canUserJoinGroup(String groupId, String userId) async {
    final group = _groups[groupId];
    if (group == null) return false;

    return !group.isMember(userId) &&
           !group.isAtCapacity &&
           group.privacy != GroupPrivacy.private;
  }

  @override
  Future<void> deleteGroup(String groupId) async {
    _groups.remove(groupId);
    _emitGroupsForUser();
  }

  @override
  Future<bool> groupExists(String groupId) async {
    return _groups.containsKey(groupId);
  }

  @override
  Future<Map<String, dynamic>> getGroupStats(String groupId) async {
    final group = _groups[groupId];
    if (group == null) throw Exception('Group not found');

    return {
      'memberCount': group.memberCount,
      'adminCount': group.adminCount,
      'totalGamesPlayed': group.totalGamesPlayed,
      'isActive': group.isActive,
      'createdAt': group.createdAt.toIso8601String(),
      'lastActivity': group.lastActivity?.toIso8601String(),
    };
  }
}

// Test data helpers
class TestGroupData {
  static final testGroup = GroupModel(
    id: 'test-group-123',
    name: 'Test Beach Volleyball Group',
    description: 'A group for testing volleyball games',
    photoUrl: null,
    createdBy: 'test-uid-123',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    memberIds: ['test-uid-123', 'user-uid-789'],
    adminIds: ['test-uid-123'],
    gameIds: ['game1', 'game2'],
    privacy: GroupPrivacy.public,
    requiresApproval: false,
    maxMembers: 20,
    location: 'Test Beach',
    allowMembersToCreateGames: true,
    allowMembersToInviteOthers: true,
    notifyMembersOfNewGames: true,
    totalGamesPlayed: 5,
    lastActivity: DateTime.now(),
  );

  static final privateGroup = GroupModel(
    id: 'private-group-456',
    name: 'Private Test Group',
    description: 'A private group for testing',
    photoUrl: null,
    createdBy: 'test-uid-123',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    memberIds: ['test-uid-123'],
    adminIds: ['test-uid-123'],
    gameIds: [],
    privacy: GroupPrivacy.private,
    requiresApproval: true,
    maxMembers: 10,
    location: 'Private Beach',
    allowMembersToCreateGames: false,
    allowMembersToInviteOthers: false,
    notifyMembersOfNewGames: true,
    totalGamesPlayed: 0,
    lastActivity: DateTime.now(),
  );

  static final fullGroup = GroupModel(
    id: 'full-group-789',
    name: 'Full Test Group',
    description: 'A group that is at capacity',
    photoUrl: null,
    createdBy: 'test-uid-123',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    memberIds: ['test-uid-123', 'user-uid-789'],
    adminIds: ['test-uid-123'],
    gameIds: [],
    privacy: GroupPrivacy.public,
    requiresApproval: false,
    maxMembers: 2, // Already at capacity
    location: 'Full Beach',
    allowMembersToCreateGames: true,
    allowMembersToInviteOthers: true,
    notifyMembersOfNewGames: true,
    totalGamesPlayed: 0,
    lastActivity: DateTime.now(),
  );
}