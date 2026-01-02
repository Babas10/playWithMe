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
}
