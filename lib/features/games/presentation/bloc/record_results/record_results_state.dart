import 'package:equatable/equatable.dart';
import 'package:play_with_me/core/data/models/game_model.dart';
import 'package:play_with_me/core/data/models/user_model.dart';

abstract class RecordResultsState extends Equatable {
  const RecordResultsState();

  @override
  List<Object?> get props => [];
}

class RecordResultsInitial extends RecordResultsState {
  const RecordResultsInitial();
}

class RecordResultsLoading extends RecordResultsState {
  const RecordResultsLoading();
}

class RecordResultsLoaded extends RecordResultsState {
  final GameModel game;
  final List<String> teamAPlayerIds;
  final List<String> teamBPlayerIds;
  final List<String> unassignedPlayerIds;
  final Map<String, UserModel> players;

  const RecordResultsLoaded({
    required this.game,
    required this.teamAPlayerIds,
    required this.teamBPlayerIds,
    required this.unassignedPlayerIds,
    this.players = const {},
  });

  @override
  List<Object?> get props => [game, teamAPlayerIds, teamBPlayerIds, unassignedPlayerIds, players];

  RecordResultsLoaded copyWith({
    GameModel? game,
    List<String>? teamAPlayerIds,
    List<String>? teamBPlayerIds,
    List<String>? unassignedPlayerIds,
    Map<String, UserModel>? players,
  }) {
    return RecordResultsLoaded(
      game: game ?? this.game,
      teamAPlayerIds: teamAPlayerIds ?? this.teamAPlayerIds,
      teamBPlayerIds: teamBPlayerIds ?? this.teamBPlayerIds,
      unassignedPlayerIds: unassignedPlayerIds ?? this.unassignedPlayerIds,
      players: players ?? this.players,
    );
  }

  bool get allPlayersAssigned => unassignedPlayerIds.isEmpty;

  bool get canSave => allPlayersAssigned && teamAPlayerIds.isNotEmpty && teamBPlayerIds.isNotEmpty;
}

class RecordResultsSaving extends RecordResultsState {
  final GameModel game;
  final List<String> teamAPlayerIds;
  final List<String> teamBPlayerIds;

  const RecordResultsSaving({
    required this.game,
    required this.teamAPlayerIds,
    required this.teamBPlayerIds,
  });

  @override
  List<Object?> get props => [game, teamAPlayerIds, teamBPlayerIds];
}

class RecordResultsSaved extends RecordResultsState {
  final GameModel game;

  const RecordResultsSaved({required this.game});

  @override
  List<Object?> get props => [game];
}

class RecordResultsError extends RecordResultsState {
  final String message;

  const RecordResultsError({required this.message});

  @override
  List<Object?> get props => [message];
}
