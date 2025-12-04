import 'package:equatable/equatable.dart';

abstract class RecordResultsEvent extends Equatable {
  const RecordResultsEvent();

  @override
  List<Object?> get props => [];
}

class LoadGameForResults extends RecordResultsEvent {
  final String gameId;

  const LoadGameForResults({required this.gameId});

  @override
  List<Object?> get props => [gameId];
}

class AssignPlayerToTeamA extends RecordResultsEvent {
  final String playerId;

  const AssignPlayerToTeamA({required this.playerId});

  @override
  List<Object?> get props => [playerId];
}

class AssignPlayerToTeamB extends RecordResultsEvent {
  final String playerId;

  const AssignPlayerToTeamB({required this.playerId});

  @override
  List<Object?> get props => [playerId];
}

class RemovePlayerFromTeam extends RecordResultsEvent {
  final String playerId;

  const RemovePlayerFromTeam({required this.playerId});

  @override
  List<Object?> get props => [playerId];
}

class SaveTeams extends RecordResultsEvent {
  final String userId;

  const SaveTeams({required this.userId});

  @override
  List<Object?> get props => [userId];
}
