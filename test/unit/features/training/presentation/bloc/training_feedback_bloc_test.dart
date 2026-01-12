// Validates TrainingFeedbackBloc manages feedback submission and aggregated viewing correctly

import 'package:bloc_test/bloc_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:play_with_me/core/data/models/training_feedback_model.dart';
import 'package:play_with_me/core/domain/repositories/training_feedback_repository.dart';
import 'package:play_with_me/features/training/presentation/bloc/feedback/training_feedback_bloc.dart';
import 'package:play_with_me/features/training/presentation/bloc/feedback/training_feedback_event.dart';
import 'package:play_with_me/features/training/presentation/bloc/feedback/training_feedback_state.dart';

class MockTrainingFeedbackRepository extends Mock
    implements TrainingFeedbackRepository {}

class FakeFirebaseFunctionsException extends Fake
    implements FirebaseFunctionsException {
  @override
  final String code;
  @override
  final String? message;

  FakeFirebaseFunctionsException(this.code, [this.message]);
}

class FakeFirebaseException extends Fake implements FirebaseException {
  @override
  final String code;
  @override
  final String? message;

  FakeFirebaseException(this.code, [this.message]);
}

void main() {
  late MockTrainingFeedbackRepository mockRepository;
  late TrainingFeedbackBloc bloc;

  setUp(() {
    mockRepository = MockTrainingFeedbackRepository();
    bloc = TrainingFeedbackBloc(
      feedbackRepository: mockRepository,
    );
  });

  tearDown(() {
    bloc.close();
  });

  group('TrainingFeedbackBloc', () {
    const testSessionId = 'session123';
    const testExercisesQuality = 4;
    const testTrainingIntensity = 5;
    const testCoachingClarity = 4;
    const testComment = 'Great training session!';

    test('initial state is FeedbackInitial', () {
      expect(bloc.state, equals(const FeedbackInitial()));
    });

    group('SubmitFeedback', () {
      blocTest<TrainingFeedbackBloc, TrainingFeedbackState>(
        'emits [SubmittingFeedback, FeedbackSubmitted] when feedback is submitted successfully',
        build: () {
          when(() => mockRepository.submitFeedback(
                trainingSessionId: testSessionId,
                exercisesQuality: testExercisesQuality,
                trainingIntensity: testTrainingIntensity,
                coachingClarity: testCoachingClarity,
                comment: testComment,
              )).thenAnswer((_) async {});
          return bloc;
        },
        act: (bloc) => bloc.add(const SubmitFeedback(
          trainingSessionId: testSessionId,
          exercisesQuality: testExercisesQuality,
          trainingIntensity: testTrainingIntensity,
          coachingClarity: testCoachingClarity,
          comment: testComment,
        )),
        expect: () => [
          const SubmittingFeedback(testSessionId),
          const FeedbackSubmitted(trainingSessionId: testSessionId),
        ],
        verify: (_) {
          verify(() => mockRepository.submitFeedback(
                trainingSessionId: testSessionId,
                exercisesQuality: testExercisesQuality,
                trainingIntensity: testTrainingIntensity,
                coachingClarity: testCoachingClarity,
                comment: testComment,
              )).called(1);
        },
      );

      blocTest<TrainingFeedbackBloc, TrainingFeedbackState>(
        'emits [SubmittingFeedback, FeedbackSubmitted] when feedback is submitted without comment',
        build: () {
          when(() => mockRepository.submitFeedback(
                trainingSessionId: testSessionId,
                exercisesQuality: testExercisesQuality,
                trainingIntensity: testTrainingIntensity,
                coachingClarity: testCoachingClarity,
                comment: null,
              )).thenAnswer((_) async {});
          return bloc;
        },
        act: (bloc) => bloc.add(const SubmitFeedback(
          trainingSessionId: testSessionId,
          exercisesQuality: testExercisesQuality,
          trainingIntensity: testTrainingIntensity,
          coachingClarity: testCoachingClarity,
        )),
        expect: () => [
          const SubmittingFeedback(testSessionId),
          const FeedbackSubmitted(trainingSessionId: testSessionId),
        ],
        verify: (_) {
          verify(() => mockRepository.submitFeedback(
                trainingSessionId: testSessionId,
                exercisesQuality: testExercisesQuality,
                trainingIntensity: testTrainingIntensity,
                coachingClarity: testCoachingClarity,
                comment: null,
              )).called(1);
        },
      );

      blocTest<TrainingFeedbackBloc, TrainingFeedbackState>(
        'emits [SubmittingFeedback, FeedbackError] when submission fails with unauthenticated error',
        build: () {
          when(() => mockRepository.submitFeedback(
                trainingSessionId: testSessionId,
                exercisesQuality: testExercisesQuality,
                trainingIntensity: testTrainingIntensity,
                coachingClarity: testCoachingClarity,
                comment: testComment,
              )).thenThrow(
            FakeFirebaseFunctionsException('unauthenticated'),
          );
          return bloc;
        },
        act: (bloc) => bloc.add(const SubmitFeedback(
          trainingSessionId: testSessionId,
          exercisesQuality: testExercisesQuality,
          trainingIntensity: testTrainingIntensity,
          coachingClarity: testCoachingClarity,
          comment: testComment,
        )),
        expect: () => [
          const SubmittingFeedback(testSessionId),
          const FeedbackError(
            message: 'You must be logged in to submit feedback',
            trainingSessionId: testSessionId,
          ),
        ],
      );

      blocTest<TrainingFeedbackBloc, TrainingFeedbackState>(
        'emits [SubmittingFeedback, FeedbackError] when submission fails with failed-precondition error',
        build: () {
          when(() => mockRepository.submitFeedback(
                trainingSessionId: testSessionId,
                exercisesQuality: testExercisesQuality,
                trainingIntensity: testTrainingIntensity,
                coachingClarity: testCoachingClarity,
                comment: testComment,
              )).thenThrow(
            FakeFirebaseFunctionsException('failed-precondition'),
          );
          return bloc;
        },
        act: (bloc) => bloc.add(const SubmitFeedback(
          trainingSessionId: testSessionId,
          exercisesQuality: testExercisesQuality,
          trainingIntensity: testTrainingIntensity,
          coachingClarity: testCoachingClarity,
          comment: testComment,
        )),
        expect: () => [
          const SubmittingFeedback(testSessionId),
          const FeedbackError(
            message: 'You must be a participant to submit feedback',
            trainingSessionId: testSessionId,
          ),
        ],
      );

      blocTest<TrainingFeedbackBloc, TrainingFeedbackState>(
        'emits [SubmittingFeedback, FeedbackError] when submission fails with already-exists error',
        build: () {
          when(() => mockRepository.submitFeedback(
                trainingSessionId: testSessionId,
                exercisesQuality: testExercisesQuality,
                trainingIntensity: testTrainingIntensity,
                coachingClarity: testCoachingClarity,
                comment: testComment,
              )).thenThrow(
            FakeFirebaseFunctionsException('already-exists'),
          );
          return bloc;
        },
        act: (bloc) => bloc.add(const SubmitFeedback(
          trainingSessionId: testSessionId,
          exercisesQuality: testExercisesQuality,
          trainingIntensity: testTrainingIntensity,
          coachingClarity: testCoachingClarity,
          comment: testComment,
        )),
        expect: () => [
          const SubmittingFeedback(testSessionId),
          const FeedbackError(
            message: 'You have already submitted feedback for this session',
            trainingSessionId: testSessionId,
          ),
        ],
      );

      blocTest<TrainingFeedbackBloc, TrainingFeedbackState>(
        'emits [SubmittingFeedback, FeedbackError] when submission fails with Firestore permission-denied error',
        build: () {
          when(() => mockRepository.submitFeedback(
                trainingSessionId: testSessionId,
                exercisesQuality: testExercisesQuality,
                trainingIntensity: testTrainingIntensity,
                coachingClarity: testCoachingClarity,
                comment: testComment,
              )).thenThrow(
            FakeFirebaseException('permission-denied'),
          );
          return bloc;
        },
        act: (bloc) => bloc.add(const SubmitFeedback(
          trainingSessionId: testSessionId,
          exercisesQuality: testExercisesQuality,
          trainingIntensity: testTrainingIntensity,
          coachingClarity: testCoachingClarity,
          comment: testComment,
        )),
        expect: () => [
          const SubmittingFeedback(testSessionId),
          const FeedbackError(
            message: 'You don\'t have permission to access this data',
            trainingSessionId: testSessionId,
          ),
        ],
      );

      blocTest<TrainingFeedbackBloc, TrainingFeedbackState>(
        'emits [SubmittingFeedback, FeedbackError] when submission fails with generic error',
        build: () {
          when(() => mockRepository.submitFeedback(
                trainingSessionId: testSessionId,
                exercisesQuality: testExercisesQuality,
                trainingIntensity: testTrainingIntensity,
                coachingClarity: testCoachingClarity,
                comment: testComment,
              )).thenThrow(
            Exception('Network error'),
          );
          return bloc;
        },
        act: (bloc) => bloc.add(const SubmitFeedback(
          trainingSessionId: testSessionId,
          exercisesQuality: testExercisesQuality,
          trainingIntensity: testTrainingIntensity,
          coachingClarity: testCoachingClarity,
          comment: testComment,
        )),
        expect: () => [
          const SubmittingFeedback(testSessionId),
          const FeedbackError(
            message: 'Failed to submit feedback. Please try again.',
            trainingSessionId: testSessionId,
          ),
        ],
      );
    });

    group('LoadAggregatedFeedback', () {
      final testFeedbackList = [
        TrainingFeedbackModel(
          id: 'feedback1',
          trainingSessionId: testSessionId,
          exercisesQuality: 5,
          trainingIntensity: 5,
          coachingClarity: 4,
          comment: 'Excellent session!',
          participantHash: 'hash1',
          submittedAt: DateTime(2025, 1, 1, 12, 0),
        ),
        TrainingFeedbackModel(
          id: 'feedback2',
          trainingSessionId: testSessionId,
          exercisesQuality: 4,
          trainingIntensity: 3,
          coachingClarity: 5,
          comment: 'Good training',
          participantHash: 'hash2',
          submittedAt: DateTime(2025, 1, 1, 12, 5),
        ),
        TrainingFeedbackModel(
          id: 'feedback3',
          trainingSessionId: testSessionId,
          exercisesQuality: 5,
          trainingIntensity: 4,
          coachingClarity: 5,
          comment: null,
          participantHash: 'hash3',
          submittedAt: DateTime(2025, 1, 1, 12, 10),
        ),
      ];

      final testAggregation = FeedbackAggregation.fromFeedbackList(
        testSessionId,
        testFeedbackList,
      );

      blocTest<TrainingFeedbackBloc, TrainingFeedbackState>(
        'emits [LoadingAggregatedFeedback, AggregatedFeedbackLoaded] when feedback is loaded successfully',
        build: () {
          when(() => mockRepository.hasUserSubmittedFeedback(testSessionId))
              .thenAnswer((_) async => false);
          when(() =>
                  mockRepository.getAggregatedFeedbackStream(testSessionId))
              .thenAnswer((_) => Stream.value(testAggregation));
          return bloc;
        },
        act: (bloc) =>
            bloc.add(const LoadAggregatedFeedback(testSessionId)),
        expect: () => [
          const LoadingAggregatedFeedback(testSessionId),
          AggregatedFeedbackLoaded(
            aggregation: testAggregation,
            hasUserSubmitted: false,
          ),
        ],
        verify: (_) {
          verify(() => mockRepository.hasUserSubmittedFeedback(testSessionId))
              .called(1);
          verify(() =>
                  mockRepository.getAggregatedFeedbackStream(testSessionId))
              .called(1);
        },
      );

      blocTest<TrainingFeedbackBloc, TrainingFeedbackState>(
        'emits [LoadingAggregatedFeedback, AggregatedFeedbackLoaded] with hasUserSubmitted true',
        build: () {
          when(() => mockRepository.hasUserSubmittedFeedback(testSessionId))
              .thenAnswer((_) async => true);
          when(() =>
                  mockRepository.getAggregatedFeedbackStream(testSessionId))
              .thenAnswer((_) => Stream.value(testAggregation));
          return bloc;
        },
        act: (bloc) =>
            bloc.add(const LoadAggregatedFeedback(testSessionId)),
        expect: () => [
          const LoadingAggregatedFeedback(testSessionId),
          AggregatedFeedbackLoaded(
            aggregation: testAggregation,
            hasUserSubmitted: true,
          ),
        ],
      );

      blocTest<TrainingFeedbackBloc, TrainingFeedbackState>(
        'emits [LoadingAggregatedFeedback, AggregatedFeedbackLoaded] with empty aggregation when no feedback',
        build: () {
          when(() => mockRepository.hasUserSubmittedFeedback(testSessionId))
              .thenAnswer((_) async => false);
          when(() =>
                  mockRepository.getAggregatedFeedbackStream(testSessionId))
              .thenAnswer(
                  (_) => Stream.value(FeedbackAggregation.empty(testSessionId)));
          return bloc;
        },
        act: (bloc) =>
            bloc.add(const LoadAggregatedFeedback(testSessionId)),
        expect: () => [
          const LoadingAggregatedFeedback(testSessionId),
          AggregatedFeedbackLoaded(
            aggregation: FeedbackAggregation.empty(testSessionId),
            hasUserSubmitted: false,
          ),
        ],
      );

      blocTest<TrainingFeedbackBloc, TrainingFeedbackState>(
        'emits [LoadingAggregatedFeedback, FeedbackError] when loading fails',
        build: () {
          when(() => mockRepository.hasUserSubmittedFeedback(testSessionId))
              .thenThrow(Exception('Network error'));
          return bloc;
        },
        act: (bloc) =>
            bloc.add(const LoadAggregatedFeedback(testSessionId)),
        expect: () => [
          const LoadingAggregatedFeedback(testSessionId),
          const FeedbackError(
            message: 'Network error',
            trainingSessionId: testSessionId,
          ),
        ],
      );
    });

    group('CheckFeedbackSubmission', () {
      blocTest<TrainingFeedbackBloc, TrainingFeedbackState>(
        'emits [CheckingFeedbackSubmission, FeedbackSubmissionChecked] with hasSubmitted true',
        build: () {
          when(() => mockRepository.hasUserSubmittedFeedback(testSessionId))
              .thenAnswer((_) async => true);
          return bloc;
        },
        act: (bloc) =>
            bloc.add(const CheckFeedbackSubmission(testSessionId)),
        expect: () => [
          const CheckingFeedbackSubmission(testSessionId),
          const FeedbackSubmissionChecked(
            trainingSessionId: testSessionId,
            hasSubmitted: true,
          ),
        ],
        verify: (_) {
          verify(() => mockRepository.hasUserSubmittedFeedback(testSessionId))
              .called(1);
        },
      );

      blocTest<TrainingFeedbackBloc, TrainingFeedbackState>(
        'emits [CheckingFeedbackSubmission, FeedbackSubmissionChecked] with hasSubmitted false',
        build: () {
          when(() => mockRepository.hasUserSubmittedFeedback(testSessionId))
              .thenAnswer((_) async => false);
          return bloc;
        },
        act: (bloc) =>
            bloc.add(const CheckFeedbackSubmission(testSessionId)),
        expect: () => [
          const CheckingFeedbackSubmission(testSessionId),
          const FeedbackSubmissionChecked(
            trainingSessionId: testSessionId,
            hasSubmitted: false,
          ),
        ],
      );

      blocTest<TrainingFeedbackBloc, TrainingFeedbackState>(
        'emits [CheckingFeedbackSubmission, FeedbackError] when check fails',
        build: () {
          when(() => mockRepository.hasUserSubmittedFeedback(testSessionId))
              .thenThrow(Exception('Network error'));
          return bloc;
        },
        act: (bloc) =>
            bloc.add(const CheckFeedbackSubmission(testSessionId)),
        expect: () => [
          const CheckingFeedbackSubmission(testSessionId),
          const FeedbackError(
            message: 'Failed to check feedback status. Please try again.',
            trainingSessionId: testSessionId,
          ),
        ],
      );
    });

    group('ResetFeedbackState', () {
      blocTest<TrainingFeedbackBloc, TrainingFeedbackState>(
        'emits FeedbackInitial when reset is called',
        build: () => bloc,
        act: (bloc) => bloc.add(const ResetFeedbackState()),
        expect: () => [
          const FeedbackInitial(),
        ],
      );
    });

    group('Error handling', () {
      blocTest<TrainingFeedbackBloc, TrainingFeedbackState>(
        'provides friendly error message for unauthenticated error',
        build: () {
          when(() => mockRepository.submitFeedback(
                trainingSessionId: testSessionId,
                exercisesQuality: testExercisesQuality,
                trainingIntensity: testTrainingIntensity,
                coachingClarity: testCoachingClarity,
              )).thenThrow(
            FakeFirebaseFunctionsException('unauthenticated'),
          );
          return bloc;
        },
        act: (bloc) => bloc.add(const SubmitFeedback(
          trainingSessionId: testSessionId,
          exercisesQuality: testExercisesQuality,
          trainingIntensity: testTrainingIntensity,
          coachingClarity: testCoachingClarity,
        )),
        expect: () => [
          const SubmittingFeedback(testSessionId),
          const FeedbackError(
            message: 'You must be logged in to submit feedback',
            trainingSessionId: testSessionId,
          ),
        ],
      );

      blocTest<TrainingFeedbackBloc, TrainingFeedbackState>(
        'provides friendly error message for not-found error',
        build: () {
          when(() => mockRepository.submitFeedback(
                trainingSessionId: testSessionId,
                exercisesQuality: testExercisesQuality,
                trainingIntensity: testTrainingIntensity,
                coachingClarity: testCoachingClarity,
              )).thenThrow(
            FakeFirebaseFunctionsException('not-found'),
          );
          return bloc;
        },
        act: (bloc) => bloc.add(const SubmitFeedback(
          trainingSessionId: testSessionId,
          exercisesQuality: testExercisesQuality,
          trainingIntensity: testTrainingIntensity,
          coachingClarity: testCoachingClarity,
        )),
        expect: () => [
          const SubmittingFeedback(testSessionId),
          const FeedbackError(
            message: 'Training session not found',
            trainingSessionId: testSessionId,
          ),
        ],
      );
    });

    group('Stream subscription cleanup', () {
      blocTest<TrainingFeedbackBloc, TrainingFeedbackState>(
        'cancels aggregated feedback subscription on close',
        build: () {
          when(() => mockRepository.hasUserSubmittedFeedback(testSessionId))
              .thenAnswer((_) async => false);
          when(() => mockRepository.getAggregatedFeedbackStream(testSessionId))
              .thenAnswer((_) => Stream.value(FeedbackAggregation.empty(testSessionId)));
          return bloc;
        },
        act: (bloc) => bloc.add(const LoadAggregatedFeedback(testSessionId)),
        expect: () => [
          const LoadingAggregatedFeedback(testSessionId),
          AggregatedFeedbackLoaded(
            aggregation: FeedbackAggregation.empty(testSessionId),
            hasUserSubmitted: false,
          ),
        ],
        // blocTest automatically handles cleanup and closing
      );
    });
  });
}
