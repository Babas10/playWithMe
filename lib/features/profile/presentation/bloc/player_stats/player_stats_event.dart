import 'package:equatable/equatable.dart';
import 'package:play_with_me/core/data/models/user_model.dart';

abstract class PlayerStatsEvent extends Equatable {
  const PlayerStatsEvent();

  @override
  List<Object> get props => [];
}

class LoadPlayerStats extends PlayerStatsEvent {
  final String userId;

  const LoadPlayerStats(this.userId);

  @override
  List<Object> get props => [userId];
}

class UpdateUserStats extends PlayerStatsEvent {
  final UserModel user;

  const UpdateUserStats(this.user);

  @override
  List<Object> get props => [user];
}
