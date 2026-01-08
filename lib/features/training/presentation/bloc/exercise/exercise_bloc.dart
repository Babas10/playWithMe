// Validates ExerciseBloc manages exercise state within training sessions.

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/data/models/exercise_model.dart';
import '../../../../../core/domain/repositories/exercise_repository.dart';
import '../../../../../core/utils/error_messages.dart';
import 'exercise_event.dart';
import 'exercise_state.dart';

class ExerciseBloc extends Bloc<ExerciseEvent, ExerciseState> {
  final ExerciseRepository _exerciseRepository;

  String? _currentSessionId;
  List<ExerciseModel> _currentExercises = [];
  bool _canModify = true;

  ExerciseBloc({
    required ExerciseRepository exerciseRepository,
  })  : _exerciseRepository = exerciseRepository,
        super(const ExerciseInitial()) {
    on<LoadExercises>(_onLoadExercises);
    on<AddExercise>(_onAddExercise);
    on<UpdateExercise>(_onUpdateExercise);
    on<DeleteExercise>(_onDeleteExercise);
    on<RefreshExercises>(_onRefreshExercises);
  }

  Future<void> _onLoadExercises(
    LoadExercises event,
    Emitter<ExerciseState> emit,
  ) async {
    try {
      emit(const ExercisesLoading());

      _currentSessionId = event.trainingSessionId;

      // Check if exercises can be modified
      _canModify = await _exerciseRepository.canModifyExercises(
        event.trainingSessionId,
      );

      // Subscribe to exercises stream using emit.forEach for proper async handling
      // emit.forEach automatically handles stream lifecycle and cancellation
      await emit.forEach<List<ExerciseModel>>(
        _exerciseRepository.getExercisesForTrainingSession(event.trainingSessionId),
        onData: (exercises) {
          _currentExercises = exercises;
          return ExercisesLoaded(
            exercises: exercises,
            canModify: _canModify,
          );
        },
        onError: (error, stackTrace) {
          return ExerciseError(
            message: ErrorMessages.getErrorMessage(error as Exception).$1,
          );
        },
      );
    } catch (e) {
      emit(ExerciseError(
        message: ErrorMessages.getErrorMessage(e as Exception).$1,
      ));
    }
  }

  Future<void> _onAddExercise(
    AddExercise event,
    Emitter<ExerciseState> emit,
  ) async {
    try {
      // Check if modifications are allowed
      final canModify = await _exerciseRepository.canModifyExercises(
        event.trainingSessionId,
      );

      if (!canModify) {
        emit(const ExercisesLocked());
        // Reload exercises to restore previous state
        emit(ExercisesLoaded(
          exercises: _currentExercises,
          canModify: false,
        ));
        return;
      }

      emit(const ExerciseAdding());

      final newExercise = ExerciseModel(
        id: '', // Will be set by repository
        name: event.name,
        description: event.description,
        durationMinutes: event.durationMinutes,
        createdAt: DateTime.now(),
      );

      final exerciseId = await _exerciseRepository.createExercise(
        event.trainingSessionId,
        newExercise,
      );

      emit(ExerciseAdded(exerciseId: exerciseId));

      // Reload exercises to show updated list
      emit(ExercisesLoaded(
        exercises: _currentExercises,
        canModify: _canModify,
      ));
    } catch (e) {
      emit(ExerciseError(
        message: ErrorMessages.getErrorMessage(e as Exception).$1,
      ));
      // Restore previous state after error
      emit(ExercisesLoaded(
        exercises: _currentExercises,
        canModify: _canModify,
      ));
    }
  }

  Future<void> _onUpdateExercise(
    UpdateExercise event,
    Emitter<ExerciseState> emit,
  ) async {
    try {
      // Check if modifications are allowed
      final canModify = await _exerciseRepository.canModifyExercises(
        event.trainingSessionId,
      );

      if (!canModify) {
        emit(const ExercisesLocked());
        // Reload exercises to restore previous state
        emit(ExercisesLoaded(
          exercises: _currentExercises,
          canModify: false,
        ));
        return;
      }

      emit(ExerciseUpdating(exerciseId: event.exerciseId));

      await _exerciseRepository.updateExercise(
        event.trainingSessionId,
        event.exerciseId,
        name: event.name,
        description: event.description,
        durationMinutes: event.durationMinutes,
      );

      emit(const ExerciseUpdated());

      // Reload exercises to show updated list
      emit(ExercisesLoaded(
        exercises: _currentExercises,
        canModify: _canModify,
      ));
    } catch (e) {
      emit(ExerciseError(
        message: ErrorMessages.getErrorMessage(e as Exception).$1,
      ));
      // Restore previous state after error
      emit(ExercisesLoaded(
        exercises: _currentExercises,
        canModify: _canModify,
      ));
    }
  }

  Future<void> _onDeleteExercise(
    DeleteExercise event,
    Emitter<ExerciseState> emit,
  ) async {
    try {
      // Check if modifications are allowed
      final canModify = await _exerciseRepository.canModifyExercises(
        event.trainingSessionId,
      );

      if (!canModify) {
        emit(const ExercisesLocked());
        // Reload exercises to restore previous state
        emit(ExercisesLoaded(
          exercises: _currentExercises,
          canModify: false,
        ));
        return;
      }

      emit(ExerciseDeleting(exerciseId: event.exerciseId));

      await _exerciseRepository.deleteExercise(
        event.trainingSessionId,
        event.exerciseId,
      );

      emit(const ExerciseDeleted());

      // Reload exercises to show updated list
      emit(ExercisesLoaded(
        exercises: _currentExercises,
        canModify: _canModify,
      ));
    } catch (e) {
      emit(ExerciseError(
        message: ErrorMessages.getErrorMessage(e as Exception).$1,
      ));
      // Restore previous state after error
      emit(ExercisesLoaded(
        exercises: _currentExercises,
        canModify: _canModify,
      ));
    }
  }

  Future<void> _onRefreshExercises(
    RefreshExercises event,
    Emitter<ExerciseState> emit,
  ) async {
    if (_currentSessionId != null) {
      add(LoadExercises(trainingSessionId: _currentSessionId!));
    }
  }
}
