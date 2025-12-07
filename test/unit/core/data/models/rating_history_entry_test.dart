// Tests RatingHistoryEntry Freezed model for ELO rating history (Story 14.5.3)
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:play_with_me/core/data/models/rating_history_entry.dart';

void main() {
  group('RatingHistoryEntry', () {
    late RatingHistoryEntry testEntry;
    late DateTime testTimestamp;

    setUp(() {
      testTimestamp = DateTime(2024, 12, 6, 14, 30, 0);
      testEntry = RatingHistoryEntry(
        entryId: 'entry-123',
        gameId: 'game-456',
        oldRating: 1600.0,
        newRating: 1632.5,
        ratingChange: 32.5,
        opponentTeam: 'Alice & Bob',
        won: true,
        timestamp: testTimestamp,
      );
    });

    group('Factory constructors', () {
      test('creates RatingHistoryEntry with all required fields', () {
        expect(testEntry.entryId, 'entry-123');
        expect(testEntry.gameId, 'game-456');
        expect(testEntry.oldRating, 1600.0);
        expect(testEntry.newRating, 1632.5);
        expect(testEntry.ratingChange, 32.5);
        expect(testEntry.opponentTeam, 'Alice & Bob');
        expect(testEntry.won, true);
        expect(testEntry.timestamp, testTimestamp);
      });

      test('creates entry for a loss', () {
        final lossEntry = RatingHistoryEntry(
          entryId: 'entry-789',
          gameId: 'game-abc',
          oldRating: 1650.0,
          newRating: 1618.0,
          ratingChange: -32.0,
          opponentTeam: 'Charlie & Dave',
          won: false,
          timestamp: testTimestamp,
        );

        expect(lossEntry.won, false);
        expect(lossEntry.ratingChange, -32.0);
        expect(lossEntry.newRating, 1618.0);
      });

      test('fromFirestore creates entry from DocumentSnapshot', () {
        final data = {
          'gameId': 'game-xyz',
          'oldRating': 1700.0,
          'newRating': 1725.0,
          'ratingChange': 25.0,
          'opponentTeam': 'Eve & Frank',
          'won': true,
          'timestamp': Timestamp.fromDate(testTimestamp),
        };

        final mockDoc = MockDocumentSnapshot('entry-abc', data);
        final entry = RatingHistoryEntry.fromFirestore(mockDoc);

        expect(entry.entryId, 'entry-abc');
        expect(entry.gameId, 'game-xyz');
        expect(entry.oldRating, 1700.0);
        expect(entry.newRating, 1725.0);
        expect(entry.ratingChange, 25.0);
        expect(entry.opponentTeam, 'Eve & Frank');
        expect(entry.won, true);
        expect(entry.timestamp, testTimestamp);
      });
    });

    group('JSON serialization', () {
      test('toJson serializes all fields correctly', () {
        final json = testEntry.toJson();

        expect(json['entryId'], 'entry-123');
        expect(json['gameId'], 'game-456');
        expect(json['oldRating'], 1600.0);
        expect(json['newRating'], 1632.5);
        expect(json['ratingChange'], 32.5);
        expect(json['opponentTeam'], 'Alice & Bob');
        expect(json['won'], true);
        expect(json['timestamp'], isA<Timestamp>());
      });

      test('fromJson deserializes all fields correctly', () {
        final json = {
          'entryId': 'entry-def',
          'gameId': 'game-ghi',
          'oldRating': 1550.0,
          'newRating': 1520.0,
          'ratingChange': -30.0,
          'opponentTeam': 'Grace & Henry',
          'won': false,
          'timestamp': Timestamp.fromDate(testTimestamp),
        };

        final entry = RatingHistoryEntry.fromJson(json);

        expect(entry.entryId, 'entry-def');
        expect(entry.gameId, 'game-ghi');
        expect(entry.oldRating, 1550.0);
        expect(entry.newRating, 1520.0);
        expect(entry.ratingChange, -30.0);
        expect(entry.opponentTeam, 'Grace & Henry');
        expect(entry.won, false);
        expect(entry.timestamp, testTimestamp);
      });

      test('toFirestore excludes entryId field', () {
        final firestoreData = testEntry.toFirestore();

        expect(firestoreData.containsKey('entryId'), false);
        expect(firestoreData['gameId'], 'game-456');
        expect(firestoreData['oldRating'], 1600.0);
        expect(firestoreData['newRating'], 1632.5);
        expect(firestoreData['ratingChange'], 32.5);
        expect(firestoreData['opponentTeam'], 'Alice & Bob');
        expect(firestoreData['won'], true);
        expect(firestoreData['timestamp'], isA<Timestamp>());
      });

      test('round trip serialization preserves data', () {
        final json = testEntry.toJson();
        final restored = RatingHistoryEntry.fromJson(json);

        expect(restored.entryId, testEntry.entryId);
        expect(restored.gameId, testEntry.gameId);
        expect(restored.oldRating, testEntry.oldRating);
        expect(restored.newRating, testEntry.newRating);
        expect(restored.ratingChange, testEntry.ratingChange);
        expect(restored.opponentTeam, testEntry.opponentTeam);
        expect(restored.won, testEntry.won);
        expect(restored.timestamp, testEntry.timestamp);
      });
    });

    group('Convenience getters', () {
      test('isGain returns true for positive rating change', () {
        expect(testEntry.isGain, true);
        expect(testEntry.isLoss, false);
      });

      test('isLoss returns true for negative rating change', () {
        final lossEntry = testEntry.copyWith(ratingChange: -15.0);

        expect(lossEntry.isGain, false);
        expect(lossEntry.isLoss, true);
      });

      test('isGain and isLoss both false for zero change', () {
        final zeroEntry = testEntry.copyWith(ratingChange: 0.0);

        expect(zeroEntry.isGain, false);
        expect(zeroEntry.isLoss, false);
      });

      test('absoluteChange returns absolute value', () {
        expect(testEntry.absoluteChange, 32.5);

        final lossEntry = testEntry.copyWith(ratingChange: -25.0);
        expect(lossEntry.absoluteChange, 25.0);

        final zeroEntry = testEntry.copyWith(ratingChange: 0.0);
        expect(zeroEntry.absoluteChange, 0.0);
      });

      test('formattedChange adds plus sign for positive', () {
        expect(testEntry.formattedChange, '+32.5');
      });

      test('formattedChange shows minus sign for negative', () {
        final lossEntry = testEntry.copyWith(ratingChange: -18.5);
        expect(lossEntry.formattedChange, '-18.5');
      });

      test('formattedChange shows plus for zero', () {
        final zeroEntry = testEntry.copyWith(ratingChange: 0.0);
        expect(zeroEntry.formattedChange, '+0.0');
      });

      test('formattedNewRating formats to whole number', () {
        expect(testEntry.formattedNewRating, '1633');

        final roundDown = testEntry.copyWith(newRating: 1632.4);
        expect(roundDown.formattedNewRating, '1632');
      });

      test('formattedOldRating formats to whole number', () {
        expect(testEntry.formattedOldRating, '1600');

        final decimal = testEntry.copyWith(oldRating: 1599.9);
        expect(decimal.formattedOldRating, '1600');
      });
    });

    group('Equality and copyWith', () {
      test('two entries with same data are equal', () {
        final entry1 = RatingHistoryEntry(
          entryId: 'same-id',
          gameId: 'same-game',
          oldRating: 1600.0,
          newRating: 1616.0,
          ratingChange: 16.0,
          opponentTeam: 'Team A',
          won: true,
          timestamp: testTimestamp,
        );

        final entry2 = RatingHistoryEntry(
          entryId: 'same-id',
          gameId: 'same-game',
          oldRating: 1600.0,
          newRating: 1616.0,
          ratingChange: 16.0,
          opponentTeam: 'Team A',
          won: true,
          timestamp: testTimestamp,
        );

        expect(entry1, equals(entry2));
      });

      test('copyWith updates specific fields', () {
        final updated = testEntry.copyWith(
          gameId: 'new-game',
          newRating: 1650.0,
        );

        expect(updated.entryId, testEntry.entryId);
        expect(updated.gameId, 'new-game');
        expect(updated.oldRating, testEntry.oldRating);
        expect(updated.newRating, 1650.0);
        expect(updated.ratingChange, testEntry.ratingChange);
        expect(updated.opponentTeam, testEntry.opponentTeam);
        expect(updated.won, testEntry.won);
        expect(updated.timestamp, testEntry.timestamp);
      });
    });

    group('Edge cases', () {
      test('handles very large ratings', () {
        final highRated = RatingHistoryEntry(
          entryId: 'entry-high',
          gameId: 'game-high',
          oldRating: 2500.0,
          newRating: 2508.5,
          ratingChange: 8.5,
          opponentTeam: 'Elite Team',
          won: true,
          timestamp: testTimestamp,
        );

        expect(highRated.formattedNewRating, '2509');
        expect(highRated.formattedOldRating, '2500');
        expect(highRated.formattedChange, '+8.5');
      });

      test('handles very small rating changes', () {
        final smallChange = RatingHistoryEntry(
          entryId: 'entry-small',
          gameId: 'game-small',
          oldRating: 1600.0,
          newRating: 1600.5,
          ratingChange: 0.5,
          opponentTeam: 'Close Match Team',
          won: true,
          timestamp: testTimestamp,
        );

        expect(smallChange.formattedChange, '+0.5');
        expect(smallChange.isGain, true);
      });

      test('handles opponent team with special characters', () {
        final specialChars = testEntry.copyWith(
          opponentTeam: "O'Brien & Müller",
        );

        expect(specialChars.opponentTeam, "O'Brien & Müller");

        final json = specialChars.toJson();
        final restored = RatingHistoryEntry.fromJson(json);
        expect(restored.opponentTeam, "O'Brien & Müller");
      });

      test('handles timestamp at epoch', () {
        final epochEntry = testEntry.copyWith(
          timestamp: DateTime.fromMillisecondsSinceEpoch(0),
        );

        final json = epochEntry.toJson();
        final restored = RatingHistoryEntry.fromJson(json);

        expect(restored.timestamp, DateTime.fromMillisecondsSinceEpoch(0));
      });
    });
  });
}

// Mock DocumentSnapshot for testing
class MockDocumentSnapshot implements DocumentSnapshot {
  final String _id;
  final Map<String, dynamic> _data;

  MockDocumentSnapshot(this._id, this._data);

  @override
  String get id => _id;

  @override
  Map<String, dynamic>? data() => _data;

  @override
  bool get exists => true;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
