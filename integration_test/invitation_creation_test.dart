// Integration test for invitation creation flow
// Tests real Firestore interactions using Firebase Emulator

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

  group('Invitation Creation Flow', () {
    test(
      'Admin can create invitation and it appears in Firestore',
      () async {
        // 1. Create admin user (User A)
        final admin = await FirebaseEmulatorHelper.createCompleteTestUser(
          email: 'admin@test.com',
          password: 'password123',
          displayName: 'Admin User',
        );

        // 2. Create regular user (User B) who will be invited
        final invitee = await FirebaseEmulatorHelper.createCompleteTestUser(
          email: 'invitee@test.com',
          password: 'password123',
          displayName: 'Invitee User',
        );

        // 3. Sign in as admin
        await FirebaseEmulatorHelper.signOut();
        await FirebaseEmulatorHelper.signIn(
          email: 'admin@test.com',
          password: 'password123',
        );

        // 4. Create a group with admin as owner
        final groupId = await FirebaseEmulatorHelper.createTestGroup(
          createdBy: admin.uid,
          name: 'Test Volleyball Group',
          description: 'A group for testing invitations',
        );

        // 5. Create invitation document (simulating InvitationRepository.sendInvitation)
        final invitationRef = FirebaseEmulatorHelper.firestore
            .collection('users')
            .doc(invitee.uid)
            .collection('invitations')
            .doc();

        await invitationRef.set({
          'groupId': groupId,
          'groupName': 'Test Volleyball Group',
          'invitedBy': admin.uid,
          'inviterName': 'Admin User',
          'invitedUserId': invitee.uid,
          'status': 'pending',
          'createdAt': FieldValue.serverTimestamp(),
        });

        await FirebaseEmulatorHelper.waitForFirestore();

        // 6. Verify invitation document exists at correct path
        final invitationDoc = await invitationRef.get();
        expect(invitationDoc.exists, true, reason: 'Invitation document should exist');

        // 7. Verify invitation contains correct fields
        final invitationData = invitationDoc.data()!;
        expect(invitationData['groupId'], groupId);
        expect(invitationData['groupName'], 'Test Volleyball Group');
        expect(invitationData['invitedBy'], admin.uid);
        expect(invitationData['inviterName'], 'Admin User');
        expect(invitationData['invitedUserId'], invitee.uid);
        expect(invitationData['status'], 'pending');
        expect(invitationData['createdAt'], isNotNull);
      },
    );

    test(
      'Non-admin cannot create invitation (security rule enforcement)',
      () async {
        // 1. Create two regular users
        final regularUser = await FirebaseEmulatorHelper.createCompleteTestUser(
          email: 'regular@test.com',
          password: 'password123',
          displayName: 'Regular User',
        );

        final invitee = await FirebaseEmulatorHelper.createCompleteTestUser(
          email: 'invitee@test.com',
          password: 'password123',
          displayName: 'Invitee User',
        );

        // 2. Create admin user and a group
        final admin = await FirebaseEmulatorHelper.createCompleteTestUser(
          email: 'admin@test.com',
          password: 'password123',
          displayName: 'Admin User',
        );

        final groupId = await FirebaseEmulatorHelper.createTestGroup(
          createdBy: admin.uid,
          name: 'Admin Group',
        );

        // 3. Sign in as regular user (NOT admin of the group)
        await FirebaseEmulatorHelper.signOut();
        await FirebaseEmulatorHelper.signIn(
          email: 'regular@test.com',
          password: 'password123',
        );

        // 4. Try to create invitation (should fail due to security rules)
        final invitationRef = FirebaseEmulatorHelper.firestore
            .collection('users')
            .doc(invitee.uid)
            .collection('invitations')
            .doc();

        // Expect permission-denied error
        expect(
          () async => await invitationRef.set({
            'groupId': groupId,
            'groupName': 'Admin Group',
            'invitedBy': regularUser.uid,
            'inviterName': 'Regular User',
            'invitedUserId': invitee.uid,
            'status': 'pending',
            'createdAt': FieldValue.serverTimestamp(),
          }),
          throwsA(
            isA<FirebaseException>().having(
              (e) => e.code,
              'code',
              'permission-denied',
            ),
          ),
        );
      },
    );

    test(
      'Invitation contains all required fields with correct types',
      () async {
        // 1. Create admin and invitee
        final admin = await FirebaseEmulatorHelper.createCompleteTestUser(
          email: 'admin@test.com',
          password: 'password123',
          displayName: 'Admin User',
        );

        final invitee = await FirebaseEmulatorHelper.createCompleteTestUser(
          email: 'invitee@test.com',
          password: 'password123',
          displayName: 'Invitee User',
        );

        await FirebaseEmulatorHelper.signOut();
        await FirebaseEmulatorHelper.signIn(
          email: 'admin@test.com',
          password: 'password123',
        );

        // 2. Create group
        final groupId = await FirebaseEmulatorHelper.createTestGroup(
          createdBy: admin.uid,
          name: 'Test Group',
        );

        // 3. Create invitation
        final invitationRef = FirebaseEmulatorHelper.firestore
            .collection('users')
            .doc(invitee.uid)
            .collection('invitations')
            .doc();

        await invitationRef.set({
          'groupId': groupId,
          'groupName': 'Test Group',
          'invitedBy': admin.uid,
          'inviterName': 'Admin User',
          'invitedUserId': invitee.uid,
          'status': 'pending',
          'createdAt': FieldValue.serverTimestamp(),
        });

        await FirebaseEmulatorHelper.waitForFirestore();

        // 4. Verify field types
        final invitationDoc = await invitationRef.get();
        final data = invitationDoc.data()!;

        expect(data['groupId'], isA<String>());
        expect(data['groupName'], isA<String>());
        expect(data['invitedBy'], isA<String>());
        expect(data['inviterName'], isA<String>());
        expect(data['invitedUserId'], isA<String>());
        expect(data['status'], isA<String>());
        expect(data['createdAt'], isA<Timestamp>());
      },
    );

    test(
      'Multiple invitations can be created for same user from different groups',
      () async {
        // 1. Create users
        final admin = await FirebaseEmulatorHelper.createCompleteTestUser(
          email: 'admin@test.com',
          password: 'password123',
          displayName: 'Admin User',
        );

        final invitee = await FirebaseEmulatorHelper.createCompleteTestUser(
          email: 'invitee@test.com',
          password: 'password123',
          displayName: 'Invitee User',
        );

        await FirebaseEmulatorHelper.signOut();
        await FirebaseEmulatorHelper.signIn(
          email: 'admin@test.com',
          password: 'password123',
        );

        // 2. Create two groups
        final group1Id = await FirebaseEmulatorHelper.createTestGroup(
          createdBy: admin.uid,
          name: 'Group 1',
        );

        final group2Id = await FirebaseEmulatorHelper.createTestGroup(
          createdBy: admin.uid,
          name: 'Group 2',
        );

        // 3. Create invitations from both groups
        final invitation1Ref = FirebaseEmulatorHelper.firestore
            .collection('users')
            .doc(invitee.uid)
            .collection('invitations')
            .doc();

        await invitation1Ref.set({
          'groupId': group1Id,
          'groupName': 'Group 1',
          'invitedBy': admin.uid,
          'inviterName': 'Admin User',
          'invitedUserId': invitee.uid,
          'status': 'pending',
          'createdAt': FieldValue.serverTimestamp(),
        });

        final invitation2Ref = FirebaseEmulatorHelper.firestore
            .collection('users')
            .doc(invitee.uid)
            .collection('invitations')
            .doc();

        await invitation2Ref.set({
          'groupId': group2Id,
          'groupName': 'Group 2',
          'invitedBy': admin.uid,
          'inviterName': 'Admin User',
          'invitedUserId': invitee.uid,
          'status': 'pending',
          'createdAt': FieldValue.serverTimestamp(),
        });

        await FirebaseEmulatorHelper.waitForFirestore();

        // 4. Verify both invitations exist
        final invitationsSnapshot = await FirebaseEmulatorHelper.firestore
            .collection('users')
            .doc(invitee.uid)
            .collection('invitations')
            .where('status', isEqualTo: 'pending')
            .get();

        expect(invitationsSnapshot.docs.length, 2);
      },
    );
  });
}
