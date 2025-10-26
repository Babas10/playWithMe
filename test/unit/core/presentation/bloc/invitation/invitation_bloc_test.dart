// Tests InvitationBloc functionality and validates all invitation operations work correctly.

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:play_with_me/core/presentation/bloc/invitation/invitation_bloc.dart';
import 'package:play_with_me/core/presentation/bloc/invitation/invitation_event.dart';
import 'package:play_with_me/core/presentation/bloc/invitation/invitation_state.dart';
import 'package:play_with_me/core/data/models/invitation_model.dart';

import '../../../data/repositories/mock_invitation_repository.dart';

void main() {
  group('InvitationBloc', () {
    late InvitationBloc invitationBloc;
    late MockInvitationRepository mockInvitationRepository;

    setUp(() {
      mockInvitationRepository = MockInvitationRepository();
      invitationBloc =
          InvitationBloc(invitationRepository: mockInvitationRepository);
    });

    tearDown(() {
      invitationBloc.close();
      mockInvitationRepository.dispose();
    });

    test('initial state is InvitationInitial', () {
      expect(invitationBloc.state, equals(const InvitationInitial()));
    });

    group('SendInvitation', () {
      blocTest<InvitationBloc, InvitationState>(
        'emits InvitationSent when invitation is sent successfully',
        build: () {
          mockInvitationRepository.clearInvitations();
          return invitationBloc;
        },
        act: (bloc) => bloc.add(const SendInvitation(
          groupId: 'group-123',
          groupName: 'Test Group',
          invitedUserId: 'user-456',
          invitedBy: 'user-123',
          inviterName: 'John Doe',
        )),
        expect: () => [
          const InvitationLoading(),
          isA<InvitationSent>(),
        ],
      );

      // Note: Error handling tests would require a mock that can throw exceptions
      // This is better tested in integration tests with real Firestore
    });

    group('LoadPendingInvitations', () {
      final testInvitation1 = InvitationModel(
        id: 'invitation-1',
        groupId: 'group-123',
        groupName: 'Test Group 1',
        invitedUserId: 'user-456',
        invitedBy: 'user-123',
        inviterName: 'John Doe',
        status: InvitationStatus.pending,
        createdAt: DateTime(2024, 1, 1),
      );

      final testInvitation2 = InvitationModel(
        id: 'invitation-2',
        groupId: 'group-789',
        groupName: 'Test Group 2',
        invitedUserId: 'user-456',
        invitedBy: 'user-111',
        inviterName: 'Jane Smith',
        status: InvitationStatus.pending,
        createdAt: DateTime(2024, 1, 2),
      );

      blocTest<InvitationBloc, InvitationState>(
        'emits InvitationsLoaded with pending invitations',
        build: () {
          mockInvitationRepository.addInvitation(testInvitation1);
          mockInvitationRepository.addInvitation(testInvitation2);
          return invitationBloc;
        },
        act: (bloc) =>
            bloc.add(const LoadPendingInvitations(userId: 'user-456')),
        expect: () => [
          isA<InvitationsLoaded>().having(
            (state) => state.invitations.length,
            'invitations count',
            2,
          ),
        ],
      );

      blocTest<InvitationBloc, InvitationState>(
        'emits InvitationsLoaded with empty list when no pending invitations',
        build: () {
          mockInvitationRepository.clearInvitations();
          return invitationBloc;
        },
        act: (bloc) =>
            bloc.add(const LoadPendingInvitations(userId: 'user-456')),
        expect: () => [
          isA<InvitationsLoaded>().having(
            (state) => state.invitations.length,
            'invitations count',
            0,
          ),
        ],
      );
    });

    group('LoadInvitations', () {
      final testInvitation = InvitationModel(
        id: 'invitation-1',
        groupId: 'group-123',
        groupName: 'Test Group',
        invitedUserId: 'user-456',
        invitedBy: 'user-123',
        inviterName: 'John Doe',
        status: InvitationStatus.accepted,
        createdAt: DateTime(2024, 1, 1),
      );

      blocTest<InvitationBloc, InvitationState>(
        'emits InvitationsLoaded with all invitations',
        build: () {
          mockInvitationRepository.addInvitation(testInvitation);
          return invitationBloc;
        },
        act: (bloc) => bloc.add(const LoadInvitations(userId: 'user-456')),
        expect: () => [
          const InvitationLoading(),
          isA<InvitationsLoaded>().having(
            (state) => state.invitations.length,
            'invitations count',
            1,
          ),
        ],
      );
    });

    group('AcceptInvitation', () {
      final testInvitation = InvitationModel(
        id: 'invitation-1',
        groupId: 'group-123',
        groupName: 'Test Group',
        invitedUserId: 'user-456',
        invitedBy: 'user-123',
        inviterName: 'John Doe',
        status: InvitationStatus.pending,
        createdAt: DateTime(2024, 1, 1),
      );

      blocTest<InvitationBloc, InvitationState>(
        'emits InvitationAccepted when acceptance succeeds',
        build: () {
          mockInvitationRepository.addInvitation(testInvitation);
          return invitationBloc;
        },
        act: (bloc) => bloc.add(const AcceptInvitation(
          userId: 'user-456',
          invitationId: 'invitation-1',
        )),
        expect: () => [
          const InvitationLoading(),
          const InvitationAccepted(invitationId: 'invitation-1'),
        ],
      );

      blocTest<InvitationBloc, InvitationState>(
        'emits InvitationError when invitation does not exist',
        build: () {
          mockInvitationRepository.clearInvitations();
          return invitationBloc;
        },
        act: (bloc) => bloc.add(const AcceptInvitation(
          userId: 'user-456',
          invitationId: 'non-existent',
        )),
        expect: () => [
          const InvitationLoading(),
          isA<InvitationError>(),
        ],
      );
    });

    group('DeclineInvitation', () {
      final testInvitation = InvitationModel(
        id: 'invitation-1',
        groupId: 'group-123',
        groupName: 'Test Group',
        invitedUserId: 'user-456',
        invitedBy: 'user-123',
        inviterName: 'John Doe',
        status: InvitationStatus.pending,
        createdAt: DateTime(2024, 1, 1),
      );

      blocTest<InvitationBloc, InvitationState>(
        'emits InvitationDeclined when decline succeeds',
        build: () {
          mockInvitationRepository.addInvitation(testInvitation);
          return invitationBloc;
        },
        act: (bloc) => bloc.add(const DeclineInvitation(
          userId: 'user-456',
          invitationId: 'invitation-1',
        )),
        expect: () => [
          const InvitationLoading(),
          const InvitationDeclined(invitationId: 'invitation-1'),
        ],
      );

      blocTest<InvitationBloc, InvitationState>(
        'emits InvitationError when invitation does not exist',
        build: () {
          mockInvitationRepository.clearInvitations();
          return invitationBloc;
        },
        act: (bloc) => bloc.add(const DeclineInvitation(
          userId: 'user-456',
          invitationId: 'non-existent',
        )),
        expect: () => [
          const InvitationLoading(),
          isA<InvitationError>(),
        ],
      );
    });

    group('DeleteInvitation', () {
      final testInvitation = InvitationModel(
        id: 'invitation-1',
        groupId: 'group-123',
        groupName: 'Test Group',
        invitedUserId: 'user-456',
        invitedBy: 'user-123',
        inviterName: 'John Doe',
        status: InvitationStatus.pending,
        createdAt: DateTime(2024, 1, 1),
      );

      blocTest<InvitationBloc, InvitationState>(
        'emits InvitationDeleted when deletion succeeds',
        build: () {
          mockInvitationRepository.addInvitation(testInvitation);
          return invitationBloc;
        },
        act: (bloc) => bloc.add(const DeleteInvitation(
          userId: 'user-456',
          invitationId: 'invitation-1',
        )),
        expect: () => [
          const InvitationLoading(),
          const InvitationDeleted(invitationId: 'invitation-1'),
        ],
      );
    });
  });
}
