// Rivals card showing nemesis statistics.
import 'package:flutter/material.dart';
import 'package:play_with_me/core/data/models/user_model.dart';

/// A card widget displaying rival/nemesis statistics.
///
/// Shows the opponent you lost to most often.
/// Tap opens HeadToHeadPage for full rivalry breakdown (Phase 3).
///
/// TODO: Implement nemesis tracking in backend.
/// For now, shows "Coming Soon" placeholder.
class RivalsCard extends StatelessWidget {
  final UserModel user;
  final VoidCallback? onTap;

  const RivalsCard({
    super.key,
    required this.user,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.all(16.0),
      child: InkWell(
        onTap: onTap,
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
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Coming soon state
              _buildComingSoonState(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildComingSoonState(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.sports_kabaddi,
              size: 48,
              color: theme.colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 12),
            Text(
              'Rival Tracking Coming Soon',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Track your toughest opponents and head-to-head records',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
