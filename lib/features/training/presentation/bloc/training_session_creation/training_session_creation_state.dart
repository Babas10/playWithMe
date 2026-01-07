// Validates CreateTrainingSessionBloc states for tracking training session creation form state and validation.

import '../../../../../core/data/models/training_session_model.dart';
import '../../../../../core/presentation/bloc/base_bloc_state.dart';

abstract class TrainingSessionCreationState extends BaseBlocState {
  const TrainingSessionCreationState();
}

/// Initial state
class TrainingSessionCreationInitial extends TrainingSessionCreationState
    implements InitialState {
  const TrainingSessionCreationInitial();
}

/// State when form is being filled
class TrainingSessionCreationFormState extends TrainingSessionCreationState {
  final String? groupId;
  final String? groupName;
  final DateTime? startTime;
  final DateTime? endTime;
  final String? locationName;
  final String? address;
  final String title;
  final String? description;
  final int maxParticipants;
  final int minParticipants;
  final String? notes;

  // Validation errors
  final String? groupError;
  final String? startTimeError;
  final String? endTimeError;
  final String? locationError;
  final String? titleError;
  final String? participantsError;

  // Form validity
  final bool isValid;

  const TrainingSessionCreationFormState({
    this.groupId,
    this.groupName,
    this.startTime,
    this.endTime,
    this.locationName,
    this.address,
    this.title = '',
    this.description,
    this.maxParticipants = 12,
    this.minParticipants = 4,
    this.notes,
    this.groupError,
    this.startTimeError,
    this.endTimeError,
    this.locationError,
    this.titleError,
    this.participantsError,
    this.isValid = false,
  });

  TrainingSessionCreationFormState copyWith({
    String? groupId,
    String? groupName,
    DateTime? startTime,
    DateTime? endTime,
    String? locationName,
    String? address,
    String? title,
    String? description,
    int? maxParticipants,
    int? minParticipants,
    String? notes,
    String? groupError,
    String? startTimeError,
    String? endTimeError,
    String? locationError,
    String? titleError,
    String? participantsError,
    bool? isValid,
  }) {
    return TrainingSessionCreationFormState(
      groupId: groupId ?? this.groupId,
      groupName: groupName ?? this.groupName,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      locationName: locationName ?? this.locationName,
      address: address ?? this.address,
      title: title ?? this.title,
      description: description ?? this.description,
      maxParticipants: maxParticipants ?? this.maxParticipants,
      minParticipants: minParticipants ?? this.minParticipants,
      notes: notes ?? this.notes,
      groupError: groupError,
      startTimeError: startTimeError,
      endTimeError: endTimeError,
      locationError: locationError,
      titleError: titleError,
      participantsError: participantsError,
      isValid: isValid ?? this.isValid,
    );
  }

  @override
  List<Object?> get props => [
        groupId,
        groupName,
        startTime,
        endTime,
        locationName,
        address,
        title,
        description,
        maxParticipants,
        minParticipants,
        notes,
        groupError,
        startTimeError,
        endTimeError,
        locationError,
        titleError,
        participantsError,
        isValid,
      ];
}

/// State when submitting the training session
class TrainingSessionCreationSubmitting extends TrainingSessionCreationState
    implements LoadingState {
  const TrainingSessionCreationSubmitting();
}

/// State when training session creation succeeds
class TrainingSessionCreationSuccess extends TrainingSessionCreationState
    implements SuccessState {
  final String sessionId;
  final TrainingSessionModel session;

  const TrainingSessionCreationSuccess({
    required this.sessionId,
    required this.session,
  });

  @override
  List<Object?> get props => [sessionId, session];
}

/// State when training session creation fails
class TrainingSessionCreationError extends TrainingSessionCreationState
    implements ErrorState {
  @override
  final String message;
  @override
  final String? errorCode;
  @override
  final bool isRetryable;

  const TrainingSessionCreationError({
    required this.message,
    this.errorCode,
    this.isRetryable = true,
  });

  @override
  List<Object?> get props => [message, errorCode, isRetryable];
}
