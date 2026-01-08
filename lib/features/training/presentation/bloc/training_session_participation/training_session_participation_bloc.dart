// Manages training session participation state including join/leave operations

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/data/models/training_session_participant_model.dart';
import '../../../../../core/domain/repositories/training_session_repository.dart';
import 'training_session_participation_event.dart';
import 'training_session_participation_state.dart';

class TrainingSessionParticipationBloc extends Bloc<
    TrainingSessionParticipationEvent, TrainingSessionParticipationState> {
  final TrainingSessionRepository _trainingSessionRepository;
  StreamSubscription? _participantsSubscription;

  TrainingSessionParticipationBloc({
    required TrainingSessionRepository trainingSessionRepository,
  })  : _trainingSessionRepository = trainingSessionRepository,
        super(const ParticipationInitial()) {
    on<LoadParticipants>(_onLoadParticipants);
    on<JoinTrainingSession>(_onJoinTrainingSession);
    on<LeaveTrainingSession>(_onLeaveTrainingSession);
    on<_ParticipantsUpdated>(_onParticipantsUpdated);
    on<_ParticipantsError>(_onParticipantsError);
  }

  Future<void> _onLoadParticipants(
    LoadParticipants event,
    Emitter<TrainingSessionParticipationState> emit,
  ) async {
    emit(const ParticipationLoading());

    try {
      // Cancel any existing subscription
      await _participantsSubscription?.cancel();

      // Subscribe to participants stream
      _participantsSubscription = _trainingSessionRepository
          .getTrainingSessionParticipantsStream(event.sessionId)
          .listen(
        (participants) {
          // Only emit if we're still in a loading or loaded state
          if (state is ParticipationLoading || state is ParticipationLoaded) {
            add(_ParticipantsUpdated(
              participants: participants,
              participantCount: participants.length,
            ));
          }
        },
        onError: (error) {
          if (state is ParticipationLoading || state is ParticipationLoaded) {
            add(_ParticipantsError(
              message: _getErrorMessage(error),
              errorCode: _getErrorCode(error),
            ));
          }
        },
      );
    } catch (e) {
      emit(ParticipationError(
        message: _getErrorMessage(e),
        errorCode: _getErrorCode(e),
      ));
    }
  }

  Future<void> _onJoinTrainingSession(
    JoinTrainingSession event,
    Emitter<TrainingSessionParticipationState> emit,
  ) async {
    emit(JoiningSession(event.sessionId));

    try {
      await _trainingSessionRepository.joinTrainingSession(event.sessionId);

      emit(JoinedSession(sessionId: event.sessionId));

      // Reload participants to reflect the change
      add(LoadParticipants(event.sessionId));
    } on FirebaseFunctionsException catch (e) {
      emit(ParticipationError(
        message: _getFriendlyErrorMessage(e),
        errorCode: e.code,
      ));
    } on FirebaseException catch (e) {
      emit(ParticipationError(
        message: _getFirestoreErrorMessage(e),
        errorCode: e.code,
      ));
    } catch (e) {
      emit(ParticipationError(
        message: 'Failed to join training session. Please try again.',
      ));
    }
  }

  Future<void> _onLeaveTrainingSession(
    LeaveTrainingSession event,
    Emitter<TrainingSessionParticipationState> emit,
  ) async {
    emit(LeavingSession(event.sessionId));

    try {
      await _trainingSessionRepository.leaveTrainingSession(event.sessionId);

      emit(LeftSession(sessionId: event.sessionId));

      // Reload participants to reflect the change
      add(LoadParticipants(event.sessionId));
    } on FirebaseFunctionsException catch (e) {
      emit(ParticipationError(
        message: _getFriendlyErrorMessage(e),
        errorCode: e.code,
      ));
    } on FirebaseException catch (e) {
      emit(ParticipationError(
        message: _getFirestoreErrorMessage(e),
        errorCode: e.code,
      ));
    } catch (e) {
      emit(ParticipationError(
        message: 'Failed to leave training session. Please try again.',
      ));
    }
  }

  /// Internal event to handle participants stream updates
  void _onParticipantsUpdated(
    _ParticipantsUpdated event,
    Emitter<TrainingSessionParticipationState> emit,
  ) {
    emit(ParticipationLoaded(
      participants: event.participants,
      participantCount: event.participantCount,
    ));
  }

  /// Internal event to handle participants stream errors
  void _onParticipantsError(
    _ParticipantsError event,
    Emitter<TrainingSessionParticipationState> emit,
  ) {
    emit(ParticipationError(
      message: event.message,
      errorCode: event.errorCode,
    ));
  }

  /// Get friendly error message from Firebase Functions exception
  String _getFriendlyErrorMessage(FirebaseFunctionsException e) {
    switch (e.code) {
      case 'unauthenticated':
        return 'You must be logged in to join a training session';
      case 'permission-denied':
        return 'You don\'t have permission to join this session';
      case 'not-found':
        return 'Training session not found';
      case 'already-exists':
        return 'You have already joined this training session';
      case 'failed-precondition':
        return e.message ?? 'Cannot complete this action';
      case 'internal':
        return 'An error occurred. Please try again later';
      default:
        return e.message ?? 'An unexpected error occurred';
    }
  }

  /// Get friendly error message from Firestore exception
  String _getFirestoreErrorMessage(FirebaseException e) {
    switch (e.code) {
      case 'permission-denied':
        return 'You don\'t have permission to access this data';
      case 'unavailable':
        return 'Service temporarily unavailable. Please try again';
      case 'not-found':
        return 'Training session not found';
      default:
        return 'An error occurred while loading participants';
    }
  }

  /// Get generic error message
  String _getErrorMessage(dynamic error) {
    if (error is FirebaseFunctionsException) {
      return _getFriendlyErrorMessage(error);
    } else if (error is FirebaseException) {
      return _getFirestoreErrorMessage(error);
    }
    return 'An unexpected error occurred';
  }

  /// Get error code from exception
  String? _getErrorCode(dynamic error) {
    if (error is FirebaseFunctionsException) {
      return error.code;
    } else if (error is FirebaseException) {
      return error.code;
    }
    return null;
  }

  @override
  Future<void> close() {
    _participantsSubscription?.cancel();
    return super.close();
  }
}

// Internal events for stream handling
class _ParticipantsUpdated extends TrainingSessionParticipationEvent {
  final List<TrainingSessionParticipantModel> participants;
  final int participantCount;

  const _ParticipantsUpdated({
    required this.participants,
    required this.participantCount,
  });

  @override
  List<Object?> get props => [participants, participantCount];
}

class _ParticipantsError extends TrainingSessionParticipationEvent {
  final String message;
  final String? errorCode;

  const _ParticipantsError({
    required this.message,
    this.errorCode,
  });

  @override
  List<Object?> get props => [message, errorCode];
}
