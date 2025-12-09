// Validates GameDetailsBloc emits correct states during game details operations.

import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:play_with_me/core/data/models/game_model.dart';
import 'package:play_with_me/features/games/presentation/bloc/game_details/game_details_bloc.dart';
import 'package:play_with_me/features/games/presentation/bloc/game_details/game_details_event.dart';
import 'package:play_with_me/features/games/presentation/bloc/game_details/game_details_state.dart';

import '../../../../../../unit/core/data/repositories/mock_game_repository.dart';

void main() {
  late MockGameRepository mockGameRepository;
  late GameDetailsBloc gameDetailsBloc;

  setUp(() {
    mockGameRepository = MockGameRepository();
    gameDetailsBloc = GameDetailsBloc(gameRepository: mockGameRepository);
  });

  tearDown(() {
    gameDetailsBloc.close();
    mockGameRepository.dispose();
  });

  group('GameDetailsBloc', () {
    test('initial state is GameDetailsInitial', () {
      expect(gameDetailsBloc.state, equals(const GameDetailsInitial()));
    });

    group('LoadGameDetails', () {
      blocTest<GameDetailsBloc, GameDetailsState>(
        'emits [loading, loaded] when game exists',
        build: () {
          mockGameRepository.addGame(TestGameData.testGame);
          return GameDetailsBloc(gameRepository: mockGameRepository);
        },
        act: (bloc) => bloc.add(const LoadGameDetails(gameId: 'test-game-123')),
        expect: () => [
          const GameDetailsLoading(),
          GameDetailsLoaded(game: TestGameData.testGame),
        ],
      );

      blocTest<GameDetailsBloc, GameDetailsState>(
        'emits [loading, not found] when game does not exist',
        build: () => GameDetailsBloc(gameRepository: mockGameRepository),
        act: (bloc) => bloc.add(const LoadGameDetails(gameId: 'non-existent-game')),
        expect: () => [
          const GameDetailsLoading(),
          const GameDetailsNotFound(message: 'Game not found or has been deleted'),
        ],
      );

      test('updates state when game changes via stream', () async {
        // Skip: Complex async stream timing test - covered by integration tests
      }, skip: 'https://github.com/Babas10/playWithMe/issues/19 - Stream timing');
    });

    group('JoinGameDetails', () {
      blocTest<GameDetailsBloc, GameDetailsState>(
        'emits [operation in progress, loaded] when join succeeds',
        build: () {
          mockGameRepository.addGame(TestGameData.testGame);
          final bloc = GameDetailsBloc(gameRepository: mockGameRepository);
          // Establish stream subscription before test
          bloc.add(const LoadGameDetails(gameId: 'test-game-123'));
          return bloc;
        },
        skip: 1, // Skip the initial loading state
        act: (bloc) async {
          // Wait for stream to be established
          await Future.delayed(Duration.zero);
          // Then join the game
          bloc.add(
            const JoinGameDetails(gameId: 'test-game-123', userId: 'new-user-456'),
          );
        },
        expect: () => [
          GameDetailsLoaded(game: TestGameData.testGame), // Initial load
          GameDetailsOperationInProgress(
            game: TestGameData.testGame,
            operation: 'join',
          ),
          isA<GameDetailsLoaded>().having(
            (state) => state.game.playerIds.contains('new-user-456'),
            'contains new player',
            true,
          ),
        ],
      );

      blocTest<GameDetailsBloc, GameDetailsState>(
        'emits error when repository throws',
        build: () => GameDetailsBloc(gameRepository: mockGameRepository),
        seed: () => GameDetailsLoaded(game: TestGameData.testGame),
        act: (bloc) => bloc.add(
          const JoinGameDetails(gameId: 'non-existent', userId: 'user-123'),
        ),
        expect: () => [
          GameDetailsOperationInProgress(
            game: TestGameData.testGame,
            operation: 'join',
          ),
          isA<GameDetailsError>().having(
            (state) => state.message,
            'error message',
            contains('Failed to join game'),
          ),
        ],
      );

      blocTest<GameDetailsBloc, GameDetailsState>(
        'handles user joining full game to waitlist',
        build: () {
          mockGameRepository.addGame(TestGameData.fullGame);
          final bloc = GameDetailsBloc(gameRepository: mockGameRepository);
          // Establish stream subscription before test
          bloc.add(const LoadGameDetails(gameId: 'full-game-101'));
          return bloc;
        },
        skip: 1, // Skip the initial loading state
        act: (bloc) async {
          // Wait for stream to be established
          await Future.delayed(Duration.zero);
          // Then join the game
          bloc.add(
            const JoinGameDetails(gameId: 'full-game-101', userId: 'new-user-789'),
          );
        },
        expect: () => [
          GameDetailsLoaded(game: TestGameData.fullGame), // Initial load
          GameDetailsOperationInProgress(
            game: TestGameData.fullGame,
            operation: 'join',
          ),
          isA<GameDetailsLoaded>().having(
            (state) => state.game.waitlistIds.contains('new-user-789'),
            'contains new user in waitlist',
            true,
          ),
        ],
      );
    });

    group('LeaveGameDetails', () {
      blocTest<GameDetailsBloc, GameDetailsState>(
        'emits [operation in progress, loaded] when leave succeeds',
        build: () {
          mockGameRepository.addGame(TestGameData.testGame);
          final bloc = GameDetailsBloc(gameRepository: mockGameRepository);
          // Establish stream subscription before test
          bloc.add(const LoadGameDetails(gameId: 'test-game-123'));
          return bloc;
        },
        skip: 1, // Skip the initial loading state
        act: (bloc) async {
          // Wait for stream to be established
          await Future.delayed(Duration.zero);
          // Then leave the game
          bloc.add(
            const LeaveGameDetails(gameId: 'test-game-123', userId: 'user-uid-789'),
          );
        },
        expect: () => [
          GameDetailsLoaded(game: TestGameData.testGame), // Initial load
          GameDetailsOperationInProgress(
            game: TestGameData.testGame,
            operation: 'leave',
          ),
          isA<GameDetailsLoaded>().having(
            (state) => !state.game.playerIds.contains('user-uid-789'),
            'player removed',
            true,
          ),
        ],
      );

      blocTest<GameDetailsBloc, GameDetailsState>(
        'emits error when repository throws',
        build: () => GameDetailsBloc(gameRepository: mockGameRepository),
        seed: () => GameDetailsLoaded(game: TestGameData.testGame),
        act: (bloc) => bloc.add(
          const LeaveGameDetails(gameId: 'non-existent', userId: 'user-123'),
        ),
        expect: () => [
          GameDetailsOperationInProgress(
            game: TestGameData.testGame,
            operation: 'leave',
          ),
          isA<GameDetailsError>().having(
            (state) => state.message,
            'error message',
            contains('Failed to leave game'),
          ),
        ],
      );

      blocTest<GameDetailsBloc, GameDetailsState>(
        'promotes waitlist player when someone leaves',
        build: () {
          // Create a full game with waitlist
          final gameWithWaitlist = TestGameData.fullGame.copyWith(
            playerIds: ['player-1', 'player-2'],
            waitlistIds: ['waitlist-1', 'waitlist-2'],
          );
          mockGameRepository.addGame(gameWithWaitlist);
          final bloc = GameDetailsBloc(gameRepository: mockGameRepository);
          // Establish stream subscription before test
          bloc.add(const LoadGameDetails(gameId: 'full-game-101'));
          return bloc;
        },
        skip: 1, // Skip the initial loading state
        act: (bloc) async {
          // Wait for stream to be established
          await Future.delayed(Duration.zero);
          // Then leave the game
          bloc.add(
            const LeaveGameDetails(gameId: 'full-game-101', userId: 'player-2'),
          );
        },
        expect: () => [
          isA<GameDetailsLoaded>(), // Initial load with game + waitlist
          isA<GameDetailsOperationInProgress>(),
          isA<GameDetailsLoaded>().having(
            (state) {
              // Check that player-2 is removed
              final hasPlayer2 = state.game.playerIds.contains('player-2');
              // Check that waitlist-1 was promoted
              final hasWaitlist1 = state.game.playerIds.contains('waitlist-1');
              // Check that waitlist-1 is not in waitlist anymore
              final waitlistHasWaitlist1 =
                  state.game.waitlistIds.contains('waitlist-1');

              return !hasPlayer2 && hasWaitlist1 && !waitlistHasWaitlist1;
            },
            'waitlist player promoted',
            true,
          ),
        ],
      );
    });

    group('Real-time updates', () {
      test('stream subscription is created on LoadGameDetails', () async {
        mockGameRepository.addGame(TestGameData.testGame);

        final bloc = GameDetailsBloc(gameRepository: mockGameRepository);

        bloc.add(const LoadGameDetails(gameId: 'test-game-123'));

        await expectLater(
          bloc.stream,
          emitsInOrder([
            const GameDetailsLoading(),
            isA<GameDetailsLoaded>(),
          ]),
        );

        await bloc.close();
      });

      test('stream subscription is cancelled on close', () async {
        mockGameRepository.addGame(TestGameData.testGame);

        final bloc = GameDetailsBloc(gameRepository: mockGameRepository);
        bloc.add(const LoadGameDetails(gameId: 'test-game-123'));

        await Future.delayed(const Duration(milliseconds: 100));
        await bloc.close();

        // Verify no errors when updating after close
        mockGameRepository.addGame(TestGameData.testGame.copyWith(
          title: 'Should not update closed bloc',
        ));

        // If we get here without errors, the subscription was properly cancelled
        expect(bloc.isClosed, true);
      });

      test('receives multiple updates from stream', () async {
        // Skip: Complex async stream timing test - covered by integration tests
      }, skip: 'https://github.com/Babas10/playWithMe/issues/19 - Stream timing');
    });

    group('GameDetailsUpdated', () {
      blocTest<GameDetailsBloc, GameDetailsState>(
        'emits loaded when game is not null',
        build: () => GameDetailsBloc(gameRepository: mockGameRepository),
        act: (bloc) => bloc.add(GameDetailsUpdated(game: TestGameData.testGame)),
        expect: () => [
          GameDetailsLoaded(game: TestGameData.testGame),
        ],
      );

      blocTest<GameDetailsBloc, GameDetailsState>(
        'emits not found when game is null',
        build: () => GameDetailsBloc(gameRepository: mockGameRepository),
        act: (bloc) => bloc.add(const GameDetailsUpdated(game: null)),
        expect: () => [
          const GameDetailsNotFound(message: 'Game not found or has been deleted'),
        ],
      );
    });

    group('MarkGameCompleted', () {
      blocTest<GameDetailsBloc, GameDetailsState>(
        'emits [operation in progress, success] when mark completed succeeds',
        build: () {
          mockGameRepository.addGame(TestGameData.testGame);
          final bloc = GameDetailsBloc(gameRepository: mockGameRepository);
          // Establish stream subscription before test
          bloc.add(const LoadGameDetails(gameId: 'test-game-123'));
          return bloc;
        },
        skip: 1, // Skip the initial loading state
        act: (bloc) async {
          // Wait for stream to be established
          await Future.delayed(Duration.zero);
          // Then mark game as completed
          bloc.add(
            const MarkGameCompleted(gameId: 'test-game-123', userId: 'test-uid-123'),
          );
        },
        expect: () => [
          GameDetailsLoaded(game: TestGameData.testGame), // Initial load
          GameDetailsOperationInProgress(
            game: TestGameData.testGame,
            operation: 'mark_completed',
          ),
          isA<GameDetailsLoaded>().having(
            (state) => state.game.status,
            'stream updates with completed status',
            GameStatus.completed,
          ),
          isA<GameCompletedSuccessfully>().having(
            (state) => state.game.status,
            'game status is completed',
            GameStatus.completed,
          ),
        ],
      );

      blocTest<GameDetailsBloc, GameDetailsState>(
        'emits error when user is not creator',
        build: () {
          mockGameRepository.addGame(TestGameData.testGame);
          final bloc = GameDetailsBloc(gameRepository: mockGameRepository);
          bloc.add(const LoadGameDetails(gameId: 'test-game-123'));
          return bloc;
        },
        skip: 1,
        act: (bloc) async {
          await Future.delayed(Duration.zero);
          bloc.add(
            const MarkGameCompleted(gameId: 'test-game-123', userId: 'different-user'),
          );
        },
        expect: () => [
          GameDetailsLoaded(game: TestGameData.testGame),
          GameDetailsOperationInProgress(
            game: TestGameData.testGame,
            operation: 'mark_completed',
          ),
          isA<GameDetailsError>().having(
            (state) => state.message,
            'error message',
            contains('Only the game creator can mark the game as completed'),
          ),
        ],
      );

      blocTest<GameDetailsBloc, GameDetailsState>(
        'emits error when game is already completed',
        build: () {
          final completedGame = TestGameData.testGame.copyWith(
            status: GameStatus.completed,
            endedAt: DateTime.now(),
          );
          mockGameRepository.addGame(completedGame);
          final bloc = GameDetailsBloc(gameRepository: mockGameRepository);
          bloc.add(const LoadGameDetails(gameId: 'test-game-123'));
          return bloc;
        },
        skip: 1,
        act: (bloc) async {
          await Future.delayed(Duration.zero);
          bloc.add(
            const MarkGameCompleted(gameId: 'test-game-123', userId: 'test-uid-123'),
          );
        },
        expect: () => [
          isA<GameDetailsLoaded>(),
          isA<GameDetailsOperationInProgress>(),
          isA<GameDetailsError>().having(
            (state) => state.message,
            'error message',
            contains('Game is already completed'),
          ),
        ],
      );

      blocTest<GameDetailsBloc, GameDetailsState>(
        'emits error when game is cancelled',
        build: () {
          final cancelledGame = TestGameData.testGame.copyWith(
            status: GameStatus.cancelled,
          );
          mockGameRepository.addGame(cancelledGame);
          final bloc = GameDetailsBloc(gameRepository: mockGameRepository);
          bloc.add(const LoadGameDetails(gameId: 'test-game-123'));
          return bloc;
        },
        skip: 1,
        act: (bloc) async {
          await Future.delayed(Duration.zero);
          bloc.add(
            const MarkGameCompleted(gameId: 'test-game-123', userId: 'test-uid-123'),
          );
        },
        expect: () => [
          isA<GameDetailsLoaded>(),
          isA<GameDetailsOperationInProgress>(),
          isA<GameDetailsError>().having(
            (state) => state.message,
            'error message',
            contains('Cannot complete a cancelled game'),
          ),
        ],
      );

      blocTest<GameDetailsBloc, GameDetailsState>(
        'emits error when game does not exist',
        build: () => GameDetailsBloc(gameRepository: mockGameRepository),
        seed: () => GameDetailsLoaded(game: TestGameData.testGame),
        act: (bloc) => bloc.add(
          const MarkGameCompleted(gameId: 'non-existent', userId: 'test-uid-123'),
        ),
        expect: () => [
          GameDetailsOperationInProgress(
            game: TestGameData.testGame,
            operation: 'mark_completed',
          ),
          isA<GameDetailsError>().having(
            (state) => state.message,
            'error message',
            contains('Failed to mark game as completed'),
          ),
        ],
      );
    });

    group('ConfirmGameResult', () {
      blocTest<GameDetailsBloc, GameDetailsState>(
        'emits [operation in progress, loaded] when confirmation succeeds',
        build: () {
          final verificationGame = TestGameData.testGame.copyWith(
            status: GameStatus.verification,
            resultSubmittedBy: 'submitter-id',
          );
          mockGameRepository.addGame(verificationGame);
          final bloc = GameDetailsBloc(gameRepository: mockGameRepository);
          bloc.add(const LoadGameDetails(gameId: 'test-game-123'));
          return bloc;
        },
        skip: 1,
        act: (bloc) async {
          await Future.delayed(Duration.zero);
          bloc.add(
            const ConfirmGameResult(gameId: 'test-game-123', userId: 'verifier-id'),
          );
        },
        expect: () => [
          isA<GameDetailsLoaded>(), // Initial load
          isA<GameDetailsOperationInProgress>().having(
            (state) => state.operation,
            'operation',
            'confirm_result',
          ),
          isA<GameDetailsLoaded>().having(
            (state) => state.game.status,
            'game becomes completed',
            GameStatus.completed,
          ),
        ],
      );

      blocTest<GameDetailsBloc, GameDetailsState>(
        'emits error when confirmation fails',
        build: () {
          mockGameRepository.addGame(TestGameData.testGame);
          return GameDetailsBloc(gameRepository: mockGameRepository);
        },
        seed: () => GameDetailsLoaded(game: TestGameData.testGame), // Scheduled status
        act: (bloc) => bloc.add(
          const ConfirmGameResult(gameId: 'test-game-123', userId: 'user-1'),
        ),
        expect: () => [
          isA<GameDetailsOperationInProgress>(),
          isA<GameDetailsError>().having(
            (state) => state.message,
            'error message',
            contains('Game is not in verification state'),
          ),
        ],
      );
    });

    group('Edge cases', () {
      test('handles multiple LoadGameDetails calls correctly', () async {
        // Skip: Complex async stream timing test - covered by integration tests
      }, skip: 'https://github.com/Babas10/playWithMe/issues/19 - Stream timing');

      blocTest<GameDetailsBloc, GameDetailsState>(
        'handles join when not in loaded state',
        build: () => GameDetailsBloc(gameRepository: mockGameRepository),
        act: (bloc) => bloc.add(
          const JoinGameDetails(gameId: 'test-game-123', userId: 'user-123'),
        ),
        expect: () => [
          isA<GameDetailsError>(),
        ],
      );

      blocTest<GameDetailsBloc, GameDetailsState>(
        'handles leave when not in loaded state',
        build: () => GameDetailsBloc(gameRepository: mockGameRepository),
        act: (bloc) => bloc.add(
          const LeaveGameDetails(gameId: 'test-game-123', userId: 'user-123'),
        ),
        expect: () => [
          isA<GameDetailsError>(),
        ],
      );
    });
  });
}
