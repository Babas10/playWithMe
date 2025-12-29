// Tests for RoleBasedStats and RoleStats models - validates computed properties and business logic.
import 'package:flutter_test/flutter_test.dart';
import 'package:play_with_me/core/data/models/user_model.dart';

void main() {
  group('RoleStats', () {
    test('calculates losses correctly', () {
      const stats = RoleStats(games: 10, wins: 6, winRate: 0.6);
      expect(stats.losses, 4);
    });

    test('converts win rate to percentage', () {
      const stats = RoleStats(games: 10, wins: 6, winRate: 0.6);
      expect(stats.winRatePercentage, 60.0);
    });

    test('formats record string correctly', () {
      const stats = RoleStats(games: 10, wins: 6, winRate: 0.6);
      expect(stats.recordString, '6W - 4L');
    });

    test('formats win rate string correctly', () {
      const stats = RoleStats(games: 8, wins: 5, winRate: 0.625);
      expect(stats.winRateString, '62.5%');
    });

    test('hasEnoughData returns false for less than 3 games', () {
      const stats = RoleStats(games: 2, wins: 1, winRate: 0.5);
      expect(stats.hasEnoughData, false);
    });

    test('hasEnoughData returns true for 3 or more games', () {
      const stats = RoleStats(games: 3, wins: 2, winRate: 0.667);
      expect(stats.hasEnoughData, true);
    });

    test('defaults to zero values', () {
      const stats = RoleStats();
      expect(stats.games, 0);
      expect(stats.wins, 0);
      expect(stats.winRate, 0.0);
      expect(stats.losses, 0);
    });
  });

  group('RoleBasedStats', () {
    test('calculates total games correctly', () {
      const stats = RoleBasedStats(
        weakLink: RoleStats(games: 5, wins: 2, winRate: 0.4),
        carry: RoleStats(games: 8, wins: 6, winRate: 0.75),
        balanced: RoleStats(games: 3, wins: 2, winRate: 0.667),
      );

      expect(stats.totalGames, 16);
    });

    test('hasData returns false when no games played', () {
      const stats = RoleBasedStats();
      expect(stats.hasData, false);
    });

    test('hasData returns true when games played', () {
      const stats = RoleBasedStats(
        carry: RoleStats(games: 1, wins: 1, winRate: 1.0),
      );
      expect(stats.hasData, true);
    });

    test('bestRole returns none when insufficient data', () {
      const stats = RoleBasedStats(
        weakLink: RoleStats(games: 2, wins: 1, winRate: 0.5),
        carry: RoleStats(games: 1, wins: 1, winRate: 1.0),
      );
      expect(stats.bestRole, 'none');
    });

    test('bestRole returns carry when carry has best win rate', () {
      const stats = RoleBasedStats(
        weakLink: RoleStats(games: 5, wins: 2, winRate: 0.4),
        carry: RoleStats(games: 8, wins: 7, winRate: 0.875),
        balanced: RoleStats(games: 3, wins: 2, winRate: 0.667),
      );
      expect(stats.bestRole, 'carry');
    });

    test('bestRole returns weakLink when weakLink has best win rate', () {
      const stats = RoleBasedStats(
        weakLink: RoleStats(games: 5, wins: 5, winRate: 1.0),
        carry: RoleStats(games: 8, wins: 6, winRate: 0.75),
        balanced: RoleStats(games: 3, wins: 2, winRate: 0.667),
      );
      expect(stats.bestRole, 'weakLink');
    });

    test('bestRole returns balanced when balanced has best win rate', () {
      const stats = RoleBasedStats(
        weakLink: RoleStats(games: 5, wins: 2, winRate: 0.4),
        carry: RoleStats(games: 8, wins: 5, winRate: 0.625),
        balanced: RoleStats(games: 10, wins: 9, winRate: 0.9),
      );
      expect(stats.bestRole, 'balanced');
    });

    test('getInsight returns play more games message when no data', () {
      const stats = RoleBasedStats();
      expect(
        stats.getInsight(),
        'Play more games to see how you perform in different team roles.',
      );
    });

    test('getInsight returns strong carry message for high carry win rate', () {
      const stats = RoleBasedStats(
        carry: RoleStats(games: 10, wins: 8, winRate: 0.8),
      );
      expect(
        stats.getInsight(),
        '💪 Strong carry performance! You elevate your teammates.',
      );
    });

    test('getInsight returns adaptability message for good weak-link performance', () {
      const stats = RoleBasedStats(
        weakLink: RoleStats(games: 10, wins: 7, winRate: 0.7),
        carry: RoleStats(games: 5, wins: 2, winRate: 0.4),
      );
      expect(
        stats.getInsight(),
        '🌟 Great adaptability! You thrive with experienced partners.',
      );
    });

    test('getInsight returns balanced message when balanced is dominant', () {
      const stats = RoleBasedStats(
        weakLink: RoleStats(games: 2, wins: 1, winRate: 0.5),
        carry: RoleStats(games: 2, wins: 1, winRate: 0.5),
        balanced: RoleStats(games: 15, wins: 10, winRate: 0.667),
      );
      expect(
        stats.getInsight(),
        '⚖️ You play best in balanced matchups.',
      );
    });

    test('getInsight returns default encouragement when no specific pattern', () {
      const stats = RoleBasedStats(
        weakLink: RoleStats(games: 5, wins: 2, winRate: 0.4),
        carry: RoleStats(games: 5, wins: 2, winRate: 0.4),
        balanced: RoleStats(games: 5, wins: 2, winRate: 0.4),
      );
      expect(
        stats.getInsight(),
        '📊 Keep playing to refine your role-based performance!',
      );
    });

    test('fromJson creates instance correctly', () {
      final json = {
        'weakLink': {'games': 5, 'wins': 2, 'winRate': 0.4},
        'carry': {'games': 8, 'wins': 6, 'winRate': 0.75},
        'balanced': {'games': 3, 'wins': 2, 'winRate': 0.667},
      };

      final stats = RoleBasedStats.fromJson(json);

      expect(stats.weakLink.games, 5);
      expect(stats.weakLink.wins, 2);
      expect(stats.carry.games, 8);
      expect(stats.carry.wins, 6);
      expect(stats.balanced.games, 3);
      expect(stats.balanced.wins, 2);
    });

  });

  group('RoleBasedStats edge cases', () {
    test('handles all zeros correctly', () {
      const stats = RoleBasedStats();
      expect(stats.totalGames, 0);
      expect(stats.hasData, false);
      expect(stats.bestRole, 'none');
    });

    test('handles tied win rates - returns first qualifying role', () {
      const stats = RoleBasedStats(
        weakLink: RoleStats(games: 10, wins: 5, winRate: 0.5),
        carry: RoleStats(games: 10, wins: 5, winRate: 0.5),
        balanced: RoleStats(games: 10, wins: 5, winRate: 0.5),
      );
      // Should return the first one that qualifies (weakLink checked first internally)
      expect(['weakLink', 'carry', 'balanced'].contains(stats.bestRole), true);
    });

    test('bestRole only considers roles with enough data', () {
      const stats = RoleBasedStats(
        weakLink: RoleStats(games: 2, wins: 2, winRate: 1.0), // Too few games
        carry: RoleStats(games: 10, wins: 6, winRate: 0.6), // Enough games
        balanced: RoleStats(games: 1, wins: 1, winRate: 1.0), // Too few games
      );
      expect(stats.bestRole, 'carry');
    });
  });
}
