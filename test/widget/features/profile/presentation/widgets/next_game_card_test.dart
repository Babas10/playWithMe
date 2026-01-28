// Widget tests for NextGameCard
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:play_with_me/core/data/models/game_model.dart';
import 'package:play_with_me/features/profile/presentation/widgets/next_game_card.dart';
import 'package:play_with_me/l10n/app_localizations.dart';

void main() {
  group('NextGameCard Widget Tests', () {
    const testUserId = 'test-user-123';

    // Helper function to pump widget with localization
    Future<void> pumpNextGameCard(
      WidgetTester tester, {
      GameModel? game,
      VoidCallback? onTap,
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
            body: NextGameCard(
              game: game,
              userId: testUserId,
              onTap: onTap,
            ),
          ),
        ),
      );
    }

    testWidgets('displays section header "Next Game"', (tester) async {
      // Arrange & Act
      await pumpNextGameCard(tester);

      // Assert
      expect(find.text('Next Game'), findsOneWidget);
    });

    testWidgets('displays empty state when no game provided', (tester) async {
      // Arrange & Act
      await pumpNextGameCard(tester, game: null);

      // Assert
      expect(find.text('No games organized yet'), findsOneWidget);
      expect(find.byIcon(Icons.sports_volleyball), findsOneWidget);
    });

    testWidgets('displays game card when game provided', (tester) async {
      // Arrange
      final game = GameModel(
        id: 'game-1',
        title: 'Beach Volleyball Match',
        groupId: 'group-1',
        createdBy: 'creator-1',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        scheduledAt: DateTime.now().add(const Duration(days: 1)),
        location: const GameLocation(name: 'Venice Beach'),
        status: GameStatus.scheduled,
        playerIds: [testUserId],
        maxPlayers: 8,
        minPlayers: 4,
      );

      // Act
      await pumpNextGameCard(tester, game: game);

      // Assert
      expect(find.text('Beach Volleyball Match'), findsOneWidget);
      expect(find.text('Venice Beach'), findsOneWidget);
      // Should not show empty state
      expect(find.text('No games organized yet'), findsNothing);
    });

    testWidgets('shows user joined badge when user is in playerIds', (tester) async {
      // Arrange
      final game = GameModel(
        id: 'game-1',
        title: 'Test Game',
        groupId: 'group-1',
        createdBy: 'creator-1',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        scheduledAt: DateTime.now().add(const Duration(days: 1)),
        location: const GameLocation(name: 'Court 1'),
        status: GameStatus.scheduled,
        playerIds: [testUserId, 'other-user'],
        maxPlayers: 8,
        minPlayers: 4,
      );

      // Act
      await pumpNextGameCard(tester, game: game);

      // Assert
      // GameListItem shows "You're In" badge when user is a player
      expect(find.text("You're In"), findsOneWidget);
    });

    testWidgets('calls onTap callback when game card is tapped', (tester) async {
      // Arrange
      bool tapped = false;
      final game = GameModel(
        id: 'game-1',
        title: 'Test Game',
        groupId: 'group-1',
        createdBy: 'creator-1',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        scheduledAt: DateTime.now().add(const Duration(days: 1)),
        location: const GameLocation(name: 'Court 1'),
        status: GameStatus.scheduled,
        playerIds: [testUserId],
        maxPlayers: 8,
        minPlayers: 4,
      );

      await pumpNextGameCard(
        tester,
        game: game,
        onTap: () {
          tapped = true;
        },
      );

      // Act - Find the InkWell (from GameListItem) and tap it
      final inkWell = find.byType(InkWell).first;
      await tester.tap(inkWell);
      await tester.pumpAndSettle();

      // Assert
      expect(tapped, true);
    });

    testWidgets('does not call onTap when empty state is shown', (tester) async {
      // Arrange
      bool tapped = false;

      await pumpNextGameCard(
        tester,
        game: null,
        onTap: () {
          tapped = true;
        },
      );

      // Act - Try to tap the empty state card
      final card = find.byType(Card).first;
      await tester.tap(card);
      await tester.pumpAndSettle();

      // Assert - Should not trigger callback
      expect(tapped, false);
    });

    testWidgets('displays player count progress', (tester) async {
      // Arrange
      final game = GameModel(
        id: 'game-1',
        title: 'Test Game',
        groupId: 'group-1',
        createdBy: 'creator-1',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        scheduledAt: DateTime.now().add(const Duration(days: 1)),
        location: const GameLocation(name: 'Court 1'),
        status: GameStatus.scheduled,
        playerIds: [testUserId, 'user-2', 'user-3'],
        maxPlayers: 8,
        minPlayers: 4,
      );

      // Act
      await pumpNextGameCard(tester, game: game);

      // Assert
      expect(find.text('3/8 players'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('displays correct date formatting for today', (tester) async {
      // Arrange
      final now = DateTime.now();
      final todayGame = GameModel(
        id: 'game-1',
        title: 'Volleyball Match',
        groupId: 'group-1',
        createdBy: 'creator-1',
        createdAt: now.subtract(const Duration(hours: 1)),
        scheduledAt: DateTime(now.year, now.month, now.day, 18, 0),
        location: const GameLocation(name: 'Court 1'),
        status: GameStatus.scheduled,
        playerIds: [testUserId],
        maxPlayers: 8,
        minPlayers: 4,
      );

      // Act
      await pumpNextGameCard(tester, game: todayGame);

      // Assert - Look for "Today •" to match the date/time string specifically
      expect(find.textContaining('Today •'), findsOneWidget);
    });

    testWidgets('displays correct date formatting for tomorrow', (tester) async {
      // Arrange
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      final tomorrowGame = GameModel(
        id: 'game-1',
        title: 'Volleyball Match',
        groupId: 'group-1',
        createdBy: 'creator-1',
        createdAt: DateTime.now(),
        scheduledAt: DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 18, 0),
        location: const GameLocation(name: 'Court 1'),
        status: GameStatus.scheduled,
        playerIds: [testUserId],
        maxPlayers: 8,
        minPlayers: 4,
      );

      // Act
      await pumpNextGameCard(tester, game: tomorrowGame);

      // Assert - Look for "Tomorrow •" to match the date/time string specifically
      expect(find.textContaining('Tomorrow •'), findsOneWidget);
    });

    testWidgets('widget renders without error with null onTap', (tester) async {
      // Arrange
      final game = GameModel(
        id: 'game-1',
        title: 'Test Game',
        groupId: 'group-1',
        createdBy: 'creator-1',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        scheduledAt: DateTime.now().add(const Duration(days: 1)),
        location: const GameLocation(name: 'Court 1'),
        status: GameStatus.scheduled,
        playerIds: [testUserId],
        maxPlayers: 8,
        minPlayers: 4,
      );

      // Act & Assert - Should not throw
      await pumpNextGameCard(tester, game: game, onTap: null);
      expect(find.byType(NextGameCard), findsOneWidget);
    });

    testWidgets('reuses GameListItem component', (tester) async {
      // Arrange
      final game = GameModel(
        id: 'game-1',
        title: 'Test Game',
        groupId: 'group-1',
        createdBy: 'creator-1',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        scheduledAt: DateTime.now().add(const Duration(days: 1)),
        location: const GameLocation(name: 'Court 1'),
        status: GameStatus.scheduled,
        playerIds: [testUserId],
        maxPlayers: 8,
        minPlayers: 4,
      );

      // Act
      await pumpNextGameCard(tester, game: game);

      // Assert - GameListItem should be used
      expect(find.byType(InkWell), findsWidgets); // GameListItem uses InkWell
      expect(find.byType(Card), findsWidgets); // GameListItem uses Card
    });
  });
}
