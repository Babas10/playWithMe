// Tests MonthlyImprovementChart edge cases and empty states (Story 302.7).
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:play_with_me/core/data/models/rating_history_entry.dart';
import 'package:play_with_me/core/domain/entities/time_period.dart';
import 'package:play_with_me/features/profile/presentation/widgets/monthly_improvement_chart.dart';

void main() {
  group('MonthlyImprovementChart Edge Cases', () {
    testWidgets('shows placeholder when user has 0 games', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MonthlyImprovementChart(
              ratingHistory: [],
              currentElo: 1500,
            ),
          ),
        ),
      );

      expect(find.text('Monthly Progress Chart'), findsOneWidget);
      expect(find.text('Play at least 3 games'), findsOneWidget);
      expect(find.text('0/3 games'), findsOneWidget);
      expect(find.text('Start playing to track your progress!'), findsOneWidget);
    });

    testWidgets('shows placeholder when user has 1 game', (tester) async {
      final history = [
        RatingHistoryEntry(
          entryId: 'entry-1',
          gameId: 'game-1',
          oldRating: 1500,
          newRating: 1525,
          ratingChange: 25,
          opponentTeam: 'Team A',
          won: true,
          timestamp: DateTime.now(),
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MonthlyImprovementChart(
              ratingHistory: history,
              currentElo: 1525,
            ),
          ),
        ),
      );

      expect(find.text('Monthly Progress Chart'), findsOneWidget);
      expect(find.text('Play at least 3 games'), findsOneWidget);
      expect(find.text('1/3 games'), findsOneWidget);
      expect(find.text('Keep playing to unlock this chart!'), findsOneWidget);
    });

    testWidgets('shows placeholder when user has 2 games', (tester) async {
      final now = DateTime.now();
      final history = [
        RatingHistoryEntry(
          entryId: 'entry-1',
          gameId: 'game-1',
          oldRating: 1500,
          newRating: 1525,
          ratingChange: 25,
          opponentTeam: 'Team A',
          won: true,
          timestamp: now.subtract(const Duration(days: 1)),
        ),
        RatingHistoryEntry(
          entryId: 'entry-2',
          gameId: 'game-2',
          oldRating: 1525,
          newRating: 1550,
          ratingChange: 25,
          opponentTeam: 'Team B',
          won: true,
          timestamp: now,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MonthlyImprovementChart(
              ratingHistory: history,
              currentElo: 1550,
            ),
          ),
        ),
      );

      expect(find.text('Monthly Progress Chart'), findsOneWidget);
      expect(find.text('2/3 games'), findsOneWidget);
    });

    testWidgets('shows chart when user has exactly 3 games', (tester) async {
      final now = DateTime.now();
      final history = [
        RatingHistoryEntry(
          entryId: 'entry-1',
          gameId: 'game-1',
          oldRating: 1500,
          newRating: 1525,
          ratingChange: 25,
          opponentTeam: 'Team A',
          won: true,
          timestamp: now.subtract(const Duration(days: 2)),
        ),
        RatingHistoryEntry(
          entryId: 'entry-2',
          gameId: 'game-2',
          oldRating: 1525,
          newRating: 1550,
          ratingChange: 25,
          opponentTeam: 'Team B',
          won: true,
          timestamp: now.subtract(const Duration(days: 1)),
        ),
        RatingHistoryEntry(
          entryId: 'entry-3',
          gameId: 'game-3',
          oldRating: 1550,
          newRating: 1575,
          ratingChange: 25,
          opponentTeam: 'Team C',
          won: true,
          timestamp: now,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MonthlyImprovementChart(
              ratingHistory: history,
              currentElo: 1575,
            ),
          ),
        ),
      );

      // Should not show placeholder
      expect(find.text('Play at least 3 games'), findsNothing);
      // Chart should be rendered (verified by absence of placeholder)
    });

    testWidgets('shows chart for multiple games on same day', (tester) async {
      final now = DateTime.now();
      final history = [
        RatingHistoryEntry(
          entryId: 'entry-1',
          gameId: 'game-1',
          oldRating: 1500,
          newRating: 1525,
          ratingChange: 25,
          opponentTeam: 'Team A',
          won: true,
          timestamp: now.copyWith(hour: 10),
        ),
        RatingHistoryEntry(
          entryId: 'entry-2',
          gameId: 'game-2',
          oldRating: 1525,
          newRating: 1550,
          ratingChange: 25,
          opponentTeam: 'Team B',
          won: true,
          timestamp: now.copyWith(hour: 14),
        ),
        RatingHistoryEntry(
          entryId: 'entry-3',
          gameId: 'game-3',
          oldRating: 1550,
          newRating: 1575,
          ratingChange: 25,
          opponentTeam: 'Team C',
          won: true,
          timestamp: now.copyWith(hour: 18),
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MonthlyImprovementChart(
              ratingHistory: history,
              currentElo: 1575,
              timePeriod: TimePeriod.thirtyDays,
            ),
          ),
        ),
      );

      // Should show chart even with single day data for short periods
      expect(find.text('Play at least 3 games'), findsNothing);
    });

    testWidgets('shows empty period message when no games in selected period', (tester) async {
      final now = DateTime.now();
      final history = [
        RatingHistoryEntry(
          entryId: 'entry-1',
          gameId: 'game-1',
          oldRating: 1500,
          newRating: 1525,
          ratingChange: 25,
          opponentTeam: 'Team A',
          won: true,
          timestamp: now.subtract(const Duration(days: 200)), // Outside 30-day period
        ),
        RatingHistoryEntry(
          entryId: 'entry-2',
          gameId: 'game-2',
          oldRating: 1525,
          newRating: 1550,
          ratingChange: 25,
          opponentTeam: 'Team B',
          won: true,
          timestamp: now.subtract(const Duration(days: 201)),
        ),
        RatingHistoryEntry(
          entryId: 'entry-3',
          gameId: 'game-3',
          oldRating: 1550,
          newRating: 1575,
          ratingChange: 25,
          opponentTeam: 'Team C',
          won: true,
          timestamp: now.subtract(const Duration(days: 202)),
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MonthlyImprovementChart(
              ratingHistory: history,
              currentElo: 1575,
              timePeriod: TimePeriod.thirtyDays,
            ),
          ),
        ),
      );

      expect(find.text('No Games in This Period'), findsOneWidget);
      expect(find.text('No games played in the last 30 days'), findsOneWidget);
      expect(find.text('Try selecting a longer time period'), findsOneWidget);
    });

    testWidgets('shows chart when aggregated data >= 2 points for long periods', (tester) async {
      final now = DateTime.now();
      final history = [
        RatingHistoryEntry(
          entryId: 'entry-1',
          gameId: 'game-1',
          oldRating: 1500,
          newRating: 1525,
          ratingChange: 25,
          opponentTeam: 'Team A',
          won: true,
          timestamp: now.subtract(const Duration(days: 60)),
        ),
        RatingHistoryEntry(
          entryId: 'entry-2',
          gameId: 'game-2',
          oldRating: 1525,
          newRating: 1550,
          ratingChange: 25,
          opponentTeam: 'Team B',
          won: true,
          timestamp: now.subtract(const Duration(days: 30)),
        ),
        RatingHistoryEntry(
          entryId: 'entry-3',
          gameId: 'game-3',
          oldRating: 1550,
          newRating: 1575,
          ratingChange: 25,
          opponentTeam: 'Team C',
          won: true,
          timestamp: now,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MonthlyImprovementChart(
              ratingHistory: history,
              currentElo: 1575,
              timePeriod: TimePeriod.ninetyDays,
            ),
          ),
        ),
      );

      // Should show chart
      expect(find.text('Play games over a longer period'), findsNothing);
    });
  });
}
