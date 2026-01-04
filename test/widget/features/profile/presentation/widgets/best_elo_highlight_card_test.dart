// Validates BestEloHighlightCard displays best ELO data and empty states correctly.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:play_with_me/core/data/models/best_elo_record.dart';
import 'package:play_with_me/core/domain/entities/time_period.dart';
import 'package:play_with_me/features/profile/presentation/widgets/best_elo_highlight_card.dart';

void main() {
  group('BestEloHighlightCard', () {
    testWidgets('shows empty state when bestElo is null', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BestEloHighlightCard(
              bestElo: null,
              timePeriod: TimePeriod.allTime,
            ),
          ),
        ),
      );

      expect(find.text('No games in this period'), findsOneWidget);
      expect(find.byIcon(Icons.emoji_events_outlined), findsOneWidget);
      expect(find.byIcon(Icons.emoji_events), findsNothing);
    });

    testWidgets('displays ELO value correctly', (tester) async {
      final bestElo = BestEloRecord(
        elo: 1847.5,
        date: DateTime(2025, 12, 15),
        gameId: 'game-123',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BestEloHighlightCard(
              bestElo: bestElo,
              timePeriod: TimePeriod.allTime,
            ),
          ),
        ),
      );

      // ELO should be displayed without decimals
      expect(find.text('1848'), findsOneWidget);
    });

    testWidgets('formats date as "MMM d, yyyy"', (tester) async {
      final date = DateTime(2025, 12, 15);
      final bestElo = BestEloRecord(
        elo: 1847.0,
        date: date,
        gameId: 'game-123',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BestEloHighlightCard(
              bestElo: bestElo,
              timePeriod: TimePeriod.allTime,
            ),
          ),
        ),
      );

      final expectedDate = DateFormat('MMM d, yyyy').format(date);
      expect(find.text(expectedDate), findsOneWidget);
    });

    testWidgets('shows trophy icon for data state', (tester) async {
      final bestElo = BestEloRecord(
        elo: 1847.0,
        date: DateTime(2025, 12, 15),
        gameId: 'game-123',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BestEloHighlightCard(
              bestElo: bestElo,
              timePeriod: TimePeriod.allTime,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.emoji_events), findsOneWidget);
    });

    group('period label', () {
      testWidgets('shows "This Month" for thirtyDays', (tester) async {
        final bestElo = BestEloRecord(
          elo: 1847.0,
          date: DateTime(2025, 12, 15),
          gameId: 'game-123',
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BestEloHighlightCard(
                bestElo: bestElo,
                timePeriod: TimePeriod.thirtyDays,
              ),
            ),
          ),
        );

        expect(find.text('Best ELO This Month'), findsOneWidget);
      });

      testWidgets('shows "Past 90 Days" for ninetyDays', (tester) async {
        final bestElo = BestEloRecord(
          elo: 1847.0,
          date: DateTime(2025, 12, 15),
          gameId: 'game-123',
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BestEloHighlightCard(
                bestElo: bestElo,
                timePeriod: TimePeriod.ninetyDays,
              ),
            ),
          ),
        );

        expect(find.text('Best ELO Past 90 Days'), findsOneWidget);
      });

      testWidgets('shows "This Year" for oneYear', (tester) async {
        final bestElo = BestEloRecord(
          elo: 1847.0,
          date: DateTime(2025, 12, 15),
          gameId: 'game-123',
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BestEloHighlightCard(
                bestElo: bestElo,
                timePeriod: TimePeriod.oneYear,
              ),
            ),
          ),
        );

        expect(find.text('Best ELO This Year'), findsOneWidget);
      });

      testWidgets('shows "All Time" for allTime', (tester) async {
        final bestElo = BestEloRecord(
          elo: 1847.0,
          date: DateTime(2025, 12, 15),
          gameId: 'game-123',
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BestEloHighlightCard(
                bestElo: bestElo,
                timePeriod: TimePeriod.allTime,
              ),
            ),
          ),
        );

        expect(find.text('Best ELO All Time'), findsOneWidget);
      });
    });

    testWidgets('tap triggers onTap callback when provided', (tester) async {
      bool tapped = false;
      final bestElo = BestEloRecord(
        elo: 1847.0,
        date: DateTime(2025, 12, 15),
        gameId: 'game-123',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BestEloHighlightCard(
              bestElo: bestElo,
              timePeriod: TimePeriod.allTime,
              onTap: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(InkWell));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });

    testWidgets('tap callback works when onTap is provided', (tester) async {
      final bestElo = BestEloRecord(
        elo: 1847.0,
        date: DateTime(2025, 12, 15),
        gameId: 'game-123',
      );

      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BestEloHighlightCard(
              bestElo: bestElo,
              timePeriod: TimePeriod.allTime,
              onTap: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(InkWell));
      expect(tapped, isTrue);
    });

    testWidgets('card still renders when onTap is null', (tester) async {
      final bestElo = BestEloRecord(
        elo: 1847.0,
        date: DateTime(2025, 12, 15),
        gameId: 'game-123',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BestEloHighlightCard(
              bestElo: bestElo,
              timePeriod: TimePeriod.allTime,
              onTap: null,
            ),
          ),
        ),
      );

      expect(find.byType(BestEloHighlightCard), findsOneWidget);
      expect(find.text('1847'), findsOneWidget);
    });

    testWidgets('card has gradient background', (tester) async {
      final bestElo = BestEloRecord(
        elo: 1847.0,
        date: DateTime(2025, 12, 15),
        gameId: 'game-123',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BestEloHighlightCard(
              bestElo: bestElo,
              timePeriod: TimePeriod.allTime,
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(InkWell),
          matching: find.byType(Container),
        ).first,
      );

      expect(container.decoration, isA<BoxDecoration>());
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.gradient, isA<LinearGradient>());
    });

    testWidgets('card has border in data state', (tester) async {
      final bestElo = BestEloRecord(
        elo: 1847.0,
        date: DateTime(2025, 12, 15),
        gameId: 'game-123',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BestEloHighlightCard(
              bestElo: bestElo,
              timePeriod: TimePeriod.allTime,
            ),
          ),
        ),
      );

      final card = tester.widget<Card>(find.byType(Card));
      expect(card.shape, isA<RoundedRectangleBorder>());

      final shape = card.shape as RoundedRectangleBorder;
      expect(shape.side.width, 1.0);
    });

    testWidgets('handles large ELO values correctly', (tester) async {
      final bestElo = BestEloRecord(
        elo: 9999.9,
        date: DateTime(2025, 12, 15),
        gameId: 'game-123',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BestEloHighlightCard(
              bestElo: bestElo,
              timePeriod: TimePeriod.allTime,
            ),
          ),
        ),
      );

      expect(find.text('10000'), findsOneWidget);
    });

    testWidgets('handles low ELO values correctly', (tester) async {
      final bestElo = BestEloRecord(
        elo: 100.1,
        date: DateTime(2025, 12, 15),
        gameId: 'game-123',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BestEloHighlightCard(
              bestElo: bestElo,
              timePeriod: TimePeriod.allTime,
            ),
          ),
        ),
      );

      expect(find.text('100'), findsOneWidget);
    });

    testWidgets('empty state has proper styling', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BestEloHighlightCard(
              bestElo: null,
              timePeriod: TimePeriod.allTime,
            ),
          ),
        ),
      );

      final card = tester.widget<Card>(find.byType(Card));
      expect(card.elevation, 0);
      expect(card.shape, isA<RoundedRectangleBorder>());
    });
  });
}
