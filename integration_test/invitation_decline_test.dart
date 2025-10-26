// Integration test for invitation decline flow
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

  group('Invitation Decline Flow', () {
    test(
      'User can decline invitation and status updates correctly',
      () async {
        // 1. Create admin and invitee users
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

        // 2. Sign in as admin and create group
        await FirebaseEmulatorHelper.signOut();
        await FirebaseEmulatorHelper.signIn(
          email: 'admin@test.com',
          password: 'password123',
        );

        final groupId = await FirebaseEmulatorHelper.createTestGroup(
          createdBy: admin.uid,
          name: 'Volleyball Group',
        );

        // 3. Create invitation
        final invitationRef = FirebaseEmulatorHelper.firestore
            .collection('users')
            .doc(invitee.uid)
            .collection('invitations')
            .doc();

        await invitationRef.set({
          'groupId': groupId,
          'groupName': 'Volleyball Group',
          'invitedBy': admin.uid,
          'inviterName': 'Admin User',
          'invitedUserId': invitee.uid,
          'status': 'pending',
          'createdAt': FieldValue.serverTimestamp(),
        });

        await FirebaseEmulatorHelper.waitForFirestore();

        // 4. Sign in as invitee and decline
        await FirebaseEmulatorHelper.signOut();
        await FirebaseEmulatorHelper.signIn(
          email: 'invitee@test.com',
          password: 'password123',
        );

        await invitationRef.update({
          'status': 'declined',
          'respondedAt': FieldValue.serverTimestamp(),
        });

        await FirebaseEmulatorHelper.waitForFirestore();

        // 5. Verify invitation status updated
        final invitationDoc = await invitationRef.get();
        final invitationData = invitationDoc.data()!;
        expect(invitationData['status'], 'declined');
        expect(invitationData['respondedAt'], isNotNull);

        // 6. Verify user NOT added to group members
        final groupRef = FirebaseEmulatorHelper.firestore
            .collection('groups')
            .doc(groupId);
        final groupDoc = await groupRef.get();
        final groupData = groupDoc.data()!;
        final memberIds = List<String>.from(groupData['memberIds']);
        expect(memberIds, isNot(contains(invitee.uid)));
        expect(memberIds.length, 1); // Only admin
      },
    );

    test(
      'Declined invitation removes from pending queries',
      () async {
        // 1. Create users and group
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

        final groupId = await FirebaseEmulatorHelper.createTestGroup(
          createdBy: admin.uid,
          name: 'Test Group',
        );

        // 2. Create invitation
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

        // 3. Verify it appears in pending invitations
        final pendingBefore = await FirebaseEmulatorHelper.firestore
            .collection('users')
            .doc(invitee.uid)
            .collection('invitations')
            .where('status', isEqualTo: 'pending')
            .get();

        expect(pendingBefore.docs.length, 1);

        // 4. Decline invitation
        await FirebaseEmulatorHelper.signOut();
        await FirebaseEmulatorHelper.signIn(
          email: 'invitee@test.com',
          password: 'password123',
        );

        await invitationRef.update({
          'status': 'declined',
          'respondedAt': FieldValue.serverTimestamp(),
        });

        await FirebaseEmulatorHelper.waitForFirestore();

        // 5. Verify it no longer appears in pending invitations
        final pendingAfter = await FirebaseEmulatorHelper.firestore
            .collection('users')
            .doc(invitee.uid)
            .collection('invitations')
            .where('status', isEqualTo: 'pending')
            .get();

        expect(pendingAfter.docs.length, 0);

        // 6. Verify it appears in declined invitations
        final declined = await FirebaseEmulatorHelper.firestore
            .collection('users')
            .doc(invitee.uid)
            .collection('invitations')
            .where('status', isEqualTo: 'declined')
            .get();

        expect(declined.docs.length, 1);
      },
    );

    test(
      'User can decline multiple invitations independently',
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

        // 3. Create two invitations
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

        // 4. Sign in as invitee and decline first invitation
        await FirebaseEmulatorHelper.signOut();
        await FirebaseEmulatorHelper.signIn(
          email: 'invitee@test.com',
          password: 'password123',
        );

        await invitation1Ref.update({
          'status': 'declined',
          'respondedAt': FieldValue.serverTimestamp(),
        });

        await FirebaseEmulatorHelper.waitForFirestore();

        // 5. Verify first invitation declined, second still pending
        final invitation1Doc = await invitation1Ref.get();
        expect(invitation1Doc.data()!['status'], 'declined');

        final invitation2Doc = await invitation2Ref.get();
        expect(invitation2Doc.data()!['status'], 'pending');

        // 6. Verify pending count is 1
        final pending = await FirebaseEmulatorHelper.firestore
            .collection('users')
            .doc(invitee.uid)
            .collection('invitations')
            .where('status', isEqualTo: 'pending')
            .get();

        expect(pending.docs.length, 1);
      },
    );

    test(
      'Only invited user can decline their invitation',
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

        final otherUser = await FirebaseEmulatorHelper.createCompleteTestUser(
          email: 'other@test.com',
          password: 'password123',
          displayName: 'Other User',
        );

        // 2. Create group and invitation
        await FirebaseEmulatorHelper.signOut();
        await FirebaseEmulatorHelper.signIn(
          email: 'admin@test.com',
          password: 'password123',
        );

        final groupId = await FirebaseEmulatorHelper.createTestGroup(
          createdBy: admin.uid,
          name: 'Test Group',
        );

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

        // 3. Try to decline as another user (should fail)
        await FirebaseEmulatorHelper.signOut();
        await FirebaseEmulatorHelper.signIn(
          email: 'other@test.com',
          password: 'password123',
        );

        // Should throw permission-denied
        expect(
          () async => await invitationRef.update({
            'status': 'declined',
            'respondedAt': FieldValue.serverTimestamp(),
          }),
          throwsA(
            isA<FirebaseException>().having(
              (e) => e.code,
              'code',
              'permission-denied',
            ),
          ),
        );

        // 4. Verify invitation still pending
        await FirebaseEmulatorHelper.signOut();
        await FirebaseEmulatorHelper.signIn(
          email: 'invitee@test.com',
          password: 'password123',
        );

        final invitationDoc = await invitationRef.get();
        expect(invitationDoc.data()!['status'], 'pending');
      },
    );

    test(
      'User cannot set invalid status when declining',
      () async {
        // 1. Create users and group
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

        final groupId = await FirebaseEmulatorHelper.createTestGroup(
          createdBy: admin.uid,
          name: 'Test Group',
        );

        // 2. Create invitation
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

        // 3. Sign in as invitee and try invalid status
        await FirebaseEmulatorHelper.signOut();
        await FirebaseEmulatorHelper.signIn(
          email: 'invitee@test.com',
          password: 'password123',
        );

        // Try to set invalid status (should fail)
        expect(
          () async => await invitationRef.update({
            'status': 'invalid_status',
            'respondedAt': FieldValue.serverTimestamp(),
          }),
          throwsA(
            isA<FirebaseException>().having(
              (e) => e.code,
              'code',
              'permission-denied',
            ),
          ),
        );

        // Verify invitation still pending
        final invitationDoc = await invitationRef.get();
        expect(invitationDoc.data()!['status'], 'pending');
      },
    );
  });
}
