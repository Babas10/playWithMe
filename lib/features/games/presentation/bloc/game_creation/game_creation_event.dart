// Validates GameCreationBloc events for managing game creation form state.

import '../../../../../core/data/models/game_model.dart';
import '../../../../../core/presentation/bloc/base_bloc_event.dart';

abstract class GameCreationEvent extends BaseBlocEvent {
  const GameCreationEvent();
}

/// Event to select a group for the game
class SelectGroup extends GameCreationEvent {
  final String groupId;
  final String groupName;

  const SelectGroup({
    required this.groupId,
    required this.groupName,
  });

  @override
  List<Object?> get props => [groupId, groupName];
}

/// Event to set the game date and time
class SetDateTime extends GameCreationEvent {
  final DateTime dateTime;

  const SetDateTime({required this.dateTime});

  @override
  List<Object?> get props => [dateTime];
}

/// Event to set the game location
class SetLocation extends GameCreationEvent {
  final String locationName;
  final String? address;

  const SetLocation({
    required this.locationName,
    this.address,
  });

  @override
  List<Object?> get props => [locationName, address];
}

/// Event to set the game title
class SetTitle extends GameCreationEvent {
  final String title;

  const SetTitle({required this.title});

  @override
  List<Object?> get props => [title];
}

/// Event to set the game description
class SetDescription extends GameCreationEvent {
  final String? description;

  const SetDescription({this.description});

  @override
  List<Object?> get props => [description];
}

/// Event to set the maximum number of players
class SetMaxPlayers extends GameCreationEvent {
  final int maxPlayers;

  const SetMaxPlayers({required this.maxPlayers});

  @override
  List<Object?> get props => [maxPlayers];
}

/// Event to set the minimum number of players
class SetMinPlayers extends GameCreationEvent {
  final int minPlayers;

  const SetMinPlayers({required this.minPlayers});

  @override
  List<Object?> get props => [minPlayers];
}

/// Event to set the game type
class SetGameType extends GameCreationEvent {
  final GameType? gameType;

  const SetGameType({this.gameType});

  @override
  List<Object?> get props => [gameType];
}

/// Event to set the skill level
class SetSkillLevel extends GameCreationEvent {
  final GameSkillLevel? skillLevel;

  const SetSkillLevel({this.skillLevel});

  @override
  List<Object?> get props => [skillLevel];
}

/// Event to validate the form
class ValidateForm extends GameCreationEvent {
  const ValidateForm();
}

/// Event to submit the form and create the game
class SubmitGame extends GameCreationEvent {
  final String createdBy;

  const SubmitGame({required this.createdBy});

  @override
  List<Object?> get props => [createdBy];
}

/// Event to reset the form
class ResetForm extends GameCreationEvent {
  const ResetForm();
}
