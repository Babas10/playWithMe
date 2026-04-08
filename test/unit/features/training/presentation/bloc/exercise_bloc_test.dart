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
        'emits [Loading, Loaded(canModify:true)] for organiser with future session',
        build: () {
          when(
            () => mockRepository.canModifyExercises('session-1'),
          ).thenAnswer((_) async => true);
          when(
            () => mockRepository.getExercisesForTrainingSession('session-1'),
          ).thenAnswer((_) => Stream.value(testExercises));
          return exerciseBloc;
        },
        act: (bloc) => bloc.add(
          const LoadExercises(
            trainingSessionId: 'session-1',
            isOrganiser: true,
          ),
        ),
        expect: () => [
          const ExercisesLoading(),
          ExercisesLoaded(
            exercises: testExercises,
            canModify: true,
            isOrganiser: true,
          ),
        ],
        verify: (_) {
          verify(
            () => mockRepository.canModifyExercises('session-1'),
          ).called(1);
          verify(
            () => mockRepository.getExercisesForTrainingSession('session-1'),
          ).called(1);
        },
      );

      blocTest<ExerciseBloc, ExerciseState>(
        'emits [Loading, Loaded(canModify:false)] for non-organiser even with future session',
        build: () {
          when(
            () => mockRepository.canModifyExercises('session-1'),
          ).thenAnswer((_) async => true);
          when(
            () => mockRepository.getExercisesForTrainingSession('session-1'),
          ).thenAnswer((_) => Stream.value(testExercises));
          return exerciseBloc;
        },
        act: (bloc) => bloc.add(
          const LoadExercises(
            trainingSessionId: 'session-1',
            isOrganiser: false,
          ),
        ),
        expect: () => [
          const ExercisesLoading(),
          ExercisesLoaded(
            exercises: testExercises,
            canModify: false,
            isOrganiser: false,
          ),
        ],
      );

      blocTest<ExerciseBloc, ExerciseState>(
        'emits [Loading, Loaded(canModify:false)] for organiser when session has started',
        build: () {
          when(
            () => mockRepository.canModifyExercises('session-1'),
          ).thenAnswer((_) async => false);
          when(
            () => mockRepository.getExercisesForTrainingSession('session-1'),
          ).thenAnswer((_) => Stream.value(testExercises));
          return exerciseBloc;
        },
        act: (bloc) => bloc.add(
          const LoadExercises(
            trainingSessionId: 'session-1',
            isOrganiser: true,
          ),
        ),
        expect: () => [
          const ExercisesLoading(),
          ExercisesLoaded(
            exercises: testExercises,
            canModify: false,
            isOrganiser: true,
          ),
        ],
      );

      blocTest<ExerciseBloc, ExerciseState>(
        'emits [Loading, ExerciseError] when loading fails',
        build: () {
          when(
            () => mockRepository.canModifyExercises('session-1'),
          ).thenThrow(Exception('Failed to check'));
          return exerciseBloc;
        },
        act: (bloc) => bloc.add(
          const LoadExercises(
            trainingSessionId: 'session-1',
            isOrganiser: true,
          ),
        ),
        expect: () => [const ExercisesLoading(), isA<ExerciseError>()],
      );

      blocTest<ExerciseBloc, ExerciseState>(
        'emits [Loading, Loaded] with empty list when no exercises',
        build: () {
          when(
            () => mockRepository.canModifyExercises('session-1'),
          ).thenAnswer((_) async => true);
          when(
            () => mockRepository.getExercisesForTrainingSession('session-1'),
          ).thenAnswer((_) => Stream.value([]));
          return exerciseBloc;
        },
        act: (bloc) => bloc.add(
          const LoadExercises(
            trainingSessionId: 'session-1',
            isOrganiser: true,
          ),
        ),
        expect: () => [
          const ExercisesLoading(),
          const ExercisesLoaded(
            exercises: [],
            canModify: true,
            isOrganiser: true,
          ),
        ],
      );
    });

    group('AddExercise — organiser restrictions', () {
      blocTest<ExerciseBloc, ExerciseState>(
        'emits [PermissionDenied, Loaded] when non-organiser attempts to add',
        build: () {
          when(
            () => mockRepository.canModifyExercises('session-1'),
          ).thenAnswer((_) async => true);
          when(
            () => mockRepository.getExercisesForTrainingSession('session-1'),
          ).thenAnswer((_) => Stream.value([]));
          return exerciseBloc;
        },
        act: (bloc) {
          bloc.add(
            const LoadExercises(
              trainingSessionId: 'session-1',
              isOrganiser: false,
            ),
          );
          return Future.delayed(
            Duration.zero,
            () => bloc.add(
              const AddExercise(
                trainingSessionId: 'session-1',
                name: 'Hacked Exercise',
              ),
            ),
          );
        },
        skip: 2, // skip ExercisesLoading + ExercisesLoaded from LoadExercises
        expect: () => [
          const ExercisePermissionDenied(),
          isA<ExercisesLoaded>()
              .having((s) => s.isOrganiser, 'isOrganiser', false)
              .having((s) => s.canModify, 'canModify', false),
        ],
        verify: (_) {
          verifyNever(() => mockRepository.createExercise(any(), any()));
        },
      );

      blocTest<ExerciseBloc, ExerciseState>(
        'emits [Adding, Added, Loaded] when organiser adds exercise',
        build: () {
          when(
            () => mockRepository.canModifyExercises('session-1'),
          ).thenAnswer((_) async => true);
          when(
            () => mockRepository.getExercisesForTrainingSession('session-1'),
          ).thenAnswer((_) => Stream.value([]));
          when(
            () => mockRepository.createExercise('session-1', any()),
          ).thenAnswer((_) async => 'exercise-3');
          return exerciseBloc;
        },
        act: (bloc) {
          bloc.add(
            const LoadExercises(
              trainingSessionId: 'session-1',
              isOrganiser: true,
            ),
          );
          return Future.delayed(
            Duration.zero,
            () => bloc.add(
              const AddExercise(
                trainingSessionId: 'session-1',
                name: 'New Exercise',
                description: 'Description',
                durationMinutes: 20,
              ),
            ),
          );
        },
        skip: 2, // skip ExercisesLoading + ExercisesLoaded from LoadExercises
        expect: () => [
          const ExerciseAdding(),
          const ExerciseAdded(exerciseId: 'exercise-3'),
          isA<ExercisesLoaded>().having((s) => s.canModify, 'canModify', true),
        ],
        verify: (_) {
          verify(
            () => mockRepository.createExercise('session-1', any()),
          ).called(1);
        },
      );

      blocTest<ExerciseBloc, ExerciseState>(
        'emits [Locked, Loaded] when organiser adds exercise after session starts',
        build: () {
          when(
            () => mockRepository.canModifyExercises('session-1'),
          ).thenAnswer((_) async => false);
          when(
            () => mockRepository.getExercisesForTrainingSession('session-1'),
          ).thenAnswer((_) => Stream.value([]));
          return exerciseBloc;
        },
        act: (bloc) {
          bloc.add(
            const LoadExercises(
              trainingSessionId: 'session-1',
              isOrganiser: true,
            ),
          );
          return Future.delayed(
            Duration.zero,
            () => bloc.add(
              const AddExercise(
                trainingSessionId: 'session-1',
                name: 'Late Exercise',
              ),
            ),
          );
        },
        skip: 2,
        expect: () => [
          const ExercisesLocked(),
          isA<ExercisesLoaded>().having((s) => s.canModify, 'canModify', false),
        ],
        verify: (_) {
          verifyNever(() => mockRepository.createExercise(any(), any()));
        },
      );
    });

    group('UpdateExercise — organiser restrictions', () {
      blocTest<ExerciseBloc, ExerciseState>(
        'emits [Locked, Loaded] when session cannot be modified',
        build: () {
          when(
            () => mockRepository.canModifyExercises('session-1'),
          ).thenAnswer((_) async => false);
          when(
            () => mockRepository.getExercisesForTrainingSession('session-1'),
          ).thenAnswer((_) => Stream.value([]));
          return exerciseBloc;
        },
        act: (bloc) {
          bloc.add(
            const LoadExercises(
              trainingSessionId: 'session-1',
              isOrganiser: true,
            ),
          );
          return Future.delayed(
            Duration.zero,
            () => bloc.add(
              const UpdateExercise(
                trainingSessionId: 'session-1',
                exerciseId: 'exercise-1',
                name: 'Updated Name',
              ),
            ),
          );
        },
        skip: 2,
        expect: () => [
          const ExercisesLocked(),
          isA<ExercisesLoaded>().having((s) => s.canModify, 'canModify', false),
        ],
        verify: (_) {
          verifyNever(
            () => mockRepository.updateExercise(
              any(),
              any(),
              name: any(named: 'name'),
            ),
          );
        },
      );

      blocTest<ExerciseBloc, ExerciseState>(
        'emits [Updating, Updated, Loaded] when organiser updates exercise',
        build: () {
          when(
            () => mockRepository.canModifyExercises('session-1'),
          ).thenAnswer((_) async => true);
          when(
            () => mockRepository.getExercisesForTrainingSession('session-1'),
          ).thenAnswer((_) => Stream.value([]));
          when(
            () => mockRepository.updateExercise(
              'session-1',
              'exercise-1',
              name: any(named: 'name'),
              description: any(named: 'description'),
              durationMinutes: any(named: 'durationMinutes'),
            ),
          ).thenAnswer((_) async {});
          return exerciseBloc;
        },
        act: (bloc) {
          bloc.add(
            const LoadExercises(
              trainingSessionId: 'session-1',
              isOrganiser: true,
            ),
          );
          return Future.delayed(
            Duration.zero,
            () => bloc.add(
              const UpdateExercise(
                trainingSessionId: 'session-1',
                exerciseId: 'exercise-1',
                name: 'Updated Name',
              ),
            ),
          );
        },
        skip: 2,
        expect: () => [
          const ExerciseUpdating(exerciseId: 'exercise-1'),
          const ExerciseUpdated(),
          isA<ExercisesLoaded>().having((s) => s.canModify, 'canModify', true),
        ],
      );
    });

    group('DeleteExercise — organiser restrictions', () {
      blocTest<ExerciseBloc, ExerciseState>(
        'emits [Deleting, Deleted, Loaded] when organiser deletes exercise',
        build: () {
          when(
            () => mockRepository.canModifyExercises('session-1'),
          ).thenAnswer((_) async => true);
          when(
            () => mockRepository.getExercisesForTrainingSession('session-1'),
          ).thenAnswer((_) => Stream.value([]));
          when(
            () => mockRepository.deleteExercise('session-1', 'exercise-1'),
          ).thenAnswer((_) async {});
          return exerciseBloc;
        },
        act: (bloc) {
          bloc.add(
            const LoadExercises(
              trainingSessionId: 'session-1',
              isOrganiser: true,
            ),
          );
          return Future.delayed(
            Duration.zero,
            () => bloc.add(
              const DeleteExercise(
                trainingSessionId: 'session-1',
                exerciseId: 'exercise-1',
              ),
            ),
          );
        },
        skip: 2,
        expect: () => [
          const ExerciseDeleting(exerciseId: 'exercise-1'),
          const ExerciseDeleted(),
          isA<ExercisesLoaded>().having((s) => s.canModify, 'canModify', true),
        ],
      );

      blocTest<ExerciseBloc, ExerciseState>(
        'emits [Locked, Loaded] when session cannot be modified',
        build: () {
          when(
            () => mockRepository.canModifyExercises('session-1'),
          ).thenAnswer((_) async => false);
          when(
            () => mockRepository.getExercisesForTrainingSession('session-1'),
          ).thenAnswer((_) => Stream.value([]));
          return exerciseBloc;
        },
        act: (bloc) {
          bloc.add(
            const LoadExercises(
              trainingSessionId: 'session-1',
              isOrganiser: true,
            ),
          );
          return Future.delayed(
            Duration.zero,
            () => bloc.add(
              const DeleteExercise(
                trainingSessionId: 'session-1',
                exerciseId: 'exercise-1',
              ),
            ),
          );
        },
        skip: 2,
        expect: () => [
          const ExercisesLocked(),
          isA<ExercisesLoaded>().having((s) => s.canModify, 'canModify', false),
        ],
        verify: (_) {
          verifyNever(() => mockRepository.deleteExercise(any(), any()));
        },
      );
    });

    group('RefreshExercises', () {
      blocTest<ExerciseBloc, ExerciseState>(
        'reloads exercises preserving isOrganiser flag',
        build: () {
          when(
            () => mockRepository.canModifyExercises('session-1'),
          ).thenAnswer((_) async => true);
          when(
            () => mockRepository.getExercisesForTrainingSession('session-1'),
          ).thenAnswer((_) => Stream.value(testExercises));
          return exerciseBloc;
        },
        act: (bloc) {
          bloc.add(
            const LoadExercises(
              trainingSessionId: 'session-1',
              isOrganiser: true,
            ),
          );
          return Future.delayed(
            const Duration(milliseconds: 100),
            () => bloc.add(const RefreshExercises()),
          );
        },
        skip: 2,
        expect: () => [
          const ExercisesLoading(),
          isA<ExercisesLoaded>()
              .having((s) => s.isOrganiser, 'isOrganiser', true)
              .having((s) => s.canModify, 'canModify', true),
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
        when(
          () => mockRepository.canModifyExercises('session-1'),
        ).thenAnswer((_) async => true);
        when(
          () => mockRepository.getExercisesForTrainingSession('session-1'),
        ).thenAnswer((_) => Stream.value(testExercises));

        exerciseBloc.add(
          const LoadExercises(
            trainingSessionId: 'session-1',
            isOrganiser: true,
          ),
        );

        await Future.delayed(const Duration(milliseconds: 100));
        await exerciseBloc.close();

        expect(exerciseBloc.isClosed, isTrue);
      });
    });

    group('Error handling', () {
      blocTest<ExerciseBloc, ExerciseState>(
        'provides friendly error message for all error types',
        build: () {
          when(
            () => mockRepository.canModifyExercises('session-1'),
          ).thenThrow(Exception('Test error'));
          return exerciseBloc;
        },
        act: (bloc) => bloc.add(
          const LoadExercises(
            trainingSessionId: 'session-1',
            isOrganiser: true,
          ),
        ),
        expect: () => [
          const ExercisesLoading(),
          isA<ExerciseError>().having((s) => s.message, 'message', isNotEmpty),
        ],
      );
    });
  });
}
