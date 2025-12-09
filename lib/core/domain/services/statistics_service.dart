import 'dart:math' as math;
import 'statistics_models.dart';

/// Pure Dart service for calculating statistics and ELO ratings
///
/// This service provides reusable business logic for:
/// - ELO rating calculations using the Weak-Link model
/// - Win percentage and streak calculations
/// - Teammate statistics analysis
///
/// All methods are pure functions with no Firebase dependencies,
/// making them easy to test and use anywhere in the app.
///
/// Example usage:
/// ```dart
/// final service = StatisticsService();
///
/// // Calculate ELO changes for a game
/// final result = service.calculateElo(
///   teamAPlayer1: PlayerRating(playerId: '1', rating: 1600),
///   teamAPlayer2: PlayerRating(playerId: '2', rating: 1650),
///   teamBPlayer1: PlayerRating(playerId: '3', rating: 1700),
///   teamBPlayer2: PlayerRating(playerId: '4', rating: 1750),
///   teamAWon: true,
/// );
///
/// print('Rating delta: ${result.ratingDelta}');
/// ```
class StatisticsService {
  /// K-factor for ELO calculation (determines rating volatility)
  /// Higher values = more volatile ratings
  static const double kFactor = 32.0;

  /// Weak-link weight for minimum rating (70%)
  static const double weakLinkMinWeight = 0.7;

  /// Weak-link weight for maximum rating (30%)
  static const double weakLinkMaxWeight = 0.3;

  /// Calculate ELO rating changes using the Weak-Link model
  ///
  /// The Weak-Link model accounts for team strength based on:
  /// - 70% weight on the weaker player
  /// - 30% weight on the stronger player
  ///
  /// This reflects beach volleyball dynamics where the weaker player
  /// is often targeted and has more impact on team performance.
  ///
  /// Example:
  /// ```dart
  /// final result = service.calculateElo(
  ///   teamAPlayer1: PlayerRating(playerId: 'a1', rating: 1600),
  ///   teamAPlayer2: PlayerRating(playerId: 'a2', rating: 1650),
  ///   teamBPlayer1: PlayerRating(playerId: 'b1', rating: 1700),
  ///   teamBPlayer2: PlayerRating(playerId: 'b2', rating: 1750),
  ///   teamAWon: true,
  /// );
  /// ```
  EloResult calculateElo({
    required PlayerRating teamAPlayer1,
    required PlayerRating teamAPlayer2,
    required PlayerRating teamBPlayer1,
    required PlayerRating teamBPlayer2,
    required bool teamAWon,
    double? customKFactor,
  }) {
    // Calculate team ratings using Weak-Link model
    final teamARating = _calculateWeakLinkRating(
      teamAPlayer1.rating,
      teamAPlayer2.rating,
    );
    final teamBRating = _calculateWeakLinkRating(
      teamBPlayer1.rating,
      teamBPlayer2.rating,
    );

    // Calculate expected scores using logistic curve
    final teamAExpectedScore = _calculateExpectedScore(teamARating, teamBRating);
    final teamBExpectedScore = 1.0 - teamAExpectedScore;

    // Calculate actual scores (1 for win, 0 for loss)
    final teamAActualScore = teamAWon ? 1.0 : 0.0;

    // Calculate rating delta: ΔR = K × (S – E)
    final k = customKFactor ?? kFactor;
    final ratingDelta = k * (teamAActualScore - teamAExpectedScore);

    return EloResult(
      teamAPlayer1: teamAPlayer1,
      teamAPlayer2: teamAPlayer2,
      teamBPlayer1: teamBPlayer1,
      teamBPlayer2: teamBPlayer2,
      teamARating: teamARating,
      teamBRating: teamBRating,
      teamAExpectedScore: teamAExpectedScore,
      teamBExpectedScore: teamBExpectedScore,
      ratingDelta: ratingDelta.abs(),
      teamAWon: teamAWon,
    );
  }

