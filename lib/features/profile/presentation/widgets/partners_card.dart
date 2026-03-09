// Partners card showing best partner statistics.
import 'package:flutter/material.dart';
import 'package:play_with_me/core/data/models/user_model.dart';
import 'package:play_with_me/core/theme/app_colors.dart';
import 'package:play_with_me/features/profile/presentation/pages/partner_detail_page.dart';
import 'package:play_with_me/l10n/app_localizations.dart';

/// Best partner section: gray background, gray section label, white card.
///
/// Shows the partner with the highest win rate (minimum 5 games threshold).
/// Tap opens PartnerDetailPage for full breakdown.
class PartnersCard extends StatelessWidget {
  final UserModel user;

  const PartnersCard({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bestPartner = _findBestPartner();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section label — uppercase, muted, letter-spaced
          Text(
            l10n.bestPartner.toUpperCase(),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textMuted,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 12),
          // White card
          Card(
            margin: EdgeInsets.zero,
            child: InkWell(
              onTap: bestPartner != null
                  ? () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => PartnerDetailPage(
                            userId: user.uid,
                            partnerId: bestPartner.userId,
                          ),
                        ),
                      )
                  : null,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: bestPartner != null
                    ? _buildPartnerInfo(context, bestPartner)
                    : _buildEmptyState(context),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildPartnerInfo(BuildContext context, _PartnerData partner) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final winRate =
        (partner.gamesWon / partner.gamesPlayed * 100).toStringAsFixed(1);

    return Row(
      children: [
        // Partner avatar
        CircleAvatar(
          radius: 28,
          backgroundColor: AppColors.secondary.withValues(alpha: 0.1),
          child: const Icon(Icons.person, size: 28, color: AppColors.secondary),
        ),
        const SizedBox(width: 16),
        // Partner stats
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                partner.displayName,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                l10n.winRatePercent(winRate),
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.green,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                l10n.winsLossesGames(
                  partner.gamesWon,
                  partner.gamesPlayed - partner.gamesWon,
                  partner.gamesPlayed,
                ),
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),
        // Win rate badge + arrow
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.trending_up, size: 14, color: Colors.green),
                  const SizedBox(width: 4),
                  Text(
                    '$winRate%',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Row(
      children: [
        Icon(
          Icons.people_outline,
          size: 32,
          color: AppColors.textMuted.withValues(alpha: 0.35),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.noPartnerDataYet,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                l10n.playGamesWithTeammate,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

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
      final displayName =
          stats['teammateName'] as String? ?? 'Unknown Player';

      if (gamesPlayed < minGames) continue;

      final winRate = gamesWon / gamesPlayed;

      if (winRate > bestWinRate ||
          (winRate == bestWinRate &&
              best != null &&
              gamesPlayed > best.gamesPlayed)) {
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
