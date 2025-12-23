// Error state placeholder for stat widgets.
import 'package:flutter/material.dart';

/// An error state widget for when stat calculation or data fetching fails.
///
/// Provides clear error messaging and optional retry functionality.
class StatsErrorPlaceholder extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onRetry;
  final IconData icon;

  const StatsErrorPlaceholder({
    super.key,
    this.title = 'Unable to Load Stats',
    this.message = 'Something went wrong while loading your statistics.',
    this.onRetry,
    this.icon = Icons.error_outline,
  });

  /// Network error variant.
  const StatsErrorPlaceholder.network({
    super.key,
    this.title = 'Network Error',
    this.message = 'Check your connection and try again.',
    this.onRetry,
  }) : icon = Icons.wifi_off;

  /// Permission error variant.
  const StatsErrorPlaceholder.permission({
    super.key,
    this.title = 'Access Denied',
    this.message = 'You don\'t have permission to view these statistics.',
    this.onRetry,
  }) : icon = Icons.lock_outline;

  /// Calculation error variant.
  const StatsErrorPlaceholder.calculation({
    super.key,
    this.title = 'Calculation Error',
    this.message = 'Unable to calculate statistics. Please try again later.',
    this.onRetry,
  }) : icon = Icons.calculate_outlined;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Error icon
            Icon(
              icon,
              size: 56,
              color: theme.colorScheme.error.withOpacity(0.7),
            ),
            const SizedBox(height: 20),
            // Title
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            // Message
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
            // Retry button (if provided)
            if (onRetry != null) ...[
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Retry'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: theme.colorScheme.primary,
                  side: BorderSide(color: theme.colorScheme.primary),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Compact error placeholder for smaller stat widgets.
class CompactStatsError extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const CompactStatsError({
    super.key,
    this.message = 'Error',
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Container(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 20,
              color: theme.colorScheme.error.withOpacity(0.7),
            ),
            const SizedBox(height: 4),
            Text(
              message,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 4),
              TextButton(
                onPressed: onRetry,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  minimumSize: const Size(0, 0),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Retry',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
