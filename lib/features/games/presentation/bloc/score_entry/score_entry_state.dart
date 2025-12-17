import 'package:equatable/equatable.dart';

import '../../../../../core/data/models/game_model.dart';

abstract class ScoreEntryState extends Equatable {
  const ScoreEntryState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class ScoreEntryInitial extends ScoreEntryState {
  const ScoreEntryInitial();
}

/// Loading game data
class ScoreEntryLoading extends ScoreEntryState {
  const ScoreEntryLoading();
}

/// Helper class to store score data for a single set
class SetScoreData {
  final int? teamAPoints;
  final int? teamBPoints;

  const SetScoreData({this.teamAPoints, this.teamBPoints});

  SetScoreData copyWith({
    int? teamAPoints,
    int? teamBPoints,
    bool clearTeamA = false,
    bool clearTeamB = false,
  }) {
    return SetScoreData(
      teamAPoints: clearTeamA ? null : (teamAPoints ?? this.teamAPoints),
      teamBPoints: clearTeamB ? null : (teamBPoints ?? this.teamBPoints),
    );
  }

  bool get isComplete => teamAPoints != null && teamBPoints != null;

  bool get isValid {
    if (!isComplete) return false;
    final maxPoints = teamAPoints! > teamBPoints! ? teamAPoints! : teamBPoints!;
    final minPoints = teamAPoints! < teamBPoints! ? teamAPoints! : teamBPoints!;

    if (maxPoints < 21) return false;
    if (maxPoints == 21) return minPoints <= 19;
    return (maxPoints - minPoints) == 2;
  }

  /// Get a user-friendly error message if the score is invalid
  String? get validationError {
    if (!isComplete) return null;
    
    final maxPoints = teamAPoints! > teamBPoints! ? teamAPoints! : teamBPoints!;
    final minPoints = teamAPoints! < teamBPoints! ? teamAPoints! : teamBPoints!;

    if (maxPoints < 21) {
      return 'Winning team must reach at least 21 points';
    }
    
    if (maxPoints == 21) {
      if (minPoints > 19) {
        return 'Must win by at least 2 points (e.g., 21-19)';
      }
    }
    
    if (maxPoints > 21) {
      if ((maxPoints - minPoints) != 2) {
        return 'In extra points, must win by exactly 2 points';
      }
    }

    return isValid ? null : 'Invalid score';
  }

  String? get winner {
    if (!isValid) return null;
    return teamAPoints! > teamBPoints! ? 'teamA' : 'teamB';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SetScoreData &&
          runtimeType == other.runtimeType &&
          teamAPoints == other.teamAPoints &&
          teamBPoints == other.teamBPoints;

  @override
  int get hashCode => teamAPoints.hashCode ^ teamBPoints.hashCode;
}

/// Helper class to store data for a single game
class GameData {
  final int numberOfSets; // 1, 2, or 3
  final List<SetScoreData> sets;

  const GameData({
    this.numberOfSets = 1,
    this.sets = const [],
  });

  GameData copyWith({
    int? numberOfSets,
    List<SetScoreData>? sets,
  }) {
    return GameData(
      numberOfSets: numberOfSets ?? this.numberOfSets,
      sets: sets ?? this.sets,
    );
  }

  /// Check if all required sets have valid scores
  bool get isComplete {
    if (sets.length < numberOfSets) return false;
    for (int i = 0; i < numberOfSets; i++) {
      if (!sets[i].isValid) return false;
    }
    return true;
  }

  /// Get the winner of this game
  String? get winner {
    if (!isComplete) return null;

    int teamAWins = 0;
    int teamBWins = 0;

    for (int i = 0; i < numberOfSets; i++) {
      if (sets[i].winner == 'teamA') teamAWins++;
      if (sets[i].winner == 'teamB') teamBWins++;
    }

    final requiredWins = (numberOfSets / 2).ceil();
    if (teamAWins >= requiredWins) return 'teamA';
    if (teamBWins >= requiredWins) return 'teamB';
    return null;
  }
}

/// Game loaded, ready for score entry
class ScoreEntryLoaded extends ScoreEntryState {
  final GameModel game;
  final int? gameCount; // null = not set yet, 1-10 = number of games
  final List<GameData> games; // Score data for each game

  const ScoreEntryLoaded({
    required this.game,
    this.gameCount,
    this.games = const [],
  });

  @override
  List<Object?> get props => [game, gameCount, games];

  /// Check if all games have valid scores
  bool get allGamesComplete {
    if (gameCount == null || gameCount == 0) return false;
    if (games.length != gameCount) return false;
    return games.every((game) => game.isComplete);
  }

  /// Get the overall winner (who won more games)
  String? get overallWinner {
    if (!allGamesComplete) return null;

    int teamAWins = 0;
    int teamBWins = 0;

    for (final game in games) {
      if (game.winner == 'teamA') teamAWins++;
      if (game.winner == 'teamB') teamBWins++;
    }

    if (teamAWins > teamBWins) return 'teamA';
    if (teamBWins > teamAWins) return 'teamB';
    return null;
  }

  /// Check if we can save (all games complete and there's a winner)
  bool get canSave => allGamesComplete && overallWinner != null;

  /// Copy with method for state updates
  ScoreEntryLoaded copyWith({
    GameModel? game,
    int? gameCount,
    List<GameData>? games,
    bool clearGameCount = false,
  }) {
    return ScoreEntryLoaded(
      game: game ?? this.game,
      gameCount: clearGameCount ? null : (gameCount ?? this.gameCount),
      games: games ?? this.games,
    );
  }
}

/// Saving scores
class ScoreEntrySaving extends ScoreEntryState {
  final GameModel game;
  final GameResult result;

  const ScoreEntrySaving({
    required this.game,
    required this.result,
  });

  @override
  List<Object?> get props => [game, result];
}

/// Scores saved successfully
class ScoreEntrySaved extends ScoreEntryState {
  final GameModel game;
  final GameResult result;

  const ScoreEntrySaved({
    required this.game,
    required this.result,
  });

  @override
  List<Object?> get props => [game, result];
}

/// Error state
class ScoreEntryError extends ScoreEntryState {
  final String message;

  const ScoreEntryError({required this.message});

  @override
  List<Object?> get props => [message];
}
