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
    test('should return list of UserEntity on successful call', () async {
      // Arrange
      final mockResult = MockHttpsCallableResult<Map<String, dynamic>>();
      when(() => mockCallable.call(any())).thenAnswer(
        (_) async => mockResult,
      );
      when(() => mockResult.data).thenReturn({
        'friends': [
          {
            'uid': 'friend-1',
            'email': 'friend1@test.com',
            'displayName': 'Friend One',
            'isEmailVerified': true,
            'isAnonymous': false,
          },
          {
            'uid': 'friend-2',
            'email': 'friend2@test.com',
            'displayName': 'Friend Two',
            'isEmailVerified': true,
            'isAnonymous': false,
          },
        ],
      });

      // Act
      final friends = await repository.getFriends('test-user-id');

      // Assert
      expect(friends, hasLength(2));
      expect(friends[0].uid, 'friend-1');
      expect(friends[0].email, 'friend1@test.com');
      expect(friends[1].uid, 'friend-2');
      verify(() => mockCallable.call({'userId': 'test-user-id'})).called(1);
    });

    test('should return empty list when no friends', () async {
      // Arrange
      final mockResult = MockHttpsCallableResult<Map<String, dynamic>>();
      when(() => mockCallable.call(any())).thenAnswer(
        (_) async => mockResult,
      );
      when(() => mockResult.data).thenReturn({'friends': []});

      // Act
      final friends = await repository.getFriends('test-user-id');

      // Assert
      expect(friends, isEmpty);
    });

    test('should throw FriendshipException on error', () async {
      // Arrange
      when(() => mockCallable.call(any())).thenThrow(
        FirebaseFunctionsException(
          code: 'unauthenticated',
          message: 'Not authenticated',
        ),
      );

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
      // Arrange
      final mockResult = MockHttpsCallableResult<Map<String, dynamic>>();
      when(() => mockCallable.call(any())).thenAnswer(
        (_) async => mockResult,
      );
      when(() => mockResult.data).thenReturn({
        'isFriend': true,
        'hasPendingRequest': false,
        'requestDirection': null,
        'friendshipId': 'friendship-123',
      });

      // Act
      final status = await repository.checkFriendshipStatus('friend-user-id');

      // Assert
      expect(status.isFriend, true);
      expect(status.hasPendingRequest, false);
      expect(status.friendshipId, 'friendship-123');
      verify(() => mockCallable.call({'userId': 'friend-user-id'})).called(1);
    });

    test('should return pending request status', () async {
      // Arrange
      final mockResult = MockHttpsCallableResult<Map<String, dynamic>>();
      when(() => mockCallable.call(any())).thenAnswer(
        (_) async => mockResult,
      );
      when(() => mockResult.data).thenReturn({
        'isFriend': false,
        'hasPendingRequest': true,
        'requestDirection': 'sent',
        'friendshipId': 'friendship-456',
      });

      // Act
      final status = await repository.checkFriendshipStatus('other-user-id');

      // Assert
      expect(status.isFriend, false);
      expect(status.hasPendingRequest, true);
      expect(status.requestDirection, 'sent');
      expect(status.friendshipId, 'friendship-456');
    });

    test('should throw FriendshipException on error', () async {
      // Arrange
      when(() => mockCallable.call(any())).thenThrow(
        FirebaseFunctionsException(
          code: 'not-found',
          message: 'User not found',
        ),
      );

      // Act & Assert
      expect(
        () => repository.checkFriendshipStatus('nonexistent-user'),
        throwsA(isA<FriendshipException>()),
      );
    });
  });
}
