import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/repositories/user_repository.dart';
import '../models/user_model.dart';

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
  Future<List<UserModel>> getUsersByIds(List<String> uids) async {
    if (uids.isEmpty) return [];

    try {
      final List<UserModel> users = [];

      // Firestore 'in' queries are limited to 10 items
      const int batchSize = 10;
      for (int i = 0; i < uids.length; i += batchSize) {
        final batch = uids.skip(i).take(batchSize).toList();
        final query = await _firestore
            .collection(_collection)
            .where(FieldPath.documentId, whereIn: batch)
            .get();

        for (final doc in query.docs) {
          if (doc.exists) {
            users.add(UserModel.fromFirestore(doc));
          }
        }
      }

      return users;
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
}