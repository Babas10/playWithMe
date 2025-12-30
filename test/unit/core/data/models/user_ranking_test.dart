// Tests UserRanking model for global/percentile/friends ranking display (Story 302.2).

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:play_with_me/core/data/models/user_ranking.dart';

void main() {
  group('UserRanking', () {
    final testDate = DateTime(2025, 12, 29, 10, 30);
    final testTimestamp = Timestamp.fromDate(testDate);

    group('constructor', () {
      test('creates instance with all required fields', () {
        final ranking = UserRanking(
          globalRank: 42,
          totalUsers: 1500,
          percentile: 97.2,
          friendsRank: 3,
          totalFriends: 15,
          calculatedAt: testDate,
        );

        expect(ranking.globalRank, equals(42));
        expect(ranking.totalUsers, equals(1500));
        expect(ranking.percentile, equals(97.2));
        expect(ranking.friendsRank, equals(3));
        expect(ranking.totalFriends, equals(15));
        expect(ranking.calculatedAt, equals(testDate));
      });

      test('creates instance without friends ranking', () {
        final ranking = UserRanking(
          globalRank: 100,
          totalUsers: 500,
          percentile: 80.0,
          friendsRank: null,
          totalFriends: null,
          calculatedAt: testDate,
        );

        expect(ranking.friendsRank, isNull);
        expect(ranking.totalFriends, isNull);
      });
    });

    group('globalRankDisplay', () {
      test('formats rank correctly with no commas', () {
        final ranking = UserRanking(
          globalRank: 42,
          totalUsers: 500,
          percentile: 91.6,
          calculatedAt: testDate,
        );

        expect(ranking.globalRankDisplay, equals('#42 of 500'));
      });

      test('formats rank correctly with thousands separator', () {
        final ranking = UserRanking(
          globalRank: 42,
          totalUsers: 1500,
          percentile: 97.2,
          calculatedAt: testDate,
        );

        expect(ranking.globalRankDisplay, equals('#42 of 1,500'));
      });

      test('formats rank correctly with tens of thousands', () {
        final ranking = UserRanking(
          globalRank: 1234,
          totalUsers: 50000,
          percentile: 97.5,
          calculatedAt: testDate,
        );

        expect(ranking.globalRankDisplay, equals('#1234 of 50,000'));
      });

      test('handles rank #1', () {
        final ranking = UserRanking(
          globalRank: 1,
          totalUsers: 1000,
          percentile: 100.0,
          calculatedAt: testDate,
        );

        expect(ranking.globalRankDisplay, equals('#1 of 1,000'));
      });
    });

    group('percentileDisplay', () {
      test('displays top 2.8% correctly', () {
        final ranking = UserRanking(
          globalRank: 42,
          totalUsers: 1500,
          percentile: 97.2,
          calculatedAt: testDate,
        );

        expect(ranking.percentileDisplay, equals('Top 2.8%'));
      });

      test('displays top 50.0% for median', () {
        final ranking = UserRanking(
          globalRank: 250,
          totalUsers: 500,
          percentile: 50.0,
          calculatedAt: testDate,
        );

        expect(ranking.percentileDisplay, equals('Top 50.0%'));
      });

      test('displays top 0.0% for #1 rank', () {
        final ranking = UserRanking(
          globalRank: 1,
          totalUsers: 1000,
          percentile: 100.0,
          calculatedAt: testDate,
        );

        expect(ranking.percentileDisplay, equals('Top 0.0%'));
      });

      test('displays top 99.9% for last rank', () {
        final ranking = UserRanking(
          globalRank: 1000,
          totalUsers: 1000,
          percentile: 0.1,
          calculatedAt: testDate,
        );

        expect(ranking.percentileDisplay, equals('Top 99.9%'));
      });

      test('rounds to 1 decimal place', () {
        final ranking = UserRanking(
          globalRank: 42,
          totalUsers: 1500,
          percentile: 97.234,
          calculatedAt: testDate,
        );

        expect(ranking.percentileDisplay, equals('Top 2.8%'));
      });
    });

    group('friendsRankDisplay', () {
      test('displays friends rank correctly', () {
        final ranking = UserRanking(
          globalRank: 42,
          totalUsers: 1500,
          percentile: 97.2,
          friendsRank: 3,
          totalFriends: 15,
          calculatedAt: testDate,
        );

        expect(ranking.friendsRankDisplay, equals('#3 of 15'));
      });

      test('returns null when friendsRank is null', () {
        final ranking = UserRanking(
          globalRank: 42,
          totalUsers: 1500,
          percentile: 97.2,
          friendsRank: null,
          totalFriends: null,
          calculatedAt: testDate,
        );

        expect(ranking.friendsRankDisplay, isNull);
      });

      test('returns null when only friendsRank is missing', () {
        final ranking = UserRanking(
          globalRank: 42,
          totalUsers: 1500,
          percentile: 97.2,
          friendsRank: null,
          totalFriends: 15,
          calculatedAt: testDate,
        );

        expect(ranking.friendsRankDisplay, isNull);
      });

      test('returns null when only totalFriends is missing', () {
        final ranking = UserRanking(
          globalRank: 42,
          totalUsers: 1500,
          percentile: 97.2,
          friendsRank: 3,
          totalFriends: null,
          calculatedAt: testDate,
        );

        expect(ranking.friendsRankDisplay, isNull);
      });

      test('displays #1 of 1 for single friend', () {
        final ranking = UserRanking(
          globalRank: 42,
          totalUsers: 1500,
          percentile: 97.2,
          friendsRank: 1,
          totalFriends: 1,
          calculatedAt: testDate,
        );

        expect(ranking.friendsRankDisplay, equals('#1 of 1'));
      });
    });

    group('hasFriends', () {
      test('returns true when both friendsRank and totalFriends are set', () {
        final ranking = UserRanking(
          globalRank: 42,
          totalUsers: 1500,
          percentile: 97.2,
          friendsRank: 3,
          totalFriends: 15,
          calculatedAt: testDate,
        );

        expect(ranking.hasFriends, isTrue);
      });

      test('returns false when friendsRank is null', () {
        final ranking = UserRanking(
          globalRank: 42,
          totalUsers: 1500,
          percentile: 97.2,
          friendsRank: null,
          totalFriends: 15,
          calculatedAt: testDate,
        );

        expect(ranking.hasFriends, isFalse);
      });

      test('returns false when totalFriends is null', () {
        final ranking = UserRanking(
          globalRank: 42,
          totalUsers: 1500,
          percentile: 97.2,
          friendsRank: 3,
          totalFriends: null,
          calculatedAt: testDate,
        );

        expect(ranking.hasFriends, isFalse);
      });

      test('returns false when both are null', () {
        final ranking = UserRanking(
          globalRank: 42,
          totalUsers: 1500,
          percentile: 97.2,
          friendsRank: null,
          totalFriends: null,
          calculatedAt: testDate,
        );

        expect(ranking.hasFriends, isFalse);
      });
    });

    group('isTopTenPercent', () {
      test('returns true for 90th percentile', () {
        final ranking = UserRanking(
          globalRank: 100,
          totalUsers: 1000,
          percentile: 90.0,
          calculatedAt: testDate,
        );

        expect(ranking.isTopTenPercent, isTrue);
      });

      test('returns true for 95th percentile', () {
        final ranking = UserRanking(
          globalRank: 42,
          totalUsers: 1000,
          percentile: 95.8,
          calculatedAt: testDate,
        );

        expect(ranking.isTopTenPercent, isTrue);
      });

      test('returns false for 89.9th percentile', () {
        final ranking = UserRanking(
          globalRank: 101,
          totalUsers: 1000,
          percentile: 89.9,
          calculatedAt: testDate,
        );

        expect(ranking.isTopTenPercent, isFalse);
      });

      test('returns false for 50th percentile', () {
        final ranking = UserRanking(
          globalRank: 500,
          totalUsers: 1000,
          percentile: 50.0,
          calculatedAt: testDate,
        );

        expect(ranking.isTopTenPercent, isFalse);
      });
    });

    group('isTopTwentyFivePercent', () {
      test('returns true for 75th percentile', () {
        final ranking = UserRanking(
          globalRank: 250,
          totalUsers: 1000,
          percentile: 75.0,
          calculatedAt: testDate,
        );

        expect(ranking.isTopTwentyFivePercent, isTrue);
      });

      test('returns true for 90th percentile', () {
        final ranking = UserRanking(
          globalRank: 100,
          totalUsers: 1000,
          percentile: 90.0,
          calculatedAt: testDate,
        );

        expect(ranking.isTopTwentyFivePercent, isTrue);
      });

      test('returns false for 74.9th percentile', () {
        final ranking = UserRanking(
          globalRank: 251,
          totalUsers: 1000,
          percentile: 74.9,
          calculatedAt: testDate,
        );

        expect(ranking.isTopTwentyFivePercent, isFalse);
      });
    });

    group('isGlobalFirst', () {
      test('returns true for rank #1', () {
        final ranking = UserRanking(
          globalRank: 1,
          totalUsers: 1000,
          percentile: 100.0,
          calculatedAt: testDate,
        );

        expect(ranking.isGlobalFirst, isTrue);
      });

      test('returns false for rank #2', () {
        final ranking = UserRanking(
          globalRank: 2,
          totalUsers: 1000,
          percentile: 99.9,
          calculatedAt: testDate,
        );

        expect(ranking.isGlobalFirst, isFalse);
      });
    });

    group('isFriendsFirst', () {
      test('returns true for friends rank #1', () {
        final ranking = UserRanking(
          globalRank: 42,
          totalUsers: 1000,
          percentile: 95.8,
          friendsRank: 1,
          totalFriends: 15,
          calculatedAt: testDate,
        );

        expect(ranking.isFriendsFirst, isTrue);
      });

      test('returns false for friends rank #2', () {
        final ranking = UserRanking(
          globalRank: 42,
          totalUsers: 1000,
          percentile: 95.8,
          friendsRank: 2,
          totalFriends: 15,
          calculatedAt: testDate,
        );

        expect(ranking.isFriendsFirst, isFalse);
      });

      test('returns false when friendsRank is null', () {
        final ranking = UserRanking(
          globalRank: 42,
          totalUsers: 1000,
          percentile: 95.8,
          friendsRank: null,
          totalFriends: null,
          calculatedAt: testDate,
        );

        expect(ranking.isFriendsFirst, isFalse);
      });
    });

    group('fromJson', () {
      test('deserializes from JSON with all fields', () {
        final json = {
          'globalRank': 42,
          'totalUsers': 1500,
          'percentile': 97.2,
          'friendsRank': 3,
          'totalFriends': 15,
          'calculatedAt': testTimestamp,
        };

        final ranking = UserRanking.fromJson(json);

        expect(ranking.globalRank, equals(42));
        expect(ranking.totalUsers, equals(1500));
        expect(ranking.percentile, equals(97.2));
        expect(ranking.friendsRank, equals(3));
        expect(ranking.totalFriends, equals(15));
        expect(ranking.calculatedAt, equals(testDate));
      });

      test('deserializes from JSON without friends ranking', () {
        final json = {
          'globalRank': 42,
          'totalUsers': 1500,
          'percentile': 97.2,
          'friendsRank': null,
          'totalFriends': null,
          'calculatedAt': testTimestamp,
        };

        final ranking = UserRanking.fromJson(json);

        expect(ranking.friendsRank, isNull);
        expect(ranking.totalFriends, isNull);
      });

      test('deserializes from JSON with DateTime string', () {
        final json = {
          'globalRank': 42,
          'totalUsers': 1500,
          'percentile': 97.2,
          'calculatedAt': testDate.toIso8601String(),
        };

        final ranking = UserRanking.fromJson(json);

        expect(ranking.calculatedAt.year, equals(testDate.year));
        expect(ranking.calculatedAt.month, equals(testDate.month));
        expect(ranking.calculatedAt.day, equals(testDate.day));
      });
    });

    group('toJson', () {
      test('serializes to JSON correctly', () {
        final ranking = UserRanking(
          globalRank: 42,
          totalUsers: 1500,
          percentile: 97.2,
          friendsRank: 3,
          totalFriends: 15,
          calculatedAt: testDate,
        );

        final json = ranking.toJson();

        expect(json['globalRank'], equals(42));
        expect(json['totalUsers'], equals(1500));
        expect(json['percentile'], equals(97.2));
        expect(json['friendsRank'], equals(3));
        expect(json['totalFriends'], equals(15));
        expect(json['calculatedAt'], isNotNull);
      });

      test('round-trip serialization preserves data', () {
        final original = UserRanking(
          globalRank: 42,
          totalUsers: 1500,
          percentile: 97.2,
          friendsRank: 3,
          totalFriends: 15,
          calculatedAt: testDate,
        );

        final json = original.toJson();
        final deserialized = UserRanking.fromJson(json);

        expect(deserialized.globalRank, equals(original.globalRank));
        expect(deserialized.totalUsers, equals(original.totalUsers));
        expect(deserialized.percentile, equals(original.percentile));
        expect(deserialized.friendsRank, equals(original.friendsRank));
        expect(deserialized.totalFriends, equals(original.totalFriends));
      });
    });

    group('equality', () {
      test('two rankings with same values are equal', () {
        final ranking1 = UserRanking(
          globalRank: 42,
          totalUsers: 1500,
          percentile: 97.2,
          friendsRank: 3,
          totalFriends: 15,
          calculatedAt: testDate,
        );

        final ranking2 = UserRanking(
          globalRank: 42,
          totalUsers: 1500,
          percentile: 97.2,
          friendsRank: 3,
          totalFriends: 15,
          calculatedAt: testDate,
        );

        expect(ranking1, equals(ranking2));
        expect(ranking1.hashCode, equals(ranking2.hashCode));
      });

      test('two rankings with different globalRank are not equal', () {
        final ranking1 = UserRanking(
          globalRank: 42,
          totalUsers: 1500,
          percentile: 97.2,
          calculatedAt: testDate,
        );

        final ranking2 = UserRanking(
          globalRank: 43,
          totalUsers: 1500,
          percentile: 97.2,
          calculatedAt: testDate,
        );

        expect(ranking1, isNot(equals(ranking2)));
      });
    });

    group('copyWith', () {
      test('creates copy with updated globalRank', () {
        final original = UserRanking(
          globalRank: 42,
          totalUsers: 1500,
          percentile: 97.2,
          calculatedAt: testDate,
        );

        final copy = original.copyWith(globalRank: 41);

        expect(copy.globalRank, equals(41));
        expect(copy.totalUsers, equals(original.totalUsers));
        expect(copy.percentile, equals(original.percentile));
      });

      test('creates copy with updated friendsRank', () {
        final original = UserRanking(
          globalRank: 42,
          totalUsers: 1500,
          percentile: 97.2,
          friendsRank: 3,
          totalFriends: 15,
          calculatedAt: testDate,
        );

        final copy = original.copyWith(friendsRank: 2);

        expect(copy.friendsRank, equals(2));
        expect(copy.totalFriends, equals(original.totalFriends));
      });

      test('creates identical copy when no parameters provided', () {
        final original = UserRanking(
          globalRank: 42,
          totalUsers: 1500,
          percentile: 97.2,
          calculatedAt: testDate,
        );

        final copy = original.copyWith();

        expect(copy, equals(original));
      });
    });

    group('edge cases', () {
      test('handles single user (rank #1 of 1)', () {
        final ranking = UserRanking(
          globalRank: 1,
          totalUsers: 1,
          percentile: 100.0,
          calculatedAt: testDate,
        );

        expect(ranking.globalRankDisplay, equals('#1 of 1'));
        expect(ranking.percentileDisplay, equals('Top 0.0%'));
        expect(ranking.isGlobalFirst, isTrue);
      });

      test('handles large user base (millions)', () {
        final ranking = UserRanking(
          globalRank: 1234,
          totalUsers: 5000000,
          percentile: 99.975,
          calculatedAt: testDate,
        );

        expect(ranking.globalRankDisplay, equals('#1234 of 5,000,000'));
        expect(ranking.percentileDisplay, equals('Top 0.0%'));
      });

      test('handles 0 percentile correctly', () {
        final ranking = UserRanking(
          globalRank: 1000,
          totalUsers: 1000,
          percentile: 0.0,
          calculatedAt: testDate,
        );

        expect(ranking.percentileDisplay, equals('Top 100.0%'));
        expect(ranking.isTopTenPercent, isFalse);
      });

      test('handles fractional percentile', () {
        final ranking = UserRanking(
          globalRank: 42,
          totalUsers: 1234,
          percentile: 96.5927,
          calculatedAt: testDate,
        );

        expect(ranking.percentileDisplay, equals('Top 3.4%'));
      });
    });
  });
}
