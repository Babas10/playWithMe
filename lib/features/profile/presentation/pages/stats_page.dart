// Dedicated stats page displaying detailed player performance analytics.
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:play_with_me/features/profile/presentation/bloc/player_stats/player_stats_bloc.dart';
import 'package:play_with_me/features/profile/presentation/bloc/player_stats/player_stats_state.dart';
import 'package:play_with_me/features/profile/presentation/widgets/expanded_stats_section.dart';
import 'package:play_with_me/l10n/app_localizations.dart';

/// Stats tab content displaying all player performance and analytics.
///
/// This page answers: "How am I performing over time?"
/// It shows:
/// - Performance Overview (ELO, win rate, games played, best win)
/// - Momentum & Consistency (streaks, trends)
/// - Partners (best partner stats)
/// - Rivals (nemesis stats)
/// - Role-Based Performance (adaptability stats)
class StatsPage extends StatelessWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlayerStatsBloc, PlayerStatsState>(
      builder: (context, statsState) {
        if (statsState is PlayerStatsLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (statsState is PlayerStatsError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 48,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error loading stats: ${statsState.message}',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        if (statsState is PlayerStatsLoaded) {
          return SingleChildScrollView(
            padding: const EdgeInsets.only(top: 16, bottom: 20),
            child: ExpandedStatsSection(
              user: statsState.user,
              ratingHistory: statsState.history,
            ),
          );
        }

        // Initial state
        return Center(
          child: Text(
            AppLocalizations.of(context)!.noStatsYet,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
        );
      },
    );
  }
}
