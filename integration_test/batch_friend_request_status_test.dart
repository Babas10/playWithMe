// Integration test for batch friend request status checking
// Tests real Firestore interactions using Firebase Emulator for Story 11.19

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

  group('Batch Friend Request Status - Story 11.19', () {
    test(
      'Should return correct statuses for multiple users (mix of none, sentByMe, receivedFromThem)',
      () async {
        // 1. Create test users
        final currentUser = await FirebaseEmulatorHelper.createCompleteTestUser(
          email: 'current@test.com',
          password: 'password123',
          displayName: 'Current User',
        );

        final userNoRequest = await FirebaseEmulatorHelper.createCompleteTestUser(
          email: 'no-request@test.com',
          password: 'password123',
          displayName: 'No Request User',
        );

        final userSentToMe = await FirebaseEmulatorHelper.createCompleteTestUser(
          email: 'sent-to-me@test.com',
          password: 'password123',
          displayName: 'Sent To Me User',
        );

        final userISentTo = await FirebaseEmulatorHelper.createCompleteTestUser(
          email: 'i-sent-to@test.com',
          password: 'password123',
          displayName: 'I Sent To User',
        );

        // 2. Sign in as currentUser
        await FirebaseEmulatorHelper.signOut();
        await FirebaseEmulatorHelper.signIn(
          email: 'current@test.com',
          password: 'password123',
        );

        // 3. Send friend request to userISentTo
        final sendRequestCallable =
            FirebaseFunctions.instance.httpsCallable('sendFriendRequest');
        await sendRequestCallable.call({'targetUserId': userISentTo.uid});
        await FirebaseEmulatorHelper.waitForFirestore();

        // 4. Sign in as userSentToMe and send request to currentUser
        await FirebaseEmulatorHelper.signOut();
        await FirebaseEmulatorHelper.signIn(
          email: 'sent-to-me@test.com',
          password: 'password123',
        );
        await sendRequestCallable.call({'targetUserId': currentUser.uid});
        await FirebaseEmulatorHelper.waitForFirestore();

        // 5. Sign back in as currentUser
        await FirebaseEmulatorHelper.signOut();
        await FirebaseEmulatorHelper.signIn(
          email: 'current@test.com',
          password: 'password123',
        );

        // 6. Call batchCheckFriendRequestStatus
        final batchCheckCallable = FirebaseFunctions.instance
            .httpsCallable('batchCheckFriendRequestStatus');
        final result = await batchCheckCallable.call({
          'userIds': [
            userNoRequest.uid,
            userSentToMe.uid,
            userISentTo.uid,
          ],
        });

        expect(result.data, isNotNull);
        expect(result.data['requestStatuses'], isNotNull);

        final statuses =
            Map<String, dynamic>.from(result.data['requestStatuses'] as Map);

        // 7. Verify each status
        expect(statuses[userNoRequest.uid], equals('none'));
        expect(statuses[userSentToMe.uid], equals('receivedFromThem'));
        expect(statuses[userISentTo.uid], equals('sentByMe'));
      },
    );

    test(
      'Should return empty map for empty userIds list',
      () async {
        // 1. Create and sign in as test user
        await FirebaseEmulatorHelper.createCompleteTestUser(
          email: 'test@test.com',
          password: 'password123',
          displayName: 'Test User',
        );

        await FirebaseEmulatorHelper.signOut();
        await FirebaseEmulatorHelper.signIn(
          email: 'test@test.com',
          password: 'password123',
        );

        // 2. Call batchCheckFriendRequestStatus with empty list
        final batchCheckCallable = FirebaseFunctions.instance
            .httpsCallable('batchCheckFriendRequestStatus');
        final result = await batchCheckCallable.call({
          'userIds': [],
        });

        expect(result.data, isNotNull);
        expect(result.data['requestStatuses'], isNotNull);

        final statuses =
            Map<String, dynamic>.from(result.data['requestStatuses'] as Map);
        expect(statuses.isEmpty, isTrue);
      },
    );

    test(
      'Should handle large batch of users (50 users)',
      () async {
        // 1. Create current user
        final currentUser = await FirebaseEmulatorHelper.createCompleteTestUser(
          email: 'current@test.com',
          password: 'password123',
          displayName: 'Current User',
        );

        // 2. Create 50 test users
        final List<String> userIds = [];
        for (int i = 0; i < 50; i++) {
          final user = await FirebaseEmulatorHelper.createCompleteTestUser(
            email: 'user$i@test.com',
            password: 'password123',
            displayName: 'User $i',
          );
          userIds.add(user.uid);
        }

        // 3. Sign in as currentUser
        await FirebaseEmulatorHelper.signOut();
        await FirebaseEmulatorHelper.signIn(
          email: 'current@test.com',
          password: 'password123',
        );

        // 4. Send requests to first 10 users
        final sendRequestCallable =
            FirebaseFunctions.instance.httpsCallable('sendFriendRequest');
        for (int i = 0; i < 10; i++) {
          await sendRequestCallable.call({'targetUserId': userIds[i]});
        }
        await FirebaseEmulatorHelper.waitForFirestore();

        // 5. Call batchCheckFriendRequestStatus
        final batchCheckCallable = FirebaseFunctions.instance
            .httpsCallable('batchCheckFriendRequestStatus');
        final result = await batchCheckCallable.call({
          'userIds': userIds,
        });

        expect(result.data, isNotNull);
        expect(result.data['requestStatuses'], isNotNull);

        final statuses =
            Map<String, dynamic>.from(result.data['requestStatuses'] as Map);

        // 6. Verify all 50 users have status
        expect(statuses.length, equals(50));

        // 7. Verify first 10 are sentByMe
        for (int i = 0; i < 10; i++) {
          expect(statuses[userIds[i]], equals('sentByMe'));
        }

        // 8. Verify remaining are none
        for (int i = 10; i < 50; i++) {
          expect(statuses[userIds[i]], equals('none'));
        }
      },
    );

    test(
      'Should reject more than 100 users',
      () async {
        // 1. Create and sign in as test user
        await FirebaseEmulatorHelper.createCompleteTestUser(
          email: 'test@test.com',
          password: 'password123',
          displayName: 'Test User',
        );

        await FirebaseEmulatorHelper.signOut();
        await FirebaseEmulatorHelper.signIn(
          email: 'test@test.com',
          password: 'password123',
        );

        // 2. Create list of 101 fake user IDs
        final List<String> userIds =
            List.generate(101, (i) => 'fake-user-id-$i');

        // 3. Call batchCheckFriendRequestStatus should fail
        final batchCheckCallable = FirebaseFunctions.instance
            .httpsCallable('batchCheckFriendRequestStatus');

        expect(
          () => batchCheckCallable.call({'userIds': userIds}),
          throwsA(
            isA<FirebaseFunctionsException>().having(
              (e) => e.code,
              'code',
              'invalid-argument',
            ),
          ),
        );
      },
    );

    test(
      'Should require authentication',
      () async {
        // 1. Ensure signed out
        await FirebaseEmulatorHelper.signOut();

        // 2. Try to call batchCheckFriendRequestStatus without auth
        final batchCheckCallable = FirebaseFunctions.instance
            .httpsCallable('batchCheckFriendRequestStatus');

        expect(
          () => batchCheckCallable.call({
            'userIds': ['fake-user-id'],
          }),
          throwsA(
            isA<FirebaseFunctionsException>().having(
              (e) => e.code,
              'code',
              'unauthenticated',
            ),
          ),
        );
      },
    );

    test(
      'Should handle mix of friends and non-friends correctly',
      () async {
        // 1. Create test users
        final currentUser = await FirebaseEmulatorHelper.createCompleteTestUser(
          email: 'current@test.com',
          password: 'password123',
          displayName: 'Current User',
        );

        final friendUser = await FirebaseEmulatorHelper.createCompleteTestUser(
          email: 'friend@test.com',
          password: 'password123',
          displayName: 'Friend User',
        );

        final pendingUser = await FirebaseEmulatorHelper.createCompleteTestUser(
          email: 'pending@test.com',
          password: 'password123',
          displayName: 'Pending User',
        );

        // 2. Create accepted friendship with friendUser
        await FirebaseEmulatorHelper.signOut();
        await FirebaseEmulatorHelper.signIn(
          email: 'current@test.com',
          password: 'password123',
        );

        final sendRequestCallable =
            FirebaseFunctions.instance.httpsCallable('sendFriendRequest');
        final requestResult =
            await sendRequestCallable.call({'targetUserId': friendUser.uid});
        final friendshipId = requestResult.data['friendshipId'];
        await FirebaseEmulatorHelper.waitForFirestore();

        // Accept the friend request
        await FirebaseEmulatorHelper.signOut();
        await FirebaseEmulatorHelper.signIn(
          email: 'friend@test.com',
          password: 'password123',
        );

        final acceptCallable =
            FirebaseFunctions.instance.httpsCallable('acceptFriendRequest');
        await acceptCallable.call({'friendshipId': friendshipId});
        await FirebaseEmulatorHelper.waitForFirestore();

        // 3. Send pending request to pendingUser
        await FirebaseEmulatorHelper.signOut();
        await FirebaseEmulatorHelper.signIn(
          email: 'current@test.com',
          password: 'password123',
        );

        await sendRequestCallable.call({'targetUserId': pendingUser.uid});
        await FirebaseEmulatorHelper.waitForFirestore();

        // 4. Call batchCheckFriendRequestStatus
        // Note: friendUser should NOT appear in request statuses because they're already friends
        final batchCheckCallable = FirebaseFunctions.instance
            .httpsCallable('batchCheckFriendRequestStatus');
        final result = await batchCheckCallable.call({
          'userIds': [
            friendUser.uid,
            pendingUser.uid,
          ],
        });

        final statuses =
            Map<String, dynamic>.from(result.data['requestStatuses'] as Map);

        // 5. Verify: friendUser shows 'none' (they're friends, not pending)
        // and pendingUser shows 'sentByMe'
        expect(statuses[friendUser.uid], equals('none'));
        expect(statuses[pendingUser.uid], equals('sentByMe'));
      },
    );
  });
}
