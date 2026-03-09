// Performance overview card following the homepage gray-background / white-card pattern.
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:play_with_me/core/data/models/user_model.dart';
import 'package:play_with_me/core/theme/app_colors.dart';
import 'package:play_with_me/features/profile/presentation/widgets/empty_states/insufficient_data_placeholder.dart';
import 'package:play_with_me/l10n/app_localizations.dart';

/// Performance stats section: gray background, gray section label, individual white cards.
///
/// Layout:
/// - "PERFORMANCE OVERVIEW" uppercase gray label
/// - Row 1: Current ELO card | Peak ELO card
/// - Row 2: Win Rate card | Games Played card
/// - Best Win card (full width)
/// - Avg Point Differential card (full width)
class PerformanceOverviewCard extends StatelessWidget {
  final UserModel user;

  const PerformanceOverviewCard({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    if (user.gamesPlayed == 0) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: EmptyStatsPlaceholder(
          title: AppLocalizations.of(context)!.noPerformanceData,
          message: AppLocalizations.of(context)!.playFirstGameToSeeStats,
          unlockMessage: AppLocalizations.of(context)!.playAtLeastOneGame,
          icon: Icons.show_chart,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Section label — uppercase, muted, letter-spaced (matches homepage style)
          Text(
            AppLocalizations.of(context)!.performanceOverview.toUpperCase(),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textMuted,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 12),
          // Row 1: Current ELO + Peak ELO
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: _StatCard(child: _buildCurrentEloContent(context))),
                const SizedBox(width: 12),
                Expanded(child: _StatCard(child: _buildPeakEloContent(context))),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Row 2: Win Rate + Games Played
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: _StatCard(child: _buildWinRateContent(context))),
                const SizedBox(width: 12),
                Expanded(child: _StatCard(child: _buildGamesPlayedContent(context))),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Best Win (full width)
          _StatCard(child: _buildBestWinContent(context)),
          const SizedBox(height: 12),
          // Point Differential (full width)
          if (user.pointStats != null && user.pointStats!.totalSets > 0)
            _StatCard(child: _buildPointDiffContent(context, user.pointStats!))
          else
            _StatCard(child: _buildPointDiffPlaceholder(context)),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildCurrentEloContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppLocalizations.of(context)!.currentElo,
              style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
            Icon(Icons.show_chart, size: 16,
                color: AppColors.textMuted.withValues(alpha: 0.5)),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          user.eloRating.toStringAsFixed(0),
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w600,
            color: AppColors.secondary,
          ),
        ),
      ],
    );
  }

  Widget _buildPeakEloContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppLocalizations.of(context)!.peakElo,
              style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
            const Icon(Icons.emoji_events, size: 16, color: AppColors.primary),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          user.eloPeak.toStringAsFixed(0),
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
        if (user.eloPeakDate != null) ...[
          const SizedBox(height: 4),
          Text(
            DateFormat('MMM d, yyyy').format(user.eloPeakDate!),
            style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
          ),
        ],
      ],
    );
  }

  Widget _buildWinRateContent(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppLocalizations.of(context)!.winRate,
                style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
              const SizedBox(height: 4),
              Text(
                '${(user.winRate * 100).toStringAsFixed(1)}%',
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                  color: AppColors.secondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${user.gamesWon}W - ${user.gamesLost}L',
                style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
              ),
            ],
          ),
        ),
        SizedBox(
          width: 44,
          height: 44,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 44,
                height: 44,
                child: CircularProgressIndicator(
                  value: user.winRate,
                  strokeWidth: 5,
                  backgroundColor: AppColors.divider,
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
              const Icon(Icons.emoji_events, size: 14, color: AppColors.primary),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGamesPlayedContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          AppLocalizations.of(context)!.gamesPlayed,
          style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Text(
              user.gamesPlayed.toString(),
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w600,
                color: AppColors.secondary,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.sports_volleyball,
              size: 22,
              color: AppColors.textMuted.withValues(alpha: 0.4),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBestWinContent(BuildContext context) {
    final theme = Theme.of(context);
    final bestWin = user.bestWin;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppLocalizations.of(context)!.bestWin,
              style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
            Icon(
              bestWin != null ? Icons.emoji_events : Icons.emoji_events_outlined,
              size: 16,
              color: bestWin != null
                  ? AppColors.primary
                  : AppColors.primary.withValues(alpha: 0.4),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (bestWin != null) ...[
          // Opponent names — primary value
          if (bestWin.opponentNames != null)
            Text(
              AppLocalizations.of(context)!.teamLabel(
                bestWin.opponentNames!.replaceAll(' & ', ' · '),
              ),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.secondary,
              ),
            ),
          const SizedBox(height: 4),
          // Team ELO — secondary
          Text(
            AppLocalizations.of(context)!.teamEloLabel(bestWin.avgEloString),
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textMuted.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 2),
          // ELO gained — tertiary
          Text(
            AppLocalizations.of(context)!.eloGained(bestWin.eloGainString),
            style: TextStyle(
              fontSize: 11,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ] else ...[
          Text(
            AppLocalizations.of(context)!.winGameToUnlock,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            AppLocalizations.of(context)!.beatOpponentsToTrack,
            style: TextStyle(
              fontSize: 11,
              color: AppColors.textMuted.withValues(alpha: 0.7),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPointDiffContent(BuildContext context, PointStats pointStats) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            const Icon(Icons.compare_arrows, size: 16, color: AppColors.secondary),
            const SizedBox(width: 6),
            Text(
              AppLocalizations.of(context)!.avgPointDifferential,
              style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
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
                    style: TextStyle(
                        fontSize: 11,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    pointStats.avgWinsString,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: pointStats.winningSetsCount > 0
                          ? Colors.green
                          : theme.colorScheme.onSurface.withValues(alpha: 0.3),
                    ),
                  ),
                  Text(
                    AppLocalizations.of(context)!.setsCount(pointStats.winningSetsCount),
                    style: TextStyle(
                        fontSize: 11,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.4)),
                  ),
                ],
              ),
            ),
            Container(width: 1, height: 50,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.1)),
            const SizedBox(width: 16),
            // Losing sets
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.inLosses,
                    style: TextStyle(
                        fontSize: 11,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    pointStats.avgLossesString,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: pointStats.losingSetsCount > 0
                          ? Colors.red
                          : theme.colorScheme.onSurface.withValues(alpha: 0.3),
                    ),
                  ),
                  Text(
                    AppLocalizations.of(context)!.setsCount(pointStats.losingSetsCount),
                    style: TextStyle(
                        fontSize: 11,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.4)),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          pointStats.statsSubtitle,
          style: TextStyle(
              fontSize: 11,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
        ),
      ],
    );
  }

  Widget _buildPointDiffPlaceholder(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppLocalizations.of(context)!.avgPointDiff,
              style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
            Icon(Icons.trending_up_outlined, size: 16,
                color: AppColors.textMuted.withValues(alpha: 0.4)),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          AppLocalizations.of(context)!.completeGameToUnlock,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          AppLocalizations.of(context)!.winAndLoseSetsToSee,
          style: TextStyle(
              fontSize: 11,
              color: AppColors.textMuted.withValues(alpha: 0.7)),
        ),
      ],
    );
  }
}

/// White card with shadow — matches the homepage _StatsCard style.
class _StatCard extends StatelessWidget {
  final Widget child;

  const _StatCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: child,
      ),
    );
  }
}
