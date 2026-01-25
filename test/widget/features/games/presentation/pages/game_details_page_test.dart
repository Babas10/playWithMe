// Widget tests for GameDetailsPage verifying UI behavior with mocked dependencies.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:play_with_me/core/data/models/game_model.dart';
import 'package:play_with_me/core/data/models/user_model.dart';
import 'package:play_with_me/features/auth/domain/entities/user_entity.dart';
import 'package:play_with_me/features/auth/presentation/bloc/authentication/authentication_bloc.dart';
import 'package:play_with_me/features/auth/presentation/bloc/authentication/authentication_state.dart';
import 'package:play_with_me/features/games/presentation/bloc/game_details/game_details_bloc.dart';
import 'package:play_with_me/features/games/presentation/bloc/game_details/game_details_event.dart';
import 'package:play_with_me/features/games/presentation/pages/game_details_page.dart';
import 'package:play_with_me/l10n/app_localizations.dart';

import '../../../../../unit/core/data/repositories/mock_game_repository.dart';
import '../../../../../unit/core/data/repositories/mock_user_repository.dart';

// Mock classes
class MockAuthenticationBloc extends Mock implements AuthenticationBloc {}

void main() {
  late MockGameRepository mockGameRepository;
  late MockUserRepository mockUserRepository;
  late MockAuthenticationBloc mockAuthBloc;
  late GameDetailsBloc gameDetailsBloc;

  const testUserId = 'test-uid-123';
  const testGameId = 'test-game-123';

  setUp(() {
    mockGameRepository = MockGameRepository();
    mockUserRepository = MockUserRepository();
    mockAuthBloc = MockAuthenticationBloc();

    // Add test users to mock repository
    mockUserRepository.addUser(TestUserData.testUser);
    mockUserRepository.addUser(TestUserData.anotherUser);
    // Add waitlist user for fullGame test
    mockUserRepository.addUser(UserModel(
      uid: 'another-uid-101',
      email: 'waitlist@example.com',
      displayName: 'Waitlist User',
      isEmailVerified: true,
      createdAt: DateTime.now(),
      lastSignInAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isAnonymous: false,
    ));

    when(() => mockAuthBloc.state).thenReturn(
      AuthenticationAuthenticated(
        UserEntity(
          uid: testUserId,
          email: 'test@example.com',
          isEmailVerified: true,
          createdAt: DateTime(2024, 1, 1),
          lastSignInAt: DateTime(2024, 1, 1),
          isAnonymous: false,
        ),
      ),
    );
    when(() => mockAuthBloc.stream).thenAnswer((_) => const Stream.empty());

    gameDetailsBloc = GameDetailsBloc(
      gameRepository: mockGameRepository,
      userRepository: mockUserRepository,
    );
  });

  tearDown(() {
    gameDetailsBloc.close();
    mockGameRepository.dispose();
    mockUserRepository.dispose();
  });

  Widget createApp({required String gameId}) {
    return MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],
      home: MultiBlocProvider(
        providers: [
          BlocProvider<AuthenticationBloc>.value(value: mockAuthBloc),
        ],
        child: GameDetailsPage(
          gameId: gameId,
          gameRepository: mockGameRepository,
          userRepository: mockUserRepository,
        ),
      ),
    );
  }

  group('GameDetailsPage Widget Tests', () {
    testWidgets('displays loading indicator initially', (tester) async {
      // Skip: Synchronous mock streams emit too fast to catch transient loading state
      // This behavior is covered by integration tests with real Firebase timing
      // See: https://github.com/Babas10/playWithMe/issues/442
    }, skip: true);

    testWidgets('displays game details when loaded', (tester) async {
      mockGameRepository.addGame(TestGameData.testGame);

      await tester.pumpWidget(createApp(gameId: testGameId));
      await tester.runAsync(() async {
        await Future.delayed(const Duration(milliseconds: 100));
      });
      await tester.pumpAndSettle();

      expect(find.text('Beach Volleyball Test Game'), findsOneWidget);
      expect(find.text('A test game for unit testing'), findsOneWidget);
      expect(find.text('Test Beach'), findsOneWidget);
      expect(find.text('123 Test Beach St'), findsOneWidget);
    });

    testWidgets('displays player count correctly', (tester) async {
      mockGameRepository.addGame(TestGameData.testGame);

      await tester.pumpWidget(createApp(gameId: testGameId));
      await tester.pumpAndSettle(); // Wait for all frames

      // Test game has 2 players out of 4 max (min: 2)
      // Player count may appear in multiple places (card header, details, etc.)
      expect(find.textContaining('2/4'), findsWidgets);
    });

    testWidgets('displays player list', (tester) async {
      mockGameRepository.addGame(TestGameData.testGame);

      await tester.pumpWidget(createApp(gameId: testGameId));
      await tester.runAsync(() async {
        await Future.delayed(const Duration(milliseconds: 100));
      });
      await tester.pumpAndSettle();

      expect(find.text('Confirmed Players'), findsOneWidget);
      expect(find.text('Test User'), findsOneWidget);
      expect(find.text('Another User'), findsOneWidget);
      expect(find.text('Organizer'), findsOneWidget);
    });

    testWidgets('displays "I\'m In" button when user is not playing',
        (tester) async {
      // Create a game where test user is NOT a player
      final gameWithoutUser = TestGameData.testGame.copyWith(
        playerIds: ['other-user-1', 'other-user-2'],
      );
      mockGameRepository.addGame(gameWithoutUser);

      await tester.pumpWidget(createApp(gameId: testGameId));
      await tester.runAsync(() async {
        await Future.delayed(const Duration(milliseconds: 100));
      });
      await tester.pumpAndSettle();

      expect(find.text('I\'m In'), findsOneWidget);
      expect(find.byIcon(Icons.add_circle_outline), findsOneWidget);
    });

    testWidgets('displays "I\'m Out" button when user is playing',
        (tester) async {
      mockGameRepository.addGame(TestGameData.testGame);

      await tester.pumpWidget(createApp(gameId: testGameId));
      await tester.runAsync(() async {
        await Future.delayed(const Duration(milliseconds: 100));
      });
      await tester.pumpAndSettle();

      expect(find.text('I\'m Out'), findsOneWidget);
      expect(find.byIcon(Icons.remove_circle_outline), findsOneWidget);
    });

    testWidgets('displays "Join Waitlist" button when game is full',
        (tester) async {
      // Create a full game where the test user is NOT a player
      final fullGameWithoutTestUser = TestGameData.fullGame.copyWith(
        playerIds: ['other-user-1', 'other-user-2'],
      );
      mockGameRepository.addGame(fullGameWithoutTestUser);

      await tester.pumpWidget(createApp(gameId: 'full-game-101'));
      await tester.pumpAndSettle(); // Wait for all frames

      // Full game should show Join Waitlist option
      expect(find.text('Join Waitlist'), findsOneWidget);
    });

    testWidgets('shows waitlist section when there are waitlisted players',
        (tester) async {
      mockGameRepository.addGame(TestGameData.fullGame);

      await tester.pumpWidget(createApp(gameId: 'full-game-101'));
      await tester.pumpAndSettle(); // Wait for all frames

      expect(find.textContaining('Waitlist'), findsWidgets);
      expect(find.text('Waitlist User'), findsOneWidget);
    });

    testWidgets('tapping "I\'m In" button triggers join event', (tester) async {
      final gameWithoutUser = TestGameData.testGame.copyWith(
        playerIds: ['other-user-1'],
      );
      mockGameRepository.addGame(gameWithoutUser);

      await tester.pumpWidget(createApp(gameId: testGameId));
      await tester.runAsync(() async {
        await Future.delayed(const Duration(milliseconds: 100));
      });
      await tester.pumpAndSettle();

      final button = find.text('I\'m In');
      expect(button, findsOneWidget);

      await tester.tap(button);
      await tester.runAsync(() async {
        await Future.delayed(const Duration(milliseconds: 100));
      });
      await tester.pumpAndSettle();

      // Verify user was added
      final updatedGame = await mockGameRepository.getGameById(testGameId);
      expect(updatedGame!.playerIds.contains(testUserId), true);
    });

    testWidgets('tapping "I\'m Out" button triggers leave event',
        (tester) async {
      mockGameRepository.addGame(TestGameData.testGame);

      await tester.pumpWidget(createApp(gameId: testGameId));
      await tester.runAsync(() async {
        await Future.delayed(const Duration(milliseconds: 100));
      });
      await tester.pumpAndSettle();

      final button = find.text('I\'m Out');
      expect(button, findsOneWidget);

      await tester.tap(button);
      await tester.runAsync(() async {
        await Future.delayed(const Duration(milliseconds: 100));
      });
      await tester.pumpAndSettle();

      // Verify user was removed
      final updatedGame = await mockGameRepository.getGameById(testGameId);
      expect(updatedGame!.playerIds.contains(testUserId), false);
    });

    testWidgets('displays empty state when no players', (tester) async {
      final gameWithNoPlayers = TestGameData.testGame.copyWith(
        playerIds: [],
      );
      mockGameRepository.addGame(gameWithNoPlayers);

      await tester.pumpWidget(createApp(gameId: testGameId));
      await tester.runAsync(() async {
        await Future.delayed(const Duration(milliseconds: 100));
      });
      await tester.pumpAndSettle();

      expect(find.text('No players yet. Be the first to join!'), findsOneWidget);
    });

    testWidgets('displays error state when game not found', (tester) async {
      await tester.pumpWidget(createApp(gameId: 'non-existent-game'));
      await tester.runAsync(() async {
        await Future.delayed(const Duration(milliseconds: 100));
      });
      await tester.pumpAndSettle();

      expect(find.text('Game Not Found'), findsOneWidget);
      expect(find.byIcon(Icons.search_off), findsOneWidget);
      expect(find.text('Go Back'), findsOneWidget);
    });

    testWidgets('back button navigates away from page', (tester) async {
      await tester.pumpWidget(createApp(gameId: 'non-existent-game'));
      await tester.runAsync(() async {
        await Future.delayed(const Duration(milliseconds: 100));
      });
      await tester.pumpAndSettle();

      final backButton = find.text('Go Back');
      expect(backButton, findsOneWidget);

      await tester.tap(backButton);
      await tester.pumpAndSettle();

      // Verify navigation occurred (page should be popped)
      expect(find.text('Game Not Found'), findsNothing);
    });

    testWidgets('displays loading indicator during RSVP operation',
        (tester) async {
      // Skip: Synchronous mock repository completes operations too fast
      // to catch the transient OperationInProgress state with loading indicator
      // This behavior is covered by integration tests with real Firebase timing
      // See: https://github.com/Babas10/playWithMe/issues/442
    }, skip: true);

    testWidgets('real-time updates: player list updates when someone joins',
        (tester) async {
      final gameWithoutUser = TestGameData.testGame.copyWith(
        playerIds: ['other-user-1'],
      );
      mockGameRepository.addGame(gameWithoutUser);

      await tester.pumpWidget(createApp(gameId: testGameId));
      await tester.runAsync(() async {
        await Future.delayed(const Duration(milliseconds: 200));
      });
      await tester.pumpAndSettle();

      // Initial state: 1 player
      expect(find.text('1/4'), findsOneWidget);

      // Simulate another player joining
      await tester.runAsync(() async {
        final updatedGame = gameWithoutUser.copyWith(
          playerIds: ['other-user-1', 'new-user-2'],
        );
        mockGameRepository.addGame(updatedGame);
        await Future.delayed(const Duration(milliseconds: 500));
      });
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pumpAndSettle();

      // Updated state: 2 players
      expect(find.text('2/4'), findsOneWidget);
    });

    testWidgets('displays game notes when available', (tester) async {
      mockGameRepository.addGame(TestGameData.testGame);

      await tester.pumpWidget(createApp(gameId: testGameId));
      await tester.runAsync(() async {
        await Future.delayed(const Duration(milliseconds: 100));
      });
      await tester.pumpAndSettle();

      expect(find.text('Notes'), findsOneWidget);
      expect(find.text('Bring sunscreen!'), findsOneWidget);
    });

    testWidgets('hides RSVP buttons when user is not authenticated',
        (tester) async {
      when(() => mockAuthBloc.state).thenReturn(
        const AuthenticationUnauthenticated(),
      );

      mockGameRepository.addGame(TestGameData.testGame);

      await tester.pumpWidget(createApp(gameId: testGameId));
      await tester.runAsync(() async {
        await Future.delayed(const Duration(milliseconds: 100));
      });
      await tester.pumpAndSettle();

      // RSVP buttons should not be visible
      expect(find.text('I\'m In'), findsNothing);
      expect(find.text('I\'m Out'), findsNothing);
    });

    testWidgets('displays past game correctly', (tester) async {
      mockGameRepository.addGame(TestGameData.pastGame);

      await tester.pumpWidget(createApp(gameId: 'past-game-789'));
      await tester.runAsync(() async {
        await Future.delayed(const Duration(milliseconds: 200));
      });
      await tester.pumpAndSettle();

      // Game should be loaded and show past game info
      expect(find.text('Past Test Game'), findsOneWidget);

      // Since the test user IS playing the past game (test-uid-123 in playerIds),
      // previously the "I'm Out" button showed. Now with Verification flow,
      // RSVP buttons are hidden for completed games.
      expect(find.text('I\'m Out'), findsNothing);
      
      // With Democratized Entry (Story 14.14), participants can enter results
      // for past/completed games if no result exists yet.
      expect(find.text('Enter Results'), findsOneWidget);
    });

    testWidgets('scrolls to reveal all game details', (tester) async {
      mockGameRepository.addGame(TestGameData.testGame);

      await tester.pumpWidget(createApp(gameId: testGameId));
      await tester.runAsync(() async {
        await Future.delayed(const Duration(milliseconds: 100));
      });
      await tester.pumpAndSettle();

      // Verify initial visible content
      expect(find.text('Beach Volleyball Test Game'), findsOneWidget);

      // Scroll down
      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, -300),
      );
      await tester.pumpAndSettle();

      // All content should still be accessible
      expect(find.text('Confirmed Players'), findsOneWidget);
    });
  });
}
