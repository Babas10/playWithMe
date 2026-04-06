// Unit tests for GameInvitationsBloc (Story 28.7).
// Validates load, accept, and decline flows with mocked repository.

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:play_with_me/core/data/models/game_invitation_details.dart';
import 'package:play_with_me/core/domain/exceptions/repository_exceptions.dart';
import 'package:play_with_me/core/domain/repositories/game_invitations_repository.dart';
import 'package:play_with_me/features/games/presentation/bloc/game_invitations/game_invitations_bloc.dart';

class MockGameInvitationsRepository extends Mock
    implements GameInvitationsRepository {}

// ── Helpers ───────────────────────────────────────────────────────────────────

GameInvitationDetails _makeInvitation({String id = 'inv-1'}) =>
    GameInvitationDetails(
      invitationId: id,
      gameId: 'game-1',
      groupId: 'group-abc',
      inviterId: 'user-bob',
      status: 'pending',
      createdAt: DateTime(2026, 6, 1),
      expiresAt: null,
      gameTitle: 'Sunday Game',
      gameScheduledAt: DateTime(2026, 7, 1, 14),
      gameLocationName: 'Beach Court',
      groupName: 'Beach Crew',
      inviterDisplayName: 'Bob',
    );

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  late MockGameInvitationsRepository mockRepo;

  setUp(() {
    mockRepo = MockGameInvitationsRepository();
  });

  group('LoadGameInvitations', () {
    blocTest<GameInvitationsBloc, GameInvitationsState>(
      'emits [Loading, Loaded] with invitations on success',
      build: () {
        when(() => mockRepo.getGameInvitations())
            .thenAnswer((_) async => [_makeInvitation()]);
        return GameInvitationsBloc(repository: mockRepo);
      },
      act: (bloc) => bloc.add(const LoadGameInvitations()),
      expect: () => [
        isA<GameInvitationsLoading>(),
        isA<GameInvitationsLoaded>()
            .having((s) => s.invitations, 'invitations', hasLength(1)),
      ],
    );

    blocTest<GameInvitationsBloc, GameInvitationsState>(
      'emits [Loading, Loaded(empty)] when no invitations',
      build: () {
        when(() => mockRepo.getGameInvitations()).thenAnswer((_) async => []);
        return GameInvitationsBloc(repository: mockRepo);
      },
      act: (bloc) => bloc.add(const LoadGameInvitations()),
      expect: () => [
        isA<GameInvitationsLoading>(),
        isA<GameInvitationsLoaded>()
            .having((s) => s.invitations, 'invitations', isEmpty),
      ],
    );

    blocTest<GameInvitationsBloc, GameInvitationsState>(
      'emits [Loading, Error] on GameInvitationException',
      build: () {
        when(() => mockRepo.getGameInvitations())
            .thenThrow(GameInvitationException('CF error', code: 'internal'));
        return GameInvitationsBloc(repository: mockRepo);
      },
      act: (bloc) => bloc.add(const LoadGameInvitations()),
      expect: () => [
        isA<GameInvitationsLoading>(),
        isA<GameInvitationsError>()
            .having((s) => s.message, 'message', 'CF error'),
      ],
    );

    blocTest<GameInvitationsBloc, GameInvitationsState>(
      'emits [Loading, Error] on unexpected exception',
      build: () {
        when(() => mockRepo.getGameInvitations())
            .thenThrow(Exception('network failure'));
        return GameInvitationsBloc(repository: mockRepo);
      },
      act: (bloc) => bloc.add(const LoadGameInvitations()),
      expect: () => [
        isA<GameInvitationsLoading>(),
        isA<GameInvitationsError>(),
      ],
    );
  });

  group('AcceptGameInvitation', () {
    final inv = _makeInvitation();

    blocTest<GameInvitationsBloc, GameInvitationsState>(
      'emits [InFlight, ActionSuccess(accepted)] and removes invitation from list',
      build: () {
        when(() => mockRepo.getGameInvitations()).thenAnswer((_) async => [inv]);
        when(() => mockRepo.acceptGameInvitation('inv-1'))
            .thenAnswer((_) async {});
        return GameInvitationsBloc(repository: mockRepo);
      },
      seed: () => GameInvitationsLoaded([inv]),
      act: (bloc) => bloc.add(const AcceptGameInvitation('inv-1')),
      expect: () => [
        isA<GameInvitationActionInFlight>()
            .having((s) => s.processingInvitationId, 'processingId', 'inv-1'),
        isA<GameInvitationActionSuccess>()
            .having((s) => s.accepted, 'accepted', true)
            .having((s) => s.invitations, 'invitations', isEmpty)
            .having((s) => s.gameId, 'gameId', 'game-1'),
      ],
    );

    blocTest<GameInvitationsBloc, GameInvitationsState>(
      'emits [InFlight, ActionError] and preserves list on GameInvitationException',
      build: () {
        when(() => mockRepo.acceptGameInvitation('inv-1')).thenThrow(
            GameInvitationException('game full', code: 'failed-precondition'));
        return GameInvitationsBloc(repository: mockRepo);
      },
      seed: () => GameInvitationsLoaded([inv]),
      act: (bloc) => bloc.add(const AcceptGameInvitation('inv-1')),
      expect: () => [
        isA<GameInvitationActionInFlight>(),
        isA<GameInvitationActionError>()
            .having((s) => s.message, 'message', 'game full')
            .having((s) => s.invitations, 'invitations', [inv]),
      ],
    );
  });

  group('DeclineGameInvitation', () {
    final inv = _makeInvitation();

    blocTest<GameInvitationsBloc, GameInvitationsState>(
      'emits [InFlight, ActionSuccess(declined)] and removes invitation from list',
      build: () {
        when(() => mockRepo.declineGameInvitation('inv-1'))
            .thenAnswer((_) async {});
        return GameInvitationsBloc(repository: mockRepo);
      },
      seed: () => GameInvitationsLoaded([inv]),
      act: (bloc) => bloc.add(const DeclineGameInvitation('inv-1')),
      expect: () => [
        isA<GameInvitationActionInFlight>()
            .having((s) => s.processingInvitationId, 'processingId', 'inv-1'),
        isA<GameInvitationActionSuccess>()
            .having((s) => s.accepted, 'accepted', false)
            .having((s) => s.invitations, 'invitations', isEmpty),
      ],
    );

    blocTest<GameInvitationsBloc, GameInvitationsState>(
      'does nothing when state carries no invitation list',
      build: () {
        return GameInvitationsBloc(repository: mockRepo);
      },
      // initial state is GameInvitationsInitial — no list to act on
      act: (bloc) => bloc.add(const DeclineGameInvitation('inv-1')),
      expect: () => [],
    );
  });
}
