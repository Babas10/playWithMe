import '../base_bloc_state.dart';
import '../../../data/models/game_model.dart';

abstract class GameState extends BaseBlocState {
  const GameState();
}

class GameInitial extends GameState implements InitialState {
  const GameInitial();
}

class GameLoading extends GameState implements LoadingState {
  const GameLoading();
}

class GameLoaded extends GameState implements SuccessState {
  final GameModel game;

  const GameLoaded({required this.game});

  @override
  List<Object?> get props => [game];
}

class GamesLoaded extends GameState implements SuccessState {
  final List<GameModel> games;

  const GamesLoaded({required this.games});

  @override
  List<Object?> get props => [games];
}

class GameCreated extends GameState implements SuccessState {
  final String gameId;
  final GameModel game;

  const GameCreated({
    required this.gameId,
    required this.game,
  });

  @override
  List<Object?> get props => [gameId, game];
}

class GameUpdated extends GameState implements SuccessState {
  final GameModel game;
  final String message;

  const GameUpdated({
    required this.game,
    required this.message,
  });

  @override
  List<Object?> get props => [game, message];
}

class GameOperationSuccess extends GameState implements SuccessState {
  final String message;

  const GameOperationSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

class GameStatsLoaded extends GameState implements SuccessState {
  final Map<String, dynamic> stats;

  const GameStatsLoaded({required this.stats});

  @override
  List<Object?> get props => [stats];
}

class GameError extends GameState implements ErrorState {
  @override
  final String message;
  @override
  final String? errorCode;
  @override
  final bool isRetryable;

  const GameError({
    required this.message,
    this.errorCode,
    this.isRetryable = true,
  });

  @override
  List<Object?> get props => [message, errorCode, isRetryable];
}

class GameNotFound extends GameState implements ErrorState {
  @override
  final String message;
  @override
  final String? errorCode;
  @override
  final bool isRetryable;

  const GameNotFound({
    this.message = 'Game not found',
    this.errorCode,
    this.isRetryable = false,
  });

  @override
  List<Object?> get props => [message, errorCode, isRetryable];
}