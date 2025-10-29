import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

import '../../domain/repositories/group_repository.dart';
import '../models/group_model.dart';

class FirestoreGroupRepository implements GroupRepository {
  final FirebaseFirestore _firestore;

  static const String _collection = 'groups';

  FirestoreGroupRepository({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<GroupModel?> getGroupById(String groupId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(groupId).get();
      return doc.exists ? GroupModel.fromFirestore(doc) : null;
    } catch (e) {
      throw Exception('Failed to get group: $e');
    }
  }

  @override
  Future<List<GroupModel>> getGroupsByIds(List<String> groupIds) async {
    if (groupIds.isEmpty) return [];

    try {
      final List<GroupModel> groups = [];

      // Firestore 'in' queries are limited to 10 items
      const int batchSize = 10;
      for (int i = 0; i < groupIds.length; i += batchSize) {
        final batch = groupIds.skip(i).take(batchSize).toList();
        final query = await _firestore
            .collection(_collection)
            .where(FieldPath.documentId, whereIn: batch)
            .get();

        for (final doc in query.docs) {
          if (doc.exists) {
            groups.add(GroupModel.fromFirestore(doc));
          }
        }
      }

      return groups;
    } catch (e) {
      throw Exception('Failed to get groups: $e');
    }
  }

  @override
  Stream<List<GroupModel>> getGroupsForUser(String userId) {
    try {
      return _firestore
          .collection(_collection)
          .where('memberIds', arrayContains: userId)
          .orderBy('lastActivity', descending: true)
          .snapshots()
          .map((snapshot) {
            final groups = snapshot.docs
                .where((doc) => doc.exists)
                .map((doc) => GroupModel.fromFirestore(doc))
                .toList();
            return groups;
          });
    } catch (e) {
      throw Exception('Failed to get groups for user: $e');
    }
  }

  @override
  Future<String> createGroup(GroupModel group) async {
    try {
      final data = group.toFirestore();

      final docRef = await _firestore
          .collection(_collection)
          .add(data);
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create group: $e');
    }
  }

  @override
  Future<void> updateGroupInfo(String groupId, {
    String? name,
    String? description,
    String? photoUrl,
    String? location,
  }) async {
    try {
      final currentGroup = await getGroupById(groupId);
      if (currentGroup == null) {
        throw Exception('Group not found');
      }

      final updatedGroup = currentGroup.updateInfo(
        name: name,
        description: description,
        photoUrl: photoUrl,
        location: location,
      );

      await _firestore
          .collection(_collection)
          .doc(groupId)
          .set(updatedGroup.toFirestore(), SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to update group info: $e');
    }
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
    try {
      final currentGroup = await getGroupById(groupId);
      if (currentGroup == null) {
        throw Exception('Group not found');
      }

      final updatedGroup = currentGroup.updateSettings(
        privacy: privacy,
        requiresApproval: requiresApproval,
        maxMembers: maxMembers,
        allowMembersToCreateGames: allowMembersToCreateGames,
        allowMembersToInviteOthers: allowMembersToInviteOthers,
        notifyMembersOfNewGames: notifyMembersOfNewGames,
      );

      await _firestore
          .collection(_collection)
          .doc(groupId)
          .set(updatedGroup.toFirestore(), SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to update group settings: $e');
    }
  }

  @override
  Future<void> addMember(String groupId, String userId) async {
    try {
      final currentGroup = await getGroupById(groupId);
      if (currentGroup == null) {
        throw Exception('Group not found');
      }

      final updatedGroup = currentGroup.addMember(userId);

      await _firestore
          .collection(_collection)
          .doc(groupId)
          .set(updatedGroup.toFirestore(), SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to add member: $e');
    }
  }

  @override
  Future<void> removeMember(String groupId, String userId) async {
    try {
      final currentGroup = await getGroupById(groupId);
      if (currentGroup == null) {
        throw Exception('Group not found');
      }

      final updatedGroup = currentGroup.removeMember(userId);

      await _firestore
          .collection(_collection)
          .doc(groupId)
          .set(updatedGroup.toFirestore(), SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to remove member: $e');
    }
  }

  @override
  Future<void> leaveGroup(String groupId) async {
    try {
      final callable = FirebaseFunctions.instance.httpsCallable('leaveGroup');
      final result = await callable.call<Map<String, dynamic>>({
        'groupId': groupId,
      });

      if (result.data['success'] != true) {
        throw Exception(result.data['message'] ?? 'Failed to leave group');
      }
    } on FirebaseFunctionsException catch (e) {
      throw Exception(e.message ?? 'Failed to leave group');
    } catch (e) {
      throw Exception('Failed to leave group: $e');
    }
  }

  @override
  Future<void> promoteToAdmin(String groupId, String userId) async {
    try {
      final currentGroup = await getGroupById(groupId);
      if (currentGroup == null) {
        throw Exception('Group not found');
      }

      final updatedGroup = currentGroup.promoteToAdmin(userId);

      await _firestore
          .collection(_collection)
          .doc(groupId)
          .set(updatedGroup.toFirestore(), SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to promote to admin: $e');
    }
  }

  @override
  Future<void> demoteFromAdmin(String groupId, String userId) async {
    try {
      final currentGroup = await getGroupById(groupId);
      if (currentGroup == null) {
        throw Exception('Group not found');
      }

      final updatedGroup = currentGroup.demoteFromAdmin(userId);

      await _firestore
          .collection(_collection)
          .doc(groupId)
          .set(updatedGroup.toFirestore(), SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to demote from admin: $e');
    }
  }

  @override
  Future<void> addGame(String groupId, String gameId) async {
    try {
      final currentGroup = await getGroupById(groupId);
      if (currentGroup == null) {
        throw Exception('Group not found');
      }

      final updatedGroup = currentGroup.addGame(gameId);

      await _firestore
          .collection(_collection)
          .doc(groupId)
          .set(updatedGroup.toFirestore(), SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to add game: $e');
    }
  }

  @override
  Future<void> removeGame(String groupId, String gameId) async {
    try {
      final currentGroup = await getGroupById(groupId);
      if (currentGroup == null) {
        throw Exception('Group not found');
      }

      final updatedGroup = currentGroup.removeGame(gameId);

      await _firestore
          .collection(_collection)
          .doc(groupId)
          .set(updatedGroup.toFirestore(), SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to remove game: $e');
    }
  }

  @override
  Future<void> updateActivity(String groupId) async {
    try {
      final currentGroup = await getGroupById(groupId);
      if (currentGroup == null) {
        throw Exception('Group not found');
      }

      final updatedGroup = currentGroup.updateActivity();

      await _firestore
          .collection(_collection)
          .doc(groupId)
          .set(updatedGroup.toFirestore(), SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to update activity: $e');
    }
  }

  @override
  Future<List<GroupModel>> searchPublicGroups(String query, {int limit = 20}) async {
    if (query.trim().isEmpty) return [];

    try {
      final queryLower = query.toLowerCase();

      // Search by name (case-insensitive)
      final nameQuery = await _firestore
          .collection(_collection)
          .where('privacy', isEqualTo: 'public')
          .where('name', isGreaterThanOrEqualTo: queryLower)
          .where('name', isLessThanOrEqualTo: '${queryLower}z')
          .limit(limit)
          .get();

      return nameQuery.docs
          .where((doc) => doc.exists)
          .map((doc) => GroupModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to search public groups: $e');
    }
  }

  @override
  Future<List<String>> getGroupMembers(String groupId) async {
    try {
      final group = await getGroupById(groupId);
      return group?.memberIds ?? [];
    } catch (e) {
      throw Exception('Failed to get group members: $e');
    }
  }

  @override
  Future<List<String>> getGroupAdmins(String groupId) async {
    try {
      final group = await getGroupById(groupId);
      return group?.adminIds ?? [];
    } catch (e) {
      throw Exception('Failed to get group admins: $e');
    }
  }

  @override
  Future<bool> canUserJoinGroup(String groupId, String userId) async {
    try {
      final group = await getGroupById(groupId);
      if (group == null) return false;

      // User is already a member
      if (group.isMember(userId)) return false;

      // Group is at capacity
      if (group.isAtCapacity) return false;

      // Group is private and user is not invited
      if (group.privacy == GroupPrivacy.private) return false;

      return true;
    } catch (e) {
      throw Exception('Failed to check if user can join group: $e');
    }
  }

  @override
  Future<void> deleteGroup(String groupId) async {
    try {
      await _firestore.collection(_collection).doc(groupId).delete();
    } catch (e) {
      throw Exception('Failed to delete group: $e');
    }
  }

  @override
  Future<bool> groupExists(String groupId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(groupId).get();
      return doc.exists;
    } catch (e) {
      throw Exception('Failed to check if group exists: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getGroupStats(String groupId) async {
    try {
      final group = await getGroupById(groupId);
      if (group == null) {
        throw Exception('Group not found');
      }

      return {
        'memberCount': group.memberCount,
        'adminCount': group.adminCount,
        'totalGamesPlayed': group.totalGamesPlayed,
        'isActive': group.isActive,
        'createdAt': group.createdAt.toIso8601String(),
        'lastActivity': group.lastActivity?.toIso8601String(),
      };
    } catch (e) {
      throw Exception('Failed to get group stats: $e');
    }
  }
}