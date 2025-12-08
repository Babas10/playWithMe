// Tests GameBloc functionality and validates all game management operations work correctly.

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:play_with_me/core/presentation/bloc/game/game_bloc.dart';
import 'package:play_with_me/core/presentation/bloc/game/game_event.dart';
import 'package:play_with_me/core/presentation/bloc/game/game_state.dart';
import 'package:play_with_me/core/data/models/game_model.dart';

import '../../../data/repositories/mock_game_repository.dart';

void main() {
  group('GameBloc', () {
    late GameBloc gameBloc;
    late MockGameRepository mockGameRepository;

    setUp(() {
      mockGameRepository = MockGameRepository();
      gameBloc = GameBloc(gameRepository: mockGameRepository);
    });

    tearDown(() {
      gameBloc.close();
    });

    test('initial state is GameInitial', () {
      expect(gameBloc.state, equals(const GameInitial()));
    });

    group('LoadGameById', () {
      final testGame = GameModel(
        id: 'game-1',
        title: 'Test Game',
        groupId: 'group-1',
        createdBy: 'user-1',
        createdAt: DateTime.now(),
        scheduledAt: DateTime.now().add(const Duration(hours: 1)),
        location: const GameLocation(name: 'Test Court'),
      );

      blocTest<GameBloc, GameState>(
        'emits GameLoaded when game exists',
        build: () {
          mockGameRepository.addGame(testGame);
          return gameBloc;
        },
        act: (bloc) => bloc.add(const LoadGameById(gameId: 'game-1')),
        expect: () => [
          const GameLoading(),
          GameLoaded(game: testGame),
        ],
      );

      blocTest<GameBloc, GameState>(
        'emits GameNotFound when game does not exist',
        build: () {
          mockGameRepository.clearGames();
          return gameBloc;
        },
        act: (bloc) => bloc.add(const LoadGameById(gameId: 'game-1')),
        expect: () => [
          const GameLoading(),
          const GameNotFound(message: 'Game not found'),
        ],
      );
    });

    group('CreateGame', () {
      final newGame = GameModel(
        id: '',
        title: 'New Game',
        groupId: 'group-1',
        createdBy: 'user-1',
        createdAt: DateTime.now(),
        scheduledAt: DateTime.now().add(const Duration(hours: 1)),
        location: const GameLocation(name: 'Test Court'),
      );

      blocTest<GameBloc, GameState>(
        'emits GameCreated when creation succeeds',
        build: () {
          mockGameRepository.clearGames();
          return gameBloc;
        },
        act: (bloc) => bloc.add(CreateGame(game: newGame)),
        expect: () => [
          const GameLoading(),
          isA<GameCreated>(),
        ],
      );
    });

    group('JoinGame', () {
      final updatedGame = GameModel(
        id: 'game-1',
        title: 'Test Game',
        groupId: 'group-1',
        createdBy: 'user-1',
        createdAt: DateTime.now(),
        scheduledAt: DateTime.now().add(const Duration(hours: 1)),
        location: const GameLocation(name: 'Test Court'),
        playerIds: ['user-2'],
      );

      blocTest<GameBloc, GameState>(
        'emits GameUpdated when join succeeds',
        build: () {
          mockGameRepository.addGame(updatedGame);
          return gameBloc;
        },
        act: (bloc) => bloc.add(const JoinGame(
          gameId: 'game-1',
          userId: 'user-2',
        )),
        expect: () => [
          const GameLoading(),
          isA<GameUpdated>(),
        ],
      );
    });

    group('StartGame', () {
      final startedGame = GameModel(
        id: 'game-1',
        title: 'Test Game',
        groupId: 'group-1',
        createdBy: 'user-1',
        createdAt: DateTime.now(),
        scheduledAt: DateTime.now().add(const Duration(hours: 1)),
        location: const GameLocation(name: 'Test Court'),
        status: GameStatus.inProgress,
        startedAt: DateTime.now(),
      );

            blocTest<GameBloc, GameState>(

              'emits GameUpdated when start succeeds',

              build: () {

                mockGameRepository.addGame(startedGame);

                return gameBloc;

              },

              act: (bloc) => bloc.add(const StartGame(gameId: 'game-1')),

              expect: () => [

                const GameLoading(),

                isA<GameUpdated>(),

              ],

            );

          });

      

          group('SaveGameResult', () {

            final game = GameModel(

              id: 'game-1',

              title: 'Test Game',

              groupId: 'group-1',

              createdBy: 'user-1',

              createdAt: DateTime.now(),

              scheduledAt: DateTime.now().add(const Duration(hours: 1)),

              location: const GameLocation(name: 'Test Court'),

              status: GameStatus.completed,

              playerIds: ['user-1', 'user-2', 'user-3', 'user-4'],

            );

            final teams = GameTeams(

              teamAPlayerIds: ['user-1', 'user-3'],

              teamBPlayerIds: ['user-2', 'user-4'],

            );

            final result = GameResult(

              games: [

                IndividualGame(

                  gameNumber: 1,

                  sets: [

                    SetScore(teamAPoints: 21, teamBPoints: 19, setNumber: 1),

                  ],

                  winner: 'teamA',

                )

              ],

              overallWinner: 'teamA',

            );

      

            blocTest<GameBloc, GameState>(

              'emits GameUpdated when saving game result succeeds',

              build: () {

                mockGameRepository.addGame(game);

                return gameBloc;

              },

              act: (bloc) => bloc.add(SaveGameResult(

                gameId: 'game-1',

                userId: 'user-1',

                teams: teams,

                result: result,

              )),

              expect: () => [

                const GameLoading(),

                isA<GameUpdated>(),

              ],

            );

          });

        });

      }

      