import 'package:flutter_test/flutter_test.dart';
import 'package:play_with_me/core/domain/services/statistics_models.dart';
import 'package:play_with_me/core/domain/services/statistics_service.dart';

void main() {
  late StatisticsService service;

  setUp(() {
    service = StatisticsService();
  });

  group('StatisticsService - ELO Calculation', () {
    test('calculateElo returns correct delta for equal teams', () {
      // Setup equal teams
      final teamAP1 = const PlayerRating(playerId: 'a1', rating: 1600);
      final teamAP2 = const PlayerRating(playerId: 'a2', rating: 1600);
      final teamBP1 = const PlayerRating(playerId: 'b1', rating: 1600);
      final teamBP2 = const PlayerRating(playerId: 'b2', rating: 1600);

      final result = service.calculateElo(
        teamAPlayer1: teamAP1,
        teamAPlayer2: teamAP2,
        teamBPlayer1: teamBP1,
        teamBPlayer2: teamBP2,
        teamAWon: true,
      );

      // Expected: Both teams rated 1600
      // Expected score for A: 0.5
      // Actual score for A: 1.0
      // Delta = 32 * (1.0 - 0.5) = 16.0
      expect(result.ratingDelta, 16.0);
      expect(result.teamAExpectedScore, 0.5);
      expect(result.teamAWon, true);
      
      // Verify new ratings helper
      expect(result.getNewRating('a1'), 1616.0);
      expect(result.getNewRating('b1'), 1584.0);
    });

    test('calculateElo favors weak-link weighting', () {
      // Team A: 1400 & 1800. Min=1400, Max=1800.
      // Weighted Rating = (0.7 * 1400) + (0.3 * 1800) = 980 + 540 = 1520
      
      // Team B: 1600 & 1600. Min=1600, Max=1600.
      // Weighted Rating = 1600
      
      final teamAP1 = const PlayerRating(playerId: 'a1', rating: 1400); // Weak link
      final teamAP2 = const PlayerRating(playerId: 'a2', rating: 1800);
      final teamBP1 = const PlayerRating(playerId: 'b1', rating: 1600);
      final teamBP2 = const PlayerRating(playerId: 'b2', rating: 1600);

      final result = service.calculateElo(
        teamAPlayer1: teamAP1,
        teamAPlayer2: teamAP2,
        teamBPlayer1: teamBP1,
        teamBPlayer2: teamBP2,
        teamAWon: true,
      );

      expect(result.teamARating, 1520.0);
      expect(result.teamBRating, 1600.0);
      
      // Team A is considered weaker (1520 vs 1600), so expected score < 0.5
      expect(result.teamAExpectedScore, lessThan(0.5));
      
      // Win for weaker team should result in larger delta > 16.0
      expect(result.ratingDelta, greaterThan(16.0));
    });

    test('calculateElo handles upset correctly (Strong loses to Weak)', () {
      final teamAP1 = const PlayerRating(playerId: 'a1', rating: 2000);
      final teamAP2 = const PlayerRating(playerId: 'a2', rating: 2000);
      final teamBP1 = const PlayerRating(playerId: 'b1', rating: 1200);
      final teamBP2 = const PlayerRating(playerId: 'b2', rating: 1200);

      final result = service.calculateElo(
        teamAPlayer1: teamAP1,
        teamAPlayer2: teamAP2,
        teamBPlayer1: teamBP1,
        teamBPlayer2: teamBP2,
        teamAWon: false, // Strong team loses
      );

      // Strong team A expected to win almost certainly
      expect(result.teamAExpectedScore, greaterThan(0.9));
      
      // They lost (score 0), so delta is 32 * (0 - 0.9) = -28.8 roughly
      // Result stores absolute delta
      expect(result.ratingDelta, closeTo(32.0 * 0.99, 1.0)); // Close to max K-factor
      
      // Verify direction for players
      expect(result.getRatingChange('a1'), lessThan(0)); // Negative for losers
      expect(result.getRatingChange('b1'), greaterThan(0)); // Positive for winners
    });
  });

  group('StatisticsService - Win Percentage', () {
    test('calculateWinPercentage returns correct percentage', () {
      expect(service.calculateWinPercentage(gamesWon: 5, gamesPlayed: 10), 0.5);
      expect(service.calculateWinPercentage(gamesWon: 3, gamesPlayed: 4), 0.75);
      expect(service.calculateWinPercentage(gamesWon: 0, gamesPlayed: 5), 0.0);
    });

    test('calculateWinPercentage handles zero games played', () {
      expect(service.calculateWinPercentage(gamesWon: 0, gamesPlayed: 0), 0.0);
    });
  });

  group('StatisticsService - Streak Calculation', () {
    test('calculateStreak counts winning streak', () {
      // Recent games: Win, Win, Win, Loss
      final results = [true, true, true, false];
      expect(service.calculateStreak(results), 3);
    });

    test('calculateStreak counts losing streak', () {
      // Recent games: Loss, Loss, Win
      final results = [false, false, true];
      expect(service.calculateStreak(results), -2);
    });

    test('calculateStreak returns 0 for empty list', () {
      expect(service.calculateStreak([]), 0);
    });

    test('calculateStreak counts single game streak', () {
      expect(service.calculateStreak([true]), 1);
      expect(service.calculateStreak([false]), -1);
    });
  });

  group('StatisticsService - Best Teammates', () {
    final t1 = const TeammateStats(
      playerId: '1', displayName: 'A', gamesPlayed: 10, gamesWon: 8, gamesLost: 2, winRate: 0.8, averageRatingChange: 5);
    final t2 = const TeammateStats(
      playerId: '2', displayName: 'B', gamesPlayed: 5, gamesWon: 3, gamesLost: 2, winRate: 0.6, averageRatingChange: 2);
    final t3 = const TeammateStats(
      playerId: '3', displayName: 'C', gamesPlayed: 2, gamesWon: 2, gamesLost: 0, winRate: 1.0, averageRatingChange: 10);
    final t4 = const TeammateStats(
      playerId: '4', displayName: 'D', gamesPlayed: 10, gamesWon: 5, gamesLost: 5, winRate: 0.5, averageRatingChange: 0);

    test('getBestTeammates filters by minGames', () {
      final best = service.getBestTeammates([t1, t2, t3], minGames: 3);
      expect(best.length, 2);
      expect(best.map((t) => t.playerId), containsAll(['1', '2']));
      expect(best.map((t) => t.playerId), isNot(contains('3')));
    });

    test('getBestTeammates sorts by winRate descending', () {
      final best = service.getBestTeammates([t1, t2, t4], minGames: 3);
      expect(best.first.playerId, '1'); // 0.8
      expect(best.last.playerId, '4');  // 0.5
    });

    test('getBestTeammates applies limit', () {
      final best = service.getBestTeammates([t1, t2, t4], minGames: 3, limit: 1);
      expect(best.length, 1);
      expect(best.first.playerId, '1');
    });
  });

  group('StatisticsService - Game Summary', () {
    test('summarizeGame identifies winner and loser correctly', () {
      final summary = service.summarizeGame(
        teamAScore: 21,
        teamBScore: 19,
        teamAPlayerIds: ['a1'],
        teamBPlayerIds: ['b1'],
      );

      expect(summary['winner'], 'teamA');
      expect(summary['score'], '21-19');
      expect(summary['margin'], 2);
      expect(summary['close'], true);
      expect(summary['winnerPlayerIds'], ['a1']);
    });

    test('summarizeGame identifies close game correctly', () {
      final summary = service.summarizeGame(
        teamAScore: 21,
        teamBScore: 10,
        teamAPlayerIds: ['a1'],
        teamBPlayerIds: ['b1'],
      );

      expect(summary['margin'], 11);
      expect(summary['close'], false);
    });
  });

  group('StatisticsService - Update Player Stats', () {
    test('updatePlayerStats increments counts correctly', () {
      final updated = service.updatePlayerStats(
        currentGamesPlayed: 10,
        currentGamesWon: 5,
        currentStreak: 1,
        won: true,
      );

      expect(updated['gamesPlayed'], 11);
      expect(updated['gamesWon'], 6);
      expect(updated['gamesLost'], 5); // 11 - 6
      expect(updated['currentStreak'], 2);
    });

    test('updatePlayerStats resets streak on loss', () {
      final updated = service.updatePlayerStats(
        currentGamesPlayed: 10,
        currentGamesWon: 5,
        currentStreak: 5,
        won: false,
      );

      expect(updated['currentStreak'], -1);
    });
  });
}