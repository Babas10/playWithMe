// Manages training session feedback state including submission and aggregated viewing

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/domain/repositories/training_feedback_repository.dart';
import 'training_feedback_event.dart';
import 'training_feedback_state.dart';

class TrainingFeedbackBloc
    extends Bloc<TrainingFeedbackEvent, TrainingFeedbackState> {
  final TrainingFeedbackRepository _feedbackRepository;
  StreamSubscription? _aggregatedFeedbackSubscription;

  TrainingFeedbackBloc({
    required TrainingFeedbackRepository feedbackRepository,
  })  : _feedbackRepository = feedbackRepository,
        super(const FeedbackInitial()) {
    on<SubmitFeedback>(_onSubmitFeedback);
    on<LoadAggregatedFeedback>(_onLoadAggregatedFeedback);
    on<CheckFeedbackSubmission>(_onCheckFeedbackSubmission);
    on<ResetFeedbackState>(_onResetFeedbackState);
    on<_AggregatedFeedbackUpdated>(_onAggregatedFeedbackUpdated);
    on<_AggregatedFeedbackError>(_onAggregatedFeedbackError);
  }

  Future<void> _onSubmitFeedback(
    SubmitFeedback event,
    Emitter<TrainingFeedbackState> emit,
  ) async {
    emit(SubmittingFeedback(event.trainingSessionId));

    try {
      await _feedbackRepository.submitFeedback(
        trainingSessionId: event.trainingSessionId,
        rating: event.rating,
        comment: event.comment,
      );

      emit(FeedbackSubmitted(trainingSessionId: event.trainingSessionId));
    } on FirebaseFunctionsException catch (e) {
      emit(FeedbackError(
        message: _getFriendlyErrorMessage(e),
        trainingSessionId: event.trainingSessionId,
      ));
    } on FirebaseException catch (e) {
      emit(FeedbackError(
        message: _getFirestoreErrorMessage(e),
        trainingSessionId: event.trainingSessionId,
      ));
    } catch (e) {
      emit(FeedbackError(
        message: 'Failed to submit feedback. Please try again.',
        trainingSessionId: event.trainingSessionId,
      ));
    }
  }

  Future<void> _onLoadAggregatedFeedback(
    LoadAggregatedFeedback event,
    Emitter<TrainingFeedbackState> emit,
  ) async {
    emit(LoadingAggregatedFeedback(event.trainingSessionId));

    try {
      // Cancel any existing subscription
      await _aggregatedFeedbackSubscription?.cancel();

      // Check if user has submitted feedback (this is separate from aggregated data)
      final hasSubmitted = await _feedbackRepository
          .hasUserSubmittedFeedback(event.trainingSessionId);

      // Subscribe to aggregated feedback stream
      _aggregatedFeedbackSubscription = _feedbackRepository
          .getAggregatedFeedbackStream(event.trainingSessionId)
          .listen(
        (aggregation) {
          // Only emit if we're still in a loading or loaded state
          if (state is LoadingAggregatedFeedback ||
              state is AggregatedFeedbackLoaded) {
            if (aggregation != null) {
              add(_AggregatedFeedbackUpdated(
                aggregation: aggregation,
                hasUserSubmitted: hasSubmitted,
              ));
            }
          }
        },
        onError: (error) {
          if (state is LoadingAggregatedFeedback ||
              state is AggregatedFeedbackLoaded) {
            add(_AggregatedFeedbackError(
              message: _getErrorMessage(error),
            ));
          }
        },
      );
    } catch (e) {
      emit(FeedbackError(
        message: _getErrorMessage(e),
        trainingSessionId: event.trainingSessionId,
      ));
    }
  }

  Future<void> _onCheckFeedbackSubmission(
    CheckFeedbackSubmission event,
    Emitter<TrainingFeedbackState> emit,
  ) async {
    emit(CheckingFeedbackSubmission(event.trainingSessionId));

    try {
      final hasSubmitted = await _feedbackRepository
          .hasUserSubmittedFeedback(event.trainingSessionId);

      emit(FeedbackSubmissionChecked(
        trainingSessionId: event.trainingSessionId,
        hasSubmitted: hasSubmitted,
      ));
    } catch (e) {
      emit(FeedbackError(
        message: 'Failed to check feedback status. Please try again.',
        trainingSessionId: event.trainingSessionId,
      ));
    }
  }

  void _onResetFeedbackState(
    ResetFeedbackState event,
    Emitter<TrainingFeedbackState> emit,
  ) {
    _aggregatedFeedbackSubscription?.cancel();
    emit(const FeedbackInitial());
  }

  /// Internal event to handle aggregated feedback stream updates
  void _onAggregatedFeedbackUpdated(
    _AggregatedFeedbackUpdated event,
    Emitter<TrainingFeedbackState> emit,
  ) {
    emit(AggregatedFeedbackLoaded(
      aggregation: event.aggregation,
      hasUserSubmitted: event.hasUserSubmitted,
    ));
  }

  /// Internal event to handle aggregated feedback stream errors
  void _onAggregatedFeedbackError(
    _AggregatedFeedbackError event,
    Emitter<TrainingFeedbackState> emit,
  ) {
    emit(FeedbackError(message: event.message));
  }

  /// Get friendly error message from FirebaseFunctionsException
  String _getFriendlyErrorMessage(FirebaseFunctionsException exception) {
    switch (exception.code) {
      case 'unauthenticated':
        return 'You must be logged in to submit feedback';
      case 'permission-denied':
        return 'You don\'t have permission to perform this action';
      case 'not-found':
        return 'Training session not found';
      case 'failed-precondition':
        return 'You must be a participant to submit feedback';
      case 'already-exists':
        return 'You have already submitted feedback for this session';
      case 'invalid-argument':
        return exception.message ?? 'Invalid feedback data';
      case 'internal':
        return 'An error occurred. Please try again later';
      default:
        return exception.message ?? 'Failed to submit feedback';
    }
  }

  /// Get friendly error message from FirebaseException
  String _getFirestoreErrorMessage(FirebaseException exception) {
    switch (exception.code) {
      case 'permission-denied':
        return 'You don\'t have permission to access this data';
      case 'unavailable':
        return 'Service temporarily unavailable. Please try again';
      case 'not-found':
        return 'Data not found';
      default:
        return exception.message ?? 'An error occurred';
    }
  }

  /// Get generic error message
  String _getErrorMessage(dynamic error) {
    if (error is FirebaseFunctionsException) {
      return _getFriendlyErrorMessage(error);
    } else if (error is FirebaseException) {
      return _getFirestoreErrorMessage(error);
    } else if (error is Exception) {
      return error.toString().replaceAll('Exception: ', '');
    } else {
      return 'An unexpected error occurred';
    }
  }

  @override
  Future<void> close() {
    _aggregatedFeedbackSubscription?.cancel();
    return super.close();
  }
}

/// Internal event for aggregated feedback updates from stream
class _AggregatedFeedbackUpdated extends TrainingFeedbackEvent {
  final FeedbackAggregation aggregation;
  final bool hasUserSubmitted;

  const _AggregatedFeedbackUpdated({
    required this.aggregation,
    required this.hasUserSubmitted,
  });

  @override
  List<Object?> get props => [aggregation, hasUserSubmitted];
}

/// Internal event for aggregated feedback stream errors
class _AggregatedFeedbackError extends TrainingFeedbackEvent {
  final String message;

  const _AggregatedFeedbackError({required this.message});

  @override
  List<Object?> get props => [message];
}
