// Widget tests for PerformanceOverviewCard empty states.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:play_with_me/core/data/models/user_model.dart';
import 'package:play_with_me/features/profile/presentation/widgets/performance_overview_card.dart';
import 'package:play_with_me/features/profile/presentation/widgets/empty_stats_placeholder.dart';

void main() {
  group('PerformanceOverviewCard Widget Tests', () {
    testWidgets('shows empty state for user with 0 games', (tester) async {
      final user = UserModel(
        uid: 'test-uid',
        email: 'test@example.com',
        isEmailVerified: true,
        isAnonymous: false,
        gamesPlayed: 0,
        gamesWon: 0,
        gamesLost: 0,
        eloRating: 1500.0,
        eloPeak: 1500.0,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PerformanceOverviewCard(user: user),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Should show EmptyStatsPlaceholder
      expect(find.byType(EmptyStatsPlaceholder), findsOneWidget);
      expect(find.text('No Performance Data'), findsOneWidget);
      expect(
        find.text('Play your first game to see your performance statistics!'),
        findsOneWidget,
      );
      expect(find.text('Play at least 1 game to unlock'), findsOneWidget);

      // Should NOT show performance stats
      expect(find.text('Performance Overview'), findsNothing);
      expect(find.text('Current ELO'), findsNothing);
      expect(find.text('Peak ELO'), findsNothing);
    });

    testWidgets('shows performance stats for user with games', (tester) async {
      final user = UserModel(
        uid: 'test-uid',
        email: 'test@example.com',
        isEmailVerified: true,
        isAnonymous: false,
        gamesPlayed: 10,
        gamesWon: 7,
        gamesLost: 3,
        eloRating: 1650.0,
        eloPeak: 1680.0,
        eloPeakDate: DateTime(2024, 1, 15),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PerformanceOverviewCard(user: user),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Should NOT show EmptyStatsPlaceholder
      expect(find.byType(EmptyStatsPlaceholder), findsNothing);

      // Should show performance stats
      expect(find.text('Performance Overview'), findsOneWidget);
      expect(find.text('Current ELO'), findsOneWidget);
      expect(find.text('1650'), findsOneWidget);
      expect(find.text('Peak ELO'), findsOneWidget);
      expect(find.text('1680'), findsOneWidget);
      expect(find.text('Games Played'), findsOneWidget);
      expect(find.text('10'), findsOneWidget);
      expect(find.text('Win Rate'), findsOneWidget);
      expect(find.text('7W - 3L'), findsOneWidget);
    });

    testWidgets('shows performance stats for user with 1 game', (tester) async {
      final user = UserModel(
        uid: 'test-uid',
        email: 'test@example.com',
        isEmailVerified: true,
        isAnonymous: false,
        gamesPlayed: 1,
        gamesWon: 1,
        gamesLost: 0,
        eloRating: 1520.0,
        eloPeak: 1520.0,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PerformanceOverviewCard(user: user),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Should show performance stats (not empty state)
      expect(find.byType(EmptyStatsPlaceholder), findsNothing);
      expect(find.text('Performance Overview'), findsOneWidget);
      expect(find.text('Games Played'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
    });

    testWidgets('shows best win with opponent names when available', (tester) async {
      final user = UserModel(
        uid: 'test-uid',
        email: 'test@example.com',
        isEmailVerified: true,
        isAnonymous: false,
        gamesPlayed: 5,
        gamesWon: 3,
        gamesLost: 2,
        eloRating: 1550.0,
        eloPeak: 1600.0,
        bestWin: BestWinRecord(
          gameId: 'game123',
          opponentTeamElo: 1700.0,
          opponentTeamAvgElo: 1650.0,
          eloGained: 24.0,
          date: DateTime(2024, 2, 10),
          gameTitle: 'vs Player A & Player B',
          opponentNames: 'Player A & Player B',
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PerformanceOverviewCard(user: user),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Should show best win data with structured layout
      expect(find.text('Best Win'), findsOneWidget);
      expect(find.text('Team: Player A · Player B'), findsOneWidget); // Team composition with middle dot
      expect(find.text('Team ELO: 1650'), findsOneWidget); // Team strength
      expect(find.text('+24 ELO gained'), findsOneWidget); // ELO gained

      // Should use trophy icon
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Icon &&
              widget.icon == Icons.emoji_events,
        ),
        findsAtLeastNWidgets(1),
      );
    });

    testWidgets('shows best win with ELO only when opponent names are null (fallback)', (tester) async {
      final user = UserModel(
        uid: 'test-uid',
        email: 'test@example.com',
        isEmailVerified: true,
        isAnonymous: false,
        gamesPlayed: 5,
        gamesWon: 3,
        gamesLost: 2,
        eloRating: 1550.0,
        eloPeak: 1600.0,
        bestWin: BestWinRecord(
          gameId: 'game123',
          opponentTeamElo: 1700.0,
          opponentTeamAvgElo: 1650.0,
          eloGained: 24.0,
          date: DateTime(2024, 2, 10),
          gameTitle: 'vs Opponents',
          opponentNames: null, // Null for backward compatibility
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PerformanceOverviewCard(user: user),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Should show best win data with ELO only (fallback behavior without team names)
      expect(find.text('Best Win'), findsOneWidget);
      expect(find.text('Team ELO: 1650'), findsOneWidget); // ELO shown without team names
      expect(find.text('+24 ELO gained'), findsOneWidget);
    });

    testWidgets('shows placeholder when user has no best win', (tester) async {
      final user = UserModel(
        uid: 'test-uid',
        email: 'test@example.com',
        isEmailVerified: true,
        isAnonymous: false,
        gamesPlayed: 5,
        gamesWon: 0,
        gamesLost: 5,
        eloRating: 1450.0,
        eloPeak: 1500.0,
        bestWin: null, // No best win yet
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PerformanceOverviewCard(user: user),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Should show placeholder
      expect(find.text('Best Win'), findsOneWidget);
      expect(find.text('Win a game to unlock'), findsOneWidget);
      expect(
        find.text('Beat opponents to track your best victory'),
        findsOneWidget,
      );

      // Should use outlined trophy icon
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Icon &&
              widget.icon == Icons.emoji_events_outlined,
        ),
        findsAtLeastNWidgets(1),
      );
    });

    testWidgets('shows correct formatting for best win with opponent names and ELO values', (tester) async {
      final user = UserModel(
        uid: 'test-uid',
        email: 'test@example.com',
        isEmailVerified: true,
        isAnonymous: false,
        gamesPlayed: 10,
        gamesWon: 6,
        gamesLost: 4,
        eloRating: 1600.0,
        eloPeak: 1650.0,
        bestWin: BestWinRecord(
          gameId: 'game456',
          opponentTeamElo: 1850.5, // Should be rounded
          opponentTeamAvgElo: 1825.7, // Should be rounded
          eloGained: 28.3, // Should be rounded with +
          date: DateTime(2024, 3, 1),
          gameTitle: 'vs Strong Team',
          opponentNames: 'Alice & Bob',
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PerformanceOverviewCard(user: user),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Should show opponent names with rounded ELO values in structured layout
      expect(find.text('Best Win'), findsOneWidget);
      expect(find.text('Team: Alice · Bob'), findsOneWidget); // Team composition with middle dot
      expect(find.text('Team ELO: 1826'), findsOneWidget); // Rounded ELO
      expect(find.text('+28 ELO gained'), findsOneWidget); // Rounded ELO gain
    });

    // Story 301.7: Average Point Differential Tests (Wins vs Losses)
    testWidgets('shows point differential for wins and losses separately', (tester) async {
      final user = UserModel(
        uid: 'test-uid',
        email: 'test@example.com',
        isEmailVerified: true,
        isAnonymous: false,
        gamesPlayed: 3,
        gamesWon: 2,
        gamesLost: 1,
        eloRating: 1550.0,
        eloPeak: 1600.0,
        pointStats: PointStats(
          totalDiffInWinningSets: 15, // +15 across 3 winning sets
          winningSetsCount: 3,
          totalDiffInLosingSets: -8, // -8 across 2 losing sets
          losingSetsCount: 2,
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PerformanceOverviewCard(user: user),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Should show title
      expect(find.text('Avg Point Differential'), findsOneWidget);

      // Should show winning sets average: 15 / 3 = +5.0
      expect(find.text('In Wins'), findsOneWidget);
      expect(find.text('+5.0'), findsOneWidget);
      expect(find.text('3 sets'), findsOneWidget);

      // Should show losing sets average: -8 / 2 = -4.0
      expect(find.text('In Losses'), findsOneWidget);
      expect(find.text('-4.0'), findsOneWidget);
      expect(find.text('2 sets'), findsOneWidget);

      // Should show subtitle
      expect(find.text('3 won, 2 lost'), findsOneWidget);

      // Should have trending_up and trending_down icons
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Icon &&
              widget.icon == Icons.trending_up,
        ),
        findsAtLeastNWidgets(1),
      );
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Icon &&
              widget.icon == Icons.trending_down,
        ),
        findsAtLeastNWidgets(1),
      );
    });

    testWidgets('shows point differential with only winning sets', (tester) async {
      final user = UserModel(
        uid: 'test-uid',
        email: 'test@example.com',
        isEmailVerified: true,
        isAnonymous: false,
        gamesPlayed: 2,
        gamesWon: 2,
        gamesLost: 0,
        eloRating: 1600.0,
        eloPeak: 1600.0,
        pointStats: PointStats(
          totalDiffInWinningSets: 20, // +20 across 4 winning sets
          winningSetsCount: 4,
          totalDiffInLosingSets: 0,
          losingSetsCount: 0, // No losing sets
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PerformanceOverviewCard(user: user),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Should show winning sets: 20 / 4 = +5.0
      expect(find.text('+5.0'), findsOneWidget);
      expect(find.text('4 sets'), findsOneWidget);

      // Should show N/A for losing sets
      expect(find.text('N/A'), findsOneWidget);
      expect(find.text('0 sets'), findsOneWidget);

      // Should show subtitle
      expect(find.text('4 won, 0 lost'), findsOneWidget);
    });

    testWidgets('shows point differential with only losing sets', (tester) async {
      final user = UserModel(
        uid: 'test-uid',
        email: 'test@example.com',
        isEmailVerified: true,
        isAnonymous: false,
        gamesPlayed: 2,
        gamesWon: 0,
        gamesLost: 2,
        eloRating: 1400.0,
        eloPeak: 1500.0,
        pointStats: PointStats(
          totalDiffInWinningSets: 0,
          winningSetsCount: 0, // No winning sets
          totalDiffInLosingSets: -12, // -12 across 3 losing sets
          losingSetsCount: 3,
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PerformanceOverviewCard(user: user),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Should show N/A for winning sets
      expect(find.text('N/A'), findsOneWidget);
      expect(find.text('0 sets'), findsOneWidget);

      // Should show losing sets: -12 / 3 = -4.0
      expect(find.text('-4.0'), findsOneWidget);
      expect(find.text('3 sets'), findsOneWidget);

      // Should show subtitle
      expect(find.text('0 won, 3 lost'), findsOneWidget);
    });

    testWidgets('shows placeholder when no sets played', (tester) async {
      final user = UserModel(
        uid: 'test-uid',
        email: 'test@example.com',
        isEmailVerified: true,
        isAnonymous: false,
        gamesPlayed: 1, // Has games but no point stats yet
        gamesWon: 1,
        gamesLost: 0,
        eloRating: 1500.0,
        eloPeak: 1500.0,
        pointStats: null, // No point stats yet
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PerformanceOverviewCard(user: user),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Should show placeholder (using _StatItem, not _PointDiffStatItem)
      expect(find.text('Avg Point Diff'), findsOneWidget);
      expect(find.text('Complete a game to unlock'), findsOneWidget);
      expect(find.text('Win and lose sets to see your margins'), findsOneWidget);

      // Should have outlined icon
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Icon &&
              widget.icon == Icons.trending_up_outlined,
        ),
        findsOneWidget,
      );
    });

    testWidgets('shows correct decimal precision for point differential', (tester) async {
      final user = UserModel(
        uid: 'test-uid',
        email: 'test@example.com',
        isEmailVerified: true,
        isAnonymous: false,
        gamesPlayed: 3,
        gamesWon: 2,
        gamesLost: 1,
        eloRating: 1530.0,
        eloPeak: 1530.0,
        pointStats: PointStats(
          totalDiffInWinningSets: 17, // 17 / 5 = 3.4
          winningSetsCount: 5,
          totalDiffInLosingSets: -11, // -11 / 3 = -3.666... ≈ -3.7
          losingSetsCount: 3,
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PerformanceOverviewCard(user: user),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Should show one decimal place
      expect(find.text('+3.4'), findsOneWidget);
      expect(find.text('-3.7'), findsOneWidget);
      expect(find.text('5 won, 3 lost'), findsOneWidget);
    });
  });
}
