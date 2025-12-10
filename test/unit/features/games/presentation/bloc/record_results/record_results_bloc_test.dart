// Validates RecordResultsBloc emits correct states during team assignment operations.

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:play_with_me/core/data/models/game_model.dart';
import 'package:play_with_me/features/games/presentation/bloc/record_results/record_results_bloc.dart';
import 'package:play_with_me/features/games/presentation/bloc/record_results/record_results_event.dart';
import 'package:play_with_me/features/games/presentation/bloc/record_results/record_results_state.dart';

import '../../../../../../unit/core/data/repositories/mock_game_repository.dart';

void main() {
  late MockGameRepository mockGameRepository;

  setUp(() {
    mockGameRepository = MockGameRepository();
  });

  tearDown(() {
    mockGameRepository.dispose();
  });

  group('RecordResultsBloc', () {
    test('initial state is RecordResultsInitial', () {
      final bloc = RecordResultsBloc(gameRepository: mockGameRepository);
      expect(bloc.state, equals(const RecordResultsInitial()));
      bloc.close();
    });

    group('LoadGameForResults', () {
      blocTest<RecordResultsBloc, RecordResultsState>(
        'emits [loading, loaded] when game exists and is completed',
        build: () {
          final completedGame = TestGameData.testGame.copyWith(
            status: GameStatus.completed,
            endedAt: DateTime.now(),
          );
          mockGameRepository.addGame(completedGame);
          return RecordResultsBloc(gameRepository: mockGameRepository);
        },
        act: (bloc) => bloc.add(const LoadGameForResults(gameId: 'test-game-123')),
        expect: () => [
          const RecordResultsLoading(),
          isA<RecordResultsLoaded>()
              .having((state) => state.game.id, 'game id', 'test-game-123')
              .having((state) => state.unassignedPlayerIds.length, 'unassigned count', 2),
        ],
      );

      blocTest<RecordResultsBloc, RecordResultsState>(
        'emits [loading, error] when game does not exist',
        build: () => RecordResultsBloc(gameRepository: mockGameRepository),
        act: (bloc) => bloc.add(const LoadGameForResults(gameId: 'non-existent')),
        expect: () => [
          const RecordResultsLoading(),
          const RecordResultsError(message: 'Game not found'),
        ],
      );

      blocTest<RecordResultsBloc, RecordResultsState>(
        'emits [loading, loaded] when game is scheduled (implicitly completing)',
        build: () {
          mockGameRepository.addGame(TestGameData.testGame); // scheduled game
          return RecordResultsBloc(gameRepository: mockGameRepository);
        },
        act: (bloc) => bloc.add(const LoadGameForResults(gameId: 'test-game-123')),
        expect: () => [
          const RecordResultsLoading(),
          isA<RecordResultsLoaded>(),
        ],
      );

      blocTest<RecordResultsBloc, RecordResultsState>(
        'loads existing teams if already assigned',
        build: () {
          final completedGameWithTeams = TestGameData.testGame.copyWith(
            status: GameStatus.completed,
            endedAt: DateTime.now(),
            teams: const GameTeams(
              teamAPlayerIds: ['test-uid-123'],
              teamBPlayerIds: ['user-uid-789'],
            ),
          );
          mockGameRepository.addGame(completedGameWithTeams);
          return RecordResultsBloc(gameRepository: mockGameRepository);
        },
        act: (bloc) => bloc.add(const LoadGameForResults(gameId: 'test-game-123')),
        expect: () => [
          const RecordResultsLoading(),
          isA<RecordResultsLoaded>()
              .having((state) => state.teamAPlayerIds, 'team A', ['test-uid-123'])
              .having((state) => state.teamBPlayerIds, 'team B', ['user-uid-789'])
              .having((state) => state.unassignedPlayerIds, 'unassigned', isEmpty),
        ],
      );
    });

    group('AssignPlayerToTeamA', () {
      blocTest<RecordResultsBloc, RecordResultsState>(
        'assigns unassigned player to team A',
        build: () => RecordResultsBloc(gameRepository: mockGameRepository),
        seed: () => RecordResultsLoaded(
          game: TestGameData.testGame,
          teamAPlayerIds: const [],
          teamBPlayerIds: const [],
          unassignedPlayerIds: const ['player1', 'player2'],
        ),
        act: (bloc) => bloc.add(const AssignPlayerToTeamA(playerId: 'player1')),
        expect: () => [
          isA<RecordResultsLoaded>()
              .having((state) => state.teamAPlayerIds, 'team A', ['player1'])
              .having((state) => state.unassignedPlayerIds, 'unassigned', ['player2']),
        ],
      );

      blocTest<RecordResultsBloc, RecordResultsState>(
        'moves player from team B to team A',
        build: () => RecordResultsBloc(gameRepository: mockGameRepository),
        seed: () => RecordResultsLoaded(
          game: TestGameData.testGame,
          teamAPlayerIds: const [],
          teamBPlayerIds: const ['player1'],
          unassignedPlayerIds: const [],
        ),
        act: (bloc) => bloc.add(const AssignPlayerToTeamA(playerId: 'player1')),
        expect: () => [
          isA<RecordResultsLoaded>()
              .having((state) => state.teamAPlayerIds, 'team A', ['player1'])
              .having((state) => state.teamBPlayerIds, 'team B', isEmpty),
        ],
      );
    });

    group('AssignPlayerToTeamB', () {
      blocTest<RecordResultsBloc, RecordResultsState>(
        'assigns unassigned player to team B',
        build: () => RecordResultsBloc(gameRepository: mockGameRepository),
        seed: () => RecordResultsLoaded(
          game: TestGameData.testGame,
          teamAPlayerIds: const [],
          teamBPlayerIds: const [],
          unassignedPlayerIds: const ['player1', 'player2'],
        ),
        act: (bloc) => bloc.add(const AssignPlayerToTeamB(playerId: 'player1')),
        expect: () => [
          isA<RecordResultsLoaded>()
              .having((state) => state.teamBPlayerIds, 'team B', ['player1'])
              .having((state) => state.unassignedPlayerIds, 'unassigned', ['player2']),
        ],
      );

      blocTest<RecordResultsBloc, RecordResultsState>(
        'moves player from team A to team B',
        build: () => RecordResultsBloc(gameRepository: mockGameRepository),
        seed: () => RecordResultsLoaded(
          game: TestGameData.testGame,
          teamAPlayerIds: const ['player1'],
          teamBPlayerIds: const [],
          unassignedPlayerIds: const [],
        ),
        act: (bloc) => bloc.add(const AssignPlayerToTeamB(playerId: 'player1')),
        expect: () => [
          isA<RecordResultsLoaded>()
              .having((state) => state.teamAPlayerIds, 'team A', isEmpty)
              .having((state) => state.teamBPlayerIds, 'team B', ['player1']),
        ],
      );
    });

    group('RemovePlayerFromTeam', () {
      blocTest<RecordResultsBloc, RecordResultsState>(
        'removes player from team A to unassigned',
        build: () => RecordResultsBloc(gameRepository: mockGameRepository),
        seed: () => RecordResultsLoaded(
          game: TestGameData.testGame,
          teamAPlayerIds: const ['player1', 'player2'],
          teamBPlayerIds: const [],
          unassignedPlayerIds: const [],
        ),
        act: (bloc) => bloc.add(const RemovePlayerFromTeam(playerId: 'player1')),
        expect: () => [
          isA<RecordResultsLoaded>()
              .having((state) => state.teamAPlayerIds, 'team A', ['player2'])
              .having((state) => state.unassignedPlayerIds, 'unassigned', ['player1']),
        ],
      );

      blocTest<RecordResultsBloc, RecordResultsState>(
        'removes player from team B to unassigned',
        build: () => RecordResultsBloc(gameRepository: mockGameRepository),
        seed: () => RecordResultsLoaded(
          game: TestGameData.testGame,
          teamAPlayerIds: const [],
          teamBPlayerIds: const ['player1', 'player2'],
          unassignedPlayerIds: const [],
        ),
        act: (bloc) => bloc.add(const RemovePlayerFromTeam(playerId: 'player1')),
        expect: () => [
          isA<RecordResultsLoaded>()
              .having((state) => state.teamBPlayerIds, 'team B', ['player2'])
              .having((state) => state.unassignedPlayerIds, 'unassigned', ['player1']),
        ],
      );
    });

    group('SaveTeams', () {
      blocTest<RecordResultsBloc, RecordResultsState>(
        'emits [saving, saved] when save succeeds',
        build: () {
          final completedGame = TestGameData.testGame.copyWith(
            status: GameStatus.completed,
            endedAt: DateTime.now(),
          );
          mockGameRepository.addGame(completedGame);
          return RecordResultsBloc(gameRepository: mockGameRepository);
        },
        seed: () => RecordResultsLoaded(
          game: TestGameData.testGame.copyWith(
            status: GameStatus.completed,
            endedAt: DateTime.now(),
          ),
          teamAPlayerIds: const ['test-uid-123'],
          teamBPlayerIds: const ['user-uid-789'],
          unassignedPlayerIds: const [],
        ),
        act: (bloc) => bloc.add(const SaveTeams(userId: 'test-uid-123')),
        expect: () => [
          isA<RecordResultsSaving>(),
          isA<RecordResultsSaved>(),
        ],
      );

      blocTest<RecordResultsBloc, RecordResultsState>(
        'emits error when not all players assigned',
        build: () => RecordResultsBloc(gameRepository: mockGameRepository),
        seed: () => RecordResultsLoaded(
          game: TestGameData.testGame.copyWith(status: GameStatus.completed),
          teamAPlayerIds: const ['player1'],
          teamBPlayerIds: const [],
          unassignedPlayerIds: const ['player2'],
        ),
        act: (bloc) => bloc.add(const SaveTeams(userId: 'test-uid-123')),
        expect: () => [
          const RecordResultsError(message: 'All players must be assigned to a team'),
          isA<RecordResultsLoaded>(),
        ],
      );

      blocTest<RecordResultsBloc, RecordResultsState>(
        'emits error when save fails due to permission',
        build: () {
          final completedGame = TestGameData.testGame.copyWith(
            status: GameStatus.completed,
            endedAt: DateTime.now(),
          );
          mockGameRepository.addGame(completedGame);
          return RecordResultsBloc(gameRepository: mockGameRepository);
        },
        seed: () => RecordResultsLoaded(
          game: TestGameData.testGame.copyWith(
            status: GameStatus.completed,
            endedAt: DateTime.now(),
          ),
          teamAPlayerIds: const ['test-uid-123'],
          teamBPlayerIds: const ['user-uid-789'],
          unassignedPlayerIds: const [],
        ),
        act: (bloc) => bloc.add(const SaveTeams(userId: 'wrong-user-id')),
        expect: () => [
          isA<RecordResultsSaving>(),
          isA<RecordResultsError>().having(
            (state) => state.message,
            'error message',
            contains('Only the game creator can update teams'),
          ),
          isA<RecordResultsLoaded>(),
        ],
      );
    });

    group('RecordResultsLoaded state helpers', () {
      test('allPlayersAssigned returns true when all assigned', () {
        final state = RecordResultsLoaded(
          game: TestGameData.testGame,
          teamAPlayerIds: const ['player1'],
          teamBPlayerIds: const ['player2'],
          unassignedPlayerIds: const [],
        );

        expect(state.allPlayersAssigned, true);
      });

      test('allPlayersAssigned returns false when unassigned exist', () {
        final state = RecordResultsLoaded(
          game: TestGameData.testGame,
          teamAPlayerIds: const ['player1'],
          teamBPlayerIds: const [],
          unassignedPlayerIds: const ['player2'],
        );

        expect(state.allPlayersAssigned, false);
      });

      test('canSave returns true when valid', () {
        final state = RecordResultsLoaded(
          game: TestGameData.testGame,
          teamAPlayerIds: const ['player1'],
          teamBPlayerIds: const ['player2'],
          unassignedPlayerIds: const [],
        );

        expect(state.canSave, true);
      });

      test('canSave returns false when team A is empty', () {
        final state = RecordResultsLoaded(
          game: TestGameData.testGame,
          teamAPlayerIds: const [],
          teamBPlayerIds: const ['player1', 'player2'],
          unassignedPlayerIds: const [],
        );

        expect(state.canSave, false);
      });

      test('canSave returns false when team B is empty', () {
        final state = RecordResultsLoaded(
          game: TestGameData.testGame,
          teamAPlayerIds: const ['player1', 'player2'],
          teamBPlayerIds: const [],
          unassignedPlayerIds: const [],
        );

        expect(state.canSave, false);
      });
    });
  });
}
