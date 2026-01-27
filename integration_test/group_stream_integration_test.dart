// Integration tests for group stream behavior using Firebase Emulator
// Tests real-time updates and stream timing that cannot be tested in unit/widget tests
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

  group('Group Stream Integration Tests', () {
    late String userId;

    Future<void> createTestUser() async {
      final user = await FirebaseEmulatorHelper.createCompleteTestUser(
        email: 'groupstream@test.com',
        password: 'password123',
        displayName: 'Stream Tester',
      );
      userId = user.uid;
    }

    test(
      'Groups stream emits data when group is created',
      () async {
        await createTestUser();

        final firestore = FirebaseFirestore.instance;

        // Set up stream listener before creating group
        final groups = <QueryDocumentSnapshot<Map<String, dynamic>>>[];
        final subscription = firestore
            .collection('groups')
            .where('memberIds', arrayContains: userId)
            .snapshots()
            .listen((snapshot) {
          groups.clear();
          groups.addAll(snapshot.docs);
        });

        // Wait for initial empty state
        await FirebaseEmulatorHelper.waitForFirestore();
        expect(groups, isEmpty);

        // Create a group
        await firestore.collection('groups').add({
          'name': 'Beach Volleyball Crew',
          'description': 'Weekly beach games',
          'createdBy': userId,
          'memberIds': [userId],
          'adminIds': [userId],
          'createdAt': FieldValue.serverTimestamp(),
        });

        // Wait for stream to emit
        await FirebaseEmulatorHelper.waitForFirestore();
        await Future.delayed(const Duration(milliseconds: 200));

        // Verify stream received the group
        expect(groups.length, equals(1));
        expect(groups.first.data()['name'], equals('Beach Volleyball Crew'));

        await subscription.cancel();
      },
    );

    test(
      'Groups stream emits update when group is modified',
      () async {
        await createTestUser();

        final firestore = FirebaseFirestore.instance;

        // Create a group first
        final groupRef = await firestore.collection('groups').add({
          'name': 'Original Name',
          'createdBy': userId,
          'memberIds': [userId],
          'adminIds': [userId],
          'createdAt': FieldValue.serverTimestamp(),
        });

        // Set up stream listener
        String? groupName;
        final subscription = firestore
            .collection('groups')
            .doc(groupRef.id)
            .snapshots()
            .listen((snapshot) {
          groupName = snapshot.data()?['name'] as String?;
        });

        // Wait for initial state
        await FirebaseEmulatorHelper.waitForFirestore();
        await Future.delayed(const Duration(milliseconds: 200));
        expect(groupName, equals('Original Name'));

        // Update the group
        await groupRef.update({'name': 'Updated Name'});

        // Wait for stream to emit update
        await FirebaseEmulatorHelper.waitForFirestore();
        await Future.delayed(const Duration(milliseconds: 200));

        // Verify stream received the update
        expect(groupName, equals('Updated Name'));

        await subscription.cancel();
      },
    );

    test(
      'Groups stream emits when multiple groups are added',
      () async {
        await createTestUser();

        final firestore = FirebaseFirestore.instance;

        // Set up stream listener
        final groups = <QueryDocumentSnapshot<Map<String, dynamic>>>[];
        final subscription = firestore
            .collection('groups')
            .where('memberIds', arrayContains: userId)
            .orderBy('createdAt', descending: true)
            .snapshots()
            .listen((snapshot) {
          groups.clear();
          groups.addAll(snapshot.docs);
        });

        // Create first group
        await firestore.collection('groups').add({
          'name': 'Group A',
          'createdBy': userId,
          'memberIds': [userId],
          'adminIds': [userId],
          'createdAt': FieldValue.serverTimestamp(),
        });

        await FirebaseEmulatorHelper.waitForFirestore();
        await Future.delayed(const Duration(milliseconds: 200));
        expect(groups.length, equals(1));

        // Create second group
        await firestore.collection('groups').add({
          'name': 'Group B',
          'createdBy': userId,
          'memberIds': [userId],
          'adminIds': [userId],
          'createdAt': FieldValue.serverTimestamp(),
        });

        await FirebaseEmulatorHelper.waitForFirestore();
        await Future.delayed(const Duration(milliseconds: 200));
        expect(groups.length, equals(2));

        // Create third group
        await firestore.collection('groups').add({
          'name': 'Group C',
          'createdBy': userId,
          'memberIds': [userId],
          'adminIds': [userId],
          'createdAt': FieldValue.serverTimestamp(),
        });

        await FirebaseEmulatorHelper.waitForFirestore();
        await Future.delayed(const Duration(milliseconds: 200));
        expect(groups.length, equals(3));

        await subscription.cancel();
      },
    );

    test(
      'Groups stream filters by memberIds correctly',
      () async {
        await createTestUser();

        final firestore = FirebaseFirestore.instance;

        // Create a group where user IS a member
        await firestore.collection('groups').add({
          'name': 'My Group',
          'createdBy': userId,
          'memberIds': [userId],
          'adminIds': [userId],
          'createdAt': FieldValue.serverTimestamp(),
        });

        // Create a group where user is NOT a member
        await firestore.collection('groups').add({
          'name': 'Other Group',
          'createdBy': 'other-user-id',
          'memberIds': ['other-user-id'],
          'adminIds': ['other-user-id'],
          'createdAt': FieldValue.serverTimestamp(),
        });

        // Set up stream listener filtered by user membership
        final groups = <QueryDocumentSnapshot<Map<String, dynamic>>>[];
        final subscription = firestore
            .collection('groups')
            .where('memberIds', arrayContains: userId)
            .snapshots()
            .listen((snapshot) {
          groups.clear();
          groups.addAll(snapshot.docs);
        });

        await FirebaseEmulatorHelper.waitForFirestore();
        await Future.delayed(const Duration(milliseconds: 200));

        // Verify only the user's group is in the stream
        expect(groups.length, equals(1));
        expect(groups.first.data()['name'], equals('My Group'));

        await subscription.cancel();
      },
    );

    test(
      'Groups stream handles group deletion',
      () async {
        await createTestUser();

        final firestore = FirebaseFirestore.instance;

        // Create a group
        final groupRef = await firestore.collection('groups').add({
          'name': 'Temporary Group',
          'createdBy': userId,
          'memberIds': [userId],
          'adminIds': [userId],
          'createdAt': FieldValue.serverTimestamp(),
        });

        // Set up stream listener
        final groups = <QueryDocumentSnapshot<Map<String, dynamic>>>[];
        final subscription = firestore
            .collection('groups')
            .where('memberIds', arrayContains: userId)
            .snapshots()
            .listen((snapshot) {
          groups.clear();
          groups.addAll(snapshot.docs);
        });

        await FirebaseEmulatorHelper.waitForFirestore();
        await Future.delayed(const Duration(milliseconds: 200));
        expect(groups.length, equals(1));

        // Delete the group
        await groupRef.delete();

        await FirebaseEmulatorHelper.waitForFirestore();
        await Future.delayed(const Duration(milliseconds: 200));

        // Verify stream reflects deletion
        expect(groups, isEmpty);

        await subscription.cancel();
      },
    );
  });
}
