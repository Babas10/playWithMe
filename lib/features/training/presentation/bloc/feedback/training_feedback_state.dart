// States for training session feedback management

import 'package:equatable/equatable.dart';

import '../../../../../core/domain/repositories/training_feedback_repository.dart';

abstract class TrainingFeedbackState extends Equatable {
  const TrainingFeedbackState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any feedback operations
class FeedbackInitial extends TrainingFeedbackState {
  const FeedbackInitial();
}

/// State when submitting feedback
class SubmittingFeedback extends TrainingFeedbackState {
  final String trainingSessionId;

  const SubmittingFeedback(this.trainingSessionId);

  @override
  List<Object?> get props => [trainingSessionId];
}

/// State when feedback has been successfully submitted
class FeedbackSubmitted extends TrainingFeedbackState {
  final String trainingSessionId;
  final String message;

  const FeedbackSubmitted({
    required this.trainingSessionId,
    this.message = 'Thank you for your feedback!',
  });

  @override
  List<Object?> get props => [trainingSessionId, message];
}

/// State when loading aggregated feedback
class LoadingAggregatedFeedback extends TrainingFeedbackState {
  final String trainingSessionId;

  const LoadingAggregatedFeedback(this.trainingSessionId);

  @override
  List<Object?> get props => [trainingSessionId];
}

/// State when aggregated feedback has been loaded
class AggregatedFeedbackLoaded extends TrainingFeedbackState {
  final FeedbackAggregation aggregation;
  final bool hasUserSubmitted;

  const AggregatedFeedbackLoaded({
    required this.aggregation,
    this.hasUserSubmitted = false,
  });

  @override
  List<Object?> get props => [aggregation, hasUserSubmitted];
}

/// State when checking if user has submitted feedback
class CheckingFeedbackSubmission extends TrainingFeedbackState {
  final String trainingSessionId;

  const CheckingFeedbackSubmission(this.trainingSessionId);

  @override
  List<Object?> get props => [trainingSessionId];
}

/// State when feedback submission check is complete
class FeedbackSubmissionChecked extends TrainingFeedbackState {
  final String trainingSessionId;
  final bool hasSubmitted;

  const FeedbackSubmissionChecked({
    required this.trainingSessionId,
    required this.hasSubmitted,
  });

  @override
  List<Object?> get props => [trainingSessionId, hasSubmitted];
}

/// State when an error occurs during feedback operations
class FeedbackError extends TrainingFeedbackState {
  final String message;
  final String? trainingSessionId;

  const FeedbackError({
    required this.message,
    this.trainingSessionId,
  });

  @override
  List<Object?> get props => [message, trainingSessionId];
}
