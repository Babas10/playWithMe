// Rivals card showing nemesis statistics.
import 'package:flutter/material.dart';
import 'package:play_with_me/core/data/models/user_model.dart';
import 'package:play_with_me/features/profile/presentation/pages/head_to_head_page.dart';
import 'package:play_with_me/features/profile/presentation/widgets/empty_states/insufficient_data_placeholder.dart';

/// A card widget displaying rival/nemesis statistics.
///
/// Shows the opponent you lost to most often.
/// Tap opens HeadToHeadPage for full rivalry breakdown.
class RivalsCard extends StatelessWidget {
  final UserModel user;

  const RivalsCard({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final nemesis = user.nemesis;

    return Card(
      margin: const EdgeInsets.all(16.0),
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
                      Text(
                        '🆚 ',
                        style: const TextStyle(fontSize: 24),
                      ),
                      Text(
                        'Rival',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  if (nemesis != null)
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              // Nemesis data or empty state
              if (nemesis != null)
                _buildNemesisData(context, nemesis)
              else
                _buildEmptyState(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNemesisData(BuildContext context, NemesisRecord nemesis) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Nemesis name
        Text(
          nemesis.opponentName,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),

        // Record
        Row(
          children: [
            Icon(
              Icons.sports_score,
              size: 16,
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            const SizedBox(width: 8),
            Text(
              nemesis.recordString,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.8),
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '(${nemesis.gamesPlayed} matchups)',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
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
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            const SizedBox(width: 8),
            Text(
              'Win Rate: ${nemesis.winRate.toStringAsFixed(1)}%',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: nemesis.winRate < 50.0
                    ? theme.colorScheme.error
                    : theme.colorScheme.onSurface.withOpacity(0.8),
                fontWeight: nemesis.winRate < 50.0 ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Tap hint
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
                Icons.info_outline,
                size: 14,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 6),
              Text(
                'Tap for full breakdown',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return EmptyStatsPlaceholder(
      title: 'No Nemesis Yet',
      message: 'Play at least 3 games against the same opponent to track your toughest matchup.',
      icon: Icons.emoji_events_outlined,
      unlockMessage: 'Face the same opponent 3+ times',
    );
  }
}
