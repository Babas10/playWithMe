// Role-based performance card showing adaptability stats across different team contexts.
import 'package:flutter/material.dart';
import 'package:play_with_me/core/data/models/user_model.dart';
import 'package:play_with_me/core/theme/app_colors.dart';
import 'package:play_with_me/l10n/app_localizations.dart';

/// Adaptability stats section: gray background, gray section label, white card.
///
/// Shows win rates when player is:
/// - Carry: Highest ELO on team (leading/carrying the team)
/// - Weak-Link: Lowest ELO on team (playing with stronger teammates)
/// - Balanced: Middle or tied ELO (balanced team composition)
class RoleBasedPerformanceCard extends StatelessWidget {
  final UserModel user;

  const RoleBasedPerformanceCard({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    final stats = user.roleBasedStats;
    final hasData = stats != null && stats.hasData;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section label — uppercase, muted, letter-spaced
          Text(
            AppLocalizations.of(context)!.adaptabilityStats.toUpperCase(),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textMuted,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 12),
          // White card — always expanded
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: hasData
                  ? _buildStatsContent(context, stats)
                  : _buildEmptyState(context),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildStatsContent(BuildContext context, RoleBasedStats stats) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.seeHowYouPerform,
          style: TextStyle(
            fontSize: 13,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 20),

        if (stats.carry.games > 0) ...[
          _RoleStatRow(
            role: AppLocalizations.of(context)!.leadingTheTeam,
            icon: Icons.emoji_events,
            color: AppColors.primary,
            stats: stats.carry,
            description: AppLocalizations.of(context)!.whenHighestRated,
          ),
          const SizedBox(height: 16),
        ],

        if (stats.weakLink.games > 0) ...[
          _RoleStatRow(
            role: AppLocalizations.of(context)!.playingWithStrongerPartners,
            icon: Icons.people,
            color: AppColors.secondary,
            stats: stats.weakLink,
            description: AppLocalizations.of(context)!.whenMoreExperiencedTeammates,
          ),
          const SizedBox(height: 16),
        ],

        if (stats.balanced.games > 0) ...[
          _RoleStatRow(
            role: AppLocalizations.of(context)!.balancedTeams,
            icon: Icons.balance,
            color: AppColors.primary,
            stats: stats.balanced,
            description: AppLocalizations.of(context)!.whenSimilarlyRatedTeammates,
          ),
          const SizedBox(height: 16),
        ],
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.seeHowYouPerform,
          style: TextStyle(
            fontSize: 13,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Icon(
              Icons.analytics_outlined,
              size: 32,
              color: AppColors.textMuted.withValues(alpha: 0.35),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.adaptabilityStatsLocked,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    AppLocalizations.of(context)!.playMoreGamesToSeeRoles,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Display row for a single role's statistics.
class _RoleStatRow extends StatelessWidget {
  final String role;
  final IconData icon;
  final Color color;
  final RoleStats stats;
  final String description;

  const _RoleStatRow({
    required this.role,
    required this.icon,
    required this.color,
    required this.stats,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Text(role, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${stats.recordString} (${stats.games} games)',
              style: const TextStyle(color: AppColors.secondary),
            ),
            Text(
              stats.winRateString,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.secondary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
