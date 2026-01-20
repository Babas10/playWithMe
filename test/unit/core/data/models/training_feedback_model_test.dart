// Tests TrainingFeedbackModel for serialization and validation methods.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:play_with_me/core/data/models/training_feedback_model.dart';

void main() {
  group('TrainingFeedbackModel', () {
    late DateTime testSubmittedAt;
    late TrainingFeedbackModel baseFeedback;

    setUp(() {
      testSubmittedAt = DateTime(2024, 1, 15, 10, 30);
      baseFeedback = TrainingFeedbackModel(
        id: 'feedback-123',
        trainingSessionId: 'session-456',
        exercisesQuality: 4,
        trainingIntensity: 5,
        coachingClarity: 3,
        comment: 'Great session!',
        participantHash: 'hash-abc123',
        submittedAt: testSubmittedAt,
      );
    });

    group('constructor', () {
      test('creates instance with all required fields', () {
        expect(baseFeedback.id, equals('feedback-123'));
        expect(baseFeedback.trainingSessionId, equals('session-456'));
        expect(baseFeedback.exercisesQuality, equals(4));
        expect(baseFeedback.trainingIntensity, equals(5));
        expect(baseFeedback.coachingClarity, equals(3));
        expect(baseFeedback.comment, equals('Great session!'));
        expect(baseFeedback.participantHash, equals('hash-abc123'));
        expect(baseFeedback.submittedAt, equals(testSubmittedAt));
      });

      test('creates instance with null comment', () {
        final feedback = TrainingFeedbackModel(
          id: 'feedback-789',
          trainingSessionId: 'session-123',
          exercisesQuality: 3,
          trainingIntensity: 4,
          coachingClarity: 5,
          participantHash: 'hash-xyz',
          submittedAt: testSubmittedAt,
        );

        expect(feedback.comment, isNull);
      });
    });

    group('fromJson', () {
      test('parses valid JSON with ISO string date', () {
        final json = {
          'id': 'feedback-123',
          'trainingSessionId': 'session-456',
          'exercisesQuality': 4,
          'trainingIntensity': 5,
          'coachingClarity': 3,
          'comment': 'Great session!',
          'participantHash': 'hash-abc',
          'submittedAt': '2024-01-15T10:30:00.000',
        };

        final feedback = TrainingFeedbackModel.fromJson(json);

        expect(feedback.id, equals('feedback-123'));
        expect(feedback.exercisesQuality, equals(4));
        expect(feedback.trainingIntensity, equals(5));
        expect(feedback.coachingClarity, equals(3));
        expect(feedback.comment, equals('Great session!'));
      });

      test('parses JSON without comment', () {
        final json = {
          'id': 'feedback-456',
          'trainingSessionId': 'session-789',
          'exercisesQuality': 3,
          'trainingIntensity': 4,
          'coachingClarity': 5,
          'participantHash': 'hash-def',
          'submittedAt': '2024-02-20T14:00:00.000',
        };

        final feedback = TrainingFeedbackModel.fromJson(json);

        expect(feedback.comment, isNull);
      });
    });

    group('toJson', () {
      test('serializes to JSON correctly', () {
        final json = baseFeedback.toJson();

        expect(json['id'], equals('feedback-123'));
        expect(json['trainingSessionId'], equals('session-456'));
        expect(json['exercisesQuality'], equals(4));
        expect(json['trainingIntensity'], equals(5));
        expect(json['coachingClarity'], equals(3));
        expect(json['comment'], equals('Great session!'));
        expect(json['participantHash'], equals('hash-abc123'));
      });

      test('serializes null comment correctly', () {
        final feedback = TrainingFeedbackModel(
          id: 'feedback-789',
          trainingSessionId: 'session-123',
          exercisesQuality: 3,
          trainingIntensity: 4,
          coachingClarity: 5,
          participantHash: 'hash-xyz',
          submittedAt: testSubmittedAt,
        );

        final json = feedback.toJson();

        expect(json['comment'], isNull);
      });
    });

    group('toFirestore', () {
      test('excludes id from Firestore map', () {
        final firestoreData = baseFeedback.toFirestore();

        expect(firestoreData.containsKey('id'), isFalse);
      });

      test('excludes trainingSessionId from Firestore map', () {
        final firestoreData = baseFeedback.toFirestore();

        expect(firestoreData.containsKey('trainingSessionId'), isFalse);
      });

      test('converts submittedAt to Timestamp', () {
        final firestoreData = baseFeedback.toFirestore();

        expect(firestoreData['submittedAt'], isA<Timestamp>());
        final timestamp = firestoreData['submittedAt'] as Timestamp;
        expect(timestamp.toDate().year, equals(testSubmittedAt.year));
      });

      test('includes all rating fields', () {
        final firestoreData = baseFeedback.toFirestore();

        expect(firestoreData['exercisesQuality'], equals(4));
        expect(firestoreData['trainingIntensity'], equals(5));
        expect(firestoreData['coachingClarity'], equals(3));
      });
    });

    group('hasValidExercisesQuality', () {
      test('returns true for valid ratings 1-5', () {
        for (int i = 1; i <= 5; i++) {
          final feedback = baseFeedback.copyWith(exercisesQuality: i);
          expect(feedback.hasValidExercisesQuality, isTrue,
              reason: 'Rating $i should be valid');
        }
      });

      test('returns false for rating below 1', () {
        final feedback = baseFeedback.copyWith(exercisesQuality: 0);
        expect(feedback.hasValidExercisesQuality, isFalse);
      });

      test('returns false for rating above 5', () {
        final feedback = baseFeedback.copyWith(exercisesQuality: 6);
        expect(feedback.hasValidExercisesQuality, isFalse);
      });

      test('returns false for negative rating', () {
        final feedback = baseFeedback.copyWith(exercisesQuality: -1);
        expect(feedback.hasValidExercisesQuality, isFalse);
      });
    });

    group('hasValidTrainingIntensity', () {
      test('returns true for valid ratings 1-5', () {
        for (int i = 1; i <= 5; i++) {
          final feedback = baseFeedback.copyWith(trainingIntensity: i);
          expect(feedback.hasValidTrainingIntensity, isTrue,
              reason: 'Rating $i should be valid');
        }
      });

      test('returns false for rating below 1', () {
        final feedback = baseFeedback.copyWith(trainingIntensity: 0);
        expect(feedback.hasValidTrainingIntensity, isFalse);
      });

      test('returns false for rating above 5', () {
        final feedback = baseFeedback.copyWith(trainingIntensity: 6);
        expect(feedback.hasValidTrainingIntensity, isFalse);
      });
    });

    group('hasValidCoachingClarity', () {
      test('returns true for valid ratings 1-5', () {
        for (int i = 1; i <= 5; i++) {
          final feedback = baseFeedback.copyWith(coachingClarity: i);
          expect(feedback.hasValidCoachingClarity, isTrue,
              reason: 'Rating $i should be valid');
        }
      });

      test('returns false for rating below 1', () {
        final feedback = baseFeedback.copyWith(coachingClarity: 0);
        expect(feedback.hasValidCoachingClarity, isFalse);
      });

      test('returns false for rating above 5', () {
        final feedback = baseFeedback.copyWith(coachingClarity: 6);
        expect(feedback.hasValidCoachingClarity, isFalse);
      });
    });

    group('hasValidRatings', () {
      test('returns true when all ratings are valid', () {
        expect(baseFeedback.hasValidRatings, isTrue);
      });

      test('returns false when exercisesQuality is invalid', () {
        final feedback = baseFeedback.copyWith(exercisesQuality: 0);
        expect(feedback.hasValidRatings, isFalse);
      });

      test('returns false when trainingIntensity is invalid', () {
        final feedback = baseFeedback.copyWith(trainingIntensity: 6);
        expect(feedback.hasValidRatings, isFalse);
      });

      test('returns false when coachingClarity is invalid', () {
        final feedback = baseFeedback.copyWith(coachingClarity: -1);
        expect(feedback.hasValidRatings, isFalse);
      });

      test('returns false when multiple ratings are invalid', () {
        final feedback = baseFeedback.copyWith(
          exercisesQuality: 0,
          trainingIntensity: 10,
        );
        expect(feedback.hasValidRatings, isFalse);
      });
    });

    group('hasComment', () {
      test('returns true when comment is non-empty', () {
        expect(baseFeedback.hasComment, isTrue);
      });

      test('returns false when comment is null', () {
        final feedback = baseFeedback.copyWith(comment: null);
        expect(feedback.hasComment, isFalse);
      });

      test('returns false when comment is empty string', () {
        final feedback = baseFeedback.copyWith(comment: '');
        expect(feedback.hasComment, isFalse);
      });

      test('returns false when comment is only whitespace', () {
        final feedback = baseFeedback.copyWith(comment: '   ');
        expect(feedback.hasComment, isFalse);
      });
    });

    group('sanitizedComment', () {
      test('returns trimmed comment when non-empty', () {
        final feedback = baseFeedback.copyWith(comment: '  Great session!  ');
        expect(feedback.sanitizedComment, equals('Great session!'));
      });

      test('returns null when comment is null', () {
        final feedback = baseFeedback.copyWith(comment: null);
        expect(feedback.sanitizedComment, isNull);
      });

      test('returns null when comment is empty', () {
        final feedback = baseFeedback.copyWith(comment: '');
        expect(feedback.sanitizedComment, isNull);
      });

      test('returns null when comment is only whitespace', () {
        final feedback = baseFeedback.copyWith(comment: '   \n\t  ');
        expect(feedback.sanitizedComment, isNull);
      });
    });

    group('averageRating', () {
      test('calculates correct average for all same ratings', () {
        final feedback = TrainingFeedbackModel(
          id: 'feedback-1',
          trainingSessionId: 'session-1',
          exercisesQuality: 3,
          trainingIntensity: 3,
          coachingClarity: 3,
          participantHash: 'hash',
          submittedAt: testSubmittedAt,
        );

        expect(feedback.averageRating, equals(3.0));
      });

      test('calculates correct average for different ratings', () {
        // (4 + 5 + 3) / 3 = 4.0
        expect(baseFeedback.averageRating, equals(4.0));
      });

      test('calculates correct average with decimals', () {
        final feedback = TrainingFeedbackModel(
          id: 'feedback-1',
          trainingSessionId: 'session-1',
          exercisesQuality: 4,
          trainingIntensity: 4,
          coachingClarity: 5,
          participantHash: 'hash',
          submittedAt: testSubmittedAt,
        );

        // (4 + 4 + 5) / 3 = 4.333...
        expect(feedback.averageRating, closeTo(4.33, 0.01));
      });

      test('calculates correct average for minimum ratings', () {
        final feedback = TrainingFeedbackModel(
          id: 'feedback-1',
          trainingSessionId: 'session-1',
          exercisesQuality: 1,
          trainingIntensity: 1,
          coachingClarity: 1,
          participantHash: 'hash',
          submittedAt: testSubmittedAt,
        );

        expect(feedback.averageRating, equals(1.0));
      });

      test('calculates correct average for maximum ratings', () {
        final feedback = TrainingFeedbackModel(
          id: 'feedback-1',
          trainingSessionId: 'session-1',
          exercisesQuality: 5,
          trainingIntensity: 5,
          coachingClarity: 5,
          participantHash: 'hash',
          submittedAt: testSubmittedAt,
        );

        expect(feedback.averageRating, equals(5.0));
      });
    });

    group('copyWith', () {
      test('creates copy with updated exercisesQuality', () {
        final copy = baseFeedback.copyWith(exercisesQuality: 2);

        expect(copy.exercisesQuality, equals(2));
        expect(copy.trainingIntensity, equals(baseFeedback.trainingIntensity));
        expect(copy.coachingClarity, equals(baseFeedback.coachingClarity));
      });

      test('creates copy with updated comment', () {
        final copy = baseFeedback.copyWith(comment: 'New comment');

        expect(copy.comment, equals('New comment'));
      });
    });

    group('equality', () {
      test('two feedbacks with same values are equal', () {
        final feedback1 = TrainingFeedbackModel(
          id: 'feedback-123',
          trainingSessionId: 'session-456',
          exercisesQuality: 4,
          trainingIntensity: 5,
          coachingClarity: 3,
          participantHash: 'hash-abc123',
          submittedAt: testSubmittedAt,
        );

        final feedback2 = TrainingFeedbackModel(
          id: 'feedback-123',
          trainingSessionId: 'session-456',
          exercisesQuality: 4,
          trainingIntensity: 5,
          coachingClarity: 3,
          participantHash: 'hash-abc123',
          submittedAt: testSubmittedAt,
        );

        expect(feedback1, equals(feedback2));
      });

      test('two feedbacks with different id are not equal', () {
        final feedback1 = baseFeedback;
        final feedback2 = baseFeedback.copyWith(id: 'different-id');

        expect(feedback1, isNot(equals(feedback2)));
      });
    });
  });

  group('TimestampConverter', () {
    const converter = TimestampConverter();

    test('fromJson parses Timestamp', () {
      final timestamp = Timestamp.fromDate(DateTime(2024, 1, 15));
      final result = converter.fromJson(timestamp);

      expect(result.year, equals(2024));
      expect(result.month, equals(1));
      expect(result.day, equals(15));
    });

    test('fromJson parses ISO string', () {
      final result = converter.fromJson('2024-01-15T10:30:00.000');

      expect(result.year, equals(2024));
      expect(result.month, equals(1));
      expect(result.day, equals(15));
    });

    test('fromJson throws for invalid format', () {
      expect(() => converter.fromJson(12345), throwsA(isA<ArgumentError>()));
    });

    test('toJson returns ISO string', () {
      final dateTime = DateTime(2024, 1, 15, 10, 30);
      final result = converter.toJson(dateTime);

      expect(result, isA<String>());
      expect(result, contains('2024-01-15'));
    });
  });
}
