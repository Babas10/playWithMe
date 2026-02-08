// Widget tests for HomeStatsSection with Performance Overview title and 4 stat cards.
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:play_with_me/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:play_with_me/core/data/models/rating_history_entry.dart';
import 'package:play_with_me/core/data/models/user_model.dart';
import 'package:play_with_me/features/profile/presentation/widgets/home_stats_section.dart';

void main() {
  group('HomeStatsSection Widget Tests', () {
    final testUser = UserModel(
      uid: 'user-123',
      email: 'test@example.com',
      displayName: 'Test User',
      isEmailVerified: true,
      isAnonymous: false,
      eloRating: 1600.0,
      gamesPlayed: 50,
      gamesWon: 30,
      gamesLost: 20,
      currentStreak: 3,
    );

    // History ordered newest-first (widget's _calculateTrend expects first=newest)
    final testHistory = <RatingHistoryEntry>[
      RatingHistoryEntry(
        entryId: 'entry-4',
        gameId: 'game-4',
        oldRating: 1585,
        newRating: 1600,
        ratingChange: 15,
        opponentTeam: 'Team G & Team H',
        won: true,
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
      ),
      RatingHistoryEntry(
        entryId: 'entry-3',
        gameId: 'game-3',
        oldRating: 1570,
        newRating: 1585,
        ratingChange: 15,
        opponentTeam: 'Team E & Team F',
        won: true,
        timestamp: DateTime.now().subtract(const Duration(days: 2)),
      ),
      RatingHistoryEntry(
        entryId: 'entry-2',
        gameId: 'game-2',
        oldRating: 1550,
        newRating: 1570,
        ratingChange: 20,
        opponentTeam: 'Team C & Team D',
        won: true,
        timestamp: DateTime.now().subtract(const Duration(days: 3)),
      ),
      RatingHistoryEntry(
        entryId: 'entry-1',
        gameId: 'game-1',
        oldRating: 1560,
        newRating: 1550,
        ratingChange: -10,
        opponentTeam: 'Team A & Team B',
        won: false,
        timestamp: DateTime.now().subtract(const Duration(days: 4)),
      ),
    ];

    Future<void> pumpHomeStatsSection(
      WidgetTester tester, {
      UserModel? user,
      List<RatingHistoryEntry>? history,
    }) async {
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
            body: HomeStatsSection(
              user: user ?? testUser,
              ratingHistory: history ?? testHistory,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('renders Performance Overview section title', (tester) async {
      await pumpHomeStatsSection(tester);

      expect(find.text('PERFORMANCE OVERVIEW'), findsOneWidget);
    });

    testWidgets('renders ELO rating label and value', (tester) async {
      await pumpHomeStatsSection(tester);

      expect(find.text('ELO Rating'), findsOneWidget);
      expect(find.text('1600'), findsOneWidget);
    });

    testWidgets('renders streak label', (tester) async {
      await pumpHomeStatsSection(tester);

      expect(find.text('Streak'), findsOneWidget);
    });

    testWidgets('renders win rate and games played labels', (tester) async {
      await pumpHomeStatsSection(tester);

      expect(find.text('Win Rate'), findsOneWidget);
      expect(find.text('Games Played'), findsOneWidget);
    });

    testWidgets('renders trophy icon for win rate card', (tester) async {
      await pumpHomeStatsSection(tester);

      expect(find.byIcon(Icons.emoji_events), findsOneWidget);
    });

    testWidgets('renders volleyball icon for games played card', (tester) async {
      await pumpHomeStatsSection(tester);

      expect(find.byIcon(Icons.sports_volleyball), findsOneWidget);
    });

    testWidgets('displays correct win rate value', (tester) async {
      await pumpHomeStatsSection(tester);

      final expectedWinRate = (testUser.winRate * 100).toStringAsFixed(1);
      expect(find.text('$expectedWinRate%'), findsOneWidget);
      expect(find.text('${testUser.gamesWon}W - ${testUser.gamesLost}L'), findsOneWidget);
    });

    testWidgets('displays correct games played value', (tester) async {
      await pumpHomeStatsSection(tester);

      expect(find.text(testUser.gamesPlayed.toString()), findsOneWidget);
    });

    testWidgets('shows winning streak with weather emoji when streak >= 2', (tester) async {
      await pumpHomeStatsSection(tester);

      // User has currentStreak = 3, should show "3 wins ☀️" weather metaphor
      expect(find.textContaining('3 wins'), findsOneWidget);
    });

    testWidgets('shows no streak text when streak < 2', (tester) async {
      final userWithSmallStreak = testUser.copyWith(currentStreak: 1);

      await pumpHomeStatsSection(tester, user: userWithSmallStreak);

      expect(find.text('None'), findsOneWidget);
    });

    testWidgets('shows losing streak with weather emoji for negative streak <= -2', (tester) async {
      final userWithLossStreak = testUser.copyWith(currentStreak: -3);

      await pumpHomeStatsSection(tester, user: userWithLossStreak);

      // Should show "3 losses 🌧️" weather metaphor in red
      expect(find.textContaining('3 losses'), findsOneWidget);
    });

    testWidgets('shows ELO trend delta for positive history', (tester) async {
      await pumpHomeStatsSection(tester);

      // first.newRating=1600, last.oldRating=1560, delta=+40
      expect(find.text('+40'), findsOneWidget);
    });

    testWidgets('handles empty rating history', (tester) async {
      await pumpHomeStatsSection(tester, history: const []);

      // Should show "No games played yet" in ELO card
      expect(find.text('No games played yet'), findsOneWidget);
      // Should still render all 4 cards without errors
      expect(find.byType(Card), findsNWidgets(4));
    });

    testWidgets('handles user with no games played', (tester) async {
      final newUser = testUser.copyWith(
        gamesPlayed: 0,
        gamesWon: 0,
        gamesLost: 0,
        currentStreak: 0,
      );

      await pumpHomeStatsSection(tester, user: newUser, history: const []);

      expect(find.text('0'), findsAtLeastNWidgets(1)); // Games played = 0
      expect(find.text('None'), findsOneWidget); // No streak
    });

    testWidgets('renders four cards in two rows', (tester) async {
      await pumpHomeStatsSection(tester);

      // Should have exactly 4 Card widgets: ELO, Streak, Win Rate, Games Played
      expect(find.byType(Card), findsNWidgets(4));
    });
  });
}
