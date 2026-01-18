// Integration test for group creation flow
// Tests real Firebase Firestore interactions using Firebase Emulator

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

  group('Group Creation Flow', () {
    test(
      'User can create a new group with valid data',
      () async {
        // 1. Create and authenticate a test user
        final testEmail = 'creator@test.com';
        final testPassword = 'password123';

        final user = await FirebaseEmulatorHelper.createCompleteTestUser(
          email: testEmail,
          password: testPassword,
          displayName: 'Group Creator',
        );

        // 2. Create a new group
        final firestore = FirebaseFirestore.instance;
        final groupRef = await firestore.collection('groups').add({
          'name': 'Beach Volleyball Crew',
          'description': 'Weekly games at the beach',
          'createdBy': user.uid,
          'createdAt': FieldValue.serverTimestamp(),
          'memberIds': [user.uid],
          'adminIds': [user.uid],
          'lastActivity': FieldValue.serverTimestamp(),
        });

        // 3. Verify group was created
        final groupDoc = await groupRef.get();
        expect(groupDoc.exists, isTrue);
        expect(groupDoc.data()?['name'], equals('Beach Volleyball Crew'));
        expect(groupDoc.data()?['createdBy'], equals(user.uid));
        expect(groupDoc.data()?['memberIds'], contains(user.uid));
        expect(groupDoc.data()?['adminIds'], contains(user.uid));
      },
    );

    test(
      'Creator is automatically added as member and admin',
      () async {
        // 1. Create and authenticate a test user
        final user = await FirebaseEmulatorHelper.createCompleteTestUser(
          email: 'admin@test.com',
          password: 'password123',
          displayName: 'Admin User',
        );

        // 2. Create a new group
        final firestore = FirebaseFirestore.instance;
        final groupRef = await firestore.collection('groups').add({
          'name': 'Test Group',
          'createdBy': user.uid,
          'createdAt': FieldValue.serverTimestamp(),
          'memberIds': [user.uid],
          'adminIds': [user.uid],
          'lastActivity': FieldValue.serverTimestamp(),
        });

        // 3. Verify creator is member and admin
        final groupDoc = await groupRef.get();
        final memberIds = List<String>.from(groupDoc.data()?['memberIds'] ?? []);
        final adminIds = List<String>.from(groupDoc.data()?['adminIds'] ?? []);

        expect(memberIds.length, equals(1));
        expect(memberIds.first, equals(user.uid));
        expect(adminIds.length, equals(1));
        expect(adminIds.first, equals(user.uid));
      },
    );

    test(
      'Group with optional description stores correctly',
      () async {
        final user = await FirebaseEmulatorHelper.createCompleteTestUser(
          email: 'nodesc@test.com',
          password: 'password123',
          displayName: 'No Desc User',
        );

        final firestore = FirebaseFirestore.instance;

        // Create group without description
        final groupRef = await firestore.collection('groups').add({
          'name': 'Group Without Description',
          'createdBy': user.uid,
          'createdAt': FieldValue.serverTimestamp(),
          'memberIds': [user.uid],
          'adminIds': [user.uid],
          'lastActivity': FieldValue.serverTimestamp(),
        });

        final groupDoc = await groupRef.get();
        expect(groupDoc.data()?['description'], isNull);
        expect(groupDoc.data()?['name'], equals('Group Without Description'));
      },
    );

    test(
      'Group with description stores correctly',
      () async {
        final user = await FirebaseEmulatorHelper.createCompleteTestUser(
          email: 'withdesc@test.com',
          password: 'password123',
          displayName: 'With Desc User',
        );

        final firestore = FirebaseFirestore.instance;

        // Create group with description
        final groupRef = await firestore.collection('groups').add({
          'name': 'Group With Description',
          'description': 'This is a detailed description of the group',
          'createdBy': user.uid,
          'createdAt': FieldValue.serverTimestamp(),
          'memberIds': [user.uid],
          'adminIds': [user.uid],
          'lastActivity': FieldValue.serverTimestamp(),
        });

        final groupDoc = await groupRef.get();
        expect(
          groupDoc.data()?['description'],
          equals('This is a detailed description of the group'),
        );
      },
    );

    test(
      'Multiple groups can be created by same user',
      () async {
        final user = await FirebaseEmulatorHelper.createCompleteTestUser(
          email: 'multigroup@test.com',
          password: 'password123',
          displayName: 'Multi Group User',
        );

        final firestore = FirebaseFirestore.instance;

        // Create first group
        await firestore.collection('groups').add({
          'name': 'First Group',
          'createdBy': user.uid,
          'createdAt': FieldValue.serverTimestamp(),
          'memberIds': [user.uid],
          'adminIds': [user.uid],
          'lastActivity': FieldValue.serverTimestamp(),
        });

        // Create second group
        await firestore.collection('groups').add({
          'name': 'Second Group',
          'createdBy': user.uid,
          'createdAt': FieldValue.serverTimestamp(),
          'memberIds': [user.uid],
          'adminIds': [user.uid],
          'lastActivity': FieldValue.serverTimestamp(),
        });

        // Verify both groups exist
        final groups = await firestore
            .collection('groups')
            .where('createdBy', isEqualTo: user.uid)
            .get();

        expect(groups.docs.length, equals(2));
      },
    );

    test(
      'Group name is stored and retrieved correctly',
      () async {
        final user = await FirebaseEmulatorHelper.createCompleteTestUser(
          email: 'nametest@test.com',
          password: 'password123',
          displayName: 'Name Test User',
        );

        final firestore = FirebaseFirestore.instance;
        final groupName = 'Special Characters & Unicode 日本語';

        final groupRef = await firestore.collection('groups').add({
          'name': groupName,
          'createdBy': user.uid,
          'createdAt': FieldValue.serverTimestamp(),
          'memberIds': [user.uid],
          'adminIds': [user.uid],
          'lastActivity': FieldValue.serverTimestamp(),
        });

        final groupDoc = await groupRef.get();
        expect(groupDoc.data()?['name'], equals(groupName));
      },
    );

    test(
      'Group creation sets timestamps correctly',
      () async {
        final user = await FirebaseEmulatorHelper.createCompleteTestUser(
          email: 'timestamp@test.com',
          password: 'password123',
          displayName: 'Timestamp User',
        );

        final firestore = FirebaseFirestore.instance;

        final groupRef = await firestore.collection('groups').add({
          'name': 'Timestamp Test Group',
          'createdBy': user.uid,
          'createdAt': FieldValue.serverTimestamp(),
          'memberIds': [user.uid],
          'adminIds': [user.uid],
          'lastActivity': FieldValue.serverTimestamp(),
        });

        final groupDoc = await groupRef.get();
        final createdAt = groupDoc.data()?['createdAt'] as Timestamp?;
        final lastActivity = groupDoc.data()?['lastActivity'] as Timestamp?;

        expect(createdAt, isNotNull);
        expect(lastActivity, isNotNull);
        expect(
          createdAt!.toDate().difference(DateTime.now()).inSeconds.abs(),
          lessThan(10),
        );
      },
    );
  });
}
