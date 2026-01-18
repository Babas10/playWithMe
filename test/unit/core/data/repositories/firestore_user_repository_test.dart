// Verifies that FirestoreUserRepository correctly handles all user data operations.
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:play_with_me/core/data/models/user_model.dart';
import 'package:play_with_me/core/data/repositories/firestore_user_repository.dart';
import 'package:play_with_me/core/domain/exceptions/repository_exceptions.dart';

// Mocktail mocks
class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUser extends Mock implements User {}

class MockFirebaseFunctions extends Mock implements FirebaseFunctions {}

class MockHttpsCallable extends Mock implements HttpsCallable {}

class MockHttpsCallableResult<T> extends Mock implements HttpsCallableResult<T> {}

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late MockFirebaseAuth mockAuth;
  late MockUser mockUser;
  late MockFirebaseFunctions mockFunctions;
  late FirestoreUserRepository repository;

  const testUserId = 'test-user-123';
  const testEmail = 'test@example.com';

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    mockAuth = MockFirebaseAuth();
    mockUser = MockUser();
    mockFunctions = MockFirebaseFunctions();

    // Setup default auth state
    when(() => mockUser.uid).thenReturn(testUserId);
    when(() => mockAuth.currentUser).thenReturn(mockUser);
    when(() => mockAuth.authStateChanges()).thenAnswer((_) => Stream.value(mockUser));

    repository = FirestoreUserRepository(
      firestore: fakeFirestore,
      auth: mockAuth,
      functions: mockFunctions,
    );
  });

  group('FirestoreUserRepository', () {
    group('currentAuthUser', () {
      test('returns current Firebase user', () {
        final result = repository.currentAuthUser;

        expect(result, equals(mockUser));
        verify(() => mockAuth.currentUser).called(1);
      });

      test('returns null when no user is signed in', () {
        when(() => mockAuth.currentUser).thenReturn(null);

        final result = repository.currentAuthUser;

        expect(result, isNull);
      });
    });

    group('getUserById', () {
      test('returns UserModel for own user from Firestore', () async {
        // Create user document in Firestore
        await fakeFirestore.collection('users').doc(testUserId).set({
          'email': testEmail,
          'displayName': 'Test User',
          'isEmailVerified': true,
          'isAnonymous': false,
        });

        final result = await repository.getUserById(testUserId);

        expect(result, isNotNull);
        expect(result!.uid, testUserId);
        expect(result.email, testEmail);
        expect(result.displayName, 'Test User');
      });

      test('returns null for own user when document does not exist', () async {
        final result = await repository.getUserById(testUserId);

        expect(result, isNull);
      });

      test('calls Cloud Function for other users', () async {
        const otherUserId = 'other-user-456';
        final mockCallable = MockHttpsCallable();
        final mockResult = MockHttpsCallableResult<Map<String, dynamic>>();

        when(() => mockFunctions.httpsCallable('getPublicUserProfile'))
            .thenReturn(mockCallable);
        when(() => mockCallable.call(any())).thenAnswer((_) async => mockResult);
        when(() => mockResult.data).thenReturn({
          'user': {
            'uid': otherUserId,
            'email': 'other@example.com',
            'displayName': 'Other User',
            'photoUrl': null,
            'firstName': null,
            'lastName': null,
          },
        });

        final result = await repository.getUserById(otherUserId);

        expect(result, isNotNull);
        expect(result!.uid, otherUserId);
        expect(result.email, 'other@example.com');
        expect(result.displayName, 'Other User');
        verify(() => mockFunctions.httpsCallable('getPublicUserProfile')).called(1);
      });

      test('returns null when Cloud Function returns null user', () async {
        const otherUserId = 'other-user-456';
        final mockCallable = MockHttpsCallable();
        final mockResult = MockHttpsCallableResult<Map<String, dynamic>>();

        when(() => mockFunctions.httpsCallable('getPublicUserProfile'))
            .thenReturn(mockCallable);
        when(() => mockCallable.call(any())).thenAnswer((_) async => mockResult);
        when(() => mockResult.data).thenReturn({'user': null});

        final result = await repository.getUserById(otherUserId);

        expect(result, isNull);
      });

      test('throws UserException on Cloud Function error', () async {
        const otherUserId = 'other-user-456';
        final mockCallable = MockHttpsCallable();

        when(() => mockFunctions.httpsCallable('getPublicUserProfile'))
            .thenReturn(mockCallable);
        when(() => mockCallable.call(any())).thenThrow(
          FirebaseFunctionsException(code: 'not-found', message: 'User not found'),
        );

        expect(
          () => repository.getUserById(otherUserId),
          throwsA(isA<UserException>().having(
            (e) => e.message,
            'message',
            contains('Failed to get user'),
          )),
        );
      });
    });

    group('createOrUpdateUser', () {
      test('creates new user document', () async {
        final user = UserModel(
          uid: testUserId,
          email: testEmail,
          displayName: 'New User',
          isEmailVerified: true,
          isAnonymous: false,
        );

        await repository.createOrUpdateUser(user);

        final doc = await fakeFirestore.collection('users').doc(testUserId).get();
        expect(doc.exists, true);
        expect(doc.data()!['email'], testEmail);
        expect(doc.data()!['displayName'], 'New User');
      });

      test('updates existing user document', () async {
        // Create initial user
        await fakeFirestore.collection('users').doc(testUserId).set({
          'email': testEmail,
          'displayName': 'Old Name',
          'isEmailVerified': true,
          'isAnonymous': false,
        });

        final updatedUser = UserModel(
          uid: testUserId,
          email: testEmail,
          displayName: 'New Name',
          isEmailVerified: true,
          isAnonymous: false,
        );

        await repository.createOrUpdateUser(updatedUser);

        final doc = await fakeFirestore.collection('users').doc(testUserId).get();
        expect(doc.data()!['displayName'], 'New Name');
        expect(doc.data()!['email'], testEmail);
      });
    });

    group('updateUserProfile', () {
      test('updates user profile fields', () async {
        // Create initial user
        await fakeFirestore.collection('users').doc(testUserId).set({
          'email': testEmail,
          'displayName': 'Old Name',
          'isEmailVerified': true,
          'isAnonymous': false,
        });

        await repository.updateUserProfile(
          testUserId,
          displayName: 'New Name',
          bio: 'New bio text',
          location: 'New York',
        );

        final doc = await fakeFirestore.collection('users').doc(testUserId).get();
        expect(doc.data()!['displayName'], 'New Name');
        expect(doc.data()!['bio'], 'New bio text');
        expect(doc.data()!['location'], 'New York');
      });

      test('throws UserException when user not found', () async {
        // Use current user's ID so it reads from Firestore directly (not Cloud Function)
        // But don't create the document, so user is not found
        expect(
          () => repository.updateUserProfile(
            testUserId,
            displayName: 'New Name',
          ),
          throwsA(isA<UserException>().having(
            (e) => e.message,
            'message',
            contains('User not found'),
          )),
        );
      });
    });

    group('updateUserPreferences', () {
      test('updates notification preferences', () async {
        await fakeFirestore.collection('users').doc(testUserId).set({
          'email': testEmail,
          'isEmailVerified': true,
          'isAnonymous': false,
          'notificationsEnabled': true,
          'emailNotifications': true,
          'pushNotifications': true,
        });

        await repository.updateUserPreferences(
          testUserId,
          notificationsEnabled: false,
          emailNotifications: false,
        );

        final doc = await fakeFirestore.collection('users').doc(testUserId).get();
        expect(doc.data()!['notificationsEnabled'], false);
        expect(doc.data()!['emailNotifications'], false);
        expect(doc.data()!['pushNotifications'], true);
      });

      test('throws UserException when user not found', () async {
        // Use current user's ID so it reads from Firestore directly (not Cloud Function)
        // But don't create the document, so user is not found
        expect(
          () => repository.updateUserPreferences(
            testUserId,
            notificationsEnabled: false,
          ),
          throwsA(isA<UserException>().having(
            (e) => e.message,
            'message',
            contains('User not found'),
          )),
        );
      });
    });

    group('updateUserPrivacy', () {
      test('updates privacy settings', () async {
        await fakeFirestore.collection('users').doc(testUserId).set({
          'email': testEmail,
          'isEmailVerified': true,
          'isAnonymous': false,
          'privacyLevel': 'public',
          'showEmail': true,
          'showPhoneNumber': true,
        });

        await repository.updateUserPrivacy(
          testUserId,
          privacyLevel: UserPrivacyLevel.friends,
          showEmail: false,
        );

        final doc = await fakeFirestore.collection('users').doc(testUserId).get();
        expect(doc.data()!['privacyLevel'], 'friends');
        expect(doc.data()!['showEmail'], false);
        expect(doc.data()!['showPhoneNumber'], true);
      });

      test('throws UserException when user not found', () async {
        // Use current user's ID so it reads from Firestore directly (not Cloud Function)
        // But don't create the document, so user is not found
        expect(
          () => repository.updateUserPrivacy(
            testUserId,
            privacyLevel: UserPrivacyLevel.private,
          ),
          throwsA(isA<UserException>().having(
            (e) => e.message,
            'message',
            contains('User not found'),
          )),
        );
      });
    });

    group('joinGroup', () {
      test('adds group to user groupIds', () async {
        await fakeFirestore.collection('users').doc(testUserId).set({
          'email': testEmail,
          'isEmailVerified': true,
          'isAnonymous': false,
          'groupIds': <String>[],
        });

        await repository.joinGroup(testUserId, 'group-123');

        final doc = await fakeFirestore.collection('users').doc(testUserId).get();
        expect(doc.data()!['groupIds'], contains('group-123'));
      });

      test('throws UserException when user not found', () async {
        // Use current user's ID so it reads from Firestore directly (not Cloud Function)
        // But don't create the document, so user is not found
        expect(
          () => repository.joinGroup(testUserId, 'group-123'),
          throwsA(isA<UserException>().having(
            (e) => e.message,
            'message',
            contains('User not found'),
          )),
        );
      });
    });

    group('leaveGroup', () {
      test('removes group from user groupIds', () async {
        await fakeFirestore.collection('users').doc(testUserId).set({
          'email': testEmail,
          'isEmailVerified': true,
          'isAnonymous': false,
          'groupIds': ['group-123', 'group-456'],
        });

        await repository.leaveGroup(testUserId, 'group-123');

        final doc = await fakeFirestore.collection('users').doc(testUserId).get();
        expect(doc.data()!['groupIds'], isNot(contains('group-123')));
        expect(doc.data()!['groupIds'], contains('group-456'));
      });

      test('throws UserException when user not found', () async {
        // Use current user's ID so it reads from Firestore directly (not Cloud Function)
        // But don't create the document, so user is not found
        expect(
          () => repository.leaveGroup(testUserId, 'group-123'),
          throwsA(isA<UserException>().having(
            (e) => e.message,
            'message',
            contains('User not found'),
          )),
        );
      });
    });

    group('addGameParticipation', () {
      test('adds game to user and updates stats', () async {
        await fakeFirestore.collection('users').doc(testUserId).set({
          'email': testEmail,
          'isEmailVerified': true,
          'isAnonymous': false,
          'gameIds': <String>[],
          'gamesPlayed': 0,
          'gamesWon': 0,
          'totalScore': 0,
        });

        await repository.addGameParticipation(
          testUserId,
          'game-123',
          won: true,
          score: 21,
        );

        final doc = await fakeFirestore.collection('users').doc(testUserId).get();
        expect(doc.data()!['gameIds'], contains('game-123'));
        expect(doc.data()!['gamesPlayed'], 1);
        expect(doc.data()!['gamesWon'], 1);
        expect(doc.data()!['totalScore'], 21);
      });

      test('throws UserException when user not found', () async {
        // Use current user's ID so it reads from Firestore directly (not Cloud Function)
        // But don't create the document, so user is not found
        expect(
          () => repository.addGameParticipation(testUserId, 'game-123'),
          throwsA(isA<UserException>().having(
            (e) => e.message,
            'message',
            contains('User not found'),
          )),
        );
      });
    });

    group('searchUsers', () {
      test('returns empty list for empty query', () async {
        final result = await repository.searchUsers('');

        expect(result, isEmpty);
      });

      test('returns empty list for whitespace-only query', () async {
        final result = await repository.searchUsers('   ');

        expect(result, isEmpty);
      });

      test('finds users by display name', () async {
        await fakeFirestore.collection('users').doc('user-1').set({
          'email': 'john@example.com',
          'displayName': 'john',
          'isEmailVerified': true,
          'isAnonymous': false,
        });
        await fakeFirestore.collection('users').doc('user-2').set({
          'email': 'jane@example.com',
          'displayName': 'jane',
          'isEmailVerified': true,
          'isAnonymous': false,
        });

        final result = await repository.searchUsers('john');

        expect(result.length, 1);
        expect(result.first.displayName, 'john');
      });
    });

    group('getUsersInGroup', () {
      test('returns users in a specific group', () async {
        await fakeFirestore.collection('users').doc('user-1').set({
          'email': 'user1@example.com',
          'displayName': 'User 1',
          'isEmailVerified': true,
          'isAnonymous': false,
          'groupIds': ['group-123'],
        });
        await fakeFirestore.collection('users').doc('user-2').set({
          'email': 'user2@example.com',
          'displayName': 'User 2',
          'isEmailVerified': true,
          'isAnonymous': false,
          'groupIds': ['group-123', 'group-456'],
        });
        await fakeFirestore.collection('users').doc('user-3').set({
          'email': 'user3@example.com',
          'displayName': 'User 3',
          'isEmailVerified': true,
          'isAnonymous': false,
          'groupIds': ['group-456'],
        });

        final result = await repository.getUsersInGroup('group-123');

        expect(result.length, 2);
        expect(result.map((u) => u.displayName), containsAll(['User 1', 'User 2']));
      });

      test('returns empty list when no users in group', () async {
        final result = await repository.getUsersInGroup('non-existent-group');

        expect(result, isEmpty);
      });
    });

    group('deleteUser', () {
      test('deletes user document', () async {
        await fakeFirestore.collection('users').doc(testUserId).set({
          'email': testEmail,
          'isEmailVerified': true,
          'isAnonymous': false,
        });

        await repository.deleteUser(testUserId);

        final doc = await fakeFirestore.collection('users').doc(testUserId).get();
        expect(doc.exists, false);
      });
    });

    group('userExists', () {
      test('returns true when user exists', () async {
        await fakeFirestore.collection('users').doc(testUserId).set({
          'email': testEmail,
          'isEmailVerified': true,
          'isAnonymous': false,
        });

        final result = await repository.userExists(testUserId);

        expect(result, true);
      });

      test('returns false when user does not exist', () async {
        final result = await repository.userExists('non-existent-user');

        expect(result, false);
      });
    });

    group('getUsersByIds', () {
      test('returns empty list for empty ids', () async {
        final result = await repository.getUsersByIds([]);

        expect(result, isEmpty);
      });

      test('calls Cloud Function and returns users', () async {
        final mockCallable = MockHttpsCallable();
        final mockResult = MockHttpsCallableResult<Map<String, dynamic>>();

        when(() => mockFunctions.httpsCallable('getUsersByIds'))
            .thenReturn(mockCallable);
        when(() => mockCallable.call(any())).thenAnswer((_) async => mockResult);
        when(() => mockResult.data).thenReturn({
          'users': [
            {
              'uid': 'user-1',
              'email': 'user1@example.com',
              'displayName': 'User 1',
              'photoUrl': null,
            },
            {
              'uid': 'user-2',
              'email': 'user2@example.com',
              'displayName': 'User 2',
              'photoUrl': null,
            },
          ],
        });

        final result = await repository.getUsersByIds(['user-1', 'user-2']);

        expect(result.length, 2);
        expect(result.map((u) => u.uid), containsAll(['user-1', 'user-2']));
      });

      test('throws UserException on Cloud Function error', () async {
        final mockCallable = MockHttpsCallable();

        when(() => mockFunctions.httpsCallable('getUsersByIds'))
            .thenReturn(mockCallable);
        when(() => mockCallable.call(any())).thenThrow(
          FirebaseFunctionsException(code: 'internal', message: 'Server error'),
        );

        expect(
          () => repository.getUsersByIds(['user-1']),
          throwsA(isA<UserException>().having(
            (e) => e.message,
            'message',
            contains('Failed to get users'),
          )),
        );
      });
    });

    group('getHeadToHeadStats', () {
      test('returns null when Cloud Function returns null', () async {
        final mockCallable = MockHttpsCallable();
        final mockResult = MockHttpsCallableResult<Map<String, dynamic>?>();

        when(() => mockFunctions.httpsCallable('getHeadToHeadStats'))
            .thenReturn(mockCallable);
        when(() => mockCallable.call(any())).thenAnswer((_) async => mockResult);
        when(() => mockResult.data).thenReturn(null);

        final result = await repository.getHeadToHeadStats(testUserId, 'opponent-123');

        expect(result, isNull);
      });

      test('throws UserException with unauthenticated code', () async {
        final mockCallable = MockHttpsCallable();

        when(() => mockFunctions.httpsCallable('getHeadToHeadStats'))
            .thenReturn(mockCallable);
        when(() => mockCallable.call(any())).thenThrow(
          FirebaseFunctionsException(code: 'unauthenticated', message: 'Not logged in'),
        );

        expect(
          () => repository.getHeadToHeadStats(testUserId, 'opponent-123'),
          throwsA(isA<UserException>().having(
            (e) => e.code,
            'code',
            'unauthenticated',
          )),
        );
      });

      test('throws UserException with permission-denied code', () async {
        final mockCallable = MockHttpsCallable();

        when(() => mockFunctions.httpsCallable('getHeadToHeadStats'))
            .thenReturn(mockCallable);
        when(() => mockCallable.call(any())).thenThrow(
          FirebaseFunctionsException(code: 'permission-denied', message: 'Access denied'),
        );

        expect(
          () => repository.getHeadToHeadStats(testUserId, 'opponent-123'),
          throwsA(isA<UserException>().having(
            (e) => e.code,
            'code',
            'permission-denied',
          )),
        );
      });

      test('returns null for not-found error', () async {
        final mockCallable = MockHttpsCallable();

        when(() => mockFunctions.httpsCallable('getHeadToHeadStats'))
            .thenReturn(mockCallable);
        when(() => mockCallable.call(any())).thenThrow(
          FirebaseFunctionsException(code: 'not-found', message: 'Stats not found'),
        );

        final result = await repository.getHeadToHeadStats(testUserId, 'opponent-123');

        expect(result, isNull);
      });
    });

    group('getUserRanking', () {
      test('throws UserException with unauthenticated code', () async {
        final mockCallable = MockHttpsCallable();

        when(() => mockFunctions.httpsCallable('calculateUserRanking'))
            .thenReturn(mockCallable);
        when(() => mockCallable.call<Map<String, dynamic>>()).thenThrow(
          FirebaseFunctionsException(code: 'unauthenticated', message: 'Not logged in'),
        );

        expect(
          () => repository.getUserRanking(testUserId),
          throwsA(isA<UserException>().having(
            (e) => e.code,
            'code',
            'unauthenticated',
          )),
        );
      });

      test('throws UserException with not-found code', () async {
        final mockCallable = MockHttpsCallable();

        when(() => mockFunctions.httpsCallable('calculateUserRanking'))
            .thenReturn(mockCallable);
        when(() => mockCallable.call<Map<String, dynamic>>()).thenThrow(
          FirebaseFunctionsException(code: 'not-found', message: 'User not found'),
        );

        expect(
          () => repository.getUserRanking(testUserId),
          throwsA(isA<UserException>().having(
            (e) => e.code,
            'code',
            'not-found',
          )),
        );
      });

      test('throws UserException with internal code', () async {
        final mockCallable = MockHttpsCallable();

        when(() => mockFunctions.httpsCallable('calculateUserRanking'))
            .thenReturn(mockCallable);
        when(() => mockCallable.call<Map<String, dynamic>>()).thenThrow(
          FirebaseFunctionsException(code: 'internal', message: 'Server error'),
        );

        expect(
          () => repository.getUserRanking(testUserId),
          throwsA(isA<UserException>().having(
            (e) => e.code,
            'code',
            'internal',
          )),
        );
      });
    });

    group('getTeammateStats', () {
      test('returns null when user does not exist', () async {
        final result = await repository.getTeammateStats(
          'non-existent-user',
          'teammate-123',
        );

        expect(result, isNull);
      });

      test('returns null when no teammate stats exist', () async {
        await fakeFirestore.collection('users').doc(testUserId).set({
          'email': testEmail,
          'isEmailVerified': true,
          'isAnonymous': false,
        });

        final result = await repository.getTeammateStats(testUserId, 'teammate-123');

        expect(result, isNull);
      });

      test('returns null when specific teammate not found in stats', () async {
        await fakeFirestore.collection('users').doc(testUserId).set({
          'email': testEmail,
          'isEmailVerified': true,
          'isAnonymous': false,
          'teammateStats': {
            'other-teammate': {
              'gamesPlayed': 5,
              'gamesWon': 3,
            },
          },
        });

        final result = await repository.getTeammateStats(testUserId, 'teammate-123');

        expect(result, isNull);
      });

      test('returns TeammateStats when found', () async {
        await fakeFirestore.collection('users').doc(testUserId).set({
          'email': testEmail,
          'isEmailVerified': true,
          'isAnonymous': false,
          'teammateStats': {
            'teammate-123': {
              'gamesPlayed': 10,
              'gamesWon': 7,
              'gamesLost': 3,
              'pointsScored': 210,
              'pointsAllowed': 180,
              'eloChange': 25.5,
            },
          },
        });

        final result = await repository.getTeammateStats(testUserId, 'teammate-123');

        expect(result, isNotNull);
        expect(result!.gamesPlayed, 10);
        expect(result.gamesWon, 7);
        expect(result.gamesLost, 3);
      });
    });
  });
}
