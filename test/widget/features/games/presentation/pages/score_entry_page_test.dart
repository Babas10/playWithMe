// Widget tests for ScoreEntryPage verifying UI and interaction.

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:play_with_me/l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:play_with_me/core/data/models/game_model.dart';
import 'package:play_with_me/features/auth/domain/entities/user_entity.dart';
import 'package:play_with_me/features/auth/presentation/bloc/authentication/authentication_bloc.dart';
import 'package:play_with_me/features/auth/presentation/bloc/authentication/authentication_state.dart';
import 'package:play_with_me/features/games/presentation/bloc/score_entry/score_entry_bloc.dart';
import 'package:play_with_me/features/games/presentation/bloc/score_entry/score_entry_event.dart';
import 'package:play_with_me/features/games/presentation/bloc/score_entry/score_entry_state.dart';
import 'package:play_with_me/features/games/presentation/pages/score_entry_page.dart';
import 'package:play_with_me/core/domain/repositories/game_repository.dart';
import 'package:play_with_me/core/services/service_locator.dart';

// Mock classes
class MockGameRepository extends Mock implements GameRepository {}

class MockAuthenticationBloc extends Mock implements AuthenticationBloc {}

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

class FakeScoreEntryState extends Fake implements ScoreEntryState {}

class FakeScoreEntryEvent extends Fake implements ScoreEntryEvent {}

class FakeGameTeams extends Fake implements GameTeams {}

class FakeGameResult extends Fake implements GameResult {}

class FakeRoute extends Fake implements Route<dynamic> {}

void main() {
  late MockGameRepository mockGameRepository;
  late MockAuthenticationBloc mockAuthBloc;

  const testUserId = 'test-uid-123';
  const testGameId = 'test-game-123';
  const testUser = UserEntity(
    uid: testUserId,
    email: 'test@example.com',
    displayName: 'Test User',
    isEmailVerified: true,
    isAnonymous: false,
  );

  final testGame = GameModel(
    id: testGameId,
    title: 'Test Game',
    groupId: 'group-1',
    createdBy: testUserId,
    createdAt: DateTime.now(),
    scheduledAt: DateTime.now().add(const Duration(hours: 1)),
    location: const GameLocation(name: 'Test Court'),
    status: GameStatus.completed,
    playerIds: ['user-1', 'user-2', 'user-3', 'user-4'],
    teams: const GameTeams(
      teamAPlayerIds: ['user-1', 'user-3'],
      teamBPlayerIds: ['user-2', 'user-4'],
    ),
  );

  setUpAll(() {
    registerFallbackValue(FakeScoreEntryState());
    registerFallbackValue(FakeScoreEntryEvent());
    registerFallbackValue(FakeGameTeams());
    registerFallbackValue(FakeGameResult());
    registerFallbackValue(FakeRoute());
  });

  setUp(() {
    mockGameRepository = MockGameRepository();
    mockAuthBloc = MockAuthenticationBloc();
    sl.registerSingleton<AuthenticationBloc>(mockAuthBloc);
    sl.registerSingleton<GameRepository>(mockGameRepository);

    when(() => mockGameRepository.getGameById(any()))
        .thenAnswer((_) async => testGame);
    when(() => mockGameRepository.saveGameResult(
          gameId: any(named: 'gameId'),
          userId: any(named: 'userId'),
          teams: any(named: 'teams'),
          result: any(named: 'result'),
        )).thenAnswer((_) async {});
    when(() => mockAuthBloc.state).thenReturn(const AuthenticationAuthenticated(testUser));
    when(() => mockAuthBloc.stream).thenAnswer((_) => Stream.value(const AuthenticationAuthenticated(testUser)));
  });

  tearDown(() {
    sl.reset();
  });

  Widget createApp({required String gameId}) {
    return BlocProvider<AuthenticationBloc>.value(
      value: mockAuthBloc,
      child: MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],
        home: ScoreEntryPage(
          gameId: gameId,
        ),
      ),
    );
  }

  group('ScoreEntryPage Tied Games Widget Tests', () {
    testWidgets('can save scores when teams are tied', (tester) async {
      final mockObserver = MockNavigatorObserver();

      await tester.pumpWidget(BlocProvider<AuthenticationBloc>.value(
        value: mockAuthBloc,
        child: MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en')],
          home: ScoreEntryPage(
            gameId: testGameId,
          ),
          navigatorObservers: [mockObserver],
        ),
      ));
      await tester.pumpAndSettle();

      // Select 2 games
      await tester.tap(find.text('2'));
      await tester.pumpAndSettle();

      // Enter scores - Game 1: Team A wins
      await tester.enterText(find.byKey(const Key('team_a_score_0_0')), '21');
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('team_b_score_0_0')), '19');
      await tester.pumpAndSettle();

      // Enter scores - Game 2: Team B wins (tie!)
      await tester.enterText(find.byKey(const Key('team_a_score_1_0')), '19');
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('team_b_score_1_0')), '21');
      await tester.pumpAndSettle();

      // Verify the "Result: Tie" text is shown
      expect(find.text('Result: Tie'), findsOneWidget);

      // Verify the Save Scores button is enabled
      final saveButtonFinder = find.widgetWithText(ElevatedButton, 'Save Scores');
      expect(saveButtonFinder, findsOneWidget);

      // Tap save
      await tester.ensureVisible(saveButtonFinder);
      await tester.tap(saveButtonFinder);
      await tester.pumpAndSettle();

      verify(() => mockObserver.didPop(any(), any())).called(1);
    });
  });

  group('ScoreEntryPage Widget Tests', () {
    testWidgets('displays game count selector when loaded', (tester) async {
      await tester.pumpWidget(createApp(gameId: testGameId));
      await tester.pumpAndSettle();

      expect(find.text('How many games did you play?'), findsOneWidget);
    });

    testWidgets('can select game count', (tester) async {
      await tester.pumpWidget(createApp(gameId: testGameId));
      await tester.pumpAndSettle();

      await tester.tap(find.text('1'));
      await tester.pumpAndSettle();

      expect(find.text('Game 1'), findsOneWidget);
    });

    testWidgets('can save scores when all games are complete', (tester) async {
      final mockObserver = MockNavigatorObserver();

      await tester.pumpWidget(BlocProvider<AuthenticationBloc>.value(
        value: mockAuthBloc,
        child: MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],
          home: ScoreEntryPage(
            gameId: testGameId,
          ),
          navigatorObservers: [mockObserver],
        ),
      ));
      await tester.pumpAndSettle();

      // Select 1 game
      await tester.tap(find.text('1'));
      await tester.pumpAndSettle();

      // Enter scores
      await tester.enterText(find.byKey(const Key('team_a_score_0_0')), '21');
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('team_b_score_0_0')), '19');
      await tester.pumpAndSettle();

      // Find the button and tap it
      final saveButtonFinder = find.widgetWithText(ElevatedButton, 'Save Scores');
      expect(saveButtonFinder, findsOneWidget);
      await tester.ensureVisible(saveButtonFinder);
      await tester.tap(saveButtonFinder);
      await tester.pumpAndSettle();

      verify(() => mockObserver.didPop(any(), any())).called(1);
    });
  });
}
