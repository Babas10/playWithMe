// Validates ExerciseBloc states for managing exercises within training sessions.

import 'package:equatable/equatable.dart';

import '../../../../../core/data/models/exercise_model.dart';

abstract class ExerciseState extends Equatable {
  const ExerciseState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class ExerciseInitial extends ExerciseState {
  const ExerciseInitial();
}

/// Loading exercises
class ExercisesLoading extends ExerciseState {
  const ExercisesLoading();
}

/// Exercises loaded successfully
class ExercisesLoaded extends ExerciseState {
  final List<ExerciseModel> exercises;
  final bool canModify; // Whether exercises can be edited (session hasn't started)

  const ExercisesLoaded({
    required this.exercises,
    required this.canModify,
  });

  @override
  List<Object?> get props => [exercises, canModify];
}

/// Adding a new exercise
class ExerciseAdding extends ExerciseState {
  const ExerciseAdding();
}

/// Exercise added successfully
class ExerciseAdded extends ExerciseState {
  final String exerciseId;

  const ExerciseAdded({required this.exerciseId});

  @override
  List<Object?> get props => [exerciseId];
}

/// Updating an exercise
class ExerciseUpdating extends ExerciseState {
  final String exerciseId;

  const ExerciseUpdating({required this.exerciseId});

  @override
  List<Object?> get props => [exerciseId];
}

/// Exercise updated successfully
class ExerciseUpdated extends ExerciseState {
  const ExerciseUpdated();
}

/// Deleting an exercise
class ExerciseDeleting extends ExerciseState {
  final String exerciseId;

  const ExerciseDeleting({required this.exerciseId});

  @override
  List<Object?> get props => [exerciseId];
}

/// Exercise deleted successfully
class ExerciseDeleted extends ExerciseState {
  const ExerciseDeleted();
}

/// Error state
class ExerciseError extends ExerciseState {
  final String message;

  const ExerciseError({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Session locked state (cannot modify exercises)
class ExercisesLocked extends ExerciseState {
  final String message;

  const ExercisesLocked({
    this.message = 'Cannot modify exercises: Training session has already started',
  });

  @override
  List<Object?> get props => [message];
}
