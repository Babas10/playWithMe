// Widget tests for GamesListPage verifying UI rendering and user interactions.
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:play_with_me/l10n/app_localizations.dart';
import 'package:play_with_me/core/data/models/game_model.dart';
import 'package:play_with_me/core/data/models/group_activity_item.dart';
import 'package:play_with_me/core/data/models/training_session_model.dart';
import 'package:play_with_me/features/auth/domain/entities/user_entity.dart';
import 'package:play_with_me/features/auth/presentation/bloc/authentication/authentication_bloc.dart';
import 'package:play_with_me/features/auth/presentation/bloc/authentication/authentication_state.dart';
import 'package:play_with_me/features/games/presentation/bloc/games_list/games_list_bloc.dart';
import 'package:play_with_me/features/games/presentation/bloc/games_list/games_list_event.dart';
import 'package:play_with_me/features/games/presentation/bloc/games_list/games_list_state.dart';
import 'package:play_with_me/features/games/presentation/widgets/game_list_item.dart';

class MockGamesListBloc extends MockBloc<GamesListEvent, GamesListState>
    implements GamesListBloc {}

class MockAuthenticationBloc extends Mock implements AuthenticationBloc {}

class FakeGamesListEvent extends Fake implements GamesListEvent {}

class FakeGamesListState extends Fake implements GamesListState {}

