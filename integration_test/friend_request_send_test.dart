// Integration test for friend request sending flow
// Tests real Firestore interactions using Firebase Emulator

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

  group('Friend Request Send Flow', () {
    test(
      'User can search for another user by email and send friend request',
      () async {
        // 1. Create two test users
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

        // 2. Sign in as user1
        await FirebaseEmulatorHelper.signOut();
        await FirebaseEmulatorHelper.signIn(
          email: 'user1@test.com',
          password: 'password123',
        );

        // 3. Search for user2 by email
        final searchCallable = FirebaseFunctions.instance.httpsCallable('searchUserByEmail');
        final searchResult = await searchCallable.call({'email': 'user2@test.com'});

        expect(searchResult.data['user'], isNotNull);
        expect(searchResult.data['user']['uid'], equals(user2.uid));
        expect(searchResult.data['user']['email'], equals('user2@test.com'));
        expect(searchResult.data['isFriend'], isFalse);
        expect(searchResult.data['hasPendingRequest'], isFalse);

        // 4. Send friend request
        final sendRequestCallable = FirebaseFunctions.instance.httpsCallable('sendFriendRequest');
        final requestResult = await sendRequestCallable.call({'targetUserId': user2.uid});

        expect(requestResult.data['success'], isTrue);
        expect(requestResult.data['friendshipId'], isNotEmpty);

        final friendshipId = requestResult.data['friendshipId'];

        await FirebaseEmulatorHelper.waitForFirestore();

        // 5. Verify friendship document created with correct data
        final friendshipDoc = await FirebaseFirestore.instance
            .collection('friendships')
            .doc(friendshipId)
            .get();

        expect(friendshipDoc.exists, isTrue);
        final friendshipData = friendshipDoc.data()!;
        expect(friendshipData['initiatorId'], equals(user1.uid));
        expect(friendshipData['recipientId'], equals(user2.uid));
        expect(friendshipData['status'], equals('pending'));
        expect(friendshipData['initiatorName'], equals('User One'));
        expect(friendshipData['recipientName'], equals('User Two'));
        expect(friendshipData['createdAt'], isNotNull);

        // 6. Search again - should show pending request
        final searchResult2 = await searchCallable.call({'email': 'user2@test.com'});
        expect(searchResult2.data['hasPendingRequest'], isTrue);
        expect(searchResult2.data['requestDirection'], equals('sent'));
      },
    );

    test(
      'User cannot send friend request to themselves',
      () async {
        // Create and sign in as user
        final user = await FirebaseEmulatorHelper.createCompleteTestUser(
          email: 'user@test.com',
          password: 'password123',
          displayName: 'Test User',
        );

        await FirebaseEmulatorHelper.signOut();
        await FirebaseEmulatorHelper.signIn(
          email: 'user@test.com',
          password: 'password123',
        );

        // Try to send friend request to self
        final sendRequestCallable = FirebaseFunctions.instance.httpsCallable('sendFriendRequest');

        expect(
          () async => await sendRequestCallable.call({'targetUserId': user.uid}),
          throwsA(isA<FirebaseFunctionsException>()),
        );
      },
    );

    test(
      'User cannot send duplicate friend request',
      () async {
        // 1. Create two test users
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

        // 2. Sign in as user1
        await FirebaseEmulatorHelper.signOut();
        await FirebaseEmulatorHelper.signIn(
          email: 'user1@test.com',
          password: 'password123',
        );

        // 3. Send first friend request
        final sendRequestCallable = FirebaseFunctions.instance.httpsCallable('sendFriendRequest');
        await sendRequestCallable.call({'targetUserId': user2.uid});

        await FirebaseEmulatorHelper.waitForFirestore();

        // 4. Try to send second friend request - should fail
        expect(
          () async => await sendRequestCallable.call({'targetUserId': user2.uid}),
          throwsA(isA<FirebaseFunctionsException>()),
        );
      },
    );

    test(
      'Sent friend request appears in sender\'s sent requests',
      () async {
        // 1. Create two test users
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

        // 2. Sign in as user1 and send request
        await FirebaseEmulatorHelper.signOut();
        await FirebaseEmulatorHelper.signIn(
          email: 'user1@test.com',
          password: 'password123',
        );

        final sendRequestCallable = FirebaseFunctions.instance.httpsCallable('sendFriendRequest');
        await sendRequestCallable.call({'targetUserId': user2.uid});

        await FirebaseEmulatorHelper.waitForFirestore();

        // 3. Get sent requests
        final getRequestsCallable = FirebaseFunctions.instance.httpsCallable('getFriendshipRequests');
        final result = await getRequestsCallable.call();

        expect(result.data['sentRequests'], isNotEmpty);
        expect(result.data['sentRequests'].length, equals(1));
        expect(result.data['receivedRequests'], isEmpty);

        final sentRequest = result.data['sentRequests'][0];
        expect(sentRequest['initiatorId'], equals(user1.uid));
        expect(sentRequest['recipientId'], equals(user2.uid));
        expect(sentRequest['status'], equals('pending'));
      },
    );

    test(
      'Sent friend request appears in recipient\'s received requests',
      () async {
        // 1. Create two test users
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

        // 2. Sign in as user1 and send request
        await FirebaseEmulatorHelper.signOut();
        await FirebaseEmulatorHelper.signIn(
          email: 'user1@test.com',
          password: 'password123',
        );

        final sendRequestCallable = FirebaseFunctions.instance.httpsCallable('sendFriendRequest');
        await sendRequestCallable.call({'targetUserId': user2.uid});

        await FirebaseEmulatorHelper.waitForFirestore();

        // 3. Sign in as user2 and get received requests
        await FirebaseEmulatorHelper.signOut();
        await FirebaseEmulatorHelper.signIn(
          email: 'user2@test.com',
          password: 'password123',
        );

        final getRequestsCallable = FirebaseFunctions.instance.httpsCallable('getFriendshipRequests');
        final result = await getRequestsCallable.call();

        expect(result.data['receivedRequests'], isNotEmpty);
        expect(result.data['receivedRequests'].length, equals(1));
        expect(result.data['sentRequests'], isEmpty);

        final receivedRequest = result.data['receivedRequests'][0];
        expect(receivedRequest['initiatorId'], equals(user1.uid));
        expect(receivedRequest['recipientId'], equals(user2.uid));
        expect(receivedRequest['status'], equals('pending'));
        expect(receivedRequest['initiatorName'], equals('User One'));
      },
    );

    test(
      'User cannot send friend request to non-existent user',
      () async {
        // Create and sign in as user
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

        // Try to send friend request to non-existent user
        final sendRequestCallable = FirebaseFunctions.instance.httpsCallable('sendFriendRequest');

        expect(
          () async => await sendRequestCallable.call({'targetUserId': 'non-existent-user-id'}),
          throwsA(isA<FirebaseFunctionsException>()),
        );
      },
    );
  });
}
