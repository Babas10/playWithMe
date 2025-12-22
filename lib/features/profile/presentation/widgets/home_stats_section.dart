// Home screen statistics section with glance-level stats display.
import 'package:flutter/material.dart';
import 'package:play_with_me/core/data/models/rating_history_entry.dart';
import 'package:play_with_me/core/data/models/user_model.dart';
import 'package:play_with_me/features/profile/presentation/widgets/compact_stat_card.dart';
import 'package:play_with_me/features/profile/presentation/widgets/elo_trend_indicator.dart';
import 'package:play_with_me/features/profile/presentation/widgets/win_streak_badge.dart';

/// A section widget displaying glance-level statistics on the home screen.
///
/// Shows core stats for instant feedback (< 3 seconds):
/// - Current ELO + Trend (with delta over last N games)
/// - Win Rate (percentage + W/L record)
/// - Games Played (total count)
/// - Current Win Streak (only if streak >= 2)
///
/// Constraints:
/// - Maximum 5 visible metrics
/// - No charts larger than a sparkline
/// - No scrolling within the stats area
class HomeStatsSection extends StatelessWidget {
  final UserModel user;
  final List<RatingHistoryEntry> ratingHistory;

  const HomeStatsSection({
    super.key,
    required this.user,
    required this.ratingHistory,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Section header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            'Performance Overview',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        const SizedBox(height: 8),
        // Stats grid
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Row 1: ELO Trend Indicator (full width)
              ELOTrendIndicator(
                currentElo: user.eloRating,
                recentHistory: ratingHistory,
                lookbackGames: 5,
              ),
              const SizedBox(height: 8),
              // Row 2: Win Rate and Games Played (2 columns)
              Row(
                children: [
                  // Win Rate
                  Expanded(
                    child: CompactStatCard(
                      label: 'Win Rate',
                      value: '${(user.winRate * 100).toStringAsFixed(1)}%',
                      icon: Icons.pie_chart,
                      iconColor: Colors.green,
                      subLabel: '${user.gamesWon}W - ${user.gamesLost}L',
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Games Played
                  Expanded(
                    child: CompactStatCard(
                      label: 'Games Played',
                      value: user.gamesPlayed.toString(),
                      icon: Icons.sports_volleyball,
                      iconColor: Colors.orange,
                    ),
                  ),
                ],
              ),
              // Row 3: Win Streak Badge (conditional, full width)
              if (user.currentStreak.abs() >= 2) ...[
                const SizedBox(height: 8),
                WinStreakBadge(currentStreak: user.currentStreak),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
