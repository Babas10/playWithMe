// Full ELO history screen with comprehensive rating timeline.
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:play_with_me/core/data/models/rating_history_entry.dart';
import 'package:play_with_me/core/services/service_locator.dart';
import 'package:play_with_me/core/domain/repositories/user_repository.dart';
import 'package:play_with_me/features/profile/presentation/bloc/elo_history/elo_history_bloc.dart';
import 'package:play_with_me/features/profile/presentation/bloc/elo_history/elo_history_event.dart';
import 'package:play_with_me/features/profile/presentation/bloc/elo_history/elo_history_state.dart';
import 'package:intl/intl.dart';

class FullEloHistoryPage extends StatelessWidget {
  final String userId;

  const FullEloHistoryPage({
    super.key,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => EloHistoryBloc(
        userRepository: sl<UserRepository>(),
      )..add(EloHistoryEvent.loadHistory(userId: userId, limit: 100)),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('ELO History'),
          actions: [
            BlocBuilder<EloHistoryBloc, EloHistoryState>(
              builder: (context, state) {
                if (state is! EloHistoryLoaded) return const SizedBox.shrink();

                if (state.filterStartDate != null) {
                  return IconButton(
                    icon: const Icon(Icons.filter_alt_off),
                    tooltip: 'Clear filter',
                    onPressed: () {
                      context.read<EloHistoryBloc>().add(
                            const EloHistoryEvent.clearFilter(),
                          );
                    },
                  );
                }

                return IconButton(
                  icon: const Icon(Icons.filter_alt),
                  tooltip: 'Filter by date',
                  onPressed: () => _showDateRangePicker(context),
                );
              },
            ),
          ],
        ),
        body: BlocBuilder<EloHistoryBloc, EloHistoryState>(
          builder: (context, state) {
            return state.when(
              initial: () => const SizedBox.shrink(),
              loading: () => const Center(child: CircularProgressIndicator()),
              loaded: (history, filteredHistory, startDate, endDate) =>
                  _buildLoadedView(context, filteredHistory, startDate, endDate),
              error: (message) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(message, textAlign: TextAlign.center),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _showDateRangePicker(BuildContext context) async {
    final bloc = context.read<EloHistoryBloc>();
    final state = bloc.state;
    if (state is! EloHistoryLoaded) return;

    final now = DateTime.now();
    final firstGameDate = state.history.isNotEmpty
        ? state.history.last.timestamp
        : now.subtract(const Duration(days: 365));

    final picked = await showDateRangePicker(
      context: context,
      firstDate: firstGameDate,
      lastDate: now,
      initialDateRange: state.filterStartDate != null && state.filterEndDate != null
          ? DateTimeRange(start: state.filterStartDate!, end: state.filterEndDate!)
          : null,
    );

    if (picked != null && context.mounted) {
      bloc.add(EloHistoryEvent.filterByDateRange(
        startDate: picked.start,
        endDate: picked.end,
      ));
    }
  }

  Widget _buildLoadedView(
    BuildContext context,
    List<RatingHistoryEntry> history,
    DateTime? filterStartDate,
    DateTime? filterEndDate,
  ) {
    final theme = Theme.of(context);

    if (history.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.timeline,
              size: 64,
              color: theme.colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No ELO history yet',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Play some games to see your rating history',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      );
    }

    // Calculate stats from visible history
    final totalChange = history.isNotEmpty
        ? history.first.newRating - history.last.oldRating
        : 0.0;
    final avgChange = history.isNotEmpty ? totalChange / history.length : 0.0;
    final wins = history.where((e) => e.won).length;
    final losses = history.length - wins;

    return Column(
      children: [
        // Stats summary
        Container(
          padding: const EdgeInsets.all(16.0),
          color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatChip(
                context,
                'Games',
                history.length.toString(),
                Colors.blue,
              ),
              _buildStatChip(
                context,
                'W-L',
                '$wins-$losses',
                Colors.orange,
              ),
              _buildStatChip(
                context,
                'Total',
                totalChange >= 0
                    ? '+${totalChange.toStringAsFixed(0)}'
                    : totalChange.toStringAsFixed(0),
                totalChange >= 0 ? Colors.green : Colors.red,
              ),
              _buildStatChip(
                context,
                'Avg',
                avgChange >= 0
                    ? '+${avgChange.toStringAsFixed(1)}'
                    : avgChange.toStringAsFixed(1),
                avgChange >= 0 ? Colors.green : Colors.red,
              ),
            ],
          ),
        ),

        // Filter indicator
        if (filterStartDate != null && filterEndDate != null)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            color: theme.colorScheme.primaryContainer,
            child: Row(
              children: [
                Icon(
                  Icons.filter_alt,
                  size: 16,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Showing ${DateFormat.yMMMd().format(filterStartDate)} - ${DateFormat.yMMMd().format(filterEndDate)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),

        // History list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: history.length,
            itemBuilder: (context, index) => _buildHistoryTile(
              context,
              history[index],
              index == 0, // Most recent
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatChip(
    BuildContext context,
    String label,
    String value,
    Color color,
  ) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryTile(
    BuildContext context,
    RatingHistoryEntry entry,
    bool isLatest,
  ) {
    final theme = Theme.of(context);
    final resultColor = entry.won ? Colors.green : Colors.red;
    final changeColor = entry.isGain ? Colors.green : Colors.red;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isLatest ? 4 : 1,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: isLatest
              ? Border.all(color: theme.colorScheme.primary, width: 2)
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Result indicator
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: resultColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: resultColor, width: 2),
                ),
                child: Center(
                  child: Text(
                    entry.won ? 'W' : 'L',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: resultColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Game details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'vs ${entry.opponentTeam}',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('MMM d, y').format(entry.timestamp),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),

              // Rating change
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        entry.isGain ? Icons.trending_up : Icons.trending_down,
                        color: changeColor,
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        entry.formattedChange,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: changeColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    entry.formattedNewRating,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
