// Rivals card showing nemesis statistics.
import 'package:flutter/material.dart';
import 'package:play_with_me/core/data/models/user_model.dart';
import 'package:play_with_me/core/theme/app_colors.dart';
import 'package:play_with_me/features/profile/presentation/pages/head_to_head_page.dart';
import 'package:play_with_me/features/profile/presentation/widgets/empty_states/insufficient_data_placeholder.dart';
import 'package:play_with_me/l10n/app_localizations.dart';

/// Rival section: gray background, gray section label, white card.
///
/// Shows the opponent you lost to most often.
/// Tap opens HeadToHeadPage for full rivalry breakdown.
class RivalsCard extends StatelessWidget {
  final UserModel user;

  const RivalsCard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final nemesis = user.nemesis;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section label — uppercase, muted, letter-spaced
          Text(
            AppLocalizations.of(context)!.rival.toUpperCase(),
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
              onTap: nemesis != null
                  ? () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HeadToHeadPage(
                          userId: user.uid,
                          opponentId: nemesis.opponentId,
                        ),
                      ),
                    )
                  : null,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: nemesis != null
                    ? _buildNemesisData(context, nemesis)
                    : _buildEmptyState(context),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildNemesisData(BuildContext context, NemesisRecord nemesis) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Name + arrow
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              nemesis.opponentName,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Record
        Row(
          children: [
            Icon(
              Icons.sports_score,
              size: 16,
              color: AppColors.textMuted.withValues(alpha: 0.7),
            ),
            const SizedBox(width: 8),
            Text(
              nemesis.recordString,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.onSurface.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '(${AppLocalizations.of(context)!.matchups(nemesis.gamesPlayed)})',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textMuted.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Win rate
        Row(
          children: [
            Icon(
              Icons.percent,
              size: 16,
              color: AppColors.textMuted.withValues(alpha: 0.7),
            ),
            const SizedBox(width: 8),
            Text(
              AppLocalizations.of(
                context,
              )!.winRateLabel(nemesis.winRate.toStringAsFixed(1)),
              style: TextStyle(
                fontSize: 13,
                color: nemesis.winRate < 50.0
                    ? theme.colorScheme.error
                    : AppColors.onSurface.withValues(alpha: 0.8),
                fontWeight: nemesis.winRate < 50.0
                    ? FontWeight.w600
                    : FontWeight.normal,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Tap hint chip
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.secondary,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            AppLocalizations.of(context)!.tapForFullBreakdown,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return EmptyStatsPlaceholder(
      title: AppLocalizations.of(context)!.noNemesisYet,
      message: AppLocalizations.of(context)!.playGamesAgainstSameOpponent,
      icon: Icons.emoji_events_outlined,
      unlockMessage: AppLocalizations.of(context)!.faceOpponentThreeTimes,
    );
  }
}
