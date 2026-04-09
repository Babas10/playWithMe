// Validates ExerciseBloc manages exercise state within training sessions.

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/data/models/exercise_model.dart';
import '../../../../../core/domain/exceptions/repository_exceptions.dart';
import '../../../../../core/domain/repositories/exercise_repository.dart';
import '../../../../../core/utils/error_messages.dart';
import 'exercise_event.dart';
import 'exercise_state.dart';

class ExerciseBloc extends Bloc<ExerciseEvent, ExerciseState> {
  final ExerciseRepository _exerciseRepository;

  String? _currentSessionId;
  List<ExerciseModel> _currentExercises = [];
  bool _canModify = true;
  bool _isOrganiser = false;

  ExerciseBloc({required ExerciseRepository exerciseRepository})
    : _exerciseRepository = exerciseRepository,
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
      _isOrganiser = event.isOrganiser;

      // Check if the session time allows modifications
      final canModifyByTime = await _exerciseRepository.canModifyExercises(
        event.trainingSessionId,
      );

      // Can modify only when organiser AND session hasn't started
      _canModify = _isOrganiser && canModifyByTime;

      await emit.forEach<List<ExerciseModel>>(
        _exerciseRepository.getExercisesForTrainingSession(
          event.trainingSessionId,
        ),
        onData: (exercises) {
          _currentExercises = exercises;
          return ExercisesLoaded(
            exercises: exercises,
            canModify: _canModify,
            isOrganiser: _isOrganiser,
          );
        },
        onError: (error, stackTrace) {
          if (error is ExerciseException) {
            return ExerciseError(message: error.message);
          }
          return ExerciseError(
            message: ErrorMessages.getErrorMessage(error as Exception).$1,
          );
        },
      );
    } on ExerciseException catch (e) {
      emit(ExerciseError(message: e.message));
    } catch (e) {
      emit(
        ExerciseError(
          message: ErrorMessages.getErrorMessage(e as Exception).$1,
        ),
      );
    }
  }

  Future<void> _onAddExercise(
    AddExercise event,
    Emitter<ExerciseState> emit,
  ) async {
    try {
      // Organiser check — must be before any write attempt
      if (!_isOrganiser) {
        emit(const ExercisePermissionDenied());
        emit(
          ExercisesLoaded(
            exercises: _currentExercises,
            canModify: false,
            isOrganiser: false,
          ),
        );
        return;
      }

      // Time-based check
      final canModifyByTime = await _exerciseRepository.canModifyExercises(
        event.trainingSessionId,
      );

      if (!canModifyByTime) {
        emit(const ExercisesLocked());
        emit(
          ExercisesLoaded(
            exercises: _currentExercises,
            canModify: false,
            isOrganiser: _isOrganiser,
          ),
        );
        return;
      }

      emit(const ExerciseAdding());

      final newExercise = ExerciseModel(
        id: '',
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

      emit(
        ExercisesLoaded(
          exercises: _currentExercises,
          canModify: _canModify,
          isOrganiser: _isOrganiser,
        ),
      );
    } on ExerciseException catch (e) {
      emit(ExerciseError(message: e.message));
      emit(
        ExercisesLoaded(
          exercises: _currentExercises,
          canModify: _canModify,
          isOrganiser: _isOrganiser,
        ),
      );
    } catch (e) {
      emit(
        ExerciseError(
          message: ErrorMessages.getErrorMessage(e as Exception).$1,
        ),
      );
      emit(
        ExercisesLoaded(
          exercises: _currentExercises,
          canModify: _canModify,
          isOrganiser: _isOrganiser,
        ),
      );
    }
  }

  Future<void> _onUpdateExercise(
    UpdateExercise event,
    Emitter<ExerciseState> emit,
  ) async {
    try {
      if (!_isOrganiser) {
        emit(const ExercisePermissionDenied());
        emit(
          ExercisesLoaded(
            exercises: _currentExercises,
            canModify: false,
            isOrganiser: false,
          ),
        );
        return;
      }

      final canModifyByTime = await _exerciseRepository.canModifyExercises(
        event.trainingSessionId,
      );

      if (!canModifyByTime) {
        emit(const ExercisesLocked());
        emit(
          ExercisesLoaded(
            exercises: _currentExercises,
            canModify: false,
            isOrganiser: _isOrganiser,
          ),
        );
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

      emit(
        ExercisesLoaded(
          exercises: _currentExercises,
          canModify: _canModify,
          isOrganiser: _isOrganiser,
        ),
      );
    } on ExerciseException catch (e) {
      emit(ExerciseError(message: e.message));
      emit(
        ExercisesLoaded(
          exercises: _currentExercises,
          canModify: _canModify,
          isOrganiser: _isOrganiser,
        ),
      );
    } catch (e) {
      emit(
        ExerciseError(
          message: ErrorMessages.getErrorMessage(e as Exception).$1,
        ),
      );
      emit(
        ExercisesLoaded(
          exercises: _currentExercises,
          canModify: _canModify,
          isOrganiser: _isOrganiser,
        ),
      );
    }
  }

  Future<void> _onDeleteExercise(
    DeleteExercise event,
    Emitter<ExerciseState> emit,
  ) async {
    try {
      if (!_isOrganiser) {
        emit(const ExercisePermissionDenied());
        emit(
          ExercisesLoaded(
            exercises: _currentExercises,
            canModify: false,
            isOrganiser: false,
          ),
        );
        return;
      }

      final canModifyByTime = await _exerciseRepository.canModifyExercises(
        event.trainingSessionId,
      );

      if (!canModifyByTime) {
        emit(const ExercisesLocked());
        emit(
          ExercisesLoaded(
            exercises: _currentExercises,
            canModify: false,
            isOrganiser: _isOrganiser,
          ),
        );
        return;
      }

      emit(ExerciseDeleting(exerciseId: event.exerciseId));

      await _exerciseRepository.deleteExercise(
        event.trainingSessionId,
        event.exerciseId,
      );

      emit(const ExerciseDeleted());

      emit(
        ExercisesLoaded(
          exercises: _currentExercises,
          canModify: _canModify,
          isOrganiser: _isOrganiser,
        ),
      );
    } on ExerciseException catch (e) {
      emit(ExerciseError(message: e.message));
      emit(
        ExercisesLoaded(
          exercises: _currentExercises,
          canModify: _canModify,
          isOrganiser: _isOrganiser,
        ),
      );
    } catch (e) {
      emit(
        ExerciseError(
          message: ErrorMessages.getErrorMessage(e as Exception).$1,
        ),
      );
      emit(
        ExercisesLoaded(
          exercises: _currentExercises,
          canModify: _canModify,
          isOrganiser: _isOrganiser,
        ),
      );
    }
  }

  Future<void> _onRefreshExercises(
    RefreshExercises event,
    Emitter<ExerciseState> emit,
  ) async {
    if (_currentSessionId != null) {
      add(
        LoadExercises(
          trainingSessionId: _currentSessionId!,
          isOrganiser: _isOrganiser,
        ),
      );
    }
  }
}
