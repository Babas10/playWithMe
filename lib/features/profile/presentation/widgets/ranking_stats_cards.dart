// Displays three ranking stat cards: global rank, percentile, and friends rank (Story 302.5).
import 'package:flutter/material.dart';
import 'package:play_with_me/core/data/models/user_ranking.dart';
import 'package:play_with_me/l10n/app_localizations.dart';

/// Three stat cards showing global rank, percentile, and friends rank.
///
/// Displayed above the ELO progress chart.
class RankingStatsCards extends StatelessWidget {
  final UserRanking? ranking;
  final VoidCallback? onAddFriendsTap;

  const RankingStatsCards({
    super.key,
    required this.ranking,
    this.onAddFriendsTap,
  });

  @override
  Widget build(BuildContext context) {
    // Empty state: No ranking data
    if (ranking == null) {
      return _buildEmptyState(context);
    }

    // Always use horizontal layout on mobile (most phones are 360-430px wide)
    // Only stack vertically on very narrow screens (< 280px)
    return LayoutBuilder(
      builder: (context, constraints) {
        // Stack vertically only on very narrow screens
        if (constraints.maxWidth < 280) {
          return Column(
            children: [
              _GlobalRankCard(ranking: ranking!),
              const SizedBox(height: 8),
              _PercentileCard(ranking: ranking!),
              const SizedBox(height: 8),
              _FriendsRankCard(
                ranking: ranking!,
                onAddFriendsTap: onAddFriendsTap,
              ),
            ],
          );
        }

        // Horizontal layout for normal mobile and wider screens
        return Row(
          children: [
            Expanded(child: _GlobalRankCard(ranking: ranking!)),
            const SizedBox(width: 8),
            Expanded(child: _PercentileCard(ranking: ranking!)),
            const SizedBox(width: 8),
            Expanded(
              child: _FriendsRankCard(
                ranking: ranking!,
                onAddFriendsTap: onAddFriendsTap,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.lock_outline,
            size: 20,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Text(
            AppLocalizations.of(context)!.playGamesToUnlockRankings,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// Global ranking card
class _GlobalRankCard extends StatelessWidget {
  final UserRanking ranking;

  const _GlobalRankCard({required this.ranking});

  @override
  Widget build(BuildContext context) {
    return _RankingStatCard(
      icon: Icons.public,
      iconColor: Colors.blue,
      label: AppLocalizations.of(context)!.globalRank,
      value: ranking.globalRankDisplay,
    );
  }
}

/// Percentile card
class _PercentileCard extends StatelessWidget {
  final UserRanking ranking;

  const _PercentileCard({required this.ranking});

  @override
  Widget build(BuildContext context) {
    return _RankingStatCard(
      icon: Icons.trending_up,
      iconColor: Colors.green,
      label: AppLocalizations.of(context)!.percentile,
      value: ranking.percentileDisplay,
    );
  }
}

/// Friends ranking card
class _FriendsRankCard extends StatelessWidget {
  final UserRanking ranking;
  final VoidCallback? onAddFriendsTap;

  const _FriendsRankCard({
    required this.ranking,
    this.onAddFriendsTap,
  });

  @override
  Widget build(BuildContext context) {
    // Empty state: No friends
    if (ranking.friendsRank == null || ranking.totalFriends == null) {
      return _RankingStatCard(
        icon: Icons.people,
        iconColor: Colors.orange,
        label: AppLocalizations.of(context)!.friendsRank,
        value: AppLocalizations.of(context)!.addFriendsAction,
        isActionable: true,
        onTap: onAddFriendsTap,
      );
    }

    return _RankingStatCard(
      icon: Icons.people,
      iconColor: Colors.orange,
      label: AppLocalizations.of(context)!.friendsRank,
      value: ranking.friendsRankDisplay!,
    );
  }
}

/// Base stat card widget
class _RankingStatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final bool isActionable;
  final VoidCallback? onTap;

  const _RankingStatCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    this.isActionable = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final card = Container(
      height: 85,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 20, color: iconColor),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 11,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Flexible(
            child: Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isActionable
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );

    if (isActionable && onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: card,
      );
    }

    return card;
  }
}
