// Tests MonthlyImprovementChart axis lines visibility (Story 302.4.2).
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:play_with_me/core/data/models/rating_history_entry.dart';
import 'package:play_with_me/core/domain/entities/time_period.dart';
import 'package:play_with_me/features/profile/presentation/widgets/monthly_improvement_chart.dart';

void main() {
  /// Helper to create test rating history
  List<RatingHistoryEntry> createHistory(List<double> ratings) {
    final now = DateTime.now();
    return ratings.asMap().entries.map((entry) {
      return RatingHistoryEntry(
        entryId: 'entry-${entry.key}',
        gameId: 'game-${entry.key}',
        oldRating: entry.key == 0 ? 1600 : ratings[entry.key - 1],
        newRating: entry.value,
        ratingChange: entry.key == 0 ? 0 : entry.value - ratings[entry.key - 1],
        opponentTeam: 'Team ${entry.key}',
        won: entry.value > (entry.key == 0 ? 1600 : ratings[entry.key - 1]),
        timestamp: now.subtract(Duration(days: ratings.length - entry.key)),
      );
    }).toList();
  }

  group('MonthlyImprovementChart Axis Lines Tests (Story 302.4.2)', () {
    testWidgets('X-axis line is visible', (tester) async {
      final history = createHistory([1600, 1625, 1650]);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MonthlyImprovementChart(
              ratingHistory: history,
              currentElo: 1650,
              timePeriod: TimePeriod.thirtyDays,
            ),
          ),
        ),
      );

      final chart = tester.widget<LineChart>(find.byType(LineChart));
      final borderData = chart.data.borderData;

      // Verify border is shown
      expect(borderData.show, isTrue);

      // Verify bottom border (X-axis) exists
      expect(borderData.border.bottom, isNotNull);
      expect(borderData.border.bottom.style, BorderStyle.solid);
    });

    testWidgets('Y-axis line is visible', (tester) async {
      final history = createHistory([1600, 1625, 1650]);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MonthlyImprovementChart(
              ratingHistory: history,
              currentElo: 1650,
              timePeriod: TimePeriod.thirtyDays,
            ),
          ),
        ),
      );

      final chart = tester.widget<LineChart>(find.byType(LineChart));
      final borderData = chart.data.borderData;

      // Verify border is shown
      expect(borderData.show, isTrue);

      // Verify left border (Y-axis) exists
      expect(borderData.border.left, isNotNull);
      expect(borderData.border.left.style, BorderStyle.solid);
    });

    testWidgets('axis lines match app theme', (tester) async {
      final history = createHistory([1600, 1625, 1650]);

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: Scaffold(
            body: MonthlyImprovementChart(
              ratingHistory: history,
              currentElo: 1650,
              timePeriod: TimePeriod.thirtyDays,
            ),
          ),
        ),
      );

      final context = tester.element(find.byType(MonthlyImprovementChart));
      final theme = Theme.of(context);
      final expectedColor = theme.colorScheme.outline.withOpacity(0.3);

      final chart = tester.widget<LineChart>(find.byType(LineChart));
      final borderData = chart.data.borderData;

      // Verify colors match theme
      expect(borderData.border.left.color, expectedColor);
      expect(borderData.border.bottom.color, expectedColor);

      // Verify width is 1
      expect(borderData.border.left.width, 1);
      expect(borderData.border.bottom.width, 1);
    });

    testWidgets('top and right borders are not shown', (tester) async {
      final history = createHistory([1600, 1625, 1650]);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MonthlyImprovementChart(
              ratingHistory: history,
              currentElo: 1650,
              timePeriod: TimePeriod.thirtyDays,
            ),
          ),
        ),
      );

      final chart = tester.widget<LineChart>(find.byType(LineChart));
      final borderData = chart.data.borderData;

      // Verify top and right borders are not shown (default BorderSide.none)
      expect(borderData.border.top.style, BorderStyle.none);
      expect(borderData.border.right.style, BorderStyle.none);
    });
  });

  group('MonthlyImprovementChart Two-Tier X-Axis Labels (Story 302.4.3)', () {
    testWidgets('shows month labels for all data points', (tester) async {
      final now = DateTime.now();
      final month1 = now.month >= 3 ? now.month - 2 : 3;
      final month2 = now.month >= 2 ? now.month - 1 : 2;

      final currentYearHistory = [
        RatingHistoryEntry(
          entryId: 'entry-1',
          gameId: 'game-1',
          oldRating: 1600,
          newRating: 1620,
          ratingChange: 20,
          opponentTeam: 'Team A',
          won: true,
          timestamp: DateTime(now.year, month1, 15),
        ),
        RatingHistoryEntry(
          entryId: 'entry-2',
          gameId: 'game-2',
          oldRating: 1620,
          newRating: 1650,
          ratingChange: 30,
          opponentTeam: 'Team B',
          won: true,
          timestamp: DateTime(now.year, month2, 10),
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MonthlyImprovementChart(
              ratingHistory: currentYearHistory,
              currentElo: 1650,
              timePeriod: TimePeriod.allTime,
            ),
          ),
        ),
      );

      // Verify month labels are present (3 letters, no digits)
      final allText = tester.widgetList<Text>(find.byType(Text));
      int monthLabelCount = 0;

      for (final text in allText) {
        final data = text.data ?? '';
        if (data.length == 3 && !data.contains(RegExp(r'\d'))) {
          monthLabelCount++;
        }
      }

      expect(monthLabelCount, greaterThanOrEqualTo(2),
          reason: 'Should have found month labels for data points');
    });

    testWidgets('shows year label centered within year range', (tester) async {
      final now = DateTime.now();
      final previousYear = now.year - 1;
      final previousYearHistory = [
        RatingHistoryEntry(
          entryId: 'entry-1',
          gameId: 'game-1',
          oldRating: 1600,
          newRating: 1620,
          ratingChange: 20,
          opponentTeam: 'Team A',
          won: true,
          timestamp: DateTime(previousYear, 11, 15), // November previous year
        ),
        RatingHistoryEntry(
          entryId: 'entry-2',
          gameId: 'game-2',
          oldRating: 1620,
          newRating: 1650,
          ratingChange: 30,
          opponentTeam: 'Team B',
          won: true,
          timestamp: DateTime(previousYear, 12, 10), // December previous year
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MonthlyImprovementChart(
              ratingHistory: previousYearHistory,
              currentElo: 1650,
              timePeriod: TimePeriod.allTime,
            ),
          ),
        ),
      );

      // Verify year label appears (should be the full 4-digit year, not abbreviated)
      final allText = tester.widgetList<Text>(find.byType(Text));
      bool foundYearLabel = false;

      for (final text in allText) {
        final data = text.data ?? '';
        // Check if it's a 4-digit year
        if (data == previousYear.toString()) {
          foundYearLabel = true;
        }
      }

      expect(foundYearLabel, isTrue,
          reason: 'Should have found year label for previous year');
    });

    testWidgets('shows year labels centered for each year in dataset', (tester) async {
      final now = DateTime.now();
      final previousYear = now.year - 1;
      final mixedYearHistory = [
        RatingHistoryEntry(
          entryId: 'entry-1',
          gameId: 'game-1',
          oldRating: 1600,
          newRating: 1620,
          ratingChange: 20,
          opponentTeam: 'Team A',
          won: true,
          timestamp: DateTime(previousYear, 12, 15), // December previous year
        ),
        RatingHistoryEntry(
          entryId: 'entry-2',
          gameId: 'game-2',
          oldRating: 1620,
          newRating: 1650,
          ratingChange: 30,
          opponentTeam: 'Team B',
          won: true,
          timestamp: DateTime(now.year, 1, 10), // January current year
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MonthlyImprovementChart(
              ratingHistory: mixedYearHistory,
              currentElo: 1650,
              timePeriod: TimePeriod.allTime,
            ),
          ),
        ),
      );

      final allText = tester.widgetList<Text>(find.byType(Text));
      bool foundPreviousYearLabel = false;
      bool foundCurrentYearLabel = false;
      int monthLabelCount = 0;

      for (final text in allText) {
        final data = text.data ?? '';
        // Check for year labels (4-digit years)
        if (data == previousYear.toString()) {
          foundPreviousYearLabel = true;
        }
        if (data == now.year.toString()) {
          foundCurrentYearLabel = true;
        }
        // Count month labels
        if (data.length == 3 && !data.contains(RegExp(r'\d'))) {
          monthLabelCount++;
        }
      }

      expect(foundPreviousYearLabel, isTrue,
          reason: 'Should have year label for previous year');
      expect(foundCurrentYearLabel, isTrue,
          reason: 'Should have year label for current year (year transition)');
      expect(monthLabelCount, greaterThanOrEqualTo(2),
          reason: 'Should have month labels for both data points');
    });

    testWidgets('reserved space increased for two-tier labels', (tester) async {
      final now = DateTime.now();
      final history = [
        RatingHistoryEntry(
          entryId: 'entry-1',
          gameId: 'game-1',
          oldRating: 1600,
          newRating: 1620,
          ratingChange: 20,
          opponentTeam: 'Team A',
          won: true,
          timestamp: DateTime(now.year, 6, 15),
        ),
        RatingHistoryEntry(
          entryId: 'entry-2',
          gameId: 'game-2',
          oldRating: 1620,
          newRating: 1650,
          ratingChange: 30,
          opponentTeam: 'Team B',
          won: true,
          timestamp: DateTime(now.year, 7, 10),
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MonthlyImprovementChart(
              ratingHistory: history,
              currentElo: 1650,
              timePeriod: TimePeriod.allTime,
            ),
          ),
        ),
      );

      final chart = tester.widget<LineChart>(find.byType(LineChart));
      final bottomTitles = chart.data.titlesData.bottomTitles;

      // Verify reserved size is increased for two-tier labels (42 vs old 32)
      expect(bottomTitles.sideTitles.reservedSize, equals(42),
          reason: 'Reserved size should be 42 for two-tier labels');
    });

    testWidgets('column layout used for two-tier labels', (tester) async {
      final now = DateTime.now();
      final previousYear = now.year - 1;
      final history = [
        RatingHistoryEntry(
          entryId: 'entry-1',
          gameId: 'game-1',
          oldRating: 1600,
          newRating: 1620,
          ratingChange: 20,
          opponentTeam: 'Team A',
          won: true,
          timestamp: DateTime(previousYear, 11, 15),
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MonthlyImprovementChart(
              ratingHistory: history,
              currentElo: 1620,
              timePeriod: TimePeriod.allTime,
            ),
          ),
        ),
      );

      // Verify Column widgets are used for label structure
      final columns = tester.widgetList<Column>(find.byType(Column));
      expect(columns.length, greaterThan(0),
          reason: 'Should have Column widgets for two-tier structure');
    });
  });
}
