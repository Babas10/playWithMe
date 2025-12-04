// Validates SetScore, IndividualGame, and GameResult models for beach volleyball scoring.

import 'package:flutter_test/flutter_test.dart';
import 'package:play_with_me/core/data/models/game_model.dart';

void main() {
  group('SetScore', () {
    test('isValid returns true for 21-19', () {
      final set = SetScore(teamAPoints: 21, teamBPoints: 19, setNumber: 1);
      expect(set.isValid(), true);
    });

    test('isValid returns true for 21-0', () {
      final set = SetScore(teamAPoints: 21, teamBPoints: 0, setNumber: 1);
      expect(set.isValid(), true);
    });

    test('isValid returns true for extended set 22-20', () {
      final set = SetScore(teamAPoints: 22, teamBPoints: 20, setNumber: 1);
      expect(set.isValid(), true);
    });

    test('isValid returns true for extended set 25-23', () {
      final set = SetScore(teamAPoints: 25, teamBPoints: 23, setNumber: 1);
      expect(set.isValid(), true);
    });

    test('isValid returns false for 21-20 (not win by 2)', () {
      final set = SetScore(teamAPoints: 21, teamBPoints: 20, setNumber: 1);
      expect(set.isValid(), false);
    });

    test('isValid returns false for incomplete set 20-18', () {
      final set = SetScore(teamAPoints: 20, teamBPoints: 18, setNumber: 1);
      expect(set.isValid(), false);
    });

    test('winner returns teamA when teamA wins', () {
      final set = SetScore(teamAPoints: 21, teamBPoints: 19, setNumber: 1);
      expect(set.winner, 'teamA');
    });

    test('winner returns teamB when teamB wins', () {
      final set = SetScore(teamAPoints: 18, teamBPoints: 21, setNumber: 1);
      expect(set.winner, 'teamB');
    });

    test('winner returns null for invalid set', () {
      final set = SetScore(teamAPoints: 20, teamBPoints: 18, setNumber: 1);
      expect(set.winner, null);
    });

    test('toJson and fromJson work correctly', () {
      final set = SetScore(teamAPoints: 21, teamBPoints: 19, setNumber: 1);
      final json = set.toJson();
      final fromJson = SetScore.fromJson(json);

      expect(fromJson.teamAPoints, set.teamAPoints);
      expect(fromJson.teamBPoints, set.teamBPoints);
      expect(fromJson.setNumber, set.setNumber);
    });
  });

  group('IndividualGame', () {
    group('Single Set Games', () {
      test('isValid returns true for valid single set game', () {
        final game = IndividualGame(
          gameNumber: 1,
          sets: [
            SetScore(teamAPoints: 21, teamBPoints: 19, setNumber: 1),
          ],
          winner: 'teamA',
        );

        expect(game.isValid(), true);
      });

      test('isValid returns false when winner does not match', () {
        final game = IndividualGame(
          gameNumber: 1,
          sets: [
            SetScore(teamAPoints: 21, teamBPoints: 19, setNumber: 1),
          ],
          winner: 'teamB', // Wrong winner
        );

        expect(game.isValid(), false);
      });
    });

    group('Best of 2 Sets Games', () {
      test('isValid returns true for 2-0 win', () {
        final game = IndividualGame(
          gameNumber: 1,
          sets: [
            SetScore(teamAPoints: 21, teamBPoints: 19, setNumber: 1),
            SetScore(teamAPoints: 21, teamBPoints: 18, setNumber: 2),
          ],
          winner: 'teamA',
        );

        expect(game.isValid(), true);
      });
    });

    group('Best of 3 Sets Games', () {
      test('isValid returns true for 2-1 win', () {
        final game = IndividualGame(
          gameNumber: 1,
          sets: [
            SetScore(teamAPoints: 21, teamBPoints: 19, setNumber: 1),
            SetScore(teamAPoints: 18, teamBPoints: 21, setNumber: 2),
            SetScore(teamAPoints: 21, teamBPoints: 17, setNumber: 3),
          ],
          winner: 'teamA',
        );

        expect(game.isValid(), true);
      });
    });

    test('setsWon returns correct count', () {
      final game = IndividualGame(
        gameNumber: 1,
        sets: [
          SetScore(teamAPoints: 21, teamBPoints: 19, setNumber: 1),
          SetScore(teamAPoints: 18, teamBPoints: 21, setNumber: 2),
          SetScore(teamAPoints: 21, teamBPoints: 17, setNumber: 3),
        ],
        winner: 'teamA',
      );

      final wins = game.setsWon;
      expect(wins['teamA'], 2);
      expect(wins['teamB'], 1);
    });

    test('toJson and fromJson work correctly', () {
      final game = IndividualGame(
        gameNumber: 1,
        sets: [
          SetScore(teamAPoints: 21, teamBPoints: 19, setNumber: 1),
        ],
        winner: 'teamA',
      );

      final json = game.toJson();
      final fromJson = IndividualGame.fromJson(json);

      expect(fromJson.gameNumber, game.gameNumber);
      expect(fromJson.sets.length, game.sets.length);
      expect(fromJson.winner, game.winner);
    });
  });

  group('GameResult - Play Session', () {
    group('Valid Session Results', () {
      test('isValid returns true for single game session', () {
        final result = GameResult(
          games: [
            IndividualGame(
              gameNumber: 1,
              sets: [SetScore(teamAPoints: 21, teamBPoints: 19, setNumber: 1)],
              winner: 'teamA',
            ),
          ],
          overallWinner: 'teamA',
        );

        expect(result.isValid(), true);
      });

      test('isValid returns true for multi-game session (Team A wins 4-2)', () {
        final result = GameResult(
          games: [
            IndividualGame(
              gameNumber: 1,
              sets: [SetScore(teamAPoints: 21, teamBPoints: 18, setNumber: 1)],
              winner: 'teamA',
            ),
            IndividualGame(
              gameNumber: 2,
              sets: [SetScore(teamAPoints: 19, teamBPoints: 21, setNumber: 1)],
              winner: 'teamB',
            ),
            IndividualGame(
              gameNumber: 3,
              sets: [SetScore(teamAPoints: 21, teamBPoints: 17, setNumber: 1)],
              winner: 'teamA',
            ),
            IndividualGame(
              gameNumber: 4,
              sets: [SetScore(teamAPoints: 22, teamBPoints: 20, setNumber: 1)],
              winner: 'teamA',
            ),
            IndividualGame(
              gameNumber: 5,
              sets: [SetScore(teamAPoints: 19, teamBPoints: 21, setNumber: 1)],
              winner: 'teamB',
            ),
            IndividualGame(
              gameNumber: 6,
              sets: [SetScore(teamAPoints: 21, teamBPoints: 16, setNumber: 1)],
              winner: 'teamA',
            ),
          ],
          overallWinner: 'teamA',
        );

        expect(result.isValid(), true);
        expect(result.gamesWon['teamA'], 4);
        expect(result.gamesWon['teamB'], 2);
      });

      test('isValid returns true for tied session with Team B winning 4-3', () {
        final result = GameResult(
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
            IndividualGame(
              gameNumber: 3,
              sets: [SetScore(teamAPoints: 21, teamBPoints: 18, setNumber: 1)],
              winner: 'teamA',
            ),
            IndividualGame(
              gameNumber: 4,
              sets: [SetScore(teamAPoints: 18, teamBPoints: 21, setNumber: 1)],
              winner: 'teamB',
            ),
            IndividualGame(
              gameNumber: 5,
              sets: [SetScore(teamAPoints: 21, teamBPoints: 19, setNumber: 1)],
              winner: 'teamA',
            ),
            IndividualGame(
              gameNumber: 6,
              sets: [SetScore(teamAPoints: 19, teamBPoints: 21, setNumber: 1)],
              winner: 'teamB',
            ),
            IndividualGame(
              gameNumber: 7,
              sets: [SetScore(teamAPoints: 18, teamBPoints: 21, setNumber: 1)],
              winner: 'teamB',
            ),
          ],
          overallWinner: 'teamB',
        );

        expect(result.isValid(), true);
        expect(result.gamesWon['teamA'], 3);
        expect(result.gamesWon['teamB'], 4);
      });
    });

    group('Invalid Session Results', () {
      test('isValid returns false for empty games list', () {
        final result = GameResult(
          games: [],
          overallWinner: 'teamA',
        );

        expect(result.isValid(), false);
      });

      test('isValid returns false when overall winner is incorrect', () {
        final result = GameResult(
          games: [
            IndividualGame(
              gameNumber: 1,
              sets: [SetScore(teamAPoints: 21, teamBPoints: 19, setNumber: 1)],
              winner: 'teamA',
            ),
            IndividualGame(
              gameNumber: 2,
              sets: [SetScore(teamAPoints: 21, teamBPoints: 18, setNumber: 1)],
              winner: 'teamA',
            ),
          ],
          overallWinner: 'teamB', // Wrong - Team A won 2-0
        );

        expect(result.isValid(), false);
      });

      test('isValid returns false when game has invalid score', () {
        final result = GameResult(
          games: [
            IndividualGame(
              gameNumber: 1,
              sets: [SetScore(teamAPoints: 20, teamBPoints: 18, setNumber: 1)], // Invalid
              winner: 'teamA',
            ),
          ],
          overallWinner: 'teamA',
        );

        expect(result.isValid(), false);
      });

      test('isValid returns false when game numbers are not sequential', () {
        final result = GameResult(
          games: [
            IndividualGame(
              gameNumber: 1,
              sets: [SetScore(teamAPoints: 21, teamBPoints: 19, setNumber: 1)],
              winner: 'teamA',
            ),
            IndividualGame(
              gameNumber: 3, // Should be 2
              sets: [SetScore(teamAPoints: 21, teamBPoints: 18, setNumber: 1)],
              winner: 'teamA',
            ),
          ],
          overallWinner: 'teamA',
        );

        expect(result.isValid(), false);
      });
    });

    group('Session Statistics', () {
      test('gamesWon returns correct count', () {
        final result = GameResult(
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
            IndividualGame(
              gameNumber: 3,
              sets: [SetScore(teamAPoints: 21, teamBPoints: 17, setNumber: 1)],
              winner: 'teamA',
            ),
          ],
          overallWinner: 'teamA',
        );

        final wins = result.gamesWon;
        expect(wins['teamA'], 2);
        expect(wins['teamB'], 1);
      });

      test('totalGames returns correct count', () {
        final result = GameResult(
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
            IndividualGame(
              gameNumber: 3,
              sets: [SetScore(teamAPoints: 21, teamBPoints: 17, setNumber: 1)],
              winner: 'teamA',
            ),
          ],
          overallWinner: 'teamA',
        );

        expect(result.totalGames, 3);
      });

      test('scoreDescription returns correct format', () {
        final result = GameResult(
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
            IndividualGame(
              gameNumber: 3,
              sets: [SetScore(teamAPoints: 21, teamBPoints: 17, setNumber: 1)],
              winner: 'teamA',
            ),
          ],
          overallWinner: 'teamA',
        );

        expect(result.scoreDescription, '2-1');
      });
    });

    group('JSON Serialization', () {
      test('toJson and fromJson work correctly for single game session', () {
        final result = GameResult(
          games: [
            IndividualGame(
              gameNumber: 1,
              sets: [SetScore(teamAPoints: 21, teamBPoints: 19, setNumber: 1)],
              winner: 'teamA',
            ),
          ],
          overallWinner: 'teamA',
        );

        final json = result.toJson();
        final fromJson = GameResult.fromJson(json);

        expect(fromJson.games.length, result.games.length);
        expect(fromJson.games[0].winner, result.games[0].winner);
        expect(fromJson.overallWinner, result.overallWinner);
      });

      test('toJson and fromJson work correctly for multi-game session', () {
        final result = GameResult(
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
            IndividualGame(
              gameNumber: 3,
              sets: [SetScore(teamAPoints: 21, teamBPoints: 17, setNumber: 1)],
              winner: 'teamA',
            ),
          ],
          overallWinner: 'teamA',
        );

        final json = result.toJson();
        final fromJson = GameResult.fromJson(json);

        expect(fromJson.games.length, 3);
        expect(fromJson.overallWinner, 'teamA');
        expect(fromJson.gamesWon['teamA'], 2);
        expect(fromJson.gamesWon['teamB'], 1);
      });
    });
  });
}
