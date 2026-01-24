// Widget tests for ELOTrendIndicator
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:play_with_me/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:play_with_me/core/data/models/rating_history_entry.dart';
import 'package:play_with_me/features/profile/presentation/widgets/elo_trend_indicator.dart';

void main() {
  group('ELOTrendIndicator Widget Tests', () {
    testWidgets('displays current ELO with no trend when history is empty',
        (tester) async {
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
            body: ELOTrendIndicator(
              currentElo: 1650.0,
              recentHistory: [],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('ELO Rating'), findsOneWidget);
      expect(find.text('1650'), findsOneWidget);
      expect(find.text('No games played yet'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_upward), findsNothing);
      expect(find.byIcon(Icons.arrow_downward), findsNothing);
    });

    testWidgets('displays positive trend with upward arrow', (tester) async {
      final history = [
        RatingHistoryEntry(
          entryId: 'entry-3',
          gameId: 'game-3',
          oldRating: 1640,
          newRating: 1660,
          ratingChange: 20,
          opponentTeam: 'Team C',
          won: true,
          timestamp: DateTime.now(),
        ),
        RatingHistoryEntry(
          entryId: 'entry-2',
          gameId: 'game-2',
          oldRating: 1625,
          newRating: 1640,
          ratingChange: 15,
          opponentTeam: 'Team B',
          won: true,
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
        ),
        RatingHistoryEntry(
          entryId: 'entry-1',
          gameId: 'game-1',
          oldRating: 1600,
          newRating: 1625,
          ratingChange: 25,
          opponentTeam: 'Team A',
          won: true,
          timestamp: DateTime.now().subtract(const Duration(days: 2)),
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
            body: ELOTrendIndicator(
              currentElo: 1660.0,
              recentHistory: history,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('1660'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_upward), findsOneWidget);
      expect(find.text('+60'), findsOneWidget); // 1660 - 1600
      expect(find.text('Last 3 games'), findsOneWidget);
    });

    testWidgets('displays negative trend with downward arrow', (tester) async {
      final history = [
        RatingHistoryEntry(
          entryId: 'entry-3',
          gameId: 'game-3',
          oldRating: 1640,
          newRating: 1620,
          ratingChange: -20,
          opponentTeam: 'Team C',
          won: false,
          timestamp: DateTime.now(),
        ),
        RatingHistoryEntry(
          entryId: 'entry-2',
          gameId: 'game-2',
          oldRating: 1655,
          newRating: 1640,
          ratingChange: -15,
          opponentTeam: 'Team B',
          won: false,
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
        ),
        RatingHistoryEntry(
          entryId: 'entry-1',
          gameId: 'game-1',
          oldRating: 1680,
          newRating: 1655,
          ratingChange: -25,
          opponentTeam: 'Team A',
          won: false,
          timestamp: DateTime.now().subtract(const Duration(days: 2)),
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
            body: ELOTrendIndicator(
              currentElo: 1620.0,
              recentHistory: history,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('1620'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_downward), findsOneWidget);
      expect(find.text('-60'), findsOneWidget); // 1620 - 1680
    });

    testWidgets('respects lookbackGames parameter', (tester) async {
      final history = [
        RatingHistoryEntry(
          entryId: 'entry-5',
          gameId: 'game-5',
          oldRating: 1640,
          newRating: 1660,
          ratingChange: 20,
          opponentTeam: 'Team E',
          won: true,
          timestamp: DateTime.now(),
        ),
        RatingHistoryEntry(
          entryId: 'entry-4',
          gameId: 'game-4',
          oldRating: 1625,
          newRating: 1640,
          ratingChange: 15,
          opponentTeam: 'Team D',
          won: true,
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
        ),
        RatingHistoryEntry(
          entryId: 'entry-3',
          gameId: 'game-3',
          oldRating: 1600,
          newRating: 1625,
          ratingChange: 25,
          opponentTeam: 'Team C',
          won: true,
          timestamp: DateTime.now().subtract(const Duration(days: 2)),
        ),
        RatingHistoryEntry(
          entryId: 'entry-2',
          gameId: 'game-2',
          oldRating: 1580,
          newRating: 1600,
          ratingChange: 20,
          opponentTeam: 'Team B',
          won: true,
          timestamp: DateTime.now().subtract(const Duration(days: 3)),
        ),
        RatingHistoryEntry(
          entryId: 'entry-1',
          gameId: 'game-1',
          oldRating: 1550,
          newRating: 1580,
          ratingChange: 30,
          opponentTeam: 'Team A',
          won: true,
          timestamp: DateTime.now().subtract(const Duration(days: 4)),
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
            body: ELOTrendIndicator(
              currentElo: 1660.0,
              recentHistory: history,
              lookbackGames: 3, // Only look at last 3 games
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('1660'), findsOneWidget);
      expect(find.text('+60'), findsOneWidget); // 1660 - 1600 (3 games)
      expect(find.text('Last 3 games'), findsOneWidget);
    });

    testWidgets('handles zero delta correctly', (tester) async {
      final history = [
        RatingHistoryEntry(
          entryId: 'entry-2',
          gameId: 'game-2',
          oldRating: 1650,
          newRating: 1660,
          ratingChange: 10,
          opponentTeam: 'Team B',
          won: true,
          timestamp: DateTime.now(),
        ),
        RatingHistoryEntry(
          entryId: 'entry-1',
          gameId: 'game-1',
          oldRating: 1660,
          newRating: 1650,
          ratingChange: -10,
          opponentTeam: 'Team A',
          won: false,
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
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
            body: ELOTrendIndicator(
              currentElo: 1660.0,
              recentHistory: history,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('1660'), findsOneWidget);
      // No arrow or delta should be shown when delta is 0
      expect(find.byIcon(Icons.arrow_upward), findsNothing);
      expect(find.byIcon(Icons.arrow_downward), findsNothing);
    });

    testWidgets('displays card with correct structure', (tester) async {
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
            body: ELOTrendIndicator(
              currentElo: 1650.0,
              recentHistory: [],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(Card), findsOneWidget);
      expect(find.byType(Column), findsWidgets);
      expect(find.byType(Row), findsOneWidget);
    });

    testWidgets('formats ELO as integer (no decimals)', (tester) async {
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
            body: ELOTrendIndicator(
              currentElo: 1649.7,
              recentHistory: [],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('1650'), findsOneWidget); // Rounded to nearest int
      expect(find.text('1649.7'), findsNothing);
    });
  });
}
