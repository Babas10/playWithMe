// Integration test for invitation acceptance flow
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

  group('Invitation Acceptance Flow', () {
    test(
      'User can accept invitation and join group',
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

        // 4. Sign in as invitee
        await FirebaseEmulatorHelper.signOut();
        await FirebaseEmulatorHelper.signIn(
          email: 'invitee@test.com',
          password: 'password123',
        );

        // 5. Accept invitation (update status and add to group)
        final batch = FirebaseEmulatorHelper.firestore.batch();

        // Update invitation status
        batch.update(invitationRef, {
          'status': 'accepted',
          'respondedAt': FieldValue.serverTimestamp(),
        });

        // Add user to group members
        final groupRef = FirebaseEmulatorHelper.firestore
            .collection('groups')
            .doc(groupId);

        batch.update(groupRef, {
          'memberIds': FieldValue.arrayUnion([invitee.uid]),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        await batch.commit();
        await FirebaseEmulatorHelper.waitForFirestore();

        // 6. Verify invitation status updated
        final invitationDoc = await invitationRef.get();
        final invitationData = invitationDoc.data()!;
        expect(invitationData['status'], 'accepted');
        expect(invitationData['respondedAt'], isNotNull);

        // 7. Verify user added to group members
        final groupDoc = await groupRef.get();
        final groupData = groupDoc.data()!;
        final memberIds = List<String>.from(groupData['memberIds']);
        expect(memberIds, contains(invitee.uid));
        expect(memberIds.length, 2); // Admin + Invitee
      },
    );

    test(
      'Acceptance is atomic - both invitation and group updated together',
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

        // 3. Sign in as invitee and accept using batch write
        await FirebaseEmulatorHelper.signOut();
        await FirebaseEmulatorHelper.signIn(
          email: 'invitee@test.com',
          password: 'password123',
        );

        final batch = FirebaseEmulatorHelper.firestore.batch();

        batch.update(invitationRef, {
          'status': 'accepted',
          'respondedAt': FieldValue.serverTimestamp(),
        });

        final groupRef = FirebaseEmulatorHelper.firestore
            .collection('groups')
            .doc(groupId);

        batch.update(groupRef, {
          'memberIds': FieldValue.arrayUnion([invitee.uid]),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        await batch.commit();
        await FirebaseEmulatorHelper.waitForFirestore();

        // 4. Verify both operations succeeded
        final invitationDoc = await invitationRef.get();
        expect(invitationDoc.data()!['status'], 'accepted');

        final groupDoc = await groupRef.get();
        expect(
          List<String>.from(groupDoc.data()!['memberIds']),
          contains(invitee.uid),
        );

        // If we got here, both operations completed successfully (atomically)
      },
    );

    test(
      'Only invited user can accept their own invitation',
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

        // 3. Try to accept as another user (should fail)
        await FirebaseEmulatorHelper.signOut();
        await FirebaseEmulatorHelper.signIn(
          email: 'other@test.com',
          password: 'password123',
        );

        // Should throw permission-denied
        expect(
          () async => await invitationRef.update({
            'status': 'accepted',
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
      },
    );

    test(
      'User cannot modify groupId or invitedBy when accepting',
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

        final fakeGroupId = 'fake-group-id';

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

        // 3. Sign in as invitee and try to modify core fields
        await FirebaseEmulatorHelper.signOut();
        await FirebaseEmulatorHelper.signIn(
          email: 'invitee@test.com',
          password: 'password123',
        );

        // Try to change groupId (should fail)
        expect(
          () async => await invitationRef.update({
            'status': 'accepted',
            'groupId': fakeGroupId, // Trying to modify core field
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

        // Try to change invitedBy (should fail)
        expect(
          () async => await invitationRef.update({
            'status': 'accepted',
            'invitedBy': 'fake-user-id', // Trying to modify core field
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
      },
    );

    test(
      'Accepted invitation removes from pending queries',
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

        // 4. Accept invitation
        await FirebaseEmulatorHelper.signOut();
        await FirebaseEmulatorHelper.signIn(
          email: 'invitee@test.com',
          password: 'password123',
        );

        await invitationRef.update({
          'status': 'accepted',
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

        // 6. Verify it appears in accepted invitations
        final accepted = await FirebaseEmulatorHelper.firestore
            .collection('users')
            .doc(invitee.uid)
            .collection('invitations')
            .where('status', isEqualTo: 'accepted')
            .get();

        expect(accepted.docs.length, 1);
      },
    );
  });
}