  /// Calculate Weak-Link team rating: TeamRating = (0.7 × R_min) + (0.3 × R_max)
  ///
  /// This formula gives more weight to the weaker player, reflecting
  /// the reality that in beach volleyball, opponents often target
  /// the weaker player.
  double _calculateWeakLinkRating(double rating1, double rating2) {
    final minRating = math.min(rating1, rating2);
    final maxRating = math.max(rating1, rating2);
    return (weakLinkMinWeight * minRating) + (weakLinkMaxWeight * maxRating);
  }

  /// Calculate expected win probability using logistic curve
  ///
  /// Formula: E = 1 / (1 + 10^((RatingB - RatingA)/400))
  ///
  /// This is the standard ELO expected score formula, which produces
  /// a probability between 0 and 1.
  double _calculateExpectedScore(double ratingA, double ratingB) {
    final exponent = (ratingB - ratingA) / 400.0;
    return 1.0 / (1.0 + math.pow(10, exponent));
  }

  /// Calculate win percentage from games won and total games played
  ///
  /// Returns a value between 0.0 and 1.0
  /// Returns 0.0 if no games have been played
  ///
  /// Example:
  /// ```dart
  /// final winRate = service.calculateWinPercentage(
  ///   gamesWon: 7,
  ///   gamesPlayed: 10,
  /// ); // Returns 0.7
  /// ```
  double calculateWinPercentage({
    required int gamesWon,
    required int gamesPlayed,
  }) {
    if (gamesPlayed <= 0) return 0.0;
    return gamesWon / gamesPlayed;
  }

  /// Calculate current streak from a list of recent game results
  ///
  /// Returns:
  /// - Positive number for winning streak
  /// - Negative number for losing streak
  /// - 0 if no games or no streak
  ///
  /// The list should be ordered from most recent to oldest.
  ///
  /// Example:
  /// ```dart
  /// final streak = service.calculateStreak([true, true, false, true]);
  /// // Returns 2 (two consecutive wins at the start)
  ///
  /// final loseStreak = service.calculateStreak([false, false, false]);
  /// // Returns -3 (three consecutive losses)
  /// ```
  int calculateStreak(List<bool> recentResults) {
    if (recentResults.isEmpty) return 0;

    int streak = 0;
    final firstResult = recentResults.first;

    for (final result in recentResults) {
      if (result == firstResult) {
        streak++;
      } else {
        break;
      }
    }

    // Return negative streak for losses
    return firstResult ? streak : -streak;
  }

  /// Get best teammates based on win rate and games played
  ///
  /// Filters and sorts teammates by:
  /// 1. Minimum games threshold (default: 3)
  /// 2. Win rate (highest first)
  /// 3. Games played (tiebreaker)
  ///
  /// Example:
  /// ```dart
  /// final teammates = [
  ///   TeammateStats(playerId: '1', displayName: 'Alice', gamesPlayed: 10, gamesWon: 8, gamesLost: 2, winRate: 0.8, averageRatingChange: 5.0),
  ///   TeammateStats(playerId: '2', displayName: 'Bob', gamesPlayed: 5, gamesWon: 3, gamesLost: 2, winRate: 0.6, averageRatingChange: 2.0),
  ///   TeammateStats(playerId: '3', displayName: 'Charlie', gamesPlayed: 2, gamesWon: 2, gamesLost: 0, winRate: 1.0, averageRatingChange: 10.0),
  /// ];
  ///
  /// final best = service.getBestTeammates(teammates, minGames: 3);
  /// // Returns [Alice, Bob] (Charlie filtered out due to < 3 games)
  /// ```
  List<TeammateStats> getBestTeammates(
    List<TeammateStats> teammates, {
    int minGames = 3,
    int? limit,
  }) {
    // Filter teammates with minimum games
    final qualified = teammates.where((t) => t.gamesPlayed >= minGames).toList();

    // Sort by win rate (descending), then by games played (descending)
    qualified.sort((a, b) {
      final winRateComparison = b.winRate.compareTo(a.winRate);
      if (winRateComparison != 0) return winRateComparison;
      return b.gamesPlayed.compareTo(a.gamesPlayed);
    });

    // Apply limit if specified
    if (limit != null && qualified.length > limit) {
      return qualified.sublist(0, limit);
    }

    return qualified;
  }

