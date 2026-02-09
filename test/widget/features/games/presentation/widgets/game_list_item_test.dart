import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:play_with_me/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:play_with_me/core/data/models/game_model.dart';
import 'package:play_with_me/core/theme/app_colors.dart';
import 'package:play_with_me/features/games/presentation/widgets/game_list_item.dart';
import 'package:play_with_me/features/games/presentation/widgets/game_result_badge.dart';
import 'package:play_with_me/features/games/presentation/widgets/set_scores_display.dart';

// Helper to create a basic valid game
GameModel _createGame({
  GameStatus status = GameStatus.scheduled,
  String? userId,
  bool isFull = false,
  bool allowWaitlist = true,
  GameResult? result,
}) {
  return GameModel(
    id: 'game-1',
    title: 'Test Game',
    groupId: 'group-1',
    createdBy: 'creator-1',
    createdAt: DateTime.now(),
    scheduledAt: DateTime.now().add(const Duration(days: 1)),
    location: const GameLocation(name: 'Court 1'),
    status: status,
    maxPlayers: 4,
    minPlayers: 2,
    playerIds: userId != null ? [userId] : [],
    waitlistIds: [],
    allowWaitlist: allowWaitlist,
    // If we want to simulate a full game without adding playerIds manually to fill it,
    // we can't easily override isFull because it's a getter.
    // We must rely on playerIds length.
    // So if isFull is true, we add dummy players.
    // But GameModel.isFull checks playerIds.length >= maxPlayers.
    // So we should construct it with enough players if isFull is needed.
    result: result,
  );
}

void main() {
  group('GameListItem', () {
    testWidgets('displays game title and location', (tester) async {
      final game = _createGame();
      await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],          home: Scaffold(
            body: GameListItem(
              game: game,
              userId: 'user-1',
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('Test Game'), findsOneWidget);
      expect(find.text('Court 1'), findsOneWidget);
    });

    testWidgets('displays scheduled status color', (tester) async {
      final game = _createGame(status: GameStatus.scheduled);
      await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],          home: Scaffold(
            body: GameListItem(
              game: game,
              userId: 'user-1',
              onTap: () {},
            ),
          ),
        ),
      );

      final icon = tester.widget<Icon>(find.byIcon(Icons.calendar_today));
      expect(icon.color, AppColors.secondary);
    });

    testWidgets('displays in progress status color', (tester) async {
      final game = _createGame(status: GameStatus.inProgress);
      await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],          home: Scaffold(
            body: GameListItem(
              game: game,
              userId: 'user-1',
              onTap: () {},
            ),
          ),
        ),
      );

      final icon = tester.widget<Icon>(find.byIcon(Icons.calendar_today));
      expect(icon.color, AppColors.secondary);
    });

    testWidgets('displays cancelled status styling (grey + strikethrough)', (tester) async {
      final game = _createGame(status: GameStatus.cancelled);
      await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],          home: Scaffold(
            body: GameListItem(
              game: game,
              userId: 'user-1',
              onTap: () {},
            ),
          ),
        ),
      );

      final icon = tester.widget<Icon>(find.byIcon(Icons.calendar_today));
      expect(icon.color, Colors.grey);

      final title = tester.widget<Text>(find.text('Test Game'));
      expect(title.style?.decoration, TextDecoration.lineThrough);
    });

    testWidgets('displays result badge and scores when completed with result', (tester) async {
      final result = const GameResult(
        games: [
          IndividualGame(
            gameNumber: 1,
            winner: 'teamA',
            sets: [SetScore(teamAPoints: 21, teamBPoints: 19, setNumber: 1)],
          )
        ],
        overallWinner: 'teamA',
      );
      final game = _createGame(
        status: GameStatus.completed,
        result: result,
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
            body: GameListItem(
              game: game,
              userId: 'user-1',
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.byType(GameResultBadge), findsOneWidget);
      expect(find.byType(SetScoresDisplay), findsOneWidget);
      expect(find.text('21-19'), findsOneWidget);
    });

    testWidgets('displays verification status with theme badge', (tester) async {
      final game = _createGame(status: GameStatus.verification);
      await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],          home: Scaffold(
            body: GameListItem(
              game: game,
              userId: 'user-1',
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('Pending Verification'), findsOneWidget);
      final icon = tester.widget<Icon>(find.byIcon(Icons.pending_actions));
      expect(icon.color, AppColors.secondary);
    });

    testWidgets('applies background tint for verification status', (tester) async {
      final game = _createGame(status: GameStatus.verification);
      await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],          home: Scaffold(
            body: GameListItem(
              game: game,
              userId: 'user-1',
              onTap: () {},
            ),
          ),
        ),
      );

      final card = tester.widget<Card>(find.byType(Card));
      expect(card.color, AppColors.primary.withValues(alpha: 0.1));
    });

    testWidgets('displays RSVP badge when not completed/cancelled', (tester) async {
      final game = _createGame(status: GameStatus.scheduled, userId: 'user-1');
      await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],          home: Scaffold(
            body: GameListItem(
              game: game,
              userId: 'user-1',
              onTap: () {},
            ),
          ),
        ),
      );

      // Assuming user-1 is in the game from _createGame default
      expect(find.text("JOINED"), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      bool tapped = false;
      final game = _createGame();
      await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],          home: Scaffold(
            body: GameListItem(
              game: game,
              userId: 'user-1',
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(GameListItem));
      expect(tapped, isTrue);
    });
  });
}
