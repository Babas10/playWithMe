// Momentum and consistency card showing streak and monthly improvement.
import 'package:flutter/material.dart';
import 'package:play_with_me/core/data/models/rating_history_entry.dart';
import 'package:play_with_me/core/data/models/user_model.dart';
import 'package:play_with_me/features/profile/presentation/widgets/monthly_improvement_chart.dart';

/// A card widget displaying momentum and consistency metrics.
///
/// Includes:
/// - Current win streak with longest streak (optional secondary line)
/// - Monthly improvement chart for long-term progress tracking
class MomentumConsistencyCard extends StatelessWidget {
  final UserModel user;
  final List<RatingHistoryEntry> ratingHistory;

  const MomentumConsistencyCard({
    super.key,
    required this.user,
    required this.ratingHistory,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Momentum & Consistency',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            // Current Streak
            _buildStreakSection(context),
            const SizedBox(height: 24),
            // Monthly Improvement Chart
            Text(
              'Monthly Progress',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            MonthlyImprovementChart(
              ratingHistory: ratingHistory,
              currentElo: user.eloRating,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStreakSection(BuildContext context) {
    final theme = Theme.of(context);
    final hasStreak = user.currentStreak != 0;

    if (!hasStreak) {
      return _buildNoStreakState(context);
    }

    final isWinning = user.currentStreak > 0;
    final streakValue = user.currentStreak.abs();
    final streakColor = isWinning ? Colors.green : Colors.red;
    final streakIcon = isWinning ? Icons.trending_up : Icons.trending_down;
    final streakEmoji = isWinning ? '🔥' : '❄️';
    final streakLabel = isWinning ? 'Win Streak' : 'Loss Streak';

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: streakColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: streakColor.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          // Emoji
          Text(
            streakEmoji,
            style: const TextStyle(fontSize: 40),
          ),
          const SizedBox(width: 16),
          // Streak info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  streakLabel,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: streakColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      streakValue.toString(),
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: streakColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'games',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: streakColor.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
                // TODO: Add longest streak when that data is available
                // const SizedBox(height: 4),
                // Text(
                //   'Longest: 12 games',
                //   style: theme.textTheme.bodySmall?.copyWith(
                //     color: theme.colorScheme.onSurface.withOpacity(0.6),
                //   ),
                // ),
              ],
            ),
          ),
          // Icon
          Icon(
            streakIcon,
            size: 32,
            color: streakColor,
          ),
        ],
      ),
    );
  }

  Widget _buildNoStreakState(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.bolt,
            size: 32,
            color: theme.colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'No Active Streak',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Win your next game to start a streak!',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
