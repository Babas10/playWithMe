// Validates InviteJoinBloc emits correct states for token validation, group joining, and pending invite processing.
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:play_with_me/core/domain/exceptions/repository_exceptions.dart';
import 'package:play_with_me/core/domain/repositories/group_invite_link_repository.dart';
import 'package:play_with_me/core/services/pending_invite_storage.dart';
import 'package:play_with_me/features/invitations/presentation/bloc/invite_join/invite_join_bloc.dart';
import 'package:play_with_me/features/invitations/presentation/bloc/invite_join/invite_join_event.dart';
import 'package:play_with_me/features/invitations/presentation/bloc/invite_join/invite_join_state.dart';

class MockGroupInviteLinkRepository extends Mock
    implements GroupInviteLinkRepository {}

class MockPendingInviteStorage extends Mock implements PendingInviteStorage {}

void main() {
  late MockGroupInviteLinkRepository mockRepo;
  late MockPendingInviteStorage mockStorage;

  setUp(() {
    mockRepo = MockGroupInviteLinkRepository();
    mockStorage = MockPendingInviteStorage();
  });

  InviteJoinBloc buildBloc() {
    return InviteJoinBloc(
      repository: mockRepo,
      pendingInviteStorage: mockStorage,
    );
  }

  const validResult = (
    groupId: 'group-123',
    groupName: 'Beach Volleyball Crew',
    groupDescription: 'A fun group',
    groupPhotoUrl: null,
    groupMemberCount: 12,
    inviterName: 'Etienne',
    inviterPhotoUrl: null,
  );

  const joinResult = (
    groupId: 'group-123',
    groupName: 'Beach Volleyball Crew',
    alreadyMember: false,
  );

  group('InviteJoinBloc', () {
    test('initial state is InviteJoinInitial', () {
      final bloc = buildBloc();
      expect(bloc.state, const InviteJoinInitial());
      bloc.close();
    });

    group('ValidateInviteToken', () {
      blocTest<InviteJoinBloc, InviteJoinState>(
        'emits [validating, validated] on successful validation',
        setUp: () {
          when(() => mockRepo.validateInviteToken(token: 'test-token'))
              .thenAnswer((_) async => validResult);
        },
        build: buildBloc,
        act: (bloc) => bloc.add(const ValidateInviteToken('test-token')),
        expect: () => [
          const InviteJoinValidating(),
          const InviteJoinValidated(
            groupId: 'group-123',
            groupName: 'Beach Volleyball Crew',
            groupDescription: 'A fun group',
            memberCount: 12,
            inviterName: 'Etienne',
            token: 'test-token',
          ),
        ],
      );

      blocTest<InviteJoinBloc, InviteJoinState>(
        'emits [validating, invalidToken] on failed-precondition error',
        setUp: () {
          when(() => mockRepo.validateInviteToken(token: 'expired-token'))
              .thenThrow(GroupInviteLinkException(
            'This invite link has expired.',
            code: 'failed-precondition',
          ));
        },
        build: buildBloc,
        act: (bloc) => bloc.add(const ValidateInviteToken('expired-token')),
        expect: () => [
          const InviteJoinValidating(),
          const InviteJoinInvalidToken(
              reason: 'This invite link has expired.'),
        ],
      );

      blocTest<InviteJoinBloc, InviteJoinState>(
        'emits [validating, error] on other errors',
        setUp: () {
          when(() => mockRepo.validateInviteToken(token: 'bad-token'))
              .thenThrow(GroupInviteLinkException(
            'Resource not found',
            code: 'not-found',
          ));
        },
        build: buildBloc,
        act: (bloc) => bloc.add(const ValidateInviteToken('bad-token')),
        expect: () => [
          const InviteJoinValidating(),
          const InviteJoinError(message: 'Resource not found'),
        ],
      );

      blocTest<InviteJoinBloc, InviteJoinState>(
        'emits [validating, error] on unexpected exception',
        setUp: () {
          when(() => mockRepo.validateInviteToken(token: 'crash-token'))
              .thenThrow(Exception('network error'));
        },
        build: buildBloc,
        act: (bloc) => bloc.add(const ValidateInviteToken('crash-token')),
        expect: () => [
          const InviteJoinValidating(),
          isA<InviteJoinError>(),
        ],
      );
    });

    group('JoinGroupViaInvite', () {
      blocTest<InviteJoinBloc, InviteJoinState>(
        'emits [joining, joined] on successful join',
        setUp: () {
          when(() => mockRepo.joinGroupViaInvite(token: 'test-token'))
              .thenAnswer((_) async => joinResult);
          when(() => mockStorage.clear()).thenAnswer((_) async {});
        },
        build: buildBloc,
        act: (bloc) => bloc.add(const JoinGroupViaInvite('test-token')),
        expect: () => [
          const InviteJoinJoining(),
          const InviteJoinJoined(
            groupId: 'group-123',
            groupName: 'Beach Volleyball Crew',
            alreadyMember: false,
          ),
        ],
        verify: (_) {
          verify(() => mockStorage.clear()).called(1);
        },
      );

      blocTest<InviteJoinBloc, InviteJoinState>(
        'emits [joining, joined] with alreadyMember=true',
        setUp: () {
          when(() => mockRepo.joinGroupViaInvite(token: 'member-token'))
              .thenAnswer((_) async => (
                    groupId: 'group-123',
                    groupName: 'Beach Volleyball Crew',
                    alreadyMember: true,
                  ));
          when(() => mockStorage.clear()).thenAnswer((_) async {});
        },
        build: buildBloc,
        act: (bloc) => bloc.add(const JoinGroupViaInvite('member-token')),
        expect: () => [
          const InviteJoinJoining(),
          const InviteJoinJoined(
            groupId: 'group-123',
            groupName: 'Beach Volleyball Crew',
            alreadyMember: true,
          ),
        ],
      );

      blocTest<InviteJoinBloc, InviteJoinState>(
        'emits [joining, invalidToken] on failed-precondition',
        setUp: () {
          when(() => mockRepo.joinGroupViaInvite(token: 'expired-token'))
              .thenThrow(GroupInviteLinkException(
            'This invite link has expired.',
            code: 'failed-precondition',
          ));
        },
        build: buildBloc,
        act: (bloc) => bloc.add(const JoinGroupViaInvite('expired-token')),
        expect: () => [
          const InviteJoinJoining(),
          const InviteJoinInvalidToken(
              reason: 'This invite link has expired.'),
        ],
      );
    });

    group('ProcessPendingInvite', () {
      blocTest<InviteJoinBloc, InviteJoinState>(
        'emits [validating, validated] when pending token exists and is valid',
        setUp: () {
          when(() => mockStorage.retrieve())
              .thenAnswer((_) async => 'pending-token');
          when(() => mockRepo.validateInviteToken(token: 'pending-token'))
              .thenAnswer((_) async => validResult);
        },
        build: buildBloc,
        act: (bloc) => bloc.add(const ProcessPendingInvite()),
        expect: () => [
          const InviteJoinValidating(),
          const InviteJoinValidated(
            groupId: 'group-123',
            groupName: 'Beach Volleyball Crew',
            groupDescription: 'A fun group',
            memberCount: 12,
            inviterName: 'Etienne',
            token: 'pending-token',
          ),
        ],
      );

      blocTest<InviteJoinBloc, InviteJoinState>(
        'emits nothing when no pending token',
        setUp: () {
          when(() => mockStorage.retrieve())
              .thenAnswer((_) async => null);
        },
        build: buildBloc,
        act: (bloc) => bloc.add(const ProcessPendingInvite()),
        expect: () => [],
      );

      blocTest<InviteJoinBloc, InviteJoinState>(
        'clears storage and emits [validating, invalidToken] when token is invalid',
        setUp: () {
          when(() => mockStorage.retrieve())
              .thenAnswer((_) async => 'bad-token');
          when(() => mockRepo.validateInviteToken(token: 'bad-token'))
              .thenThrow(GroupInviteLinkException(
            'This invite link has been revoked.',
            code: 'failed-precondition',
          ));
          when(() => mockStorage.clear()).thenAnswer((_) async {});
        },
        build: buildBloc,
        act: (bloc) => bloc.add(const ProcessPendingInvite()),
        expect: () => [
          const InviteJoinValidating(),
          const InviteJoinInvalidToken(
              reason: 'This invite link has been revoked.'),
        ],
        verify: (_) {
          verify(() => mockStorage.clear()).called(1);
        },
      );

      blocTest<InviteJoinBloc, InviteJoinState>(
        'clears storage on unexpected error',
        setUp: () {
          when(() => mockStorage.retrieve())
              .thenAnswer((_) async => 'crash-token');
          when(() => mockRepo.validateInviteToken(token: 'crash-token'))
              .thenThrow(Exception('network error'));
          when(() => mockStorage.clear()).thenAnswer((_) async {});
        },
        build: buildBloc,
        act: (bloc) => bloc.add(const ProcessPendingInvite()),
        expect: () => [
          const InviteJoinValidating(),
          isA<InviteJoinError>(),
        ],
        verify: (_) {
          verify(() => mockStorage.clear()).called(1);
        },
      );
    });
  });
}
