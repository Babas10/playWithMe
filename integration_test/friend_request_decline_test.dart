// Integration test for friend request decline flow
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

  group('Friend Request Decline Flow', () {
    test(
      'User can decline friend request',
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

        // 2. User1 sends friend request
        await FirebaseEmulatorHelper.signOut();
        await FirebaseEmulatorHelper.signIn(
          email: 'user1@test.com',
          password: 'password123',
        );

        final sendRequestCallable = FirebaseFunctions.instance.httpsCallable('sendFriendRequest');
        final requestResult = await sendRequestCallable.call({'targetUserId': user2.uid});
        final friendshipId = requestResult.data['friendshipId'];

        await FirebaseEmulatorHelper.waitForFirestore();

        // 3. User2 declines the request
        await FirebaseEmulatorHelper.signOut();
        await FirebaseEmulatorHelper.signIn(
          email: 'user2@test.com',
          password: 'password123',
        );

        await FirebaseFirestore.instance
            .collection('friendships')
            .doc(friendshipId)
            .update({
          'status': 'declined',
          'updatedAt': FieldValue.serverTimestamp(),
        });

        await FirebaseEmulatorHelper.waitForFirestore();

        // 4. Verify friendship status updated to declined
        final friendshipDoc = await FirebaseFirestore.instance
            .collection('friendships')
            .doc(friendshipId)
            .get();

        expect(friendshipDoc.exists, isTrue);
        expect(friendshipDoc.data()!['status'], equals('declined'));

        // 5. Verify users are NOT friends
        final getFriendsCallable = FirebaseFunctions.instance.httpsCallable('getFriends');
        final friendsResult = await getFriendsCallable.call({'userId': user2.uid});

        expect(friendsResult.data['friends'], isEmpty);
      },
    );

    test(
      'Declined request no longer appears in pending requests',
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

        // 2. User1 sends friend request
        await FirebaseEmulatorHelper.signOut();
        await FirebaseEmulatorHelper.signIn(
          email: 'user1@test.com',
          password: 'password123',
        );

        final sendRequestCallable = FirebaseFunctions.instance.httpsCallable('sendFriendRequest');
        final requestResult = await sendRequestCallable.call({'targetUserId': user2.uid});
        final friendshipId = requestResult.data['friendshipId'];

        await FirebaseEmulatorHelper.waitForFirestore();

        // 3. Verify request appears in pending lists
        final getRequestsCallable = FirebaseFunctions.instance.httpsCallable('getFriendshipRequests');
        final requests1Before = await getRequestsCallable.call();
        expect(requests1Before.data['sentRequests'], isNotEmpty);

        await FirebaseEmulatorHelper.signOut();
        await FirebaseEmulatorHelper.signIn(
          email: 'user2@test.com',
          password: 'password123',
        );

        final requests2Before = await getRequestsCallable.call();
        expect(requests2Before.data['receivedRequests'], isNotEmpty);

        // 4. User2 declines the request
        await FirebaseFirestore.instance
            .collection('friendships')
            .doc(friendshipId)
            .update({
          'status': 'declined',
          'updatedAt': FieldValue.serverTimestamp(),
        });

        await FirebaseEmulatorHelper.waitForFirestore();

        // 5. Verify request no longer in user2's received requests
        final requests2After = await getRequestsCallable.call();
        expect(requests2After.data['receivedRequests'], isEmpty);

        // 6. Verify request no longer in user1's sent requests
        await FirebaseEmulatorHelper.signOut();
        await FirebaseEmulatorHelper.signIn(
          email: 'user1@test.com',
          password: 'password123',
        );

        final requests1After = await getRequestsCallable.call();
        expect(requests1After.data['sentRequests'], isEmpty);
      },
    );

    test(
      'User can send new request after previous was declined',
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

        // 2. User1 sends friend request
        await FirebaseEmulatorHelper.signOut();
        await FirebaseEmulatorHelper.signIn(
          email: 'user1@test.com',
          password: 'password123',
        );

        final sendRequestCallable = FirebaseFunctions.instance.httpsCallable('sendFriendRequest');
        final firstRequest = await sendRequestCallable.call({'targetUserId': user2.uid});
        final firstFriendshipId = firstRequest.data['friendshipId'];

        await FirebaseEmulatorHelper.waitForFirestore();

        // 3. User2 declines
        await FirebaseEmulatorHelper.signOut();
        await FirebaseEmulatorHelper.signIn(
          email: 'user2@test.com',
          password: 'password123',
        );

        await FirebaseFirestore.instance
            .collection('friendships')
            .doc(firstFriendshipId)
            .update({
          'status': 'declined',
          'updatedAt': FieldValue.serverTimestamp(),
        });

        await FirebaseEmulatorHelper.waitForFirestore();

        // 4. User1 sends new request - should succeed
        await FirebaseEmulatorHelper.signOut();
        await FirebaseEmulatorHelper.signIn(
          email: 'user1@test.com',
          password: 'password123',
        );

        final secondRequest = await sendRequestCallable.call({'targetUserId': user2.uid});
        expect(secondRequest.data['success'], isTrue);
        expect(secondRequest.data['friendshipId'], isNotEmpty);

        // 5. Verify new friendship created (different ID)
        final secondFriendshipId = secondRequest.data['friendshipId'];
        expect(secondFriendshipId, isNot(equals(firstFriendshipId)));

        final secondFriendshipDoc = await FirebaseFirestore.instance
            .collection('friendships')
            .doc(secondFriendshipId)
            .get();

        expect(secondFriendshipDoc.exists, isTrue);
        expect(secondFriendshipDoc.data()!['status'], equals('pending'));
      },
    );

    test(
      'Initiator can cancel their own sent request',
      () async {
        // 1. Create two test users
        final user1 = await FirebaseEmulatorHelper.createCompleteTestUser(
          email: 'user1@test.com',
          password: 'password123',
          displayName: 'User One',
        );

        await FirebaseEmulatorHelper.createCompleteTestUser(
          email: 'user2@test.com',
          password: 'password123',
          displayName: 'User Two',
        );

        // 2. User1 sends friend request
        await FirebaseEmulatorHelper.signOut();
        await FirebaseEmulatorHelper.signIn(
          email: 'user1@test.com',
          password: 'password123',
        );

        final sendRequestCallable = FirebaseFunctions.instance.httpsCallable('sendFriendRequest');
        final requestResult = await sendRequestCallable.call({'targetUserId': user1.uid});
        final friendshipId = requestResult.data['friendshipId'];

        await FirebaseEmulatorHelper.waitForFirestore();

        // 3. Verify request appears in sent requests
        final getRequestsCallable = FirebaseFunctions.instance.httpsCallable('getFriendshipRequests');
        final requestsBefore = await getRequestsCallable.call();
        expect(requestsBefore.data['sentRequests'], isNotEmpty);

        // 4. User1 cancels the request (same as declining)
        await FirebaseFirestore.instance
            .collection('friendships')
            .doc(friendshipId)
            .update({
          'status': 'declined',
          'updatedAt': FieldValue.serverTimestamp(),
        });

        await FirebaseEmulatorHelper.waitForFirestore();

        // 5. Verify request no longer in sent requests
        final requestsAfter = await getRequestsCallable.call();
        expect(requestsAfter.data['sentRequests'], isEmpty);
      },
    );

    test(
      'Search shows no pending request after decline',
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

        // 2. User1 sends friend request
        await FirebaseEmulatorHelper.signOut();
        await FirebaseEmulatorHelper.signIn(
          email: 'user1@test.com',
          password: 'password123',
        );

        final sendRequestCallable = FirebaseFunctions.instance.httpsCallable('sendFriendRequest');
        final requestResult = await sendRequestCallable.call({'targetUserId': user2.uid});
        final friendshipId = requestResult.data['friendshipId'];

        await FirebaseEmulatorHelper.waitForFirestore();

        // 3. Search shows pending request
        final searchCallable = FirebaseFunctions.instance.httpsCallable('searchUserByEmail');
        final searchBefore = await searchCallable.call({'email': 'user2@test.com'});
        expect(searchBefore.data['hasPendingRequest'], isTrue);
        expect(searchBefore.data['requestDirection'], equals('sent'));

        // 4. User2 declines
        await FirebaseEmulatorHelper.signOut();
        await FirebaseEmulatorHelper.signIn(
          email: 'user2@test.com',
          password: 'password123',
        );

        await FirebaseFirestore.instance
            .collection('friendships')
            .doc(friendshipId)
            .update({
          'status': 'declined',
          'updatedAt': FieldValue.serverTimestamp(),
        });

        await FirebaseEmulatorHelper.waitForFirestore();

        // 5. User1 searches again - should show no pending request
        await FirebaseEmulatorHelper.signOut();
        await FirebaseEmulatorHelper.signIn(
          email: 'user1@test.com',
          password: 'password123',
        );

        final searchAfter = await searchCallable.call({'email': 'user2@test.com'});
        expect(searchAfter.data['hasPendingRequest'], isFalse);
        expect(searchAfter.data['isFriend'], isFalse);
        expect(searchAfter.data['requestDirection'], isNull);
      },
    );
  });
}
