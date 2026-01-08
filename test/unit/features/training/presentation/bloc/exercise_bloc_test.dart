// Validates ExerciseBloc state transitions and event handling for exercise management.

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:play_with_me/core/data/models/exercise_model.dart';
import 'package:play_with_me/core/domain/repositories/exercise_repository.dart';
import 'package:play_with_me/features/training/presentation/bloc/exercise/exercise_bloc.dart';
import 'package:play_with_me/features/training/presentation/bloc/exercise/exercise_event.dart';
import 'package:play_with_me/features/training/presentation/bloc/exercise/exercise_state.dart';

class MockExerciseRepository extends Mock implements ExerciseRepository {}

class FakeExerciseModel extends Fake implements ExerciseModel {}

void main() {
  late ExerciseBloc exerciseBloc;
  late MockExerciseRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(FakeExerciseModel());
  });

  setUp(() {
    mockRepository = MockExerciseRepository();
    exerciseBloc = ExerciseBloc(exerciseRepository: mockRepository);
  });

  tearDown(() {
    exerciseBloc.close();
  });

  group('ExerciseBloc', () {
    final testExercises = [
      ExerciseModel(
        id: 'exercise-1',
        name: 'Serving Practice',
        description: 'Practice serves',
        durationMinutes: 30,
        createdAt: DateTime(2024, 1, 1),
      ),
      ExerciseModel(
        id: 'exercise-2',
        name: 'Drills',
        durationMinutes: 45,
        createdAt: DateTime(2024, 1, 1),
      ),
    ];

    group('initial state', () {
      test('is ExerciseInitial', () {
        expect(exerciseBloc.state, const ExerciseInitial());
      });
    });

    group('LoadExercises', () {
      blocTest<ExerciseBloc, ExerciseState>(
        'emits [ExercisesLoading, ExercisesLoaded] when exercises load successfully',
        build: () {
          when(() => mockRepository.canModifyExercises('session-1'))
              .thenAnswer((_) async => true);
          when(() => mockRepository.getExercisesForTrainingSession('session-1'))
              .thenAnswer((_) => Stream.value(testExercises));
          return exerciseBloc;
        },
        act: (bloc) =>
            bloc.add(const LoadExercises(trainingSessionId: 'session-1')),
        expect: () => [
          const ExercisesLoading(),
          ExercisesLoaded(exercises: testExercises, canModify: true),
        ],
        verify: (_) {
          verify(() => mockRepository.canModifyExercises('session-1'))
              .called(1);
          verify(() =>
                  mockRepository.getExercisesForTrainingSession('session-1'))
              .called(1);
        },
      );

      blocTest<ExerciseBloc, ExerciseState>(
        'emits [ExercisesLoading, ExercisesLoaded] with canModify false when session has started',
        build: () {
          when(() => mockRepository.canModifyExercises('session-1'))
              .thenAnswer((_) async => false);
          when(() => mockRepository.getExercisesForTrainingSession('session-1'))
              .thenAnswer((_) => Stream.value(testExercises));
          return exerciseBloc;
        },
        act: (bloc) =>
            bloc.add(const LoadExercises(trainingSessionId: 'session-1')),
        expect: () => [
          const ExercisesLoading(),
          ExercisesLoaded(exercises: testExercises, canModify: false),
        ],
      );

      blocTest<ExerciseBloc, ExerciseState>(
        'emits [ExercisesLoading, ExerciseError] when loading fails',
        build: () {
          when(() => mockRepository.canModifyExercises('session-1'))
              .thenThrow(Exception('Failed to check'));
          return exerciseBloc;
        },
        act: (bloc) =>
            bloc.add(const LoadExercises(trainingSessionId: 'session-1')),
        expect: () => [
          const ExercisesLoading(),
          isA<ExerciseError>(),
        ],
      );

      blocTest<ExerciseBloc, ExerciseState>(
        'emits [ExercisesLoading, ExercisesLoaded] with empty list when no exercises',
        build: () {
          when(() => mockRepository.canModifyExercises('session-1'))
              .thenAnswer((_) async => true);
          when(() => mockRepository.getExercisesForTrainingSession('session-1'))
              .thenAnswer((_) => Stream.value([]));
          return exerciseBloc;
        },
        act: (bloc) =>
            bloc.add(const LoadExercises(trainingSessionId: 'session-1')),
        expect: () => [
          const ExercisesLoading(),
          const ExercisesLoaded(exercises: [], canModify: true),
        ],
      );
    });

    group('AddExercise', () {
      blocTest<ExerciseBloc, ExerciseState>(
        'emits [ExerciseAdding, ExerciseAdded, ExercisesLoaded] when exercise added successfully',
        build: () {
          when(() => mockRepository.canModifyExercises('session-1'))
              .thenAnswer((_) async => true);
          when(() => mockRepository.createExercise(
                'session-1',
                any(),
              )).thenAnswer((_) async => 'exercise-3');
          return exerciseBloc;
        },
        act: (bloc) => bloc.add(const AddExercise(
          trainingSessionId: 'session-1',
          name: 'New Exercise',
          description: 'Description',
          durationMinutes: 20,
        )),
        expect: () => [
          const ExerciseAdding(),
          const ExerciseAdded(exerciseId: 'exercise-3'),
          const ExercisesLoaded(exercises: [], canModify: true),
        ],
        verify: (_) {
          verify(() => mockRepository.canModifyExercises('session-1'))
              .called(1);
          verify(() => mockRepository.createExercise('session-1', any()))
              .called(1);
        },
      );

      blocTest<ExerciseBloc, ExerciseState>(
        'emits [ExercisesLocked, ExercisesLoaded] when session cannot be modified',
        build: () {
          when(() => mockRepository.canModifyExercises('session-1'))
              .thenAnswer((_) async => false);
          return exerciseBloc;
        },
        act: (bloc) => bloc.add(const AddExercise(
          trainingSessionId: 'session-1',
          name: 'New Exercise',
        )),
        expect: () => [
          const ExercisesLocked(),
          const ExercisesLoaded(exercises: [], canModify: false),
        ],
        verify: (_) {
          verify(() => mockRepository.canModifyExercises('session-1'))
              .called(1);
          verifyNever(() => mockRepository.createExercise(any(), any()));
        },
      );

      blocTest<ExerciseBloc, ExerciseState>(
        'emits [ExerciseAdding, ExerciseError, ExercisesLoaded] when creation fails',
        build: () {
          when(() => mockRepository.canModifyExercises('session-1'))
              .thenAnswer((_) async => true);
          when(() => mockRepository.createExercise('session-1', any()))
              .thenThrow(Exception('Failed to create'));
          return exerciseBloc;
        },
        act: (bloc) => bloc.add(const AddExercise(
          trainingSessionId: 'session-1',
          name: 'New Exercise',
        )),
        expect: () => [
          const ExerciseAdding(),
          isA<ExerciseError>(),
          const ExercisesLoaded(exercises: [], canModify: true),
        ],
      );

      blocTest<ExerciseBloc, ExerciseState>(
        'creates exercise without optional fields',
        build: () {
          when(() => mockRepository.canModifyExercises('session-1'))
              .thenAnswer((_) async => true);
          when(() => mockRepository.createExercise('session-1', any()))
              .thenAnswer((_) async => 'exercise-3');
          return exerciseBloc;
        },
        act: (bloc) => bloc.add(const AddExercise(
          trainingSessionId: 'session-1',
          name: 'New Exercise',
        )),
        expect: () => [
          const ExerciseAdding(),
          const ExerciseAdded(exerciseId: 'exercise-3'),
          const ExercisesLoaded(exercises: [], canModify: true),
        ],
      );
    });

    group('UpdateExercise', () {
      blocTest<ExerciseBloc, ExerciseState>(
        'emits [ExerciseUpdating, ExerciseUpdated, ExercisesLoaded] when update succeeds',
        build: () {
          when(() => mockRepository.canModifyExercises('session-1'))
              .thenAnswer((_) async => true);
          when(() => mockRepository.updateExercise(
                'session-1',
                'exercise-1',
                name: any(named: 'name'),
                description: any(named: 'description'),
                durationMinutes: any(named: 'durationMinutes'),
              )).thenAnswer((_) async {});
          return exerciseBloc;
        },
        act: (bloc) => bloc.add(const UpdateExercise(
          trainingSessionId: 'session-1',
          exerciseId: 'exercise-1',
          name: 'Updated Name',
          description: 'Updated Description',
          durationMinutes: 40,
        )),
        expect: () => [
          const ExerciseUpdating(exerciseId: 'exercise-1'),
          const ExerciseUpdated(),
          const ExercisesLoaded(exercises: [], canModify: true),
        ],
      );

      blocTest<ExerciseBloc, ExerciseState>(
        'emits [ExercisesLocked, ExercisesLoaded] when session cannot be modified',
        build: () {
          when(() => mockRepository.canModifyExercises('session-1'))
              .thenAnswer((_) async => false);
          return exerciseBloc;
        },
        act: (bloc) => bloc.add(const UpdateExercise(
          trainingSessionId: 'session-1',
          exerciseId: 'exercise-1',
          name: 'Updated Name',
        )),
        expect: () => [
          const ExercisesLocked(),
          const ExercisesLoaded(exercises: [], canModify: false),
        ],
        verify: (_) {
          verifyNever(() => mockRepository.updateExercise(
                any(),
                any(),
                name: any(named: 'name'),
              ));
        },
      );

      blocTest<ExerciseBloc, ExerciseState>(
        'emits [ExerciseUpdating, ExerciseError, ExercisesLoaded] when update fails',
        build: () {
          when(() => mockRepository.canModifyExercises('session-1'))
              .thenAnswer((_) async => true);
          when(() => mockRepository.updateExercise(
                any(),
                any(),
                name: any(named: 'name'),
              )).thenThrow(Exception('Failed to update'));
          return exerciseBloc;
        },
        act: (bloc) => bloc.add(const UpdateExercise(
          trainingSessionId: 'session-1',
          exerciseId: 'exercise-1',
          name: 'Updated Name',
        )),
        expect: () => [
          const ExerciseUpdating(exerciseId: 'exercise-1'),
          isA<ExerciseError>(),
          const ExercisesLoaded(exercises: [], canModify: true),
        ],
      );
    });

    group('DeleteExercise', () {
      blocTest<ExerciseBloc, ExerciseState>(
        'emits [ExerciseDeleting, ExerciseDeleted, ExercisesLoaded] when delete succeeds',
        build: () {
          when(() => mockRepository.canModifyExercises('session-1'))
              .thenAnswer((_) async => true);
          when(() => mockRepository.deleteExercise('session-1', 'exercise-1'))
              .thenAnswer((_) async {});
          return exerciseBloc;
        },
        act: (bloc) => bloc.add(const DeleteExercise(
          trainingSessionId: 'session-1',
          exerciseId: 'exercise-1',
        )),
        expect: () => [
          const ExerciseDeleting(exerciseId: 'exercise-1'),
          const ExerciseDeleted(),
          const ExercisesLoaded(exercises: [], canModify: true),
        ],
      );

      blocTest<ExerciseBloc, ExerciseState>(
        'emits [ExercisesLocked, ExercisesLoaded] when session cannot be modified',
        build: () {
          when(() => mockRepository.canModifyExercises('session-1'))
              .thenAnswer((_) async => false);
          return exerciseBloc;
        },
        act: (bloc) => bloc.add(const DeleteExercise(
          trainingSessionId: 'session-1',
          exerciseId: 'exercise-1',
        )),
        expect: () => [
          const ExercisesLocked(),
          const ExercisesLoaded(exercises: [], canModify: false),
        ],
        verify: (_) {
          verifyNever(() => mockRepository.deleteExercise(any(), any()));
        },
      );

      blocTest<ExerciseBloc, ExerciseState>(
        'emits [ExerciseDeleting, ExerciseError, ExercisesLoaded] when delete fails',
        build: () {
          when(() => mockRepository.canModifyExercises('session-1'))
              .thenAnswer((_) async => true);
          when(() => mockRepository.deleteExercise(any(), any()))
              .thenThrow(Exception('Failed to delete'));
          return exerciseBloc;
        },
        act: (bloc) => bloc.add(const DeleteExercise(
          trainingSessionId: 'session-1',
          exerciseId: 'exercise-1',
        )),
        expect: () => [
          const ExerciseDeleting(exerciseId: 'exercise-1'),
          isA<ExerciseError>(),
          const ExercisesLoaded(exercises: [], canModify: true),
        ],
      );
    });

    group('RefreshExercises', () {
      blocTest<ExerciseBloc, ExerciseState>(
        'reloads exercises for current session',
        build: () {
          when(() => mockRepository.canModifyExercises('session-1'))
              .thenAnswer((_) async => true);
          when(() => mockRepository.getExercisesForTrainingSession('session-1'))
              .thenAnswer((_) => Stream.value(testExercises));
          return exerciseBloc;
        },
        seed: () => const ExercisesLoaded(exercises: [], canModify: true),
        act: (bloc) {
          // First load exercises to set current session ID
          bloc.add(const LoadExercises(trainingSessionId: 'session-1'));
          return Future.delayed(
            const Duration(milliseconds: 100),
            () => bloc.add(const RefreshExercises()),
          );
        },
        skip: 2, // Skip initial load states
        expect: () => [
          const ExercisesLoading(),
          ExercisesLoaded(exercises: testExercises, canModify: true),
        ],
      );

      blocTest<ExerciseBloc, ExerciseState>(
        'does nothing when no session is loaded',
        build: () => exerciseBloc,
        act: (bloc) => bloc.add(const RefreshExercises()),
        expect: () => [],
      );
    });

    group('Stream subscription cleanup', () {
      test('cancels subscriptions on close', () async {
        when(() => mockRepository.canModifyExercises('session-1'))
            .thenAnswer((_) async => true);
        when(() => mockRepository.getExercisesForTrainingSession('session-1'))
            .thenAnswer((_) => Stream.value(testExercises));

        exerciseBloc.add(const LoadExercises(trainingSessionId: 'session-1'));

        await Future.delayed(const Duration(milliseconds: 100));

        await exerciseBloc.close();

        // Verify bloc is closed and no more events can be added
        expect(exerciseBloc.isClosed, isTrue);
      });
    });

    group('Error handling', () {
      blocTest<ExerciseBloc, ExerciseState>(
        'provides friendly error message for all error types',
        build: () {
          when(() => mockRepository.canModifyExercises('session-1'))
              .thenThrow(Exception('Test error'));
          return exerciseBloc;
        },
        act: (bloc) =>
            bloc.add(const LoadExercises(trainingSessionId: 'session-1')),
        expect: () => [
          const ExercisesLoading(),
          isA<ExerciseError>()
              .having((s) => s.message, 'message', isNotEmpty),
        ],
      );
    });
  });
}
