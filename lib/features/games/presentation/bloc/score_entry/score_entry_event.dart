import 'package:equatable/equatable.dart';

abstract class ScoreEntryEvent extends Equatable {
  const ScoreEntryEvent();

  @override
  List<Object?> get props => [];
}

/// Load game for score entry
class LoadGameForScoreEntry extends ScoreEntryEvent {
  final String gameId;

  const LoadGameForScoreEntry({required this.gameId});

  @override
  List<Object?> get props => [gameId];
}

/// Set the number of games played in the session
class SetGameCount extends ScoreEntryEvent {
  final int count; // 1-10

  const SetGameCount({required this.count});

  @override
  List<Object?> get props => [count];
}

/// Set the format for a specific game (single set, best of 2, best of 3)
class SetGameFormat extends ScoreEntryEvent {
  final int gameIndex; // 0-based index
  final int numberOfSets; // 1, 2, or 3

  const SetGameFormat({
    required this.gameIndex,
    required this.numberOfSets,
  });

  @override
  List<Object?> get props => [gameIndex, numberOfSets];
}

/// Update score for a specific set in a specific game
class UpdateSetScore extends ScoreEntryEvent {
  final int gameIndex; // 0-based index
  final int setIndex; // 0-based index
  final int? teamAPoints;
  final int? teamBPoints;

  const UpdateSetScore({
    required this.gameIndex,
    required this.setIndex,
    this.teamAPoints,
    this.teamBPoints,
  });

  @override
  List<Object?> get props => [gameIndex, setIndex, teamAPoints, teamBPoints];
}

/// Save all the entered scores
class SaveScores extends ScoreEntryEvent {
  final String userId;

  const SaveScores({required this.userId});

  @override
  List<Object?> get props => [userId];
}
