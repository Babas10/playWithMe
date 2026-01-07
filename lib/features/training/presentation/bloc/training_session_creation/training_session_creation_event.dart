// Validates CreateTrainingSessionBloc events for managing training session creation form state.

import '../../../../../core/presentation/bloc/base_bloc_event.dart';

abstract class TrainingSessionCreationEvent extends BaseBlocEvent {
  const TrainingSessionCreationEvent();
}

/// Event to select a group for the training session
class SelectTrainingGroup extends TrainingSessionCreationEvent {
  final String groupId;
  final String groupName;

  const SelectTrainingGroup({
    required this.groupId,
    required this.groupName,
  });

  @override
  List<Object?> get props => [groupId, groupName];
}

/// Event to set the training session start time
class SetStartTime extends TrainingSessionCreationEvent {
  final DateTime startTime;

  const SetStartTime({required this.startTime});

  @override
  List<Object?> get props => [startTime];
}

/// Event to set the training session end time
class SetEndTime extends TrainingSessionCreationEvent {
  final DateTime endTime;

  const SetEndTime({required this.endTime});

  @override
  List<Object?> get props => [endTime];
}

/// Event to set the training session location
class SetTrainingLocation extends TrainingSessionCreationEvent {
  final String locationName;
  final String? address;

  const SetTrainingLocation({
    required this.locationName,
    this.address,
  });

  @override
  List<Object?> get props => [locationName, address];
}

/// Event to set the training session title
class SetTrainingTitle extends TrainingSessionCreationEvent {
  final String title;

  const SetTrainingTitle({required this.title});

  @override
  List<Object?> get props => [title];
}

/// Event to set the training session description
class SetTrainingDescription extends TrainingSessionCreationEvent {
  final String? description;

  const SetTrainingDescription({this.description});

  @override
  List<Object?> get props => [description];
}

/// Event to set the maximum number of participants
class SetMaxParticipants extends TrainingSessionCreationEvent {
  final int maxParticipants;

  const SetMaxParticipants({required this.maxParticipants});

  @override
  List<Object?> get props => [maxParticipants];
}

/// Event to set the minimum number of participants
class SetMinParticipants extends TrainingSessionCreationEvent {
  final int minParticipants;

  const SetMinParticipants({required this.minParticipants});

  @override
  List<Object?> get props => [minParticipants];
}

/// Event to set session notes
class SetSessionNotes extends TrainingSessionCreationEvent {
  final String? notes;

  const SetSessionNotes({this.notes});

  @override
  List<Object?> get props => [notes];
}

/// Event to validate the form
class ValidateTrainingForm extends TrainingSessionCreationEvent {
  const ValidateTrainingForm();
}

/// Event to submit the form and create the training session
class SubmitTrainingSession extends TrainingSessionCreationEvent {
  final String createdBy;

  const SubmitTrainingSession({required this.createdBy});

  @override
  List<Object?> get props => [createdBy];
}

/// Event to reset the form
class ResetTrainingForm extends TrainingSessionCreationEvent {
  const ResetTrainingForm();
}
