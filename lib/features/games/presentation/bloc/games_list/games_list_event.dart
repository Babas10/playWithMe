import 'package:equatable/equatable.dart';
import 'package:play_with_me/core/data/models/game_model.dart';
import 'package:play_with_me/core/data/models/group_activity_item.dart';

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

class ActivityListUpdated extends GamesListEvent {
  final List<GroupActivityItem> activities;

  const ActivityListUpdated({required this.activities});

  @override
  List<Object?> get props => [activities];
}

class RefreshGamesList extends GamesListEvent {
  const RefreshGamesList();
}
