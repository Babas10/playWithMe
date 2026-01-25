// Validates FirestoreExerciseRepository methods with fake Firestore.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:play_with_me/core/data/models/exercise_model.dart';
import 'package:play_with_me/core/data/models/game_model.dart';
import 'package:play_with_me/core/data/models/training_session_model.dart';
import 'package:play_with_me/core/data/repositories/firestore_exercise_repository.dart';
import 'package:play_with_me/core/domain/exceptions/repository_exceptions.dart';
import 'package:play_with_me/core/domain/repositories/exercise_repository.dart';
import 'package:play_with_me/core/domain/repositories/training_session_repository.dart';

class MockTrainingSessionRepository extends Mock
    implements TrainingSessionRepository {}

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late ExerciseRepository exerciseRepository;
  late MockTrainingSessionRepository mockTrainingSessionRepository;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    mockTrainingSessionRepository = MockTrainingSessionRepository();
    exerciseRepository = FirestoreExerciseRepository(
      firestore: fakeFirestore,
      trainingSessionRepository: mockTrainingSessionRepository,
    );
  });

  TrainingSessionModel createFutureSession(String sessionId) {
    return TrainingSessionModel(
      id: sessionId,
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
  }

  TrainingSessionModel createPastSession(String sessionId) {
    return TrainingSessionModel(
      id: sessionId,
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
  }

  Future<String> createTrainingSessionInFirestore(String sessionId) async {
    await fakeFirestore.collection('trainingSessions').doc(sessionId).set({
      'groupId': 'group-1',
      'title': 'Test Session',
      'createdBy': 'user-1',
      'createdAt': Timestamp.now(),
      'startTime': Timestamp.fromDate(
        DateTime.now().add(const Duration(days: 1)),
      ),
      'endTime': Timestamp.fromDate(
        DateTime.now().add(const Duration(days: 1, hours: 2)),
      ),
      'minParticipants': 2,
      'maxParticipants': 10,
    });
    return sessionId;
  }

  Future<String> addExerciseToFirestore(
    String sessionId,
    String exerciseId, {
    String name = 'Test Exercise',
    String? description,
    int? durationMinutes,
  }) async {
    await fakeFirestore
        .collection('trainingSessions')
        .doc(sessionId)
        .collection('exercises')
        .doc(exerciseId)
        .set({
      'name': name,
      if (description != null) 'description': description,
      if (durationMinutes != null) 'durationMinutes': durationMinutes,
      'createdAt': Timestamp.now(),
    });
    return exerciseId;
  }

  group('FirestoreExerciseRepository', () {
    group('getExerciseById', () {
      test('returns exercise when it exists', () async {
        const sessionId = 'session-1';
        await createTrainingSessionInFirestore(sessionId);
        await addExerciseToFirestore(
          sessionId,
          'exercise-1',
          name: 'Warm-up Drills',
          description: 'Basic warm-up exercises',
          durationMinutes: 15,
        );

        final exercise = await exerciseRepository.getExerciseById(
          sessionId,
          'exercise-1',
        );

        expect(exercise, isNotNull);
        expect(exercise!.id, 'exercise-1');
        expect(exercise.name, 'Warm-up Drills');
        expect(exercise.description, 'Basic warm-up exercises');
        expect(exercise.durationMinutes, 15);
      });

      test('returns null when exercise does not exist', () async {
        const sessionId = 'session-1';
        await createTrainingSessionInFirestore(sessionId);

        final exercise = await exerciseRepository.getExerciseById(
          sessionId,
          'non-existent-exercise',
        );

        expect(exercise, isNull);
      });

      test('returns exercise with minimal fields', () async {
        const sessionId = 'session-1';
        await createTrainingSessionInFirestore(sessionId);
        await addExerciseToFirestore(
          sessionId,
          'exercise-1',
          name: 'Basic Exercise',
        );

        final exercise = await exerciseRepository.getExerciseById(
          sessionId,
          'exercise-1',
        );

        expect(exercise, isNotNull);
        expect(exercise!.name, 'Basic Exercise');
        expect(exercise.description, isNull);
        expect(exercise.durationMinutes, isNull);
      });
    });

    group('getExerciseStream', () {
      test('emits exercise when it exists', () async {
        const sessionId = 'session-1';
        await createTrainingSessionInFirestore(sessionId);
        await addExerciseToFirestore(
          sessionId,
          'exercise-1',
          name: 'Streamed Exercise',
        );

        final stream = exerciseRepository.getExerciseStream(
          sessionId,
          'exercise-1',
        );

        await expectLater(
          stream,
          emits(
            isA<ExerciseModel>().having(
              (e) => e.name,
              'name',
              'Streamed Exercise',
            ),
          ),
        );
      });

      test('emits null when exercise does not exist', () async {
        const sessionId = 'session-1';
        await createTrainingSessionInFirestore(sessionId);

        final stream = exerciseRepository.getExerciseStream(
          sessionId,
          'non-existent-exercise',
        );

        await expectLater(stream, emits(isNull));
      });
    });

    group('getExercisesForTrainingSession', () {
      test('returns stream of exercises', () async {
        const sessionId = 'session-1';
        await createTrainingSessionInFirestore(sessionId);
        await addExerciseToFirestore(
          sessionId,
          'exercise-1',
          name: 'Exercise 1',
        );
        await addExerciseToFirestore(
          sessionId,
          'exercise-2',
          name: 'Exercise 2',
        );

        final stream = exerciseRepository.getExercisesForTrainingSession(
          sessionId,
        );
        final exercises = await stream.first;

        expect(exercises.length, 2);
        expect(exercises.any((e) => e.name == 'Exercise 1'), true);
        expect(exercises.any((e) => e.name == 'Exercise 2'), true);
      });

      test('returns empty list when no exercises exist', () async {
        const sessionId = 'session-1';
        await createTrainingSessionInFirestore(sessionId);

        final stream = exerciseRepository.getExercisesForTrainingSession(
          sessionId,
        );
        final exercises = await stream.first;

        expect(exercises, isEmpty);
      });
    });

    group('getExerciseCount', () {
      test('returns correct count of exercises', () async {
        const sessionId = 'session-1';
        await createTrainingSessionInFirestore(sessionId);
        await addExerciseToFirestore(sessionId, 'exercise-1', name: 'Ex 1');
        await addExerciseToFirestore(sessionId, 'exercise-2', name: 'Ex 2');
        await addExerciseToFirestore(sessionId, 'exercise-3', name: 'Ex 3');

        final stream = exerciseRepository.getExerciseCount(sessionId);
        final count = await stream.first;

        expect(count, 3);
      });

      test('returns 0 when no exercises exist', () async {
        const sessionId = 'session-1';
        await createTrainingSessionInFirestore(sessionId);

        final stream = exerciseRepository.getExerciseCount(sessionId);
        final count = await stream.first;

        expect(count, 0);
      });
    });

    group('createExercise', () {
      test('creates exercise successfully', () async {
        const sessionId = 'session-1';
        await createTrainingSessionInFirestore(sessionId);

        when(() => mockTrainingSessionRepository.getTrainingSessionById(
              sessionId,
            )).thenAnswer((_) async => createFutureSession(sessionId));

        final exercise = ExerciseModel(
          id: '',
          name: 'New Exercise',
          description: 'A new exercise',
          durationMinutes: 30,
          createdAt: DateTime.now(),
        );

        final exerciseId = await exerciseRepository.createExercise(
          sessionId,
          exercise,
        );

        expect(exerciseId, isNotEmpty);

        // Verify exercise was created in Firestore
        final doc = await fakeFirestore
            .collection('trainingSessions')
            .doc(sessionId)
            .collection('exercises')
            .doc(exerciseId)
            .get();
        expect(doc.exists, true);
        expect(doc.data()!['name'], 'New Exercise');
      });

      test('throws exception when session does not exist', () async {
        const sessionId = 'non-existent-session';

        when(() => mockTrainingSessionRepository.getTrainingSessionById(
              sessionId,
            )).thenAnswer((_) async => null);

        final exercise = ExerciseModel(
          id: '',
          name: 'New Exercise',
          createdAt: DateTime.now(),
        );

        await expectLater(
          exerciseRepository.createExercise(sessionId, exercise),
          throwsA(isA<ExerciseException>()),
        );
      });

      test('throws exception when session has started', () async {
        const sessionId = 'session-1';
        await createTrainingSessionInFirestore(sessionId);

        when(() => mockTrainingSessionRepository.getTrainingSessionById(
              sessionId,
            )).thenAnswer((_) async => createPastSession(sessionId));

        final exercise = ExerciseModel(
          id: '',
          name: 'New Exercise',
          createdAt: DateTime.now(),
        );

        await expectLater(
          exerciseRepository.createExercise(sessionId, exercise),
          throwsA(isA<ExerciseException>()),
        );
      });

      test('throws exception when exercise name is empty', () async {
        const sessionId = 'session-1';
        await createTrainingSessionInFirestore(sessionId);

        when(() => mockTrainingSessionRepository.getTrainingSessionById(
              sessionId,
            )).thenAnswer((_) async => createFutureSession(sessionId));

        final exercise = ExerciseModel(
          id: '',
          name: '',
          createdAt: DateTime.now(),
        );

        await expectLater(
          exerciseRepository.createExercise(sessionId, exercise),
          throwsA(isA<ExerciseException>()),
        );
      });

      test('throws exception when duration is invalid', () async {
        const sessionId = 'session-1';
        await createTrainingSessionInFirestore(sessionId);

        when(() => mockTrainingSessionRepository.getTrainingSessionById(
              sessionId,
            )).thenAnswer((_) async => createFutureSession(sessionId));

        final exercise = ExerciseModel(
          id: '',
          name: 'Valid Name',
          durationMinutes: 301, // Invalid: > 300
          createdAt: DateTime.now(),
        );

        await expectLater(
          exerciseRepository.createExercise(sessionId, exercise),
          throwsA(isA<ExerciseException>()),
        );
      });
    });

    group('updateExercise', () {
      test('updates exercise successfully', () async {
        const sessionId = 'session-1';
        await createTrainingSessionInFirestore(sessionId);
        await addExerciseToFirestore(
          sessionId,
          'exercise-1',
          name: 'Original Name',
          durationMinutes: 15,
        );

        when(() => mockTrainingSessionRepository.getTrainingSessionById(
              sessionId,
            )).thenAnswer((_) async => createFutureSession(sessionId));

        await exerciseRepository.updateExercise(
          sessionId,
          'exercise-1',
          name: 'Updated Name',
          description: 'New description',
          durationMinutes: 30,
        );

        // Verify exercise was updated
        final doc = await fakeFirestore
            .collection('trainingSessions')
            .doc(sessionId)
            .collection('exercises')
            .doc('exercise-1')
            .get();
        expect(doc.data()!['name'], 'Updated Name');
        expect(doc.data()!['description'], 'New description');
        expect(doc.data()!['durationMinutes'], 30);
      });

      test('throws exception when exercise does not exist', () async {
        const sessionId = 'session-1';
        await createTrainingSessionInFirestore(sessionId);

        when(() => mockTrainingSessionRepository.getTrainingSessionById(
              sessionId,
            )).thenAnswer((_) async => createFutureSession(sessionId));

        await expectLater(
          exerciseRepository.updateExercise(
            sessionId,
            'non-existent-exercise',
            name: 'Updated Name',
          ),
          throwsA(isA<ExerciseException>()),
        );
      });

      test('throws exception when session has started', () async {
        const sessionId = 'session-1';
        await createTrainingSessionInFirestore(sessionId);
        await addExerciseToFirestore(
          sessionId,
          'exercise-1',
          name: 'Original Name',
        );

        when(() => mockTrainingSessionRepository.getTrainingSessionById(
              sessionId,
            )).thenAnswer((_) async => createPastSession(sessionId));

        await expectLater(
          exerciseRepository.updateExercise(
            sessionId,
            'exercise-1',
            name: 'Updated Name',
          ),
          throwsA(isA<ExerciseException>()),
        );
      });

      test('throws exception when updating name to empty', () async {
        const sessionId = 'session-1';
        await createTrainingSessionInFirestore(sessionId);
        await addExerciseToFirestore(
          sessionId,
          'exercise-1',
          name: 'Original Name',
        );

        when(() => mockTrainingSessionRepository.getTrainingSessionById(
              sessionId,
            )).thenAnswer((_) async => createFutureSession(sessionId));

        await expectLater(
          exerciseRepository.updateExercise(
            sessionId,
            'exercise-1',
            name: '',
          ),
          throwsA(isA<ExerciseException>()),
        );
      });

      test('throws exception when updating duration to invalid value',
          () async {
        const sessionId = 'session-1';
        await createTrainingSessionInFirestore(sessionId);
        await addExerciseToFirestore(
          sessionId,
          'exercise-1',
          name: 'Original Name',
          durationMinutes: 15,
        );

        when(() => mockTrainingSessionRepository.getTrainingSessionById(
              sessionId,
            )).thenAnswer((_) async => createFutureSession(sessionId));

        await expectLater(
          exerciseRepository.updateExercise(
            sessionId,
            'exercise-1',
            durationMinutes: 301,
          ),
          throwsA(isA<ExerciseException>()),
        );
      });
    });

    group('deleteExercise', () {
      test('deletes exercise successfully', () async {
        const sessionId = 'session-1';
        await createTrainingSessionInFirestore(sessionId);
        await addExerciseToFirestore(
          sessionId,
          'exercise-1',
          name: 'To Be Deleted',
        );

        when(() => mockTrainingSessionRepository.getTrainingSessionById(
              sessionId,
            )).thenAnswer((_) async => createFutureSession(sessionId));

        await exerciseRepository.deleteExercise(sessionId, 'exercise-1');

        // Verify exercise was deleted
        final doc = await fakeFirestore
            .collection('trainingSessions')
            .doc(sessionId)
            .collection('exercises')
            .doc('exercise-1')
            .get();
        expect(doc.exists, false);
      });

      test('throws exception when exercise does not exist', () async {
        const sessionId = 'session-1';
        await createTrainingSessionInFirestore(sessionId);

        when(() => mockTrainingSessionRepository.getTrainingSessionById(
              sessionId,
            )).thenAnswer((_) async => createFutureSession(sessionId));

        await expectLater(
          exerciseRepository.deleteExercise(sessionId, 'non-existent-exercise'),
          throwsA(isA<ExerciseException>()),
        );
      });

      test('throws exception when session has started', () async {
        const sessionId = 'session-1';
        await createTrainingSessionInFirestore(sessionId);
        await addExerciseToFirestore(
          sessionId,
          'exercise-1',
          name: 'To Be Deleted',
        );

        when(() => mockTrainingSessionRepository.getTrainingSessionById(
              sessionId,
            )).thenAnswer((_) async => createPastSession(sessionId));

        await expectLater(
          exerciseRepository.deleteExercise(sessionId, 'exercise-1'),
          throwsA(isA<ExerciseException>()),
        );
      });
    });

    group('exerciseExists', () {
      test('returns true when exercise exists', () async {
        const sessionId = 'session-1';
        await createTrainingSessionInFirestore(sessionId);
        await addExerciseToFirestore(
          sessionId,
          'exercise-1',
          name: 'Existing Exercise',
        );

        final exists = await exerciseRepository.exerciseExists(
          sessionId,
          'exercise-1',
        );

        expect(exists, true);
      });

      test('returns false when exercise does not exist', () async {
        const sessionId = 'session-1';
        await createTrainingSessionInFirestore(sessionId);

        final exists = await exerciseRepository.exerciseExists(
          sessionId,
          'non-existent-exercise',
        );

        expect(exists, false);
      });
    });

    group('canModifyExercises', () {
      test('returns true when session has not started', () async {
        when(() => mockTrainingSessionRepository.getTrainingSessionById(
              'session-1',
            )).thenAnswer((_) async => createFutureSession('session-1'));

        final canModify =
            await exerciseRepository.canModifyExercises('session-1');

        expect(canModify, isTrue);
      });

      test('returns false when session has started', () async {
        when(() => mockTrainingSessionRepository.getTrainingSessionById(
              'session-1',
            )).thenAnswer((_) async => createPastSession('session-1'));

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

    group('deleteAllExercisesForSession', () {
      test('deletes all exercises successfully', () async {
        const sessionId = 'session-1';
        await createTrainingSessionInFirestore(sessionId);
        await addExerciseToFirestore(sessionId, 'exercise-1', name: 'Ex 1');
        await addExerciseToFirestore(sessionId, 'exercise-2', name: 'Ex 2');
        await addExerciseToFirestore(sessionId, 'exercise-3', name: 'Ex 3');

        await exerciseRepository.deleteAllExercisesForSession(sessionId);

        // Verify all exercises were deleted
        final snapshot = await fakeFirestore
            .collection('trainingSessions')
            .doc(sessionId)
            .collection('exercises')
            .get();
        expect(snapshot.docs, isEmpty);
      });

      test('handles empty collection gracefully', () async {
        const sessionId = 'session-1';
        await createTrainingSessionInFirestore(sessionId);

        await expectLater(
          exerciseRepository.deleteAllExercisesForSession(sessionId),
          completes,
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

      test('validates exercise name is valid when non-empty', () {
        final exercise = ExerciseModel(
          id: '',
          name: 'Valid Name',
          createdAt: DateTime.now(),
        );

        expect(exercise.hasValidName, isTrue);
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

      test('validates duration rejects 0', () {
        final exercise = ExerciseModel(
          id: '',
          name: 'Test',
          durationMinutes: 0,
          createdAt: DateTime.now(),
        );

        expect(exercise.hasValidDuration, isFalse);
      });

      test('validates duration accepts minimum of 1', () {
        final exercise = ExerciseModel(
          id: '',
          name: 'Test',
          durationMinutes: 1,
          createdAt: DateTime.now(),
        );

        expect(exercise.hasValidDuration, isTrue);
      });

      test('validates duration accepts maximum of 300', () {
        final exercise = ExerciseModel(
          id: '',
          name: 'Test',
          durationMinutes: 300,
          createdAt: DateTime.now(),
        );

        expect(exercise.hasValidDuration, isTrue);
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
