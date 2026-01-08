// Validates ExerciseBloc events for managing exercises within training sessions.

import '../../../../../core/presentation/bloc/base_bloc_event.dart';

abstract class ExerciseEvent extends BaseBlocEvent {
  const ExerciseEvent();
}

/// Event to load exercises for a training session
class LoadExercises extends ExerciseEvent {
  final String trainingSessionId;

  const LoadExercises({required this.trainingSessionId});

  @override
  List<Object?> get props => [trainingSessionId];
}

/// Event to add a new exercise
class AddExercise extends ExerciseEvent {
  final String trainingSessionId;
  final String name;
  final String? description;
  final int? durationMinutes;

  const AddExercise({
    required this.trainingSessionId,
    required this.name,
    this.description,
    this.durationMinutes,
  });

  @override
  List<Object?> get props => [
        trainingSessionId,
        name,
        description,
        durationMinutes,
      ];
}

/// Event to update an existing exercise
class UpdateExercise extends ExerciseEvent {
  final String trainingSessionId;
  final String exerciseId;
  final String? name;
  final String? description;
  final int? durationMinutes;

  const UpdateExercise({
    required this.trainingSessionId,
    required this.exerciseId,
    this.name,
    this.description,
    this.durationMinutes,
  });

  @override
  List<Object?> get props => [
        trainingSessionId,
        exerciseId,
        name,
        description,
        durationMinutes,
      ];
}

/// Event to delete an exercise
class DeleteExercise extends ExerciseEvent {
  final String trainingSessionId;
  final String exerciseId;

  const DeleteExercise({
    required this.trainingSessionId,
    required this.exerciseId,
  });

  @override
  List<Object?> get props => [trainingSessionId, exerciseId];
}

/// Event to refresh exercise list
class RefreshExercises extends ExerciseEvent {
  const RefreshExercises();

  @override
  List<Object?> get props => [];
}
