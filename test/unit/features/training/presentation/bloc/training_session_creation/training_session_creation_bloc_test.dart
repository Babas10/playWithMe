// Validates CreateTrainingSessionBloc correctly manages form state and creates training sessions

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:play_with_me/core/data/models/game_model.dart';
import 'package:play_with_me/core/data/models/training_session_model.dart';
import 'package:play_with_me/core/domain/repositories/training_session_repository.dart';
import 'package:play_with_me/features/training/presentation/bloc/training_session_creation/training_session_creation_bloc.dart';
import 'package:play_with_me/features/training/presentation/bloc/training_session_creation/training_session_creation_event.dart';
import 'package:play_with_me/features/training/presentation/bloc/training_session_creation/training_session_creation_state.dart';

class MockTrainingSessionRepository extends Mock
    implements TrainingSessionRepository {}

class FakeTrainingSessionModel extends Fake implements TrainingSessionModel {}

void main() {
  late TrainingSessionCreationBloc bloc;
  late MockTrainingSessionRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(FakeTrainingSessionModel());
  });

  setUp(() {
    mockRepository = MockTrainingSessionRepository();
    bloc = TrainingSessionCreationBloc(
      trainingSessionRepository: mockRepository,
    );
  });

  tearDown(() {
    bloc.close();
  });

  group('TrainingSessionCreationBloc', () {
    group('Initial State', () {
      test('initial state is TrainingSessionCreationInitial', () {
        expect(bloc.state, equals(const TrainingSessionCreationInitial()));
      });
    });

    group('SelectTrainingGroup', () {
      blocTest<TrainingSessionCreationBloc, TrainingSessionCreationState>(
        'emits form state with group selected and no error',
        build: () => bloc,
        act: (bloc) => bloc.add(const SelectTrainingGroup(
          groupId: 'group-1',
          groupName: 'Test Group',
        )),
        expect: () => [
          isA<TrainingSessionCreationFormState>()
              .having((s) => s.groupId, 'groupId', 'group-1')
              .having((s) => s.groupName, 'groupName', 'Test Group')
              .having((s) => s.groupError, 'groupError', null)
              .having((s) => s.isValid, 'isValid', false),
        ],
      );
    });

    group('SetStartTime', () {
      final futureTime = DateTime.now().add(const Duration(days: 1));

      blocTest<TrainingSessionCreationBloc, TrainingSessionCreationState>(
        'emits form state with start time set and no error',
        build: () => bloc,
        act: (bloc) => bloc.add(SetStartTime(startTime: futureTime)),
        expect: () => [
          isA<TrainingSessionCreationFormState>()
              .having((s) => s.startTime, 'startTime', futureTime)
              .having((s) => s.startTimeError, 'startTimeError', null)
              .having((s) => s.isValid, 'isValid', false),
        ],
      );

      blocTest<TrainingSessionCreationBloc, TrainingSessionCreationState>(
        'validates that start time is in the future',
        build: () => bloc,
        seed: () => TrainingSessionCreationFormState(
          startTime: DateTime.now().subtract(const Duration(hours: 1)),
        ),
        act: (bloc) => bloc.add(const ValidateTrainingForm()),
        expect: () => [
          isA<TrainingSessionCreationFormState>()
              .having((s) => s.startTimeError, 'startTimeError',
                  'Start time must be in the future')
              .having((s) => s.isValid, 'isValid', false),
        ],
      );
    });

    group('SetEndTime', () {
      final startTime = DateTime.now().add(const Duration(days: 1));
      final endTime = startTime.add(const Duration(hours: 2));

      blocTest<TrainingSessionCreationBloc, TrainingSessionCreationState>(
        'emits form state with end time set and no error',
        build: () => bloc,
        act: (bloc) => bloc.add(SetEndTime(endTime: endTime)),
        expect: () => [
          isA<TrainingSessionCreationFormState>()
              .having((s) => s.endTime, 'endTime', endTime)
              .having((s) => s.endTimeError, 'endTimeError', null)
              .having((s) => s.isValid, 'isValid', false),
        ],
      );

      blocTest<TrainingSessionCreationBloc, TrainingSessionCreationState>(
        'validates that end time is after start time',
        build: () => bloc,
        seed: () => TrainingSessionCreationFormState(
          startTime: DateTime.now().add(const Duration(days: 1)),
          endTime: DateTime.now(),
        ),
        act: (bloc) => bloc.add(const ValidateTrainingForm()),
        expect: () => [
          isA<TrainingSessionCreationFormState>()
              .having((s) => s.endTimeError, 'endTimeError',
                  'End time must be after start time')
              .having((s) => s.isValid, 'isValid', false),
        ],
      );

      blocTest<TrainingSessionCreationBloc, TrainingSessionCreationState>(
        'validates minimum session duration of 30 minutes',
        build: () => bloc,
        seed: () => TrainingSessionCreationFormState(
          startTime: DateTime.now().add(const Duration(days: 1)),
          endTime: DateTime.now().add(const Duration(days: 1, minutes: 15)),
        ),
        act: (bloc) => bloc.add(const ValidateTrainingForm()),
        expect: () => [
          isA<TrainingSessionCreationFormState>()
              .having((s) => s.endTimeError, 'endTimeError',
                  'Training session must be at least 30 minutes long')
              .having((s) => s.isValid, 'isValid', false),
        ],
      );
    });

    group('SetTrainingLocation', () {
      blocTest<TrainingSessionCreationBloc, TrainingSessionCreationState>(
        'emits form state with location set',
        build: () => bloc,
        act: (bloc) => bloc.add(const SetTrainingLocation(
          locationName: 'Beach Court 1',
          address: '123 Beach St',
        )),
        expect: () => [
          isA<TrainingSessionCreationFormState>()
              .having((s) => s.locationName, 'locationName', 'Beach Court 1')
              .having((s) => s.address, 'address', '123 Beach St')
              .having((s) => s.locationError, 'locationError', null)
              .having((s) => s.isValid, 'isValid', false),
        ],
      );

      blocTest<TrainingSessionCreationBloc, TrainingSessionCreationState>(
        'validates location is not empty',
        build: () => bloc,
        seed: () => const TrainingSessionCreationFormState(
          locationName: '',
        ),
        act: (bloc) => bloc.add(const ValidateTrainingForm()),
        expect: () => [
          isA<TrainingSessionCreationFormState>()
              .having((s) => s.locationError, 'locationError',
                  'Please enter a location')
              .having((s) => s.isValid, 'isValid', false),
        ],
      );
    });

    group('SetTrainingTitle', () {
      blocTest<TrainingSessionCreationBloc, TrainingSessionCreationState>(
        'emits form state with title set',
        build: () => bloc,
        act: (bloc) => bloc.add(const SetTrainingTitle(
            title: 'Advanced Serving Practice')),
        expect: () => [
          isA<TrainingSessionCreationFormState>()
              .having(
                  (s) => s.title, 'title', 'Advanced Serving Practice')
              .having((s) => s.titleError, 'titleError', null)
              .having((s) => s.isValid, 'isValid', false),
        ],
      );

      blocTest<TrainingSessionCreationBloc, TrainingSessionCreationState>(
        'validates title is not empty',
        build: () => bloc,
        seed: () => const TrainingSessionCreationFormState(title: ''),
        act: (bloc) => bloc.add(const ValidateTrainingForm()),
        expect: () => [
          isA<TrainingSessionCreationFormState>()
              .having((s) => s.titleError, 'titleError',
                  'Please enter a session title')
              .having((s) => s.isValid, 'isValid', false),
        ],
      );

      blocTest<TrainingSessionCreationBloc, TrainingSessionCreationState>(
        'validates title minimum length (3 characters)',
        build: () => bloc,
        seed: () => const TrainingSessionCreationFormState(title: 'AB'),
        act: (bloc) => bloc.add(const ValidateTrainingForm()),
        expect: () => [
          isA<TrainingSessionCreationFormState>()
              .having((s) => s.titleError, 'titleError',
                  'Title must be at least 3 characters')
              .having((s) => s.isValid, 'isValid', false),
        ],
      );

      blocTest<TrainingSessionCreationBloc, TrainingSessionCreationState>(
        'validates title maximum length (100 characters)',
        build: () => bloc,
        seed: () => TrainingSessionCreationFormState(
            title: 'A' * 101),
        act: (bloc) => bloc.add(const ValidateTrainingForm()),
        expect: () => [
          isA<TrainingSessionCreationFormState>()
              .having((s) => s.titleError, 'titleError',
                  'Title must be less than 100 characters')
              .having((s) => s.isValid, 'isValid', false),
        ],
      );
    });

    group('SetTrainingDescription', () {
      blocTest<TrainingSessionCreationBloc, TrainingSessionCreationState>(
        'emits form state with description set (no validation)',
        build: () => bloc,
        act: (bloc) => bloc.add(const SetTrainingDescription(
            description: 'Focus on serves and blocks')),
        expect: () => [
          isA<TrainingSessionCreationFormState>()
              .having((s) => s.description, 'description',
                  'Focus on serves and blocks')
              .having((s) => s.isValid, 'isValid', false),
        ],
      );
    });

    group('SetMaxParticipants', () {
      blocTest<TrainingSessionCreationBloc, TrainingSessionCreationState>(
        'emits form state with maxParticipants set',
        build: () => bloc,
        act: (bloc) => bloc.add(const SetMaxParticipants(maxParticipants: 10)),
        expect: () => [
          isA<TrainingSessionCreationFormState>()
              .having((s) => s.maxParticipants, 'maxParticipants', 10)
              .having((s) => s.participantsError, 'participantsError', null)
              .having((s) => s.isValid, 'isValid', false),
        ],
      );

      blocTest<TrainingSessionCreationBloc, TrainingSessionCreationState>(
        'validates maxParticipants cannot exceed 30',
        build: () => bloc,
        seed: () => const TrainingSessionCreationFormState(
          maxParticipants: 35,
        ),
        act: (bloc) => bloc.add(const ValidateTrainingForm()),
        expect: () => [
          isA<TrainingSessionCreationFormState>()
              .having((s) => s.participantsError, 'participantsError',
                  'Maximum participants cannot exceed 30')
              .having((s) => s.isValid, 'isValid', false),
        ],
      );
    });

    group('SetMinParticipants', () {
      blocTest<TrainingSessionCreationBloc, TrainingSessionCreationState>(
        'emits form state with minParticipants set',
        build: () => bloc,
        act: (bloc) => bloc.add(const SetMinParticipants(minParticipants: 6)),
        expect: () => [
          isA<TrainingSessionCreationFormState>()
              .having((s) => s.minParticipants, 'minParticipants', 6)
              .having((s) => s.participantsError, 'participantsError', null)
              .having((s) => s.isValid, 'isValid', false),
        ],
      );

      blocTest<TrainingSessionCreationBloc, TrainingSessionCreationState>(
        'validates minParticipants is at least 2',
        build: () => bloc,
        seed: () => const TrainingSessionCreationFormState(
          minParticipants: 1,
        ),
        act: (bloc) => bloc.add(const ValidateTrainingForm()),
        expect: () => [
          isA<TrainingSessionCreationFormState>()
              .having((s) => s.participantsError, 'participantsError',
                  'Minimum participants must be at least 2')
              .having((s) => s.isValid, 'isValid', false),
        ],
      );

      blocTest<TrainingSessionCreationBloc, TrainingSessionCreationState>(
        'validates maxParticipants >= minParticipants',
        build: () => bloc,
        seed: () => const TrainingSessionCreationFormState(
          minParticipants: 10,
          maxParticipants: 8,
        ),
        act: (bloc) => bloc.add(const ValidateTrainingForm()),
        expect: () => [
          isA<TrainingSessionCreationFormState>()
              .having((s) => s.participantsError, 'participantsError',
                  'Maximum participants must be greater than or equal to minimum participants')
              .having((s) => s.isValid, 'isValid', false),
        ],
      );
    });

    group('SetSessionNotes', () {
      blocTest<TrainingSessionCreationBloc, TrainingSessionCreationState>(
        'emits form state with notes set (no validation)',
        build: () => bloc,
        act: (bloc) => bloc.add(const SetSessionNotes(
            notes: 'Bring water and sunscreen')),
        expect: () => [
          isA<TrainingSessionCreationFormState>()
              .having((s) => s.notes, 'notes', 'Bring water and sunscreen')
              .having((s) => s.isValid, 'isValid', false),
        ],
      );
    });

    group('SubmitTrainingSession', () {
      final validStartTime = DateTime.now().add(const Duration(days: 1));
      final validEndTime = validStartTime.add(const Duration(hours: 2));

      blocTest<TrainingSessionCreationBloc, TrainingSessionCreationState>(
        'emits validation errors when form is invalid',
        build: () => bloc,
        seed: () => const TrainingSessionCreationFormState(),
        act: (bloc) => bloc.add(const SubmitTrainingSession(
          createdBy: 'user-1',
        )),
        expect: () => [
          isA<TrainingSessionCreationFormState>()
              .having((s) => s.isValid, 'isValid', false)
              .having((s) => s.groupError, 'groupError', isNotNull)
              .having((s) => s.startTimeError, 'startTimeError', isNotNull)
              .having((s) => s.endTimeError, 'endTimeError', isNotNull)
              .having((s) => s.locationError, 'locationError', isNotNull)
              .having((s) => s.titleError, 'titleError', isNotNull),
        ],
        verify: (_) {
          verifyNever(() => mockRepository.createTrainingSession(any()));
        },
      );

      blocTest<TrainingSessionCreationBloc, TrainingSessionCreationState>(
        'successfully creates training session with valid form',
        build: () => bloc,
        setUp: () {
          when(() => mockRepository.createTrainingSession(any()))
              .thenAnswer((_) async => 'session-123');
        },
        seed: () => TrainingSessionCreationFormState(
          groupId: 'group-1',
          groupName: 'Test Group',
          startTime: validStartTime,
          endTime: validEndTime,
          locationName: 'Beach Court 1',
          address: '123 Beach St',
          title: 'Advanced Training',
          description: 'Practice session',
          maxParticipants: 12,
          minParticipants: 4,
          notes: 'Bring equipment',
        ),
        act: (bloc) => bloc.add(const SubmitTrainingSession(
          createdBy: 'user-1',
        )),
        expect: () => [
          isA<TrainingSessionCreationSubmitting>(),
          isA<TrainingSessionCreationSuccess>()
              .having((s) => s.sessionId, 'sessionId', 'session-123')
              .having((s) => s.session.id, 'session.id', 'session-123')
              .having((s) => s.session.groupId, 'session.groupId', 'group-1')
              .having((s) => s.session.title, 'session.title',
                  'Advanced Training')
              .having((s) => s.session.createdBy, 'session.createdBy', 'user-1')
              .having((s) => s.session.minParticipants,
                  'session.minParticipants', 4)
              .having((s) => s.session.maxParticipants,
                  'session.maxParticipants', 12),
        ],
        verify: (_) {
          verify(() => mockRepository.createTrainingSession(any())).called(1);
        },
      );

      blocTest<TrainingSessionCreationBloc, TrainingSessionCreationState>(
        'emits error when repository throws not a member exception',
        build: () => bloc,
        setUp: () {
          when(() => mockRepository.createTrainingSession(any())).thenThrow(
              Exception('Creator is not a member of the group'));
        },
        seed: () => TrainingSessionCreationFormState(
          groupId: 'group-1',
          groupName: 'Test Group',
          startTime: validStartTime,
          endTime: validEndTime,
          locationName: 'Beach Court 1',
          title: 'Advanced Training',
        ),
        act: (bloc) => bloc.add(const SubmitTrainingSession(
          createdBy: 'user-1',
        )),
        expect: () => [
          isA<TrainingSessionCreationSubmitting>(),
          isA<TrainingSessionCreationError>()
              .having((s) => s.message, 'message',
                  'You must be a member of the group to create a training session')
              .having((s) => s.errorCode, 'errorCode', 'NOT_A_MEMBER')
              .having((s) => s.isRetryable, 'isRetryable', true),
        ],
      );

      blocTest<TrainingSessionCreationBloc, TrainingSessionCreationState>(
        'emits error when repository throws group not found exception',
        build: () => bloc,
        setUp: () {
          when(() => mockRepository.createTrainingSession(any()))
              .thenThrow(Exception('Group not found'));
        },
        seed: () => TrainingSessionCreationFormState(
          groupId: 'group-1',
          groupName: 'Test Group',
          startTime: validStartTime,
          endTime: validEndTime,
          locationName: 'Beach Court 1',
          title: 'Advanced Training',
        ),
        act: (bloc) => bloc.add(const SubmitTrainingSession(
          createdBy: 'user-1',
        )),
        expect: () => [
          isA<TrainingSessionCreationSubmitting>(),
          isA<TrainingSessionCreationError>()
              .having((s) => s.message, 'message',
                  'The selected group no longer exists')
              .having((s) => s.errorCode, 'errorCode', 'GROUP_NOT_FOUND')
              .having((s) => s.isRetryable, 'isRetryable', true),
        ],
      );

      blocTest<TrainingSessionCreationBloc, TrainingSessionCreationState>(
        'emits generic error for other exceptions',
        build: () => bloc,
        setUp: () {
          when(() => mockRepository.createTrainingSession(any()))
              .thenThrow(Exception('Network error'));
        },
        seed: () => TrainingSessionCreationFormState(
          groupId: 'group-1',
          groupName: 'Test Group',
          startTime: validStartTime,
          endTime: validEndTime,
          locationName: 'Beach Court 1',
          title: 'Advanced Training',
        ),
        act: (bloc) => bloc.add(const SubmitTrainingSession(
          createdBy: 'user-1',
        )),
        expect: () => [
          isA<TrainingSessionCreationSubmitting>(),
          isA<TrainingSessionCreationError>()
              .having((s) => s.message, 'message',
                  contains('Failed to create training session'))
              .having((s) => s.errorCode, 'errorCode', 'CREATE_SESSION_ERROR')
              .having((s) => s.isRetryable, 'isRetryable', true),
        ],
      );
    });

    group('ResetTrainingForm', () {
      blocTest<TrainingSessionCreationBloc, TrainingSessionCreationState>(
        'resets form to initial state',
        build: () => bloc,
        seed: () => TrainingSessionCreationFormState(
          groupId: 'group-1',
          groupName: 'Test Group',
          title: 'Test Title',
          startTime: DateTime.now().add(const Duration(days: 1)),
        ),
        act: (bloc) => bloc.add(const ResetTrainingForm()),
        expect: () => [
          const TrainingSessionCreationFormState(),
        ],
      );
    });

    group('Form Validation', () {
      final validStartTime = DateTime.now().add(const Duration(days: 1));
      final validEndTime = validStartTime.add(const Duration(hours: 2));

      blocTest<TrainingSessionCreationBloc, TrainingSessionCreationState>(
        'emits valid state when all fields are correct',
        build: () => bloc,
        seed: () => TrainingSessionCreationFormState(
          groupId: 'group-1',
          groupName: 'Test Group',
          startTime: validStartTime,
          endTime: validEndTime,
          locationName: 'Beach Court 1',
          address: '123 Beach St',
          title: 'Advanced Training',
          description: 'Practice session',
          maxParticipants: 12,
          minParticipants: 4,
        ),
        act: (bloc) => bloc.add(const ValidateTrainingForm()),
        expect: () => [
          isA<TrainingSessionCreationFormState>()
              .having((s) => s.isValid, 'isValid', true)
              .having((s) => s.groupError, 'groupError', null)
              .having((s) => s.startTimeError, 'startTimeError', null)
              .having((s) => s.endTimeError, 'endTimeError', null)
              .having((s) => s.locationError, 'locationError', null)
              .having((s) => s.titleError, 'titleError', null)
              .having((s) => s.participantsError, 'participantsError', null),
        ],
      );
    });
  });
}
