import 'package:equatable/equatable.dart';
import 'package:play_with_me/core/data/models/rating_history_entry.dart';
import 'package:play_with_me/core/data/models/user_model.dart';
import 'package:play_with_me/core/data/models/user_ranking.dart';

abstract class PlayerStatsState extends Equatable {
  const PlayerStatsState();

  @override
  List<Object?> get props => [];
}

class PlayerStatsInitial extends PlayerStatsState {}

class PlayerStatsLoading extends PlayerStatsState {}

class PlayerStatsLoaded extends PlayerStatsState {
  final UserModel user;
  final List<RatingHistoryEntry> history;
  final UserRanking? ranking; // Story 302.5: Add ranking to state

  const PlayerStatsLoaded({
    required this.user,
    required this.history,
    this.ranking,
  });

  @override
  List<Object?> get props => [user, history, ranking];

  /// Create a copy of this state with updated fields (Story 302.5)
  PlayerStatsLoaded copyWith({
    UserModel? user,
    List<RatingHistoryEntry>? history,
    UserRanking? ranking,
  }) {
    return PlayerStatsLoaded(
      user: user ?? this.user,
      history: history ?? this.history,
      ranking: ranking ?? this.ranking,
    );
  }
}

class PlayerStatsError extends PlayerStatsState {
  final String message;

  const PlayerStatsError(this.message);

  @override
  List<Object> get props => [message];
}
