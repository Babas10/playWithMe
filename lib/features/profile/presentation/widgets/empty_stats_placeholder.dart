// Empty state placeholder for users with no game data.
import 'package:flutter/material.dart';

/// A friendly empty state widget for users who haven't played any games yet.
///
/// Shows an encouraging message and clear unlock criteria.
/// Avoids misleading zeros or complex calculations.
class EmptyStatsPlaceholder extends StatelessWidget {
  final String title;
  final String message;
  final String? unlockMessage;
  final IconData icon;

  const EmptyStatsPlaceholder({
    super.key,
    this.title = 'No Stats Yet',
    this.message = 'Start playing games to see your statistics!',
    this.unlockMessage,
    this.icon = Icons.insert_chart_outlined,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48.0, horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Icon
            Icon(
              icon,
              size: 64,
              color: theme.colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            // Title
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            // Message
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            // Unlock message (if provided)
            if (unlockMessage != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12.0,
                ),
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
                      size: 16,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        unlockMessage!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Variant for insufficient data scenarios (e.g., "Play more games to unlock").
class InsufficientDataPlaceholder extends StatelessWidget {
  final String featureName;
  final String requirement;
  final IconData icon;

  const InsufficientDataPlaceholder({
    super.key,
    required this.featureName,
    required this.requirement,
    this.icon = Icons.info_outline,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyStatsPlaceholder(
      title: '$featureName Locked',
      message: 'This feature requires more game data.',
      unlockMessage: requirement,
      icon: icon,
    );
  }
}
