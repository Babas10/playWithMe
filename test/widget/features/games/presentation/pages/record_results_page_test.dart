// Widget tests for RecordResultsPage verifying UI and interaction.

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:play_with_me/core/data/models/game_model.dart';
import 'package:play_with_me/features/auth/domain/entities/user_entity.dart';
import 'package:play_with_me/features/auth/presentation/bloc/authentication/authentication_bloc.dart';
import 'package:play_with_me/features/auth/presentation/bloc/authentication/authentication_state.dart';
import 'package:play_with_me/features/games/presentation/bloc/record_results/record_results_bloc.dart';
import 'package:play_with_me/features/games/presentation/bloc/record_results/record_results_event.dart';
import 'package:play_with_me/features/games/presentation/bloc/record_results/record_results_state.dart';
import 'package:play_with_me/features/games/presentation/pages/record_results_page.dart';
import 'package:play_with_me/core/services/service_locator.dart';
import 'package:play_with_me/features/games/presentation/pages/score_entry_page.dart';
import 'package:play_with_me/core/domain/repositories/game_repository.dart';
import 'package:play_with_me/core/domain/repositories/user_repository.dart';
import 'package:play_with_me/core/services/service_locator.dart';

// Mock classes
class MockGameRepository extends Mock implements GameRepository {}

class MockUserRepository extends Mock implements UserRepository {}

class MockAuthenticationBloc extends Mock implements AuthenticationBloc {}

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

class FakeRecordResultsState extends Fake implements RecordResultsState {}

class FakeRecordResultsEvent extends Fake implements RecordResultsEvent {}

class FakeGameTeams extends Fake implements GameTeams {}

class FakeRoute extends Fake implements Route<dynamic> {}

void main() {
  late MockGameRepository mockGameRepository;
  late MockUserRepository mockUserRepository;
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
  );

  setUpAll(() {
    registerFallbackValue(FakeRecordResultsState());
    registerFallbackValue(FakeRecordResultsEvent());
    registerFallbackValue(FakeGameTeams());
    registerFallbackValue(FakeRoute());
  });

  setUp(() {
    mockGameRepository = MockGameRepository();
    mockUserRepository = MockUserRepository();
    mockAuthBloc = MockAuthenticationBloc();
    sl.registerSingleton<AuthenticationBloc>(mockAuthBloc);
    sl.registerSingleton<GameRepository>(mockGameRepository);
    sl.registerSingleton<UserRepository>(mockUserRepository);

    when(() => mockGameRepository.getGameById(any()))
        .thenAnswer((_) async => testGame);
    when(() => mockGameRepository.updateGameTeams(any(), any(), any())).thenAnswer((_) async {});
    when(() => mockUserRepository.getUsersByIds(any())).thenAnswer((_) async => []);
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
        home: RecordResultsPage(
          gameId: gameId,
        ),
      ),
    );
  }

  group('RecordResultsPage Widget Tests', () {
    testWidgets('displays players and teams when loaded', (tester) async {
      await tester.pumpWidget(createApp(gameId: testGameId));
      await tester.pumpAndSettle();

      expect(find.text('Assign Players to Teams'), findsOneWidget);
      expect(find.byKey(const Key('team_a_section')), findsOneWidget);
      expect(find.byKey(const Key('team_b_section')), findsOneWidget);
      expect(find.byKey(const Key('unassigned_section')), findsOneWidget);
      expect(find.text('user-1'), findsOneWidget);
      expect(find.text('user-2'), findsOneWidget);
      expect(find.text('user-3'), findsOneWidget);
      expect(find.text('user-4'), findsOneWidget);
    });

    testWidgets('can assign a player to a team', (tester) async {
      await tester.pumpWidget(createApp(gameId: testGameId));
      await tester.pumpAndSettle();

      // Find 'user-1' in unassigned section initially
      final unassignedCard = find.byKey(const Key('unassigned_section'));
      expect(find.descendant(of: unassignedCard, matching: find.text('user-1')), findsOneWidget);

      final buttonFinder = find.byKey(const Key('assign_team_A_button_user-1'));
      await tester.scrollUntilVisible(buttonFinder, 500);
      await tester.tap(buttonFinder);
      await tester.pump();

      // Verify user-1 is now in Team A section
      final teamACard = find.byKey(const Key('team_a_section'));
      expect(find.descendant(of: teamACard, matching: find.text('user-1')), findsOneWidget);
    });

    testWidgets('can save teams when all players are assigned and navigates', (tester) async {
      final mockObserver = MockNavigatorObserver();

      await tester.pumpWidget(BlocProvider<AuthenticationBloc>.value(
        value: mockAuthBloc,
        child: MaterialApp(
          home: RecordResultsPage(
            gameId: testGameId,
          ),
          navigatorObservers: [mockObserver],
        ),
      ));
      await tester.pumpAndSettle();

      // Assign all players
      for (final playerId in ['user-1', 'user-2', 'user-3', 'user-4']) {
        final team = (playerId == 'user-1' || playerId == 'user-3') ? 'A' : 'B';
        final buttonFinder = find.byKey(Key('assign_team_${team}_button_$playerId'));
        await tester.scrollUntilVisible(buttonFinder, 500);
        await tester.tap(buttonFinder);
        await tester.pump();
      }

      final saveButtonFinder = find.widgetWithText(ElevatedButton, 'Save Teams');
      await tester.scrollUntilVisible(saveButtonFinder, 500);
      await tester.tap(saveButtonFinder);
      await tester.pumpAndSettle();

      verify(() => mockObserver.didPush(any(), any())).called(1);
    });
  });
}
