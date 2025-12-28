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

    testWidgets('shows best win when user has best win data', (tester) async {
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

      // Should show best win data
      expect(find.text('Best Win'), findsOneWidget);
      expect(find.text('vs 1650 ELO'), findsOneWidget);
      expect(find.text('+24 ELO gained'), findsOneWidget);

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

    testWidgets('shows correct formatting for best win ELO values', (tester) async {
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

      // Should show rounded values
      expect(find.text('Best Win'), findsOneWidget);
      expect(find.text('vs 1826 ELO'), findsOneWidget); // Rounded
      expect(find.text('+28 ELO gained'), findsOneWidget); // Rounded with +
    });
  });
}
