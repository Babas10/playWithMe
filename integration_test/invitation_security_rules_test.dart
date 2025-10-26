// Integration test for Firestore security rules validation
// Tests that security rules properly enforce access control

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

  group('Security Rule Validation - Invitation Creation', () {
    test(
      'Non-admin member cannot create invitations',
      () async {
        // 1. Create admin, member, and invitee
        final admin = await FirebaseEmulatorHelper.createCompleteTestUser(
          email: 'admin@test.com',
          password: 'password123',
          displayName: 'Admin User',
        );

        final member = await FirebaseEmulatorHelper.createCompleteTestUser(
          email: 'member@test.com',
          password: 'password123',
          displayName: 'Member User',
        );

        final invitee = await FirebaseEmulatorHelper.createCompleteTestUser(
          email: 'invitee@test.com',
          password: 'password123',
          displayName: 'Invitee User',
        );

        // 2. Create group with admin and add member (not as admin)
        await FirebaseEmulatorHelper.signOut();
        await FirebaseEmulatorHelper.signIn(
          email: 'admin@test.com',
          password: 'password123',
        );

        final groupId = await FirebaseEmulatorHelper.createTestGroup(
          createdBy: admin.uid,
          name: 'Test Group',
          memberIds: [admin.uid, member.uid],
          adminIds: [admin.uid], // Member is NOT admin
        );

        // 3. Sign in as regular member
        await FirebaseEmulatorHelper.signOut();
        await FirebaseEmulatorHelper.signIn(
          email: 'member@test.com',
          password: 'password123',
        );

        // 4. Try to create invitation (should fail)
        final invitationRef = FirebaseEmulatorHelper.firestore
            .collection('users')
            .doc(invitee.uid)
            .collection('invitations')
            .doc();

        expect(
          () async => await invitationRef.set({
            'groupId': groupId,
            'groupName': 'Test Group',
            'invitedBy': member.uid,
            'inviterName': 'Member User',
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
      'Non-group-member cannot create invitations',
      () async {
        // 1. Create users
        final admin = await FirebaseEmulatorHelper.createCompleteTestUser(
          email: 'admin@test.com',
          password: 'password123',
          displayName: 'Admin User',
        );

        final outsider = await FirebaseEmulatorHelper.createCompleteTestUser(
          email: 'outsider@test.com',
          password: 'password123',
          displayName: 'Outsider User',
        );

        final invitee = await FirebaseEmulatorHelper.createCompleteTestUser(
          email: 'invitee@test.com',
          password: 'password123',
          displayName: 'Invitee User',
        );

        // 2. Create group
        await FirebaseEmulatorHelper.signOut();
        await FirebaseEmulatorHelper.signIn(
          email: 'admin@test.com',
          password: 'password123',
        );

        final groupId = await FirebaseEmulatorHelper.createTestGroup(
          createdBy: admin.uid,
          name: 'Private Group',
        );

        // 3. Sign in as outsider (not in group at all)
        await FirebaseEmulatorHelper.signOut();
        await FirebaseEmulatorHelper.signIn(
          email: 'outsider@test.com',
          password: 'password123',
        );

        // 4. Try to create invitation (should fail)
        final invitationRef = FirebaseEmulatorHelper.firestore
            .collection('users')
            .doc(invitee.uid)
            .collection('invitations')
            .doc();

        expect(
          () async => await invitationRef.set({
            'groupId': groupId,
            'groupName': 'Private Group',
            'invitedBy': outsider.uid,
            'inviterName': 'Outsider User',
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
      'Unauthenticated user cannot create invitations',
      () async {
        // 1. Create admin and invitee (but don't sign in)
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

        // 2. Sign out (unauthenticated)
        await FirebaseEmulatorHelper.signOut();

        // 3. Try to create invitation (should fail)
        final invitationRef = FirebaseEmulatorHelper.firestore
            .collection('users')
            .doc(invitee.uid)
            .collection('invitations')
            .doc();

        expect(
          () async => await invitationRef.set({
            'groupId': groupId,
            'groupName': 'Test Group',
            'invitedBy': admin.uid,
            'inviterName': 'Admin User',
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
  });

  group('Security Rule Validation - Invitation Reading', () {
    test(
      'Users cannot read other users invitations',
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

        // 3. Try to read as another user (should fail)
        await FirebaseEmulatorHelper.signOut();
        await FirebaseEmulatorHelper.signIn(
          email: 'other@test.com',
          password: 'password123',
        );

        expect(
          () async => await invitationRef.get(),
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
      'Group admin cannot read invitations they sent',
      () async {
        // This tests that admins can't read the invitation document
        // even though they created it (only invitee can read)

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

        // 2. Create group and invitation as admin
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

        // 3. Try to read as admin (who created it) - should fail
        expect(
          () async => await invitationRef.get(),
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
      'Invited user CAN read their own invitations',
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

        // 3. Read as invited user (should succeed)
        await FirebaseEmulatorHelper.signOut();
        await FirebaseEmulatorHelper.signIn(
          email: 'invitee@test.com',
          password: 'password123',
        );

        final invitationDoc = await invitationRef.get();
        expect(invitationDoc.exists, true);
        expect(invitationDoc.data()!['status'], 'pending');
      },
    );
  });

  group('Security Rule Validation - Invitation Deletion', () {
    test(
      'Invited user can delete their own invitations',
      () async {
        // 1. Create users and invitation
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

        // 2. Delete as invitee (should succeed)
        await FirebaseEmulatorHelper.signOut();
        await FirebaseEmulatorHelper.signIn(
          email: 'invitee@test.com',
          password: 'password123',
        );

        await invitationRef.delete();
        await FirebaseEmulatorHelper.waitForFirestore();

        // 3. Verify deleted
        final invitationDoc = await invitationRef.get();
        expect(invitationDoc.exists, false);
      },
    );

    test(
      'Inviter (admin) can delete invitations they sent',
      () async {
        // 1. Create users and invitation
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

        // 2. Delete as admin/inviter (should succeed)
        await invitationRef.delete();
        await FirebaseEmulatorHelper.waitForFirestore();

        // 3. Verify deleted
        final invitationDoc = await invitationRef.get();
        expect(invitationDoc.exists, false);
      },
    );

    test(
      'Other users cannot delete invitations',
      () async {
        // 1. Create users and invitation
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

        // 2. Try to delete as other user (should fail)
        await FirebaseEmulatorHelper.signOut();
        await FirebaseEmulatorHelper.signIn(
          email: 'other@test.com',
          password: 'password123',
        );

        expect(
          () async => await invitationRef.delete(),
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
  });
}
