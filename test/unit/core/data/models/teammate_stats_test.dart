// Tests TeammateStats and RecentGameResult models for partner performance tracking (Story 16.3.3.1).

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:play_with_me/core/data/models/teammate_stats.dart';

void main() {
  group('TeammateStats', () {
    final testDate = DateTime(2025, 12, 29, 10, 30);
    final testTimestamp = Timestamp.fromDate(testDate);

    group('constructor', () {
      test('creates instance with all required fields', () {
        final stats = TeammateStats(
          userId: 'user-123',
          gamesPlayed: 20,
          gamesWon: 12,
          gamesLost: 8,
          pointsScored: 400,
          pointsAllowed: 350,
          eloChange: 45.5,
          recentGames: [],
          lastUpdated: testDate,
        );

        expect(stats.userId, equals('user-123'));
        expect(stats.gamesPlayed, equals(20));
        expect(stats.gamesWon, equals(12));
        expect(stats.gamesLost, equals(8));
        expect(stats.pointsScored, equals(400));
        expect(stats.pointsAllowed, equals(350));
        expect(stats.eloChange, equals(45.5));
        expect(stats.recentGames, isEmpty);
        expect(stats.lastUpdated, equals(testDate));
      });

      test('creates instance with default values', () {
        final stats = TeammateStats(
          userId: 'user-456',
          gamesPlayed: 10,
          gamesWon: 5,
          gamesLost: 5,
        );

        expect(stats.pointsScored, equals(0));
        expect(stats.pointsAllowed, equals(0));
        expect(stats.eloChange, equals(0.0));
        expect(stats.recentGames, isEmpty);
        expect(stats.lastUpdated, isNull);
      });
    });

    group('winRate', () {
      test('calculates win rate correctly', () {
        final stats = TeammateStats(
          userId: 'user-1',
          gamesPlayed: 20,
          gamesWon: 12,
          gamesLost: 8,
        );

        expect(stats.winRate, equals(60.0));
      });

      test('returns 0 when no games played', () {
        final stats = TeammateStats(
          userId: 'user-1',
          gamesPlayed: 0,
          gamesWon: 0,
          gamesLost: 0,
        );

        expect(stats.winRate, equals(0.0));
      });

      test('calculates 100% win rate', () {
        final stats = TeammateStats(
          userId: 'user-1',
          gamesPlayed: 10,
          gamesWon: 10,
          gamesLost: 0,
        );

        expect(stats.winRate, equals(100.0));
      });
    });

    group('lossRate', () {
      test('calculates loss rate correctly', () {
        final stats = TeammateStats(
          userId: 'user-1',
          gamesPlayed: 20,
          gamesWon: 12,
          gamesLost: 8,
        );

        expect(stats.lossRate, equals(40.0));
      });

      test('returns 0 when no games played', () {
        final stats = TeammateStats(
          userId: 'user-1',
          gamesPlayed: 0,
          gamesWon: 0,
          gamesLost: 0,
        );

        expect(stats.lossRate, equals(0.0));
      });
    });

    group('avgPointsScored', () {
      test('calculates average points scored correctly', () {
        final stats = TeammateStats(
          userId: 'user-1',
          gamesPlayed: 10,
          gamesWon: 5,
          gamesLost: 5,
          pointsScored: 200,
        );

        expect(stats.avgPointsScored, equals(20.0));
      });

      test('returns 0 when no games played', () {
        final stats = TeammateStats(
          userId: 'user-1',
          gamesPlayed: 0,
          gamesWon: 0,
          gamesLost: 0,
          pointsScored: 0,
        );

        expect(stats.avgPointsScored, equals(0.0));
      });
    });

    group('avgPointsAllowed', () {
      test('calculates average points allowed correctly', () {
        final stats = TeammateStats(
          userId: 'user-1',
          gamesPlayed: 10,
          gamesWon: 5,
          gamesLost: 5,
          pointsAllowed: 180,
        );

        expect(stats.avgPointsAllowed, equals(18.0));
      });

      test('returns 0 when no games played', () {
        final stats = TeammateStats(
          userId: 'user-1',
          gamesPlayed: 0,
          gamesWon: 0,
          gamesLost: 0,
        );

        expect(stats.avgPointsAllowed, equals(0.0));
      });
    });

    group('avgPointDifferential', () {
      test('calculates positive point differential', () {
        final stats = TeammateStats(
          userId: 'user-1',
          gamesPlayed: 10,
          gamesWon: 7,
          gamesLost: 3,
          pointsScored: 200,
          pointsAllowed: 150,
        );

        expect(stats.avgPointDifferential, equals(5.0)); // 20 - 15
      });

      test('calculates negative point differential', () {
        final stats = TeammateStats(
          userId: 'user-1',
          gamesPlayed: 10,
          gamesWon: 3,
          gamesLost: 7,
          pointsScored: 150,
          pointsAllowed: 200,
        );

        expect(stats.avgPointDifferential, equals(-5.0)); // 15 - 20
      });
    });

    group('avgEloChange', () {
      test('calculates average ELO change correctly', () {
        final stats = TeammateStats(
          userId: 'user-1',
          gamesPlayed: 10,
          gamesWon: 6,
          gamesLost: 4,
          eloChange: 50.0,
        );

        expect(stats.avgEloChange, equals(5.0));
      });

      test('returns 0 when no games played', () {
        final stats = TeammateStats(
          userId: 'user-1',
          gamesPlayed: 0,
          gamesWon: 0,
          gamesLost: 0,
        );

        expect(stats.avgEloChange, equals(0.0));
      });
    });

    group('currentStreak', () {
      test('returns positive streak for consecutive wins', () {
        final stats = TeammateStats(
          userId: 'user-1',
          gamesPlayed: 5,
          gamesWon: 3,
          gamesLost: 2,
          recentGames: [
            RecentGameResult(
              gameId: 'g1',
              won: true,
              pointsScored: 21,
              pointsAllowed: 15,
              eloChange: 10.0,
              timestamp: testDate,
            ),
            RecentGameResult(
              gameId: 'g2',
              won: true,
              pointsScored: 21,
              pointsAllowed: 18,
              eloChange: 8.0,
              timestamp: testDate.subtract(const Duration(days: 1)),
            ),
            RecentGameResult(
              gameId: 'g3',
              won: true,
              pointsScored: 21,
              pointsAllowed: 19,
              eloChange: 7.0,
              timestamp: testDate.subtract(const Duration(days: 2)),
            ),
            RecentGameResult(
              gameId: 'g4',
              won: false,
              pointsScored: 15,
              pointsAllowed: 21,
              eloChange: -10.0,
              timestamp: testDate.subtract(const Duration(days: 3)),
            ),
          ],
        );

        expect(stats.currentStreak, equals(3));
      });

      test('returns negative streak for consecutive losses', () {
        final stats = TeammateStats(
          userId: 'user-1',
          gamesPlayed: 4,
          gamesWon: 1,
          gamesLost: 3,
          recentGames: [
            RecentGameResult(
              gameId: 'g1',
              won: false,
              pointsScored: 15,
              pointsAllowed: 21,
              eloChange: -10.0,
              timestamp: testDate,
            ),
            RecentGameResult(
              gameId: 'g2',
              won: false,
              pointsScored: 18,
              pointsAllowed: 21,
              eloChange: -8.0,
              timestamp: testDate.subtract(const Duration(days: 1)),
            ),
            RecentGameResult(
              gameId: 'g3',
              won: true,
              pointsScored: 21,
              pointsAllowed: 15,
              eloChange: 10.0,
              timestamp: testDate.subtract(const Duration(days: 2)),
            ),
          ],
        );

        expect(stats.currentStreak, equals(-2));
      });

      test('returns 0 when no recent games', () {
        final stats = TeammateStats(
          userId: 'user-1',
          gamesPlayed: 0,
          gamesWon: 0,
          gamesLost: 0,
          recentGames: [],
        );

        expect(stats.currentStreak, equals(0));
      });
    });

    group('isOnWinningStreak / isOnLosingStreak', () {
      test('isOnWinningStreak returns true for positive streak', () {
        final stats = TeammateStats(
          userId: 'user-1',
          gamesPlayed: 2,
          gamesWon: 2,
          gamesLost: 0,
          recentGames: [
            RecentGameResult(
              gameId: 'g1',
              won: true,
              pointsScored: 21,
              pointsAllowed: 15,
              eloChange: 10.0,
              timestamp: testDate,
            ),
          ],
        );

        expect(stats.isOnWinningStreak, isTrue);
        expect(stats.isOnLosingStreak, isFalse);
      });

      test('isOnLosingStreak returns true for negative streak', () {
        final stats = TeammateStats(
          userId: 'user-1',
          gamesPlayed: 2,
          gamesWon: 0,
          gamesLost: 2,
          recentGames: [
            RecentGameResult(
              gameId: 'g1',
              won: false,
              pointsScored: 15,
              pointsAllowed: 21,
              eloChange: -10.0,
              timestamp: testDate,
            ),
          ],
        );

        expect(stats.isOnWinningStreak, isFalse);
        expect(stats.isOnLosingStreak, isTrue);
      });
    });

    group('recordString', () {
      test('formats record correctly', () {
        final stats = TeammateStats(
          userId: 'user-1',
          gamesPlayed: 20,
          gamesWon: 12,
          gamesLost: 8,
        );

        expect(stats.recordString, equals('12W - 8L'));
      });

      test('formats perfect record', () {
        final stats = TeammateStats(
          userId: 'user-1',
          gamesPlayed: 10,
          gamesWon: 10,
          gamesLost: 0,
        );

        expect(stats.recordString, equals('10W - 0L'));
      });
    });

    group('formattedPointDifferential', () {
      test('formats positive differential with plus sign', () {
        final stats = TeammateStats(
          userId: 'user-1',
          gamesPlayed: 10,
          gamesWon: 7,
          gamesLost: 3,
          pointsScored: 200,
          pointsAllowed: 150,
        );

        expect(stats.formattedPointDifferential, equals('+5.0'));
      });

      test('formats negative differential without plus sign', () {
        final stats = TeammateStats(
          userId: 'user-1',
          gamesPlayed: 10,
          gamesWon: 3,
          gamesLost: 7,
          pointsScored: 150,
          pointsAllowed: 200,
        );

        expect(stats.formattedPointDifferential, equals('-5.0'));
      });

      test('formats zero differential with plus sign', () {
        final stats = TeammateStats(
          userId: 'user-1',
          gamesPlayed: 10,
          gamesWon: 5,
          gamesLost: 5,
          pointsScored: 180,
          pointsAllowed: 180,
        );

        expect(stats.formattedPointDifferential, equals('+0.0'));
      });
    });

    group('formattedEloChange', () {
      test('formats positive ELO change with plus sign', () {
        final stats = TeammateStats(
          userId: 'user-1',
          gamesPlayed: 10,
          gamesWon: 7,
          gamesLost: 3,
          eloChange: 45.5,
        );

        expect(stats.formattedEloChange, equals('+45.5'));
      });

      test('formats negative ELO change without plus sign', () {
        final stats = TeammateStats(
          userId: 'user-1',
          gamesPlayed: 10,
          gamesWon: 3,
          gamesLost: 7,
          eloChange: -32.5,
        );

        expect(stats.formattedEloChange, equals('-32.5'));
      });
    });

    group('fromJson', () {
      test('deserializes from JSON with all fields', () {
        final json = {
          'userId': 'user-123',
          'gamesPlayed': 20,
          'gamesWon': 12,
          'gamesLost': 8,
          'pointsScored': 400,
          'pointsAllowed': 350,
          'eloChange': 45.5,
          'recentGames': [],
          'lastUpdated': testTimestamp,
        };

        final stats = TeammateStats.fromJson(json);

        expect(stats.userId, equals('user-123'));
        expect(stats.gamesPlayed, equals(20));
        expect(stats.gamesWon, equals(12));
        expect(stats.gamesLost, equals(8));
        expect(stats.pointsScored, equals(400));
        expect(stats.pointsAllowed, equals(350));
        expect(stats.eloChange, equals(45.5));
        expect(stats.lastUpdated, equals(testDate));
      });

      test('deserializes with nested recent games', () {
        final json = {
          'userId': 'user-123',
          'gamesPlayed': 2,
          'gamesWon': 1,
          'gamesLost': 1,
          'recentGames': [
            {
              'gameId': 'game-1',
              'won': true,
              'pointsScored': 21,
              'pointsAllowed': 15,
              'eloChange': 10.0,
              'timestamp': testTimestamp,
            },
          ],
        };

        final stats = TeammateStats.fromJson(json);

        expect(stats.recentGames.length, equals(1));
        expect(stats.recentGames.first.gameId, equals('game-1'));
        expect(stats.recentGames.first.won, isTrue);
      });
    });

    group('toJson', () {
      test('serializes to JSON correctly', () {
        final stats = TeammateStats(
          userId: 'user-123',
          gamesPlayed: 20,
          gamesWon: 12,
          gamesLost: 8,
          pointsScored: 400,
          pointsAllowed: 350,
          eloChange: 45.5,
          lastUpdated: testDate,
        );

        final json = stats.toJson();

        expect(json['userId'], equals('user-123'));
        expect(json['gamesPlayed'], equals(20));
        expect(json['gamesWon'], equals(12));
        expect(json['gamesLost'], equals(8));
        expect(json['pointsScored'], equals(400));
        expect(json['pointsAllowed'], equals(350));
        expect(json['eloChange'], equals(45.5));
      });

      test('round-trip serialization preserves data', () {
        final original = TeammateStats(
          userId: 'user-123',
          gamesPlayed: 20,
          gamesWon: 12,
          gamesLost: 8,
          pointsScored: 400,
          pointsAllowed: 350,
          eloChange: 45.5,
          lastUpdated: testDate,
        );

        final json = original.toJson();
        final restored = TeammateStats.fromJson(json);

        expect(restored.userId, equals(original.userId));
        expect(restored.gamesPlayed, equals(original.gamesPlayed));
        expect(restored.gamesWon, equals(original.gamesWon));
        expect(restored.gamesLost, equals(original.gamesLost));
      });
    });

    group('fromFirestore', () {
      test('creates instance from Firestore data', () {
        final data = {
          'gamesPlayed': 15,
          'gamesWon': 9,
          'gamesLost': 6,
          'pointsScored': 300,
          'pointsAllowed': 280,
          'eloChange': 25.0,
          'recentGames': [],
          'lastUpdated': testTimestamp,
        };

        final stats = TeammateStats.fromFirestore('user-abc', data);

        expect(stats.userId, equals('user-abc'));
        expect(stats.gamesPlayed, equals(15));
        expect(stats.gamesWon, equals(9));
      });
    });

    group('toFirestore', () {
      test('excludes userId from output', () {
        final stats = TeammateStats(
          userId: 'user-123',
          gamesPlayed: 10,
          gamesWon: 6,
          gamesLost: 4,
        );

        final firestoreData = stats.toFirestore();

        expect(firestoreData.containsKey('userId'), isFalse);
        expect(firestoreData['gamesPlayed'], equals(10));
      });
    });

    group('equality', () {
      test('two stats with same values are equal', () {
        final stats1 = TeammateStats(
          userId: 'user-123',
          gamesPlayed: 20,
          gamesWon: 12,
          gamesLost: 8,
          lastUpdated: testDate,
        );

        final stats2 = TeammateStats(
          userId: 'user-123',
          gamesPlayed: 20,
          gamesWon: 12,
          gamesLost: 8,
          lastUpdated: testDate,
        );

        expect(stats1, equals(stats2));
        expect(stats1.hashCode, equals(stats2.hashCode));
      });

      test('two stats with different userId are not equal', () {
        final stats1 = TeammateStats(
          userId: 'user-123',
          gamesPlayed: 20,
          gamesWon: 12,
          gamesLost: 8,
        );

        final stats2 = TeammateStats(
          userId: 'user-456',
          gamesPlayed: 20,
          gamesWon: 12,
          gamesLost: 8,
        );

        expect(stats1, isNot(equals(stats2)));
      });
    });

    group('copyWith', () {
      test('creates copy with updated gamesWon', () {
        final original = TeammateStats(
          userId: 'user-123',
          gamesPlayed: 20,
          gamesWon: 12,
          gamesLost: 8,
        );

        final copy = original.copyWith(gamesWon: 13);

        expect(copy.gamesWon, equals(13));
        expect(copy.userId, equals(original.userId));
        expect(copy.gamesPlayed, equals(original.gamesPlayed));
      });

      test('creates identical copy when no parameters provided', () {
        final original = TeammateStats(
          userId: 'user-123',
          gamesPlayed: 20,
          gamesWon: 12,
          gamesLost: 8,
        );

        final copy = original.copyWith();

        expect(copy, equals(original));
      });
    });
  });

  group('RecentGameResult', () {
    final testDate = DateTime(2025, 12, 29, 14, 30);
    final testTimestamp = Timestamp.fromDate(testDate);

    group('constructor', () {
      test('creates instance with all required fields', () {
        final result = RecentGameResult(
          gameId: 'game-123',
          won: true,
          pointsScored: 21,
          pointsAllowed: 15,
          eloChange: 12.5,
          timestamp: testDate,
        );

        expect(result.gameId, equals('game-123'));
        expect(result.won, isTrue);
        expect(result.pointsScored, equals(21));
        expect(result.pointsAllowed, equals(15));
        expect(result.eloChange, equals(12.5));
        expect(result.timestamp, equals(testDate));
      });
    });

    group('pointDifferential', () {
      test('calculates positive differential', () {
        final result = RecentGameResult(
          gameId: 'g1',
          won: true,
          pointsScored: 21,
          pointsAllowed: 15,
          eloChange: 10.0,
          timestamp: testDate,
        );

        expect(result.pointDifferential, equals(6));
      });

      test('calculates negative differential', () {
        final result = RecentGameResult(
          gameId: 'g1',
          won: false,
          pointsScored: 15,
          pointsAllowed: 21,
          eloChange: -10.0,
          timestamp: testDate,
        );

        expect(result.pointDifferential, equals(-6));
      });
    });

    group('formattedPointDifferential', () {
      test('formats positive differential with plus sign', () {
        final result = RecentGameResult(
          gameId: 'g1',
          won: true,
          pointsScored: 21,
          pointsAllowed: 15,
          eloChange: 10.0,
          timestamp: testDate,
        );

        expect(result.formattedPointDifferential, equals('+6'));
      });

      test('formats negative differential without plus sign', () {
        final result = RecentGameResult(
          gameId: 'g1',
          won: false,
          pointsScored: 15,
          pointsAllowed: 21,
          eloChange: -10.0,
          timestamp: testDate,
        );

        expect(result.formattedPointDifferential, equals('-6'));
      });
    });

    group('formattedEloChange', () {
      test('formats positive ELO change', () {
        final result = RecentGameResult(
          gameId: 'g1',
          won: true,
          pointsScored: 21,
          pointsAllowed: 15,
          eloChange: 12.5,
          timestamp: testDate,
        );

        expect(result.formattedEloChange, equals('+12.5'));
      });

      test('formats negative ELO change', () {
        final result = RecentGameResult(
          gameId: 'g1',
          won: false,
          pointsScored: 15,
          pointsAllowed: 21,
          eloChange: -8.5,
          timestamp: testDate,
        );

        expect(result.formattedEloChange, equals('-8.5'));
      });
    });

    group('resultLetter', () {
      test('returns W for win', () {
        final result = RecentGameResult(
          gameId: 'g1',
          won: true,
          pointsScored: 21,
          pointsAllowed: 15,
          eloChange: 10.0,
          timestamp: testDate,
        );

        expect(result.resultLetter, equals('W'));
      });

      test('returns L for loss', () {
        final result = RecentGameResult(
          gameId: 'g1',
          won: false,
          pointsScored: 15,
          pointsAllowed: 21,
          eloChange: -10.0,
          timestamp: testDate,
        );

        expect(result.resultLetter, equals('L'));
      });
    });

    group('resultDisplay', () {
      test('returns display map for win', () {
        final result = RecentGameResult(
          gameId: 'g1',
          won: true,
          pointsScored: 21,
          pointsAllowed: 15,
          eloChange: 10.0,
          timestamp: testDate,
        );

        final display = result.resultDisplay;
        expect(display['text'], equals('W'));
        expect(display['won'], isTrue);
      });

      test('returns display map for loss', () {
        final result = RecentGameResult(
          gameId: 'g1',
          won: false,
          pointsScored: 15,
          pointsAllowed: 21,
          eloChange: -10.0,
          timestamp: testDate,
        );

        final display = result.resultDisplay;
        expect(display['text'], equals('L'));
        expect(display['won'], isFalse);
      });
    });

    group('fromJson', () {
      test('deserializes from JSON with Timestamp', () {
        final json = {
          'gameId': 'game-123',
          'won': true,
          'pointsScored': 21,
          'pointsAllowed': 15,
          'eloChange': 12.5,
          'timestamp': testTimestamp,
        };

        final result = RecentGameResult.fromJson(json);

        expect(result.gameId, equals('game-123'));
        expect(result.won, isTrue);
        expect(result.pointsScored, equals(21));
        expect(result.pointsAllowed, equals(15));
        expect(result.eloChange, equals(12.5));
        expect(result.timestamp, equals(testDate));
      });

      test('deserializes from JSON with DateTime string', () {
        final json = {
          'gameId': 'game-456',
          'won': false,
          'pointsScored': 18,
          'pointsAllowed': 21,
          'eloChange': -8.0,
          'timestamp': testDate.toIso8601String(),
        };

        final result = RecentGameResult.fromJson(json);

        expect(result.gameId, equals('game-456'));
        expect(result.won, isFalse);
        expect(result.timestamp.year, equals(testDate.year));
      });
    });

    group('toJson', () {
      test('serializes to JSON correctly', () {
        final result = RecentGameResult(
          gameId: 'game-123',
          won: true,
          pointsScored: 21,
          pointsAllowed: 15,
          eloChange: 12.5,
          timestamp: testDate,
        );

        final json = result.toJson();

        expect(json['gameId'], equals('game-123'));
        expect(json['won'], isTrue);
        expect(json['pointsScored'], equals(21));
        expect(json['pointsAllowed'], equals(15));
        expect(json['eloChange'], equals(12.5));
      });

      test('round-trip serialization preserves data', () {
        final original = RecentGameResult(
          gameId: 'game-789',
          won: false,
          pointsScored: 19,
          pointsAllowed: 21,
          eloChange: -5.5,
          timestamp: testDate,
        );

        final json = original.toJson();
        final restored = RecentGameResult.fromJson(json);

        expect(restored.gameId, equals(original.gameId));
        expect(restored.won, equals(original.won));
        expect(restored.pointsScored, equals(original.pointsScored));
        expect(restored.pointsAllowed, equals(original.pointsAllowed));
        expect(restored.eloChange, equals(original.eloChange));
      });
    });

    group('equality', () {
      test('two results with same values are equal', () {
        final result1 = RecentGameResult(
          gameId: 'game-123',
          won: true,
          pointsScored: 21,
          pointsAllowed: 15,
          eloChange: 10.0,
          timestamp: testDate,
        );

        final result2 = RecentGameResult(
          gameId: 'game-123',
          won: true,
          pointsScored: 21,
          pointsAllowed: 15,
          eloChange: 10.0,
          timestamp: testDate,
        );

        expect(result1, equals(result2));
        expect(result1.hashCode, equals(result2.hashCode));
      });

      test('two results with different gameId are not equal', () {
        final result1 = RecentGameResult(
          gameId: 'game-123',
          won: true,
          pointsScored: 21,
          pointsAllowed: 15,
          eloChange: 10.0,
          timestamp: testDate,
        );

        final result2 = RecentGameResult(
          gameId: 'game-456',
          won: true,
          pointsScored: 21,
          pointsAllowed: 15,
          eloChange: 10.0,
          timestamp: testDate,
        );

        expect(result1, isNot(equals(result2)));
      });
    });

    group('copyWith', () {
      test('creates copy with updated won status', () {
        final original = RecentGameResult(
          gameId: 'game-123',
          won: true,
          pointsScored: 21,
          pointsAllowed: 15,
          eloChange: 10.0,
          timestamp: testDate,
        );

        final copy = original.copyWith(won: false);

        expect(copy.won, isFalse);
        expect(copy.gameId, equals(original.gameId));
      });

      test('creates identical copy when no parameters provided', () {
        final original = RecentGameResult(
          gameId: 'game-123',
          won: true,
          pointsScored: 21,
          pointsAllowed: 15,
          eloChange: 10.0,
          timestamp: testDate,
        );

        final copy = original.copyWith();

        expect(copy, equals(original));
      });
    });

    group('edge cases', () {
      test('handles zero point game', () {
        final result = RecentGameResult(
          gameId: 'g1',
          won: true,
          pointsScored: 0,
          pointsAllowed: 0,
          eloChange: 0.0,
          timestamp: testDate,
        );

        expect(result.pointDifferential, equals(0));
        expect(result.formattedPointDifferential, equals('+0'));
      });

      test('handles large scores', () {
        final result = RecentGameResult(
          gameId: 'g1',
          won: true,
          pointsScored: 35,
          pointsAllowed: 33,
          eloChange: 5.0,
          timestamp: testDate,
        );

        expect(result.pointDifferential, equals(2));
        expect(result.formattedPointDifferential, equals('+2'));
      });
    });
  });
}
