// States for training session participation management

import 'package:equatable/equatable.dart';

import '../../../../../core/data/models/training_session_participant_model.dart';

abstract class TrainingSessionParticipationState extends Equatable {
  const TrainingSessionParticipationState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any participation data is loaded
class ParticipationInitial extends TrainingSessionParticipationState {
  const ParticipationInitial();
}

/// State when participants are being loaded
class ParticipationLoading extends TrainingSessionParticipationState {
  const ParticipationLoading();
}

/// State when participants have been successfully loaded
class ParticipationLoaded extends TrainingSessionParticipationState {
  final List<TrainingSessionParticipantModel> participants;
  final int participantCount;

  const ParticipationLoaded({
    required this.participants,
    required this.participantCount,
  });

  @override
  List<Object?> get props => [participants, participantCount];
}

/// State when user is joining a training session
class JoiningSession extends TrainingSessionParticipationState {
  final String sessionId;

  const JoiningSession(this.sessionId);

  @override
  List<Object?> get props => [sessionId];
}

/// State when user has successfully joined
class JoinedSession extends TrainingSessionParticipationState {
  final String sessionId;
  final String message;

  const JoinedSession({
    required this.sessionId,
    this.message = 'Successfully joined training session',
  });

  @override
  List<Object?> get props => [sessionId, message];
}

/// State when user is leaving a training session
class LeavingSession extends TrainingSessionParticipationState {
  final String sessionId;

  const LeavingSession(this.sessionId);

  @override
  List<Object?> get props => [sessionId];
}

/// State when user has successfully left
class LeftSession extends TrainingSessionParticipationState {
  final String sessionId;
  final String message;

  const LeftSession({
    required this.sessionId,
    this.message = 'Successfully left training session',
  });

  @override
  List<Object?> get props => [sessionId, message];
}

/// State when an error occurs during participation operations
class ParticipationError extends TrainingSessionParticipationState {
  final String message;
  final String? errorCode;

  const ParticipationError({
    required this.message,
    this.errorCode,
  });

  @override
  List<Object?> get props => [message, errorCode];
}
