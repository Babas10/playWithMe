// Momentum and consistency card showing streak and monthly improvement.
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:play_with_me/core/data/models/rating_history_entry.dart';
import 'package:play_with_me/core/data/models/user_model.dart';
import 'package:play_with_me/core/domain/repositories/user_repository.dart';
import 'package:play_with_me/core/services/service_locator.dart';
import 'package:play_with_me/features/profile/presentation/bloc/elo_history/elo_history_bloc.dart';
import 'package:play_with_me/features/profile/presentation/bloc/elo_history/elo_history_event.dart';
import 'package:play_with_me/features/profile/presentation/bloc/elo_history/elo_history_state.dart';
import 'package:play_with_me/features/profile/presentation/bloc/player_stats/player_stats_bloc.dart';
import 'package:play_with_me/features/profile/presentation/bloc/player_stats/player_stats_event.dart';
import 'package:play_with_me/features/profile/presentation/bloc/player_stats/player_stats_state.dart';
import 'package:play_with_me/features/profile/presentation/widgets/monthly_improvement_chart.dart';
import 'package:play_with_me/features/profile/presentation/widgets/ranking_stats_cards.dart';
import 'package:play_with_me/features/profile/presentation/widgets/time_period_selector.dart';

/// A card widget displaying momentum and consistency metrics.
///
/// Includes:
/// - Current win streak with longest streak (optional secondary line)
/// - Time period selector for filtering (Story 302.3)
/// - Monthly improvement chart for long-term progress tracking (Story 302.4)
class MomentumConsistencyCard extends StatelessWidget {
  final UserModel user;
  final List<RatingHistoryEntry> ratingHistory;

  const MomentumConsistencyCard({
    super.key,
    required this.user,
    required this.ratingHistory,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => EloHistoryBloc(
            userRepository: sl<UserRepository>(),
          )..add(EloHistoryEvent.loadHistory(userId: user.uid)),
        ),
        BlocProvider(
          create: (context) => PlayerStatsBloc(
            userRepository: sl<UserRepository>(),
          )..add(LoadPlayerStats(user.uid)), // Story 302.5: Load stats (ranking auto-loads via listener)
        ),
      ],
      child: Card(
        margin: const EdgeInsets.all(16.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Momentum & Consistency',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              // Current Streak
              _buildStreakSection(context),
              const SizedBox(height: 24),
              // Monthly Progress with Time Period Selector
              Text(
                'ELO Progress',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              // Ranking Stats Cards (Story 302.5) - Displayed above time period selector
              BlocListener<PlayerStatsBloc, PlayerStatsState>(
                listener: (context, statsState) {
                  // Auto-load ranking when stats are loaded
                  if (statsState is PlayerStatsLoaded &&
                      statsState.ranking == null) {
                    context
                        .read<PlayerStatsBloc>()
                        .add(LoadRanking(user.uid));
                  }
                },
                child: BlocBuilder<PlayerStatsBloc, PlayerStatsState>(
                  builder: (context, statsState) {
                    if (statsState is PlayerStatsLoaded) {
                      return Column(
                        children: [
                          RankingStatsCards(
                            ranking: statsState.ranking,
                            onAddFriendsTap: () {
                              // Navigate to friends page
                              Navigator.pushNamed(context, '/friends');
                            },
                          ),
                          const SizedBox(height: 16),
                        ],
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
              // Time Period Selector (Story 302.3)
              BlocBuilder<EloHistoryBloc, EloHistoryState>(
                builder: (context, state) {
                  if (state is! EloHistoryLoaded) return const SizedBox.shrink();

                  return Column(
                    children: [
                      TimePeriodSelector(
                        selectedPeriod: state.selectedPeriod,
                        onPeriodChanged: (period) {
                          context.read<EloHistoryBloc>().add(
                                EloHistoryEvent.filterByPeriod(period),
                              );
                        },
                      ),
                      const SizedBox(height: 16),
                      // Enhanced Chart (Story 302.4)
                      MonthlyImprovementChart(
                        ratingHistory: state.filteredHistory,
                        currentElo: user.eloRating,
                        timePeriod: state.selectedPeriod,
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStreakSection(BuildContext context) {
    final theme = Theme.of(context);
    final hasStreak = user.currentStreak != 0;

    if (!hasStreak) {
      return _buildNoStreakState(context);
    }

    final isWinning = user.currentStreak > 0;
    final streakValue = user.currentStreak.abs();
    final streakColor = isWinning ? Colors.green : Colors.red;
    final streakIcon = isWinning ? Icons.trending_up : Icons.trending_down;
    final streakEmoji = isWinning ? '🔥' : '❄️';
    final streakLabel = isWinning ? 'Win Streak' : 'Loss Streak';

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: streakColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: streakColor.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          // Emoji
          Text(
            streakEmoji,
            style: const TextStyle(fontSize: 40),
          ),
          const SizedBox(width: 16),
          // Streak info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  streakLabel,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: streakColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      streakValue.toString(),
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: streakColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'games',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: streakColor.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Icon
          Icon(
            streakIcon,
            size: 32,
            color: streakColor,
          ),
        ],
      ),
    );
  }

  Widget _buildNoStreakState(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.bolt,
            size: 32,
            color: theme.colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'No Active Streak',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Win your next game to start a streak!',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
