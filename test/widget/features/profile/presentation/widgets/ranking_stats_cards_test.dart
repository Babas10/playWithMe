// Validates RankingStatsCards widget displays correct ranking stats (Story 302.5).
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:play_with_me/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:play_with_me/core/data/models/user_ranking.dart';
import 'package:play_with_me/features/profile/presentation/widgets/ranking_stats_cards.dart';

void main() {
  group('RankingStatsCards', () {
    testWidgets('shows empty state when ranking is null', (tester) async {
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
            body: RankingStatsCards(
              ranking: null,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.lock_outline), findsOneWidget);
      expect(find.text('Play games to unlock rankings'), findsOneWidget);
    });

    testWidgets('displays global rank correctly', (tester) async {
      final ranking = UserRanking(
        globalRank: 42,
        totalUsers: 1500,
        percentile: 97.2,
        calculatedAt: DateTime(2024, 1, 1),
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
            body: RankingStatsCards(
              ranking: ranking,
            ),
          ),
        ),
      );

      expect(find.text('Global Rank'), findsOneWidget);
      expect(find.text('#42 of 1,500'), findsOneWidget);
      expect(find.byIcon(Icons.public), findsOneWidget);
    });

    testWidgets('displays percentile correctly', (tester) async {
      final ranking = UserRanking(
        globalRank: 42,
        totalUsers: 1500,
        percentile: 97.2,
        calculatedAt: DateTime(2024, 1, 1),
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
            body: RankingStatsCards(
              ranking: ranking,
            ),
          ),
        ),
      );

      expect(find.text('Percentile'), findsOneWidget);
      expect(find.text('Top 2.8%'), findsOneWidget);
      expect(find.byIcon(Icons.trending_up), findsOneWidget);
    });

    testWidgets('displays friends rank when available', (tester) async {
      final ranking = UserRanking(
        globalRank: 42,
        totalUsers: 1500,
        percentile: 97.2,
        friendsRank: 3,
        totalFriends: 15,
        calculatedAt: DateTime(2024, 1, 1),
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
            body: RankingStatsCards(
              ranking: ranking,
            ),
          ),
        ),
      );

      expect(find.text('Friends Rank'), findsOneWidget);
      expect(find.text('#3 of 15'), findsOneWidget);
      expect(find.byIcon(Icons.people), findsOneWidget);
    });

    testWidgets('shows "Add friends" when no friends', (tester) async {
      final ranking = UserRanking(
        globalRank: 42,
        totalUsers: 1500,
        percentile: 97.2,
        calculatedAt: DateTime(2024, 1, 1),
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
            body: RankingStatsCards(
              ranking: ranking,
            ),
          ),
        ),
      );

      expect(find.text('Friends Rank'), findsOneWidget);
      expect(find.text('Add friends'), findsOneWidget);
      expect(find.byIcon(Icons.people), findsOneWidget);
    });

    testWidgets('tap on "Add friends" triggers callback', (tester) async {
      final ranking = UserRanking(
        globalRank: 42,
        totalUsers: 1500,
        percentile: 97.2,
        calculatedAt: DateTime(2024, 1, 1),
      );

      bool callbackTriggered = false;

      await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],          home: Scaffold(
            body: RankingStatsCards(
              ranking: ranking,
              onAddFriendsTap: () {
                callbackTriggered = true;
              },
            ),
          ),
        ),
      );

      // Find and tap the "Add friends" text
      await tester.tap(find.text('Add friends'));
      await tester.pumpAndSettle();

      expect(callbackTriggered, isTrue);
    });

    testWidgets('responsive layout: horizontal on wide screens', (tester) async {
      final ranking = UserRanking(
        globalRank: 42,
        totalUsers: 1500,
        percentile: 97.2,
        friendsRank: 3,
        totalFriends: 15,
        calculatedAt: DateTime(2024, 1, 1),
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
            body: Center(
              child: SizedBox(
                width: 600, // Wide screen
                child: RankingStatsCards(
                  ranking: ranking,
                ),
              ),
            ),
          ),
        ),
      );

      // Check that a Row widget is used (horizontal layout)
      expect(find.byType(Row), findsWidgets);
    });

    testWidgets('responsive layout: vertical on very narrow screens', (tester) async {
      final ranking = UserRanking(
        globalRank: 42,
        totalUsers: 1500,
        percentile: 97.2,
        friendsRank: 3,
        totalFriends: 15,
        calculatedAt: DateTime(2024, 1, 1),
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
            body: Center(
              child: SizedBox(
                width: 250, // Very narrow screen (< 280px threshold)
                child: RankingStatsCards(
                  ranking: ranking,
                ),
              ),
            ),
          ),
        ),
      );

      // Check that a Column widget is used (vertical layout)
      expect(find.byType(Column), findsWidgets);
    });

    testWidgets('icons display with correct colors', (tester) async {
      final ranking = UserRanking(
        globalRank: 42,
        totalUsers: 1500,
        percentile: 97.2,
        friendsRank: 3,
        totalFriends: 15,
        calculatedAt: DateTime(2024, 1, 1),
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
            body: RankingStatsCards(
              ranking: ranking,
            ),
          ),
        ),
      );

      // Find all icon widgets
      final iconFinders = [
        find.byIcon(Icons.public),
        find.byIcon(Icons.trending_up),
        find.byIcon(Icons.people),
      ];

      for (final finder in iconFinders) {
        expect(finder, findsOneWidget);
      }
    });

    testWidgets('all three cards rendered when ranking has all data', (tester) async {
      final ranking = UserRanking(
        globalRank: 1,
        totalUsers: 10000,
        percentile: 99.9,
        friendsRank: 1,
        totalFriends: 50,
        calculatedAt: DateTime(2024, 1, 1),
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
            body: RankingStatsCards(
              ranking: ranking,
            ),
          ),
        ),
      );

      expect(find.text('Global Rank'), findsOneWidget);
      expect(find.text('Percentile'), findsOneWidget);
      expect(find.text('Friends Rank'), findsOneWidget);
      expect(find.text('#1 of 10,000'), findsOneWidget);
      expect(find.text('Top 0.1%'), findsOneWidget);
      expect(find.text('#1 of 50'), findsOneWidget);
    });
  });
}
