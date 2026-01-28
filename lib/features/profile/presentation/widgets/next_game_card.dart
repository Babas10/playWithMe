// Widget displaying the next upcoming game for the user on the homepage.
import 'package:flutter/material.dart';
import 'package:play_with_me/core/data/models/game_model.dart';
import 'package:play_with_me/features/games/presentation/widgets/game_list_item.dart';
import 'package:play_with_me/l10n/app_localizations.dart';

/// A card widget that displays the user's next upcoming game.
///
/// Shows:
/// - The chronologically next scheduled game where user has joined
/// - Empty state if no upcoming games
/// - Reuses GameListItem widget for consistent design
class NextGameCard extends StatelessWidget {
  final GameModel? game;
  final String userId;
  final VoidCallback? onTap;

  const NextGameCard({
    super.key,
    required this.game,
    required this.userId,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Section header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            l10n.nextGame,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 8),

        // Game card or empty state
        if (game != null)
          GameListItem(
            game: game!,
            userId: userId,
            isPast: false,
            onTap: onTap ?? () {},
          )
        else
          _buildEmptyState(context, l10n),
      ],
    );
  }

  /// Builds the empty state when there are no upcoming games
  Widget _buildEmptyState(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.sports_volleyball,
                size: 48,
                color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.noGamesScheduled,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
