// Tests TrainingSessionParticipantModel for serialization and helper methods.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:play_with_me/core/data/models/training_session_participant_model.dart';

void main() {
  group('TrainingSessionParticipantModel', () {
    late DateTime testJoinedAt;
    late TrainingSessionParticipantModel baseParticipant;

    setUp(() {
      testJoinedAt = DateTime(2024, 1, 15, 10, 30);
      baseParticipant = TrainingSessionParticipantModel(
        userId: 'user-123',
        joinedAt: testJoinedAt,
        status: ParticipantStatus.joined,
      );
    });

    group('constructor', () {
      test('creates instance with required fields', () {
        expect(baseParticipant.userId, equals('user-123'));
        expect(baseParticipant.joinedAt, equals(testJoinedAt));
        expect(baseParticipant.status, equals(ParticipantStatus.joined));
      });

      test('creates instance with default status', () {
        final participant = TrainingSessionParticipantModel(
          userId: 'user-456',
          joinedAt: testJoinedAt,
        );

        expect(participant.status, equals(ParticipantStatus.joined));
      });

      test('creates instance with left status', () {
        final participant = TrainingSessionParticipantModel(
          userId: 'user-789',
          joinedAt: testJoinedAt,
          status: ParticipantStatus.left,
        );

        expect(participant.status, equals(ParticipantStatus.left));
      });
    });

    group('fromJson', () {
      test('parses valid JSON with ISO string date', () {
        final json = {
          'userId': 'user-123',
          'joinedAt': '2024-01-15T10:30:00.000',
          'status': 'joined',
        };

        final participant = TrainingSessionParticipantModel.fromJson(json);

        expect(participant.userId, equals('user-123'));
        expect(participant.joinedAt.year, equals(2024));
        expect(participant.joinedAt.month, equals(1));
        expect(participant.joinedAt.day, equals(15));
        expect(participant.status, equals(ParticipantStatus.joined));
      });

      test('parses JSON with left status', () {
        final json = {
          'userId': 'user-456',
          'joinedAt': '2024-02-20T14:00:00.000',
          'status': 'left',
        };

        final participant = TrainingSessionParticipantModel.fromJson(json);

        expect(participant.status, equals(ParticipantStatus.left));
      });

      test('parses JSON without status uses default', () {
        final json = {
          'userId': 'user-789',
          'joinedAt': '2024-03-10T09:00:00.000',
        };

        final participant = TrainingSessionParticipantModel.fromJson(json);

        expect(participant.status, equals(ParticipantStatus.joined));
      });
    });

    group('toJson', () {
      test('serializes to JSON correctly', () {
        final json = baseParticipant.toJson();

        expect(json['userId'], equals('user-123'));
        expect(json['status'], equals('joined'));
        expect(json.containsKey('joinedAt'), isTrue);
      });

      test('serializes left status correctly', () {
        final participant = TrainingSessionParticipantModel(
          userId: 'user-456',
          joinedAt: testJoinedAt,
          status: ParticipantStatus.left,
        );

        final json = participant.toJson();

        expect(json['status'], equals('left'));
      });
    });

    group('toFirestore', () {
      test('excludes userId from Firestore map', () {
        final firestoreData = baseParticipant.toFirestore();

        expect(firestoreData.containsKey('userId'), isFalse);
        expect(firestoreData['status'], equals('joined'));
      });

      test('converts joinedAt to Timestamp', () {
        final firestoreData = baseParticipant.toFirestore();

        expect(firestoreData['joinedAt'], isA<Timestamp>());
        final timestamp = firestoreData['joinedAt'] as Timestamp;
        expect(timestamp.toDate().year, equals(testJoinedAt.year));
        expect(timestamp.toDate().month, equals(testJoinedAt.month));
        expect(timestamp.toDate().day, equals(testJoinedAt.day));
      });
    });

    group('isJoined', () {
      test('returns true when status is joined', () {
        expect(baseParticipant.isJoined, isTrue);
      });

      test('returns false when status is left', () {
        final leftParticipant = TrainingSessionParticipantModel(
          userId: 'user-123',
          joinedAt: testJoinedAt,
          status: ParticipantStatus.left,
        );

        expect(leftParticipant.isJoined, isFalse);
      });
    });

    group('hasLeft', () {
      test('returns true when status is left', () {
        final leftParticipant = TrainingSessionParticipantModel(
          userId: 'user-123',
          joinedAt: testJoinedAt,
          status: ParticipantStatus.left,
        );

        expect(leftParticipant.hasLeft, isTrue);
      });

      test('returns false when status is joined', () {
        expect(baseParticipant.hasLeft, isFalse);
      });
    });

    group('copyWith', () {
      test('creates copy with updated userId', () {
        final copy = baseParticipant.copyWith(userId: 'new-user-id');

        expect(copy.userId, equals('new-user-id'));
        expect(copy.joinedAt, equals(baseParticipant.joinedAt));
        expect(copy.status, equals(baseParticipant.status));
      });

      test('creates copy with updated status', () {
        final copy = baseParticipant.copyWith(status: ParticipantStatus.left);

        expect(copy.userId, equals(baseParticipant.userId));
        expect(copy.status, equals(ParticipantStatus.left));
      });

      test('creates copy with updated joinedAt', () {
        final newDate = DateTime(2024, 6, 1);
        final copy = baseParticipant.copyWith(joinedAt: newDate);

        expect(copy.joinedAt, equals(newDate));
      });
    });

    group('equality', () {
      test('two participants with same values are equal', () {
        final participant1 = TrainingSessionParticipantModel(
          userId: 'user-123',
          joinedAt: testJoinedAt,
          status: ParticipantStatus.joined,
        );

        final participant2 = TrainingSessionParticipantModel(
          userId: 'user-123',
          joinedAt: testJoinedAt,
          status: ParticipantStatus.joined,
        );

        expect(participant1, equals(participant2));
      });

      test('two participants with different userId are not equal', () {
        final participant1 = TrainingSessionParticipantModel(
          userId: 'user-123',
          joinedAt: testJoinedAt,
        );

        final participant2 = TrainingSessionParticipantModel(
          userId: 'user-456',
          joinedAt: testJoinedAt,
        );

        expect(participant1, isNot(equals(participant2)));
      });

      test('two participants with different status are not equal', () {
        final participant1 = TrainingSessionParticipantModel(
          userId: 'user-123',
          joinedAt: testJoinedAt,
          status: ParticipantStatus.joined,
        );

        final participant2 = TrainingSessionParticipantModel(
          userId: 'user-123',
          joinedAt: testJoinedAt,
          status: ParticipantStatus.left,
        );

        expect(participant1, isNot(equals(participant2)));
      });
    });

    group('hashCode', () {
      test('same values produce same hashCode', () {
        final participant1 = TrainingSessionParticipantModel(
          userId: 'user-123',
          joinedAt: testJoinedAt,
          status: ParticipantStatus.joined,
        );

        final participant2 = TrainingSessionParticipantModel(
          userId: 'user-123',
          joinedAt: testJoinedAt,
          status: ParticipantStatus.joined,
        );

        expect(participant1.hashCode, equals(participant2.hashCode));
      });
    });
  });

  group('ParticipantStatus', () {
    test('joined has correct JSON value', () {
      expect(ParticipantStatus.joined.name, equals('joined'));
    });

    test('left has correct JSON value', () {
      expect(ParticipantStatus.left.name, equals('left'));
    });
  });
}