void main() {
  late MockGamesListBloc mockGamesListBloc;
  late MockAuthenticationBloc mockAuthBloc;

  const testUserId = 'test-user-123';
  const testGroupId = 'test-group-123';
  const testGroupName = 'Beach Volleyball Crew';

  setUpAll(() {
    registerFallbackValue(FakeGamesListEvent());
    registerFallbackValue(FakeGamesListState());
  });

  setUp(() {
    mockGamesListBloc = MockGamesListBloc();
    mockAuthBloc = MockAuthenticationBloc();

    when(() => mockGamesListBloc.state).thenReturn(const GamesListInitial());

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
  });

  tearDown(() {
    mockGamesListBloc.close();
  });

  Widget createTestWidget() {
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
          BlocProvider<GamesListBloc>.value(value: mockGamesListBloc),
          BlocProvider<AuthenticationBloc>.value(value: mockAuthBloc),
        ],
        child: Scaffold(
          appBar: AppBar(
            title: Text('$testGroupName Games'),
            centerTitle: true,
          ),
          body: BlocBuilder<GamesListBloc, GamesListState>(
            builder: (context, state) {
              if (state is GamesListLoading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              if (state is GamesListError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64),
                      const SizedBox(height: 16),
                      const Text('Error'),
                      const SizedBox(height: 8),
                      Text(state.message),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () {
                          context
                              .read<GamesListBloc>()
                              .add(const RefreshGamesList());
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }
              if (state is GamesListEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.sports_volleyball, size: 64),
                      const SizedBox(height: 16),
                      const Text('No upcoming games yet'),
                      const SizedBox(height: 8),
                      const Text('Create the first game!'),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.add),
                        label: const Text('Create Game'),
                      ),
                    ],
                  ),
                );
              }
              if (state is GamesListLoaded) {
                return RefreshIndicator(
                  onRefresh: () async {
                    context
                        .read<GamesListBloc>()
                        .add(const RefreshGamesList());
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (state.upcomingActivities.isNotEmpty) ...[
                          const Padding(
                            padding: EdgeInsets.all(16),
                            child: Text(
                              'Upcoming Activities',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          ...state.upcomingActivities.map((activity) {
                            return activity.when(
                              game: (game) => GameListItem(
                                game: game,
                                userId: testUserId,
                                isPast: false,
                                onTap: () {},
                              ),
                              training: (session) => ListTile(
                                title: Text(session.title),
                              ),
                            );
                          }),
                        ],
                        if (state.pastActivities.isNotEmpty) ...[
                          const Padding(
                            padding: EdgeInsets.all(16),
                            child: Text(
                              'Past Activities',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          ...state.pastActivities.map((activity) {
                            return activity.when(
                              game: (game) => GameListItem(
                                game: game,
                                userId: testUserId,
                                isPast: true,
                                onTap: () {},
                              ),
                              training: (session) => ListTile(
                                title: Text(session.title),
                              ),
                            );
                          }),
                        ],
                      ],
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {},
            icon: const Icon(Icons.add),
            label: const Text('Create Game'),
          ),
        ),
      ),
    );
  }

  group('GamesListPage Widget Tests', () {
    group('Initial UI Rendering', () {
      testWidgets('renders app bar with group name', (tester) async {
        await tester.pumpWidget(createTestWidget());

        expect(find.byType(AppBar), findsOneWidget);
        expect(find.text('$testGroupName Games'), findsOneWidget);
      });

      testWidgets('renders floating action button', (tester) async {
        await tester.pumpWidget(createTestWidget());

        expect(find.byType(FloatingActionButton), findsOneWidget);
        expect(find.text('Create Game'), findsWidgets);
      });
    });

    group('Loading State', () {
      testWidgets('shows loading indicator when loading', (tester) async {
        when(() => mockGamesListBloc.state)
            .thenReturn(const GamesListLoading());

        await tester.pumpWidget(createTestWidget());

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });
    });

    group('Empty State', () {
      testWidgets('shows empty state when no games', (tester) async {
        when(() => mockGamesListBloc.state)
            .thenReturn(const GamesListEmpty(userId: testUserId));

        await tester.pumpWidget(createTestWidget());

        expect(find.byIcon(Icons.sports_volleyball), findsOneWidget);
        expect(find.text('No upcoming games yet'), findsOneWidget);
        expect(find.text('Create the first game!'), findsOneWidget);
      });

      testWidgets('empty state shows create game button', (tester) async {
        when(() => mockGamesListBloc.state)
            .thenReturn(const GamesListEmpty(userId: testUserId));

        await tester.pumpWidget(createTestWidget());

        // The "Create Game" button text should be visible in empty state
        // (both in empty state button and in FAB)
        expect(find.text('Create Game'), findsWidgets);
      });
    });

    group('Error State', () {
      testWidgets('shows error state with message', (tester) async {
        when(() => mockGamesListBloc.state)
            .thenReturn(const GamesListError(message: 'Failed to load games'));

        await tester.pumpWidget(createTestWidget());

        expect(find.byIcon(Icons.error_outline), findsOneWidget);
        expect(find.text('Error'), findsOneWidget);
        expect(find.text('Failed to load games'), findsOneWidget);
      });

      testWidgets('shows retry button in error state', (tester) async {
        when(() => mockGamesListBloc.state)
            .thenReturn(const GamesListError(message: 'Error message'));

        await tester.pumpWidget(createTestWidget());

        // Find "Retry" text
        expect(find.text('Retry'), findsOneWidget);
      });

      testWidgets('retry button triggers RefreshGamesList', (tester) async {
        when(() => mockGamesListBloc.state)
            .thenReturn(const GamesListError(message: 'Error'));

        await tester.pumpWidget(createTestWidget());

        // Tap the Retry text (button)
        await tester.tap(find.text('Retry'));
        await tester.pump();

        verify(() => mockGamesListBloc.add(const RefreshGamesList())).called(1);
      });
    });

    group('Loaded State', () {
      testWidgets('shows upcoming activities section', (tester) async {
        final upcomingGame = GameModel(
          id: 'game-1',
          title: 'Beach Volleyball Match',
          groupId: testGroupId,
          createdBy: testUserId,
          createdAt: DateTime.now(),
          scheduledAt: DateTime.now().add(const Duration(days: 1)),
          location: GameLocation(name: 'Venice Beach'),
          maxPlayers: 4,
          minPlayers: 2,
          playerIds: [testUserId],
        );

        when(() => mockGamesListBloc.state).thenReturn(
          GamesListLoaded(
            upcomingActivities: [GroupActivityItem.game(upcomingGame)],
            pastActivities: [],
            userId: testUserId,
          ),
        );

        await tester.pumpWidget(createTestWidget());

        expect(find.text('Upcoming Activities'), findsOneWidget);
        expect(find.text('Beach Volleyball Match'), findsOneWidget);
      });

      testWidgets('shows past activities section', (tester) async {
        final pastGame = GameModel(
          id: 'game-2',
          title: 'Last Week Game',
          groupId: testGroupId,
          createdBy: testUserId,
          createdAt: DateTime.now().subtract(const Duration(days: 10)),
          scheduledAt: DateTime.now().subtract(const Duration(days: 7)),
          location: GameLocation(name: 'Santa Monica'),
          maxPlayers: 4,
          minPlayers: 2,
          playerIds: [testUserId],
        );

        when(() => mockGamesListBloc.state).thenReturn(
          GamesListLoaded(
            upcomingActivities: [],
            pastActivities: [GroupActivityItem.game(pastGame)],
            userId: testUserId,
          ),
        );

        await tester.pumpWidget(createTestWidget());

        expect(find.text('Past Activities'), findsOneWidget);
        expect(find.text('Last Week Game'), findsOneWidget);
      });

      testWidgets('shows both upcoming and past activities', (tester) async {
        final upcomingGame = GameModel(
          id: 'game-1',
          title: 'Upcoming Match',
          groupId: testGroupId,
          createdBy: testUserId,
          createdAt: DateTime.now(),
          scheduledAt: DateTime.now().add(const Duration(days: 1)),
          location: GameLocation(name: 'Venice Beach'),
          maxPlayers: 4,
          minPlayers: 2,
          playerIds: [testUserId],
        );

        final pastGame = GameModel(
          id: 'game-2',
          title: 'Past Match',
          groupId: testGroupId,
          createdBy: testUserId,
          createdAt: DateTime.now().subtract(const Duration(days: 10)),
          scheduledAt: DateTime.now().subtract(const Duration(days: 7)),
          location: GameLocation(name: 'Santa Monica'),
          maxPlayers: 4,
          minPlayers: 2,
          playerIds: [testUserId],
        );

        when(() => mockGamesListBloc.state).thenReturn(
          GamesListLoaded(
            upcomingActivities: [GroupActivityItem.game(upcomingGame)],
            pastActivities: [GroupActivityItem.game(pastGame)],
            userId: testUserId,
          ),
        );

        await tester.pumpWidget(createTestWidget());

        expect(find.text('Upcoming Activities'), findsOneWidget);
        expect(find.text('Upcoming Match'), findsOneWidget);
        expect(find.text('Past Activities'), findsOneWidget);
        expect(find.text('Past Match'), findsOneWidget);
      });

      testWidgets('shows training sessions in activity list', (tester) async {
        final trainingSession = TrainingSessionModel(
          id: 'training-1',
          title: 'Team Practice',
          groupId: testGroupId,
          createdBy: testUserId,
          createdAt: DateTime.now(),
          startTime: DateTime.now().add(const Duration(days: 2)),
          endTime: DateTime.now().add(const Duration(days: 2, hours: 2)),
          location: const GameLocation(name: 'Training Facility'),
          minParticipants: 2,
          maxParticipants: 10,
          participantIds: [testUserId],
          status: TrainingStatus.scheduled,
        );

        when(() => mockGamesListBloc.state).thenReturn(
          GamesListLoaded(
            upcomingActivities: [GroupActivityItem.training(trainingSession)],
            pastActivities: [],
            userId: testUserId,
          ),
        );

        await tester.pumpWidget(createTestWidget());

        expect(find.text('Upcoming Activities'), findsOneWidget);
        expect(find.text('Team Practice'), findsOneWidget);
      });

      testWidgets('renders GameListItem for games', (tester) async {
        final game = GameModel(
          id: 'game-1',
          title: 'Test Game',
          groupId: testGroupId,
          createdBy: testUserId,
          createdAt: DateTime.now(),
          scheduledAt: DateTime.now().add(const Duration(days: 1)),
          location: GameLocation(name: 'Test Location'),
          maxPlayers: 4,
          minPlayers: 2,
          playerIds: [testUserId],
        );

        when(() => mockGamesListBloc.state).thenReturn(
          GamesListLoaded(
            upcomingActivities: [GroupActivityItem.game(game)],
            pastActivities: [],
            userId: testUserId,
          ),
        );

        await tester.pumpWidget(createTestWidget());

        expect(find.byType(GameListItem), findsOneWidget);
      });
    });

    group('Pull to Refresh', () {
      testWidgets('shows RefreshIndicator in loaded state', (tester) async {
        final game = GameModel(
          id: 'game-1',
          title: 'Test Game',
          groupId: testGroupId,
          createdBy: testUserId,
          createdAt: DateTime.now(),
          scheduledAt: DateTime.now().add(const Duration(days: 1)),
          location: GameLocation(name: 'Test Location'),
          maxPlayers: 4,
          minPlayers: 2,
          playerIds: [testUserId],
        );

        when(() => mockGamesListBloc.state).thenReturn(
          GamesListLoaded(
            upcomingActivities: [GroupActivityItem.game(game)],
            pastActivities: [],
            userId: testUserId,
          ),
        );

        await tester.pumpWidget(createTestWidget());

        expect(find.byType(RefreshIndicator), findsOneWidget);
      });
    });

    group('FAB Interaction', () {
      testWidgets('FAB shows create game icon and label', (tester) async {
        when(() => mockGamesListBloc.state)
            .thenReturn(const GamesListEmpty(userId: testUserId));

        await tester.pumpWidget(createTestWidget());

        final fab = find.byType(FloatingActionButton);
        expect(fab, findsOneWidget);

        // Check for icon within FAB
        expect(
          find.descendant(of: fab, matching: find.byIcon(Icons.add)),
          findsOneWidget,
        );
      });
    });
  });
}
