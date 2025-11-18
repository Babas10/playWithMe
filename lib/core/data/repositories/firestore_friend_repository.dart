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
      // Story 11.13: Use Cloud Function to fetch friends
      // Following Epic 11's Cloud Function-first architecture
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) {
        throw FriendshipException('User not authenticated');
      }

      // Only the current user can fetch their own friends list
      if (userId != currentUserId) {
        throw FriendshipException(
          'You can only view your own friends list',
          code: 'permission-denied',
        );
      }

      // Call Cloud Function to get friends (uses Admin SDK on backend)
      final callable = _functions.httpsCallable('getFriends');
      final result = await callable.call({'userId': userId});

      final data = Map<String, dynamic>.from(result.data as Map);
      final List<dynamic> friendsData = data['friends'] as List? ?? [];

      // Parse friend profiles from Cloud Function response
      return friendsData.map((json) {
        final friendData = Map<String, dynamic>.from(json as Map);

        return UserEntity(
          uid: friendData['uid'] as String,
          email: friendData['email'] as String,
          displayName: friendData['displayName'] as String?,
          photoUrl: friendData['photoUrl'] as String?,
          isEmailVerified: friendData['isEmailVerified'] as bool? ?? false,
          createdAt: friendData['createdAt'] != null
              ? DateTime.parse(friendData['createdAt'] as String)
              : null,
          lastSignInAt: friendData['lastSignInAt'] != null
              ? DateTime.parse(friendData['lastSignInAt'] as String)
              : null,
          isAnonymous: friendData['isAnonymous'] as bool? ?? false,
        );
      }).toList();
    } on FirebaseFunctionsException catch (e) {
      throw _handleError(e);
    } on FriendshipException {
      rethrow;
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
      // Story 11.6: Use cached friendIds for fast friendship checks
      // This optimizes from 2+ Firestore queries to 1 user doc read
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) {
        throw FriendshipException('User not authenticated');
      }

      // Cannot check friendship with yourself
      if (currentUserId == userId) {
        throw FriendshipException(
          'Cannot check friendship status with yourself',
          code: 'invalid-argument',
        );
      }

      // Read current user's document to check cached friendIds
      final userDoc =
          await _firestore.collection('users').doc(currentUserId).get();

      if (!userDoc.exists) {
        throw FriendshipException(
          'User not found',
          code: 'not-found',
        );
      }

      final userData = userDoc.data()!;
      final friendIds = List<String>.from(userData['friendIds'] ?? []);

      // Check if already friends using cache
      if (friendIds.contains(userId)) {
        return FriendshipStatusResult(
          isFriend: true,
          hasPendingRequest: false,
        );
      }

      // Not in cache, check for pending requests
      // Query friendships collection for pending status
      final pendingQuery = await _firestore
          .collection('friendships')
          .where('status', isEqualTo: 'pending')
          .get();

      for (final doc in pendingQuery.docs) {
        final data = doc.data();
        final initiatorId = data['initiatorId'] as String;
        final recipientId = data['recipientId'] as String;

        // Check if there's a pending request between these users
        if ((initiatorId == currentUserId && recipientId == userId) ||
            (initiatorId == userId && recipientId == currentUserId)) {
          return FriendshipStatusResult(
            isFriend: false,
            hasPendingRequest: true,
            requestDirection:
                initiatorId == currentUserId ? 'sent' : 'received',
          );
        }
      }

      // No friendship or pending request
      return FriendshipStatusResult(
        isFriend: false,
        hasPendingRequest: false,
      );
    } on FriendshipException {
      rethrow;
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw FriendshipException(
          'You don\'t have permission to check friendship status',
          code: 'permission-denied',
        );
      } else if (e.code == 'not-found') {
        throw FriendshipException(
          'User not found',
          code: 'not-found',
        );
      }
      throw FriendshipException(
          'Failed to check friendship status: ${e.message}');
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

  @override
  Future<Map<String, bool>> batchCheckFriendship(List<String> userIds) async {
    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) {
        throw FriendshipException('User not authenticated');
      }

      // Handle empty list early
      if (userIds.isEmpty) {
        return {};
      }

      // Validate input size
      if (userIds.length > 100) {
        throw FriendshipException(
          'Maximum 100 users can be checked at once',
          code: 'invalid-argument',
        );
      }

      // Call Cloud Function (Story 11.17)
      final callable = _functions.httpsCallable('batchCheckFriendship');
      final result = await callable.call({'userIds': userIds});

      final data = Map<String, dynamic>.from(result.data as Map);
      final friendships = Map<String, dynamic>.from(data['friendships'] as Map);

      // Convert to Map<String, bool>
      return friendships.map((key, value) => MapEntry(key, value as bool));
    } on FirebaseFunctionsException catch (e) {
      throw _handleError(e);
    } on FriendshipException {
      rethrow;
    } catch (e) {
      throw FriendshipException('Failed to check friendships: $e');
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
