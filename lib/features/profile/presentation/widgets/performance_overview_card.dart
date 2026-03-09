// Performance overview card with detailed statistics.
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:play_with_me/core/data/models/user_model.dart';
import 'package:play_with_me/core/theme/app_colors.dart';
import 'package:play_with_me/features/profile/presentation/widgets/empty_states/insufficient_data_placeholder.dart';
import 'package:play_with_me/l10n/app_localizations.dart';

/// A card widget displaying comprehensive performance statistics.
///
/// Includes:
/// - 2×2 dashboard grid: Current ELO, Peak ELO, Win Rate, Games Played
/// - Best Win (structured multi-line layout)
/// - Average Point Differential (wins vs losses)
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
            Text(
              AppLocalizations.of(context)!.performanceOverview,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.secondary,
              ),
            ),
            const SizedBox(height: 16),
            _buildStatsGrid(context),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context) {
    return Column(
      children: [
        // 2×2 dashboard grid — no per-stat background boxes
        _build2x2Grid(context),
        const SizedBox(height: 12),
        // Best Win
        if (user.bestWin != null)
          _BestWinStatItem(bestWin: user.bestWin!)
        else
          _StatItem(
            label: AppLocalizations.of(context)!.bestWin,
            value: AppLocalizations.of(context)!.winGameToUnlock,
            icon: Icons.emoji_events_outlined,
            iconColor: AppColors.primary.withValues(alpha: 0.5),
            subLabel: AppLocalizations.of(context)!.beatOpponentsToTrack,
          ),
        const SizedBox(height: 12),
        // Average Point Differential
        if (user.pointStats != null && user.pointStats!.totalSets > 0)
          _PointDiffStatItem(pointStats: user.pointStats!)
        else
          _StatItem(
            label: AppLocalizations.of(context)!.avgPointDiff,
            value: AppLocalizations.of(context)!.completeGameToUnlock,
            icon: Icons.trending_up_outlined,
            iconColor: AppColors.textMuted.withValues(alpha: 0.5),
            subLabel: AppLocalizations.of(context)!.winAndLoseSetsToSee,
          ),
      ],
    );
  }

  /// 2×2 grid of key stats inside a single bordered container.
  Widget _build2x2Grid(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.divider),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: _GridStatItem(
                    label: AppLocalizations.of(context)!.currentElo,
                    value: user.eloRating.toStringAsFixed(0),
                    icon: Icons.show_chart,
                    iconColor: AppColors.textMuted,
                    valueColor: AppColors.secondary,
                  ),
                ),
                const VerticalDivider(width: 1, color: AppColors.divider),
                Expanded(
                  child: _GridStatItem(
                    label: AppLocalizations.of(context)!.peakElo,
                    value: user.eloPeak.toStringAsFixed(0),
                    icon: Icons.emoji_events,
                    iconColor: AppColors.primary,
                    valueColor: AppColors.primary,
                    subLabel: user.eloPeakDate != null
                        ? DateFormat('MMM d, yyyy').format(user.eloPeakDate!)
                        : null,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.divider),
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: _GridStatItem(
                    label: AppLocalizations.of(context)!.winRate,
                    value: '${(user.winRate * 100).toStringAsFixed(1)}%',
                    icon: Icons.pie_chart,
                    iconColor: AppColors.primary,
                    valueColor: AppColors.secondary,
                    subLabel: '${user.gamesWon}W - ${user.gamesLost}L',
                  ),
                ),
                const VerticalDivider(width: 1, color: AppColors.divider),
                Expanded(
                  child: _GridStatItem(
                    label: AppLocalizations.of(context)!.gamesPlayed,
                    value: user.gamesPlayed.toString(),
                    icon: Icons.sports_volleyball,
                    iconColor: AppColors.textMuted,
                    valueColor: AppColors.secondary,
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

/// Stat item for the 2×2 grid — no background, clean whitespace layout.
class _GridStatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;
  final Color valueColor;
  final String? subLabel;

  const _GridStatItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
    required this.valueColor,
    this.subLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: iconColor),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
          if (subLabel != null) ...[
            const SizedBox(height: 2),
            Text(
              subLabel!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}

/// Locked/placeholder stat item with tinted background to indicate unavailability.
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
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(icon, size: 18, color: iconColor),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          if (subLabel != null) ...[
            const SizedBox(height: 4),
            Text(
              subLabel!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
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

  const _PointDiffStatItem({required this.pointStats});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.compare_arrows, size: 20, color: AppColors.secondary),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.of(context)!.avgPointDifferential,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              // Winning sets
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.inWins,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      pointStats.avgWinsString,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: pointStats.winningSetsCount > 0
                            ? Colors.green
                            : theme.colorScheme.onSurface.withValues(alpha: 0.3),
                      ),
                    ),
                    Text(
                      AppLocalizations.of(context)!.setsCount(pointStats.winningSetsCount),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                      ),
                    ),
                  ],
                ),
              ),
              // Divider
              Container(
                width: 1,
                height: 60,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
              ),
              const SizedBox(width: 16),
              // Losing sets
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.inLosses,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      pointStats.avgLossesString,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: pointStats.losingSetsCount > 0
                            ? Colors.red
                            : theme.colorScheme.onSurface.withValues(alpha: 0.3),
                      ),
                    ),
                    Text(
                      AppLocalizations.of(context)!.setsCount(pointStats.losingSetsCount),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            pointStats.statsSubtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}

/// Best Win stat item with clear label vs value typography hierarchy.
class _BestWinStatItem extends StatelessWidget {
  final BestWinRecord bestWin;

  const _BestWinStatItem({required this.bestWin});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row: label + trophy icon
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context)!.bestWin,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Icon(Icons.emoji_events, size: 18, color: AppColors.primary),
            ],
          ),
          const SizedBox(height: 8),
          // Opponent names — primary value, bold and prominent
          if (bestWin.opponentNames != null) ...[
            Text(
              AppLocalizations.of(context)!.teamLabel(
                bestWin.opponentNames!.replaceAll(' & ', ' · '),
              ),
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.secondary,
              ),
            ),
            const SizedBox(height: 4),
          ],
          // Team ELO — secondary info, smaller and muted
          Text(
            AppLocalizations.of(context)!.teamEloLabel(bestWin.avgEloString),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 2),
          // ELO gained — tertiary, muted
          Text(
            AppLocalizations.of(context)!.eloGained(bestWin.eloGainString),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}
