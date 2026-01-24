// Widget tests for HomeStatsSection
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:play_with_me/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:play_with_me/core/data/models/rating_history_entry.dart';
import 'package:play_with_me/core/data/models/user_model.dart';
import 'package:play_with_me/features/profile/presentation/widgets/home_stats_section.dart';
import 'package:play_with_me/features/profile/presentation/widgets/compact_stat_card.dart';
import 'package:play_with_me/features/profile/presentation/widgets/elo_trend_indicator.dart';
import 'package:play_with_me/features/profile/presentation/widgets/win_streak_badge.dart';

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

    final testHistory = <RatingHistoryEntry>[
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
        entryId: 'entry-4',
        gameId: 'game-4',
        oldRating: 1585,
        newRating: 1600,
        ratingChange: 15,
        opponentTeam: 'Team G & Team H',
        won: true,
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];

    testWidgets('renders section header', (tester) async {
      await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],          home: Scaffold(
            body: HomeStatsSection(
              user: testUser,
              ratingHistory: testHistory,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Performance Overview'), findsOneWidget);
    });

    testWidgets('renders ELOTrendIndicator', (tester) async {
      await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],          home: Scaffold(
            body: HomeStatsSection(
              user: testUser,
              ratingHistory: testHistory,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ELOTrendIndicator), findsOneWidget);
    });

    testWidgets('renders CompactStatCard widgets', (tester) async {
      await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],          home: Scaffold(
            body: HomeStatsSection(
              user: testUser,
              ratingHistory: testHistory,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Should have 2 CompactStatCards: Win Rate and Games Played
      expect(find.byType(CompactStatCard), findsNWidgets(2));
      expect(find.text('Win Rate'), findsOneWidget);
      expect(find.text('Games Played'), findsOneWidget);
    });

    testWidgets('displays correct win rate', (tester) async {
      await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],          home: Scaffold(
            body: HomeStatsSection(
              user: testUser,
              ratingHistory: testHistory,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final expectedWinRate = (testUser.winRate * 100).toStringAsFixed(1);
      expect(find.text('$expectedWinRate%'), findsOneWidget);
      expect(find.text('${testUser.gamesWon}W - ${testUser.gamesLost}L'), findsOneWidget);
    });

    testWidgets('displays correct games played', (tester) async {
      await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],          home: Scaffold(
            body: HomeStatsSection(
              user: testUser,
              ratingHistory: testHistory,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(testUser.gamesPlayed.toString()), findsOneWidget);
    });

    testWidgets('renders WinStreakBadge when streak >= 2', (tester) async {
      await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],          home: Scaffold(
            body: HomeStatsSection(
              user: testUser,
              ratingHistory: testHistory,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(WinStreakBadge), findsOneWidget);
    });

    testWidgets('does not render WinStreakBadge when streak < 2', (tester) async {
      final userWithSmallStreak = testUser.copyWith(currentStreak: 1);

      await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],          home: Scaffold(
            body: HomeStatsSection(
              user: userWithSmallStreak,
              ratingHistory: testHistory,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(WinStreakBadge), findsNothing);
    });

    testWidgets('renders WinStreakBadge for negative streak <= -2', (tester) async {
      final userWithLossStreak = testUser.copyWith(currentStreak: -3);

      await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],          home: Scaffold(
            body: HomeStatsSection(
              user: userWithLossStreak,
              ratingHistory: testHistory,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(WinStreakBadge), findsOneWidget);
    });

    testWidgets('handles empty rating history', (tester) async {
      await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],          home: Scaffold(
            body: HomeStatsSection(
              user: testUser,
              ratingHistory: const [],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Should still render without errors
      expect(find.byType(ELOTrendIndicator), findsOneWidget);
      expect(find.byType(CompactStatCard), findsNWidgets(2));
    });

    testWidgets('handles user with no games played', (tester) async {
      final newUser = testUser.copyWith(
        gamesPlayed: 0,
        gamesWon: 0,
        gamesLost: 0,
        currentStreak: 0,
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
            body: HomeStatsSection(
              user: newUser,
              ratingHistory: const [],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('0'), findsAtLeastNWidgets(1)); // Games played = 0
      expect(find.byType(WinStreakBadge), findsNothing); // No streak badge
    });
  });
}
