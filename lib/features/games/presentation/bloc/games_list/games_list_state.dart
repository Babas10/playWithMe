import 'package:equatable/equatable.dart';
import 'package:play_with_me/core/data/models/game_model.dart';

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
  final List<GameModel> upcomingGames;
  final List<GameModel> pastGames;
  final String userId;

  const GamesListLoaded({
    required this.upcomingGames,
    required this.pastGames,
    required this.userId,
  });

  @override
  List<Object?> get props => [upcomingGames, pastGames, userId];
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
