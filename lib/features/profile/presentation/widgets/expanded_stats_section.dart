// Expanded statistics section for profile page with explore-level stats.
import 'package:flutter/material.dart';
import 'package:play_with_me/core/data/models/rating_history_entry.dart';
import 'package:play_with_me/core/data/models/user_model.dart';
import 'package:play_with_me/features/profile/presentation/widgets/performance_overview_card.dart';
import 'package:play_with_me/features/profile/presentation/widgets/momentum_consistency_card.dart';
import 'package:play_with_me/features/profile/presentation/widgets/partners_card.dart';
import 'package:play_with_me/features/profile/presentation/widgets/rivals_card.dart';
import 'package:play_with_me/features/profile/presentation/widgets/role_based_performance_card.dart';

/// A section widget displaying expanded statistics on the profile page.
///
/// This is the "Explore" level of progressive disclosure, showing:
/// - Performance Overview (current/peak ELO, win rate, best win, point diff)
/// - Momentum & Consistency (streak + monthly improvement chart)
/// - Partners (best partner stats)
/// - Rivals (nemesis stats)
/// - Role-Based Performance (weak-link/carry win rates, collapsible)
///
/// Stats are grouped into themed cards for easy understanding.
class ExpandedStatsSection extends StatelessWidget {
  final UserModel user;
  final List<RatingHistoryEntry> ratingHistory;

  const ExpandedStatsSection({
    super.key,
    required this.user,
    required this.ratingHistory,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Performance Overview Card
        PerformanceOverviewCard(user: user),

        // Momentum & Consistency Card
        MomentumConsistencyCard(
          user: user,
          ratingHistory: ratingHistory,
        ),

        // Partners Card
        PartnersCard(user: user),

        // Rivals Card
        RivalsCard(user: user),

        // Role-Based Performance Card (Advanced, Collapsible)
        RoleBasedPerformanceCard(user: user),

        // Spacing at bottom
        const SizedBox(height: 16),
      ],
    );
  }
}
