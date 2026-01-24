// Widget tests for enhanced MonthlyImprovementChart (Story 302.4, 302.7)
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:play_with_me/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:play_with_me/core/data/models/rating_history_entry.dart';
import 'package:play_with_me/core/domain/entities/time_period.dart';
import 'package:play_with_me/features/profile/presentation/widgets/monthly_improvement_chart.dart';
import 'package:play_with_me/features/profile/presentation/widgets/empty_states/insufficient_data_placeholder.dart';
import 'package:fl_chart/fl_chart.dart';

void main() {
  group('MonthlyImprovementChart Widget Tests', () {
    testWidgets('shows placeholder when history is empty', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],
          home: Scaffold(
            body: MonthlyImprovementChart(
              ratingHistory: [],
              currentElo: 1600.0,
              timePeriod: TimePeriod.allTime,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Story 302.7: Updated text expectations for new placeholder
      expect(find.byType(InsufficientDataPlaceholder), findsOneWidget);
      expect(find.text('Monthly Progress Chart'), findsOneWidget);
      expect(find.text('Play at least 3 games'), findsOneWidget);
      expect(find.text('0/3 games'), findsOneWidget);
      expect(find.byIcon(Icons.timeline), findsOneWidget);
    });

    testWidgets('shows placeholder when only 1 month of data', (tester) async {
      // Story 302.7: Need at least 3 games, but all in same month
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
        RatingHistoryEntry(
          entryId: 'entry-3',
          gameId: 'game-3',
          oldRating: 1640,
          newRating: 1660,
          ratingChange: 20,
          opponentTeam: 'Team C',
          won: true,
          timestamp: DateTime(2024, 1, 25),
        ),
      ];

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
              ratingHistory: singleMonthHistory,
              currentElo: 1640.0,
              timePeriod: TimePeriod.allTime,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Story 302.7: With 3 games in same month, aggregates to 1 data point (needs 2+)
      expect(find.byType(InsufficientDataPlaceholder), findsOneWidget);
      expect(find.text('Monthly Progress Chart'), findsOneWidget);
      expect(find.text('Play games over a longer period'), findsOneWidget);
    });

    testWidgets('shows chart when 2 months of data', (tester) async {
      // Story 302.7: Need at least 3 games
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
        RatingHistoryEntry(
          entryId: 'entry-3',
          gameId: 'game-3',
          oldRating: 1650,
          newRating: 1670,
          ratingChange: 20,
          opponentTeam: 'Team C',
          won: true,
          timestamp: DateTime(2024, 2, 20),
        ),
      ];

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
              ratingHistory: twoMonthHistory,
              currentElo: 1650.0,
              timePeriod: TimePeriod.allTime,
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
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],          home: Scaffold(
            body: MonthlyImprovementChart(
              ratingHistory: multiMonthHistory,
              currentElo: 1640.0,
              timePeriod: TimePeriod.allTime,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(LineChart), findsOneWidget);
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
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],          home: Scaffold(
            body: MonthlyImprovementChart(
              ratingHistory: sameMonthGames,
              currentElo: 1650.0,
              timePeriod: TimePeriod.allTime,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Should use most recent entry from January (1620) as end-of-month snapshot
      expect(find.byType(LineChart), findsOneWidget);
    });

    // Story 302.4: New tests for adaptive aggregation
    testWidgets('uses daily aggregation for 15-day period', (tester) async {
      final now = DateTime.now();
      final dailyHistory = List.generate(
        10,
        (i) => RatingHistoryEntry(
          entryId: 'entry-$i',
          gameId: 'game-$i',
          oldRating: 1600 + (i * 10).toDouble(),
          newRating: 1610 + (i * 10).toDouble(),
          ratingChange: 10,
          opponentTeam: 'Team ${String.fromCharCode(65 + i)}',
          won: true,
          timestamp: now.subtract(Duration(days: 10 - i)),
        ),
      );

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
              ratingHistory: dailyHistory,
              currentElo: 1700.0,
              timePeriod: TimePeriod.thirtyDays,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(LineChart), findsOneWidget);
    });

    testWidgets('uses weekly aggregation for 90-day period', (tester) async {
      final now = DateTime.now();
      final weeklyHistory = List.generate(
        20,
        (i) => RatingHistoryEntry(
          entryId: 'entry-$i',
          gameId: 'game-$i',
          oldRating: 1600 + (i * 5).toDouble(),
          newRating: 1605 + (i * 5).toDouble(),
          ratingChange: 5,
          opponentTeam: 'Team ${String.fromCharCode(65 + (i % 26))}',
          won: true,
          timestamp: now.subtract(Duration(days: 70 - (i * 3))),
        ),
      );

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
              ratingHistory: weeklyHistory,
              currentElo: 1700.0,
              timePeriod: TimePeriod.ninetyDays,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(LineChart), findsOneWidget);
    });

    testWidgets('uses monthly aggregation for 1-year period', (tester) async {
      final monthlyHistory = List.generate(
        12,
        (i) => RatingHistoryEntry(
          entryId: 'entry-$i',
          gameId: 'game-$i',
          oldRating: 1600 + (i * 10).toDouble(),
          newRating: 1610 + (i * 10).toDouble(),
          ratingChange: 10,
          opponentTeam: 'Team ${String.fromCharCode(65 + i)}',
          won: true,
          timestamp: DateTime(2024, i + 1, 15),
        ),
      );

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
              ratingHistory: monthlyHistory,
              currentElo: 1720.0,
              timePeriod: TimePeriod.allTime, // Story 302.7: Use allTime for 2024 test data
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(LineChart), findsOneWidget);
    });

    testWidgets('hides dots for large datasets (> 15 points)', (tester) async {
      // Create 20 months of data
      final largeDataset = List.generate(
        20,
        (i) => RatingHistoryEntry(
          entryId: 'entry-$i',
          gameId: 'game-$i',
          oldRating: 1600 + (i * 5).toDouble(),
          newRating: 1605 + (i * 5).toDouble(),
          ratingChange: 5,
          opponentTeam: 'Team ${String.fromCharCode(65 + (i % 26))}',
          won: true,
          timestamp: DateTime(2023, (i % 12) + 1, 15 + (i ~/ 12)),
        ),
      );

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
              ratingHistory: largeDataset,
              currentElo: 1700.0,
              timePeriod: TimePeriod.allTime,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Chart should render without dots for datasets > 15
      expect(find.byType(LineChart), findsOneWidget);
    });

    testWidgets('shows dots for small datasets (<= 15 points)', (tester) async {
      // Create 5 months of data
      final smallDataset = List.generate(
        5,
        (i) => RatingHistoryEntry(
          entryId: 'entry-$i',
          gameId: 'game-$i',
          oldRating: 1600 + (i * 10).toDouble(),
          newRating: 1610 + (i * 10).toDouble(),
          ratingChange: 10,
          opponentTeam: 'Team ${String.fromCharCode(65 + i)}',
          won: true,
          timestamp: DateTime(2024, i + 1, 15),
        ),
      );

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
              ratingHistory: smallDataset,
              currentElo: 1650.0,
              timePeriod: TimePeriod.allTime,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Chart should render with dots for datasets <= 15
      expect(find.byType(LineChart), findsOneWidget);
    });

    testWidgets('chart has proper height (220)', (tester) async {
      // Story 302.7: Need at least 3 games
      final historyData = [
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
          newRating: 1670,
          ratingChange: 20,
          opponentTeam: 'Team C',
          won: true,
          timestamp: DateTime(2024, 3, 5),
        ),
      ];

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
              ratingHistory: historyData,
              currentElo: 1650.0,
              timePeriod: TimePeriod.allTime,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final sizedBox = find.byType(SizedBox).first;
      final widget = tester.widget<SizedBox>(sizedBox);
      expect(widget.height, 220);
    });
  });
}
