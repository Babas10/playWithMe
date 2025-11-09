// Integration test for friend-related security rules
// Tests that Cloud Functions properly enforce authentication and authorization

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'helpers/firebase_emulator_helper.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await FirebaseEmulatorHelper.initialize();
  });

  setUp(() async {
    await FirebaseEmulatorHelper.clearFirestore();
    await FirebaseEmulatorHelper.signOut();
  });

  tearDown(() async {
    await FirebaseEmulatorHelper.signOut();
  });

  group('Friend Security Rules', () {
    test(
      'Unauthenticated users cannot send friend requests',
      () async {
        // Create target user but don't sign in
        final targetUser = await FirebaseEmulatorHelper.createCompleteTestUser(
          email: 'target@test.com',
          password: 'password123',
          displayName: 'Target User',
        );

        // Sign out to become unauthenticated
        await FirebaseEmulatorHelper.signOut();

        // Try to send friend request while unauthenticated
        final sendRequestCallable = FirebaseFunctions.instance.httpsCallable('sendFriendRequest');

        expect(
          () async => await sendRequestCallable.call({'targetUserId': targetUser.uid}),
          throwsA(
            predicate((e) =>
                e is FirebaseFunctionsException &&
                e.code == 'unauthenticated'),
          ),
        );
      },
    );

    test(
      'Unauthenticated users cannot search for users',
      () async {
        // Create user but don't sign in
        await FirebaseEmulatorHelper.createCompleteTestUser(
          email: 'user@test.com',
          password: 'password123',
          displayName: 'Test User',
        );

        // Sign out to become unauthenticated
        await FirebaseEmulatorHelper.signOut();

        // Try to search while unauthenticated
        final searchCallable = FirebaseFunctions.instance.httpsCallable('searchUserByEmail');

        expect(
          () async => await searchCallable.call({'email': 'user@test.com'}),
          throwsA(
            predicate((e) =>
                e is FirebaseFunctionsException &&
                e.code == 'unauthenticated'),
          ),
        );
      },
    );

    test(
      'Unauthenticated users cannot get friends list',
      () async {
        // Create user
        final user = await FirebaseEmulatorHelper.createCompleteTestUser(
          email: 'user@test.com',
          password: 'password123',
          displayName: 'Test User',
        );

        // Sign out to become unauthenticated
        await FirebaseEmulatorHelper.signOut();

        // Try to get friends while unauthenticated
        final getFriendsCallable = FirebaseFunctions.instance.httpsCallable('getFriends');

        expect(
          () async => await getFriendsCallable.call({'userId': user.uid}),
          throwsA(
            predicate((e) =>
                e is FirebaseFunctionsException &&
                e.code == 'unauthenticated'),
          ),
        );
      },
    );

    test(
      'Unauthenticated users cannot get friendship requests',
      () async {
        // Create user
        await FirebaseEmulatorHelper.createCompleteTestUser(
          email: 'user@test.com',
          password: 'password123',
          displayName: 'Test User',
        );

        // Sign out to become unauthenticated
        await FirebaseEmulatorHelper.signOut();

        // Try to get requests while unauthenticated
        final getRequestsCallable = FirebaseFunctions.instance.httpsCallable('getFriendshipRequests');

        expect(
          () async => await getRequestsCallable.call(),
          throwsA(
            predicate((e) =>
                e is FirebaseFunctionsException &&
                e.code == 'unauthenticated'),
          ),
        );
      },
    );

    test(
      'Unauthenticated users cannot check friendship status',
      () async {
        // Create user
        final user = await FirebaseEmulatorHelper.createCompleteTestUser(
          email: 'user@test.com',
          password: 'password123',
          displayName: 'Test User',
        );

        // Sign out to become unauthenticated
        await FirebaseEmulatorHelper.signOut();

        // Try to check status while unauthenticated
        final checkStatusCallable = FirebaseFunctions.instance.httpsCallable('checkFriendshipStatus');

        expect(
          () async => await checkStatusCallable.call({'userId': user.uid}),
          throwsA(
            predicate((e) =>
                e is FirebaseFunctionsException &&
                e.code == 'unauthenticated'),
          ),
        );
      },
    );

    test(
      'Cloud Functions validate required parameters',
      () async {
        // Sign in as user
        await FirebaseEmulatorHelper.createCompleteTestUser(
          email: 'user@test.com',
          password: 'password123',
          displayName: 'Test User',
        );

        await FirebaseEmulatorHelper.signOut();
        await FirebaseEmulatorHelper.signIn(
          email: 'user@test.com',
          password: 'password123',
        );

        // Try to send friend request without required parameter
        final sendRequestCallable = FirebaseFunctions.instance.httpsCallable('sendFriendRequest');

        expect(
          () async => await sendRequestCallable.call({}),
          throwsA(isA<FirebaseFunctionsException>()),
        );

        // Try to search without email parameter
        final searchCallable = FirebaseFunctions.instance.httpsCallable('searchUserByEmail');

        expect(
          () async => await searchCallable.call({}),
          throwsA(isA<FirebaseFunctionsException>()),
        );
      },
    );

    test(
      'Users can only access their own friendship requests',
      () async {
        // Create two users
        final user1 = await FirebaseEmulatorHelper.createCompleteTestUser(
          email: 'user1@test.com',
          password: 'password123',
          displayName: 'User One',
        );

        final user2 = await FirebaseEmulatorHelper.createCompleteTestUser(
          email: 'user2@test.com',
          password: 'password123',
          displayName: 'User Two',
        );

        // User1 sends request to user2
        await FirebaseEmulatorHelper.signOut();
        await FirebaseEmulatorHelper.signIn(
          email: 'user1@test.com',
          password: 'password123',
        );

        final sendRequestCallable = FirebaseFunctions.instance.httpsCallable('sendFriendRequest');
        await sendRequestCallable.call({'targetUserId': user2.uid});

        await FirebaseEmulatorHelper.waitForFirestore();

        // User1 gets their own requests - should see sent request
        final getRequestsCallable = FirebaseFunctions.instance.httpsCallable('getFriendshipRequests');
        final user1Requests = await getRequestsCallable.call();

        expect(user1Requests.data['sentRequests'], isNotEmpty);
        expect(user1Requests.data['receivedRequests'], isEmpty);

        // User2 gets their own requests - should see received request
        await FirebaseEmulatorHelper.signOut();
        await FirebaseEmulatorHelper.signIn(
          email: 'user2@test.com',
          password: 'password123',
        );

        final user2Requests = await getRequestsCallable.call();

        expect(user2Requests.data['receivedRequests'], isNotEmpty);
        expect(user2Requests.data['sentRequests'], isEmpty);

        // Verify each user only sees their own requests, not the other's
        expect(
          user1Requests.data['sentRequests'][0]['initiatorId'],
          equals(user1.uid),
        );
        expect(
          user2Requests.data['receivedRequests'][0]['recipientId'],
          equals(user2.uid),
        );
      },
    );

    test(
      'Cloud Functions handle invalid user IDs gracefully',
      () async {
        // Sign in as user
        await FirebaseEmulatorHelper.createCompleteTestUser(
          email: 'user@test.com',
          password: 'password123',
          displayName: 'Test User',
        );

        await FirebaseEmulatorHelper.signOut();
        await FirebaseEmulatorHelper.signIn(
          email: 'user@test.com',
          password: 'password123',
        );

        // Try operations with invalid user IDs
        final sendRequestCallable = FirebaseFunctions.instance.httpsCallable('sendFriendRequest');

        // Empty user ID
        expect(
          () async => await sendRequestCallable.call({'targetUserId': ''}),
          throwsA(isA<FirebaseFunctionsException>()),
        );

        // Non-existent user ID
        expect(
          () async => await sendRequestCallable.call({'targetUserId': 'non-existent-id'}),
          throwsA(isA<FirebaseFunctionsException>()),
        );
      },
    );

    test(
      'Search function returns appropriate data without exposing sensitive info',
      () async {
        // Create two users
        await FirebaseEmulatorHelper.createCompleteTestUser(
          email: 'user1@test.com',
          password: 'password123',
          displayName: 'User One',
        );

        final user2 = await FirebaseEmulatorHelper.createCompleteTestUser(
          email: 'user2@test.com',
          password: 'password123',
          displayName: 'User Two',
        );

        // Sign in as user1 and search for user2
        await FirebaseEmulatorHelper.signOut();
        await FirebaseEmulatorHelper.signIn(
          email: 'user1@test.com',
          password: 'password123',
        );

        final searchCallable = FirebaseFunctions.instance.httpsCallable('searchUserByEmail');
        final result = await searchCallable.call({'email': 'user2@test.com'});

        // Verify returned data includes public info
        expect(result.data['user'], isNotNull);
        expect(result.data['user']['uid'], equals(user2.uid));
        expect(result.data['user']['email'], equals('user2@test.com'));
        expect(result.data['user']['displayName'], equals('User Two'));

        // Verify relationship status included
        expect(result.data['isFriend'], isNotNull);
        expect(result.data['hasPendingRequest'], isNotNull);

        // Verify user data doesn't include sensitive fields
        // (In production, verify no tokens, passwords, or private data)
        expect(result.data['user']['password'], isNull);
      },
    );

    test(
      'getFriends returns complete user profiles with required fields',
      () async {
        // Create two users and establish friendship
        final user1 = await FirebaseEmulatorHelper.createCompleteTestUser(
          email: 'user1@test.com',
          password: 'password123',
          displayName: 'User One',
        );

        final user2 = await FirebaseEmulatorHelper.createCompleteTestUser(
          email: 'user2@test.com',
          password: 'password123',
          displayName: 'User Two',
        );

        // Create accepted friendship
        await FirebaseEmulatorHelper.signOut();
        await FirebaseEmulatorHelper.signIn(
          email: 'user1@test.com',
          password: 'password123',
        );

        final sendRequestCallable = FirebaseFunctions.instance.httpsCallable('sendFriendRequest');
        final requestResult = await sendRequestCallable.call({'targetUserId': user2.uid});

        await FirebaseEmulatorHelper.signOut();
        await FirebaseEmulatorHelper.signIn(
          email: 'user2@test.com',
          password: 'password123',
        );

        await FirebaseEmulatorHelper.firestore
            .collection('friendships')
            .doc(requestResult.data['friendshipId'])
            .update({
          'status': 'accepted',
          'updatedAt': FieldValue.serverTimestamp(),
        });

        await FirebaseEmulatorHelper.waitForFirestore();

        // Get friends list
        final getFriendsCallable = FirebaseFunctions.instance.httpsCallable('getFriends');
        final result = await getFriendsCallable.call({'userId': user2.uid});

        expect(result.data['friends'], isNotEmpty);

        final friend = result.data['friends'][0];

        // Verify all required fields are present
        expect(friend['uid'], isNotNull);
        expect(friend['email'], isNotNull);
        expect(friend['displayName'], isNotNull);
        expect(friend['isEmailVerified'], isNotNull);
        expect(friend['isAnonymous'], isNotNull);

        // Verify actual values
        expect(friend['uid'], equals(user1.uid));
        expect(friend['email'], equals('user1@test.com'));
        expect(friend['displayName'], equals('User One'));
      },
    );
  });
}
