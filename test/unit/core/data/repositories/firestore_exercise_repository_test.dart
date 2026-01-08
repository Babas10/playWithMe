// Validates FirestoreExerciseRepository methods with mocked dependencies.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:play_with_me/core/data/models/exercise_model.dart';
import 'package:play_with_me/core/data/models/game_model.dart';
import 'package:play_with_me/core/data/models/training_session_model.dart';
import 'package:play_with_me/core/data/repositories/firestore_exercise_repository.dart';
import 'package:play_with_me/core/domain/repositories/exercise_repository.dart';
import 'package:play_with_me/core/domain/repositories/training_session_repository.dart';

class MockTrainingSessionRepository extends Mock
    implements TrainingSessionRepository {}

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

void main() {
  late ExerciseRepository exerciseRepository;
  late MockTrainingSessionRepository mockTrainingSessionRepository;
  late MockFirebaseFirestore mockFirestore;

  setUp(() {
    mockTrainingSessionRepository = MockTrainingSessionRepository();
    mockFirestore = MockFirebaseFirestore();
    exerciseRepository = FirestoreExerciseRepository(
      firestore: mockFirestore,
      trainingSessionRepository: mockTrainingSessionRepository,
    );
  });

  group('FirestoreExerciseRepository', () {
    group('canModifyExercises', () {
      test('returns true when session has not started', () async {
        final futureSession = TrainingSessionModel(
          id: 'session-1',
          groupId: 'group-1',
          title: 'Future Session',
          location: const GameLocation(
            name: 'Beach',
            latitude: 0,
            longitude: 0,
          ),
          startTime: DateTime.now().add(const Duration(days: 1)),
          endTime: DateTime.now().add(const Duration(days: 1, hours: 2)),
          minParticipants: 2,
          maxParticipants: 10,
          createdBy: 'user-1',
          createdAt: DateTime.now(),
        );

        when(() => mockTrainingSessionRepository.getTrainingSessionById(
              'session-1',
            )).thenAnswer((_) async => futureSession);

        final canModify =
            await exerciseRepository.canModifyExercises('session-1');

        expect(canModify, isTrue);
      });

      test('returns false when session has started', () async {
        final pastSession = TrainingSessionModel(
          id: 'session-1',
          groupId: 'group-1',
          title: 'Past Session',
          location: const GameLocation(
            name: 'Beach',
            latitude: 0,
            longitude: 0,
          ),
          startTime: DateTime.now().subtract(const Duration(hours: 1)),
          endTime: DateTime.now().add(const Duration(hours: 1)),
          minParticipants: 2,
          maxParticipants: 10,
          createdBy: 'user-1',
          createdAt: DateTime.now(),
        );

        when(() => mockTrainingSessionRepository.getTrainingSessionById(
              'session-1',
            )).thenAnswer((_) async => pastSession);

        final canModify =
            await exerciseRepository.canModifyExercises('session-1');

        expect(canModify, isFalse);
      });

      test('returns false when session does not exist', () async {
        when(() => mockTrainingSessionRepository.getTrainingSessionById(
              'session-1',
            )).thenAnswer((_) async => null);

        final canModify =
            await exerciseRepository.canModifyExercises('session-1');

        expect(canModify, isFalse);
      });

      test('throws exception when repository fails', () async {
        when(() => mockTrainingSessionRepository.getTrainingSessionById(
              'session-1',
            )).thenThrow(Exception('Failed to get session'));

        expect(
          () => exerciseRepository.canModifyExercises('session-1'),
          throwsException,
        );
      });
    });

    group('Exercise Model Validation', () {
      test('validates exercise name is not empty', () {
        final exercise = ExerciseModel(
          id: '',
          name: '',
          createdAt: DateTime.now(),
        );

        expect(exercise.hasValidName, isFalse);
      });

      test('validates exercise name with whitespace only', () {
        final exercise = ExerciseModel(
          id: '',
          name: '   ',
          createdAt: DateTime.now(),
        );

        expect(exercise.hasValidName, isFalse);
      });

      test('validates duration is within valid range', () {
        final validExercise = ExerciseModel(
          id: '',
          name: 'Test',
          durationMinutes: 150,
          createdAt: DateTime.now(),
        );

        final invalidExercise = ExerciseModel(
          id: '',
          name: 'Test',
          durationMinutes: 301,
          createdAt: DateTime.now(),
        );

        expect(validExercise.hasValidDuration, isTrue);
        expect(invalidExercise.hasValidDuration, isFalse);
      });

      test('validates duration accepts null', () {
        final exercise = ExerciseModel(
          id: '',
          name: 'Test',
          durationMinutes: null,
          createdAt: DateTime.now(),
        );

        expect(exercise.hasValidDuration, isTrue);
      });
    });

    group('Exercise Creation Validation', () {
      test('createExercise validates name is not empty', () {
        final exercise = ExerciseModel(
          id: '',
          name: '',
          createdAt: DateTime.now(),
        );

        when(() => mockTrainingSessionRepository.getTrainingSessionById(
              'session-1',
            )).thenAnswer(
          (_) async => TrainingSessionModel(
            id: 'session-1',
            groupId: 'group-1',
            title: 'Session',
            location: const GameLocation(
              name: 'Beach',
              latitude: 0,
              longitude: 0,
            ),
            startTime: DateTime.now().add(const Duration(days: 1)),
            endTime: DateTime.now().add(const Duration(days: 1, hours: 2)),
            minParticipants: 2,
            maxParticipants: 10,
            createdBy: 'user-1',
            createdAt: DateTime.now(),
          ),
        );

        expect(
          () => exerciseRepository.createExercise('session-1', exercise),
          throwsException,
        );
      });

      test('createExercise validates duration is within range', () {
        final exercise = ExerciseModel(
          id: '',
          name: 'Test',
          durationMinutes: 301,
          createdAt: DateTime.now(),
        );

        when(() => mockTrainingSessionRepository.getTrainingSessionById(
              'session-1',
            )).thenAnswer(
          (_) async => TrainingSessionModel(
            id: 'session-1',
            groupId: 'group-1',
            title: 'Session',
            location: const GameLocation(
              name: 'Beach',
              latitude: 0,
              longitude: 0,
            ),
            startTime: DateTime.now().add(const Duration(days: 1)),
            endTime: DateTime.now().add(const Duration(days: 1, hours: 2)),
            minParticipants: 2,
            maxParticipants: 10,
            createdBy: 'user-1',
            createdAt: DateTime.now(),
          ),
        );

        expect(
          () => exerciseRepository.createExercise('session-1', exercise),
          throwsException,
        );
      });
    });

    group('Repository Interface', () {
      test('repository implements ExerciseRepository', () {
        expect(exerciseRepository, isA<ExerciseRepository>());
      });

      test('repository has all required methods', () {
        expect(exerciseRepository.getExerciseById, isA<Function>());
        expect(exerciseRepository.getExerciseStream, isA<Function>());
        expect(
          exerciseRepository.getExercisesForTrainingSession,
          isA<Function>(),
        );
        expect(exerciseRepository.getExerciseCount, isA<Function>());
        expect(exerciseRepository.createExercise, isA<Function>());
        expect(exerciseRepository.updateExercise, isA<Function>());
        expect(exerciseRepository.deleteExercise, isA<Function>());
        expect(exerciseRepository.exerciseExists, isA<Function>());
        expect(exerciseRepository.canModifyExercises, isA<Function>());
        expect(
          exerciseRepository.deleteAllExercisesForSession,
          isA<Function>(),
        );
      });
    });
  });
}
