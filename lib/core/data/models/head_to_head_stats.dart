import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:play_with_me/core/data/models/user_model.dart';

part 'head_to_head_stats.freezed.dart';
part 'head_to_head_stats.g.dart';

/// Head-to-head statistics between two players (when on opposing teams).
/// Tracks rivalry/matchup performance for competitive analysis.
@freezed
class HeadToHeadStats with _$HeadToHeadStats {
  const factory HeadToHeadStats({
    /// Primary user ID (the user viewing these stats)
    required String userId,

    /// Opponent user ID
    required String opponentId,

    /// Total games played against this opponent
    required int gamesPlayed,

    /// Games won against this opponent
    required int gamesWon,

    /// Games lost against this opponent
    required int gamesLost,

    /// Total points scored against this opponent
    @Default(0) int pointsScored,

    /// Total points allowed against this opponent
    @Default(0) int pointsAllowed,

    /// Net ELO change from games against this opponent
    @Default(0.0) double eloChange,

    /// Largest point margin victory
    @Default(0) int largestVictoryMargin,

    /// Largest point margin defeat
    @Default(0) int largestDefeatMargin,

    /// Recent matchup results (up to 10 most recent)
    @Default([]) List<HeadToHeadGameResult> recentMatchups,

    /// When these stats were last updated
    @TimestampConverter() DateTime? lastUpdated,
  }) = _HeadToHeadStats;

  const HeadToHeadStats._();

  factory HeadToHeadStats.fromJson(Map<String, dynamic> json) =>
      _$HeadToHeadStatsFromJson(json);

  /// Factory constructor for creating from Firestore DocumentSnapshot
  factory HeadToHeadStats.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return HeadToHeadStats.fromJson(data);
  }

  /// Convert to Firestore-compatible map
  Map<String, dynamic> toFirestore() {
    return toJson();
  }

  /// Calculate win rate as a percentage (0-100)
  double get winRate => gamesPlayed > 0 ? (gamesWon / gamesPlayed) * 100 : 0.0;

  /// Calculate loss rate as a percentage (0-100)
  double get lossRate => gamesPlayed > 0 ? (gamesLost / gamesPlayed) * 100 : 0.0;

  /// Calculate average points scored per game
  double get avgPointsScored => gamesPlayed > 0 ? pointsScored / gamesPlayed : 0.0;

  /// Calculate average points allowed per game
  double get avgPointsAllowed => gamesPlayed > 0 ? pointsAllowed / gamesPlayed : 0.0;

  /// Calculate average point differential per game
  double get avgPointDifferential => avgPointsScored - avgPointsAllowed;

  /// Calculate average ELO change per game
  double get avgEloChange => gamesPlayed > 0 ? eloChange / gamesPlayed : 0.0;

  /// Get current streak against this opponent (positive for wins, negative for losses)
  int get currentStreak {
    if (recentMatchups.isEmpty) return 0;

    int streak = 0;
    final firstGameWon = recentMatchups.first.won;

    for (final game in recentMatchups) {
      if (game.won == firstGameWon) {
        streak++;
      } else {
        break;
      }
    }

    return firstGameWon ? streak : -streak;
  }

  /// Check if currently on a winning streak against this opponent
  bool get isOnWinningStreak => currentStreak > 0;

  /// Check if currently on a losing streak against this opponent
  bool get isOnLosingStreak => currentStreak < 0;

  /// Format win-loss record as string (e.g., "5W - 3L")
  String get recordString => '${gamesWon}W - ${gamesLost}L';

  /// Format point differential with sign (e.g., "+3.5" or "-2.1")
  String get formattedPointDifferential {
    final diff = avgPointDifferential;
    final sign = diff >= 0 ? '+' : '';
    return '$sign${diff.toStringAsFixed(1)}';
  }

  /// Format ELO change with sign (e.g., "+25.0" or "-18.5")
  String get formattedEloChange {
    final sign = eloChange >= 0 ? '+' : '';
    return '$sign${eloChange.toStringAsFixed(1)}';
  }

  /// Determine matchup advantage (positive = user favored, negative = opponent favored)
  String get matchupAdvantage {
    if (gamesPlayed < 5) return 'Not enough data';
    if (winRate > 60) return 'Strong advantage';
    if (winRate >= 50) return 'Slight advantage';
    if (winRate >= 40) return 'Even matchup';
    return 'Disadvantage';
  }

  /// Check if this is a rivalry (defined as >= 10 games played)
  bool get isRivalry => gamesPlayed >= 10;

  /// Get rivalry intensity level
  String get rivalryIntensity {
    if (gamesPlayed < 5) return 'New matchup';
    if (gamesPlayed < 10) return 'Developing rivalry';
    if (gamesPlayed < 20) return 'Active rivalry';
    return 'Intense rivalry';
  }
}

/// Represents a single head-to-head matchup result.
@freezed
class HeadToHeadGameResult with _$HeadToHeadGameResult {
  const factory HeadToHeadGameResult({
    /// Reference to the game
    required String gameId,

    /// Whether the primary user won
    required bool won,

    /// Points scored by user's team
    required int pointsScored,

    /// Points scored by opponent's team
    required int pointsAllowed,

    /// ELO change from this game
    required double eloChange,

    /// Partner who played with the user (if any)
    String? partnerId,

    /// Partner who played with the opponent (if any)
    String? opponentPartnerId,

    /// When the game was played
    @RequiredTimestampConverter() required DateTime timestamp,
  }) = _HeadToHeadGameResult;

  const HeadToHeadGameResult._();

  factory HeadToHeadGameResult.fromJson(Map<String, dynamic> json) =>
      _$HeadToHeadGameResultFromJson(json);

  /// Point differential for this game
  int get pointDifferential => pointsScored - pointsAllowed;

  /// Format point differential with sign
  String get formattedPointDifferential {
    final sign = pointDifferential >= 0 ? '+' : '';
    return '$sign$pointDifferential';
  }

  /// Format ELO change with sign
  String get formattedEloChange {
    final sign = eloChange >= 0 ? '+' : '';
    return '$sign${eloChange.toStringAsFixed(1)}';
  }

  /// Result as short string (e.g., "W", "L")
  String get resultLetter => won ? 'W' : 'L';

  /// Result with color (green for wins, red for losses)
  Map<String, dynamic> get resultDisplay => {
        'text': resultLetter,
        'won': won,
      };

  /// Format score display (e.g., "21-15")
  String get scoreDisplay => '$pointsScored-$pointsAllowed';
}
