// Integration test for game details real-time RSVP functionality
// Tests real Firestore interactions using Firebase Emulator

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
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

  group('Game Details Real-Time RSVP', () {
    test(
      'User A can see when User B joins the game in real-time',
      () async {
        // 1. Create two users
        final userA = await FirebaseEmulatorHelper.createCompleteTestUser(
          email: 'usera@test.com',
          password: 'password123',
          displayName: 'User A',
        );

        final userB = await FirebaseEmulatorHelper.createCompleteTestUser(
          email: 'userb@test.com',
          password: 'password123',
          displayName: 'User B',
        );

        // 2. Sign in as User A and create a group
        await FirebaseEmulatorHelper.signOut();
        await FirebaseEmulatorHelper.signIn(
          email: 'usera@test.com',
          password: 'password123',
        );

        final groupId = await FirebaseEmulatorHelper.createTestGroup(
          createdBy: userA.uid,
          name: 'Beach Volleyball',
        );

        // Add User B to the group
        await FirebaseEmulatorHelper.firestore
            .collection('groups')
            .doc(groupId)
            .update({
          'memberIds': FieldValue.arrayUnion([userB.uid]),
        });

        // 3. Create a game
        final gameRef = FirebaseEmulatorHelper.firestore
            .collection('games')
            .doc();

        await gameRef.set({
          'title': 'Beach Game',
          'description': 'Fun beach volleyball game',
          'groupId': groupId,
          'createdBy': userA.uid,
          'createdAt': FieldValue.serverTimestamp(),
          'scheduledAt': Timestamp.fromDate(
            DateTime.now().add(const Duration(hours: 2)),
          ),
          'location': {
            'name': 'Test Beach',
            'address': '123 Beach St',
            'latitude': 40.7128,
            'longitude': -74.0060,
          },
          'status': 'scheduled',
          'maxPlayers': 4,
          'minPlayers': 2,
          'playerIds': [userA.uid], // Only User A initially
          'waitlistIds': [],
          'allowWaitlist': true,
          'allowPlayerInvites': true,
          'visibility': 'group',
          'weatherDependent': true,
        });

        await FirebaseEmulatorHelper.waitForFirestore();

        // 4. Set up stream listener for User A (simulating them viewing the game)
        final gameStream = gameRef.snapshots();
        final streamController = StreamController<DocumentSnapshot>();
        final subscription = gameStream.listen(streamController.add);

        // 5. Verify initial state - only User A is in the game
        final initialSnapshot = await streamController.stream.first;
        final initialData = initialSnapshot.data() as Map<String, dynamic>;
        expect(initialData['playerIds'], hasLength(1));
        expect(initialData['playerIds'], contains(userA.uid));
        expect(initialData['playerIds'], isNot(contains(userB.uid)));

        // 6. User B joins the game (simulate another device/user)
        await gameRef.update({
          'playerIds': FieldValue.arrayUnion([userB.uid]),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        await FirebaseEmulatorHelper.waitForFirestore();

        // 7. User A should receive real-time update with User B added
        final updatedSnapshot = await streamController.stream
            .firstWhere((snapshot) {
              final data = snapshot.data() as Map<String, dynamic>;
              return (data['playerIds'] as List).length == 2;
            })
            .timeout(const Duration(seconds: 5));

        final updatedData = updatedSnapshot.data() as Map<String, dynamic>;
        expect(updatedData['playerIds'], hasLength(2));
        expect(updatedData['playerIds'], contains(userA.uid));
        expect(updatedData['playerIds'], contains(userB.uid));

        // Clean up
        await subscription.cancel();
        await streamController.close();
      },
      timeout: const Timeout(Duration(seconds: 30)),
    );

    test(
      'User can join and leave game, updates reflected immediately',
      () async {
        // 1. Create a user
        final user = await FirebaseEmulatorHelper.createCompleteTestUser(
          email: 'user@test.com',
          password: 'password123',
          displayName: 'Test User',
        );

        // 2. Create group and game
        await FirebaseEmulatorHelper.signOut();
        await FirebaseEmulatorHelper.signIn(
          email: 'user@test.com',
          password: 'password123',
        );

        final groupId = await FirebaseEmulatorHelper.createTestGroup(
          createdBy: user.uid,
          name: 'Test Group',
        );

        final gameRef = FirebaseEmulatorHelper.firestore
            .collection('games')
            .doc();

        await gameRef.set({
          'title': 'Test Game',
          'groupId': groupId,
          'createdBy': user.uid,
          'createdAt': FieldValue.serverTimestamp(),
          'scheduledAt': Timestamp.fromDate(
            DateTime.now().add(const Duration(hours: 1)),
          ),
          'location': {
            'name': 'Test Location',
          },
          'status': 'scheduled',
          'maxPlayers': 4,
          'minPlayers': 2,
          'playerIds': [], // Start with no players
          'waitlistIds': [],
          'allowWaitlist': true,
        });

        await FirebaseEmulatorHelper.waitForFirestore();

        // 3. Set up stream listener
        final gameStream = gameRef.snapshots();
        final updates = <List<dynamic>>[];
        final subscription = gameStream.listen((snapshot) {
          final data = snapshot.data() as Map<String, dynamic>;
          updates.add(List.from(data['playerIds'] as List));
        });

        // Wait for initial empty state
        await Future.delayed(const Duration(milliseconds: 200));

        // 4. User joins
        await gameRef.update({
          'playerIds': FieldValue.arrayUnion([user.uid]),
        });

        await Future.delayed(const Duration(milliseconds: 200));

        // 5. User leaves
        await gameRef.update({
          'playerIds': FieldValue.arrayRemove([user.uid]),
        });

        await Future.delayed(const Duration(milliseconds: 200));

        // 6. Verify we received all updates
        expect(updates.length, greaterThanOrEqualTo(3));
        expect(updates[0], isEmpty); // Initial state
        expect(updates[1], contains(user.uid)); // After join
        expect(updates[2], isEmpty); // After leave

        // Clean up
        await subscription.cancel();
      },
      timeout: const Timeout(Duration(seconds: 30)),
    );

    test(
      'Multiple users can join simultaneously and all see updates',
      () async {
        // 1. Create three users
        final users = await Future.wait([
          FirebaseEmulatorHelper.createCompleteTestUser(
            email: 'user1@test.com',
            password: 'password123',
            displayName: 'User 1',
          ),
          FirebaseEmulatorHelper.createCompleteTestUser(
            email: 'user2@test.com',
            password: 'password123',
            displayName: 'User 2',
          ),
          FirebaseEmulatorHelper.createCompleteTestUser(
            email: 'user3@test.com',
            password: 'password123',
            displayName: 'User 3',
          ),
        ]);

        // 2. Create group (as user1) and add all users
        await FirebaseEmulatorHelper.signOut();
        await FirebaseEmulatorHelper.signIn(
          email: 'user1@test.com',
          password: 'password123',
        );

        final groupId = await FirebaseEmulatorHelper.createTestGroup(
          createdBy: users[0].uid,
          name: 'Multi User Group',
        );

        await FirebaseEmulatorHelper.firestore
            .collection('groups')
            .doc(groupId)
            .update({
          'memberIds': FieldValue.arrayUnion([
            users[1].uid,
            users[2].uid,
          ]),
        });

        // 3. Create game
        final gameRef = FirebaseEmulatorHelper.firestore
            .collection('games')
            .doc();

        await gameRef.set({
          'title': 'Multi User Game',
          'groupId': groupId,
          'createdBy': users[0].uid,
          'createdAt': FieldValue.serverTimestamp(),
          'scheduledAt': Timestamp.fromDate(
            DateTime.now().add(const Duration(hours: 1)),
          ),
          'location': {'name': 'Test Beach'},
          'status': 'scheduled',
          'maxPlayers': 6,
          'minPlayers': 2,
          'playerIds': [],
          'waitlistIds': [],
          'allowWaitlist': true,
        });

        await FirebaseEmulatorHelper.waitForFirestore();

        // 4. Set up stream listener for each user
        final streamControllers = List.generate(
          3,
          (_) => StreamController<DocumentSnapshot>(),
        );

        final subscriptions = List.generate(
          3,
          (i) => gameRef.snapshots().listen(streamControllers[i].add),
        );

        await Future.delayed(const Duration(milliseconds: 100));

        // 5. All users join simultaneously
        final batch = FirebaseEmulatorHelper.firestore.batch();
        for (final user in users) {
          batch.update(gameRef, {
            'playerIds': FieldValue.arrayUnion([user.uid]),
          });
        }
        await batch.commit();

        await FirebaseEmulatorHelper.waitForFirestore();
        await Future.delayed(const Duration(milliseconds: 300));

        // 6. Verify all stream listeners received the update
        for (var i = 0; i < 3; i++) {
          final latestSnapshot = await streamControllers[i]
              .stream
              .firstWhere((snapshot) {
                final data = snapshot.data() as Map<String, dynamic>;
                return (data['playerIds'] as List).length == 3;
              })
              .timeout(const Duration(seconds: 5));

          final data = latestSnapshot.data() as Map<String, dynamic>;
          final playerIds = data['playerIds'] as List;

          expect(playerIds, hasLength(3));
          expect(playerIds, containsAll(users.map((u) => u.uid)));
        }

        // Clean up
        for (final subscription in subscriptions) {
          await subscription.cancel();
        }
        for (final controller in streamControllers) {
          await controller.close();
        }
      },
      timeout: const Timeout(Duration(seconds: 30)),
    );

    test(
      'User joins full game and is added to waitlist',
      () async {
        // 1. Create users
        final creator = await FirebaseEmulatorHelper.createCompleteTestUser(
          email: 'creator@test.com',
          password: 'password123',
          displayName: 'Creator',
        );

        final player = await FirebaseEmulatorHelper.createCompleteTestUser(
          email: 'player@test.com',
          password: 'password123',
          displayName: 'Player',
        );

        final waitlister = await FirebaseEmulatorHelper.createCompleteTestUser(
          email: 'waitlister@test.com',
          password: 'password123',
          displayName: 'Waitlister',
        );

        // 2. Create group and add all users
        await FirebaseEmulatorHelper.signOut();
        await FirebaseEmulatorHelper.signIn(
          email: 'creator@test.com',
          password: 'password123',
        );

        final groupId = await FirebaseEmulatorHelper.createTestGroup(
          createdBy: creator.uid,
          name: 'Full Game Group',
        );

        await FirebaseEmulatorHelper.firestore
            .collection('groups')
            .doc(groupId)
            .update({
          'memberIds': FieldValue.arrayUnion([player.uid, waitlister.uid]),
        });

        // 3. Create game with max 2 players
        final gameRef = FirebaseEmulatorHelper.firestore
            .collection('games')
            .doc();

        await gameRef.set({
          'title': 'Full Game',
          'groupId': groupId,
          'createdBy': creator.uid,
          'createdAt': FieldValue.serverTimestamp(),
          'scheduledAt': Timestamp.fromDate(
            DateTime.now().add(const Duration(hours: 1)),
          ),
          'location': {'name': 'Test Beach'},
          'status': 'scheduled',
          'maxPlayers': 2, // Only 2 spots
          'minPlayers': 2,
          'playerIds': [creator.uid, player.uid], // Already full
          'waitlistIds': [],
          'allowWaitlist': true,
        });

        await FirebaseEmulatorHelper.waitForFirestore();

        // 4. Set up stream listener
        final gameStream = gameRef.snapshots();
        final streamController = StreamController<DocumentSnapshot>();
        final subscription = gameStream.listen(streamController.add);

        // 5. Verify game is full
        final initialSnapshot = await streamController.stream.first;
        final initialData = initialSnapshot.data() as Map<String, dynamic>;
        expect(initialData['playerIds'], hasLength(2));
        expect(initialData['waitlistIds'], isEmpty);

        // 6. Waitlister tries to join (should go to waitlist)
        await gameRef.update({
          'waitlistIds': FieldValue.arrayUnion([waitlister.uid]),
        });

        await FirebaseEmulatorHelper.waitForFirestore();

        // 7. Verify waitlister was added to waitlist
        final updatedSnapshot = await streamController.stream
            .firstWhere((snapshot) {
              final data = snapshot.data() as Map<String, dynamic>;
              return (data['waitlistIds'] as List).isNotEmpty;
            })
            .timeout(const Duration(seconds: 5));

        final updatedData = updatedSnapshot.data() as Map<String, dynamic>;
        expect(updatedData['playerIds'], hasLength(2));
        expect(updatedData['waitlistIds'], hasLength(1));
        expect(updatedData['waitlistIds'], contains(waitlister.uid));

        // Clean up
        await subscription.cancel();
        await streamController.close();
      },
      timeout: const Timeout(Duration(seconds: 30)),
    );
  });
}
