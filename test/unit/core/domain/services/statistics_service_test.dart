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

    test('calculateElo handles expected win (Strong beats Weak)', () {
      final teamAP1 = const PlayerRating(playerId: 'a1', rating: 2000);
      final teamAP2 = const PlayerRating(playerId: 'a2', rating: 2000);
      final teamBP1 = const PlayerRating(playerId: 'b1', rating: 1200);
      final teamBP2 = const PlayerRating(playerId: 'b2', rating: 1200);

      final result = service.calculateElo(
        teamAPlayer1: teamAP1,
        teamAPlayer2: teamAP2,
        teamBPlayer1: teamBP1,
        teamBPlayer2: teamBP2,
        teamAWon: true, // Strong team wins
      );

      // Delta should be small because outcome was expected
      expect(result.ratingDelta, lessThan(5.0));
    });

    test('calculateElo handles Team B winning correctly', () {
      final teamAP1 = const PlayerRating(playerId: 'a1', rating: 1600);
      final teamAP2 = const PlayerRating(playerId: 'a2', rating: 1600);
      final teamBP1 = const PlayerRating(playerId: 'b1', rating: 1600);
      final teamBP2 = const PlayerRating(playerId: 'b2', rating: 1600);

      final result = service.calculateElo(
        teamAPlayer1: teamAP1,
        teamAPlayer2: teamAP2,
        teamBPlayer1: teamBP1,
        teamBPlayer2: teamBP2,
        teamAWon: false, // Team B wins
      );

      expect(result.ratingDelta, 16.0); // Absolute change
      expect(result.getRatingChange('a1'), -16.0); // Team A loses
      expect(result.getRatingChange('b1'), 16.0); // Team B wins
    });

    test('calculateElo respects custom K-factor', () {
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
        customKFactor: 64.0, // Double normal K
      );

      // Delta = 64 * (1 - 0.5) = 32.0
      expect(result.ratingDelta, 32.0);
    });
  });

  group('EloResult - Helper Methods', () {
    late EloResult result;

    setUp(() {
      result = service.calculateElo(
        teamAPlayer1: const PlayerRating(playerId: 'a1', rating: 1600),
        teamAPlayer2: const PlayerRating(playerId: 'a2', rating: 1650),
        teamBPlayer1: const PlayerRating(playerId: 'b1', rating: 1700),
        teamBPlayer2: const PlayerRating(playerId: 'b2', rating: 1750),
        teamAWon: true,
      );
    });

    test('getNewRating returns correct rating for all Team A players', () {
      final delta = result.ratingDelta;
      expect(result.getNewRating('a1'), closeTo(1600 + delta, 0.01));
      expect(result.getNewRating('a2'), closeTo(1650 + delta, 0.01));
    });

    test('getNewRating returns correct rating for all Team B players', () {
      final delta = result.ratingDelta;
      expect(result.getNewRating('b1'), closeTo(1700 - delta, 0.01));
      expect(result.getNewRating('b2'), closeTo(1750 - delta, 0.01));
    });

    test('getNewRating throws ArgumentError for invalid player ID', () {
      expect(
        () => result.getNewRating('invalid-id'),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('getRatingChange returns positive for winning team players', () {
      expect(result.getRatingChange('a1'), greaterThan(0));
      expect(result.getRatingChange('a2'), greaterThan(0));
    });

    test('getRatingChange returns negative for losing team players', () {
      expect(result.getRatingChange('b1'), lessThan(0));
      expect(result.getRatingChange('b2'), lessThan(0));
    });

    test('getRatingChange returns same absolute value for all players', () {
      final changeA1 = result.getRatingChange('a1');
      final changeA2 = result.getRatingChange('a2');
      final changeB1 = result.getRatingChange('b1');
      final changeB2 = result.getRatingChange('b2');

      expect(changeA1, changeA2); // Same team, same change
      expect(changeA1.abs(), changeB1.abs()); // Opposite teams, same magnitude
      expect(changeA2.abs(), changeB2.abs());
    });

    test('getRatingChange throws ArgumentError for invalid player ID', () {
      expect(
        () => result.getRatingChange('invalid-id'),
        throwsA(isA<ArgumentError>()),
      );
    });
  });

  group('TeammateStats - Getters', () {
    test('hasWinningRecord returns true for win rate > 50%', () {
      final stats = const TeammateStats(
        playerId: '1',
        displayName: 'Alice',
        gamesPlayed: 10,
        gamesWon: 6,
        gamesLost: 4,
        winRate: 0.6,
        averageRatingChange: 5.0,
      );

      expect(stats.hasWinningRecord, true);
    });

    test('hasWinningRecord returns false for win rate = 50%', () {
      final stats = const TeammateStats(
        playerId: '1',
        displayName: 'Bob',
        gamesPlayed: 10,
        gamesWon: 5,
        gamesLost: 5,
        winRate: 0.5,
        averageRatingChange: 0.0,
      );

      expect(stats.hasWinningRecord, false);
    });

    test('hasWinningRecord returns false for win rate < 50%', () {
      final stats = const TeammateStats(
        playerId: '1',
        displayName: 'Charlie',
        gamesPlayed: 10,
        gamesWon: 4,
        gamesLost: 6,
        winRate: 0.4,
        averageRatingChange: -2.0,
      );

      expect(stats.hasWinningRecord, false);
    });

    test('isFrequentTeammate returns true for 5+ games', () {
      final stats = const TeammateStats(
        playerId: '1',
        displayName: 'Alice',
        gamesPlayed: 5,
        gamesWon: 3,
        gamesLost: 2,
        winRate: 0.6,
        averageRatingChange: 5.0,
      );

      expect(stats.isFrequentTeammate, true);
    });

    test('isFrequentTeammate returns true for more than 5 games', () {
      final stats = const TeammateStats(
        playerId: '1',
        displayName: 'Bob',
        gamesPlayed: 10,
        gamesWon: 7,
        gamesLost: 3,
        winRate: 0.7,
        averageRatingChange: 8.0,
      );

      expect(stats.isFrequentTeammate, true);
    });

    test('isFrequentTeammate returns false for < 5 games', () {
      final stats = const TeammateStats(
        playerId: '1',
        displayName: 'Charlie',
        gamesPlayed: 4,
        gamesWon: 3,
        gamesLost: 1,
        winRate: 0.75,
        averageRatingChange: 10.0,
      );

      expect(stats.isFrequentTeammate, false);
    });

    test('formattedWinRate returns percentage string with 1 decimal', () {
      final stats = const TeammateStats(
        playerId: '1',
        displayName: 'Alice',
        gamesPlayed: 10,
        gamesWon: 7,
        gamesLost: 3,
        winRate: 0.7,
        averageRatingChange: 5.0,
      );

      expect(stats.formattedWinRate, '70.0%');
    });

    test('formattedWinRate handles 100% correctly', () {
      final stats = const TeammateStats(
        playerId: '1',
        displayName: 'Bob',
        gamesPlayed: 5,
        gamesWon: 5,
        gamesLost: 0,
        winRate: 1.0,
        averageRatingChange: 15.0,
      );

      expect(stats.formattedWinRate, '100.0%');
    });

    test('formattedWinRate handles 0% correctly', () {
      final stats = const TeammateStats(
        playerId: '1',
        displayName: 'Charlie',
        gamesPlayed: 5,
        gamesWon: 0,
        gamesLost: 5,
        winRate: 0.0,
        averageRatingChange: -10.0,
      );

      expect(stats.formattedWinRate, '0.0%');
    });

    test('formattedWinRate handles decimal win rates correctly', () {
      final stats = const TeammateStats(
        playerId: '1',
        displayName: 'Dave',
        gamesPlayed: 9,
        gamesWon: 5,
        gamesLost: 4,
        winRate: 0.5555,
        averageRatingChange: 2.5,
      );

      // 0.5555 * 100 = 55.55, toStringAsFixed(1) = '55.5'
      expect(stats.formattedWinRate, '55.5%');
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

    test('calculateWinPercentage handles negative games played gracefully', () {
      expect(service.calculateWinPercentage(gamesWon: 5, gamesPlayed: -1), 0.0);
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

    test('getBestTeammates handles empty list', () {
      final best = service.getBestTeammates([], minGames: 3);
      expect(best, isEmpty);
    });

    test('getBestTeammates breaks ties with games played', () {
      final tTie1 = const TeammateStats(playerId: 't1', displayName: 'T1', gamesPlayed: 10, gamesWon: 5, gamesLost: 5, winRate: 0.5, averageRatingChange: 0);
      final tTie2 = const TeammateStats(playerId: 't2', displayName: 'T2', gamesPlayed: 20, gamesWon: 10, gamesLost: 10, winRate: 0.5, averageRatingChange: 0);
      
      final best = service.getBestTeammates([tTie1, tTie2], minGames: 1);
      
      expect(best.first.playerId, 't2'); // More games played comes first
      expect(best.last.playerId, 't1');
    });
  });

  group('StatisticsService - Game Summary', () {
    test('summarizeGame identifies winner and loser correctly (Team A)', () {
      final summary = service.summarizeGame(
        teamAScore: 21,
        teamBScore: 19,
        teamAPlayerIds: ['a1'],
        teamBPlayerIds: ['b1'],
      );

      expect(summary['winner'], 'teamA');
      expect(summary['loser'], 'teamB');
      expect(summary['score'], '21-19');
      expect(summary['margin'], 2);
      expect(summary['close'], true);
      expect(summary['winnerPlayerIds'], ['a1']);
      expect(summary['loserPlayerIds'], ['b1']);
    });

    test('summarizeGame identifies winner and loser correctly (Team B)', () {
      final summary = service.summarizeGame(
        teamAScore: 15,
        teamBScore: 21,
        teamAPlayerIds: ['a1'],
        teamBPlayerIds: ['b1'],
      );

      expect(summary['winner'], 'teamB');
      expect(summary['loser'], 'teamA');
      expect(summary['score'], '15-21');
      expect(summary['winnerPlayerIds'], ['b1']);
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

    test('summarizeGame returns all required fields', () {
      final summary = service.summarizeGame(
        teamAScore: 21,
        teamBScore: 19,
        teamAPlayerIds: ['a1', 'a2'],
        teamBPlayerIds: ['b1', 'b2'],
      );

      // Verify all required fields are present
      expect(summary, containsPair('winner', 'teamA'));
      expect(summary, containsPair('loser', 'teamB'));
      expect(summary, containsPair('score', '21-19'));
      expect(summary, containsPair('teamAScore', 21));
      expect(summary, containsPair('teamBScore', 19));
      expect(summary, containsPair('margin', 2));
      expect(summary, containsPair('close', true));
      expect(summary['teamAPlayerIds'], ['a1', 'a2']);
      expect(summary['teamBPlayerIds'], ['b1', 'b2']);
      expect(summary['winnerPlayerIds'], ['a1', 'a2']);
      expect(summary['loserPlayerIds'], ['b1', 'b2']);
    });

    test('summarizeGame handles edge case of 2-point margin (close)', () {
      final summary = service.summarizeGame(
        teamAScore: 21,
        teamBScore: 19,
        teamAPlayerIds: ['a1'],
        teamBPlayerIds: ['b1'],
      );

      expect(summary['margin'], 2);
      expect(summary['close'], true); // Exactly 2 points = close
    });

    test('summarizeGame handles edge case of 3-point margin (not close)', () {
      final summary = service.summarizeGame(
        teamAScore: 21,
        teamBScore: 18,
        teamAPlayerIds: ['a1'],
        teamBPlayerIds: ['b1'],
      );

      expect(summary['margin'], 3);
      expect(summary['close'], false); // 3 points = not close
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

    test('updatePlayerStats continues negative streak', () {
      final updated = service.updatePlayerStats(
        currentGamesPlayed: 10,
        currentGamesWon: 5,
        currentStreak: -2,
        won: false,
      );
      expect(updated['currentStreak'], -3);
    });

    test('updatePlayerStats breaks negative streak with win', () {
      final updated = service.updatePlayerStats(
        currentGamesPlayed: 10,
        currentGamesWon: 5,
        currentStreak: -5,
        won: true,
      );
      expect(updated['currentStreak'], 1);
    });

    test('updatePlayerStats starts streak from zero (win)', () {
      final updated = service.updatePlayerStats(
        currentGamesPlayed: 0,
        currentGamesWon: 0,
        currentStreak: 0,
        won: true,
      );
      expect(updated['currentStreak'], 1);
    });

    test('updatePlayerStats starts streak from zero (loss)', () {
      final updated = service.updatePlayerStats(
        currentGamesPlayed: 0,
        currentGamesWon: 0,
        currentStreak: 0,
        won: false,
      );
      expect(updated['currentStreak'], -1);
    });
  });

  group('StatisticsService - Comprehensive ELO Scenarios (Story 14.10)', () {
    group('Equal Teams Scenario (1200 vs 1200)', () {
      test('equal teams at 1200 rating result in ±16 rating change with K=32', () {
        final teamAP1 = const PlayerRating(playerId: 'a1', rating: 1200);
        final teamAP2 = const PlayerRating(playerId: 'a2', rating: 1200);
        final teamBP1 = const PlayerRating(playerId: 'b1', rating: 1200);
        final teamBP2 = const PlayerRating(playerId: 'b2', rating: 1200);

        final result = service.calculateElo(
          teamAPlayer1: teamAP1,
          teamAPlayer2: teamAP2,
          teamBPlayer1: teamBP1,
          teamBPlayer2: teamBP2,
          teamAWon: true,
          customKFactor: 32,
        );

        // Team A: [1200, 1200] → Team Rating: 1200
        // Team B: [1200, 1200] → Team Rating: 1200
        // Expected: E = 0.5
        // If Team A wins: ΔR = 32 * (1 - 0.5) = +16
        expect(result.teamARating, 1200);
        expect(result.teamBRating, 1200);
        expect(result.teamAExpectedScore, 0.5);
        expect(result.ratingDelta, closeTo(16, 0.5));
      });

      test('equal teams - Team B wins results in opposite delta', () {
        final teamAP1 = const PlayerRating(playerId: 'a1', rating: 1200);
        final teamAP2 = const PlayerRating(playerId: 'a2', rating: 1200);
        final teamBP1 = const PlayerRating(playerId: 'b1', rating: 1200);
        final teamBP2 = const PlayerRating(playerId: 'b2', rating: 1200);

        final result = service.calculateElo(
          teamAPlayer1: teamAP1,
          teamAPlayer2: teamAP2,
          teamBPlayer1: teamBP1,
          teamBPlayer2: teamBP2,
          teamAWon: false, // Team B wins
          customKFactor: 32,
        );

        // If Team B wins: ΔR = 32 * (0 - 0.5) = -16
        expect(result.ratingDelta, closeTo(16, 0.5));
        expect(result.getRatingChange('a1'), closeTo(-16, 0.5));
        expect(result.getRatingChange('b1'), closeTo(16, 0.5));
      });
    });

    group('Strong Team Wins (Expected) - 1400 vs 1000', () {
      test('strong team (1400) beats weak team (1000) with minimal gain', () {
        final teamAP1 = const PlayerRating(playerId: 'a1', rating: 1400);
        final teamAP2 = const PlayerRating(playerId: 'a2', rating: 1400);
        final teamBP1 = const PlayerRating(playerId: 'b1', rating: 1000);
        final teamBP2 = const PlayerRating(playerId: 'b2', rating: 1000);

        final result = service.calculateElo(
          teamAPlayer1: teamAP1,
          teamAPlayer2: teamAP2,
          teamBPlayer1: teamBP1,
          teamBPlayer2: teamBP2,
          teamAWon: true,
        );

        // Team A: [1400, 1400] → Team Rating: 1400
        // Team B: [1000, 1000] → Team Rating: 1000
        // Expected: E_A ≈ 0.91 (91% chance to win)
        // If Team A wins: ΔR = 32 * (1 - 0.91) ≈ +3
        expect(result.teamARating, 1400);
        expect(result.teamBRating, 1000);
        expect(result.teamAExpectedScore, greaterThan(0.9));
        expect(result.teamAExpectedScore, lessThan(0.92));
        expect(result.ratingDelta, lessThan(4));
        expect(result.ratingDelta, greaterThan(2));
      });

      test('weak team (1000) beats strong team (1400) with huge gain (upset)', () {
        final teamAP1 = const PlayerRating(playerId: 'a1', rating: 1000);
        final teamAP2 = const PlayerRating(playerId: 'a2', rating: 1000);
        final teamBP1 = const PlayerRating(playerId: 'b1', rating: 1400);
        final teamBP2 = const PlayerRating(playerId: 'b2', rating: 1400);

        final result = service.calculateElo(
          teamAPlayer1: teamAP1,
          teamAPlayer2: teamAP2,
          teamBPlayer1: teamBP1,
          teamBPlayer2: teamBP2,
          teamAWon: true, // Weak team wins (upset!)
        );

        // If Team B (weak) wins: ΔR = 32 * (1 - 0.09) ≈ +29 (upset!)
        expect(result.teamAExpectedScore, lessThan(0.1));
        expect(result.ratingDelta, greaterThan(28));
      });
    });

    group('Weak-Link Effect - Exact Scenario from Issue', () {
      test('weak link drags down team rating: [1500, 1100] vs [1300, 1300]', () {
        final teamAP1 = const PlayerRating(playerId: 'a1', rating: 1500);
        final teamAP2 = const PlayerRating(playerId: 'a2', rating: 1100); // Weak link
        final teamBP1 = const PlayerRating(playerId: 'b1', rating: 1300);
        final teamBP2 = const PlayerRating(playerId: 'b2', rating: 1300);

        final result = service.calculateElo(
          teamAPlayer1: teamAP1,
          teamAPlayer2: teamAP2,
          teamBPlayer1: teamBP1,
          teamBPlayer2: teamBP2,
          teamAWon: true,
        );

        // Team A: [1500, 1100] → Team Rating: 0.7*1100 + 0.3*1500 = 1220
        // Team B: [1300, 1300] → Team Rating: 1300
        // Despite higher max rating, Team A's weak link gives them lower team rating
        expect(result.teamARating, closeTo(1220, 0.5));
        expect(result.teamBRating, 1300);
        expect(result.teamARating, lessThan(result.teamBRating));
      });
    });

    group('Variable K-Factors', () {
      test('K=16 (established players) results in slower rating changes', () {
        final teamAP1 = const PlayerRating(playerId: 'a1', rating: 1200);
        final teamAP2 = const PlayerRating(playerId: 'a2', rating: 1200);
        final teamBP1 = const PlayerRating(playerId: 'b1', rating: 1200);
        final teamBP2 = const PlayerRating(playerId: 'b2', rating: 1200);

        final result = service.calculateElo(
          teamAPlayer1: teamAP1,
          teamAPlayer2: teamAP2,
          teamBPlayer1: teamBP1,
          teamBPlayer2: teamBP2,
          teamAWon: true,
          customKFactor: 16,
        );

        // K=16 (established players): Slower rating changes
        // Delta = 16 * (1 - 0.5) = 8
        expect(result.ratingDelta, closeTo(8, 0.5));
      });

      test('K=32 (default) results in moderate rating changes', () {
        final teamAP1 = const PlayerRating(playerId: 'a1', rating: 1200);
        final teamAP2 = const PlayerRating(playerId: 'a2', rating: 1200);
        final teamBP1 = const PlayerRating(playerId: 'b1', rating: 1200);
        final teamBP2 = const PlayerRating(playerId: 'b2', rating: 1200);

        final result = service.calculateElo(
          teamAPlayer1: teamAP1,
          teamAPlayer2: teamAP2,
          teamBPlayer1: teamBP1,
          teamBPlayer2: teamBP2,
          teamAWon: true,
          customKFactor: 32,
        );

        // K=32 (default): Moderate changes
        // Delta = 32 * (1 - 0.5) = 16
        expect(result.ratingDelta, closeTo(16, 0.5));
      });

      test('K=64 (provisional ratings) results in rapid adjustments', () {
        final teamAP1 = const PlayerRating(playerId: 'a1', rating: 1200);
        final teamAP2 = const PlayerRating(playerId: 'a2', rating: 1200);
        final teamBP1 = const PlayerRating(playerId: 'b1', rating: 1200);
        final teamBP2 = const PlayerRating(playerId: 'b2', rating: 1200);

        final result = service.calculateElo(
          teamAPlayer1: teamAP1,
          teamAPlayer2: teamAP2,
          teamBPlayer1: teamBP1,
          teamBPlayer2: teamBP2,
          teamAWon: true,
          customKFactor: 64,
        );

        // K=64 (provisional ratings): Rapid adjustments
        // Delta = 64 * (1 - 0.5) = 32
        expect(result.ratingDelta, closeTo(32, 0.5));
      });

      test('K-factors scale proportionally (K=16 is half of K=32, K=64 is double)', () {
        final teamAP1 = const PlayerRating(playerId: 'a1', rating: 1200);
        final teamAP2 = const PlayerRating(playerId: 'a2', rating: 1200);
        final teamBP1 = const PlayerRating(playerId: 'b1', rating: 1200);
        final teamBP2 = const PlayerRating(playerId: 'b2', rating: 1200);

        final resultK16 = service.calculateElo(
          teamAPlayer1: teamAP1,
          teamAPlayer2: teamAP2,
          teamBPlayer1: teamBP1,
          teamBPlayer2: teamBP2,
          teamAWon: true,
          customKFactor: 16,
        );

        final resultK32 = service.calculateElo(
          teamAPlayer1: teamAP1,
          teamAPlayer2: teamAP2,
          teamBPlayer1: teamBP1,
          teamBPlayer2: teamBP2,
          teamAWon: true,
          customKFactor: 32,
        );

        final resultK64 = service.calculateElo(
          teamAPlayer1: teamAP1,
          teamAPlayer2: teamAP2,
          teamBPlayer1: teamBP1,
          teamBPlayer2: teamBP2,
          teamAWon: true,
          customKFactor: 64,
        );

        expect(resultK16.ratingDelta, closeTo(8, 0.5));
        expect(resultK32.ratingDelta, closeTo(16, 0.5));
        expect(resultK64.ratingDelta, closeTo(32, 0.5));

        // Verify proportional scaling
        expect(resultK32.ratingDelta, closeTo(resultK16.ratingDelta * 2, 0.5));
        expect(resultK64.ratingDelta, closeTo(resultK32.ratingDelta * 2, 0.5));
      });
    });

    group('Large Rating Gap (>400 points)', () {
      test('very large rating gap (1200 points) results in minimal change for favorite', () {
        final teamAP1 = const PlayerRating(playerId: 'a1', rating: 2000);
        final teamAP2 = const PlayerRating(playerId: 'a2', rating: 2000);
        final teamBP1 = const PlayerRating(playerId: 'b1', rating: 800);
        final teamBP2 = const PlayerRating(playerId: 'b2', rating: 800);

        final result = service.calculateElo(
          teamAPlayer1: teamAP1,
          teamAPlayer2: teamAP2,
          teamBPlayer1: teamBP1,
          teamBPlayer2: teamBP2,
          teamAWon: true, // Expected outcome
        );

        // Team A: [2000, 2000]
        // Team B: [800, 800]
        // Expected: E_A ≈ 0.99 (99.6% chance)
        // Team A win: ΔR ≈ +0.13 (negligible)
        expect(result.teamARating, 2000);
        expect(result.teamBRating, 800);
        expect(result.teamAExpectedScore, greaterThan(0.99));
        expect(result.ratingDelta, lessThan(1)); // Almost no change
      });

      test('huge upset (800 beats 2000) results in maximum rating swing', () {
        final teamAP1 = const PlayerRating(playerId: 'a1', rating: 800);
        final teamAP2 = const PlayerRating(playerId: 'a2', rating: 800);
        final teamBP1 = const PlayerRating(playerId: 'b1', rating: 2000);
        final teamBP2 = const PlayerRating(playerId: 'b2', rating: 2000);

        final result = service.calculateElo(
          teamAPlayer1: teamAP1,
          teamAPlayer2: teamAP2,
          teamBPlayer1: teamBP1,
          teamBPlayer2: teamBP2,
          teamAWon: true, // Huge upset!
        );

        // Team B win: ΔR ≈ +31.87 (huge upset bonus)
        expect(result.teamAExpectedScore, lessThan(0.01));
        expect(result.ratingDelta, greaterThan(31)); // Nearly full K-factor
      });
    });

    group('Expected Win Probability Validation', () {
      test('rating difference of 0 results in 50% expected win probability', () {
        final result = service.calculateElo(
          teamAPlayer1: const PlayerRating(playerId: 'a1', rating: 1500),
          teamAPlayer2: const PlayerRating(playerId: 'a2', rating: 1500),
          teamBPlayer1: const PlayerRating(playerId: 'b1', rating: 1500),
          teamBPlayer2: const PlayerRating(playerId: 'b2', rating: 1500),
          teamAWon: true,
        );

        expect(result.teamAExpectedScore, closeTo(0.5, 0.01));
      });

      test('rating difference of 100 results in ~64% expected win probability', () {
        final result = service.calculateElo(
          teamAPlayer1: const PlayerRating(playerId: 'a1', rating: 1550),
          teamAPlayer2: const PlayerRating(playerId: 'a2', rating: 1550),
          teamBPlayer1: const PlayerRating(playerId: 'b1', rating: 1450),
          teamBPlayer2: const PlayerRating(playerId: 'b2', rating: 1450),
          teamAWon: true,
        );

        // Rating Difference: 100 → Expected Win: 64%
        expect(result.teamARating, 1550);
        expect(result.teamBRating, 1450);
        expect(result.teamAExpectedScore, closeTo(0.64, 0.02));
      });

      test('rating difference of 200 results in ~76% expected win probability', () {
        final result = service.calculateElo(
          teamAPlayer1: const PlayerRating(playerId: 'a1', rating: 1600),
          teamAPlayer2: const PlayerRating(playerId: 'a2', rating: 1600),
          teamBPlayer1: const PlayerRating(playerId: 'b1', rating: 1400),
          teamBPlayer2: const PlayerRating(playerId: 'b2', rating: 1400),
          teamAWon: true,
        );

        // Rating Difference: 200 → Expected Win: 76%
        expect(result.teamARating, 1600);
        expect(result.teamBRating, 1400);
        expect(result.teamAExpectedScore, closeTo(0.76, 0.02));
      });

      test('rating difference of 400 results in ~91% expected win probability', () {
        final result = service.calculateElo(
          teamAPlayer1: const PlayerRating(playerId: 'a1', rating: 1700),
          teamAPlayer2: const PlayerRating(playerId: 'a2', rating: 1700),
          teamBPlayer1: const PlayerRating(playerId: 'b1', rating: 1300),
          teamBPlayer2: const PlayerRating(playerId: 'b2', rating: 1300),
          teamAWon: true,
        );

        // Rating Difference: 400 → Expected Win: 91%
        expect(result.teamARating, 1700);
        expect(result.teamBRating, 1300);
        expect(result.teamAExpectedScore, closeTo(0.91, 0.02));
      });

      test('rating difference of 800 results in ~99% expected win probability', () {
        final result = service.calculateElo(
          teamAPlayer1: const PlayerRating(playerId: 'a1', rating: 1900),
          teamAPlayer2: const PlayerRating(playerId: 'a2', rating: 1900),
          teamBPlayer1: const PlayerRating(playerId: 'b1', rating: 1100),
          teamBPlayer2: const PlayerRating(playerId: 'b2', rating: 1100),
          teamAWon: true,
        );

        // Rating Difference: 800 → Expected Win: 99%
        expect(result.teamARating, 1900);
        expect(result.teamBRating, 1100);
        expect(result.teamAExpectedScore, closeTo(0.99, 0.01));
      });
    });
  });
}
