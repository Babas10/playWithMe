// Validates ScoreEntryBloc emits correct states during multi-game score entry operations.

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:play_with_me/core/data/models/game_model.dart';
import 'package:play_with_me/features/games/presentation/bloc/score_entry/score_entry_bloc.dart';
import 'package:play_with_me/features/games/presentation/bloc/score_entry/score_entry_event.dart';
import 'package:play_with_me/features/games/presentation/bloc/score_entry/score_entry_state.dart';

import '../../../../../../unit/core/data/repositories/mock_game_repository.dart';
import '../../../../../../unit/core/data/repositories/mock_user_repository.dart';

void main() {
  late MockGameRepository mockGameRepository;
  late MockUserRepository mockUserRepository;

  setUp(() {
    mockGameRepository = MockGameRepository();
    mockUserRepository = MockUserRepository();
  });

  tearDown(() {
    mockGameRepository.dispose();
  });

  // Helper to build the bloc with both required repositories
  ScoreEntryBloc buildBloc() => ScoreEntryBloc(
        gameRepository: mockGameRepository,
        userRepository: mockUserRepository,
      );

  // Teams used across tests for a 4-player game
  const testTeams = GameTeams(
    teamAPlayerIds: ['p1', 'p2'],
    teamBPlayerIds: ['p3', 'p4'],
  );

  group('ScoreEntryBloc', () {
    test('initial state is ScoreEntryInitial', () {
      final bloc = buildBloc();
      expect(bloc.state, equals(const ScoreEntryInitial()));
      bloc.close();
    });

    group('LoadGameForScoreEntry', () {
      blocTest<ScoreEntryBloc, ScoreEntryState>(
        'emits [loading, loaded] when game exists',
        build: () {
          final game = TestGameData.testGame.copyWith(
            status: GameStatus.completed,
            endedAt: DateTime.now(),
          );
          mockGameRepository.addGame(game);
          return buildBloc();
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
        'emits [loading, loaded] when game exists with session-level teams',
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
          return buildBloc();
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
        'loads existing scores and restores per-game teams',
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
                  teams: const GameTeams(
                    teamAPlayerIds: ['player1', 'player2'],
                    teamBPlayerIds: ['player3', 'player4'],
                  ),
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
          return buildBloc();
        },
        act: (bloc) => bloc.add(const LoadGameForScoreEntry(gameId: 'test-game-123')),
        expect: () => [
          const ScoreEntryLoading(),
          isA<ScoreEntryLoaded>()
              .having((state) => state.gameCount, 'game count', 2)
              .having((state) => state.games.length, 'games length', 2)
              .having((state) => state.games[0].sets[0].teamAPoints, 'game 1 set 1 teamA', 21)
              .having((state) => state.games[1].sets[0].teamBPoints, 'game 2 set 1 teamB', 21)
              // game 1 has explicit per-game teams
              .having((state) => state.games[0].teams, 'game 1 teams', isNotNull)
              // game 2 falls back to session-level teams
              .having((state) => state.games[1].teams, 'game 2 teams (fallback)', isNotNull),
        ],
      );

      blocTest<ScoreEntryBloc, ScoreEntryState>(
        'emits error when game not found',
        build: () => buildBloc(),
        act: (bloc) => bloc.add(const LoadGameForScoreEntry(gameId: 'non-existent')),
        expect: () => [
          const ScoreEntryLoading(),
          const ScoreEntryError(message: 'Game not found'),
        ],
      );

      blocTest<ScoreEntryBloc, ScoreEntryState>(
        'emits loaded when game is scheduled (no teams required at load)',
        build: () {
          final scheduledGame = TestGameData.testGame.copyWith(
            status: GameStatus.scheduled,
          );
          mockGameRepository.addGame(scheduledGame);
          return buildBloc();
        },
        act: (bloc) => bloc.add(const LoadGameForScoreEntry(gameId: 'test-game-123')),
        expect: () => [
          const ScoreEntryLoading(),
          isA<ScoreEntryLoaded>(),
        ],
      );

      blocTest<ScoreEntryBloc, ScoreEntryState>(
        'emits loaded even when game has no session-level teams (teams now per-game)',
        build: () {
          final game = TestGameData.testGame.copyWith(
            status: GameStatus.completed,
            endedAt: DateTime.now(),
            teams: null, // No session-level teams; per-game teams are selected in UI
          );
          mockGameRepository.addGame(game);
          return buildBloc();
        },
        act: (bloc) => bloc.add(const LoadGameForScoreEntry(gameId: 'test-game-123')),
        expect: () => [
          const ScoreEntryLoading(),
          isA<ScoreEntryLoaded>(),
        ],
      );
    });

    group('SetGameCount', () {
      blocTest<ScoreEntryBloc, ScoreEntryState>(
        'sets game count and initializes games with no teams selected',
        build: () => buildBloc(),
        seed: () => ScoreEntryLoaded(
          game: TestGameData.testGame.copyWith(
            status: GameStatus.completed,
          ),
        ),
        act: (bloc) => bloc.add(const SetGameCount(count: 3)),
        expect: () => [
          isA<ScoreEntryLoaded>()
              .having((state) => state.gameCount, 'game count', 3)
              .having((state) => state.games.length, 'games length', 3)
              .having((state) => state.games[0].numberOfSets, 'game 0 sets', 1)
              .having((state) => state.games[1].numberOfSets, 'game 1 sets', 1)
              .having((state) => state.games[2].numberOfSets, 'game 2 sets', 1)
              .having((state) => state.games[0].teams, 'game 0 teams null', null)
              .having((state) => state.games[1].teams, 'game 1 teams null', null)
              .having((state) => state.games[2].teams, 'game 2 teams null', null),
        ],
      );

      blocTest<ScoreEntryBloc, ScoreEntryState>(
        'sets game count to 1 for single game',
        build: () => buildBloc(),
        seed: () => ScoreEntryLoaded(
          game: TestGameData.testGame.copyWith(
            status: GameStatus.completed,
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
        build: () => buildBloc(),
        seed: () => ScoreEntryLoaded(
          game: TestGameData.testGame.copyWith(
            status: GameStatus.completed,
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
        build: () => buildBloc(),
        seed: () => ScoreEntryLoaded(
          game: TestGameData.testGame.copyWith(
            status: GameStatus.completed,
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
        build: () => buildBloc(),
        seed: () => ScoreEntryLoaded(
          game: TestGameData.testGame.copyWith(
            status: GameStatus.completed,
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
        build: () => buildBloc(),
        seed: () => ScoreEntryLoaded(
          game: TestGameData.testGame.copyWith(
            status: GameStatus.completed,
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

      blocTest<ScoreEntryBloc, ScoreEntryState>(
        'preserves existing values when updating one field',
        build: () => buildBloc(),
        seed: () => ScoreEntryLoaded(
          game: TestGameData.testGame.copyWith(
            status: GameStatus.completed,
          ),
          gameCount: 1,
          games: [
            GameData(numberOfSets: 1, sets: [const SetScoreData()]),
          ],
        ),
        act: (bloc) => bloc
          // First, set Team A score (Team B is null)
          ..add(const UpdateSetScore(gameIndex: 0, setIndex: 0, teamAPoints: 21, teamBPoints: null))
          // Then, set Team B score (must preserve Team A)
          ..add(const UpdateSetScore(gameIndex: 0, setIndex: 0, teamAPoints: 21, teamBPoints: 19)),
        expect: () => [
          isA<ScoreEntryLoaded>()
              .having((state) => state.games[0].sets[0].teamAPoints, 'first update teamA', 21)
              .having((state) => state.games[0].sets[0].teamBPoints, 'first update teamB', null),
          isA<ScoreEntryLoaded>()
              .having((state) => state.games[0].sets[0].teamAPoints, 'second update teamA preserved', 21)
              .having((state) => state.games[0].sets[0].teamBPoints, 'second update teamB', 19),
        ],
      );
    });

    group('SelectGameTeams', () {
      blocTest<ScoreEntryBloc, ScoreEntryState>(
        'selects teams for a specific game',
        build: () => buildBloc(),
        seed: () => ScoreEntryLoaded(
          game: TestGameData.testGame.copyWith(status: GameStatus.completed),
          gameCount: 2,
          games: [
            GameData(numberOfSets: 1, sets: [const SetScoreData()]),
            GameData(numberOfSets: 1, sets: [const SetScoreData()]),
          ],
        ),
        act: (bloc) => bloc.add(SelectGameTeams(
          gameIndex: 0,
          teams: testTeams,
        )),
        expect: () => [
          isA<ScoreEntryLoaded>()
              .having((state) => state.games[0].teams, 'game 0 teams set', testTeams)
              .having((state) => state.games[1].teams, 'game 1 teams unchanged', null),
        ],
      );

      blocTest<ScoreEntryBloc, ScoreEntryState>(
        'selects different teams for different games independently',
        build: () => buildBloc(),
        seed: () => ScoreEntryLoaded(
          game: TestGameData.testGame.copyWith(status: GameStatus.completed),
          gameCount: 2,
          games: [
            GameData(numberOfSets: 1, sets: [const SetScoreData()]),
            GameData(numberOfSets: 1, sets: [const SetScoreData()]),
          ],
        ),
        act: (bloc) => bloc
          ..add(SelectGameTeams(
            gameIndex: 0,
            teams: testTeams,
          ))
          ..add(SelectGameTeams(
            gameIndex: 1,
            teams: const GameTeams(
              teamAPlayerIds: ['p1', 'p3'],
              teamBPlayerIds: ['p2', 'p4'],
            ),
          )),
        expect: () => [
          isA<ScoreEntryLoaded>()
              .having((state) => state.games[0].teams, 'game 0 teams', testTeams)
              .having((state) => state.games[1].teams, 'game 1 unchanged', null),
          isA<ScoreEntryLoaded>()
              .having((state) => state.games[0].teams, 'game 0 preserved', testTeams)
              .having(
                (state) => state.games[1].teams?.teamAPlayerIds,
                'game 1 teams set',
                ['p1', 'p3'],
              ),
        ],
      );

      blocTest<ScoreEntryBloc, ScoreEntryState>(
        'ignores SelectGameTeams when index out of range',
        build: () => buildBloc(),
        seed: () => ScoreEntryLoaded(
          game: TestGameData.testGame.copyWith(status: GameStatus.completed),
          gameCount: 1,
          games: [
            GameData(numberOfSets: 1, sets: [const SetScoreData()]),
          ],
        ),
        act: (bloc) => bloc.add(SelectGameTeams(
          gameIndex: 5, // out of range
          teams: testTeams,
        )),
        expect: () => [], // no state change
      );
    });

    group('SaveScores', () {
      blocTest<ScoreEntryBloc, ScoreEntryState>(
        'saves valid single game session with per-game teams',
        build: () {
          final game = TestGameData.testGame.copyWith(
            status: GameStatus.completed,
            endedAt: DateTime.now(),
            playerIds: ['p1', 'p2', 'p3', 'p4'],
          );
          mockGameRepository.addGame(game);
          return buildBloc();
        },
        seed: () => ScoreEntryLoaded(
          game: TestGameData.testGame.copyWith(
            status: GameStatus.completed,
            playerIds: ['p1', 'p2', 'p3', 'p4'],
          ),
          gameCount: 1,
          games: [
            GameData(
              numberOfSets: 1,
              sets: [const SetScoreData(teamAPoints: 21, teamBPoints: 19)],
              teams: testTeams,
            ),
          ],
        ),
        act: (bloc) => bloc.add(const SaveScores(userId: 'test-uid-123')),
        expect: () => [
          isA<ScoreEntrySaving>(),
          isA<ScoreEntrySaved>()
              .having((state) => state.result.games.length, 'games count', 1)
              .having((state) => state.result.overallWinner, 'winner', 'teamA')
              .having((state) => state.result.games[0].teams, 'game 0 teams saved', testTeams),
        ],
      );

      blocTest<ScoreEntryBloc, ScoreEntryState>(
        'saves valid multi-game session (Team A wins 2-1)',
        build: () {
          final game = TestGameData.testGame.copyWith(
            status: GameStatus.completed,
            endedAt: DateTime.now(),
            playerIds: ['p1', 'p2', 'p3', 'p4'],
          );
          mockGameRepository.addGame(game);
          return buildBloc();
        },
        seed: () => ScoreEntryLoaded(
          game: TestGameData.testGame.copyWith(
            status: GameStatus.completed,
            playerIds: ['p1', 'p2', 'p3', 'p4'],
          ),
          gameCount: 3,
          games: [
            GameData(
              numberOfSets: 1,
              sets: [const SetScoreData(teamAPoints: 21, teamBPoints: 19)],
              teams: testTeams,
            ),
            GameData(
              numberOfSets: 1,
              sets: [const SetScoreData(teamAPoints: 19, teamBPoints: 21)],
              teams: testTeams,
            ),
            GameData(
              numberOfSets: 1,
              sets: [const SetScoreData(teamAPoints: 21, teamBPoints: 18)],
              teams: testTeams,
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
        'saves valid tied session (1-1)',
        build: () {
          final game = TestGameData.testGame.copyWith(
            status: GameStatus.completed,
            endedAt: DateTime.now(),
            playerIds: ['p1', 'p2', 'p3', 'p4'],
          );
          mockGameRepository.addGame(game);
          return buildBloc();
        },
        seed: () => ScoreEntryLoaded(
          game: TestGameData.testGame.copyWith(
            status: GameStatus.completed,
            playerIds: ['p1', 'p2', 'p3', 'p4'],
          ),
          gameCount: 2,
          games: [
            GameData(
              numberOfSets: 1,
              sets: [const SetScoreData(teamAPoints: 21, teamBPoints: 19)],
              teams: testTeams,
            ),
            GameData(
              numberOfSets: 1,
              sets: [const SetScoreData(teamAPoints: 19, teamBPoints: 21)],
              teams: testTeams,
            ),
          ],
        ),
        act: (bloc) => bloc.add(const SaveScores(userId: 'test-uid-123')),
        expect: () => [
          isA<ScoreEntrySaving>(),
          isA<ScoreEntrySaved>()
              .having((state) => state.result.games.length, 'games count', 2)
              .having((state) => state.result.overallWinner, 'winner', null)
              .having((state) => state.result.gamesWon['teamA'], 'teamA wins', 1)
              .having((state) => state.result.gamesWon['teamB'], 'teamB wins', 1),
        ],
      );

      blocTest<ScoreEntryBloc, ScoreEntryState>(
        'saves valid tied session (2-2)',
        build: () {
          final game = TestGameData.testGame.copyWith(
            status: GameStatus.completed,
            endedAt: DateTime.now(),
            playerIds: ['p1', 'p2', 'p3', 'p4'],
          );
          mockGameRepository.addGame(game);
          return buildBloc();
        },
        seed: () => ScoreEntryLoaded(
          game: TestGameData.testGame.copyWith(
            status: GameStatus.completed,
            playerIds: ['p1', 'p2', 'p3', 'p4'],
          ),
          gameCount: 4,
          games: [
            GameData(
              numberOfSets: 1,
              sets: [const SetScoreData(teamAPoints: 21, teamBPoints: 18)],
              teams: testTeams,
            ),
            GameData(
              numberOfSets: 1,
              sets: [const SetScoreData(teamAPoints: 19, teamBPoints: 21)],
              teams: testTeams,
            ),
            GameData(
              numberOfSets: 1,
              sets: [const SetScoreData(teamAPoints: 21, teamBPoints: 17)],
              teams: testTeams,
            ),
            GameData(
              numberOfSets: 1,
              sets: [const SetScoreData(teamAPoints: 18, teamBPoints: 21)],
              teams: testTeams,
            ),
          ],
        ),
        act: (bloc) => bloc.add(const SaveScores(userId: 'test-uid-123')),
        expect: () => [
          isA<ScoreEntrySaving>(),
          isA<ScoreEntrySaved>()
              .having((state) => state.result.games.length, 'games count', 4)
              .having((state) => state.result.overallWinner, 'winner', null)
              .having((state) => state.result.gamesWon['teamA'], 'teamA wins', 2)
              .having((state) => state.result.gamesWon['teamB'], 'teamB wins', 2),
        ],
      );

      blocTest<ScoreEntryBloc, ScoreEntryState>(
        'emits error when scores incomplete (no teams selected)',
        build: () => buildBloc(),
        seed: () => ScoreEntryLoaded(
          game: TestGameData.testGame.copyWith(
            status: GameStatus.completed,
          ),
          gameCount: 1,
          games: [
            GameData(
              numberOfSets: 1,
              sets: [const SetScoreData(teamAPoints: 21, teamBPoints: 19)],
              // No teams selected — isComplete returns false
            ),
          ],
        ),
        act: (bloc) => bloc.add(const SaveScores(userId: 'test-uid-123')),
        expect: () => [
          const ScoreEntryError(
              message: 'Please select teams and enter valid scores for all games'),
          isA<ScoreEntryLoaded>(),
        ],
      );

      blocTest<ScoreEntryBloc, ScoreEntryState>(
        'emits error when score values missing (teams set but score incomplete)',
        build: () => buildBloc(),
        seed: () => ScoreEntryLoaded(
          game: TestGameData.testGame.copyWith(
            status: GameStatus.completed,
          ),
          gameCount: 1,
          games: [
            GameData(
              numberOfSets: 1,
              sets: [const SetScoreData(teamAPoints: 21)], // Missing teamB
              teams: testTeams,
            ),
          ],
        ),
        act: (bloc) => bloc.add(const SaveScores(userId: 'test-uid-123')),
        expect: () => [
          const ScoreEntryError(
              message: 'Please select teams and enter valid scores for all games'),
          isA<ScoreEntryLoaded>(),
        ],
      );
    });

    group('ScoreEntryLoaded state helpers', () {
      test('allGamesComplete returns true when all games have teams and complete scores', () {
        final state = ScoreEntryLoaded(
          game: TestGameData.testGame,
          gameCount: 2,
          games: [
            GameData(
              numberOfSets: 1,
              sets: [const SetScoreData(teamAPoints: 21, teamBPoints: 19)],
              teams: testTeams,
            ),
            GameData(
              numberOfSets: 1,
              sets: [const SetScoreData(teamAPoints: 19, teamBPoints: 21)],
              teams: testTeams,
            ),
          ],
        );

        expect(state.allGamesComplete, true);
      });

      test('allGamesComplete returns false when teams missing for a game', () {
        final state = ScoreEntryLoaded(
          game: TestGameData.testGame,
          gameCount: 2,
          games: [
            GameData(
              numberOfSets: 1,
              sets: [const SetScoreData(teamAPoints: 21, teamBPoints: 19)],
              teams: testTeams,
            ),
            GameData(
              numberOfSets: 1,
              sets: [const SetScoreData(teamAPoints: 19, teamBPoints: 21)],
              // No teams — isComplete = false
            ),
          ],
        );

        expect(state.allGamesComplete, false);
      });

      test('allGamesComplete returns false when games incomplete', () {
        final state = ScoreEntryLoaded(
          game: TestGameData.testGame,
          gameCount: 2,
          games: [
            GameData(
              numberOfSets: 1,
              sets: [const SetScoreData(teamAPoints: 21, teamBPoints: 19)],
              teams: testTeams,
            ),
            GameData(
              numberOfSets: 1,
              sets: [const SetScoreData()], // Incomplete
              teams: testTeams,
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
              teams: testTeams,
            ),
            GameData(
              numberOfSets: 1,
              sets: [const SetScoreData(teamAPoints: 19, teamBPoints: 21)],
              teams: testTeams,
            ),
            GameData(
              numberOfSets: 1,
              sets: [const SetScoreData(teamAPoints: 21, teamBPoints: 18)],
              teams: testTeams,
            ),
          ],
        );

        expect(state.overallWinner, 'teamA');
      });

      test('canSave returns true when all games have teams and complete scores', () {
        final state = ScoreEntryLoaded(
          game: TestGameData.testGame,
          gameCount: 1,
          games: [
            GameData(
              numberOfSets: 1,
              sets: [const SetScoreData(teamAPoints: 21, teamBPoints: 19)],
              teams: testTeams,
            ),
          ],
        );

        expect(state.canSave, true);
      });

      test('canSave returns false when teams missing', () {
        final state = ScoreEntryLoaded(
          game: TestGameData.testGame,
          gameCount: 1,
          games: [
            GameData(
              numberOfSets: 1,
              sets: [const SetScoreData(teamAPoints: 21, teamBPoints: 19)],
              // No teams
            ),
          ],
        );

        expect(state.canSave, false);
      });

      test('canSave returns true when all games complete and tied', () {
        final state = ScoreEntryLoaded(
          game: TestGameData.testGame,
          gameCount: 2,
          games: [
            GameData(
              numberOfSets: 1,
              sets: [const SetScoreData(teamAPoints: 21, teamBPoints: 19)],
              teams: testTeams,
            ),
            GameData(
              numberOfSets: 1,
              sets: [const SetScoreData(teamAPoints: 19, teamBPoints: 21)],
              teams: testTeams,
            ),
          ],
        );

        expect(state.canSave, true);
      });

      test('isTied returns true when teams have equal wins', () {
        final state = ScoreEntryLoaded(
          game: TestGameData.testGame,
          gameCount: 2,
          games: [
            GameData(
              numberOfSets: 1,
              sets: [const SetScoreData(teamAPoints: 21, teamBPoints: 19)],
              teams: testTeams,
            ),
            GameData(
              numberOfSets: 1,
              sets: [const SetScoreData(teamAPoints: 19, teamBPoints: 21)],
              teams: testTeams,
            ),
          ],
        );

        expect(state.isTied, true);
        expect(state.overallWinner, null);
      });

      test('isTied returns false when there is a clear winner', () {
        final state = ScoreEntryLoaded(
          game: TestGameData.testGame,
          gameCount: 1,
          games: [
            GameData(
              numberOfSets: 1,
              sets: [const SetScoreData(teamAPoints: 21, teamBPoints: 19)],
              teams: testTeams,
            ),
          ],
        );

        expect(state.isTied, false);
        expect(state.overallWinner, 'teamA');
      });

      test('isTied returns false when games are incomplete', () {
        final state = ScoreEntryLoaded(
          game: TestGameData.testGame,
          gameCount: 2,
          games: [
            GameData(
              numberOfSets: 1,
              sets: [const SetScoreData(teamAPoints: 21, teamBPoints: 19)],
              teams: testTeams,
            ),
            GameData(
              numberOfSets: 1,
              sets: [const SetScoreData()],
              teams: testTeams,
            ),
          ],
        );

        expect(state.isTied, false);
      });

      test('canSave returns false when games incomplete', () {
        final state = ScoreEntryLoaded(
          game: TestGameData.testGame,
          gameCount: 1,
          games: [
            GameData(
              numberOfSets: 1,
              sets: [const SetScoreData()],
              teams: testTeams,
            ),
          ],
        );

        expect(state.canSave, false);
      });
    });
  });
}
