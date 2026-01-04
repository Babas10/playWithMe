import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:play_with_me/core/data/models/best_elo_record.dart';
import 'package:play_with_me/core/domain/entities/time_period.dart';

/// Highlight card displaying the best ELO achieved in the selected time period.
///
/// Shows:
/// - Trophy icon
/// - ELO value (large)
/// - Date achieved
/// - Empty state when no data available
class BestEloHighlightCard extends StatelessWidget {
  final BestEloRecord? bestElo;
  final TimePeriod timePeriod;
  final VoidCallback? onTap;

  const BestEloHighlightCard({
    super.key,
    required this.bestElo,
    required this.timePeriod,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Empty state: No ELO data
    if (bestElo == null) {
      return _buildEmptyState(context);
    }

    return _buildCard(context);
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.emoji_events_outlined,
              size: 18,
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
            ),
            const SizedBox(width: 8),
            Text(
              'No games in this period',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormatter = DateFormat('MMM d, yyyy');

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: theme.colorScheme.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.colorScheme.primary.withOpacity(0.04),
                theme.colorScheme.primary.withOpacity(0.01),
              ],
            ),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Row(
            children: [
              // Trophy icon
              Icon(
                Icons.emoji_events,
                size: 20,
                color: Colors.amber[700],
              ),
              const SizedBox(width: 12),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Best ELO ${_getPeriodLabel()}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      dateFormatter.format(bestElo!.date),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              // ELO Value
              Text(
                bestElo!.elo.toStringAsFixed(0),
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                  fontSize: 28,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getPeriodLabel() {
    switch (timePeriod) {
      case TimePeriod.thirtyDays:
        return 'This Month';
      case TimePeriod.ninetyDays:
        return 'Past 90 Days';
      case TimePeriod.oneYear:
        return 'This Year';
      case TimePeriod.allTime:
        return 'All Time';
    }
  }
}
