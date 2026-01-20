// Tests FirestoreTrainingFeedbackRepository methods with mocked dependencies.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:play_with_me/core/data/models/training_feedback_model.dart';
import 'package:play_with_me/core/data/repositories/firestore_training_feedback_repository.dart';
import 'package:play_with_me/core/domain/repositories/training_feedback_repository.dart';

class MockFirebaseFunctions extends Mock implements FirebaseFunctions {}

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUser extends Mock implements User {}

class MockHttpsCallable extends Mock implements HttpsCallable {}

class MockHttpsCallableResult<T> extends Mock implements HttpsCallableResult<T> {}

void main() {
  group('FirestoreTrainingFeedbackRepository', () {
    late FakeFirebaseFirestore fakeFirestore;
    late MockFirebaseFunctions mockFunctions;
    late MockFirebaseAuth mockAuth;
    late MockUser mockUser;
    late FirestoreTrainingFeedbackRepository repository;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      mockFunctions = MockFirebaseFunctions();
      mockAuth = MockFirebaseAuth();
      mockUser = MockUser();

      when(() => mockUser.uid).thenReturn('user-123');
      when(() => mockAuth.currentUser).thenReturn(mockUser);

      repository = FirestoreTrainingFeedbackRepository(
        firestore: fakeFirestore,
        functions: mockFunctions,
        auth: mockAuth,
      );
    });

    group('constructor', () {
      test('creates repository with custom dependencies', () {
        final repo = FirestoreTrainingFeedbackRepository(
          firestore: fakeFirestore,
          functions: mockFunctions,
          auth: mockAuth,
        );
        expect(repo, isNotNull);
      });
    });

    group('submitFeedback', () {
      test('calls Cloud Function with valid feedback', () async {
        final mockCallable = MockHttpsCallable();
        final mockResult = MockHttpsCallableResult<Map<String, dynamic>>();

        when(() => mockFunctions.httpsCallable('submitTrainingFeedback'))
            .thenReturn(mockCallable);
        when(() => mockCallable.call(any()))
            .thenAnswer((_) async => mockResult);
        when(() => mockResult.data).thenReturn({});

        await repository.submitFeedback(
          trainingSessionId: 'session-123',
          exercisesQuality: 4,
          trainingIntensity: 5,
          coachingClarity: 3,
          comment: 'Great session!',
        );

        verify(() => mockFunctions.httpsCallable('submitTrainingFeedback'))
            .called(1);
      });

      test('throws exception for unauthenticated user', () async {
        when(() => mockAuth.currentUser).thenReturn(null);

        expect(
          () => repository.submitFeedback(
            trainingSessionId: 'session-123',
            exercisesQuality: 4,
            trainingIntensity: 5,
            coachingClarity: 3,
          ),
          throwsA(isA<Exception>()),
        );
      });

      test('throws exception for invalid exercises quality', () async {
        expect(
          () => repository.submitFeedback(
            trainingSessionId: 'session-123',
            exercisesQuality: 0,
            trainingIntensity: 5,
            coachingClarity: 3,
          ),
          throwsA(isA<Exception>()),
        );
      });

      test('throws exception for invalid training intensity', () async {
        expect(
          () => repository.submitFeedback(
            trainingSessionId: 'session-123',
            exercisesQuality: 4,
            trainingIntensity: 6,
            coachingClarity: 3,
          ),
          throwsA(isA<Exception>()),
        );
      });

      test('throws exception for invalid coaching clarity', () async {
        expect(
          () => repository.submitFeedback(
            trainingSessionId: 'session-123',
            exercisesQuality: 4,
            trainingIntensity: 5,
            coachingClarity: -1,
          ),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('hasUserSubmittedFeedback', () {
      test('calls Cloud Function and returns true', () async {
        final mockCallable = MockHttpsCallable();
        final mockResult = MockHttpsCallableResult<Map<String, dynamic>>();

        when(() => mockFunctions.httpsCallable('hasSubmittedTrainingFeedback'))
            .thenReturn(mockCallable);
        when(() => mockCallable.call(any()))
            .thenAnswer((_) async => mockResult);
        when(() => mockResult.data).thenReturn({'hasSubmitted': true});

        final result =
            await repository.hasUserSubmittedFeedback('session-123');

        expect(result, isTrue);
      });

      test('calls Cloud Function and returns false', () async {
        final mockCallable = MockHttpsCallable();
        final mockResult = MockHttpsCallableResult<Map<String, dynamic>>();

        when(() => mockFunctions.httpsCallable('hasSubmittedTrainingFeedback'))
            .thenReturn(mockCallable);
        when(() => mockCallable.call(any()))
            .thenAnswer((_) async => mockResult);
        when(() => mockResult.data).thenReturn({'hasSubmitted': false});

        final result =
            await repository.hasUserSubmittedFeedback('session-123');

        expect(result, isFalse);
      });

      test('returns false for unauthenticated user', () async {
        when(() => mockAuth.currentUser).thenReturn(null);

        final result =
            await repository.hasUserSubmittedFeedback('session-123');

        expect(result, isFalse);
      });

      test('returns false on error', () async {
        final mockCallable = MockHttpsCallable();

        when(() => mockFunctions.httpsCallable('hasSubmittedTrainingFeedback'))
            .thenReturn(mockCallable);
        when(() => mockCallable.call(any()))
            .thenThrow(Exception('Network error'));

        final result =
            await repository.hasUserSubmittedFeedback('session-123');

        expect(result, isFalse);
      });
    });

    group('getAggregatedFeedback', () {
      test('returns empty aggregation when no feedback exists', () async {
        final result =
            await repository.getAggregatedFeedback('session-123');

        expect(result, isNotNull);
        expect(result!.trainingSessionId, equals('session-123'));
        expect(result.totalCount, equals(0));
      });

      test('aggregates feedback from Firestore', () async {
        // Add test feedback to Firestore
        await fakeFirestore
            .collection('trainingSessions')
            .doc('session-123')
            .collection('feedback')
            .add({
          'exercisesQuality': 4,
          'trainingIntensity': 5,
          'coachingClarity': 3,
          'participantHash': 'hash-1',
          'submittedAt': Timestamp.now(),
        });

        await fakeFirestore
            .collection('trainingSessions')
            .doc('session-123')
            .collection('feedback')
            .add({
          'exercisesQuality': 5,
          'trainingIntensity': 4,
          'coachingClarity': 5,
          'participantHash': 'hash-2',
          'submittedAt': Timestamp.now(),
        });

        final result =
            await repository.getAggregatedFeedback('session-123');

        expect(result, isNotNull);
        expect(result!.totalCount, equals(2));
      });
    });

    group('deleteFeedbackForSession', () {
      test('deletes all feedback for a session', () async {
        // Add test feedback
        await fakeFirestore
            .collection('trainingSessions')
            .doc('session-123')
            .collection('feedback')
            .add({
          'exercisesQuality': 4,
          'trainingIntensity': 5,
          'coachingClarity': 3,
          'participantHash': 'hash-1',
          'submittedAt': Timestamp.now(),
        });

        await fakeFirestore
            .collection('trainingSessions')
            .doc('session-123')
            .collection('feedback')
            .add({
          'exercisesQuality': 5,
          'trainingIntensity': 4,
          'coachingClarity': 5,
          'participantHash': 'hash-2',
          'submittedAt': Timestamp.now(),
        });

        // Verify feedback exists
        var feedbackSnapshot = await fakeFirestore
            .collection('trainingSessions')
            .doc('session-123')
            .collection('feedback')
            .get();
        expect(feedbackSnapshot.docs.length, equals(2));

        // Delete feedback
        await repository.deleteFeedbackForSession('session-123');

        // Verify feedback is deleted
        feedbackSnapshot = await fakeFirestore
            .collection('trainingSessions')
            .doc('session-123')
            .collection('feedback')
            .get();
        expect(feedbackSnapshot.docs.length, equals(0));
      });

      test('handles empty feedback collection', () async {
        // Should not throw when no feedback exists
        await repository.deleteFeedbackForSession('session-123');

        final feedbackSnapshot = await fakeFirestore
            .collection('trainingSessions')
            .doc('session-123')
            .collection('feedback')
            .get();
        expect(feedbackSnapshot.docs.length, equals(0));
      });
    });
  });

  group('FeedbackAggregation', () {
    group('empty', () {
      test('creates empty aggregation', () {
        final aggregation = FeedbackAggregation.empty('session-123');

        expect(aggregation.trainingSessionId, equals('session-123'));
        expect(aggregation.totalCount, equals(0));
        expect(aggregation.averageExercisesQuality, equals(0.0));
        expect(aggregation.averageTrainingIntensity, equals(0.0));
        expect(aggregation.averageCoachingClarity, equals(0.0));
      });
    });

    group('fromFeedbackList', () {
      test('calculates averages from feedback list', () {
        final now = DateTime.now();
        final feedbackList = [
          TrainingFeedbackModel(
            id: 'feedback-1',
            trainingSessionId: 'session-123',
            exercisesQuality: 4,
            trainingIntensity: 5,
            coachingClarity: 3,
            participantHash: 'hash-1',
            submittedAt: now,
          ),
          TrainingFeedbackModel(
            id: 'feedback-2',
            trainingSessionId: 'session-123',
            exercisesQuality: 5,
            trainingIntensity: 4,
            coachingClarity: 5,
            participantHash: 'hash-2',
            submittedAt: now,
          ),
        ];

        final aggregation =
            FeedbackAggregation.fromFeedbackList('session-123', feedbackList);

        expect(aggregation.totalCount, equals(2));
        expect(aggregation.averageExercisesQuality, equals(4.5));
        expect(aggregation.averageTrainingIntensity, equals(4.5));
        expect(aggregation.averageCoachingClarity, equals(4.0));
      });

      test('returns empty aggregation for empty list', () {
        final aggregation =
            FeedbackAggregation.fromFeedbackList('session-123', []);

        expect(aggregation.totalCount, equals(0));
        expect(aggregation.averageExercisesQuality, equals(0.0));
      });

      test('counts comments correctly', () {
        final now = DateTime.now();
        final feedbackList = [
          TrainingFeedbackModel(
            id: 'feedback-1',
            trainingSessionId: 'session-123',
            exercisesQuality: 4,
            trainingIntensity: 5,
            coachingClarity: 3,
            comment: 'Great!',
            participantHash: 'hash-1',
            submittedAt: now,
          ),
          TrainingFeedbackModel(
            id: 'feedback-2',
            trainingSessionId: 'session-123',
            exercisesQuality: 5,
            trainingIntensity: 4,
            coachingClarity: 5,
            participantHash: 'hash-2',
            submittedAt: now,
          ),
        ];

        final aggregation =
            FeedbackAggregation.fromFeedbackList('session-123', feedbackList);

        expect(aggregation.comments.length, equals(1));
        expect(aggregation.comments.first, equals('Great!'));
      });

      test('filters empty comments', () {
        final now = DateTime.now();
        final feedbackList = [
          TrainingFeedbackModel(
            id: 'feedback-1',
            trainingSessionId: 'session-123',
            exercisesQuality: 4,
            trainingIntensity: 5,
            coachingClarity: 3,
            comment: '',
            participantHash: 'hash-1',
            submittedAt: now,
          ),
          TrainingFeedbackModel(
            id: 'feedback-2',
            trainingSessionId: 'session-123',
            exercisesQuality: 5,
            trainingIntensity: 4,
            coachingClarity: 5,
            comment: '   ',
            participantHash: 'hash-2',
            submittedAt: now,
          ),
        ];

        final aggregation =
            FeedbackAggregation.fromFeedbackList('session-123', feedbackList);

        expect(aggregation.comments.isEmpty, isTrue);
      });
    });

    group('overallAverage', () {
      test('calculates overall average', () {
        final now = DateTime.now();
        final feedbackList = [
          TrainingFeedbackModel(
            id: 'feedback-1',
            trainingSessionId: 'session-123',
            exercisesQuality: 3,
            trainingIntensity: 3,
            coachingClarity: 3,
            participantHash: 'hash-1',
            submittedAt: now,
          ),
        ];

        final aggregation =
            FeedbackAggregation.fromFeedbackList('session-123', feedbackList);

        expect(aggregation.overallAverage, equals(3.0));
      });

      test('returns 0 for empty aggregation', () {
        final aggregation = FeedbackAggregation.empty('session-123');

        expect(aggregation.overallAverage, equals(0.0));
      });
    });
  });
}
