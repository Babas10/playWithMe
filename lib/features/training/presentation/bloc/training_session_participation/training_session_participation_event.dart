// Events for training session participation management

import 'package:equatable/equatable.dart';

abstract class TrainingSessionParticipationEvent extends Equatable {
  const TrainingSessionParticipationEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load participants for a training session
class LoadParticipants extends TrainingSessionParticipationEvent {
  final String sessionId;

  const LoadParticipants(this.sessionId);

  @override
  List<Object?> get props => [sessionId];
}

/// Event to join a training session
class JoinTrainingSession extends TrainingSessionParticipationEvent {
  final String sessionId;

  const JoinTrainingSession(this.sessionId);

  @override
  List<Object?> get props => [sessionId];
}

/// Event to leave a training session
class LeaveTrainingSession extends TrainingSessionParticipationEvent {
  final String sessionId;

  const LeaveTrainingSession(this.sessionId);

  @override
  List<Object?> get props => [sessionId];
}
