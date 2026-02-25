// Unit tests for FirestoreFriendRepository - validates friendship management operations
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:play_with_me/core/data/repositories/firestore_friend_repository.dart';
import 'package:play_with_me/core/domain/repositories/friend_repository.dart';

// Mocks
class MockFirebaseFunctions extends Mock implements FirebaseFunctions {}

class MockHttpsCallable extends Mock implements HttpsCallable {}

class MockHttpsCallableResult<T> extends Mock
    implements HttpsCallableResult<T> {}

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUser extends Mock implements User {}

class MockCollectionReference extends Mock
    implements CollectionReference<Map<String, dynamic>> {}

class MockQuery extends Mock implements Query<Map<String, dynamic>> {}

class MockQuerySnapshot extends Mock
    implements QuerySnapshot<Map<String, dynamic>> {}

class MockDocumentReference extends Mock
    implements DocumentReference<Map<String, dynamic>> {}

class MockQueryDocumentSnapshot extends Mock
    implements QueryDocumentSnapshot<Map<String, dynamic>> {}

// Fakes
class FakeHttpsCallableOptions extends Fake implements HttpsCallableOptions {}

void main() {
  late MockFirebaseFunctions mockFunctions;
  late MockHttpsCallable mockCallable;
  late MockFirebaseFirestore mockFirestore;
  late MockFirebaseAuth mockAuth;
  late MockUser mockUser;
  late FirestoreFriendRepository repository;

  setUpAll(() {
    registerFallbackValue(FakeHttpsCallableOptions());
  });

  setUp(() {
    mockFunctions = MockFirebaseFunctions();
    mockCallable = MockHttpsCallable();
    mockFirestore = MockFirebaseFirestore();
    mockAuth = MockFirebaseAuth();
    mockUser = MockUser();

    // Default auth setup
    when(() => mockAuth.currentUser).thenReturn(mockUser);
    when(() => mockUser.uid).thenReturn('test-user-id');

    // Default httpsCallable setup for all Cloud Function calls
    when(() => mockFunctions.httpsCallable('sendFriendRequest'))
        .thenReturn(mockCallable);
    when(() => mockFunctions.httpsCallable('getFriends'))
        .thenReturn(mockCallable);
    when(() => mockFunctions.httpsCallable('checkFriendshipStatus'))
        .thenReturn(mockCallable);

    repository = FirestoreFriendRepository(
      functions: mockFunctions,
      firestore: mockFirestore,
      auth: mockAuth,
    );
  });

  group('sendFriendRequest', () {
    test('should return friendshipId on successful friend request', () async {
      // Arrange
      final mockResult = MockHttpsCallableResult<Map<String, dynamic>>();
      when(() => mockFunctions.httpsCallable('sendFriendRequest'))
          .thenReturn(mockCallable);
      when(() => mockCallable.call(any())).thenAnswer(
        (_) async => mockResult,
      );
      when(() => mockResult.data).thenReturn({
        'friendshipId': 'friendship-123',
      });

      // Act
      final friendshipId = await repository.sendFriendRequest('target-user-id');

      // Assert
      expect(friendshipId, 'friendship-123');
      verify(() => mockCallable.call({'targetUserId': 'target-user-id'}))
          .called(1);
    });

    test('should throw FriendshipException for already-friends error', () async {
      // Arrange
      when(() => mockFunctions.httpsCallable('sendFriendRequest'))
          .thenReturn(mockCallable);
      when(() => mockCallable.call(any())).thenThrow(
        FirebaseFunctionsException(
          code: 'already-friends',
          message: 'Already friends',
        ),
      );

      // Act & Assert
      expect(
        () => repository.sendFriendRequest('target-user-id'),
        throwsA(
          isA<FriendshipException>().having(
            (e) => e.message,
            'message',
            'You are already friends with this user',
          ),
        ),
      );
    });

    test('should throw FriendshipException for request-exists error', () async {
      // Arrange
      when(() => mockFunctions.httpsCallable('sendFriendRequest'))
          .thenReturn(mockCallable);
      when(() => mockCallable.call(any())).thenThrow(
        FirebaseFunctionsException(
          code: 'request-exists',
          message: 'Request exists',
        ),
      );

      // Act & Assert
      expect(
        () => repository.sendFriendRequest('target-user-id'),
        throwsA(
          isA<FriendshipException>().having(
            (e) => e.message,
            'message',
            'A friend request already exists',
          ),
        ),
      );
    });

    test('should throw FriendshipException for cannot-friend-self error',
        () async {
      // Arrange
      when(() => mockFunctions.httpsCallable('sendFriendRequest'))
          .thenReturn(mockCallable);
      when(() => mockCallable.call(any())).thenThrow(
        FirebaseFunctionsException(
          code: 'cannot-friend-self',
          message: 'Cannot friend self',
        ),
      );

      // Act & Assert
      expect(
        () => repository.sendFriendRequest('same-user-id'),
        throwsA(
          isA<FriendshipException>().having(
            (e) => e.message,
            'message',
            'You cannot send a friend request to yourself',
          ),
        ),
      );
    });

    test('should throw FriendshipException for not-found error', () async {
      // Arrange
      when(() => mockFunctions.httpsCallable('sendFriendRequest'))
          .thenReturn(mockCallable);
      when(() => mockCallable.call(any())).thenThrow(
        FirebaseFunctionsException(
          code: 'not-found',
          message: 'User not found',
        ),
      );

      // Act & Assert
      expect(
        () => repository.sendFriendRequest('nonexistent-user'),
        throwsA(
          isA<FriendshipException>().having(
            (e) => e.message,
            'message',
            'User not found',
          ),
        ),
      );
    });

    test('should throw FriendshipException for generic error', () async {
      // Arrange
      when(() => mockFunctions.httpsCallable('sendFriendRequest'))
          .thenReturn(mockCallable);
      when(() => mockCallable.call(any())).thenThrow(
        Exception('Network error'),
      );

      // Act & Assert
      expect(
        () => repository.sendFriendRequest('target-user-id'),
        throwsA(isA<FriendshipException>()),
      );
    });
  });

  group('acceptFriendRequest', () {
    test('should update friendship status to accepted', () async {
      // Arrange
      final mockCollection = MockCollectionReference();
      final mockDoc = MockDocumentReference();

      when(() => mockFirestore.collection('friendships'))
          .thenReturn(mockCollection);
      when(() => mockCollection.doc('friendship-123')).thenReturn(mockDoc);
      when(() => mockDoc.update(any())).thenAnswer((_) async {});

      // Act
      await repository.acceptFriendRequest('friendship-123');

      // Assert
      verify(() => mockDoc.update(any())).called(1);
    });

    test('should throw FriendshipException when user not authenticated',
        () async {
      // Arrange
      when(() => mockAuth.currentUser).thenReturn(null);

      // Act & Assert
      expect(
        () => repository.acceptFriendRequest('friendship-123'),
        throwsA(
          isA<FriendshipException>().having(
            (e) => e.message,
            'message',
            'User not authenticated',
          ),
        ),
      );
    });

    test('should throw FriendshipException for permission-denied', () async {
      // Arrange
      final mockCollection = MockCollectionReference();
      final mockDoc = MockDocumentReference();

      // Ensure user is authenticated for this test
      when(() => mockAuth.currentUser).thenReturn(mockUser);
      when(() => mockUser.uid).thenReturn('test-user-id');

      when(() => mockFirestore.collection('friendships'))
          .thenReturn(mockCollection);
      when(() => mockCollection.doc('friendship-123')).thenReturn(mockDoc);
      when(() => mockDoc.update(any())).thenThrow(
        FirebaseException(
          plugin: 'firestore',
          code: 'permission-denied',
          message: 'Permission denied',
        ),
      );

      // Act & Assert
      expect(
        () => repository.acceptFriendRequest('friendship-123'),
        throwsA(
          isA<FriendshipException>().having(
            (e) => e.message,
            'message',
            contains('don\'t have permission'),
          ),
        ),
      );
    });

    test('should throw FriendshipException for not-found', () async {
      // Arrange
      final mockCollection = MockCollectionReference();
      final mockDoc = MockDocumentReference();

      // Ensure user is authenticated for this test
      when(() => mockAuth.currentUser).thenReturn(mockUser);
      when(() => mockUser.uid).thenReturn('test-user-id');

      when(() => mockFirestore.collection('friendships'))
          .thenReturn(mockCollection);
      when(() => mockCollection.doc('friendship-123')).thenReturn(mockDoc);
      when(() => mockDoc.update(any())).thenThrow(
        FirebaseException(
          plugin: 'firestore',
          code: 'not-found',
          message: 'Document not found',
        ),
      );

      // Act & Assert
      expect(
        () => repository.acceptFriendRequest('friendship-123'),
        throwsA(
          isA<FriendshipException>().having(
            (e) => e.message,
            'message',
            'Friend request not found',
          ),
        ),
      );
    });
  });

  group('declineFriendRequest', () {
    test('should update friendship status to declined', () async {
      // Arrange
      final mockCollection = MockCollectionReference();
      final mockDoc = MockDocumentReference();

      when(() => mockFirestore.collection('friendships'))
          .thenReturn(mockCollection);
      when(() => mockCollection.doc('friendship-123')).thenReturn(mockDoc);
      when(() => mockDoc.update(any())).thenAnswer((_) async {});

      // Act
      await repository.declineFriendRequest('friendship-123');

      // Assert
      verify(() => mockDoc.update(any())).called(1);
    });

    test('should throw FriendshipException when user not authenticated',
        () async {
      // Arrange
      when(() => mockAuth.currentUser).thenReturn(null);

      // Act & Assert
      expect(
        () => repository.declineFriendRequest('friendship-123'),
        throwsA(
          isA<FriendshipException>().having(
            (e) => e.message,
            'message',
            'User not authenticated',
          ),
        ),
      );
    });
  });

  group('removeFriend', () {
    test('should delete friendship document', () async {
      // Arrange
      final mockCollection = MockCollectionReference();
      final mockDoc = MockDocumentReference();

      when(() => mockFirestore.collection('friendships'))
          .thenReturn(mockCollection);
      when(() => mockCollection.doc('friendship-123')).thenReturn(mockDoc);
      when(() => mockDoc.delete()).thenAnswer((_) async {});

      // Act
      await repository.removeFriend('friendship-123');

      // Assert
      verify(() => mockDoc.delete()).called(1);
    });

    test('should throw FriendshipException when user not authenticated',
        () async {
      // Arrange
      when(() => mockAuth.currentUser).thenReturn(null);

      // Act & Assert
      expect(
        () => repository.removeFriend('friendship-123'),
        throwsA(
          isA<FriendshipException>().having(
            (e) => e.message,
            'message',
            'User not authenticated',
          ),
        ),
      );
    });

    test('should throw FriendshipException for permission-denied', () async {
      // Arrange
      final mockCollection = MockCollectionReference();
      final mockDoc = MockDocumentReference();

      // Ensure user is authenticated for this test
      when(() => mockAuth.currentUser).thenReturn(mockUser);
      when(() => mockUser.uid).thenReturn('test-user-id');

      when(() => mockFirestore.collection('friendships'))
          .thenReturn(mockCollection);
      when(() => mockCollection.doc('friendship-123')).thenReturn(mockDoc);
      when(() => mockDoc.delete()).thenThrow(
        FirebaseException(
          plugin: 'firestore',
          code: 'permission-denied',
          message: 'Permission denied',
        ),
      );

      // Act & Assert
      expect(
        () => repository.removeFriend('friendship-123'),
        throwsA(
          isA<FriendshipException>().having(
            (e) => e.message,
            'message',
            contains('don\'t have permission'),
          ),
        ),
      );
    });
  });

  group('getFriends', () {
    test('should return list of UserEntity from Cloud Function', () async {
      // Arrange - Story 11.13: Uses Cloud Function following Epic 11 architecture
      when(() => mockFunctions.httpsCallable('getFriends'))
          .thenReturn(mockCallable);
      when(() => mockCallable.call({'userId': 'test-user-id'}))
          .thenAnswer((_) async {
        final result = MockHttpsCallableResult();
        when(() => result.data).thenReturn({
          'friends': [
            {
              'uid': 'friend-1',
              'email': 'friend1@test.com',
              'displayName': 'Friend One',
              'photoUrl': null,
              'isEmailVerified': true,
              'isAnonymous': false,
              'createdAt': DateTime.now().toIso8601String(),
              'lastSignInAt': DateTime.now().toIso8601String(),
            },
            {
              'uid': 'friend-2',
              'email': 'friend2@test.com',
              'displayName': 'Friend Two',
              'photoUrl': 'https://example.com/photo.jpg',
              'isEmailVerified': false,
              'isAnonymous': false,
              'createdAt': DateTime.now().toIso8601String(),
              'lastSignInAt': null,
            },
          ],
        });
        return result;
      });

      // Act
      final friends = await repository.getFriends('test-user-id');

      // Assert
      expect(friends, hasLength(2));
      expect(friends[0].uid, 'friend-1');
      expect(friends[0].email, 'friend1@test.com');
      expect(friends[0].displayName, 'Friend One');
      expect(friends[0].isEmailVerified, true);
      expect(friends[1].uid, 'friend-2');
      expect(friends[1].email, 'friend2@test.com');
      expect(friends[1].photoUrl, 'https://example.com/photo.jpg');
      verify(() => mockCallable.call({'userId': 'test-user-id'})).called(1);
    });

    test('should return empty list when no friends from Cloud Function', () async {
      // Arrange
      when(() => mockFunctions.httpsCallable('getFriends'))
          .thenReturn(mockCallable);
      when(() => mockCallable.call({'userId': 'test-user-id'}))
          .thenAnswer((_) async {
        final result = MockHttpsCallableResult();
        when(() => result.data).thenReturn({
          'friends': [],
        });
        return result;
      });

      // Act
      final friends = await repository.getFriends('test-user-id');

      // Assert
      expect(friends, isEmpty);
      verify(() => mockCallable.call({'userId': 'test-user-id'})).called(1);
    });

    test('should throw FriendshipException when user not authenticated', () async {
      // Arrange
      when(() => mockAuth.currentUser).thenReturn(null);

      // Act & Assert
      expect(
        () => repository.getFriends('test-user-id'),
        throwsA(
          isA<FriendshipException>().having(
            (e) => e.message,
            'message',
            'User not authenticated',
          ),
        ),
      );
    });

    test('should throw FriendshipException when trying to view another user\'s friends', () async {
      // Arrange - current user is 'user-1' but trying to fetch friends of 'user-2'
      when(() => mockAuth.currentUser).thenReturn(mockUser);
      when(() => mockUser.uid).thenReturn('user-1');

      // Act & Assert
      expect(
        () => repository.getFriends('user-2'),
        throwsA(
          isA<FriendshipException>().having(
            (e) => e.message,
            'message',
            'You can only view your own friends list',
          ),
        ),
      );
    });

    test('should handle Cloud Function errors gracefully', () async {
      // Arrange
      when(() => mockFunctions.httpsCallable('getFriends'))
          .thenReturn(mockCallable);
      when(() => mockCallable.call({'userId': 'test-user-id'}))
          .thenThrow(FirebaseFunctionsException(
        code: 'internal',
        message: 'Failed to retrieve friends list',
      ));

      // Act & Assert
      expect(
        () => repository.getFriends('test-user-id'),
        throwsA(isA<FriendshipException>()),
      );
    });
  });

  group('getPendingRequests', () {
    test('should return list of sent pending requests', () async {
      // Arrange
      final mockCallable = MockHttpsCallable();
      final mockResult = MockHttpsCallableResult();

      when(() => mockFunctions.httpsCallable('getFriendshipRequests'))
          .thenReturn(mockCallable);
      when(() => mockCallable.call()).thenAnswer((_) async => mockResult);
      when(() => mockResult.data).thenReturn({
        'sentRequests': [
          {
            'id': 'friendship-1',
            'initiatorId': 'test-user-id',
            'recipientId': 'recipient-1',
            'initiatorName': 'Test User',
            'recipientName': 'Recipient One',
            'status': 'pending',
            'createdAt': {'_seconds': DateTime.now().millisecondsSinceEpoch ~/ 1000},
            'updatedAt': {'_seconds': DateTime.now().millisecondsSinceEpoch ~/ 1000},
          },
          {
            'id': 'friendship-2',
            'initiatorId': 'test-user-id',
            'recipientId': 'recipient-2',
            'initiatorName': 'Test User',
            'recipientName': 'Recipient Two',
            'status': 'pending',
            'createdAt': {'_seconds': DateTime.now().millisecondsSinceEpoch ~/ 1000},
            'updatedAt': {'_seconds': DateTime.now().millisecondsSinceEpoch ~/ 1000},
          },
        ],
        'receivedRequests': [],
      });

      // Act
      final requests = await repository.getPendingRequests(
        type: FriendRequestType.sent,
      );

      // Assert
      expect(requests, hasLength(2));
      expect(requests[0].id, 'friendship-1');
      expect(requests[0].recipientId, 'recipient-1');
      expect(requests[1].id, 'friendship-2');
    });

    test('should return list of received pending requests', () async {
      // Arrange
      final mockCallable = MockHttpsCallable();
      final mockResult = MockHttpsCallableResult();

      when(() => mockFunctions.httpsCallable('getFriendshipRequests'))
          .thenReturn(mockCallable);
      when(() => mockCallable.call()).thenAnswer((_) async => mockResult);
      when(() => mockResult.data).thenReturn({
        'sentRequests': [],
        'receivedRequests': [],
      });

      // Act
      final requests = await repository.getPendingRequests(
        type: FriendRequestType.received,
      );

      // Assert
      expect(requests, isEmpty);
      verify(() => mockFunctions.httpsCallable('getFriendshipRequests')).called(1);
    });

    test('should throw FriendshipException when user not authenticated',
        () async {
      // Arrange
      when(() => mockAuth.currentUser).thenReturn(null);

      // Act & Assert
      expect(
        () => repository.getPendingRequests(type: FriendRequestType.sent),
        throwsA(
          isA<FriendshipException>().having(
            (e) => e.message,
            'message',
            'User not authenticated',
          ),
        ),
      );
    });

    test('should throw FriendshipException on Cloud Function error', () async {
      // Arrange
      final mockCallable = MockHttpsCallable();

      when(() => mockFunctions.httpsCallable('getFriendshipRequests'))
          .thenReturn(mockCallable);
      when(() => mockCallable.call()).thenThrow(
        FirebaseFunctionsException(
          code: 'internal',
          message: 'Network error',
        ),
      );

      // Act & Assert
      expect(
        () => repository.getPendingRequests(type: FriendRequestType.sent),
        throwsA(isA<FriendshipException>()),
      );
    });
  });

  group('checkFriendshipStatus', () {
    test('should return FriendshipStatusResult on successful call', () async {
      // Arrange - Story 11.6: Check cached friendIds first
      final mockCollection = MockCollectionReference();
      final mockUserDoc = MockDocumentReference();
      final mockUserSnapshot = MockQueryDocumentSnapshot();

      when(() => mockFirestore.collection('users')).thenReturn(mockCollection);
      when(() => mockCollection.doc('test-user-id')).thenReturn(mockUserDoc);
      when(() => mockUserDoc.get()).thenAnswer((_) async => mockUserSnapshot);
      when(() => mockUserSnapshot.exists).thenReturn(true);
      when(() => mockUserSnapshot.data()).thenReturn({
        'friendIds': ['friend-user-id'], // Friend is in cache
        'friendCount': 1,
      });

      // Act
      final status = await repository.checkFriendshipStatus('friend-user-id');

      // Assert
      expect(status.isFriend, true);
      expect(status.hasPendingRequest, false);
      verify(() => mockUserDoc.get()).called(1);
    });

    test('should return pending request status', () async {
      // Arrange - Story 11.6: Not in cache, check pending requests
      final mockCollection = MockCollectionReference();
      final mockUserDoc = MockDocumentReference();
      final mockUserSnapshot = MockQueryDocumentSnapshot();
      final mockFriendshipsQuery = MockQuery();
      final mockFriendshipsSnapshot = MockQuerySnapshot();
      final mockFriendshipDoc = MockQueryDocumentSnapshot();

      // Mock user doc read (friend not in cache)
      when(() => mockFirestore.collection('users')).thenReturn(mockCollection);
      when(() => mockCollection.doc('test-user-id')).thenReturn(mockUserDoc);
      when(() => mockUserDoc.get()).thenAnswer((_) async => mockUserSnapshot);
      when(() => mockUserSnapshot.exists).thenReturn(true);
      when(() => mockUserSnapshot.data()).thenReturn({
        'friendIds': [], // Not in cache
        'friendCount': 0,
      });

      // Mock pending requests query
      when(() => mockFirestore.collection('friendships'))
          .thenReturn(mockCollection);
      when(() => mockCollection.where('status', isEqualTo: 'pending'))
          .thenReturn(mockFriendshipsQuery);
      when(() => mockFriendshipsQuery.get())
          .thenAnswer((_) async => mockFriendshipsSnapshot);
      when(() => mockFriendshipsSnapshot.docs).thenReturn([mockFriendshipDoc]);

      when(() => mockFriendshipDoc.data()).thenReturn({
        'initiatorId': 'test-user-id',
        'recipientId': 'other-user-id',
        'status': 'pending',
      });

      // Act
      final status = await repository.checkFriendshipStatus('other-user-id');

      // Assert
      expect(status.isFriend, false);
      expect(status.hasPendingRequest, true);
      expect(status.requestDirection, 'sent');
    });

    test('should throw FriendshipException on error', () async {
      // Arrange
      final mockCollection = MockCollectionReference();
      when(() => mockFirestore.collection('users')).thenReturn(mockCollection);
      when(() => mockCollection.doc(any())).thenThrow(
        Exception('Firestore error'),
      );

      // Act & Assert
      expect(
        () => repository.checkFriendshipStatus('nonexistent-user'),
        throwsA(isA<FriendshipException>()),
      );
    });
  });

  group('batchCheckFriendship', () {
    test('should return map of friendship statuses for multiple users', () async {
      // Arrange - Story 11.17: Batch check friendships
      final mockCallable = MockHttpsCallable();
      final mockResult = MockHttpsCallableResult();

      when(() => mockFunctions.httpsCallable('batchCheckFriendship'))
          .thenReturn(mockCallable);
      when(() => mockCallable.call({'userIds': ['user1', 'user2', 'user3']}))
          .thenAnswer((_) async => mockResult);
      when(() => mockResult.data).thenReturn({
        'friendships': {
          'user1': true,
          'user2': false,
          'user3': true,
        },
      });

      // Act
      final result = await repository.batchCheckFriendship(['user1', 'user2', 'user3']);

      // Assert
      expect(result, hasLength(3));
      expect(result['user1'], true);
      expect(result['user2'], false);
      expect(result['user3'], true);
      verify(() => mockCallable.call({'userIds': ['user1', 'user2', 'user3']})).called(1);
    });

    test('should return empty map when userIds list is empty', () async {
      // Arrange
      // Act
      final result = await repository.batchCheckFriendship([]);

      // Assert
      expect(result, isEmpty);
      verifyNever(() => mockFunctions.httpsCallable('batchCheckFriendship'));
    });

    test('should handle single user check', () async {
      // Arrange
      final mockCallable = MockHttpsCallable();
      final mockResult = MockHttpsCallableResult();

      when(() => mockFunctions.httpsCallable('batchCheckFriendship'))
          .thenReturn(mockCallable);
      when(() => mockCallable.call({'userIds': ['user1']}))
          .thenAnswer((_) async => mockResult);
      when(() => mockResult.data).thenReturn({
        'friendships': {
          'user1': true,
        },
      });

      // Act
      final result = await repository.batchCheckFriendship(['user1']);

      // Assert
      expect(result, hasLength(1));
      expect(result['user1'], true);
    });

    test('should handle all users as non-friends', () async {
      // Arrange
      final mockCallable = MockHttpsCallable();
      final mockResult = MockHttpsCallableResult();

      when(() => mockFunctions.httpsCallable('batchCheckFriendship'))
          .thenReturn(mockCallable);
      when(() => mockCallable.call({'userIds': ['user1', 'user2']}))
          .thenAnswer((_) async => mockResult);
      when(() => mockResult.data).thenReturn({
        'friendships': {
          'user1': false,
          'user2': false,
        },
      });

      // Act
      final result = await repository.batchCheckFriendship(['user1', 'user2']);

      // Assert
      expect(result, hasLength(2));
      expect(result['user1'], false);
      expect(result['user2'], false);
    });

    test('should throw FriendshipException when user not authenticated', () async {
      // Arrange
      when(() => mockAuth.currentUser).thenReturn(null);

      // Act & Assert
      expect(
        () => repository.batchCheckFriendship(['user1', 'user2']),
        throwsA(
          isA<FriendshipException>().having(
            (e) => e.message,
            'message',
            'User not authenticated',
          ),
        ),
      );
    });

    test('should throw FriendshipException when checking more than 100 users', () async {
      // Arrange
      final tooManyUsers = List.generate(101, (index) => 'user$index');

      // Act & Assert
      expect(
        () => repository.batchCheckFriendship(tooManyUsers),
        throwsA(
          isA<FriendshipException>().having(
            (e) => e.message,
            'message',
            'Maximum 100 users can be checked at once',
          ),
        ),
      );
    });

    test('should handle exactly 100 users (edge case)', () async {
      // Arrange
      final exactly100Users = List.generate(100, (index) => 'user$index');
      final mockCallable = MockHttpsCallable();
      final mockResult = MockHttpsCallableResult();

      when(() => mockFunctions.httpsCallable('batchCheckFriendship'))
          .thenReturn(mockCallable);
      when(() => mockCallable.call({'userIds': exactly100Users}))
          .thenAnswer((_) async => mockResult);

      // Generate response with all users as non-friends
      final friendships = Map.fromIterable(
        exactly100Users,
        key: (user) => user,
        value: (_) => false,
      );

      when(() => mockResult.data).thenReturn({
        'friendships': friendships,
      });

      // Act
      final result = await repository.batchCheckFriendship(exactly100Users);

      // Assert
      expect(result, hasLength(100));
      verify(() => mockCallable.call({'userIds': exactly100Users})).called(1);
    });

    test('should throw FriendshipException on Cloud Function error', () async {
      // Arrange
      final mockCallable = MockHttpsCallable();

      when(() => mockFunctions.httpsCallable('batchCheckFriendship'))
          .thenReturn(mockCallable);
      when(() => mockCallable.call(any())).thenThrow(
        FirebaseFunctionsException(
          code: 'internal',
          message: 'Failed to check friendships',
        ),
      );

      // Act & Assert
      expect(
        () => repository.batchCheckFriendship(['user1', 'user2']),
        throwsA(isA<FriendshipException>()),
      );
    });

    test('should throw FriendshipException on unauthenticated error from Cloud Function', () async {
      // Arrange
      final mockCallable = MockHttpsCallable();

      when(() => mockFunctions.httpsCallable('batchCheckFriendship'))
          .thenReturn(mockCallable);
      when(() => mockCallable.call(any())).thenThrow(
        FirebaseFunctionsException(
          code: 'unauthenticated',
          message: 'User must be logged in',
        ),
      );

      // Act & Assert
      expect(
        () => repository.batchCheckFriendship(['user1', 'user2']),
        throwsA(
          isA<FriendshipException>().having(
            (e) => e.message,
            'message',
            contains('must be logged in'),
          ),
        ),
      );
    });

    test('should throw FriendshipException on not-found error from Cloud Function', () async {
      // Arrange
      final mockCallable = MockHttpsCallable();

      when(() => mockFunctions.httpsCallable('batchCheckFriendship'))
          .thenReturn(mockCallable);
      when(() => mockCallable.call(any())).thenThrow(
        FirebaseFunctionsException(
          code: 'not-found',
          message: 'User not found',
        ),
      );

      // Act & Assert
      expect(
        () => repository.batchCheckFriendship(['user1', 'user2']),
        throwsA(
          isA<FriendshipException>().having(
            (e) => e.message,
            'message',
            'User not found',
          ),
        ),
      );
    });

    test('should throw FriendshipException on generic error', () async {
      // Arrange
      final mockCallable = MockHttpsCallable();

      when(() => mockFunctions.httpsCallable('batchCheckFriendship'))
          .thenReturn(mockCallable);
      when(() => mockCallable.call(any())).thenThrow(
        Exception('Network error'),
      );

      // Act & Assert
      expect(
        () => repository.batchCheckFriendship(['user1', 'user2']),
        throwsA(
          isA<FriendshipException>().having(
            (e) => e.message,
            'message',
            contains('Failed to check friendships'),
          ),
        ),
      );
    });
  });

  group('getFriendRequestStatus', () {
    setUp(() {
      when(() => mockAuth.currentUser).thenReturn(mockUser);
      when(() => mockUser.uid).thenReturn('test-user-id');
    });

    test('should return sentByMe when current user sent request', () async {
      // Arrange
      final mockCollection = MockCollectionReference();
      final mockQuery = MockQuery();
      final mockQuerySnapshot = MockQuerySnapshot();
      final mockDoc = MockQueryDocumentSnapshot();

      when(() => mockFirestore.collection('friendships'))
          .thenReturn(mockCollection);
      when(() => mockCollection.where('initiatorId', isEqualTo: 'test-user-id'))
          .thenReturn(mockQuery);
      when(() => mockQuery.where('recipientId', isEqualTo: 'target-user-id'))
          .thenReturn(mockQuery);
      when(() => mockQuery.where('status', isEqualTo: 'pending'))
          .thenReturn(mockQuery);
      when(() => mockQuery.limit(1)).thenReturn(mockQuery);
      when(() => mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(() => mockQuerySnapshot.docs).thenReturn([mockDoc]);

      // Act
      final status = await repository.getFriendRequestStatus(
        'test-user-id',
        'target-user-id',
      );

      // Assert
      expect(status, FriendRequestStatus.sentByMe);
    });

    test('should return receivedFromThem when target user sent request',
        () async {
      // Arrange
      final mockCollection = MockCollectionReference();
      final mockQuery1 = MockQuery();
      final mockQuery2 = MockQuery();
      final mockQuerySnapshot1 = MockQuerySnapshot();
      final mockQuerySnapshot2 = MockQuerySnapshot();
      final mockDoc = MockQueryDocumentSnapshot();

      when(() => mockFirestore.collection('friendships'))
          .thenReturn(mockCollection);

      // First query (sent by me) - empty
      when(() => mockCollection.where('initiatorId', isEqualTo: 'test-user-id'))
          .thenReturn(mockQuery1);
      when(() => mockQuery1.where('recipientId', isEqualTo: 'target-user-id'))
          .thenReturn(mockQuery1);
      when(() => mockQuery1.where('status', isEqualTo: 'pending'))
          .thenReturn(mockQuery1);
      when(() => mockQuery1.limit(1)).thenReturn(mockQuery1);
      when(() => mockQuery1.get()).thenAnswer((_) async => mockQuerySnapshot1);
      when(() => mockQuerySnapshot1.docs).thenReturn([]);

      // Second query (received from them) - has doc
      when(() =>
              mockCollection.where('initiatorId', isEqualTo: 'target-user-id'))
          .thenReturn(mockQuery2);
      when(() => mockQuery2.where('recipientId', isEqualTo: 'test-user-id'))
          .thenReturn(mockQuery2);
      when(() => mockQuery2.where('status', isEqualTo: 'pending'))
          .thenReturn(mockQuery2);
      when(() => mockQuery2.limit(1)).thenReturn(mockQuery2);
      when(() => mockQuery2.get()).thenAnswer((_) async => mockQuerySnapshot2);
      when(() => mockQuerySnapshot2.docs).thenReturn([mockDoc]);

      // Act
      final status = await repository.getFriendRequestStatus(
        'test-user-id',
        'target-user-id',
      );

      // Assert
      expect(status, FriendRequestStatus.receivedFromThem);
    });

    test('should return none when no pending request exists', () async {
      // Arrange
      final mockCollection = MockCollectionReference();
      final mockQuery1 = MockQuery();
      final mockQuery2 = MockQuery();
      final mockQuerySnapshot1 = MockQuerySnapshot();
      final mockQuerySnapshot2 = MockQuerySnapshot();

      when(() => mockFirestore.collection('friendships'))
          .thenReturn(mockCollection);

      // First query (sent by me) - empty
      when(() => mockCollection.where('initiatorId', isEqualTo: 'test-user-id'))
          .thenReturn(mockQuery1);
      when(() => mockQuery1.where('recipientId', isEqualTo: 'target-user-id'))
          .thenReturn(mockQuery1);
      when(() => mockQuery1.where('status', isEqualTo: 'pending'))
          .thenReturn(mockQuery1);
      when(() => mockQuery1.limit(1)).thenReturn(mockQuery1);
      when(() => mockQuery1.get()).thenAnswer((_) async => mockQuerySnapshot1);
      when(() => mockQuerySnapshot1.docs).thenReturn([]);

      // Second query (received from them) - empty
      when(() =>
              mockCollection.where('initiatorId', isEqualTo: 'target-user-id'))
          .thenReturn(mockQuery2);
      when(() => mockQuery2.where('recipientId', isEqualTo: 'test-user-id'))
          .thenReturn(mockQuery2);
      when(() => mockQuery2.where('status', isEqualTo: 'pending'))
          .thenReturn(mockQuery2);
      when(() => mockQuery2.limit(1)).thenReturn(mockQuery2);
      when(() => mockQuery2.get()).thenAnswer((_) async => mockQuerySnapshot2);
      when(() => mockQuerySnapshot2.docs).thenReturn([]);

      // Act
      final status = await repository.getFriendRequestStatus(
        'test-user-id',
        'target-user-id',
      );

      // Assert
      expect(status, FriendRequestStatus.none);
    });

    test('should throw FriendshipException when user is not authenticated',
        () async {
      // Arrange
      when(() => mockAuth.currentUser).thenReturn(null);

      // Act & Assert
      expect(
        () => repository.getFriendRequestStatus(
          'test-user-id',
          'target-user-id',
        ),
        throwsA(
          isA<FriendshipException>().having(
            (e) => e.message,
            'message',
            'User not authenticated',
          ),
        ),
      );
    });

    test(
        'should throw FriendshipException when currentUserId does not match authenticated user',
        () async {
      // Arrange
      when(() => mockAuth.currentUser).thenReturn(mockUser);
      when(() => mockUser.uid).thenReturn('test-user-id');

      // Act & Assert
      expect(
        () => repository.getFriendRequestStatus(
          'different-user-id',
          'target-user-id',
        ),
        throwsA(
          isA<FriendshipException>().having(
            (e) => e.message,
            'message',
            'Can only check request status for authenticated user',
          ),
        ),
      );
    });

    test('should throw FriendshipException when checking status with yourself',
        () async {
      // Arrange
      when(() => mockAuth.currentUser).thenReturn(mockUser);
      when(() => mockUser.uid).thenReturn('test-user-id');

      // Act & Assert
      expect(
        () => repository.getFriendRequestStatus(
          'test-user-id',
          'test-user-id',
        ),
        throwsA(
          isA<FriendshipException>().having(
            (e) => e.message,
            'message',
            'Cannot check request status with yourself',
          ),
        ),
      );
    });

    test('should throw FriendshipException on Firestore permission denied error',
        () async {
      // Arrange
      final mockCollection = MockCollectionReference();
      final mockQuery = MockQuery();

      when(() => mockFirestore.collection('friendships'))
          .thenReturn(mockCollection);
      when(() => mockCollection.where('initiatorId', isEqualTo: 'test-user-id'))
          .thenReturn(mockQuery);
      when(() => mockQuery.where('recipientId', isEqualTo: 'target-user-id'))
          .thenReturn(mockQuery);
      when(() => mockQuery.where('status', isEqualTo: 'pending'))
          .thenReturn(mockQuery);
      when(() => mockQuery.limit(1)).thenReturn(mockQuery);
      when(() => mockQuery.get()).thenThrow(
        FirebaseException(
          plugin: 'cloud_firestore',
          code: 'permission-denied',
        ),
      );

      // Act & Assert
      expect(
        () => repository.getFriendRequestStatus(
          'test-user-id',
          'target-user-id',
        ),
        throwsA(
          isA<FriendshipException>().having(
            (e) => e.message,
            'message',
            contains('permission'),
          ),
        ),
      );
    });

    test('should throw FriendshipException on generic error', () async {
      // Arrange
      final mockCollection = MockCollectionReference();
      final mockQuery = MockQuery();

      when(() => mockFirestore.collection('friendships'))
          .thenReturn(mockCollection);
      when(() => mockCollection.where('initiatorId', isEqualTo: 'test-user-id'))
          .thenReturn(mockQuery);
      when(() => mockQuery.where('recipientId', isEqualTo: 'target-user-id'))
          .thenReturn(mockQuery);
      when(() => mockQuery.where('status', isEqualTo: 'pending'))
          .thenReturn(mockQuery);
      when(() => mockQuery.limit(1)).thenReturn(mockQuery);
      when(() => mockQuery.get()).thenThrow(
        Exception('Network error'),
      );

      // Act & Assert
      expect(
        () => repository.getFriendRequestStatus(
          'test-user-id',
          'target-user-id',
        ),
        throwsA(
          isA<FriendshipException>().having(
            (e) => e.message,
            'message',
            contains('Failed to check friend request status'),
          ),
        ),
      );
    });
  });

  group('getPendingFriendRequestCount', () {
    test('should return stream with correct count of pending requests', () async {
      // Arrange
      final mockCollection = MockCollectionReference();
      final mockQuery = MockQuery();
      final mockQuerySnapshot = MockQuerySnapshot();
      final mockDoc1 = MockQueryDocumentSnapshot();
      final mockDoc2 = MockQueryDocumentSnapshot();

      when(() => mockFirestore.collection('friendships'))
          .thenReturn(mockCollection);
      when(() => mockCollection.where('recipientId', isEqualTo: 'test-user-id'))
          .thenReturn(mockQuery);
      when(() => mockQuery.where('status', isEqualTo: 'pending'))
          .thenReturn(mockQuery);
      when(() => mockQuery.snapshots()).thenAnswer(
        (_) => Stream.value(mockQuerySnapshot),
      );
      when(() => mockQuerySnapshot.docs).thenReturn([mockDoc1, mockDoc2]);

      // Act
      final stream = repository.getPendingFriendRequestCount('test-user-id');

      // Assert
      await expectLater(
        stream,
        emits(2),
      );
    });

    test('should return stream with zero when no pending requests', () async {
      // Arrange
      final mockCollection = MockCollectionReference();
      final mockQuery = MockQuery();
      final mockQuerySnapshot = MockQuerySnapshot();

      when(() => mockFirestore.collection('friendships'))
          .thenReturn(mockCollection);
      when(() => mockCollection.where('recipientId', isEqualTo: 'test-user-id'))
          .thenReturn(mockQuery);
      when(() => mockQuery.where('status', isEqualTo: 'pending'))
          .thenReturn(mockQuery);
      when(() => mockQuery.snapshots()).thenAnswer(
        (_) => Stream.value(mockQuerySnapshot),
      );
      when(() => mockQuerySnapshot.docs).thenReturn([]);

      // Act
      final stream = repository.getPendingFriendRequestCount('test-user-id');

      // Assert
      await expectLater(
        stream,
        emits(0),
      );
    });

    test('should emit updated count when friendships collection changes', () async {
      // Arrange
      final mockCollection = MockCollectionReference();
      final mockQuery = MockQuery();
      final mockQuerySnapshot1 = MockQuerySnapshot();
      final mockQuerySnapshot2 = MockQuerySnapshot();
      final mockDoc1 = MockQueryDocumentSnapshot();
      final mockDoc2 = MockQueryDocumentSnapshot();
      final mockDoc3 = MockQueryDocumentSnapshot();

      when(() => mockFirestore.collection('friendships'))
          .thenReturn(mockCollection);
      when(() => mockCollection.where('recipientId', isEqualTo: 'test-user-id'))
          .thenReturn(mockQuery);
      when(() => mockQuery.where('status', isEqualTo: 'pending'))
          .thenReturn(mockQuery);
      when(() => mockQuery.snapshots()).thenAnswer(
        (_) => Stream.fromIterable([mockQuerySnapshot1, mockQuerySnapshot2]),
      );
      when(() => mockQuerySnapshot1.docs).thenReturn([mockDoc1, mockDoc2]);
      when(() => mockQuerySnapshot2.docs).thenReturn([mockDoc1, mockDoc2, mockDoc3]);

      // Act
      final stream = repository.getPendingFriendRequestCount('test-user-id');

      // Assert
      await expectLater(
        stream,
        emitsInOrder([2, 3]),
      );
    });

    test('should handle permission denied error in stream', () async {
      // Arrange
      final mockCollection = MockCollectionReference();
      final mockQuery = MockQuery();

      when(() => mockFirestore.collection('friendships'))
          .thenReturn(mockCollection);
      when(() => mockCollection.where('recipientId', isEqualTo: 'test-user-id'))
          .thenReturn(mockQuery);
      when(() => mockQuery.where('status', isEqualTo: 'pending'))
          .thenReturn(mockQuery);
      when(() => mockQuery.snapshots()).thenAnswer(
        (_) => Stream.error(
          FirebaseException(
            plugin: 'cloud_firestore',
            code: 'permission-denied',
          ),
        ),
      );

      // Act
      final stream = repository.getPendingFriendRequestCount('test-user-id');

      // Assert
      await expectLater(
        stream,
        emitsError(
          isA<FriendshipException>().having(
            (e) => e.message,
            'message',
            contains('permission'),
          ),
        ),
      );
    });

    test('should handle generic error in stream', () async {
      // Arrange
      final mockCollection = MockCollectionReference();
      final mockQuery = MockQuery();

      when(() => mockFirestore.collection('friendships'))
          .thenReturn(mockCollection);
      when(() => mockCollection.where('recipientId', isEqualTo: 'test-user-id'))
          .thenReturn(mockQuery);
      when(() => mockQuery.where('status', isEqualTo: 'pending'))
          .thenReturn(mockQuery);
      when(() => mockQuery.snapshots()).thenAnswer(
        (_) => Stream.error(Exception('Network error')),
      );

      // Act
      final stream = repository.getPendingFriendRequestCount('test-user-id');

      // Assert
      await expectLater(
        stream,
        emitsError(
          isA<FriendshipException>().having(
            (e) => e.message,
            'message',
            contains('Failed to get pending friend request count'),
          ),
        ),
      );
    });
  });

  group('Friendship status caching', () {
    group('batchCheckFriendship cache', () {
      test('returns cached result on second call without hitting Cloud Function', () async {
        final mockCallable = MockHttpsCallable();
        final mockResult = MockHttpsCallableResult();

        when(() => mockFunctions.httpsCallable('batchCheckFriendship'))
            .thenReturn(mockCallable);
        when(() => mockCallable.call(any())).thenAnswer((_) async => mockResult);
        when(() => mockResult.data).thenReturn({
          'friendships': {'user1': true},
        });

        // First call — hits Cloud Function.
        final first = await repository.batchCheckFriendship(['user1']);
        expect(first['user1'], true);

        // Second call — should return from cache.
        final second = await repository.batchCheckFriendship(['user1']);
        expect(second['user1'], true);

        // Cloud Function called only once.
        verify(() => mockFunctions.httpsCallable('batchCheckFriendship')).called(1);
      });

      test('only fetches cache-missing UIDs on partial cache hit', () async {
        final mockCallable = MockHttpsCallable();
        final mockResult1 = MockHttpsCallableResult();
        final mockResult2 = MockHttpsCallableResult();

        when(() => mockFunctions.httpsCallable('batchCheckFriendship'))
            .thenReturn(mockCallable);

        when(() => mockCallable.call({'userIds': ['user1']}))
            .thenAnswer((_) async => mockResult1);
        when(() => mockResult1.data).thenReturn({
          'friendships': {'user1': true},
        });

        await repository.batchCheckFriendship(['user1']);

        when(() => mockCallable.call({'userIds': ['user2']}))
            .thenAnswer((_) async => mockResult2);
        when(() => mockResult2.data).thenReturn({
          'friendships': {'user2': false},
        });

        final result = await repository.batchCheckFriendship(['user1', 'user2']);

        expect(result['user1'], true);
        expect(result['user2'], false);
        // user-1 from cache, user-2 from Cloud Function.
        verify(() => mockCallable.call({'userIds': ['user1']})).called(1);
        verify(() => mockCallable.call({'userIds': ['user2']})).called(1);
      });
    });

    group('batchCheckFriendRequestStatus cache', () {
      test('returns cached result on second call without hitting Cloud Function', () async {
        final mockCallable = MockHttpsCallable();
        final mockResult = MockHttpsCallableResult();

        when(() => mockFunctions.httpsCallable('batchCheckFriendRequestStatus'))
            .thenReturn(mockCallable);
        when(() => mockCallable.call(any())).thenAnswer((_) async => mockResult);
        when(() => mockResult.data).thenReturn({
          'requestStatuses': {'user1': 'sentByMe'},
        });

        final first = await repository.batchCheckFriendRequestStatus(['user1']);
        expect(first['user1'], FriendRequestStatus.sentByMe);

        final second = await repository.batchCheckFriendRequestStatus(['user1']);
        expect(second['user1'], FriendRequestStatus.sentByMe);

        verify(() => mockFunctions.httpsCallable('batchCheckFriendRequestStatus')).called(1);
      });
    });

    group('cache invalidation on mutating operations', () {
      Future<void> _populateCaches() async {
        // Use separate callables so the stubs don't interfere with each other.
        final mockFriendshipCallable = MockHttpsCallable();
        final mockFriendshipResult = MockHttpsCallableResult();

        when(() => mockFunctions.httpsCallable('batchCheckFriendship'))
            .thenReturn(mockFriendshipCallable);
        when(() => mockFriendshipCallable.call(any()))
            .thenAnswer((_) async => mockFriendshipResult);
        when(() => mockFriendshipResult.data).thenReturn({
          'friendships': {'user1': true},
        });

        await repository.batchCheckFriendship(['user1']);

        final mockStatusCallable = MockHttpsCallable();
        final mockStatusResult = MockHttpsCallableResult();

        when(() => mockFunctions.httpsCallable('batchCheckFriendRequestStatus'))
            .thenReturn(mockStatusCallable);
        when(() => mockStatusCallable.call(any()))
            .thenAnswer((_) async => mockStatusResult);
        when(() => mockStatusResult.data).thenReturn({
          'requestStatuses': {'user1': 'none'},
        });

        await repository.batchCheckFriendRequestStatus(['user1']);
      }

      test('acceptFriendRequest clears friendship caches', () async {
        await _populateCaches();

        // Mock the Firestore update for acceptFriendRequest.
        final mockCollRef = MockCollectionReference();
        final mockDocRef = MockDocumentReference();

        when(() => mockFirestore.collection('friendships')).thenReturn(mockCollRef);
        when(() => mockCollRef.doc('friendship-123')).thenReturn(mockDocRef);
        when(() => mockDocRef.update(any())).thenAnswer((_) async {});

        await repository.acceptFriendRequest('friendship-123');

        // After clearing the cache, a fresh Cloud Function call is required.
        final mockCallable2 = MockHttpsCallable();
        final mockResult2 = MockHttpsCallableResult();
        when(() => mockFunctions.httpsCallable('batchCheckFriendship'))
            .thenReturn(mockCallable2);
        when(() => mockCallable2.call(any())).thenAnswer((_) async => mockResult2);
        when(() => mockResult2.data).thenReturn({
          'friendships': {'user1': false},
        });

        await repository.batchCheckFriendship(['user1']);
        verify(() => mockCallable2.call(any())).called(1);
      });

      test('declineFriendRequest clears friendship caches', () async {
        await _populateCaches();

        final mockCollRef = MockCollectionReference();
        final mockDocRef = MockDocumentReference();

        when(() => mockFirestore.collection('friendships')).thenReturn(mockCollRef);
        when(() => mockCollRef.doc('friendship-456')).thenReturn(mockDocRef);
        when(() => mockDocRef.update(any())).thenAnswer((_) async {});

        await repository.declineFriendRequest('friendship-456');

        final mockCallable2 = MockHttpsCallable();
        final mockResult2 = MockHttpsCallableResult();
        when(() => mockFunctions.httpsCallable('batchCheckFriendship'))
            .thenReturn(mockCallable2);
        when(() => mockCallable2.call(any())).thenAnswer((_) async => mockResult2);
        when(() => mockResult2.data).thenReturn({
          'friendships': {'user1': false},
        });

        await repository.batchCheckFriendship(['user1']);
        verify(() => mockCallable2.call(any())).called(1);
      });

      test('removeFriend clears friendship caches', () async {
        await _populateCaches();

        final mockCollRef = MockCollectionReference();
        final mockDocRef = MockDocumentReference();

        when(() => mockFirestore.collection('friendships')).thenReturn(mockCollRef);
        when(() => mockCollRef.doc('friendship-789')).thenReturn(mockDocRef);
        when(() => mockDocRef.delete()).thenAnswer((_) async {});

        await repository.removeFriend('friendship-789');

        final mockCallable2 = MockHttpsCallable();
        final mockResult2 = MockHttpsCallableResult();
        when(() => mockFunctions.httpsCallable('batchCheckFriendship'))
            .thenReturn(mockCallable2);
        when(() => mockCallable2.call(any())).thenAnswer((_) async => mockResult2);
        when(() => mockResult2.data).thenReturn({
          'friendships': {'user1': false},
        });

        await repository.batchCheckFriendship(['user1']);
        verify(() => mockCallable2.call(any())).called(1);
      });
    });
  });
}
