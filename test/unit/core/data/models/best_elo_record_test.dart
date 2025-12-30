// Tests BestEloRecord model for peak ELO performance tracking (Story 302.1).

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:play_with_me/core/data/models/best_elo_record.dart';

void main() {
  group('BestEloRecord', () {
    final testDate = DateTime(2025, 12, 15, 14, 30);
    final testTimestamp = Timestamp.fromDate(testDate);

    group('constructor', () {
      test('creates instance with all required fields', () {
        final record = BestEloRecord(
          elo: 1847.5,
          date: testDate,
          gameId: 'game-123',
        );

        expect(record.elo, equals(1847.5));
        expect(record.date, equals(testDate));
        expect(record.gameId, equals('game-123'));
      });

      test('creates instance with different values', () {
        final anotherDate = DateTime(2025, 11, 20, 10, 0);
        final record = BestEloRecord(
          elo: 2000.0,
          date: anotherDate,
          gameId: 'game-456',
        );

        expect(record.elo, equals(2000.0));
        expect(record.date, equals(anotherDate));
        expect(record.gameId, equals('game-456'));
      });
    });

    group('fromJson', () {
      test('deserializes from JSON with Timestamp', () {
        final json = {
          'elo': 1847.5,
          'date': testTimestamp,
          'gameId': 'game-123',
        };

        final record = BestEloRecord.fromJson(json);

        expect(record.elo, equals(1847.5));
        expect(record.date, equals(testDate));
        expect(record.gameId, equals('game-123'));
      });

      test('deserializes from JSON with DateTime string', () {
        final json = {
          'elo': 1900.0,
          'date': testDate.toIso8601String(),
          'gameId': 'game-789',
        };

        final record = BestEloRecord.fromJson(json);

        expect(record.elo, equals(1900.0));
        expect(record.gameId, equals('game-789'));
        // Date should be parsed correctly
        expect(record.date.year, equals(testDate.year));
        expect(record.date.month, equals(testDate.month));
        expect(record.date.day, equals(testDate.day));
      });

      test('handles integer ELO values', () {
        final json = {
          'elo': 1850, // Integer instead of double
          'date': testTimestamp,
          'gameId': 'game-int',
        };

        final record = BestEloRecord.fromJson(json);

        expect(record.elo, equals(1850.0));
      });
    });

    group('toJson', () {
      test('serializes to JSON correctly', () {
        final record = BestEloRecord(
          elo: 1847.5,
          date: testDate,
          gameId: 'game-123',
        );

        final json = record.toJson();

        expect(json['elo'], equals(1847.5));
        expect(json['gameId'], equals('game-123'));
        // Date should be serialized as Timestamp or ISO string
        expect(json['date'], isNotNull);
      });

      test('round-trip serialization preserves data', () {
        final original = BestEloRecord(
          elo: 1999.99,
          date: testDate,
          gameId: 'game-roundtrip',
        );

        final json = original.toJson();
        final deserialized = BestEloRecord.fromJson(json);

        expect(deserialized.elo, equals(original.elo));
        expect(deserialized.gameId, equals(original.gameId));
        // Date comparison (allow microsecond precision difference)
        expect(
          deserialized.date.difference(original.date).abs().inMilliseconds,
          lessThan(1),
        );
      });
    });

    group('equality', () {
      test('two records with same values are equal', () {
        final record1 = BestEloRecord(
          elo: 1847.5,
          date: testDate,
          gameId: 'game-123',
        );

        final record2 = BestEloRecord(
          elo: 1847.5,
          date: testDate,
          gameId: 'game-123',
        );

        expect(record1, equals(record2));
        expect(record1.hashCode, equals(record2.hashCode));
      });

      test('two records with different elo are not equal', () {
        final record1 = BestEloRecord(
          elo: 1847.5,
          date: testDate,
          gameId: 'game-123',
        );

        final record2 = BestEloRecord(
          elo: 1850.0,
          date: testDate,
          gameId: 'game-123',
        );

        expect(record1, isNot(equals(record2)));
      });

      test('two records with different gameId are not equal', () {
        final record1 = BestEloRecord(
          elo: 1847.5,
          date: testDate,
          gameId: 'game-123',
        );

        final record2 = BestEloRecord(
          elo: 1847.5,
          date: testDate,
          gameId: 'game-456',
        );

        expect(record1, isNot(equals(record2)));
      });

      test('two records with different date are not equal', () {
        final record1 = BestEloRecord(
          elo: 1847.5,
          date: testDate,
          gameId: 'game-123',
        );

        final record2 = BestEloRecord(
          elo: 1847.5,
          date: testDate.add(const Duration(days: 1)),
          gameId: 'game-123',
        );

        expect(record1, isNot(equals(record2)));
      });
    });

    group('copyWith', () {
      test('creates copy with updated elo', () {
        final original = BestEloRecord(
          elo: 1847.5,
          date: testDate,
          gameId: 'game-123',
        );

        final copy = original.copyWith(elo: 1900.0);

        expect(copy.elo, equals(1900.0));
        expect(copy.date, equals(original.date));
        expect(copy.gameId, equals(original.gameId));
      });

      test('creates copy with updated date', () {
        final original = BestEloRecord(
          elo: 1847.5,
          date: testDate,
          gameId: 'game-123',
        );

        final newDate = DateTime(2025, 12, 20);
        final copy = original.copyWith(date: newDate);

        expect(copy.elo, equals(original.elo));
        expect(copy.date, equals(newDate));
        expect(copy.gameId, equals(original.gameId));
      });

      test('creates copy with updated gameId', () {
        final original = BestEloRecord(
          elo: 1847.5,
          date: testDate,
          gameId: 'game-123',
        );

        final copy = original.copyWith(gameId: 'game-new');

        expect(copy.elo, equals(original.elo));
        expect(copy.date, equals(original.date));
        expect(copy.gameId, equals('game-new'));
      });

      test('creates identical copy when no parameters provided', () {
        final original = BestEloRecord(
          elo: 1847.5,
          date: testDate,
          gameId: 'game-123',
        );

        final copy = original.copyWith();

        expect(copy, equals(original));
      });
    });

    group('edge cases', () {
      test('handles very high ELO values', () {
        final record = BestEloRecord(
          elo: 9999.99,
          date: testDate,
          gameId: 'game-high',
        );

        expect(record.elo, equals(9999.99));
      });

      test('handles very low ELO values', () {
        final record = BestEloRecord(
          elo: 0.01,
          date: testDate,
          gameId: 'game-low',
        );

        expect(record.elo, equals(0.01));
      });

      test('handles past dates', () {
        final pastDate = DateTime(2020, 1, 1);
        final record = BestEloRecord(
          elo: 1500.0,
          date: pastDate,
          gameId: 'game-past',
        );

        expect(record.date, equals(pastDate));
      });

      test('handles future dates', () {
        final futureDate = DateTime(2030, 12, 31);
        final record = BestEloRecord(
          elo: 1500.0,
          date: futureDate,
          gameId: 'game-future',
        );

        expect(record.date, equals(futureDate));
      });

      test('handles empty gameId', () {
        final record = BestEloRecord(
          elo: 1500.0,
          date: testDate,
          gameId: '',
        );

        expect(record.gameId, equals(''));
      });
    });
  });
}
