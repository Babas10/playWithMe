// Validates GameGuestInvitationBloc state transitions for load and invite flows (Story 28.6).
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:play_with_me/core/data/models/invitable_player_model.dart';
import 'package:play_with_me/core/domain/exceptions/repository_exceptions.dart';
import 'package:play_with_me/core/domain/repositories/game_guest_invitation_repository.dart';
import 'package:play_with_me/features/games/presentation/bloc/game_guest_invitation/game_guest_invitation_bloc.dart';
import 'package:play_with_me/features/games/presentation/bloc/game_guest_invitation/game_guest_invitation_event.dart';
import 'package:play_with_me/features/games/presentation/bloc/game_guest_invitation/game_guest_invitation_state.dart';

class MockGameGuestInvitationRepository extends Mock
    implements GameGuestInvitationRepository {}

final _player = InvitablePlayerModel(
  uid: 'player-1',
  displayName: 'Alice',
  sourceGroupId: 'group-x',
  sourceGroupName: 'Beach Crew',
);

void main() {
  late MockGameGuestInvitationRepository mockRepo;

  setUp(() {
    mockRepo = MockGameGuestInvitationRepository();
  });

  group('LoadInvitablePlayers', () {
    blocTest<GameGuestInvitationBloc, GameGuestInvitationState>(
      'emits [loading, loaded] on success',
      build: () {
        when(() => mockRepo.getInvitablePlayers('game-1'))
            .thenAnswer((_) async => [_player]);
        return GameGuestInvitationBloc(repository: mockRepo);
      },
      act: (bloc) => bloc.add(const LoadInvitablePlayers(gameId: 'game-1')),
      expect: () => [
        const InvitablePlayersLoading(),
        InvitablePlayersLoaded(players: [_player]),
      ],
    );

    blocTest<GameGuestInvitationBloc, GameGuestInvitationState>(
      'emits [loading, loaded(empty)] when no players available',
      build: () {
        when(() => mockRepo.getInvitablePlayers('game-1'))
            .thenAnswer((_) async => []);
        return GameGuestInvitationBloc(repository: mockRepo);
      },
      act: (bloc) => bloc.add(const LoadInvitablePlayers(gameId: 'game-1')),
      expect: () => [
        const InvitablePlayersLoading(),
        const InvitablePlayersLoaded(players: []),
      ],
    );

    blocTest<GameGuestInvitationBloc, GameGuestInvitationState>(
      'emits [loading, error] on GameInvitationException',
      build: () {
        when(() => mockRepo.getInvitablePlayers('game-1'))
            .thenThrow(GameInvitationException('Not allowed', code: 'permission-denied'));
        return GameGuestInvitationBloc(repository: mockRepo);
      },
      act: (bloc) => bloc.add(const LoadInvitablePlayers(gameId: 'game-1')),
      expect: () => [
        const InvitablePlayersLoading(),
        const InvitablePlayersError(
          message: 'Not allowed',
          errorCode: 'permission-denied',
        ),
      ],
    );

    blocTest<GameGuestInvitationBloc, GameGuestInvitationState>(
      'emits [loading, error] on unexpected exception',
      build: () {
        when(() => mockRepo.getInvitablePlayers('game-1'))
            .thenThrow(Exception('network error'));
        return GameGuestInvitationBloc(repository: mockRepo);
      },
      act: (bloc) => bloc.add(const LoadInvitablePlayers(gameId: 'game-1')),
      expect: () => [
        const InvitablePlayersLoading(),
        isA<InvitablePlayersError>(),
      ],
    );
  });

  group('InviteGuestPlayer', () {
    blocTest<GameGuestInvitationBloc, GameGuestInvitationState>(
      'emits [sending, success] on happy path',
      build: () {
        when(() => mockRepo.getInvitablePlayers('game-1'))
            .thenAnswer((_) async => [_player]);
        when(() => mockRepo.inviteGuestPlayer(
              gameId: 'game-1',
              inviteeId: 'player-1',
            )).thenAnswer((_) async => 'inv-123');
        return GameGuestInvitationBloc(repository: mockRepo);
      },
      act: (bloc) async {
        bloc.add(const LoadInvitablePlayers(gameId: 'game-1'));
        await Future<void>.delayed(Duration.zero);
        bloc.add(const InviteGuestPlayer(gameId: 'game-1', inviteeId: 'player-1'));
      },
      skip: 2, // skip [loading, loaded] from LoadInvitablePlayers
      expect: () => [
        InvitePlayerSending(players: [_player], inviteeId: 'player-1'),
        InvitePlayerSuccess(players: [_player], inviteeId: 'player-1'),
      ],
    );

    blocTest<GameGuestInvitationBloc, GameGuestInvitationState>(
      'emits [sending, error] on GameInvitationException',
      build: () {
        when(() => mockRepo.getInvitablePlayers('game-1'))
            .thenAnswer((_) async => [_player]);
        when(() => mockRepo.inviteGuestPlayer(
              gameId: 'game-1',
              inviteeId: 'player-1',
            )).thenThrow(GameInvitationException('Already exists', code: 'already-exists'));
        return GameGuestInvitationBloc(repository: mockRepo);
      },
      act: (bloc) async {
        bloc.add(const LoadInvitablePlayers(gameId: 'game-1'));
        await Future<void>.delayed(Duration.zero);
        bloc.add(const InviteGuestPlayer(gameId: 'game-1', inviteeId: 'player-1'));
      },
      skip: 2,
      expect: () => [
        InvitePlayerSending(players: [_player], inviteeId: 'player-1'),
        InvitePlayerError(
          players: [_player],
          message: 'Already exists',
          errorCode: 'already-exists',
        ),
      ],
    );

    blocTest<GameGuestInvitationBloc, GameGuestInvitationState>(
      'preserves player list in error state for retry',
      build: () {
        when(() => mockRepo.getInvitablePlayers('game-1'))
            .thenAnswer((_) async => [_player]);
        when(() => mockRepo.inviteGuestPlayer(
              gameId: 'game-1',
              inviteeId: 'player-1',
            )).thenThrow(Exception('network'));
        return GameGuestInvitationBloc(repository: mockRepo);
      },
      act: (bloc) async {
        bloc.add(const LoadInvitablePlayers(gameId: 'game-1'));
        await Future<void>.delayed(Duration.zero);
        bloc.add(const InviteGuestPlayer(gameId: 'game-1', inviteeId: 'player-1'));
      },
      skip: 2,
      expect: () => [
        isA<InvitePlayerSending>(),
        isA<InvitePlayerError>()
            .having((s) => s.players, 'players', [_player]),
      ],
    );
  });

  group('InviteGroupPlayers', () {
    final player2 = InvitablePlayerModel(
      uid: 'player-2',
      displayName: 'Carol',
      sourceGroupId: 'group-x',
      sourceGroupName: 'Beach Crew',
    );

    blocTest<GameGuestInvitationBloc, GameGuestInvitationState>(
      'emits [groupSending, groupSuccess] and calls CF for each member',
      build: () {
        when(() => mockRepo.getInvitablePlayers('game-1'))
            .thenAnswer((_) async => [_player, player2]);
        when(() => mockRepo.inviteGuestPlayer(
              gameId: 'game-1',
              inviteeId: any(named: 'inviteeId'),
            )).thenAnswer((_) async => 'inv-1');
        return GameGuestInvitationBloc(repository: mockRepo);
      },
      act: (bloc) async {
        bloc.add(const LoadInvitablePlayers(gameId: 'game-1'));
        await Future<void>.delayed(Duration.zero);
        bloc.add(const InviteGroupPlayers(gameId: 'game-1', groupId: 'group-x'));
      },
      skip: 2,
      expect: () => [
        isA<InviteGroupSending>()
            .having((s) => s.groupId, 'groupId', 'group-x'),
        isA<InviteGroupSuccess>()
            .having((s) => s.groupId, 'groupId', 'group-x'),
      ],
      verify: (_) {
        verify(() => mockRepo.inviteGuestPlayer(
              gameId: 'game-1',
              inviteeId: 'player-1',
            )).called(1);
        verify(() => mockRepo.inviteGuestPlayer(
              gameId: 'game-1',
              inviteeId: 'player-2',
            )).called(1);
      },
    );

    blocTest<GameGuestInvitationBloc, GameGuestInvitationState>(
      'swallows already-exists errors and still emits groupSuccess',
      build: () {
        when(() => mockRepo.getInvitablePlayers('game-1'))
            .thenAnswer((_) async => [_player]);
        when(() => mockRepo.inviteGuestPlayer(
              gameId: 'game-1',
              inviteeId: 'player-1',
            )).thenThrow(
              GameInvitationException('Already invited', code: 'already-exists'));
        return GameGuestInvitationBloc(repository: mockRepo);
      },
      act: (bloc) async {
        bloc.add(const LoadInvitablePlayers(gameId: 'game-1'));
        await Future<void>.delayed(Duration.zero);
        bloc.add(const InviteGroupPlayers(gameId: 'game-1', groupId: 'group-x'));
      },
      skip: 2,
      expect: () => [
        isA<InviteGroupSending>(),
        isA<InviteGroupSuccess>(),
      ],
    );
  });
}
