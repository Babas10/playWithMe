import 'package:freezed_annotation/freezed_annotation.dart';

part 'statistics_models.freezed.dart';
part 'statistics_models.g.dart';

/// Represents a player's rating for ELO calculations
@freezed
class PlayerRating with _$PlayerRating {
  const factory PlayerRating({
    required String playerId,
    required double rating,
    String? displayName,
  }) = _PlayerRating;

  const PlayerRating._();

  factory PlayerRating.fromJson(Map<String, dynamic> json) =>
      _$PlayerRatingFromJson(json);
}

/// Represents the result of an ELO calculation
@freezed
class EloResult with _$EloResult {
  const factory EloResult({
    required PlayerRating teamAPlayer1,
    required PlayerRating teamAPlayer2,
    required PlayerRating teamBPlayer1,
    required PlayerRating teamBPlayer2,
    required double teamARating,
    required double teamBRating,
    required double teamAExpectedScore,
    required double teamBExpectedScore,
    required double ratingDelta,
    required bool teamAWon,
  }) = _EloResult;

  const EloResult._();

  factory EloResult.fromJson(Map<String, dynamic> json) =>
      _$EloResultFromJson(json);

  /// Get the new rating for a specific player after the game
  double getNewRating(String playerId) {
    if (playerId == teamAPlayer1.playerId) {
      return teamAPlayer1.rating + (teamAWon ? ratingDelta : -ratingDelta);
    } else if (playerId == teamAPlayer2.playerId) {
      return teamAPlayer2.rating + (teamAWon ? ratingDelta : -ratingDelta);
    } else if (playerId == teamBPlayer1.playerId) {
      return teamBPlayer1.rating + (teamAWon ? -ratingDelta : ratingDelta);
    } else if (playerId == teamBPlayer2.playerId) {
      return teamBPlayer2.rating + (teamAWon ? -ratingDelta : ratingDelta);
    }
    throw ArgumentError('Player ID $playerId not found in ELO result');
  }

  /// Get the rating change for a specific player (positive or negative)
  double getRatingChange(String playerId) {
    if (playerId == teamAPlayer1.playerId || playerId == teamAPlayer2.playerId) {
      return teamAWon ? ratingDelta : -ratingDelta;
    } else if (playerId == teamBPlayer1.playerId || playerId == teamBPlayer2.playerId) {
      return teamAWon ? -ratingDelta : ratingDelta;
    }
    throw ArgumentError('Player ID $playerId not found in ELO result');
  }
}

/// Represents statistics about a teammate
@freezed
class TeammateStats with _$TeammateStats {
  const factory TeammateStats({
    required String playerId,
    required String displayName,
    required int gamesPlayed,
    required int gamesWon,
    required int gamesLost,
    required double winRate,
    required double averageRatingChange,
  }) = _TeammateStats;

  const TeammateStats._();

  factory TeammateStats.fromJson(Map<String, dynamic> json) =>
      _$TeammateStatsFromJson(json);

  /// Check if this teammate has a winning record
  bool get hasWinningRecord => winRate > 0.5;

  /// Check if this is a frequent teammate (played 5+ games together)
  bool get isFrequentTeammate => gamesPlayed >= 5;

  /// Get formatted win rate percentage
  String get formattedWinRate => '${(winRate * 100).toStringAsFixed(1)}%';
}
