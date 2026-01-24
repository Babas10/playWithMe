// Partners card showing best partner statistics.
import 'package:flutter/material.dart';
import 'package:play_with_me/core/data/models/user_model.dart';
import 'package:play_with_me/features/profile/presentation/pages/partner_detail_page.dart';
import 'package:play_with_me/l10n/app_localizations.dart';

/// A card widget displaying best partner statistics.
///
/// Shows the partner with the highest win rate (minimum 5 games threshold).
/// Tap opens PartnerDetailPage for full breakdown (Phase 3).
class PartnersCard extends StatelessWidget {
  final UserModel user;

  const PartnersCard({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final bestPartner = _findBestPartner();

    return Card(
      margin: const EdgeInsets.all(16.0),
      child: InkWell(
        onTap: bestPartner != null
            ? () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => PartnerDetailPage(
                      userId: user.uid,
                      partnerId: bestPartner.userId,
                    ),
                  ),
                );
              }
            : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with icon
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Text(
                        '🤝 ',
                        style: TextStyle(fontSize: 24),
                      ),
                      Text(
                        l10n.bestPartner,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  if (bestPartner != null)
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              // Partner info or empty state
              if (bestPartner != null)
                _buildPartnerInfo(context, bestPartner)
              else
                _buildEmptyState(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPartnerInfo(BuildContext context, _PartnerData partner) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final winRate = (partner.gamesWon / partner.gamesPlayed * 100).toStringAsFixed(1);

    return Row(
      children: [
        // Partner avatar placeholder
        CircleAvatar(
          radius: 30,
          backgroundColor: theme.colorScheme.primaryContainer,
          child: Icon(
            Icons.person,
            size: 30,
            color: theme.colorScheme.onPrimaryContainer,
          ),
        ),
        const SizedBox(width: 16),
        // Partner stats
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                partner.displayName,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                l10n.winRatePercent(winRate),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.green,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                l10n.winsLossesGames(partner.gamesWon, partner.gamesPlayed - partner.gamesWon, partner.gamesPlayed),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
        // Win rate badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.trending_up,
                size: 16,
                color: Colors.green,
              ),
              const SizedBox(width: 4),
              Text(
                '$winRate%',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.people_outline,
              size: 48,
              color: theme.colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.noPartnerDataYet,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: theme.colorScheme.primary.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.lock_outline,
                    size: 14,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    l10n.playGamesWithTeammate,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Finds the best partner from teammateStats.
  ///
  /// Criteria:
  /// - Minimum 5 games played together
  /// - Highest win rate
  /// - If tie, use most games played as tiebreaker
  _PartnerData? _findBestPartner() {
    if (user.teammateStats.isEmpty) return null;

    const minGames = 5;
    _PartnerData? best;
    double bestWinRate = -1;

    for (final entry in user.teammateStats.entries) {
      final userId = entry.key;
      final stats = entry.value as Map<String, dynamic>;
      final gamesWon = stats['gamesWon'] as int? ?? 0;
      final gamesPlayed = stats['gamesPlayed'] as int? ?? 0;
      final displayName = stats['teammateName'] as String? ?? 'Unknown Player';

      if (gamesPlayed < minGames) continue;

      final winRate = gamesWon / gamesPlayed;

      if (winRate > bestWinRate ||
          (winRate == bestWinRate && best != null && gamesPlayed > best.gamesPlayed)) {
        bestWinRate = winRate;
        best = _PartnerData(
          userId: userId,
          displayName: displayName,
          gamesWon: gamesWon,
          gamesPlayed: gamesPlayed,
        );
      }
    }

    return best;
  }
}

/// Internal data class for partner information.
class _PartnerData {
  final String userId;
  final String displayName;
  final int gamesWon;
  final int gamesPlayed;

  _PartnerData({
    required this.userId,
    required this.displayName,
    required this.gamesWon,
    required this.gamesPlayed,
  });
}
