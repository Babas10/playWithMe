import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:play_with_me/core/domain/entities/friendship_entity.dart';
import 'package:play_with_me/core/domain/entities/friendship_status_result.dart';
import 'package:play_with_me/core/domain/entities/user_search_result.dart';
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

      // Safely cast the result data
      final data = Map<String, dynamic>.from(result.data as Map);
      final friendsData = (data['friends'] as List? ?? []);

      // Convert each friend data to UserEntity
      final friends = friendsData.map((json) {
        final userData = Map<String, dynamic>.from(json as Map);
        return UserEntity(
          uid: userData['uid'] as String,
          email: userData['email'] as String,
          displayName: userData['displayName'] as String?,
          photoUrl: userData['photoUrl'] as String?,
          isEmailVerified: userData['isEmailVerified'] as bool? ?? false,
          createdAt: userData['createdAt'] != null
              ? DateTime.parse(userData['createdAt'] as String)
              : null,
          lastSignInAt: userData['lastSignInAt'] != null
              ? DateTime.parse(userData['lastSignInAt'] as String)
              : null,
          isAnonymous: userData['isAnonymous'] as bool? ?? false,
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

      // Call Cloud Function to get friendship requests
      // This uses Admin SDK on backend to bypass security rules
      final callable = _functions.httpsCallable('getFriendshipRequests');
      final result = await callable.call();

      final data = Map<String, dynamic>.from(result.data as Map);

      // Parse the appropriate list based on request type
      final List<dynamic> requestsData = type == FriendRequestType.received
          ? (data['receivedRequests'] as List? ?? [])
          : (data['sentRequests'] as List? ?? []);

      return requestsData.map((json) {
        final requestData = Map<String, dynamic>.from(json as Map);

        // Convert Firestore Timestamps to DateTime
        // The Cloud Function returns Timestamp objects that need conversion
        DateTime parseTimestamp(dynamic timestamp) {
          if (timestamp == null) return DateTime.now();
          if (timestamp is DateTime) return timestamp;
          // Firestore Timestamp has _seconds and _nanoseconds fields
          if (timestamp is Map) {
            final seconds = timestamp['_seconds'] ?? timestamp['seconds'];
            if (seconds != null) {
              return DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
            }
          }
          return DateTime.now();
        }

        return FriendshipEntity.fromJson({
          'id': requestData['id'],
          'initiatorId': requestData['initiatorId'],
          'initiatorName': requestData['initiatorName'],
          'recipientId': requestData['recipientId'],
          'recipientName': requestData['recipientName'],
          'status': requestData['status'],
          'createdAt': parseTimestamp(requestData['createdAt']).toIso8601String(),
          'updatedAt': parseTimestamp(requestData['updatedAt']).toIso8601String(),
        });
      }).toList();
    } on FirebaseFunctionsException catch (e) {
      throw _handleError(e);
    } on FriendshipException {
      rethrow;
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

  @override
  Future<UserSearchResult> searchUserByEmail(String email) async {
    try {
      final callable = _functions.httpsCallable('searchUserByEmail');
      final result = await callable.call({'email': email});

      // Convert result.data to Map<String, dynamic> safely
      final data = Map<String, dynamic>.from(result.data as Map);

      // Parse user data if present
      UserEntity? user;
      if (data['user'] != null) {
        // Convert nested map safely
        final userDataRaw = data['user'];
        final userData = Map<String, dynamic>.from(userDataRaw as Map);

        user = UserEntity(
          uid: userData['uid'] as String,
          email: userData['email'] as String,
          displayName: userData['displayName'] as String?,
          photoUrl: userData['photoUrl'] as String?,
          isEmailVerified: userData['isEmailVerified'] as bool? ?? false,
          createdAt: userData['createdAt'] != null
              ? DateTime.parse(userData['createdAt'] as String)
              : null,
          lastSignInAt: userData['lastSignInAt'] != null
              ? DateTime.parse(userData['lastSignInAt'] as String)
              : null,
          isAnonymous: userData['isAnonymous'] as bool? ?? false,
        );
      }

      return UserSearchResult(
        user: user,
        isFriend: data['isFriend'] as bool? ?? false,
        hasPendingRequest: data['hasPendingRequest'] as bool? ?? false,
        requestDirection: data['requestDirection'] as String?,
      );
    } on FirebaseFunctionsException catch (e) {
      throw _handleError(e);
    } catch (e) {
      throw FriendshipException('Failed to search user by email: $e');
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
