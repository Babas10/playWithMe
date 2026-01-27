// Integration tests for group navigation flow using Firebase Emulator
// Tests navigation from GroupListPage to GroupDetailsPage with real repositories
// Reference: https://github.com/Babas10/playWithMe/issues/442

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

  group('Group Navigation Integration Tests', () {
    late String userId;
    late String groupId;

    Future<void> createTestUserAndGroup() async {
      final user = await FirebaseEmulatorHelper.createCompleteTestUser(
        email: 'navigation@test.com',
        password: 'password123',
        displayName: 'Navigation Tester',
      );
      userId = user.uid;

      final firestore = FirebaseFirestore.instance;
      final groupRef = await firestore.collection('groups').add({
        'name': 'Test Navigation Group',
        'description': 'A group for testing navigation',
        'createdBy': userId,
        'memberIds': [userId],
        'adminIds': [userId],
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      groupId = groupRef.id;
    }

    test(
      'Group document can be fetched for navigation',
      () async {
        await createTestUserAndGroup();

        final firestore = FirebaseFirestore.instance;

        // Simulate what happens when navigating to group details
        final groupDoc = await firestore.collection('groups').doc(groupId).get();

        expect(groupDoc.exists, isTrue);
        expect(groupDoc.data()?['name'], equals('Test Navigation Group'));
        expect(groupDoc.data()?['description'], equals('A group for testing navigation'));
        expect(groupDoc.data()?['createdBy'], equals(userId));
        expect(groupDoc.data()?['memberIds'], contains(userId));
      },
    );

    test(
      'Group stream provides real-time updates for details page',
      () async {
        await createTestUserAndGroup();

        final firestore = FirebaseFirestore.instance;

        // Set up stream listener like GroupDetailsPage would
        String? groupName;
        final subscription = firestore
            .collection('groups')
            .doc(groupId)
            .snapshots()
            .listen((snapshot) {
          groupName = snapshot.data()?['name'] as String?;
        });

        await FirebaseEmulatorHelper.waitForFirestore();
        await Future.delayed(const Duration(milliseconds: 200));
        expect(groupName, equals('Test Navigation Group'));

        // Update group (simulating another user updating the group)
        await firestore.collection('groups').doc(groupId).update({
          'name': 'Updated Group Name',
        });

        await FirebaseEmulatorHelper.waitForFirestore();
        await Future.delayed(const Duration(milliseconds: 200));

        // Details page stream should have the update
        expect(groupName, equals('Updated Group Name'));

        await subscription.cancel();
      },
    );

    test(
      'Group members can be fetched for details page',
      () async {
        await createTestUserAndGroup();

        final firestore = FirebaseFirestore.instance;

        // Add another member to the group
        final otherUser = await FirebaseEmulatorHelper.createCompleteTestUser(
          email: 'member@test.com',
          password: 'password123',
          displayName: 'Other Member',
        );

        await firestore.collection('groups').doc(groupId).update({
          'memberIds': FieldValue.arrayUnion([otherUser.uid]),
        });

        // Fetch group for navigation context
        final groupDoc = await firestore.collection('groups').doc(groupId).get();
        final memberIds = List<String>.from(groupDoc.data()?['memberIds'] ?? []);

        expect(memberIds.length, equals(2));
        expect(memberIds, contains(userId));
        expect(memberIds, contains(otherUser.uid));
      },
    );

    test(
      'Group games can be queried for details page',
      () async {
        await createTestUserAndGroup();

        final firestore = FirebaseFirestore.instance;

        // Create games in the group
        await firestore.collection('games').add({
          'title': 'Saturday Game',
          'groupId': groupId,
          'createdBy': userId,
          'scheduledAt': Timestamp.fromDate(DateTime.now().add(const Duration(days: 7))),
          'location': {'name': 'Beach Court'},
          'maxPlayers': 4,
          'minPlayers': 2,
          'playerIds': [userId],
          'status': 'scheduled',
          'createdAt': FieldValue.serverTimestamp(),
        });

        await firestore.collection('games').add({
          'title': 'Sunday Game',
          'groupId': groupId,
          'createdBy': userId,
          'scheduledAt': Timestamp.fromDate(DateTime.now().add(const Duration(days: 8))),
          'location': {'name': 'Park Court'},
          'maxPlayers': 6,
          'minPlayers': 4,
          'playerIds': [userId],
          'status': 'scheduled',
          'createdAt': FieldValue.serverTimestamp(),
        });

        // Query games like GroupDetailsPage would
        final gamesSnapshot = await firestore
            .collection('games')
            .where('groupId', isEqualTo: groupId)
            .where('status', isEqualTo: 'scheduled')
            .get();

        expect(gamesSnapshot.docs.length, equals(2));
      },
    );

    test(
      'Navigating to non-existent group returns null',
      () async {
        await createTestUserAndGroup();

        final firestore = FirebaseFirestore.instance;

        // Try to fetch a non-existent group
        final nonExistentDoc = await firestore
            .collection('groups')
            .doc('non-existent-group-id')
            .get();

        expect(nonExistentDoc.exists, isFalse);
        expect(nonExistentDoc.data(), isNull);
      },
    );
  });
}
