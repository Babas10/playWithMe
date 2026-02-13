// Tests GroupInviteLinkBloc state transitions for invite generation and revocation.

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:play_with_me/core/domain/exceptions/repository_exceptions.dart';
import 'package:play_with_me/core/domain/repositories/group_invite_link_repository.dart';
import 'package:play_with_me/features/groups/presentation/bloc/group_invite_link/group_invite_link_bloc.dart';
import 'package:play_with_me/features/groups/presentation/bloc/group_invite_link/group_invite_link_event.dart';
import 'package:play_with_me/features/groups/presentation/bloc/group_invite_link/group_invite_link_state.dart';

class MockGroupInviteLinkRepository extends Mock
    implements GroupInviteLinkRepository {}

void main() {
  group('GroupInviteLinkBloc', () {
    late GroupInviteLinkBloc bloc;
    late MockGroupInviteLinkRepository mockRepository;

    setUp(() {
      mockRepository = MockGroupInviteLinkRepository();
      bloc = GroupInviteLinkBloc(repository: mockRepository);
    });

    tearDown(() {
      bloc.close();
    });

    test('initial state is GroupInviteLinkInitial', () {
      expect(bloc.state, equals(const GroupInviteLinkInitial()));
    });

    group('GenerateInvite', () {
      const groupId = 'group-123';
      const inviteId = 'invite-456';
      const token = 'abc123token';
      const deepLinkUrl = 'https://playwithme.app/invite/abc123token';

      blocTest<GroupInviteLinkBloc, GroupInviteLinkState>(
        'emits [loading, generated] when invite is created successfully',
        build: () {
          when(() => mockRepository.createGroupInvite(
                groupId: any(named: 'groupId'),
                expiresInHours: any(named: 'expiresInHours'),
                usageLimit: any(named: 'usageLimit'),
              )).thenAnswer((_) async => (
                inviteId: inviteId,
                token: token,
                deepLinkUrl: deepLinkUrl,
              ));
          return bloc;
        },
        act: (bloc) =>
            bloc.add(const GenerateInvite(groupId: groupId)),
        expect: () => [
          const GroupInviteLinkLoading(),
          const GroupInviteLinkGenerated(
            deepLinkUrl: deepLinkUrl,
            inviteId: inviteId,
          ),
        ],
        verify: (_) {
          verify(() => mockRepository.createGroupInvite(
                groupId: groupId,
                expiresInHours: null,
                usageLimit: null,
              )).called(1);
        },
      );

      blocTest<GroupInviteLinkBloc, GroupInviteLinkState>(
        'passes expiresInHours and usageLimit to repository',
        build: () {
          when(() => mockRepository.createGroupInvite(
                groupId: any(named: 'groupId'),
                expiresInHours: any(named: 'expiresInHours'),
                usageLimit: any(named: 'usageLimit'),
              )).thenAnswer((_) async => (
                inviteId: inviteId,
                token: token,
                deepLinkUrl: deepLinkUrl,
              ));
          return bloc;
        },
        act: (bloc) => bloc.add(const GenerateInvite(
          groupId: groupId,
          expiresInHours: 48,
          usageLimit: 10,
        )),
        expect: () => [
          const GroupInviteLinkLoading(),
          const GroupInviteLinkGenerated(
            deepLinkUrl: deepLinkUrl,
            inviteId: inviteId,
          ),
        ],
        verify: (_) {
          verify(() => mockRepository.createGroupInvite(
                groupId: groupId,
                expiresInHours: 48,
                usageLimit: 10,
              )).called(1);
        },
      );

      blocTest<GroupInviteLinkBloc, GroupInviteLinkState>(
        'emits [loading, error] when repository throws GroupInviteLinkException',
        build: () {
          when(() => mockRepository.createGroupInvite(
                groupId: any(named: 'groupId'),
                expiresInHours: any(named: 'expiresInHours'),
                usageLimit: any(named: 'usageLimit'),
              )).thenThrow(GroupInviteLinkException(
            'You do not have permission to create invite links for this group.',
            code: 'permission-denied',
          ));
          return bloc;
        },
        act: (bloc) =>
            bloc.add(const GenerateInvite(groupId: groupId)),
        expect: () => [
          const GroupInviteLinkLoading(),
          isA<GroupInviteLinkError>()
              .having((e) => e.message, 'message',
                  'You do not have permission to create invite links for this group.')
              .having((e) => e.errorCode, 'errorCode', 'permission-denied')
              .having((e) => e.isRetryable, 'isRetryable', false),
        ],
      );

      blocTest<GroupInviteLinkBloc, GroupInviteLinkState>(
        'emits [loading, error] with retryable flag for internal errors',
        build: () {
          when(() => mockRepository.createGroupInvite(
                groupId: any(named: 'groupId'),
                expiresInHours: any(named: 'expiresInHours'),
                usageLimit: any(named: 'usageLimit'),
              )).thenThrow(GroupInviteLinkException(
            'Failed to create invite link. Please try again later.',
            code: 'internal',
          ));
          return bloc;
        },
        act: (bloc) =>
            bloc.add(const GenerateInvite(groupId: groupId)),
        expect: () => [
          const GroupInviteLinkLoading(),
          isA<GroupInviteLinkError>()
              .having((e) => e.message, 'message',
                  'Failed to create invite link. Please try again later.')
              .having((e) => e.isRetryable, 'isRetryable', true),
        ],
      );

      blocTest<GroupInviteLinkBloc, GroupInviteLinkState>(
        'emits [loading, error] when capacity is reached',
        build: () {
          when(() => mockRepository.createGroupInvite(
                groupId: any(named: 'groupId'),
                expiresInHours: any(named: 'expiresInHours'),
                usageLimit: any(named: 'usageLimit'),
              )).thenThrow(GroupInviteLinkException(
            'This group is at capacity and cannot accept new members.',
            code: 'failed-precondition',
          ));
          return bloc;
        },
        act: (bloc) =>
            bloc.add(const GenerateInvite(groupId: groupId)),
        expect: () => [
          const GroupInviteLinkLoading(),
          isA<GroupInviteLinkError>()
              .having((e) => e.message, 'message',
                  'This group is at capacity and cannot accept new members.')
              .having((e) => e.isRetryable, 'isRetryable', true),
        ],
      );

      blocTest<GroupInviteLinkBloc, GroupInviteLinkState>(
        'emits [loading, error] when unexpected exception occurs',
        build: () {
          when(() => mockRepository.createGroupInvite(
                groupId: any(named: 'groupId'),
                expiresInHours: any(named: 'expiresInHours'),
                usageLimit: any(named: 'usageLimit'),
              )).thenThrow(Exception('Network timeout'));
          return bloc;
        },
        act: (bloc) =>
            bloc.add(const GenerateInvite(groupId: groupId)),
        expect: () => [
          const GroupInviteLinkLoading(),
          isA<GroupInviteLinkError>()
              .having(
                  (e) => e.errorCode, 'errorCode', 'GENERATE_INVITE_ERROR'),
        ],
      );
    });

    group('RevokeInvite', () {
      const groupId = 'group-123';
      const inviteId = 'invite-456';

      blocTest<GroupInviteLinkBloc, GroupInviteLinkState>(
        'emits [loading, revoked] when invite is revoked successfully',
        build: () {
          when(() => mockRepository.revokeGroupInvite(
                groupId: any(named: 'groupId'),
                inviteId: any(named: 'inviteId'),
              )).thenAnswer((_) async {});
          return bloc;
        },
        act: (bloc) => bloc.add(const RevokeInvite(
          groupId: groupId,
          inviteId: inviteId,
        )),
        expect: () => [
          const GroupInviteLinkLoading(),
          const GroupInviteLinkRevoked(),
        ],
        verify: (_) {
          verify(() => mockRepository.revokeGroupInvite(
                groupId: groupId,
                inviteId: inviteId,
              )).called(1);
        },
      );

      blocTest<GroupInviteLinkBloc, GroupInviteLinkState>(
        'emits [loading, error] when revocation fails with permission denied',
        build: () {
          when(() => mockRepository.revokeGroupInvite(
                groupId: any(named: 'groupId'),
                inviteId: any(named: 'inviteId'),
              )).thenThrow(GroupInviteLinkException(
            'You do not have permission to revoke this invite.',
            code: 'permission-denied',
          ));
          return bloc;
        },
        act: (bloc) => bloc.add(const RevokeInvite(
          groupId: groupId,
          inviteId: inviteId,
        )),
        expect: () => [
          const GroupInviteLinkLoading(),
          isA<GroupInviteLinkError>()
              .having((e) => e.message, 'message',
                  'You do not have permission to revoke this invite.')
              .having((e) => e.errorCode, 'errorCode', 'permission-denied')
              .having((e) => e.isRetryable, 'isRetryable', false),
        ],
      );

      blocTest<GroupInviteLinkBloc, GroupInviteLinkState>(
        'emits [loading, error] when invite not found',
        build: () {
          when(() => mockRepository.revokeGroupInvite(
                groupId: any(named: 'groupId'),
                inviteId: any(named: 'inviteId'),
              )).thenThrow(GroupInviteLinkException(
            'The invite does not exist.',
            code: 'not-found',
          ));
          return bloc;
        },
        act: (bloc) => bloc.add(const RevokeInvite(
          groupId: groupId,
          inviteId: inviteId,
        )),
        expect: () => [
          const GroupInviteLinkLoading(),
          isA<GroupInviteLinkError>()
              .having(
                  (e) => e.message, 'message', 'The invite does not exist.')
              .having((e) => e.errorCode, 'errorCode', 'not-found')
              .having((e) => e.isRetryable, 'isRetryable', false),
        ],
      );

      blocTest<GroupInviteLinkBloc, GroupInviteLinkState>(
        'emits [loading, error] when invite already revoked',
        build: () {
          when(() => mockRepository.revokeGroupInvite(
                groupId: any(named: 'groupId'),
                inviteId: any(named: 'inviteId'),
              )).thenThrow(GroupInviteLinkException(
            'This invite is already revoked.',
            code: 'already-exists',
          ));
          return bloc;
        },
        act: (bloc) => bloc.add(const RevokeInvite(
          groupId: groupId,
          inviteId: inviteId,
        )),
        expect: () => [
          const GroupInviteLinkLoading(),
          isA<GroupInviteLinkError>()
              .having((e) => e.message, 'message',
                  'This invite is already revoked.')
              .having((e) => e.errorCode, 'errorCode', 'already-exists')
              .having((e) => e.isRetryable, 'isRetryable', false),
        ],
      );

      blocTest<GroupInviteLinkBloc, GroupInviteLinkState>(
        'emits [loading, error] when unexpected exception occurs',
        build: () {
          when(() => mockRepository.revokeGroupInvite(
                groupId: any(named: 'groupId'),
                inviteId: any(named: 'inviteId'),
              )).thenThrow(Exception('Connection failed'));
          return bloc;
        },
        act: (bloc) => bloc.add(const RevokeInvite(
          groupId: groupId,
          inviteId: inviteId,
        )),
        expect: () => [
          const GroupInviteLinkLoading(),
          isA<GroupInviteLinkError>()
              .having(
                  (e) => e.errorCode, 'errorCode', 'REVOKE_INVITE_ERROR'),
        ],
      );
    });

    group('Event equality', () {
      test('GenerateInvite events with same props are equal', () {
        const event1 = GenerateInvite(groupId: 'group-1');
        const event2 = GenerateInvite(groupId: 'group-1');
        expect(event1, equals(event2));
      });

      test('GenerateInvite events with different props are not equal', () {
        const event1 = GenerateInvite(groupId: 'group-1');
        const event2 = GenerateInvite(groupId: 'group-2');
        expect(event1, isNot(equals(event2)));
      });

      test('RevokeInvite events with same props are equal', () {
        const event1 =
            RevokeInvite(groupId: 'group-1', inviteId: 'invite-1');
        const event2 =
            RevokeInvite(groupId: 'group-1', inviteId: 'invite-1');
        expect(event1, equals(event2));
      });

      test('RevokeInvite events with different props are not equal', () {
        const event1 =
            RevokeInvite(groupId: 'group-1', inviteId: 'invite-1');
        const event2 =
            RevokeInvite(groupId: 'group-1', inviteId: 'invite-2');
        expect(event1, isNot(equals(event2)));
      });
    });

    group('State equality', () {
      test('GroupInviteLinkGenerated states with same props are equal', () {
        const state1 = GroupInviteLinkGenerated(
          deepLinkUrl: 'https://example.com/invite/abc',
          inviteId: 'invite-1',
        );
        const state2 = GroupInviteLinkGenerated(
          deepLinkUrl: 'https://example.com/invite/abc',
          inviteId: 'invite-1',
        );
        expect(state1, equals(state2));
      });

      test('GroupInviteLinkError states with same props are equal', () {
        const state1 = GroupInviteLinkError(
          message: 'Error',
          errorCode: 'ERR',
          isRetryable: false,
        );
        const state2 = GroupInviteLinkError(
          message: 'Error',
          errorCode: 'ERR',
          isRetryable: false,
        );
        expect(state1, equals(state2));
      });
    });
  });
}