  /// Summarize a game result into a human-readable description
  ///
  /// Returns a map with game summary information.
  ///
  /// Example:
  /// ```dart
  /// final summary = service.summarizeGame(
  ///   teamAScore: 21,
  ///   teamBScore: 19,
  ///   teamAPlayerIds: ['a1', 'a2'],
  ///   teamBPlayerIds: ['b1', 'b2'],
  /// );
  /// // Returns: {
  /// //   'winner': 'teamA',
  /// //   'score': '21-19',
  /// //   'margin': 2,
  /// //   'close': true,
  /// // }
  /// ```
  Map<String, dynamic> summarizeGame({
    required int teamAScore,
    required int teamBScore,
    required List<String> teamAPlayerIds,
    required List<String> teamBPlayerIds,
  }) {
    final teamAWon = teamAScore > teamBScore;
    final margin = (teamAScore - teamBScore).abs();

    // A game is "close" if the margin is 2 points or less
    final isClose = margin <= 2;

    return {
      'winner': teamAWon ? 'teamA' : 'teamB',
      'loser': teamAWon ? 'teamB' : 'teamA',
      'score': '$teamAScore-$teamBScore',
      'teamAScore': teamAScore,
      'teamBScore': teamBScore,
      'margin': margin,
      'close': isClose,
      'teamAPlayerIds': teamAPlayerIds,
      'teamBPlayerIds': teamBPlayerIds,
      'winnerPlayerIds': teamAWon ? teamAPlayerIds : teamBPlayerIds,
      'loserPlayerIds': teamAWon ? teamBPlayerIds : teamAPlayerIds,
    };
  }

  /// Update player statistics after a game
  ///
  /// Takes current stats and game result, returns updated stats.
  /// This is a pure function that doesn't modify the input.
  ///
  /// Example:
  /// ```dart
  /// final updated = service.updatePlayerStats(
  ///   currentGamesPlayed: 10,
  ///   currentGamesWon: 6,
  ///   currentStreak: 2,
  ///   won: true,
  /// );
  /// // Returns: {
  /// //   'gamesPlayed': 11,
  /// //   'gamesWon': 7,
  /// //   'gamesLost': 4,
  /// //   'currentStreak': 3,
  /// //   'winRate': 0.636...
  /// // }
  /// ```
  Map<String, dynamic> updatePlayerStats({
    required int currentGamesPlayed,
    required int currentGamesWon,
    required int currentStreak,
    required bool won,
  }) {
    final newGamesPlayed = currentGamesPlayed + 1;
    final newGamesWon = currentGamesWon + (won ? 1 : 0);
    final newGamesLost = newGamesPlayed - newGamesWon;

    // Update streak
    int newStreak;
    if (currentStreak == 0) {
      // Starting a new streak
      newStreak = won ? 1 : -1;
    } else if ((currentStreak > 0 && won) || (currentStreak < 0 && !won)) {
      // Continuing streak in same direction
      newStreak = currentStreak + (won ? 1 : -1);
    } else {
      // Streak broken, starting new streak
      newStreak = won ? 1 : -1;
    }

    return {
      'gamesPlayed': newGamesPlayed,
      'gamesWon': newGamesWon,
      'gamesLost': newGamesLost,
      'currentStreak': newStreak,
      'winRate': calculateWinPercentage(
        gamesWon: newGamesWon,
        gamesPlayed: newGamesPlayed,
      ),
    };
  }
}
