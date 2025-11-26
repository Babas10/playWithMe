import 'package:equatable/equatable.dart';
import 'package:play_with_me/core/data/models/game_model.dart';

abstract class GamesListEvent extends Equatable {
  const GamesListEvent();

  @override
  List<Object?> get props => [];
}

class LoadGamesForGroup extends GamesListEvent {
  final String groupId;
  final String userId;

  const LoadGamesForGroup({
    required this.groupId,
    required this.userId,
  });

  @override
  List<Object?> get props => [groupId, userId];
}

class GamesListUpdated extends GamesListEvent {
  final List<GameModel> games;

  const GamesListUpdated({required this.games});

  @override
  List<Object?> get props => [games];
}

class RefreshGamesList extends GamesListEvent {
  const RefreshGamesList();
}
