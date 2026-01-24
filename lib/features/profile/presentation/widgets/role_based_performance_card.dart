// Role-based performance card showing adaptability stats across different team contexts.
import 'package:flutter/material.dart';
import 'package:play_with_me/core/data/models/user_model.dart';
import 'package:play_with_me/l10n/app_localizations.dart';

/// A collapsible card widget displaying role-based performance metrics.
///
/// Shows win rates when player is:
/// - Weak-Link: Lowest ELO on team (playing with stronger teammates)
/// - Carry: Highest ELO on team (leading/carrying the team)
/// - Balanced: Middle or tied ELO (balanced team composition)
///
/// Purpose: Show adaptability and resilience with positive framing.
class RoleBasedPerformanceCard extends StatefulWidget {
  final UserModel user;

  const RoleBasedPerformanceCard({
    super.key,
    required this.user,
  });

  @override
  State<RoleBasedPerformanceCard> createState() =>
      _RoleBasedPerformanceCardState();
}

class _RoleBasedPerformanceCardState extends State<RoleBasedPerformanceCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final stats = widget.user.roleBasedStats;

    // Check if there's any role-based data
    final hasData = stats != null && stats.hasData;

    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header (always visible)
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          Icons.psychology,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        Flexible(
                          child: Text(
                            AppLocalizations.of(context)!.adaptabilityStats,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          AppLocalizations.of(context)!.advanced,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        _isExpanded
                            ? Icons.expand_less
                            : Icons.expand_more,
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Expandable content
          if (_isExpanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: hasData
                  ? _buildStatsContent(context, stats as RoleBasedStats)
                  : _buildEmptyState(context),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatsContent(BuildContext context, RoleBasedStats stats) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Description
        Text(
          AppLocalizations.of(context)!.seeHowYouPerform,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 20),

        // Carry Stats (if available)
        if (stats.carry.games > 0) ...  [
          _RoleStatRow(
            role: AppLocalizations.of(context)!.leadingTheTeam,
            icon: Icons.emoji_events,
            color: Colors.amber,
            stats: stats.carry,
            description: AppLocalizations.of(context)!.whenHighestRated,
          ),
          const SizedBox(height: 16),
        ],

        // Weak Link Stats (reframed positively)
        if (stats.weakLink.games > 0) ...[
          _RoleStatRow(
            role: AppLocalizations.of(context)!.playingWithStrongerPartners,
            icon: Icons.people,
            color: Colors.blue,
            stats: stats.weakLink,
            description: AppLocalizations.of(context)!.whenMoreExperiencedTeammates,
          ),
          const SizedBox(height: 16),
        ],

        // Balanced Stats
        if (stats.balanced.games > 0) ...[
          _RoleStatRow(
            role: AppLocalizations.of(context)!.balancedTeams,
            icon: Icons.balance,
            color: Colors.green,
            stats: stats.balanced,
            description: AppLocalizations.of(context)!.whenSimilarlyRatedTeammates,
          ),
          const SizedBox(height: 16),
        ],

        // Insight Message
        _InsightMessage(insight: stats.getInsight()),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Description
        Text(
          AppLocalizations.of(context)!.seeHowYouPerform,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 20),
        // Empty state placeholder
        Container(
          padding: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Column(
              children: [
                Icon(
                  Icons.analytics_outlined,
                  size: 48,
                  color: theme.colorScheme.onSurface.withOpacity(0.3),
                ),
                const SizedBox(height: 12),
                Text(
                  AppLocalizations.of(context)!.adaptabilityStatsLocked,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context)!.playMoreGamesToSeeRoles,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
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
            Text('${stats.recordString} (${stats.games} games)'),
            Text(
              stats.winRateString,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: stats.winRate >= 0.5 ? Colors.green : Colors.orange,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Personalized insight message based on role performance.
class _InsightMessage extends StatelessWidget {
  final String insight;

  const _InsightMessage({required this.insight});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.lightbulb_outline,
            size: 20,
            color: Colors.blue,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              insight,
              style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic),
            ),
          ),
        ],
      ),
    );
  }
}
