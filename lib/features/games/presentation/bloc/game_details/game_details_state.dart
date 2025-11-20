import 'package:play_with_me/core/data/models/game_model.dart';
import 'package:play_with_me/core/presentation/bloc/base_bloc_state.dart';

abstract class GameDetailsState extends BaseBlocState {
  const GameDetailsState();
}

class GameDetailsInitial extends GameDetailsState implements InitialState {
  const GameDetailsInitial();
}

class GameDetailsLoading extends GameDetailsState implements LoadingState {
  const GameDetailsLoading();
}

class GameDetailsLoaded extends GameDetailsState implements SuccessState {
  final GameModel game;

  const GameDetailsLoaded({required this.game});

  @override
  List<Object?> get props => [game];
}

class GameDetailsOperationInProgress extends GameDetailsState
    implements LoadingState {
  final GameModel game;
  final String operation;

  const GameDetailsOperationInProgress({
    required this.game,
    required this.operation,
  });

  @override
  List<Object?> get props => [game, operation];
}

class GameDetailsError extends GameDetailsState implements ErrorState {
  @override
  final String message;
  @override
  final String? errorCode;
  @override
  final bool isRetryable;

  const GameDetailsError({
    required this.message,
    this.errorCode,
    this.isRetryable = true,
  });

  @override
  List<Object?> get props => [message, errorCode, isRetryable];
}

class GameDetailsNotFound extends GameDetailsState implements ErrorState {
  @override
  final String message;
  @override
  final String? errorCode;
  @override
  final bool isRetryable;

  const GameDetailsNotFound({
    this.message = 'Game not found',
    this.errorCode,
    this.isRetryable = false,
  });

  @override
  List<Object?> get props => [message, errorCode, isRetryable];
}
