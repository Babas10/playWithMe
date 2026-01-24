// Performance overview card with detailed statistics.
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:play_with_me/core/data/models/user_model.dart';
import 'package:play_with_me/features/profile/presentation/widgets/empty_states/insufficient_data_placeholder.dart';
import 'package:play_with_me/l10n/app_localizations.dart';

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
      return EmptyStatsPlaceholder(
        title: AppLocalizations.of(context)!.noPerformanceData,
        message: AppLocalizations.of(context)!.playFirstGameToSeeStats,
        unlockMessage: AppLocalizations.of(context)!.playAtLeastOneGame,
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
              AppLocalizations.of(context)!.performanceOverview,
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
    return Column(
      children: [
        // Row 1: Current ELO and Peak ELO
        Row(
          children: [
            Expanded(
              child: _StatItem(
                label: AppLocalizations.of(context)!.currentElo,
                value: user.eloRating.toStringAsFixed(0),
                icon: Icons.show_chart,
                iconColor: Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatItem(
                label: AppLocalizations.of(context)!.peakElo,
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
                label: AppLocalizations.of(context)!.gamesPlayed,
                value: user.gamesPlayed.toString(),
                icon: Icons.sports_volleyball,
                iconColor: Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatItem(
                label: AppLocalizations.of(context)!.winRate,
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
          _BestWinStatItem(
            bestWin: user.bestWin!,
          )
        else
          _StatItem(
            label: AppLocalizations.of(context)!.bestWin,
            value: AppLocalizations.of(context)!.winGameToUnlock,
            icon: Icons.emoji_events_outlined,
            iconColor: Colors.amber.withOpacity(0.5),
            subLabel: AppLocalizations.of(context)!.beatOpponentsToTrack,
          ),
        const SizedBox(height: 12),
        // Row 4: Average Point Differential (Wins vs Losses)
        if (user.pointStats != null && user.pointStats!.totalSets > 0)
          _PointDiffStatItem(pointStats: user.pointStats!)
        else
          _StatItem(
            label: AppLocalizations.of(context)!.avgPointDiff,
            value: AppLocalizations.of(context)!.completeGameToUnlock,
            icon: Icons.trending_up_outlined,
            iconColor: Colors.teal.withOpacity(0.5),
            subLabel: AppLocalizations.of(context)!.winAndLoseSetsToSee,
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

/// Point Differential stat item showing winning and losing set averages separately.
class _PointDiffStatItem extends StatelessWidget {
  final PointStats pointStats;

  const _PointDiffStatItem({
    required this.pointStats,
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
          // Header
          Row(
            children: [
              Icon(
                Icons.compare_arrows,
                size: 20,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.of(context)!.avgPointDifferential,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Two columns: Wins and Losses
          Row(
            children: [
              // Winning sets
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.trending_up,
                          size: 16,
                          color: Colors.green,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          AppLocalizations.of(context)!.inWins,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      pointStats.avgWinsString,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: pointStats.winningSetsCount > 0
                            ? Colors.green
                            : theme.colorScheme.onSurface.withOpacity(0.3),
                      ),
                    ),
                    Text(
                      AppLocalizations.of(context)!.setsCount(pointStats.winningSetsCount),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.4),
                      ),
                    ),
                  ],
                ),
              ),
              // Divider
              Container(
                width: 1,
                height: 60,
                color: theme.colorScheme.onSurface.withOpacity(0.1),
              ),
              const SizedBox(width: 16),
              // Losing sets
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.trending_down,
                          size: 16,
                          color: Colors.red,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          AppLocalizations.of(context)!.inLosses,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      pointStats.avgLossesString,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: pointStats.losingSetsCount > 0
                            ? Colors.red
                            : theme.colorScheme.onSurface.withOpacity(0.3),
                      ),
                    ),
                    Text(
                      AppLocalizations.of(context)!.setsCount(pointStats.losingSetsCount),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Footer subtitle
          Text(
            pointStats.statsSubtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }
}

/// Best Win stat item with structured multi-line layout.
class _BestWinStatItem extends StatelessWidget {
  final BestWinRecord bestWin;

  const _BestWinStatItem({
    required this.bestWin,
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
              Text(
                AppLocalizations.of(context)!.bestWin,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Icon(
                Icons.emoji_events,
                size: 18,
                color: Colors.amber,
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Team composition (if available)
          if (bestWin.opponentNames != null) ...[
            Text(
              AppLocalizations.of(context)!.teamLabel(bestWin.opponentNames!.replaceAll(' & ', ' · ')),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
          ],
          // Team ELO
          Text(
            AppLocalizations.of(context)!.teamEloLabel(bestWin.avgEloString),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          // ELO gained
          Text(
            AppLocalizations.of(context)!.eloGained(bestWin.eloGainString),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }
}
