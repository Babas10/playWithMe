import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/repositories/user_repository.dart';
import '../models/rating_history_entry.dart';
import '../models/user_model.dart';
import '../models/teammate_stats.dart';
import '../models/head_to_head_stats.dart';

class FirestoreUserRepository implements UserRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  static const String _collection = 'users';

  FirestoreUserRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  @override
  Stream<UserModel?> get currentUser {
    return _auth.authStateChanges().asyncExpand((user) async* {
      if (user == null) {
        yield null;
      } else {
        yield* _firestore
            .collection(_collection)
            .doc(user.uid)
            .snapshots()
            .map((doc) => doc.exists ? UserModel.fromFirestore(doc) : null);
      }
    });
  }

  @override
  Future<UserModel?> getUserById(String uid) async {
    try {
      final doc = await _firestore.collection(_collection).doc(uid).get();
      return doc.exists ? UserModel.fromFirestore(doc) : null;
    } catch (e) {
      throw Exception('Failed to get user: $e');
    }
  }

  @override
  Stream<UserModel?> getUserStream(String uid) {
    return _firestore
        .collection(_collection)
        .doc(uid)
        .snapshots()
        .map((doc) => doc.exists ? UserModel.fromFirestore(doc) : null);
  }

  @override
  Future<List<UserModel>> getUsersByIds(List<String> uids) async {
    if (uids.isEmpty) return [];

    try {
      // Use Cloud Function for secure cross-user query
      final callable = FirebaseFunctions.instance.httpsCallable('getUsersByIds');
      final result = await callable.call({
        'userIds': uids,
      });

      // Convert result.data to Map<String, dynamic> safely
      final data = Map<String, dynamic>.from(result.data as Map);
      final usersData = List<Map<String, dynamic>>.from(
        (data['users'] as List).map((u) => Map<String, dynamic>.from(u as Map))
      );

      return usersData.map((userData) {
        return UserModel(
          uid: userData['uid'] as String,
          email: userData['email'] as String,
          displayName: userData['displayName'] as String?,
          photoUrl: userData['photoUrl'] as String?,
          isEmailVerified: false, // Not returned by Cloud Function
          isAnonymous: false, // Not returned by Cloud Function
        );
      }).toList();
    } on FirebaseFunctionsException catch (e) {
      throw Exception('Failed to get users: ${e.message ?? e.code}');
    } catch (e) {
      throw Exception('Failed to get users: $e');
    }
  }

  @override
  Future<void> createOrUpdateUser(UserModel user) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(user.uid)
          .set(user.toFirestore(), SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to create/update user: $e');
    }
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
    try {
      final currentUser = await getUserById(uid);
      if (currentUser == null) {
        throw Exception('User not found');
      }

      final updatedUser = currentUser.updateProfile(
        displayName: displayName,
        photoUrl: photoUrl,
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
        location: location,
        bio: bio,
        dateOfBirth: dateOfBirth,
      );

      await createOrUpdateUser(updatedUser);
    } catch (e) {
      throw Exception('Failed to update user profile: $e');
    }
  }

  @override
  Future<void> updateUserPreferences(String uid, {
    bool? notificationsEnabled,
    bool? emailNotifications,
    bool? pushNotifications,
  }) async {
    try {
      final currentUser = await getUserById(uid);
      if (currentUser == null) {
        throw Exception('User not found');
      }

      final updatedUser = currentUser.updatePreferences(
        notificationsEnabled: notificationsEnabled,
        emailNotifications: emailNotifications,
        pushNotifications: pushNotifications,
      );

      await createOrUpdateUser(updatedUser);
    } catch (e) {
      throw Exception('Failed to update user preferences: $e');
    }
  }

  @override
  Future<void> updateUserPrivacy(String uid, {
    UserPrivacyLevel? privacyLevel,
    bool? showEmail,
    bool? showPhoneNumber,
  }) async {
    try {
      final currentUser = await getUserById(uid);
      if (currentUser == null) {
        throw Exception('User not found');
      }

      final updatedUser = currentUser.updatePrivacy(
        privacyLevel: privacyLevel,
        showEmail: showEmail,
        showPhoneNumber: showPhoneNumber,
      );

      await createOrUpdateUser(updatedUser);
    } catch (e) {
      throw Exception('Failed to update user privacy: $e');
    }
  }

  @override
  Future<void> joinGroup(String uid, String groupId) async {
    try {
      final currentUser = await getUserById(uid);
      if (currentUser == null) {
        throw Exception('User not found');
      }

      final updatedUser = currentUser.joinGroup(groupId);
      await createOrUpdateUser(updatedUser);
    } catch (e) {
      throw Exception('Failed to join group: $e');
    }
  }

  @override
  Future<void> leaveGroup(String uid, String groupId) async {
    try {
      final currentUser = await getUserById(uid);
      if (currentUser == null) {
        throw Exception('User not found');
      }

      final updatedUser = currentUser.leaveGroup(groupId);
      await createOrUpdateUser(updatedUser);
    } catch (e) {
      throw Exception('Failed to leave group: $e');
    }
  }

  @override
  Future<void> addGameParticipation(String uid, String gameId, {
    bool won = false,
    int score = 0,
  }) async {
    try {
      final currentUser = await getUserById(uid);
      if (currentUser == null) {
        throw Exception('User not found');
      }

      final updatedUser = currentUser.addGame(gameId, won: won, score: score);
      await createOrUpdateUser(updatedUser);
    } catch (e) {
      throw Exception('Failed to add game participation: $e');
    }
  }

  @override
  Future<List<UserModel>> searchUsers(String query, {int limit = 20}) async {
    if (query.trim().isEmpty) return [];

    try {
      final queryLower = query.toLowerCase();

      // Search by display name (case-insensitive)
      final displayNameQuery = await _firestore
          .collection(_collection)
          .where('displayName', isGreaterThanOrEqualTo: queryLower)
          .where('displayName', isLessThanOrEqualTo: '${queryLower}z')
          .limit(limit)
          .get();

      // Search by email (case-insensitive)
      final emailQuery = await _firestore
          .collection(_collection)
          .where('email', isGreaterThanOrEqualTo: queryLower)
          .where('email', isLessThanOrEqualTo: '${queryLower}z')
          .limit(limit)
          .get();

      final users = <String, UserModel>{};

      // Add users from display name query
      for (final doc in displayNameQuery.docs) {
        if (doc.exists) {
          final user = UserModel.fromFirestore(doc);
          users[user.uid] = user;
        }
      }

      // Add users from email query (avoiding duplicates)
      for (final doc in emailQuery.docs) {
        if (doc.exists && !users.containsKey(doc.id)) {
          final user = UserModel.fromFirestore(doc);
          users[user.uid] = user;
        }
      }

      return users.values.toList();
    } catch (e) {
      throw Exception('Failed to search users: $e');
    }
  }

  @override
  Future<List<UserModel>> getUsersInGroup(String groupId) async {
    try {
      final query = await _firestore
          .collection(_collection)
          .where('groupIds', arrayContains: groupId)
          .get();

      return query.docs
          .where((doc) => doc.exists)
          .map((doc) => UserModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get users in group: $e');
    }
  }

  @override
  Future<void> deleteUser(String uid) async {
    try {
      await _firestore.collection(_collection).doc(uid).delete();
    } catch (e) {
      throw Exception('Failed to delete user: $e');
    }
  }

  @override
  Future<bool> userExists(String uid) async {
    try {
      final doc = await _firestore.collection(_collection).doc(uid).get();
      return doc.exists;
    } catch (e) {
      throw Exception('Failed to check if user exists: $e');
    }
  }

  @override
  Stream<List<RatingHistoryEntry>> getRatingHistory(
    String userId, {
    int limit = 20,
  }) {
    return _firestore
        .collection(_collection)
        .doc(userId)
        .collection('ratingHistory')
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .where((doc) => doc.exists)
            .map((doc) => RatingHistoryEntry.fromFirestore(doc))
            .toList());
  }

  @override
  Future<TeammateStats?> getTeammateStats(
    String userId,
    String teammateId,
  ) async {
    try {
      final userDoc = await _firestore.collection(_collection).doc(userId).get();
      if (!userDoc.exists) return null;

      final userData = userDoc.data();
      if (userData == null) return null;

      final teammateStatsMap =
          userData['teammateStats'] as Map<String, dynamic>?;
      if (teammateStatsMap == null || !teammateStatsMap.containsKey(teammateId)) {
        return null;
      }

      final statsData =
          teammateStatsMap[teammateId] as Map<String, dynamic>;
      return TeammateStats.fromFirestore(teammateId, statsData);
    } catch (e) {
      throw Exception('Failed to get teammate stats: $e');
    }
  }

  @override
  Stream<List<TeammateStats>> getAllTeammateStats(String userId) {
    return _firestore
        .collection(_collection)
        .doc(userId)
        .snapshots()
        .map((doc) {
      if (!doc.exists) return <TeammateStats>[];

      final userData = doc.data();
      if (userData == null) return <TeammateStats>[];

      final teammateStatsMap =
          userData['teammateStats'] as Map<String, dynamic>?;
      if (teammateStatsMap == null || teammateStatsMap.isEmpty) {
        return <TeammateStats>[];
      }

      final statsList = teammateStatsMap.entries
          .map((entry) {
            try {
              return TeammateStats.fromFirestore(
                entry.key,
                entry.value as Map<String, dynamic>,
              );
            } catch (e) {
              // Skip invalid entries
              return null;
            }
          })
          .whereType<TeammateStats>()
          .toList();

      // Sort by games played descending
      statsList.sort((a, b) => b.gamesPlayed.compareTo(a.gamesPlayed));
      return statsList;
    });
  }

  @override
  Future<HeadToHeadStats?> getHeadToHeadStats(
    String userId,
    String opponentId,
  ) async {
    try {
      final h2hDoc = await _firestore
          .collection(_collection)
          .doc(userId)
          .collection('headToHead')
          .doc(opponentId)
          .get();

      if (!h2hDoc.exists) return null;

      return HeadToHeadStats.fromFirestore(h2hDoc);
    } catch (e) {
      throw Exception('Failed to get head-to-head stats: $e');
    }
  }

  @override
  Stream<List<HeadToHeadStats>> getAllHeadToHeadStats(String userId) {
    return _firestore
        .collection(_collection)
        .doc(userId)
        .collection('headToHead')
        .orderBy('gamesPlayed', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .where((doc) => doc.exists)
            .map((doc) => HeadToHeadStats.fromFirestore(doc))
            .toList());
  }
}