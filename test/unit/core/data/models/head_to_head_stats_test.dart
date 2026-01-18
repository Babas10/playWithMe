// Tests HeadToHeadStats and HeadToHeadGameResult models for rivalry tracking (Story 16.3.3.1).

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:play_with_me/core/data/models/head_to_head_stats.dart';

void main() {
  group('HeadToHeadStats', () {
    final testDate = DateTime(2025, 12, 29, 10, 30);
    final testTimestamp = Timestamp.fromDate(testDate);

    group('constructor', () {
      test('creates instance with all required fields', () {
        final stats = HeadToHeadStats(
          userId: 'user-123',
          opponentId: 'opponent-456',
          opponentName: 'John Doe',
          opponentEmail: 'john@example.com',
          opponentPhotoUrl: 'https://example.com/photo.jpg',
          gamesPlayed: 15,
          gamesWon: 9,
          gamesLost: 6,
          pointsScored: 300,
          pointsAllowed: 280,
          eloChange: 35.5,
          largestVictoryMargin: 10,
          largestDefeatMargin: 5,
          recentMatchups: [],
          lastUpdated: testDate,
        );

        expect(stats.userId, equals('user-123'));
        expect(stats.opponentId, equals('opponent-456'));
        expect(stats.opponentName, equals('John Doe'));
        expect(stats.opponentEmail, equals('john@example.com'));
        expect(stats.opponentPhotoUrl, equals('https://example.com/photo.jpg'));
        expect(stats.gamesPlayed, equals(15));
        expect(stats.gamesWon, equals(9));
        expect(stats.gamesLost, equals(6));
        expect(stats.pointsScored, equals(300));
        expect(stats.pointsAllowed, equals(280));
        expect(stats.eloChange, equals(35.5));
        expect(stats.largestVictoryMargin, equals(10));
        expect(stats.largestDefeatMargin, equals(5));
        expect(stats.lastUpdated, equals(testDate));
      });

      test('creates instance with default values', () {
        final stats = HeadToHeadStats(
          userId: 'user-123',
          opponentId: 'opponent-456',
          gamesPlayed: 5,
          gamesWon: 3,
          gamesLost: 2,
        );

        expect(stats.opponentName, isNull);
        expect(stats.opponentEmail, isNull);
        expect(stats.opponentPhotoUrl, isNull);
        expect(stats.pointsScored, equals(0));
        expect(stats.pointsAllowed, equals(0));
        expect(stats.eloChange, equals(0.0));
        expect(stats.largestVictoryMargin, equals(0));
        expect(stats.largestDefeatMargin, equals(0));
        expect(stats.recentMatchups, isEmpty);
        expect(stats.lastUpdated, isNull);
      });
    });

    group('winRate', () {
      test('calculates win rate correctly', () {
        final stats = HeadToHeadStats(
          userId: 'user-1',
          opponentId: 'opponent-1',
          gamesPlayed: 20,
          gamesWon: 14,
          gamesLost: 6,
        );

        expect(stats.winRate, equals(70.0));
      });

      test('returns 0 when no games played', () {
        final stats = HeadToHeadStats(
          userId: 'user-1',
          opponentId: 'opponent-1',
          gamesPlayed: 0,
          gamesWon: 0,
          gamesLost: 0,
        );

        expect(stats.winRate, equals(0.0));
      });

      test('calculates 100% win rate', () {
        final stats = HeadToHeadStats(
          userId: 'user-1',
          opponentId: 'opponent-1',
          gamesPlayed: 10,
          gamesWon: 10,
          gamesLost: 0,
        );

        expect(stats.winRate, equals(100.0));
      });

      test('calculates 0% win rate', () {
        final stats = HeadToHeadStats(
          userId: 'user-1',
          opponentId: 'opponent-1',
          gamesPlayed: 10,
          gamesWon: 0,
          gamesLost: 10,
        );

        expect(stats.winRate, equals(0.0));
      });
    });

    group('lossRate', () {
      test('calculates loss rate correctly', () {
        final stats = HeadToHeadStats(
          userId: 'user-1',
          opponentId: 'opponent-1',
          gamesPlayed: 20,
          gamesWon: 14,
          gamesLost: 6,
        );

        expect(stats.lossRate, equals(30.0));
      });

      test('returns 0 when no games played', () {
        final stats = HeadToHeadStats(
          userId: 'user-1',
          opponentId: 'opponent-1',
          gamesPlayed: 0,
          gamesWon: 0,
          gamesLost: 0,
        );

        expect(stats.lossRate, equals(0.0));
      });
    });

    group('avgPointsScored', () {
      test('calculates average points scored correctly', () {
        final stats = HeadToHeadStats(
          userId: 'user-1',
          opponentId: 'opponent-1',
          gamesPlayed: 10,
          gamesWon: 6,
          gamesLost: 4,
          pointsScored: 195,
        );

        expect(stats.avgPointsScored, equals(19.5));
      });

      test('returns 0 when no games played', () {
        final stats = HeadToHeadStats(
          userId: 'user-1',
          opponentId: 'opponent-1',
          gamesPlayed: 0,
          gamesWon: 0,
          gamesLost: 0,
        );

        expect(stats.avgPointsScored, equals(0.0));
      });
    });

    group('avgPointsAllowed', () {
      test('calculates average points allowed correctly', () {
        final stats = HeadToHeadStats(
          userId: 'user-1',
          opponentId: 'opponent-1',
          gamesPlayed: 10,
          gamesWon: 6,
          gamesLost: 4,
          pointsAllowed: 170,
        );

        expect(stats.avgPointsAllowed, equals(17.0));
      });
    });

    group('avgPointDifferential', () {
      test('calculates positive point differential', () {
        final stats = HeadToHeadStats(
          userId: 'user-1',
          opponentId: 'opponent-1',
          gamesPlayed: 10,
          gamesWon: 7,
          gamesLost: 3,
          pointsScored: 200,
          pointsAllowed: 170,
        );

        expect(stats.avgPointDifferential, equals(3.0)); // 20 - 17
      });

      test('calculates negative point differential', () {
        final stats = HeadToHeadStats(
          userId: 'user-1',
          opponentId: 'opponent-1',
          gamesPlayed: 10,
          gamesWon: 3,
          gamesLost: 7,
          pointsScored: 170,
          pointsAllowed: 200,
        );

        expect(stats.avgPointDifferential, equals(-3.0)); // 17 - 20
      });
    });

    group('avgEloChange', () {
      test('calculates average ELO change correctly', () {
        final stats = HeadToHeadStats(
          userId: 'user-1',
          opponentId: 'opponent-1',
          gamesPlayed: 10,
          gamesWon: 6,
          gamesLost: 4,
          eloChange: 40.0,
        );

        expect(stats.avgEloChange, equals(4.0));
      });

      test('returns 0 when no games played', () {
        final stats = HeadToHeadStats(
          userId: 'user-1',
          opponentId: 'opponent-1',
          gamesPlayed: 0,
          gamesWon: 0,
          gamesLost: 0,
        );

        expect(stats.avgEloChange, equals(0.0));
      });
    });

    group('currentStreak', () {
      test('returns positive streak for consecutive wins', () {
        final stats = HeadToHeadStats(
          userId: 'user-1',
          opponentId: 'opponent-1',
          gamesPlayed: 5,
          gamesWon: 4,
          gamesLost: 1,
          recentMatchups: [
            HeadToHeadGameResult(
              gameId: 'g1',
              won: true,
              pointsScored: 21,
              pointsAllowed: 15,
              eloChange: 10.0,
              timestamp: testDate,
            ),
            HeadToHeadGameResult(
              gameId: 'g2',
              won: true,
              pointsScored: 21,
              pointsAllowed: 18,
              eloChange: 8.0,
              timestamp: testDate.subtract(const Duration(days: 1)),
            ),
            HeadToHeadGameResult(
              gameId: 'g3',
              won: false,
              pointsScored: 18,
              pointsAllowed: 21,
              eloChange: -8.0,
              timestamp: testDate.subtract(const Duration(days: 2)),
            ),
          ],
        );

        expect(stats.currentStreak, equals(2));
      });

      test('returns negative streak for consecutive losses', () {
        final stats = HeadToHeadStats(
          userId: 'user-1',
          opponentId: 'opponent-1',
          gamesPlayed: 4,
          gamesWon: 1,
          gamesLost: 3,
          recentMatchups: [
            HeadToHeadGameResult(
              gameId: 'g1',
              won: false,
              pointsScored: 15,
              pointsAllowed: 21,
              eloChange: -10.0,
              timestamp: testDate,
            ),
            HeadToHeadGameResult(
              gameId: 'g2',
              won: false,
              pointsScored: 18,
              pointsAllowed: 21,
              eloChange: -8.0,
              timestamp: testDate.subtract(const Duration(days: 1)),
            ),
            HeadToHeadGameResult(
              gameId: 'g3',
              won: false,
              pointsScored: 19,
              pointsAllowed: 21,
              eloChange: -7.0,
              timestamp: testDate.subtract(const Duration(days: 2)),
            ),
          ],
        );

        expect(stats.currentStreak, equals(-3));
      });

      test('returns 0 when no recent matchups', () {
        final stats = HeadToHeadStats(
          userId: 'user-1',
          opponentId: 'opponent-1',
          gamesPlayed: 0,
          gamesWon: 0,
          gamesLost: 0,
          recentMatchups: [],
        );

        expect(stats.currentStreak, equals(0));
      });
    });

    group('isOnWinningStreak / isOnLosingStreak', () {
      test('isOnWinningStreak returns true for positive streak', () {
        final stats = HeadToHeadStats(
          userId: 'user-1',
          opponentId: 'opponent-1',
          gamesPlayed: 2,
          gamesWon: 2,
          gamesLost: 0,
          recentMatchups: [
            HeadToHeadGameResult(
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
        final stats = HeadToHeadStats(
          userId: 'user-1',
          opponentId: 'opponent-1',
          gamesPlayed: 2,
          gamesWon: 0,
          gamesLost: 2,
          recentMatchups: [
            HeadToHeadGameResult(
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
        final stats = HeadToHeadStats(
          userId: 'user-1',
          opponentId: 'opponent-1',
          gamesPlayed: 15,
          gamesWon: 9,
          gamesLost: 6,
        );

        expect(stats.recordString, equals('9W - 6L'));
      });
    });

    group('formattedPointDifferential', () {
      test('formats positive differential with plus sign', () {
        final stats = HeadToHeadStats(
          userId: 'user-1',
          opponentId: 'opponent-1',
          gamesPlayed: 10,
          gamesWon: 7,
          gamesLost: 3,
          pointsScored: 200,
          pointsAllowed: 170,
        );

        expect(stats.formattedPointDifferential, equals('+3.0'));
      });

      test('formats negative differential without plus sign', () {
        final stats = HeadToHeadStats(
          userId: 'user-1',
          opponentId: 'opponent-1',
          gamesPlayed: 10,
          gamesWon: 3,
          gamesLost: 7,
          pointsScored: 170,
          pointsAllowed: 200,
        );

        expect(stats.formattedPointDifferential, equals('-3.0'));
      });
    });

    group('formattedEloChange', () {
      test('formats positive ELO change with plus sign', () {
        final stats = HeadToHeadStats(
          userId: 'user-1',
          opponentId: 'opponent-1',
          gamesPlayed: 10,
          gamesWon: 7,
          gamesLost: 3,
          eloChange: 35.5,
        );

        expect(stats.formattedEloChange, equals('+35.5'));
      });

      test('formats negative ELO change without plus sign', () {
        final stats = HeadToHeadStats(
          userId: 'user-1',
          opponentId: 'opponent-1',
          gamesPlayed: 10,
          gamesWon: 3,
          gamesLost: 7,
          eloChange: -25.5,
        );

        expect(stats.formattedEloChange, equals('-25.5'));
      });
    });

    group('matchupAdvantage', () {
      test('returns "Not enough data" for less than 5 games', () {
        final stats = HeadToHeadStats(
          userId: 'user-1',
          opponentId: 'opponent-1',
          gamesPlayed: 4,
          gamesWon: 3,
          gamesLost: 1,
        );

        expect(stats.matchupAdvantage, equals('Not enough data'));
      });

      test('returns "Strong advantage" for win rate > 60%', () {
        final stats = HeadToHeadStats(
          userId: 'user-1',
          opponentId: 'opponent-1',
          gamesPlayed: 10,
          gamesWon: 7,
          gamesLost: 3,
        );

        expect(stats.matchupAdvantage, equals('Strong advantage'));
      });

      test('returns "Slight advantage" for win rate 50-60%', () {
        final stats = HeadToHeadStats(
          userId: 'user-1',
          opponentId: 'opponent-1',
          gamesPlayed: 10,
          gamesWon: 5,
          gamesLost: 5,
        );

        expect(stats.matchupAdvantage, equals('Slight advantage'));
      });

      test('returns "Even matchup" for win rate 40-50%', () {
        final stats = HeadToHeadStats(
          userId: 'user-1',
          opponentId: 'opponent-1',
          gamesPlayed: 10,
          gamesWon: 4,
          gamesLost: 6,
        );

        expect(stats.matchupAdvantage, equals('Even matchup'));
      });

      test('returns "Disadvantage" for win rate < 40%', () {
        final stats = HeadToHeadStats(
          userId: 'user-1',
          opponentId: 'opponent-1',
          gamesPlayed: 10,
          gamesWon: 3,
          gamesLost: 7,
        );

        expect(stats.matchupAdvantage, equals('Disadvantage'));
      });
    });

    group('isRivalry', () {
      test('returns true for 10+ games', () {
        final stats = HeadToHeadStats(
          userId: 'user-1',
          opponentId: 'opponent-1',
          gamesPlayed: 10,
          gamesWon: 5,
          gamesLost: 5,
        );

        expect(stats.isRivalry, isTrue);
      });

      test('returns false for less than 10 games', () {
        final stats = HeadToHeadStats(
          userId: 'user-1',
          opponentId: 'opponent-1',
          gamesPlayed: 9,
          gamesWon: 5,
          gamesLost: 4,
        );

        expect(stats.isRivalry, isFalse);
      });
    });

    group('rivalryIntensity', () {
      test('returns "New matchup" for less than 5 games', () {
        final stats = HeadToHeadStats(
          userId: 'user-1',
          opponentId: 'opponent-1',
          gamesPlayed: 4,
          gamesWon: 2,
          gamesLost: 2,
        );

        expect(stats.rivalryIntensity, equals('New matchup'));
      });

      test('returns "Developing rivalry" for 5-9 games', () {
        final stats = HeadToHeadStats(
          userId: 'user-1',
          opponentId: 'opponent-1',
          gamesPlayed: 7,
          gamesWon: 4,
          gamesLost: 3,
        );

        expect(stats.rivalryIntensity, equals('Developing rivalry'));
      });

      test('returns "Active rivalry" for 10-19 games', () {
        final stats = HeadToHeadStats(
          userId: 'user-1',
          opponentId: 'opponent-1',
          gamesPlayed: 15,
          gamesWon: 8,
          gamesLost: 7,
        );

        expect(stats.rivalryIntensity, equals('Active rivalry'));
      });

      test('returns "Intense rivalry" for 20+ games', () {
        final stats = HeadToHeadStats(
          userId: 'user-1',
          opponentId: 'opponent-1',
          gamesPlayed: 25,
          gamesWon: 13,
          gamesLost: 12,
        );

        expect(stats.rivalryIntensity, equals('Intense rivalry'));
      });
    });

    group('opponentDisplayName', () {
      test('returns opponentName when available', () {
        final stats = HeadToHeadStats(
          userId: 'user-1',
          opponentId: 'opponent-1',
          opponentName: 'John Doe',
          opponentEmail: 'john@example.com',
          gamesPlayed: 5,
          gamesWon: 3,
          gamesLost: 2,
        );

        expect(stats.opponentDisplayName, equals('John Doe'));
      });

      test('returns opponentEmail when name is null', () {
        final stats = HeadToHeadStats(
          userId: 'user-1',
          opponentId: 'opponent-1',
          opponentEmail: 'john@example.com',
          gamesPlayed: 5,
          gamesWon: 3,
          gamesLost: 2,
        );

        expect(stats.opponentDisplayName, equals('john@example.com'));
      });

      test('returns "Unknown" when both name and email are null', () {
        final stats = HeadToHeadStats(
          userId: 'user-1',
          opponentId: 'opponent-1',
          gamesPlayed: 5,
          gamesWon: 3,
          gamesLost: 2,
        );

        expect(stats.opponentDisplayName, equals('Unknown'));
      });
    });

    group('fromJson', () {
      test('deserializes from JSON with all fields', () {
        final json = {
          'userId': 'user-123',
          'opponentId': 'opponent-456',
          'opponentName': 'John Doe',
          'opponentEmail': 'john@example.com',
          'opponentPhotoUrl': 'https://example.com/photo.jpg',
          'gamesPlayed': 15,
          'gamesWon': 9,
          'gamesLost': 6,
          'pointsScored': 300,
          'pointsAllowed': 280,
          'eloChange': 35.5,
          'largestVictoryMargin': 10,
          'largestDefeatMargin': 5,
          'recentMatchups': [],
          'lastUpdated': testTimestamp,
        };

        final stats = HeadToHeadStats.fromJson(json);

        expect(stats.userId, equals('user-123'));
        expect(stats.opponentId, equals('opponent-456'));
        expect(stats.opponentName, equals('John Doe'));
        expect(stats.gamesPlayed, equals(15));
        expect(stats.gamesWon, equals(9));
        expect(stats.lastUpdated, equals(testDate));
      });

      test('deserializes with nested recent matchups', () {
        final json = {
          'userId': 'user-123',
          'opponentId': 'opponent-456',
          'gamesPlayed': 2,
          'gamesWon': 1,
          'gamesLost': 1,
          'recentMatchups': [
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

        final stats = HeadToHeadStats.fromJson(json);

        expect(stats.recentMatchups.length, equals(1));
        expect(stats.recentMatchups.first.gameId, equals('game-1'));
        expect(stats.recentMatchups.first.won, isTrue);
      });
    });

    group('toJson', () {
      test('serializes to JSON correctly', () {
        final stats = HeadToHeadStats(
          userId: 'user-123',
          opponentId: 'opponent-456',
          opponentName: 'John Doe',
          gamesPlayed: 15,
          gamesWon: 9,
          gamesLost: 6,
          lastUpdated: testDate,
        );

        final json = stats.toJson();

        expect(json['userId'], equals('user-123'));
        expect(json['opponentId'], equals('opponent-456'));
        expect(json['opponentName'], equals('John Doe'));
        expect(json['gamesPlayed'], equals(15));
      });

      test('round-trip serialization preserves data', () {
        final original = HeadToHeadStats(
          userId: 'user-123',
          opponentId: 'opponent-456',
          gamesPlayed: 15,
          gamesWon: 9,
          gamesLost: 6,
          lastUpdated: testDate,
        );

        final json = original.toJson();
        final restored = HeadToHeadStats.fromJson(json);

        expect(restored.userId, equals(original.userId));
        expect(restored.opponentId, equals(original.opponentId));
        expect(restored.gamesPlayed, equals(original.gamesPlayed));
      });
    });

    group('toFirestore', () {
      test('returns JSON representation for Firestore', () {
        final stats = HeadToHeadStats(
          userId: 'user-123',
          opponentId: 'opponent-456',
          gamesPlayed: 10,
          gamesWon: 6,
          gamesLost: 4,
        );

        final firestoreData = stats.toFirestore();

        expect(firestoreData['userId'], equals('user-123'));
        expect(firestoreData['gamesPlayed'], equals(10));
      });
    });

    group('equality', () {
      test('two stats with same values are equal', () {
        final stats1 = HeadToHeadStats(
          userId: 'user-123',
          opponentId: 'opponent-456',
          gamesPlayed: 15,
          gamesWon: 9,
          gamesLost: 6,
          lastUpdated: testDate,
        );

        final stats2 = HeadToHeadStats(
          userId: 'user-123',
          opponentId: 'opponent-456',
          gamesPlayed: 15,
          gamesWon: 9,
          gamesLost: 6,
          lastUpdated: testDate,
        );

        expect(stats1, equals(stats2));
        expect(stats1.hashCode, equals(stats2.hashCode));
      });

      test('two stats with different opponentId are not equal', () {
        final stats1 = HeadToHeadStats(
          userId: 'user-123',
          opponentId: 'opponent-456',
          gamesPlayed: 15,
          gamesWon: 9,
          gamesLost: 6,
        );

        final stats2 = HeadToHeadStats(
          userId: 'user-123',
          opponentId: 'opponent-789',
          gamesPlayed: 15,
          gamesWon: 9,
          gamesLost: 6,
        );

        expect(stats1, isNot(equals(stats2)));
      });
    });

    group('copyWith', () {
      test('creates copy with updated gamesWon', () {
        final original = HeadToHeadStats(
          userId: 'user-123',
          opponentId: 'opponent-456',
          gamesPlayed: 15,
          gamesWon: 9,
          gamesLost: 6,
        );

        final copy = original.copyWith(gamesWon: 10);

        expect(copy.gamesWon, equals(10));
        expect(copy.userId, equals(original.userId));
        expect(copy.opponentId, equals(original.opponentId));
      });

      test('creates identical copy when no parameters provided', () {
        final original = HeadToHeadStats(
          userId: 'user-123',
          opponentId: 'opponent-456',
          gamesPlayed: 15,
          gamesWon: 9,
          gamesLost: 6,
        );

        final copy = original.copyWith();

        expect(copy, equals(original));
      });
    });
  });

  group('HeadToHeadGameResult', () {
    final testDate = DateTime(2025, 12, 29, 14, 30);
    final testTimestamp = Timestamp.fromDate(testDate);

    group('constructor', () {
      test('creates instance with all required fields', () {
        final result = HeadToHeadGameResult(
          gameId: 'game-123',
          won: true,
          pointsScored: 21,
          pointsAllowed: 15,
          eloChange: 12.5,
          partnerId: 'partner-1',
          opponentPartnerId: 'opp-partner-1',
          timestamp: testDate,
        );

        expect(result.gameId, equals('game-123'));
        expect(result.won, isTrue);
        expect(result.pointsScored, equals(21));
        expect(result.pointsAllowed, equals(15));
        expect(result.eloChange, equals(12.5));
        expect(result.partnerId, equals('partner-1'));
        expect(result.opponentPartnerId, equals('opp-partner-1'));
        expect(result.timestamp, equals(testDate));
      });

      test('creates instance with optional fields as null', () {
        final result = HeadToHeadGameResult(
          gameId: 'game-123',
          won: false,
          pointsScored: 18,
          pointsAllowed: 21,
          eloChange: -8.0,
          timestamp: testDate,
        );

        expect(result.partnerId, isNull);
        expect(result.opponentPartnerId, isNull);
      });
    });

    group('pointDifferential', () {
      test('calculates positive differential', () {
        final result = HeadToHeadGameResult(
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
        final result = HeadToHeadGameResult(
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
        final result = HeadToHeadGameResult(
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
        final result = HeadToHeadGameResult(
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
        final result = HeadToHeadGameResult(
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
        final result = HeadToHeadGameResult(
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
        final result = HeadToHeadGameResult(
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
        final result = HeadToHeadGameResult(
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
        final result = HeadToHeadGameResult(
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
        final result = HeadToHeadGameResult(
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

    group('scoreDisplay', () {
      test('formats score correctly for win', () {
        final result = HeadToHeadGameResult(
          gameId: 'g1',
          won: true,
          pointsScored: 21,
          pointsAllowed: 15,
          eloChange: 10.0,
          timestamp: testDate,
        );

        expect(result.scoreDisplay, equals('21-15'));
      });

      test('formats score correctly for loss', () {
        final result = HeadToHeadGameResult(
          gameId: 'g1',
          won: false,
          pointsScored: 18,
          pointsAllowed: 21,
          eloChange: -8.0,
          timestamp: testDate,
        );

        expect(result.scoreDisplay, equals('18-21'));
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
          'partnerId': 'partner-1',
          'opponentPartnerId': 'opp-partner-1',
          'timestamp': testTimestamp,
        };

        final result = HeadToHeadGameResult.fromJson(json);

        expect(result.gameId, equals('game-123'));
        expect(result.won, isTrue);
        expect(result.partnerId, equals('partner-1'));
        expect(result.timestamp, equals(testDate));
      });

      test('deserializes from JSON with null optional fields', () {
        final json = {
          'gameId': 'game-456',
          'won': false,
          'pointsScored': 18,
          'pointsAllowed': 21,
          'eloChange': -8.0,
          'timestamp': testTimestamp,
        };

        final result = HeadToHeadGameResult.fromJson(json);

        expect(result.partnerId, isNull);
        expect(result.opponentPartnerId, isNull);
      });
    });

    group('toJson', () {
      test('serializes to JSON correctly', () {
        final result = HeadToHeadGameResult(
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
      });

      test('round-trip serialization preserves data', () {
        final original = HeadToHeadGameResult(
          gameId: 'game-789',
          won: false,
          pointsScored: 19,
          pointsAllowed: 21,
          eloChange: -5.5,
          partnerId: 'partner-abc',
          timestamp: testDate,
        );

        final json = original.toJson();
        final restored = HeadToHeadGameResult.fromJson(json);

        expect(restored.gameId, equals(original.gameId));
        expect(restored.won, equals(original.won));
        expect(restored.partnerId, equals(original.partnerId));
      });
    });

    group('equality', () {
      test('two results with same values are equal', () {
        final result1 = HeadToHeadGameResult(
          gameId: 'game-123',
          won: true,
          pointsScored: 21,
          pointsAllowed: 15,
          eloChange: 10.0,
          timestamp: testDate,
        );

        final result2 = HeadToHeadGameResult(
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
        final result1 = HeadToHeadGameResult(
          gameId: 'game-123',
          won: true,
          pointsScored: 21,
          pointsAllowed: 15,
          eloChange: 10.0,
          timestamp: testDate,
        );

        final result2 = HeadToHeadGameResult(
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
        final original = HeadToHeadGameResult(
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
        final original = HeadToHeadGameResult(
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
  });
}
