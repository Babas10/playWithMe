import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/exceptions/repository_exceptions.dart';
import '../../domain/repositories/user_repository.dart';
import '../models/rating_history_entry.dart';
import '../models/user_model.dart';
import '../models/teammate_stats.dart';
import '../models/head_to_head_stats.dart';
import '../models/best_elo_record.dart';
import '../models/user_ranking.dart';
import '../../domain/entities/time_period.dart';

class FirestoreUserRepository implements UserRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final FirebaseFunctions _functions;

  static const String _collection = 'users';

  FirestoreUserRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    FirebaseFunctions? functions,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        _functions = functions ?? FirebaseFunctions.instance;

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
  User? get currentAuthUser => _auth.currentUser;

  @override
  Future<UserModel?> getUserById(String uid) async {
    try {
      final currentUser = _auth.currentUser;

      // If fetching own user data, read directly from Firestore
      // (user has permission to read their own document)
      if (currentUser != null && currentUser.uid == uid) {
        final doc = await _firestore.collection(_collection).doc(uid).get();
        return doc.exists ? UserModel.fromFirestore(doc) : null;
      }

      // If fetching another user's data, use Cloud Function to get public profile
      // (bypasses Firestore security rules)
      final callable = _functions.httpsCallable('getPublicUserProfile');
      final result = await callable.call({'userId': uid});

      final userData = result.data['user'];
      if (userData == null) {
        return null;
      }

      // Convert public profile data to UserModel
      // Only include fields returned by the Cloud Function
      return UserModel(
        uid: userData['uid'] as String,
        email: userData['email'] as String,
        displayName: userData['displayName'] as String?,
        photoUrl: userData['photoUrl'] as String?,
        firstName: userData['firstName'] as String?,
        lastName: userData['lastName'] as String?,
        isEmailVerified: false, // Not returned by public profile
        isAnonymous: false, // Not returned by public profile
      );
    } on FirebaseFunctionsException catch (e) {
      throw UserException('Failed to get user: ${e.code} - ${e.message}');
    } catch (e) {
      throw UserException('Failed to get user: $e');
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
      final callable = _functions.httpsCallable('getUsersByIds');
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
          firstName: userData['firstName'] as String?,
          lastName: userData['lastName'] as String?,
          isEmailVerified: false, // Not returned by Cloud Function
          isAnonymous: false, // Not returned by Cloud Function
        );
      }).toList();
    } on FirebaseFunctionsException catch (e) {
      throw UserException('Failed to get users: ${e.message ?? e.code}');
    } catch (e) {
      throw UserException('Failed to get users: $e');
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
      throw UserException('Failed to create/update user: $e');
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
        throw UserException('User not found', code: 'not-found');
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
      throw UserException('Failed to update user profile: $e');
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
        throw UserException('User not found', code: 'not-found');
      }

      final updatedUser = currentUser.updatePreferences(
        notificationsEnabled: notificationsEnabled,
        emailNotifications: emailNotifications,
        pushNotifications: pushNotifications,
      );

      await createOrUpdateUser(updatedUser);
    } catch (e) {
      throw UserException('Failed to update user preferences: $e');
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
        throw UserException('User not found', code: 'not-found');
      }

      final updatedUser = currentUser.updatePrivacy(
        privacyLevel: privacyLevel,
        showEmail: showEmail,
        showPhoneNumber: showPhoneNumber,
      );

      await createOrUpdateUser(updatedUser);
    } catch (e) {
      throw UserException('Failed to update user privacy: $e');
    }
  }

  @override
  Future<void> joinGroup(String uid, String groupId) async {
    try {
      final currentUser = await getUserById(uid);
      if (currentUser == null) {
        throw UserException('User not found', code: 'not-found');
      }

      final updatedUser = currentUser.joinGroup(groupId);
      await createOrUpdateUser(updatedUser);
    } catch (e) {
      throw UserException('Failed to join group: $e');
    }
  }

  @override
  Future<void> leaveGroup(String uid, String groupId) async {
    try {
      final currentUser = await getUserById(uid);
      if (currentUser == null) {
        throw UserException('User not found', code: 'not-found');
      }

      final updatedUser = currentUser.leaveGroup(groupId);
      await createOrUpdateUser(updatedUser);
    } catch (e) {
      throw UserException('Failed to leave group: $e');
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
        throw UserException('User not found', code: 'not-found');
      }

      final updatedUser = currentUser.addGame(gameId, won: won, score: score);
      await createOrUpdateUser(updatedUser);
    } catch (e) {
      throw UserException('Failed to add game participation: $e');
    }
  }

  @override
  Future<List<UserModel>> searchUsers(String query, {int limit = 20}) async {
    if (query.trim().isEmpty) return [];

    try {
      // Use Cloud Function for secure cross-user search
      // The Cloud Function handles:
      // - Query validation (minimum 3 characters)
      // - Case-insensitive search by email and displayName
      // - Filtering out self, friends, and pending requests
      final callable = _functions.httpsCallable('searchUsers');
      final result = await callable.call({
        'query': query,
      });

      // Convert result.data to Map<String, dynamic> safely
      final data = Map<String, dynamic>.from(result.data as Map);
      final usersData = List<Map<String, dynamic>>.from(
        (data['users'] as List).map((u) => Map<String, dynamic>.from(u as Map)),
      );

      // Apply limit if fewer results than Cloud Function default (20)
      final limitedUsers = usersData.take(limit).toList();

      return limitedUsers.map((userData) {
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
      // Handle specific Cloud Function errors
      switch (e.code) {
        case 'unauthenticated':
          throw UserException(
            'You must be logged in to search for users',
            code: 'unauthenticated',
          );
        case 'invalid-argument':
          // Query too short or invalid - return empty list instead of throwing
          return [];
        case 'permission-denied':
          throw UserException(
            'You don\'t have permission to search for users',
            code: 'permission-denied',
          );
        default:
          throw UserException('Failed to search users: ${e.message}');
      }
    } catch (e) {
      throw UserException('Failed to search users: $e');
    }
  }

  @override
  Future<List<UserModel>> getUsersInGroup(String groupId) async {
    try {
      // Step 1: Get group document to retrieve memberIds
      // This is allowed by Firestore security rules (user can read group they belong to)
      final groupDoc = await _firestore.collection('groups').doc(groupId).get();

      if (!groupDoc.exists) {
        return [];
      }

      final groupData = groupDoc.data();
      if (groupData == null) {
        return [];
      }

      // Extract memberIds from group document
      final memberIds = (groupData['memberIds'] as List?)?.cast<String>() ?? [];

      if (memberIds.isEmpty) {
        return [];
      }

      // Step 2: Use Cloud Function to get user data securely
      // This follows the Cross-User Query Pattern from CLAUDE.md
      final callable = _functions.httpsCallable('getUsersByIds');
      final result = await callable.call({
        'userIds': memberIds,
      });

      // Convert result.data to Map<String, dynamic> safely
      final data = Map<String, dynamic>.from(result.data as Map);
      final usersData = List<Map<String, dynamic>>.from(
        (data['users'] as List).map((u) => Map<String, dynamic>.from(u as Map)),
      );

      return usersData.map((userData) {
        return UserModel(
          uid: userData['uid'] as String,
          email: userData['email'] as String,
          displayName: userData['displayName'] as String?,
          photoUrl: userData['photoUrl'] as String?,
          firstName: userData['firstName'] as String?,
          lastName: userData['lastName'] as String?,
          isEmailVerified: false, // Not returned by Cloud Function
          isAnonymous: false, // Not returned by Cloud Function
        );
      }).toList();
    } on FirebaseFunctionsException catch (e) {
      // Handle specific Cloud Function errors
      switch (e.code) {
        case 'unauthenticated':
          throw UserException(
            'You must be logged in to get users in group',
            code: 'unauthenticated',
          );
        case 'permission-denied':
          throw UserException(
            'You don\'t have permission to view users in this group',
            code: 'permission-denied',
          );
        case 'invalid-argument':
          throw UserException(
            'Invalid group data',
            code: 'invalid-argument',
          );
        default:
          throw UserException('Failed to get users in group: ${e.message}');
      }
    } catch (e) {
      throw UserException('Failed to get users in group: $e');
    }
  }

  @override
  Future<void> deleteUser(String uid) async {
    try {
      await _firestore.collection(_collection).doc(uid).delete();
    } catch (e) {
      throw UserException('Failed to delete user: $e');
    }
  }

  @override
  Future<bool> userExists(String uid) async {
    try {
      final doc = await _firestore.collection(_collection).doc(uid).get();
      return doc.exists;
    } catch (e) {
      throw UserException('Failed to check if user exists: $e');
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
  Stream<List<RatingHistoryEntry>> getRatingHistoryByPeriod(
    String userId,
    TimePeriod period,
  ) {
    final startDate = period.getStartDate();

    return _firestore
        .collection(_collection)
        .doc(userId)
        .collection('ratingHistory')
        .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .where((doc) => doc.exists)
            .map((doc) => RatingHistoryEntry.fromFirestore(doc))
            .toList());
  }

  @override
  Future<BestEloRecord?> getBestEloInPeriod(
    String userId,
    TimePeriod period,
  ) async {
    try {
      final startDate = period.getStartDate();

      final snapshot = await _firestore
          .collection(_collection)
          .doc(userId)
          .collection('ratingHistory')
          .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .orderBy('newRating', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;

      final entry = RatingHistoryEntry.fromFirestore(snapshot.docs.first);
      return BestEloRecord(
        elo: entry.newRating,
        date: entry.timestamp,
        gameId: entry.gameId,
      );
    } catch (e) {
      throw UserException('Failed to get best ELO in period: $e');
    }
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
      throw UserException('Failed to get teammate stats: $e');
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
      // Call Cloud Function to get head-to-head stats
      // Security: Function validates that the caller is requesting their own stats
      final callable = _functions.httpsCallable('getHeadToHeadStats');
      final result = await callable.call({
        'opponentId': opponentId,
      });

      if (result.data == null) return null;

      // Convert Cloud Function result to HeadToHeadStats model
      // Cloud Function returns JSON-serializable data with ISO string timestamps
      final data = Map<String, dynamic>.from(result.data as Map);

      // Convert nested recentMatchups list
      if (data['recentMatchups'] != null) {
        data['recentMatchups'] = (data['recentMatchups'] as List)
            .map((matchup) => Map<String, dynamic>.from(matchup as Map))
            .toList();
      }

      return HeadToHeadStats.fromJson(data);
    } on FirebaseFunctionsException catch (e) {
      // Handle specific Cloud Function errors
      switch (e.code) {
        case 'unauthenticated':
          throw UserException('You must be logged in to view head-to-head statistics', code: 'unauthenticated');
        case 'permission-denied':
          throw UserException('You don\'t have permission to view these statistics', code: 'permission-denied');
        case 'not-found':
          return null;
        default:
          throw UserException('Failed to get head-to-head stats: ${e.message}');
      }
    } catch (e) {
      throw UserException('Failed to get head-to-head stats: $e');
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

  @override
  Future<UserRanking> getUserRanking(String userId) async {
    try {
      final callable = _functions.httpsCallable('calculateUserRanking');
      final result = await callable.call<Map<String, dynamic>>();

      return UserRanking.fromJson(result.data);
    } on FirebaseFunctionsException catch (e) {
      switch (e.code) {
        case 'unauthenticated':
          throw UserException('You must be logged in to view rankings', code: 'unauthenticated');
        case 'not-found':
          throw UserException('User not found', code: 'not-found');
        case 'internal':
          throw UserException('Failed to calculate ranking. Please try again.', code: 'internal');
        default:
          throw UserException('Failed to get ranking: ${e.message}');
      }
    } catch (e) {
      throw UserException('Failed to get ranking: $e');
    }
  }
}