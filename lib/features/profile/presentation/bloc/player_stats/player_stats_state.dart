import 'package:equatable/equatable.dart';
import 'package:play_with_me/core/data/models/rating_history_entry.dart';
import 'package:play_with_me/core/data/models/user_model.dart';

abstract class PlayerStatsState extends Equatable {
  const PlayerStatsState();

  @override
  List<Object> get props => [];
}

class PlayerStatsInitial extends PlayerStatsState {}

class PlayerStatsLoading extends PlayerStatsState {}

class PlayerStatsLoaded extends PlayerStatsState {
  final UserModel user;
  final List<RatingHistoryEntry> history;

  const PlayerStatsLoaded({required this.user, required this.history});

  @override
  List<Object> get props => [user, history];
}

class PlayerStatsError extends PlayerStatsState {
  final String message;

  const PlayerStatsError(this.message);

  @override
  List<Object> get props => [message];
}
