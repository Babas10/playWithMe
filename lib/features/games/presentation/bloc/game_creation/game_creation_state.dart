// Validates GameCreationBloc states for tracking game creation form state and validation.

import '../../../../../core/data/models/game_model.dart';
import '../../../../../core/presentation/bloc/base_bloc_state.dart';

abstract class GameCreationState extends BaseBlocState {
  const GameCreationState();
}

/// Initial state
class GameCreationInitial extends GameCreationState implements InitialState {
  const GameCreationInitial();
}

/// State when form is being filled
class GameCreationFormState extends GameCreationState {
  final String? groupId;
  final String? groupName;
  final DateTime? dateTime;
  final String? locationName;
  final String? address;
  final String title;
  final String? description;
  final int maxPlayers;
  final int minPlayers;
  final GameType? gameType;
  final GameSkillLevel? skillLevel;

  // Validation errors
  final String? groupError;
  final String? dateTimeError;
  final String? locationError;
  final String? titleError;
  final String? playersError;

  // Form validity
  final bool isValid;

  const GameCreationFormState({
    this.groupId,
    this.groupName,
    this.dateTime,
    this.locationName,
    this.address,
    this.title = '',
    this.description,
    this.maxPlayers = 4,
    this.minPlayers = 2,
    this.gameType,
    this.skillLevel,
    this.groupError,
    this.dateTimeError,
    this.locationError,
    this.titleError,
    this.playersError,
    this.isValid = false,
  });

  GameCreationFormState copyWith({
    String? groupId,
    String? groupName,
    DateTime? dateTime,
    String? locationName,
    String? address,
    String? title,
    String? description,
    int? maxPlayers,
    int? minPlayers,
    GameType? gameType,
    GameSkillLevel? skillLevel,
    String? groupError,
    String? dateTimeError,
    String? locationError,
    String? titleError,
    String? playersError,
    bool? isValid,
  }) {
    return GameCreationFormState(
      groupId: groupId ?? this.groupId,
      groupName: groupName ?? this.groupName,
      dateTime: dateTime ?? this.dateTime,
      locationName: locationName ?? this.locationName,
      address: address ?? this.address,
      title: title ?? this.title,
      description: description ?? this.description,
      maxPlayers: maxPlayers ?? this.maxPlayers,
      minPlayers: minPlayers ?? this.minPlayers,
      gameType: gameType ?? this.gameType,
      skillLevel: skillLevel ?? this.skillLevel,
      groupError: groupError,
      dateTimeError: dateTimeError,
      locationError: locationError,
      titleError: titleError,
      playersError: playersError,
      isValid: isValid ?? this.isValid,
    );
  }

  @override
  List<Object?> get props => [
        groupId,
        groupName,
        dateTime,
        locationName,
        address,
        title,
        description,
        maxPlayers,
        minPlayers,
        gameType,
        skillLevel,
        groupError,
        dateTimeError,
        locationError,
        titleError,
        playersError,
        isValid,
      ];
}

/// State when submitting the game
class GameCreationSubmitting extends GameCreationState implements LoadingState {
  const GameCreationSubmitting();
}

/// State when game creation succeeds
class GameCreationSuccess extends GameCreationState implements SuccessState {
  final String gameId;
  final GameModel game;

  const GameCreationSuccess({
    required this.gameId,
    required this.game,
  });

  @override
  List<Object?> get props => [gameId, game];
}

/// State when game creation fails
class GameCreationError extends GameCreationState implements ErrorState {
  @override
  final String message;
  @override
  final String? errorCode;
  @override
  final bool isRetryable;

  const GameCreationError({
    required this.message,
    this.errorCode,
    this.isRetryable = true,
  });

  @override
  List<Object?> get props => [message, errorCode, isRetryable];
}
