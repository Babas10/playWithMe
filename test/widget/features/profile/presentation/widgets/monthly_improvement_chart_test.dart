// Widget tests for MonthlyImprovementChart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:play_with_me/core/data/models/rating_history_entry.dart';
import 'package:play_with_me/features/profile/presentation/widgets/monthly_improvement_chart.dart';
import 'package:play_with_me/features/profile/presentation/widgets/empty_stats_placeholder.dart';
import 'package:fl_chart/fl_chart.dart';

void main() {
  group('MonthlyImprovementChart Widget Tests', () {
    testWidgets('shows placeholder when history is empty', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MonthlyImprovementChart(
              ratingHistory: [],
              currentElo: 1600.0,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(InsufficientDataPlaceholder), findsOneWidget);
      expect(find.text('Monthly Progress Chart Locked'), findsOneWidget);
      expect(find.text('Play games for at least 2 months'), findsOneWidget);
      expect(find.byIcon(Icons.timeline), findsOneWidget);
    });

    testWidgets('shows placeholder when only 1 month of data', (tester) async {
      final singleMonthHistory = [
        RatingHistoryEntry(
          entryId: 'entry-1',
          gameId: 'game-1',
          oldRating: 1600,
          newRating: 1620,
          ratingChange: 20,
          opponentTeam: 'Team A',
          won: true,
          timestamp: DateTime(2024, 1, 15),
        ),
        RatingHistoryEntry(
          entryId: 'entry-2',
          gameId: 'game-2',
          oldRating: 1620,
          newRating: 1640,
          ratingChange: 20,
          opponentTeam: 'Team B',
          won: true,
          timestamp: DateTime(2024, 1, 20),
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MonthlyImprovementChart(
              ratingHistory: singleMonthHistory,
              currentElo: 1640.0,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(InsufficientDataPlaceholder), findsOneWidget);
    });

    testWidgets('shows chart when 2 months of data', (tester) async {
      final twoMonthHistory = [
        RatingHistoryEntry(
          entryId: 'entry-1',
          gameId: 'game-1',
          oldRating: 1600,
          newRating: 1620,
          ratingChange: 20,
          opponentTeam: 'Team A',
          won: true,
          timestamp: DateTime(2024, 1, 15),
        ),
        RatingHistoryEntry(
          entryId: 'entry-2',
          gameId: 'game-2',
          oldRating: 1620,
          newRating: 1650,
          ratingChange: 30,
          opponentTeam: 'Team B',
          won: true,
          timestamp: DateTime(2024, 2, 10),
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MonthlyImprovementChart(
              ratingHistory: twoMonthHistory,
              currentElo: 1650.0,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(LineChart), findsOneWidget);
      expect(find.byType(InsufficientDataPlaceholder), findsNothing);
    });

    testWidgets('shows chart with 3+ months of data', (tester) async {
      final multiMonthHistory = [
        RatingHistoryEntry(
          entryId: 'entry-1',
          gameId: 'game-1',
          oldRating: 1600,
          newRating: 1620,
          ratingChange: 20,
          opponentTeam: 'Team A',
          won: true,
          timestamp: DateTime(2024, 1, 15),
        ),
        RatingHistoryEntry(
          entryId: 'entry-2',
          gameId: 'game-2',
          oldRating: 1620,
          newRating: 1650,
          ratingChange: 30,
          opponentTeam: 'Team B',
          won: true,
          timestamp: DateTime(2024, 2, 10),
        ),
        RatingHistoryEntry(
          entryId: 'entry-3',
          gameId: 'game-3',
          oldRating: 1650,
          newRating: 1640,
          ratingChange: -10,
          opponentTeam: 'Team C',
          won: false,
          timestamp: DateTime(2024, 3, 5),
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MonthlyImprovementChart(
              ratingHistory: multiMonthHistory,
              currentElo: 1640.0,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(LineChart), findsOneWidget);
    });

    testWidgets('shows best month badge when positive delta exists',
        (tester) async {
      final historyWithImprovement = [
        RatingHistoryEntry(
          entryId: 'entry-1',
          gameId: 'game-1',
          oldRating: 1600,
          newRating: 1620,
          ratingChange: 20,
          opponentTeam: 'Team A',
          won: true,
          timestamp: DateTime(2024, 1, 15),
        ),
        RatingHistoryEntry(
          entryId: 'entry-2',
          gameId: 'game-2',
          oldRating: 1620,
          newRating: 1680,
          ratingChange: 60,
          opponentTeam: 'Team B',
          won: true,
          timestamp: DateTime(2024, 2, 10),
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MonthlyImprovementChart(
              ratingHistory: historyWithImprovement,
              currentElo: 1680.0,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Best Month'), findsOneWidget);
      // Feb appears in both the chart and the badge, so we check for the badge text specifically
      expect(find.textContaining('Feb: +'), findsOneWidget);
    });

    testWidgets('shows worst month badge when negative delta exists',
        (tester) async {
      final historyWithDecline = [
        RatingHistoryEntry(
          entryId: 'entry-1',
          gameId: 'game-1',
          oldRating: 1600,
          newRating: 1620,
          ratingChange: 20,
          opponentTeam: 'Team A',
          won: true,
          timestamp: DateTime(2024, 1, 15),
        ),
        RatingHistoryEntry(
          entryId: 'entry-2',
          gameId: 'game-2',
          oldRating: 1620,
          newRating: 1580,
          ratingChange: -40,
          opponentTeam: 'Team B',
          won: false,
          timestamp: DateTime(2024, 2, 10),
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MonthlyImprovementChart(
              ratingHistory: historyWithDecline,
              currentElo: 1580.0,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Toughest Month'), findsOneWidget);
    });

    testWidgets('shows both best and worst month badges', (tester) async {
      final historyWithMixedPerformance = [
        RatingHistoryEntry(
          entryId: 'entry-1',
          gameId: 'game-1',
          oldRating: 1600,
          newRating: 1620,
          ratingChange: 20,
          opponentTeam: 'Team A',
          won: true,
          timestamp: DateTime(2024, 1, 15),
        ),
        RatingHistoryEntry(
          entryId: 'entry-2',
          gameId: 'game-2',
          oldRating: 1620,
          newRating: 1680,
          ratingChange: 60,
          opponentTeam: 'Team B',
          won: true,
          timestamp: DateTime(2024, 2, 10),
        ),
        RatingHistoryEntry(
          entryId: 'entry-3',
          gameId: 'game-3',
          oldRating: 1680,
          newRating: 1640,
          ratingChange: -40,
          opponentTeam: 'Team C',
          won: false,
          timestamp: DateTime(2024, 3, 5),
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MonthlyImprovementChart(
              ratingHistory: historyWithMixedPerformance,
              currentElo: 1640.0,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Best Month'), findsOneWidget);
      expect(find.text('Toughest Month'), findsOneWidget);
    });

    testWidgets('handles multiple games in same month correctly',
        (tester) async {
      final sameMonthGames = [
        RatingHistoryEntry(
          entryId: 'entry-1',
          gameId: 'game-1',
          oldRating: 1600,
          newRating: 1610,
          ratingChange: 10,
          opponentTeam: 'Team A',
          won: true,
          timestamp: DateTime(2024, 1, 5),
        ),
        RatingHistoryEntry(
          entryId: 'entry-2',
          gameId: 'game-2',
          oldRating: 1610,
          newRating: 1620,
          ratingChange: 10,
          opponentTeam: 'Team B',
          won: true,
          timestamp: DateTime(2024, 1, 15), // Most recent in Jan
        ),
        RatingHistoryEntry(
          entryId: 'entry-3',
          gameId: 'game-3',
          oldRating: 1620,
          newRating: 1650,
          ratingChange: 30,
          opponentTeam: 'Team C',
          won: true,
          timestamp: DateTime(2024, 2, 10),
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MonthlyImprovementChart(
              ratingHistory: sameMonthGames,
              currentElo: 1650.0,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Should use most recent entry from January (1620) as end-of-month snapshot
      expect(find.byType(LineChart), findsOneWidget);
    });
  });
}
