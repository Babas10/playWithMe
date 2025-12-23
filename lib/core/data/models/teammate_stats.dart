import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:play_with_me/core/data/models/user_model.dart';

part 'teammate_stats.freezed.dart';
part 'teammate_stats.g.dart';

/// Statistics for games played with a specific teammate.
/// Tracks comprehensive performance metrics for partner analysis.
@freezed
class TeammateStats with _$TeammateStats {
  const factory TeammateStats({
    /// The teammate's user ID
    required String userId,

    /// Total games played together
    required int gamesPlayed,

    /// Games won together
    required int gamesWon,

    /// Games lost together
    required int gamesLost,

    /// Total points scored when playing together
    @Default(0) int pointsScored,

    /// Total points allowed when playing together
    @Default(0) int pointsAllowed,

    /// ELO rating change when playing together (cumulative)
    @Default(0.0) double eloChange,

    /// Recent game results (up to 10 most recent)
    @Default([]) List<RecentGameResult> recentGames,

    /// When these stats were last updated
    @TimestampConverter() DateTime? lastUpdated,
  }) = _TeammateStats;

  const TeammateStats._();

  factory TeammateStats.fromJson(Map<String, dynamic> json) =>
      _$TeammateStatsFromJson(json);

  /// Factory constructor for creating from Firestore map
  factory TeammateStats.fromFirestore(String userId, Map<String, dynamic> data) {
    return TeammateStats.fromJson({
      'userId': userId,
      ...data,
    });
  }

  /// Convert to Firestore-compatible map
  Map<String, dynamic> toFirestore() {
    final json = toJson();
    json.remove('userId'); // userId is the key in the parent map
    return json;
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

  /// Get current streak (positive for wins, negative for losses)
  int get currentStreak {
    if (recentGames.isEmpty) return 0;

    int streak = 0;
    final firstGameWon = recentGames.first.won;

    for (final game in recentGames) {
      if (game.won == firstGameWon) {
        streak++;
      } else {
        break;
      }
    }

    return firstGameWon ? streak : -streak;
  }

  /// Check if currently on a winning streak with this partner
  bool get isOnWinningStreak => currentStreak > 0;

  /// Check if currently on a losing streak with this partner
  bool get isOnLosingStreak => currentStreak < 0;

  /// Format win-loss record as string (e.g., "12W - 8L")
  String get recordString => '${gamesWon}W - ${gamesLost}L';

  /// Format point differential with sign (e.g., "+5.2" or "-3.1")
  String get formattedPointDifferential {
    final diff = avgPointDifferential;
    final sign = diff >= 0 ? '+' : '';
    return '$sign${diff.toStringAsFixed(1)}';
  }

  /// Format ELO change with sign (e.g., "+45.0" or "-12.5")
  String get formattedEloChange {
    final sign = eloChange >= 0 ? '+' : '';
    return '$sign${eloChange.toStringAsFixed(1)}';
  }
}

/// Represents a single game result in recent games history.
@freezed
class RecentGameResult with _$RecentGameResult {
  const factory RecentGameResult({
    /// Reference to the game
    required String gameId,

    /// Whether the team won
    required bool won,

    /// Points scored by the team
    required int pointsScored,

    /// Points scored by opponents
    required int pointsAllowed,

    /// ELO change from this game
    required double eloChange,

    /// When the game was played
    @RequiredTimestampConverter() required DateTime timestamp,
  }) = _RecentGameResult;

  const RecentGameResult._();

  factory RecentGameResult.fromJson(Map<String, dynamic> json) =>
      _$RecentGameResultFromJson(json);

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
  /// Returns a tuple-like map for UI rendering
  Map<String, dynamic> get resultDisplay => {
        'text': resultLetter,
        'won': won,
      };
}
