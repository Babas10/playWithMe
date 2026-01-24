// Widget tests for PartnersCard displaying teammate display names.
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:play_with_me/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:play_with_me/core/data/models/user_model.dart';
import 'package:play_with_me/features/profile/presentation/widgets/partners_card.dart';

void main() {
  group('PartnersCard Widget Tests', () {
    testWidgets('displays teammate display name instead of user ID', (tester) async {
      // Create a user with teammate stats including display name
      final user = UserModel(
        uid: 'user-123',
        email: 'test@example.com',
        displayName: 'Test User',
        isEmailVerified: true,
        isAnonymous: false,
        teammateStats: {
          'teammate-456': {
            'teammateName': 'John Doe',
            'gamesPlayed': 10,
            'gamesWon': 8,
            'gamesLost': 2,
            'pointsScored': 100,
            'pointsAllowed': 50,
            'eloChange': 25.0,
          },
        },
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
            body: PartnersCard(user: user),
          ),
        ),
      );

      // Verify display name is shown
      expect(find.text('John Doe'), findsOneWidget);

      // Verify user ID is NOT shown
      expect(find.textContaining('User ID:'), findsNothing);
      expect(find.textContaining('teammate-456'), findsNothing);

      // Verify other stats are still displayed
      expect(find.text('80.0% Win Rate'), findsOneWidget);
      expect(find.text('8W - 2L • 10 games'), findsOneWidget);
    });

    testWidgets('displays "Unknown Player" when teammateName is missing', (tester) async {
      // Create a user with teammate stats WITHOUT display name (legacy data)
      final user = UserModel(
        uid: 'user-123',
        email: 'test@example.com',
        displayName: 'Test User',
        isEmailVerified: true,
        isAnonymous: false,
        teammateStats: {
          'teammate-789': {
            // Missing 'teammateName' field (legacy data)
            'gamesPlayed': 7,
            'gamesWon': 5,
            'gamesLost': 2,
            'pointsScored': 70,
            'pointsAllowed': 40,
            'eloChange': 15.0,
          },
        },
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
            body: PartnersCard(user: user),
          ),
        ),
      );

      // Verify fallback to "Unknown Player"
      expect(find.text('Unknown Player'), findsOneWidget);

      // Verify stats are still displayed
      expect(find.text('71.4% Win Rate'), findsOneWidget);
    });

    testWidgets('shows empty state when no teammates have 5+ games', (tester) async {
      final user = UserModel(
        uid: 'user-123',
        email: 'test@example.com',
        displayName: 'Test User',
        isEmailVerified: true,
        isAnonymous: false,
        teammateStats: {
          'teammate-111': {
            'teammateName': 'Alice Smith',
            'gamesPlayed': 3, // Below 5 game threshold
            'gamesWon': 2,
            'gamesLost': 1,
            'pointsScored': 30,
            'pointsAllowed': 20,
            'eloChange': 10.0,
          },
        },
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
            body: PartnersCard(user: user),
          ),
        ),
      );

      // Verify empty state is shown
      expect(find.text('No partner data yet'), findsOneWidget);
      expect(find.text('Play 5+ games with a teammate'), findsOneWidget);

      // Verify teammate name is NOT shown (below threshold)
      expect(find.text('Alice Smith'), findsNothing);
    });

    testWidgets('selects teammate with highest win rate', (tester) async {
      final user = UserModel(
        uid: 'user-123',
        email: 'test@example.com',
        displayName: 'Test User',
        isEmailVerified: true,
        isAnonymous: false,
        teammateStats: {
          'teammate-low': {
            'teammateName': 'Bob Jones',
            'gamesPlayed': 10,
            'gamesWon': 6, // 60% win rate
            'gamesLost': 4,
            'pointsScored': 80,
            'pointsAllowed': 60,
            'eloChange': 10.0,
          },
          'teammate-high': {
            'teammateName': 'Sarah Lee',
            'gamesPlayed': 8,
            'gamesWon': 7, // 87.5% win rate (higher)
            'gamesLost': 1,
            'pointsScored': 90,
            'pointsAllowed': 30,
            'eloChange': 20.0,
          },
        },
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
            body: PartnersCard(user: user),
          ),
        ),
      );

      // Verify the teammate with highest win rate is shown
      expect(find.text('Sarah Lee'), findsOneWidget);
      expect(find.text('87.5% Win Rate'), findsOneWidget);

      // Verify lower win rate teammate is NOT shown
      expect(find.text('Bob Jones'), findsNothing);
      expect(find.text('60.0% Win Rate'), findsNothing);
    });

    testWidgets('handles long teammate names with ellipsis', (tester) async {
      final user = UserModel(
        uid: 'user-123',
        email: 'test@example.com',
        displayName: 'Test User',
        isEmailVerified: true,
        isAnonymous: false,
        teammateStats: {
          'teammate-long': {
            'teammateName': 'Alexander Maximilian Constantine Rodriguez',
            'gamesPlayed': 10,
            'gamesWon': 7,
            'gamesLost': 3,
            'pointsScored': 90,
            'pointsAllowed': 60,
            'eloChange': 15.0,
          },
        },
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
            body: SizedBox(
              width: 400, // Constrained width to test ellipsis
              child: PartnersCard(user: user),
            ),
          ),
        ),
      );

      // Verify text widget exists (may be truncated with ellipsis)
      expect(find.textContaining('Alexander'), findsOneWidget);

      // Verify the Text widget has overflow: TextOverflow.ellipsis
      final textWidget = tester.widget<Text>(find.textContaining('Alexander'));
      expect(textWidget.overflow, TextOverflow.ellipsis);
    });
  });
}
