// Events for training session feedback management

import 'package:equatable/equatable.dart';

abstract class TrainingFeedbackEvent extends Equatable {
  const TrainingFeedbackEvent();

  @override
  List<Object?> get props => [];
}

/// Event to submit feedback for a training session
class SubmitFeedback extends TrainingFeedbackEvent {
  final String trainingSessionId;
  final int exercisesQuality;
  final int trainingIntensity;
  final int coachingClarity;
  final String? comment;

  const SubmitFeedback({
    required this.trainingSessionId,
    required this.exercisesQuality,
    required this.trainingIntensity,
    required this.coachingClarity,
    this.comment,
  });

  @override
  List<Object?> get props => [trainingSessionId, exercisesQuality, trainingIntensity, coachingClarity, comment];
}

/// Event to load aggregated feedback for a training session
class LoadAggregatedFeedback extends TrainingFeedbackEvent {
  final String trainingSessionId;

  const LoadAggregatedFeedback(this.trainingSessionId);

  @override
  List<Object?> get props => [trainingSessionId];
}

/// Event to check if user has submitted feedback
class CheckFeedbackSubmission extends TrainingFeedbackEvent {
  final String trainingSessionId;

  const CheckFeedbackSubmission(this.trainingSessionId);

  @override
  List<Object?> get props => [trainingSessionId];
}

/// Event to reset feedback state
class ResetFeedbackState extends TrainingFeedbackEvent {
  const ResetFeedbackState();
}
