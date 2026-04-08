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
import 'package:play_with_me/features/profile/presentation/widgets/best_elo_highlight_card.dart';
import 'package:play_with_me/features/profile/presentation/widgets/monthly_improvement_chart.dart';
import 'package:play_with_me/features/profile/presentation/widgets/ranking_stats_cards.dart';
import 'package:play_with_me/features/profile/presentation/widgets/time_period_selector.dart';
import 'package:play_with_me/core/theme/app_colors.dart';
import 'package:play_with_me/l10n/app_localizations.dart';

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
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              EloHistoryBloc(userRepository: sl<UserRepository>())
                ..add(EloHistoryEvent.loadHistory(userId: user.uid)),
        ),
        BlocProvider(
          create: (context) =>
              PlayerStatsBloc(userRepository: sl<UserRepository>())..add(
                LoadPlayerStats(user.uid),
              ), // Story 302.5: Load stats (ranking auto-loads via listener)
        ),
      ],
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section label — uppercase, muted, letter-spaced
            Text(
              AppLocalizations.of(
                context,
              )!.momentumAndConsistency.toUpperCase(),
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textMuted,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 12),
            // Streak white card
            Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _buildStreakSection(context),
              ),
            ),
            const SizedBox(height: 20),
            // ELO Progress section label
            Text(
              AppLocalizations.of(context)!.eloProgress.toUpperCase(),
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textMuted,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 12),
            // Ranking Stats Cards — sit directly on gray background (Story 302.5)
            BlocListener<PlayerStatsBloc, PlayerStatsState>(
              listener: (context, statsState) {
                if (statsState is PlayerStatsLoaded &&
                    statsState.ranking == null) {
                  context.read<PlayerStatsBloc>().add(LoadRanking(user.uid));
                }
              },
              child: BlocBuilder<PlayerStatsBloc, PlayerStatsState>(
                builder: (context, statsState) {
                  if (statsState is PlayerStatsLoaded) {
                    return Column(
                      children: [
                        RankingStatsCards(
                          ranking: statsState.ranking,
                          currentStreak: user.currentStreak,
                        ),
                        const SizedBox(height: 12),
                      ],
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            // Period selector + chart + best ELO — white card (Story 302.3/4/6)
            BlocBuilder<EloHistoryBloc, EloHistoryState>(
              builder: (context, state) {
                if (state is! EloHistoryLoaded) return const SizedBox.shrink();

                return Card(
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
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
                        MonthlyImprovementChart(
                          ratingHistory: state.filteredHistory,
                          currentElo: user.eloRating,
                          timePeriod: state.selectedPeriod,
                        ),
                        const SizedBox(height: 16),
                        BestEloHighlightCard(
                          bestElo: state.bestEloInPeriod,
                          timePeriod: state.selectedPeriod,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
          ],
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
    final streakLabel = isWinning
        ? AppLocalizations.of(context)!.winStreak
        : AppLocalizations.of(context)!.lossStreak;

    // Short streak (1–2 games): subtle inline chip — no need for a loud alert
    if (streakValue < 3) {
      return Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: streakColor.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: streakColor.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(streakIcon, size: 16, color: streakColor),
              const SizedBox(width: 6),
              Text(
                '$streakValue',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: streakColor,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                streakLabel,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: streakColor.withValues(alpha: 0.85),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Significant streak (3+ games): prominent colored text, no inner container
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                streakLabel,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: streakColor.withValues(alpha: 0.8),
                ),
              ),
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    streakValue.toString(),
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: streakColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    AppLocalizations.of(context)!
                        .gamesCount(streakValue)
                        .replaceFirst('$streakValue ', ''),
                    style: TextStyle(
                      fontSize: 16,
                      color: streakColor.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Icon(streakIcon, size: 32, color: streakColor),
      ],
    );
  }

  Widget _buildNoStreakState(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.bolt,
          size: 28,
          color: AppColors.textMuted.withValues(alpha: 0.35),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)!.noActiveStreak,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                AppLocalizations.of(context)!.winNextGameToStartStreak,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
