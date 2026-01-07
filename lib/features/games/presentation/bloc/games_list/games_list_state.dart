import 'package:equatable/equatable.dart';
import 'package:play_with_me/core/data/models/game_model.dart';
import 'package:play_with_me/core/data/models/group_activity_item.dart';

abstract class GamesListState extends Equatable {
  const GamesListState();

  @override
  List<Object?> get props => [];
}

class GamesListInitial extends GamesListState {
  const GamesListInitial();
}

class GamesListLoading extends GamesListState {
  const GamesListLoading();
}

class GamesListLoaded extends GamesListState {
  final List<GroupActivityItem> upcomingActivities;
  final List<GroupActivityItem> pastActivities;
  final String userId;

  const GamesListLoaded({
    required this.upcomingActivities,
    required this.pastActivities,
    required this.userId,
  });

  @override
  List<Object?> get props => [upcomingActivities, pastActivities, userId];

  // Helper getters for backward compatibility and filtering
  List<GameModel> get upcomingGames => upcomingActivities
      .whereType<GameActivityItem>()
      .map((item) => item.game)
      .toList();

  List<GameModel> get pastGames =>
      pastActivities.whereType<GameActivityItem>().map((item) => item.game).toList();
}

class GamesListError extends GamesListState {
  final String message;

  const GamesListError({required this.message});

  @override
  List<Object?> get props => [message];
}

class GamesListEmpty extends GamesListState {
  final String userId;

  const GamesListEmpty({required this.userId});

  @override
  List<Object?> get props => [userId];
}
