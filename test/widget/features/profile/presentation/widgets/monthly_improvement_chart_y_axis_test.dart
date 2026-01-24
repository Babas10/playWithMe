// Widget test for Y-axis label logic in MonthlyImprovementChart
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:play_with_me/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:play_with_me/core/data/models/rating_history_entry.dart';
import 'package:play_with_me/core/domain/entities/time_period.dart';
import 'package:play_with_me/features/profile/presentation/widgets/monthly_improvement_chart.dart';

void main() {
  // Helper to create simple history
  // Story 302.7: Spread across different months to avoid single-month aggregation
  List<RatingHistoryEntry> createHistory(List<double> ratings) {
    return List.generate(
      ratings.length,
      (i) => RatingHistoryEntry(
        entryId: 'entry-$i',
        gameId: 'game-$i',
        oldRating: ratings[i] - 10,
        newRating: ratings[i],
        ratingChange: 10,
        opponentTeam: 'Opponents',
        won: true,
        timestamp: DateTime(2024, i + 1, 15), // Spread across months
      ),
    );
  }

  group('MonthlyImprovementChart Y-Axis Tests', () {
    testWidgets('ensures max 5 labels with compact intervals', (tester) async {
      // Data range: 1600 to 1700 (range=100)
      // rawInterval = 100 / 4 = 25
      // niceInterval = 20
      // minY = floor(1600/20) * 20 = 1600
      // maxY = ceil(1700/20) * 20 = 1700
      // numLabels = (1700-1600)/20 + 1 = 6 labels (TOO MANY)
      // Next interval = 50
      // minY = floor(1600/50) * 50 = 1600
      // maxY = ceil(1700/50) * 50 = 1700
      // numLabels = (1700-1600)/50 + 1 = 3 labels
      // Labels: 1600, 1650, 1700 (compact, exactly fits data)

      // Story 302.7: Minimum 3 games required
      final history = createHistory([1600, 1650, 1700]);

      await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],          home: Scaffold(
            body: MonthlyImprovementChart(
              ratingHistory: history,
              currentElo: 1700,
              timePeriod: TimePeriod.allTime, // Story 302.7: Use allTime to include older test data
            ),
          ),
        ),
      );

      final chart = tester.widget<LineChart>(find.byType(LineChart));
      final data = chart.data;

      final minY = data.minY;
      final maxY = data.maxY;
      final interval = data.titlesData.leftTitles.sideTitles.interval!;

      // Verify max 5 labels
      final numLabels = ((maxY - minY) / interval).round() + 1;
      expect(numLabels, lessThanOrEqualTo(5));

      // Verify compact interval (should be 50)
      expect(interval, equals(50.0));

      // Verify bounds are tight around the data
      expect(minY, equals(1600));
      expect(maxY, equals(1700));
    });

    testWidgets('handles small ranges with compact intervals', (tester) async {
      // Data range: 1599 to 1601 (range=2)
      // rawInterval = 2 / 4 = 0.5
      // niceInterval = 1 (minimum enforced)
      // minY = floor(1599/1) * 1 = 1599
      // maxY = ceil(1601/1) * 1 = 1601
      // numLabels = (1601-1599)/1 + 1 = 3 labels
      // Labels: 1599, 1600, 1601 (compact, exactly fits data)

      // Story 302.7: Minimum 3 games required
      final history = createHistory([1599, 1600, 1601]);

      await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],          home: Scaffold(
            body: MonthlyImprovementChart(
              ratingHistory: history,
              currentElo: 1601,
              timePeriod: TimePeriod.allTime, // Story 302.7: Use allTime to include older test data
            ),
          ),
        ),
      );

      final chart = tester.widget<LineChart>(find.byType(LineChart));
      final data = chart.data;
      final minY = data.minY;
      final maxY = data.maxY;
      final interval = data.titlesData.leftTitles.sideTitles.interval!;

      // Verify max 5 labels
      final numLabels = ((maxY - minY) / interval).round() + 1;
      expect(numLabels, lessThanOrEqualTo(5));

      // Interval should be 1
      expect(interval, equals(1.0));

      // Verify bounds are tight around the data
      expect(minY, equals(1599));
      expect(maxY, equals(1601));
    });

    testWidgets('handles range like 1600-1718 compactly', (tester) async {
      // Data range: 1600 to 1718 (range=118)
      // rawInterval = 118 / 4 = 29.5
      // niceInterval = 20
      // minY = floor(1600/20) * 20 = 1600
      // maxY = ceil(1718/20) * 20 = 1720
      // numLabels = (1720-1600)/20 + 1 = 7 labels (TOO MANY)
      // Next interval = 50
      // minY = floor(1600/50) * 50 = 1600
      // maxY = ceil(1718/50) * 50 = 1750
      // numLabels = (1750-1600)/50 + 1 = 4 labels
      // Labels: 1600, 1650, 1700, 1750 (compact, close to max 1718)

      // Story 302.7: Minimum 3 games required
      final history = createHistory([1600, 1659, 1718]);

      await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],          home: Scaffold(
            body: MonthlyImprovementChart(
              ratingHistory: history,
              currentElo: 1718,
              timePeriod: TimePeriod.allTime, // Story 302.7: Use allTime to include older test data
            ),
          ),
        ),
      );

      final chart = tester.widget<LineChart>(find.byType(LineChart));
      final data = chart.data;

      final minY = data.minY;
      final maxY = data.maxY;
      final interval = data.titlesData.leftTitles.sideTitles.interval!;

      // Verify max 5 labels
      final numLabels = ((maxY - minY) / interval).round() + 1;
      expect(numLabels, lessThanOrEqualTo(5));

      // Verify interval (should be 50)
      expect(interval, equals(50.0));

      // Verify bounds are reasonably tight (maxY should be 1750, not 1800)
      expect(minY, equals(1600));
      expect(maxY, equals(1750));
      expect(maxY, lessThan(1800)); // Much more compact than before!
    });
  });
}
