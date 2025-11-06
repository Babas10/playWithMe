import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:play_with_me/core/domain/entities/friendship_entity.dart';
import 'package:play_with_me/core/domain/entities/friendship_status_result.dart';
import 'package:play_with_me/core/domain/repositories/friend_repository.dart';
import 'package:play_with_me/features/auth/domain/entities/user_entity.dart';

/// Firestore implementation of FriendRepository
/// Follows the pattern: BLoC → Repository → Cloud Functions
class FirestoreFriendRepository implements FriendRepository {
  final FirebaseFunctions _functions;
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  FirestoreFriendRepository({
    required FirebaseFunctions functions,
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
  })  : _functions = functions,
        _firestore = firestore,
        _auth = auth;

  @override
  Future<String> sendFriendRequest(String targetUserId) async {
    try {
      final callable = _functions.httpsCallable('sendFriendRequest');
      final result = await callable.call({'targetUserId': targetUserId});
      return result.data['friendshipId'] as String;
    } on FirebaseFunctionsException catch (e) {
      throw _handleError(e);
    } catch (e) {
      throw FriendshipException('Failed to send friend request: $e');
    }
  }

  @override
  Future<void> acceptFriendRequest(String friendshipId) async {
    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) {
        throw FriendshipException('User not authenticated');
      }

      // Update friendship status directly in Firestore
      // Security rules ensure only recipient can accept
      await _firestore.collection('friendships').doc(friendshipId).update({
        'status': 'accepted',
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on FriendshipException {
      rethrow;
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw FriendshipException(
          'You don\'t have permission to accept this friend request',
          code: 'permission-denied',
        );
      } else if (e.code == 'not-found') {
        throw FriendshipException(
          'Friend request not found',
          code: 'not-found',
        );
      }
      throw FriendshipException('Failed to accept friend request: ${e.message}');
    } catch (e) {
      throw FriendshipException('Failed to accept friend request: $e');
    }
  }

  @override
  Future<void> declineFriendRequest(String friendshipId) async {
    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) {
        throw FriendshipException('User not authenticated');
      }

      // Update friendship status directly in Firestore
      // Security rules ensure only recipient can decline
      await _firestore.collection('friendships').doc(friendshipId).update({
        'status': 'declined',
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on FriendshipException {
      rethrow;
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw FriendshipException(
          'You don\'t have permission to decline this friend request',
          code: 'permission-denied',
        );
      } else if (e.code == 'not-found') {
        throw FriendshipException(
          'Friend request not found',
          code: 'not-found',
        );
      }
      throw FriendshipException('Failed to decline friend request: ${e.message}');
    } catch (e) {
      throw FriendshipException('Failed to decline friend request: $e');
    }
  }

  @override
  Future<void> removeFriend(String friendshipId) async {
    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) {
        throw FriendshipException('User not authenticated');
      }

      // Delete friendship document
      // Security rules ensure only initiator or recipient can delete
      await _firestore.collection('friendships').doc(friendshipId).delete();
    } on FriendshipException {
      rethrow;
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw FriendshipException(
          'You don\'t have permission to remove this friend',
          code: 'permission-denied',
        );
      } else if (e.code == 'not-found') {
        throw FriendshipException(
          'Friendship not found',
          code: 'not-found',
        );
      }
      throw FriendshipException('Failed to remove friend: ${e.message}');
    } catch (e) {
      throw FriendshipException('Failed to remove friend: $e');
    }
  }

  @override
  Future<List<UserEntity>> getFriends(String userId) async {
    try {
      final callable = _functions.httpsCallable('getFriends');
      final result = await callable.call({'userId': userId});
      final friendsData = (result.data['friends'] as List);

      // Convert each friend data to UserEntity
      final friends = friendsData.map((json) {
        final data = json as Map<String, dynamic>;
        return UserEntity(
          uid: data['uid'] as String,
          email: data['email'] as String,
          displayName: data['displayName'] as String?,
          photoUrl: data['photoUrl'] as String?,
          isEmailVerified: data['isEmailVerified'] as bool? ?? false,
          createdAt: data['createdAt'] != null
              ? DateTime.parse(data['createdAt'] as String)
              : null,
          lastSignInAt: data['lastSignInAt'] != null
              ? DateTime.parse(data['lastSignInAt'] as String)
              : null,
          isAnonymous: data['isAnonymous'] as bool? ?? false,
        );
      }).toList();

      return friends;
    } on FirebaseFunctionsException catch (e) {
      throw _handleError(e);
    } catch (e) {
      throw FriendshipException('Failed to get friends: $e');
    }
  }

  @override
  Future<List<FriendshipEntity>> getPendingRequests({
    required FriendRequestType type,
  }) async {
    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) {
        throw FriendshipException('User not authenticated');
      }

      // Query friendships where status is pending
      // and current user is either initiator (sent) or recipient (received)
      Query<Map<String, dynamic>> query = _firestore
          .collection('friendships')
          .where('status', isEqualTo: 'pending');

      if (type == FriendRequestType.sent) {
        query = query.where('initiatorId', isEqualTo: currentUserId);
      } else {
        query = query.where('recipientId', isEqualTo: currentUserId);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => FriendshipEntity.fromJson({
                'id': doc.id,
                ...doc.data(),
              }))
          .toList();
    } on FriendshipException {
      rethrow;
    } on FirebaseException catch (e) {
      throw FriendshipException('Failed to get pending requests: ${e.message}');
    } catch (e) {
      throw FriendshipException('Failed to get pending requests: $e');
    }
  }

  @override
  Future<FriendshipStatusResult> checkFriendshipStatus(String userId) async {
    try {
      final callable = _functions.httpsCallable('checkFriendshipStatus');
      final result = await callable.call({'userId': userId});
      return FriendshipStatusResult.fromJson(
        result.data as Map<String, dynamic>,
      );
    } on FirebaseFunctionsException catch (e) {
      throw _handleError(e);
    } catch (e) {
      throw FriendshipException('Failed to check friendship status: $e');
    }
  }

  /// Map FirebaseFunctionsException to user-friendly FriendshipException
  FriendshipException _handleError(FirebaseFunctionsException e) {
    switch (e.code) {
      case 'already-friends':
        return FriendshipException(
          'You are already friends with this user',
          code: e.code,
        );
      case 'request-exists':
        return FriendshipException(
          'A friend request already exists',
          code: e.code,
        );
      case 'cannot-friend-self':
        return FriendshipException(
          'You cannot send a friend request to yourself',
          code: e.code,
        );
      case 'not-found':
        return FriendshipException(
          'User not found',
          code: e.code,
        );
      case 'permission-denied':
        return FriendshipException(
          'You don\'t have permission to perform this action',
          code: e.code,
        );
      case 'unauthenticated':
        return FriendshipException(
          'You must be logged in to perform this action',
          code: e.code,
        );
      default:
        return FriendshipException(
          'An error occurred: ${e.message ?? e.code}',
          code: e.code,
        );
    }
  }
}
