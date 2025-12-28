// Performance overview card with detailed statistics.
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:play_with_me/core/data/models/user_model.dart';
import 'package:play_with_me/features/profile/presentation/widgets/empty_stats_placeholder.dart';

/// A card widget displaying comprehensive performance statistics.
///
/// Includes:
/// - Current ELO
/// - Peak ELO (with date)
/// - Games Played
/// - Win Rate
/// - Best Win (future: highest-rated opponent team defeated)
/// - Average Point Differential (future: avg points won - points conceded)
///
/// Shows an empty state if the user hasn't played any games yet.
class PerformanceOverviewCard extends StatelessWidget {
  final UserModel user;

  const PerformanceOverviewCard({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Show empty state for new users with no games
    if (user.gamesPlayed == 0) {
      return const EmptyStatsPlaceholder(
        title: 'No Performance Data',
        message: 'Play your first game to see your performance statistics!',
        unlockMessage: 'Play at least 1 game to unlock',
        icon: Icons.show_chart,
      );
    }

    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Performance Overview',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            // Stats grid (2 columns)
            _buildStatsGrid(context),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // Row 1: Current ELO and Peak ELO
        Row(
          children: [
            Expanded(
              child: _StatItem(
                label: 'Current ELO',
                value: user.eloRating.toStringAsFixed(0),
                icon: Icons.show_chart,
                iconColor: Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatItem(
                label: 'Peak ELO',
                value: user.eloPeak.toStringAsFixed(0),
                icon: Icons.trending_up,
                iconColor: Colors.green,
                subLabel: user.eloPeakDate != null
                    ? DateFormat('MMM d, yyyy').format(user.eloPeakDate!)
                    : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Row 2: Games Played and Win Rate
        Row(
          children: [
            Expanded(
              child: _StatItem(
                label: 'Games Played',
                value: user.gamesPlayed.toString(),
                icon: Icons.sports_volleyball,
                iconColor: Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatItem(
                label: 'Win Rate',
                value: '${(user.winRate * 100).toStringAsFixed(1)}%',
                icon: Icons.pie_chart,
                iconColor: Colors.purple,
                subLabel: '${user.gamesWon}W - ${user.gamesLost}L',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Row 3: Best Win
        if (user.bestWin != null)
          _StatItem(
            label: 'Best Win',
            value: 'vs ${user.bestWin!.avgEloString} ELO',
            icon: Icons.emoji_events,
            iconColor: Colors.amber,
            subLabel: '${user.bestWin!.eloGainString} ELO gained',
          )
        else
          _StatItem(
            label: 'Best Win',
            value: 'Win a game to unlock',
            icon: Icons.emoji_events_outlined,
            iconColor: Colors.amber.withOpacity(0.5),
            subLabel: 'Beat opponents to track your best victory',
          ),
        const SizedBox(height: 12),
        // Row 4: Average Point Differential (placeholder for now)
        _StatItem(
          label: 'Avg Point Differential',
          value: 'Coming Soon',
          icon: Icons.compare_arrows,
          iconColor: Colors.teal,
          subLabel: 'Points scored vs conceded',
        ),
      ],
    );
  }
}

/// Internal stat item widget for consistent styling.
class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;
  final String? subLabel;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
    this.subLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label and icon
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(
                icon,
                size: 18,
                color: iconColor,
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Value
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          // Sub-label (optional)
          if (subLabel != null) ...[
            const SizedBox(height: 4),
            Text(
              subLabel!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}
