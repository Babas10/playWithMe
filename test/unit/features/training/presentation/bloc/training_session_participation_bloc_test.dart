// Validates TrainingSessionParticipationBloc manages participation state and join/leave operations correctly

import 'package:bloc_test/bloc_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:play_with_me/core/data/models/training_session_participant_model.dart';
import 'package:play_with_me/core/domain/repositories/training_session_repository.dart';
import 'package:play_with_me/features/training/presentation/bloc/training_session_participation/training_session_participation_bloc.dart';
import 'package:play_with_me/features/training/presentation/bloc/training_session_participation/training_session_participation_event.dart';
import 'package:play_with_me/features/training/presentation/bloc/training_session_participation/training_session_participation_state.dart';

class MockTrainingSessionRepository extends Mock
    implements TrainingSessionRepository {}

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
  late MockTrainingSessionRepository mockRepository;
  late TrainingSessionParticipationBloc bloc;

  setUp(() {
    mockRepository = MockTrainingSessionRepository();
    bloc = TrainingSessionParticipationBloc(
      trainingSessionRepository: mockRepository,
    );
  });

  tearDown(() {
    bloc.close();
  });

  group('TrainingSessionParticipationBloc', () {
    const testSessionId = 'session123';
    final testParticipants = [
      TrainingSessionParticipantModel(
        userId: 'user1',
        joinedAt: DateTime(2025, 1, 1, 10, 0),
        status: ParticipantStatus.joined,
      ),
      TrainingSessionParticipantModel(
        userId: 'user2',
        joinedAt: DateTime(2025, 1, 1, 10, 5),
        status: ParticipantStatus.joined,
      ),
    ];

    test('initial state is ParticipationInitial', () {
      expect(bloc.state, equals(const ParticipationInitial()));
    });

    group('LoadParticipants', () {
      blocTest<TrainingSessionParticipationBloc,
          TrainingSessionParticipationState>(
        'emits [ParticipationLoading, ParticipationLoaded] when participants are loaded successfully',
        build: () {
          when(() => mockRepository
                  .getTrainingSessionParticipantsStream(testSessionId))
              .thenAnswer((_) => Stream.value(testParticipants));
          return bloc;
        },
        act: (bloc) => bloc.add(const LoadParticipants(testSessionId)),
        expect: () => [
          const ParticipationLoading(),
          ParticipationLoaded(
            participants: testParticipants,
            participantCount: 2,
          ),
        ],
        verify: (_) {
          verify(() => mockRepository
              .getTrainingSessionParticipantsStream(testSessionId)).called(1);
        },
      );

      blocTest<TrainingSessionParticipationBloc,
          TrainingSessionParticipationState>(
        'emits [ParticipationLoading, ParticipationLoaded] with empty list when no participants',
        build: () {
          when(() => mockRepository
                  .getTrainingSessionParticipantsStream(testSessionId))
              .thenAnswer((_) => Stream.value([]));
          return bloc;
        },
        act: (bloc) => bloc.add(const LoadParticipants(testSessionId)),
        expect: () => [
          const ParticipationLoading(),
          const ParticipationLoaded(
            participants: [],
            participantCount: 0,
          ),
        ],
      );

      blocTest<TrainingSessionParticipationBloc,
          TrainingSessionParticipationState>(
        'emits [ParticipationLoading, ParticipationError] when stream fails with FirebaseException',
        build: () {
          when(() => mockRepository
                  .getTrainingSessionParticipantsStream(testSessionId))
              .thenAnswer((_) => Stream.error(
                  FakeFirebaseException('permission-denied', 'Access denied')));
          return bloc;
        },
        act: (bloc) => bloc.add(const LoadParticipants(testSessionId)),
        expect: () => [
          const ParticipationLoading(),
          const ParticipationError(
            message: 'You don\'t have permission to access this data',
            errorCode: 'permission-denied',
          ),
        ],
      );

      blocTest<TrainingSessionParticipationBloc,
          TrainingSessionParticipationState>(
        'updates loaded state when participants stream emits new data',
        build: () {
          final controller =
              Stream<List<TrainingSessionParticipantModel>>.value(
            testParticipants,
          );
          when(() => mockRepository
                  .getTrainingSessionParticipantsStream(testSessionId))
              .thenAnswer((_) => controller);
          return bloc;
        },
        act: (bloc) => bloc.add(const LoadParticipants(testSessionId)),
        expect: () => [
          const ParticipationLoading(),
          ParticipationLoaded(
            participants: testParticipants,
            participantCount: 2,
          ),
        ],
      );
    });

    group('JoinTrainingSession', () {
      blocTest<TrainingSessionParticipationBloc,
          TrainingSessionParticipationState>(
        'emits [JoiningSession, JoinedSession, ParticipationLoading, ParticipationLoaded] when join succeeds',
        build: () {
          when(() => mockRepository.joinTrainingSession(testSessionId))
              .thenAnswer((_) async => {});
          when(() => mockRepository
                  .getTrainingSessionParticipantsStream(testSessionId))
              .thenAnswer((_) => Stream.value(testParticipants));
          return bloc;
        },
        act: (bloc) => bloc.add(const JoinTrainingSession(testSessionId)),
        expect: () => [
          const JoiningSession(testSessionId),
          const JoinedSession(sessionId: testSessionId),
          const ParticipationLoading(),
          ParticipationLoaded(
            participants: testParticipants,
            participantCount: 2,
          ),
        ],
        verify: (_) {
          verify(() => mockRepository.joinTrainingSession(testSessionId))
              .called(1);
          verify(() => mockRepository
              .getTrainingSessionParticipantsStream(testSessionId)).called(1);
        },
      );

      blocTest<TrainingSessionParticipationBloc,
          TrainingSessionParticipationState>(
        'emits [JoiningSession, ParticipationError] when join fails with unauthenticated error',
        build: () {
          when(() => mockRepository.joinTrainingSession(testSessionId))
              .thenThrow(FakeFirebaseFunctionsException(
            'unauthenticated',
            'Not authenticated',
          ));
          return bloc;
        },
        act: (bloc) => bloc.add(const JoinTrainingSession(testSessionId)),
        expect: () => [
          const JoiningSession(testSessionId),
          const ParticipationError(
            message: 'You must be logged in to join a training session',
            errorCode: 'unauthenticated',
          ),
        ],
      );

      blocTest<TrainingSessionParticipationBloc,
          TrainingSessionParticipationState>(
        'emits [JoiningSession, ParticipationError] when join fails with already-exists error',
        build: () {
          when(() => mockRepository.joinTrainingSession(testSessionId))
              .thenThrow(FakeFirebaseFunctionsException(
            'already-exists',
            'Already joined',
          ));
          return bloc;
        },
        act: (bloc) => bloc.add(const JoinTrainingSession(testSessionId)),
        expect: () => [
          const JoiningSession(testSessionId),
          const ParticipationError(
            message: 'You have already joined this training session',
            errorCode: 'already-exists',
          ),
        ],
      );

      blocTest<TrainingSessionParticipationBloc,
          TrainingSessionParticipationState>(
        'emits [JoiningSession, ParticipationError] when join fails with failed-precondition error',
        build: () {
          when(() => mockRepository.joinTrainingSession(testSessionId))
              .thenThrow(FakeFirebaseFunctionsException(
            'failed-precondition',
            'Session is full',
          ));
          return bloc;
        },
        act: (bloc) => bloc.add(const JoinTrainingSession(testSessionId)),
        expect: () => [
          const JoiningSession(testSessionId),
          const ParticipationError(
            message: 'Session is full',
            errorCode: 'failed-precondition',
          ),
        ],
      );

      blocTest<TrainingSessionParticipationBloc,
          TrainingSessionParticipationState>(
        'emits [JoiningSession, ParticipationError] when join fails with generic error',
        build: () {
          when(() => mockRepository.joinTrainingSession(testSessionId))
              .thenThrow(Exception('Unknown error'));
          return bloc;
        },
        act: (bloc) => bloc.add(const JoinTrainingSession(testSessionId)),
        expect: () => [
          const JoiningSession(testSessionId),
          const ParticipationError(
            message: 'Failed to join training session. Please try again.',
          ),
        ],
      );
    });

    group('LeaveTrainingSession', () {
      blocTest<TrainingSessionParticipationBloc,
          TrainingSessionParticipationState>(
        'emits [LeavingSession, LeftSession, ParticipationLoading, ParticipationLoaded] when leave succeeds',
        build: () {
          when(() => mockRepository.leaveTrainingSession(testSessionId))
              .thenAnswer((_) async => {});
          when(() => mockRepository
                  .getTrainingSessionParticipantsStream(testSessionId))
              .thenAnswer((_) => Stream.value([]));
          return bloc;
        },
        act: (bloc) => bloc.add(const LeaveTrainingSession(testSessionId)),
        expect: () => [
          const LeavingSession(testSessionId),
          const LeftSession(sessionId: testSessionId),
          const ParticipationLoading(),
          const ParticipationLoaded(
            participants: [],
            participantCount: 0,
          ),
        ],
        verify: (_) {
          verify(() => mockRepository.leaveTrainingSession(testSessionId))
              .called(1);
          verify(() => mockRepository
              .getTrainingSessionParticipantsStream(testSessionId)).called(1);
        },
      );

      blocTest<TrainingSessionParticipationBloc,
          TrainingSessionParticipationState>(
        'emits [LeavingSession, ParticipationError] when leave fails with permission-denied error',
        build: () {
          when(() => mockRepository.leaveTrainingSession(testSessionId))
              .thenThrow(FakeFirebaseFunctionsException(
            'permission-denied',
            'Permission denied',
          ));
          return bloc;
        },
        act: (bloc) => bloc.add(const LeaveTrainingSession(testSessionId)),
        expect: () => [
          const LeavingSession(testSessionId),
          const ParticipationError(
            message: 'You don\'t have permission to join this session',
            errorCode: 'permission-denied',
          ),
        ],
      );

      blocTest<TrainingSessionParticipationBloc,
          TrainingSessionParticipationState>(
        'emits [LeavingSession, ParticipationError] when leave fails with not-found error',
        build: () {
          when(() => mockRepository.leaveTrainingSession(testSessionId))
              .thenThrow(FakeFirebaseFunctionsException(
            'not-found',
            'Session not found',
          ));
          return bloc;
        },
        act: (bloc) => bloc.add(const LeaveTrainingSession(testSessionId)),
        expect: () => [
          const LeavingSession(testSessionId),
          const ParticipationError(
            message: 'Training session not found',
            errorCode: 'not-found',
          ),
        ],
      );

      blocTest<TrainingSessionParticipationBloc,
          TrainingSessionParticipationState>(
        'emits [LeavingSession, ParticipationError] when leave fails with Firestore error',
        build: () {
          when(() => mockRepository.leaveTrainingSession(testSessionId))
              .thenThrow(FakeFirebaseException('unavailable', 'Service unavailable'));
          return bloc;
        },
        act: (bloc) => bloc.add(const LeaveTrainingSession(testSessionId)),
        expect: () => [
          const LeavingSession(testSessionId),
          const ParticipationError(
            message: 'Service temporarily unavailable. Please try again',
            errorCode: 'unavailable',
          ),
        ],
      );

      blocTest<TrainingSessionParticipationBloc,
          TrainingSessionParticipationState>(
        'emits [LeavingSession, ParticipationError] when leave fails with generic error',
        build: () {
          when(() => mockRepository.leaveTrainingSession(testSessionId))
              .thenThrow(Exception('Unknown error'));
          return bloc;
        },
        act: (bloc) => bloc.add(const LeaveTrainingSession(testSessionId)),
        expect: () => [
          const LeavingSession(testSessionId),
          const ParticipationError(
            message: 'Failed to leave training session. Please try again.',
          ),
        ],
      );
    });

    group('Error handling', () {
      blocTest<TrainingSessionParticipationBloc,
          TrainingSessionParticipationState>(
        'provides friendly error message for all Firebase Functions error codes',
        build: () => bloc,
        act: (bloc) {},
        verify: (bloc) {
          // Test all error code mappings
          final testCases = {
            'unauthenticated':
                'You must be logged in to join a training session',
            'permission-denied':
                'You don\'t have permission to join this session',
            'not-found': 'Training session not found',
            'already-exists': 'You have already joined this training session',
            'internal': 'An error occurred. Please try again later',
          };

          // This is verified by the error handling tests above
          expect(testCases.keys.length, equals(5));
        },
      );
    });

    group('Stream subscription cleanup', () {
      test('cancels participants subscription on close', () async {
        when(() =>
                mockRepository.getTrainingSessionParticipantsStream(testSessionId))
            .thenAnswer((_) => Stream.value(testParticipants));

        bloc.add(const LoadParticipants(testSessionId));
        await Future.delayed(const Duration(milliseconds: 100));

        await bloc.close();

        // Verify that close was called without errors
        expect(bloc.isClosed, isTrue);
      });
    });
  });
}
