// Tests FirestoreInvitationRepository methods with fake Firestore
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:play_with_me/core/data/models/invitation_model.dart';
import 'package:play_with_me/core/data/repositories/firestore_invitation_repository.dart';
import 'package:play_with_me/core/domain/repositories/group_repository.dart';

class MockGroupRepository extends Mock implements GroupRepository {}

void main() {
  group('FirestoreInvitationRepository', () {
    late FakeFirebaseFirestore fakeFirestore;
    late MockGroupRepository mockGroupRepository;
    late FirestoreInvitationRepository repository;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      mockGroupRepository = MockGroupRepository();
      repository = FirestoreInvitationRepository(
        firestore: fakeFirestore,
        groupRepository: mockGroupRepository,
      );
    });

    group('sendInvitation', () {
      test('creates invitation successfully and returns invitation ID', () async {
        // Act
        final invitationId = await repository.sendInvitation(
          groupId: 'group-123',
          groupName: 'Test Group',
          invitedUserId: 'user-456',
          invitedBy: 'user-123',
          inviterName: 'John Doe',
        );

        // Assert
        expect(invitationId, isNotEmpty);

        // Verify the invitation was created in Firestore
        final doc = await fakeFirestore
            .collection('users')
            .doc('user-456')
            .collection('invitations')
            .doc(invitationId)
            .get();
        expect(doc.exists, true);

        final data = doc.data()!;
        expect(data['groupId'], 'group-123');
        expect(data['groupName'], 'Test Group');
        expect(data['invitedUserId'], 'user-456');
        expect(data['invitedBy'], 'user-123');
        expect(data['inviterName'], 'John Doe');
        expect(data['status'], 'pending');
        expect(data['createdAt'], isA<Timestamp>());
      });

      test('throws exception when user already has pending invitation', () async {
        // Arrange - Create existing pending invitation
        await fakeFirestore
            .collection('users')
            .doc('user-456')
            .collection('invitations')
            .add({
          'groupId': 'group-123',
          'groupName': 'Test Group',
          'invitedUserId': 'user-456',
          'invitedBy': 'user-123',
          'inviterName': 'John Doe',
          'status': 'pending',
          'createdAt': Timestamp.now(),
        });

        // Act & Assert
        expect(
          () => repository.sendInvitation(
            groupId: 'group-123',
            groupName: 'Test Group',
            invitedUserId: 'user-456',
            invitedBy: 'user-123',
            inviterName: 'John Doe',
          ),
          throwsA(isA<Exception>()),
        );
      });

      test('allows sending invitation if previous invitation was declined', () async {
        // Arrange - Create existing declined invitation
        await fakeFirestore
            .collection('users')
            .doc('user-456')
            .collection('invitations')
            .add({
          'groupId': 'group-123',
          'groupName': 'Test Group',
          'invitedUserId': 'user-456',
          'invitedBy': 'user-123',
          'inviterName': 'John Doe',
          'status': 'declined',
          'createdAt': Timestamp.now(),
        });

        // Act
        final invitationId = await repository.sendInvitation(
          groupId: 'group-123',
          groupName: 'Test Group',
          invitedUserId: 'user-456',
          invitedBy: 'user-123',
          inviterName: 'John Doe',
        );

        // Assert
        expect(invitationId, isNotEmpty);
      });
    });

    group('getPendingInvitations', () {
      test('returns stream of pending invitations for user', () async {
        // Arrange
        await fakeFirestore
            .collection('users')
            .doc('user-456')
            .collection('invitations')
            .add({
          'groupId': 'group-123',
          'groupName': 'Test Group 1',
          'invitedUserId': 'user-456',
          'invitedBy': 'user-123',
          'inviterName': 'John Doe',
          'status': 'pending',
          'createdAt': Timestamp.now(),
        });

        await fakeFirestore
            .collection('users')
            .doc('user-456')
            .collection('invitations')
            .add({
          'groupId': 'group-789',
          'groupName': 'Test Group 2',
          'invitedUserId': 'user-456',
          'invitedBy': 'user-111',
          'inviterName': 'Jane Smith',
          'status': 'pending',
          'createdAt': Timestamp.now(),
        });

        // Add a non-pending invitation (should not be included)
        await fakeFirestore
            .collection('users')
            .doc('user-456')
            .collection('invitations')
            .add({
          'groupId': 'group-999',
          'groupName': 'Test Group 3',
          'invitedUserId': 'user-456',
          'invitedBy': 'user-222',
          'inviterName': 'Bob Johnson',
          'status': 'accepted',
          'createdAt': Timestamp.now(),
        });

        // Act
        final stream = repository.getPendingInvitations('user-456');

        // Assert
        await expectLater(
          stream,
          emits(predicate<List<InvitationModel>>((invitations) {
            return invitations.length == 2 &&
                invitations.every((inv) => inv.status == InvitationStatus.pending);
          })),
        );
      });

      test('returns empty stream when user has no pending invitations', () async {
        // Act
        final stream = repository.getPendingInvitations('user-456');

        // Assert
        await expectLater(
          stream,
          emits(predicate<List<InvitationModel>>(
            (invitations) => invitations.isEmpty,
          )),
        );
      });
    });

    group('getInvitations', () {
      test('returns all invitations for user regardless of status', () async {
        // Arrange
        await fakeFirestore
            .collection('users')
            .doc('user-456')
            .collection('invitations')
            .add({
          'groupId': 'group-123',
          'groupName': 'Test Group 1',
          'invitedUserId': 'user-456',
          'invitedBy': 'user-123',
          'inviterName': 'John Doe',
          'status': 'pending',
          'createdAt': Timestamp.now(),
        });

        await fakeFirestore
            .collection('users')
            .doc('user-456')
            .collection('invitations')
            .add({
          'groupId': 'group-789',
          'groupName': 'Test Group 2',
          'invitedUserId': 'user-456',
          'invitedBy': 'user-111',
          'inviterName': 'Jane Smith',
          'status': 'accepted',
          'createdAt': Timestamp.now(),
        });

        await fakeFirestore
            .collection('users')
            .doc('user-456')
            .collection('invitations')
            .add({
          'groupId': 'group-999',
          'groupName': 'Test Group 3',
          'invitedUserId': 'user-456',
          'invitedBy': 'user-222',
          'inviterName': 'Bob Johnson',
          'status': 'declined',
          'createdAt': Timestamp.now(),
        });

        // Act
        final invitations = await repository.getInvitations('user-456');

        // Assert
        expect(invitations, hasLength(3));
        expect(
          invitations.where((i) => i.status == InvitationStatus.pending),
          hasLength(1),
        );
        expect(
          invitations.where((i) => i.status == InvitationStatus.accepted),
          hasLength(1),
        );
        expect(
          invitations.where((i) => i.status == InvitationStatus.declined),
          hasLength(1),
        );
      });

      test('returns empty list when user has no invitations', () async {
        // Act
        final invitations = await repository.getInvitations('user-456');

        // Assert
        expect(invitations, isEmpty);
      });
    });

    group('getInvitationById', () {
      test('returns invitation when it exists', () async {
        // Arrange
        final docRef = await fakeFirestore
            .collection('users')
            .doc('user-456')
            .collection('invitations')
            .add({
          'groupId': 'group-123',
          'groupName': 'Test Group',
          'invitedUserId': 'user-456',
          'invitedBy': 'user-123',
          'inviterName': 'John Doe',
          'status': 'pending',
          'createdAt': Timestamp.now(),
        });

        // Act
        final invitation = await repository.getInvitationById(
          userId: 'user-456',
          invitationId: docRef.id,
        );

        // Assert
        expect(invitation, isNotNull);
        expect(invitation!.id, docRef.id);
        expect(invitation.groupId, 'group-123');
        expect(invitation.groupName, 'Test Group');
        expect(invitation.invitedUserId, 'user-456');
        expect(invitation.status, InvitationStatus.pending);
      });

      test('returns null when invitation does not exist', () async {
        // Act
        final invitation = await repository.getInvitationById(
          userId: 'user-456',
          invitationId: 'non-existent-id',
        );

        // Assert
        expect(invitation, isNull);
      });
    });

    group('acceptInvitation', () {
      test('updates invitation status and adds user to group', () async {
        // Arrange
        final invitationRef = await fakeFirestore
            .collection('users')
            .doc('user-456')
            .collection('invitations')
            .add({
          'groupId': 'group-123',
          'groupName': 'Test Group',
          'invitedUserId': 'user-456',
          'invitedBy': 'user-123',
          'inviterName': 'John Doe',
          'status': 'pending',
          'createdAt': Timestamp.now(),
        });

        // Create the group in Firestore
        await fakeFirestore.collection('groups').doc('group-123').set({
          'name': 'Test Group',
          'createdBy': 'user-123',
          'createdAt': Timestamp.now(),
          'memberIds': ['user-123'],
          'adminIds': ['user-123'],
        });

        // Act
        await repository.acceptInvitation(
          userId: 'user-456',
          invitationId: invitationRef.id,
        );

        // Assert - Check invitation status
        final invitationDoc = await invitationRef.get();
        expect(invitationDoc.data()!['status'], 'accepted');
        expect(invitationDoc.data()!['respondedAt'], isA<Timestamp>());

        // Assert - Check user was added to group
        final groupDoc = await fakeFirestore
            .collection('groups')
            .doc('group-123')
            .get();
        expect(groupDoc.data()!['memberIds'], contains('user-456'));
      });

      test('throws exception when invitation does not exist', () async {
        // Act & Assert
        expect(
          () => repository.acceptInvitation(
            userId: 'user-456',
            invitationId: 'non-existent-id',
          ),
          throwsA(isA<Exception>()),
        );
      });

      test('throws exception when invitation is not pending', () async {
        // Arrange
        final invitationRef = await fakeFirestore
            .collection('users')
            .doc('user-456')
            .collection('invitations')
            .add({
          'groupId': 'group-123',
          'groupName': 'Test Group',
          'invitedUserId': 'user-456',
          'invitedBy': 'user-123',
          'inviterName': 'John Doe',
          'status': 'accepted',
          'createdAt': Timestamp.now(),
        });

        // Act & Assert
        expect(
          () => repository.acceptInvitation(
            userId: 'user-456',
            invitationId: invitationRef.id,
          ),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('declineInvitation', () {
      test('updates invitation status to declined', () async {
        // Arrange
        final invitationRef = await fakeFirestore
            .collection('users')
            .doc('user-456')
            .collection('invitations')
            .add({
          'groupId': 'group-123',
          'groupName': 'Test Group',
          'invitedUserId': 'user-456',
          'invitedBy': 'user-123',
          'inviterName': 'John Doe',
          'status': 'pending',
          'createdAt': Timestamp.now(),
        });

        // Act
        await repository.declineInvitation(
          userId: 'user-456',
          invitationId: invitationRef.id,
        );

        // Assert
        final invitationDoc = await invitationRef.get();
        expect(invitationDoc.data()!['status'], 'declined');
        expect(invitationDoc.data()!['respondedAt'], isA<Timestamp>());
      });

      test('throws exception when invitation does not exist', () async {
        // Act & Assert
        expect(
          () => repository.declineInvitation(
            userId: 'user-456',
            invitationId: 'non-existent-id',
          ),
          throwsA(isA<Exception>()),
        );
      });

      test('throws exception when invitation is not pending', () async {
        // Arrange
        final invitationRef = await fakeFirestore
            .collection('users')
            .doc('user-456')
            .collection('invitations')
            .add({
          'groupId': 'group-123',
          'groupName': 'Test Group',
          'invitedUserId': 'user-456',
          'invitedBy': 'user-123',
          'inviterName': 'John Doe',
          'status': 'declined',
          'createdAt': Timestamp.now(),
        });

        // Act & Assert
        expect(
          () => repository.declineInvitation(
            userId: 'user-456',
            invitationId: invitationRef.id,
          ),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('deleteInvitation', () {
      test('deletes invitation successfully', () async {
        // Arrange
        final invitationRef = await fakeFirestore
            .collection('users')
            .doc('user-456')
            .collection('invitations')
            .add({
          'groupId': 'group-123',
          'groupName': 'Test Group',
          'invitedUserId': 'user-456',
          'invitedBy': 'user-123',
          'inviterName': 'John Doe',
          'status': 'pending',
          'createdAt': Timestamp.now(),
        });

        // Act
        await repository.deleteInvitation(
          userId: 'user-456',
          invitationId: invitationRef.id,
        );

        // Assert
        final invitationDoc = await invitationRef.get();
        expect(invitationDoc.exists, false);
      });

      test('completes without error when invitation does not exist', () async {
        // Act & Assert
        await repository.deleteInvitation(
          userId: 'user-456',
          invitationId: 'non-existent-id',
        );
        // If no exception is thrown, test passes
      });
    });

    group('hasPendingInvitation', () {
      test('returns true when user has pending invitation for group', () async {
        // Arrange
        await fakeFirestore
            .collection('users')
            .doc('user-456')
            .collection('invitations')
            .add({
          'groupId': 'group-123',
          'groupName': 'Test Group',
          'invitedUserId': 'user-456',
          'invitedBy': 'user-123',
          'inviterName': 'John Doe',
          'status': 'pending',
          'createdAt': Timestamp.now(),
        });

        // Act
        final hasPending = await repository.hasPendingInvitation(
          userId: 'user-456',
          groupId: 'group-123',
        );

        // Assert
        expect(hasPending, true);
      });

      test('returns false when user has no pending invitation for group', () async {
        // Act
        final hasPending = await repository.hasPendingInvitation(
          userId: 'user-456',
          groupId: 'group-123',
        );

        // Assert
        expect(hasPending, false);
      });

      test('returns false when invitation exists but is not pending', () async {
        // Arrange
        await fakeFirestore
            .collection('users')
            .doc('user-456')
            .collection('invitations')
            .add({
          'groupId': 'group-123',
          'groupName': 'Test Group',
          'invitedUserId': 'user-456',
          'invitedBy': 'user-123',
          'inviterName': 'John Doe',
          'status': 'accepted',
          'createdAt': Timestamp.now(),
        });

        // Act
        final hasPending = await repository.hasPendingInvitation(
          userId: 'user-456',
          groupId: 'group-123',
        );

        // Assert
        expect(hasPending, false);
      });
    });

    group('cancelInvitation', () {
      test('deletes invitation when canceled', () async {
        // Arrange
        final invitationRef = await fakeFirestore
            .collection('users')
            .doc('user-456')
            .collection('invitations')
            .add({
          'groupId': 'group-123',
          'groupName': 'Test Group',
          'invitedUserId': 'user-456',
          'invitedBy': 'user-123',
          'inviterName': 'John Doe',
          'status': 'pending',
          'createdAt': Timestamp.now(),
        });

        // Act
        await repository.cancelInvitation(
          userId: 'user-456',
          invitationId: invitationRef.id,
        );

        // Assert
        final invitationDoc = await invitationRef.get();
        expect(invitationDoc.exists, false);
      });
    });
  });
}
