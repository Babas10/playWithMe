import 'package:play_with_me/core/presentation/bloc/base_bloc_event.dart';

abstract class GameDetailsEvent extends BaseBlocEvent {
  const GameDetailsEvent();
}

class LoadGameDetails extends GameDetailsEvent {
  final String gameId;

  const LoadGameDetails({required this.gameId});

  @override
  List<Object?> get props => [gameId];
}

class GameDetailsUpdated extends GameDetailsEvent {
  final dynamic game;

  const GameDetailsUpdated({required this.game});

  @override
  List<Object?> get props => [game];
}

class JoinGameDetails extends GameDetailsEvent {
  final String gameId;
  final String userId;

  const JoinGameDetails({
    required this.gameId,
    required this.userId,
  });

  @override
  List<Object?> get props => [gameId, userId];
}

class LeaveGameDetails extends GameDetailsEvent {
  final String gameId;
  final String userId;

  const LeaveGameDetails({
    required this.gameId,
    required this.userId,
  });

  @override
  List<Object?> get props => [gameId, userId];
}
