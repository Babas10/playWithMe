// Widget displaying the next upcoming training session for the user on the homepage.
import 'package:flutter/material.dart';
import 'package:play_with_me/core/data/models/training_session_model.dart';
import 'package:play_with_me/features/games/presentation/widgets/training_session_list_item.dart';
import 'package:play_with_me/l10n/app_localizations.dart';

/// A card widget that displays the user's next upcoming training session.
///
/// Shows:
/// - The chronologically next scheduled training session where user has joined
/// - Empty state if no upcoming training sessions
/// - Reuses TrainingSessionListItem widget for consistent design
class NextTrainingSessionCard extends StatelessWidget {
  final TrainingSessionModel? session;
  final String userId;
  final VoidCallback? onTap;

  const NextTrainingSessionCard({
    super.key,
    required this.session,
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
            l10n.nextTrainingSession,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 8),

        // Training session card or empty state
        if (session != null)
          TrainingSessionListItem(
            session: session!,
            userId: userId,
            isPast: false,
            onTap: onTap ?? () {},
          )
        else
          _buildEmptyState(context, l10n),
      ],
    );
  }

  /// Builds the empty state when there are no upcoming training sessions
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
                Icons.fitness_center,
                size: 48,
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.noTrainingSessionsScheduled,
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
