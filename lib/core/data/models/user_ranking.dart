import 'package:freezed_annotation/freezed_annotation.dart';

import 'user_model.dart'; // For RequiredTimestampConverter

part 'user_ranking.freezed.dart';
part 'user_ranking.g.dart';

/// Represents a user's ranking information across global, percentile, and friends contexts (Story 302.2).
/// Used to display ranking stats in the monthly improvement chart.
@freezed
class UserRanking with _$UserRanking {
  const factory UserRanking({
    /// User's position in global rankings (1 = highest rated)
    required int globalRank,

    /// Total number of users with ELO ratings
    required int totalUsers,

    /// Percentile (0-100, where 100 = top performer)
    required double percentile,

    /// User's position among friends (nullable if no friends)
    int? friendsRank,

    /// Total number of friends with ELO ratings (nullable if no friends)
    int? totalFriends,

    /// When this ranking was calculated
    @RequiredTimestampConverter() required DateTime calculatedAt,
  }) = _UserRanking;

  const UserRanking._();

  factory UserRanking.fromJson(Map<String, dynamic> json) =>
      _$UserRankingFromJson(json);

  /// Display global rank as "#42 of 1,500"
  String get globalRankDisplay {
    final formattedTotal = totalUsers
        .toString()
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
    return '#$globalRank of $formattedTotal';
  }

  /// Display percentile as "Top 2.8%"
  String get percentileDisplay {
    final topPercent = 100 - percentile;
    return 'Top ${topPercent.toStringAsFixed(1)}%';
  }

  /// Display friends rank as "#3 of 15" or null if no friends
  String? get friendsRankDisplay {
    if (friendsRank == null || totalFriends == null) return null;
    return '#$friendsRank of $totalFriends';
  }

  /// Whether the user has friends to compare ranking against
  bool get hasFriends => friendsRank != null && totalFriends != null;

  /// Whether the user is in the top 10% globally
  bool get isTopTenPercent => percentile >= 90.0;

  /// Whether the user is in the top 25% globally
  bool get isTopTwentyFivePercent => percentile >= 75.0;

  /// Whether the user is #1 globally
  bool get isGlobalFirst => globalRank == 1;

  /// Whether the user is #1 among friends
  bool get isFriendsFirst => friendsRank == 1;
}
