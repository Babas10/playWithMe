// Validates ScoreEntryBloc emits correct states during multi-game score entry operations.

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:play_with_me/core/data/models/game_model.dart';
import 'package:play_with_me/features/games/presentation/bloc/score_entry/score_entry_bloc.dart';
import 'package:play_with_me/features/games/presentation/bloc/score_entry/score_entry_event.dart';
import 'package:play_with_me/features/games/presentation/bloc/score_entry/score_entry_state.dart';

import '../../../../../../unit/core/data/repositories/mock_game_repository.dart';

void main() {
  late MockGameRepository mockGameRepository;

  setUp(() {
    mockGameRepository = MockGameRepository();
  });

  tearDown(() {
    mockGameRepository.dispose();
  });

  group('ScoreEntryBloc', () {
    test('initial state is ScoreEntryInitial', () {
      final bloc = ScoreEntryBloc(gameRepository: mockGameRepository);
      expect(bloc.state, equals(const ScoreEntryInitial()));
      bloc.close();
    });

    group('LoadGameForScoreEntry', () {
      blocTest<ScoreEntryBloc, ScoreEntryState>(
        'emits [loading, loaded] when game exists with teams',
        build: () {
          final game = TestGameData.testGame.copyWith(
            status: GameStatus.completed,
            endedAt: DateTime.now(),
            teams: const GameTeams(
              teamAPlayerIds: ['player1', 'player2'],
              teamBPlayerIds: ['player3', 'player4'],
            ),
          );
          mockGameRepository.addGame(game);
          return ScoreEntryBloc(gameRepository: mockGameRepository);
        },
        act: (bloc) => bloc.add(const LoadGameForScoreEntry(gameId: 'test-game-123')),
        expect: () => [
          const ScoreEntryLoading(),
          isA<ScoreEntryLoaded>()
              .having((state) => state.game.id, 'game id', 'test-game-123')
              .having((state) => state.gameCount, 'game count', null),
        ],
      );

      blocTest<ScoreEntryBloc, ScoreEntryState>(
        'loads existing scores when game has result',
        build: () {
          final game = TestGameData.testGame.copyWith(
            status: GameStatus.completed,
            endedAt: DateTime.now(),
            teams: const GameTeams(
              teamAPlayerIds: ['player1', 'player2'],
              teamBPlayerIds: ['player3', 'player4'],
            ),
            result: GameResult(
              games: [
                IndividualGame(
                  gameNumber: 1,
                  sets: [SetScore(teamAPoints: 21, teamBPoints: 19, setNumber: 1)],
                  winner: 'teamA',
                ),
                IndividualGame(
                  gameNumber: 2,
                  sets: [SetScore(teamAPoints: 19, teamBPoints: 21, setNumber: 1)],
                  winner: 'teamB',
                ),
              ],
              overallWinner: 'teamA',
            ),
          );
          mockGameRepository.addGame(game);
          return ScoreEntryBloc(gameRepository: mockGameRepository);
        },
        act: (bloc) => bloc.add(const LoadGameForScoreEntry(gameId: 'test-game-123')),
        expect: () => [
          const ScoreEntryLoading(),
          isA<ScoreEntryLoaded>()
              .having((state) => state.gameCount, 'game count', 2)
              .having((state) => state.games.length, 'games length', 2)
              .having((state) => state.games[0].sets[0].teamAPoints, 'game 1 set 1 teamA', 21)
              .having((state) => state.games[1].sets[0].teamBPoints, 'game 2 set 1 teamB', 21),
        ],
      );

      blocTest<ScoreEntryBloc, ScoreEntryState>(
        'emits error when game not found',
        build: () => ScoreEntryBloc(gameRepository: mockGameRepository),
        act: (bloc) => bloc.add(const LoadGameForScoreEntry(gameId: 'non-existent')),
        expect: () => [
          const ScoreEntryLoading(),
          const ScoreEntryError(message: 'Game not found'),
        ],
      );

      blocTest<ScoreEntryBloc, ScoreEntryState>(
        'emits error when game not completed',
        build: () {
          mockGameRepository.addGame(TestGameData.testGame); // scheduled game
          return ScoreEntryBloc(gameRepository: mockGameRepository);
        },
        act: (bloc) => bloc.add(const LoadGameForScoreEntry(gameId: 'test-game-123')),
        expect: () => [
          const ScoreEntryLoading(),
          const ScoreEntryError(message: 'Game must be completed before entering scores'),
        ],
      );

      blocTest<ScoreEntryBloc, ScoreEntryState>(
        'emits error when teams not assigned',
        build: () {
          final game = TestGameData.testGame.copyWith(
            status: GameStatus.completed,
            endedAt: DateTime.now(),
            teams: null,
          );
          mockGameRepository.addGame(game);
          return ScoreEntryBloc(gameRepository: mockGameRepository);
        },
        act: (bloc) => bloc.add(const LoadGameForScoreEntry(gameId: 'test-game-123')),
        expect: () => [
          const ScoreEntryLoading(),
          const ScoreEntryError(message: 'Teams must be assigned before entering scores'),
        ],
      );
    });

    group('SetGameCount', () {
      blocTest<ScoreEntryBloc, ScoreEntryState>(
        'sets game count and initializes games with single sets',
        build: () => ScoreEntryBloc(gameRepository: mockGameRepository),
        seed: () => ScoreEntryLoaded(
          game: TestGameData.testGame.copyWith(
            status: GameStatus.completed,
            teams: const GameTeams(
              teamAPlayerIds: ['p1'],
              teamBPlayerIds: ['p2'],
            ),
          ),
        ),
        act: (bloc) => bloc.add(const SetGameCount(count: 3)),
        expect: () => [
          isA<ScoreEntryLoaded>()
              .having((state) => state.gameCount, 'game count', 3)
              .having((state) => state.games.length, 'games length', 3)
              .having((state) => state.games[0].numberOfSets, 'game 0 sets', 1)
              .having((state) => state.games[1].numberOfSets, 'game 1 sets', 1)
              .having((state) => state.games[2].numberOfSets, 'game 2 sets', 1),
        ],
      );

      blocTest<ScoreEntryBloc, ScoreEntryState>(
        'sets game count to 1 for single game',
        build: () => ScoreEntryBloc(gameRepository: mockGameRepository),
        seed: () => ScoreEntryLoaded(
          game: TestGameData.testGame.copyWith(
            status: GameStatus.completed,
            teams: const GameTeams(
              teamAPlayerIds: ['p1'],
              teamBPlayerIds: ['p2'],
            ),
          ),
        ),
        act: (bloc) => bloc.add(const SetGameCount(count: 1)),
        expect: () => [
          isA<ScoreEntryLoaded>()
              .having((state) => state.gameCount, 'game count', 1)
              .having((state) => state.games.length, 'games length', 1),
        ],
      );
    });

    group('SetGameFormat', () {
      blocTest<ScoreEntryBloc, ScoreEntryState>(
        'changes game format to best of 2',
        build: () => ScoreEntryBloc(gameRepository: mockGameRepository),
        seed: () => ScoreEntryLoaded(
          game: TestGameData.testGame.copyWith(
            status: GameStatus.completed,
            teams: const GameTeams(
              teamAPlayerIds: ['p1'],
              teamBPlayerIds: ['p2'],
            ),
          ),
          gameCount: 2,
          games: [
            GameData(numberOfSets: 1, sets: [const SetScoreData()]),
            GameData(numberOfSets: 1, sets: [const SetScoreData()]),
          ],
        ),
        act: (bloc) => bloc.add(const SetGameFormat(gameIndex: 0, numberOfSets: 2)),
        expect: () => [
          isA<ScoreEntryLoaded>()
              .having((state) => state.games[0].numberOfSets, 'game 0 sets', 2)
              .having((state) => state.games[0].sets.length, 'game 0 sets length', 2)
              .having((state) => state.games[1].numberOfSets, 'game 1 sets', 1),
        ],
      );

      blocTest<ScoreEntryBloc, ScoreEntryState>(
        'changes game format to best of 3',
        build: () => ScoreEntryBloc(gameRepository: mockGameRepository),
        seed: () => ScoreEntryLoaded(
          game: TestGameData.testGame.copyWith(
            status: GameStatus.completed,
            teams: const GameTeams(
              teamAPlayerIds: ['p1'],
              teamBPlayerIds: ['p2'],
            ),
          ),
          gameCount: 1,
          games: [
            GameData(numberOfSets: 1, sets: [const SetScoreData()]),
          ],
        ),
        act: (bloc) => bloc.add(const SetGameFormat(gameIndex: 0, numberOfSets: 3)),
        expect: () => [
          isA<ScoreEntryLoaded>()
              .having((state) => state.games[0].numberOfSets, 'game 0 sets', 3)
              .having((state) => state.games[0].sets.length, 'game 0 sets length', 3),
        ],
      );
    });

    group('UpdateSetScore', () {
      blocTest<ScoreEntryBloc, ScoreEntryState>(
        'updates score for specific set in specific game',
        build: () => ScoreEntryBloc(gameRepository: mockGameRepository),
        seed: () => ScoreEntryLoaded(
          game: TestGameData.testGame.copyWith(
            status: GameStatus.completed,
            teams: const GameTeams(
              teamAPlayerIds: ['p1'],
              teamBPlayerIds: ['p2'],
            ),
          ),
          gameCount: 2,
          games: [
            GameData(numberOfSets: 1, sets: [const SetScoreData()]),
            GameData(numberOfSets: 1, sets: [const SetScoreData()]),
          ],
        ),
        act: (bloc) => bloc.add(const UpdateSetScore(
          gameIndex: 0,
          setIndex: 0,
          teamAPoints: 21,
          teamBPoints: 19,
        )),
        expect: () => [
          isA<ScoreEntryLoaded>()
              .having((state) => state.games[0].sets[0].teamAPoints, 'game 0 set 0 teamA', 21)
              .having((state) => state.games[0].sets[0].teamBPoints, 'game 0 set 0 teamB', 19)
              .having((state) => state.games[1].sets[0].teamAPoints, 'game 1 unchanged', null),
        ],
      );

      blocTest<ScoreEntryBloc, ScoreEntryState>(
        'updates multiple sets independently',
        build: () => ScoreEntryBloc(gameRepository: mockGameRepository),
        seed: () => ScoreEntryLoaded(
          game: TestGameData.testGame.copyWith(
            status: GameStatus.completed,
            teams: const GameTeams(
              teamAPlayerIds: ['p1'],
              teamBPlayerIds: ['p2'],
            ),
          ),
          gameCount: 1,
          games: [
            GameData(numberOfSets: 2, sets: [const SetScoreData(), const SetScoreData()]),
          ],
        ),
        act: (bloc) => bloc
          ..add(const UpdateSetScore(gameIndex: 0, setIndex: 0, teamAPoints: 21, teamBPoints: 19))
          ..add(const UpdateSetScore(gameIndex: 0, setIndex: 1, teamAPoints: 19, teamBPoints: 21)),
        expect: () => [
          isA<ScoreEntryLoaded>()
              .having((state) => state.games[0].sets[0].teamAPoints, 'set 0 teamA', 21)
              .having((state) => state.games[0].sets[0].teamBPoints, 'set 0 teamB', 19),
          isA<ScoreEntryLoaded>()
              .having((state) => state.games[0].sets[1].teamAPoints, 'set 1 teamA', 19)
              .having((state) => state.games[0].sets[1].teamBPoints, 'set 1 teamB', 21),
        ],
      );
    });

    group('SaveScores', () {
      blocTest<ScoreEntryBloc, ScoreEntryState>(
        'saves valid single game session',
        build: () {
          final game = TestGameData.testGame.copyWith(
            status: GameStatus.completed,
            endedAt: DateTime.now(),
            teams: const GameTeams(
              teamAPlayerIds: ['p1'],
              teamBPlayerIds: ['p2'],
            ),
          );
          mockGameRepository.addGame(game);
          return ScoreEntryBloc(gameRepository: mockGameRepository);
        },
        seed: () => ScoreEntryLoaded(
          game: TestGameData.testGame.copyWith(
            status: GameStatus.completed,
            teams: const GameTeams(
              teamAPlayerIds: ['p1'],
              teamBPlayerIds: ['p2'],
            ),
          ),
          gameCount: 1,
          games: [
            GameData(
              numberOfSets: 1,
              sets: [const SetScoreData(teamAPoints: 21, teamBPoints: 19)],
            ),
          ],
        ),
        act: (bloc) => bloc.add(const SaveScores(userId: 'test-uid-123')),
        expect: () => [
          isA<ScoreEntrySaving>(),
          isA<ScoreEntrySaved>()
              .having((state) => state.result.games.length, 'games count', 1)
              .having((state) => state.result.overallWinner, 'winner', 'teamA'),
        ],
      );

      blocTest<ScoreEntryBloc, ScoreEntryState>(
        'saves valid multi-game session (Team A wins 2-1)',
        build: () {
          final game = TestGameData.testGame.copyWith(
            status: GameStatus.completed,
            endedAt: DateTime.now(),
            teams: const GameTeams(
              teamAPlayerIds: ['p1'],
              teamBPlayerIds: ['p2'],
            ),
          );
          mockGameRepository.addGame(game);
          return ScoreEntryBloc(gameRepository: mockGameRepository);
        },
        seed: () => ScoreEntryLoaded(
          game: TestGameData.testGame.copyWith(
            status: GameStatus.completed,
            teams: const GameTeams(
              teamAPlayerIds: ['p1'],
              teamBPlayerIds: ['p2'],
            ),
          ),
          gameCount: 3,
          games: [
            GameData(
              numberOfSets: 1,
              sets: [const SetScoreData(teamAPoints: 21, teamBPoints: 19)],
            ),
            GameData(
              numberOfSets: 1,
              sets: [const SetScoreData(teamAPoints: 19, teamBPoints: 21)],
            ),
            GameData(
              numberOfSets: 1,
              sets: [const SetScoreData(teamAPoints: 21, teamBPoints: 18)],
            ),
          ],
        ),
        act: (bloc) => bloc.add(const SaveScores(userId: 'test-uid-123')),
        expect: () => [
          isA<ScoreEntrySaving>(),
          isA<ScoreEntrySaved>()
              .having((state) => state.result.games.length, 'games count', 3)
              .having((state) => state.result.overallWinner, 'winner', 'teamA')
              .having((state) => state.result.gamesWon['teamA'], 'teamA wins', 2)
              .having((state) => state.result.gamesWon['teamB'], 'teamB wins', 1),
        ],
      );

      blocTest<ScoreEntryBloc, ScoreEntryState>(
        'emits error when scores incomplete',
        build: () => ScoreEntryBloc(gameRepository: mockGameRepository),
        seed: () => ScoreEntryLoaded(
          game: TestGameData.testGame.copyWith(
            status: GameStatus.completed,
            teams: const GameTeams(
              teamAPlayerIds: ['p1'],
              teamBPlayerIds: ['p2'],
            ),
          ),
          gameCount: 1,
          games: [
            GameData(
              numberOfSets: 1,
              sets: [const SetScoreData(teamAPoints: 21)], // Missing teamB
            ),
          ],
        ),
        act: (bloc) => bloc.add(const SaveScores(userId: 'test-uid-123')),
        expect: () => [
          const ScoreEntryError(message: 'Please enter valid scores for all games'),
          isA<ScoreEntryLoaded>(),
        ],
      );
    });

    group('ScoreEntryLoaded state helpers', () {
      test('allGamesComplete returns true when all games complete', () {
        final state = ScoreEntryLoaded(
          game: TestGameData.testGame,
          gameCount: 2,
          games: [
            GameData(
              numberOfSets: 1,
              sets: [const SetScoreData(teamAPoints: 21, teamBPoints: 19)],
            ),
            GameData(
              numberOfSets: 1,
              sets: [const SetScoreData(teamAPoints: 19, teamBPoints: 21)],
            ),
          ],
        );

        expect(state.allGamesComplete, true);
      });

      test('allGamesComplete returns false when games incomplete', () {
        final state = ScoreEntryLoaded(
          game: TestGameData.testGame,
          gameCount: 2,
          games: [
            GameData(
              numberOfSets: 1,
              sets: [const SetScoreData(teamAPoints: 21, teamBPoints: 19)],
            ),
            GameData(
              numberOfSets: 1,
              sets: [const SetScoreData()], // Incomplete
            ),
          ],
        );

        expect(state.allGamesComplete, false);
      });

      test('overallWinner returns correct winner', () {
        final state = ScoreEntryLoaded(
          game: TestGameData.testGame,
          gameCount: 3,
          games: [
            GameData(
              numberOfSets: 1,
              sets: [const SetScoreData(teamAPoints: 21, teamBPoints: 19)],
            ),
            GameData(
              numberOfSets: 1,
              sets: [const SetScoreData(teamAPoints: 19, teamBPoints: 21)],
            ),
            GameData(
              numberOfSets: 1,
              sets: [const SetScoreData(teamAPoints: 21, teamBPoints: 18)],
            ),
          ],
        );

        expect(state.overallWinner, 'teamA');
      });

      test('canSave returns true when all complete and has winner', () {
        final state = ScoreEntryLoaded(
          game: TestGameData.testGame,
          gameCount: 1,
          games: [
            GameData(
              numberOfSets: 1,
              sets: [const SetScoreData(teamAPoints: 21, teamBPoints: 19)],
            ),
          ],
        );

        expect(state.canSave, true);
      });

      test('canSave returns false when games incomplete', () {
        final state = ScoreEntryLoaded(
          game: TestGameData.testGame,
          gameCount: 1,
          games: [
            GameData(
              numberOfSets: 1,
              sets: [const SetScoreData()],
            ),
          ],
        );

        expect(state.canSave, false);
      });
    });
  });
}
