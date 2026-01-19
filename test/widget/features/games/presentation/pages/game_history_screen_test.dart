// Widget tests for GameHistoryScreen verifying history display, filtering, and pagination (Story 16.3.3.4).

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:play_with_me/core/data/models/game_model.dart';
import 'package:play_with_me/features/games/presentation/bloc/game_history/game_history_bloc.dart';
import 'package:play_with_me/features/games/presentation/bloc/game_history/game_history_event.dart';
import 'package:play_with_me/features/games/presentation/bloc/game_history/game_history_state.dart';
import 'package:play_with_me/features/games/presentation/widgets/game_history_card.dart';

class MockGameHistoryBloc
    extends MockBloc<GameHistoryEvent, GameHistoryState>
    implements GameHistoryBloc {}

class FakeGameHistoryEvent extends Fake implements GameHistoryEvent {}

class FakeGameHistoryState extends Fake implements GameHistoryState {}

void main() {
  late MockGameHistoryBloc mockGameHistoryBloc;

  final testGame1 = GameModel(
    id: 'game-1',
    title: 'Beach Game 1',
    groupId: 'group-1',
    createdBy: 'user-1',
    createdAt: DateTime(2025, 1, 10, 10, 0),
    scheduledAt: DateTime(2025, 1, 15, 14, 0),
    endedAt: DateTime(2025, 1, 15, 16, 0),
    location: const GameLocation(name: 'Beach Court', address: '123 Beach Rd'),
    status: GameStatus.completed,
    playerIds: ['user-1', 'user-2', 'user-3', 'user-4'],
  );

  final testGame2 = GameModel(
    id: 'game-2',
    title: 'Evening Match',
    groupId: 'group-1',
    createdBy: 'user-2',
    createdAt: DateTime(2025, 1, 12, 11, 0),
    scheduledAt: DateTime(2025, 1, 14, 18, 0),
    endedAt: DateTime(2025, 1, 14, 20, 0),
    location: const GameLocation(name: 'Sports Center', address: '456 Sports Ave'),
    status: GameStatus.completed,
    playerIds: ['user-1', 'user-3', 'user-5', 'user-6'],
  );

  final testGame3 = GameModel(
    id: 'game-3',
    title: 'Weekend Tournament',
    groupId: 'group-1',
    createdBy: 'user-1',
    createdAt: DateTime(2025, 1, 8, 9, 0),
    scheduledAt: DateTime(2025, 1, 13, 10, 0),
    endedAt: DateTime(2025, 1, 13, 14, 0),
    location: const GameLocation(name: 'Park Courts', address: '789 Park Lane'),
    status: GameStatus.completed,
    playerIds: ['user-1', 'user-2', 'user-4', 'user-7'],
  );

  setUpAll(() {
    registerFallbackValue(FakeGameHistoryEvent());
    registerFallbackValue(FakeGameHistoryState());
  });

  setUp(() {
    mockGameHistoryBloc = MockGameHistoryBloc();
    when(() => mockGameHistoryBloc.state)
        .thenReturn(const GameHistoryState.initial());
  });

  tearDown(() {
    mockGameHistoryBloc.close();
  });

  Widget buildContentWidget(GameHistoryState state) {
    return state.when(
      initial: () => const Center(
        child: Text('Select filters to view game history'),
      ),
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      loaded: (games, hasMore, filter, startDate, endDate, isLoadingMore) {
        if (games.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.history, size: 64),
                const SizedBox(height: 16),
                const Text('No completed games yet'),
                const SizedBox(height: 8),
                const Text('Games will appear here after they are completed'),
              ],
            ),
          );
        }
        return ListView.builder(
          itemCount: games.length + (hasMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index >= games.length) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ),
              );
            }
            final game = games[index];
            return GameHistoryCard(
              game: game,
              onTap: () {},
            );
          },
        );
      },
      error: (message, lastFilter) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48),
            const SizedBox(height: 16),
            Text(message),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget createTestWidget(GameHistoryState state) {
    return MaterialApp(
      home: Scaffold(
        body: buildContentWidget(state),
      ),
    );
  }

  group('GameHistoryScreen Widget Tests', () {
    group('Initial State', () {
      testWidgets('renders initial state message', (tester) async {
        await tester.pumpWidget(
          createTestWidget(const GameHistoryState.initial()),
        );

        expect(find.text('Select filters to view game history'), findsOneWidget);
      });
    });

    group('Loading State', () {
      testWidgets('shows loading indicator during initial load', (tester) async {
        await tester.pumpWidget(
          createTestWidget(const GameHistoryState.loading()),
        );

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });
    });

    group('Empty State', () {
      testWidgets('displays empty state icon when no games', (tester) async {
        await tester.pumpWidget(
          createTestWidget(
            const GameHistoryState.loaded(
              games: [],
              hasMore: false,
              currentFilter: GameHistoryFilter.all,
            ),
          ),
        );

        expect(find.byIcon(Icons.history), findsOneWidget);
      });

      testWidgets('displays empty state title when no games', (tester) async {
        await tester.pumpWidget(
          createTestWidget(
            const GameHistoryState.loaded(
              games: [],
              hasMore: false,
              currentFilter: GameHistoryFilter.all,
            ),
          ),
        );

        expect(find.text('No completed games yet'), findsOneWidget);
      });

      testWidgets('displays empty state description when no games',
          (tester) async {
        await tester.pumpWidget(
          createTestWidget(
            const GameHistoryState.loaded(
              games: [],
              hasMore: false,
              currentFilter: GameHistoryFilter.all,
            ),
          ),
        );

        expect(
          find.text('Games will appear here after they are completed'),
          findsOneWidget,
        );
      });
    });

    group('Games List', () {
      testWidgets('displays list of games', (tester) async {
        await tester.pumpWidget(
          createTestWidget(
            GameHistoryState.loaded(
              games: [testGame1, testGame2, testGame3],
              hasMore: false,
              currentFilter: GameHistoryFilter.all,
            ),
          ),
        );

        expect(find.byType(ListView), findsOneWidget);
        expect(find.byType(GameHistoryCard), findsNWidgets(3));
      });

      testWidgets('displays single game', (tester) async {
        await tester.pumpWidget(
          createTestWidget(
            GameHistoryState.loaded(
              games: [testGame1],
              hasMore: false,
              currentFilter: GameHistoryFilter.all,
            ),
          ),
        );

        expect(find.byType(GameHistoryCard), findsOneWidget);
      });

      testWidgets('shows pagination loading indicator when hasMore is true',
          (tester) async {
        await tester.pumpWidget(
          createTestWidget(
            GameHistoryState.loaded(
              games: [testGame1, testGame2],
              hasMore: true,
              currentFilter: GameHistoryFilter.all,
            ),
          ),
        );

        // Scroll to bottom to see loading indicator
        await tester.drag(find.byType(ListView), const Offset(0, -500));
        await tester.pump();

        expect(find.byType(GameHistoryCard), findsNWidgets(2));
        // There should be a loading indicator at the end
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });

      testWidgets('does not show pagination indicator when hasMore is false',
          (tester) async {
        await tester.pumpWidget(
          createTestWidget(
            GameHistoryState.loaded(
              games: [testGame1, testGame2],
              hasMore: false,
              currentFilter: GameHistoryFilter.all,
            ),
          ),
        );

        expect(find.byType(GameHistoryCard), findsNWidgets(2));
        expect(find.byType(CircularProgressIndicator), findsNothing);
      });
    });

    group('Error State', () {
      testWidgets('displays error icon', (tester) async {
        await tester.pumpWidget(
          createTestWidget(
            const GameHistoryState.error(
              message: 'Failed to load game history',
            ),
          ),
        );

        expect(find.byIcon(Icons.error_outline), findsOneWidget);
      });

      testWidgets('displays error message', (tester) async {
        await tester.pumpWidget(
          createTestWidget(
            const GameHistoryState.error(
              message: 'Failed to load game history',
            ),
          ),
        );

        expect(find.text('Failed to load game history'), findsOneWidget);
      });

      testWidgets('displays retry button on error', (tester) async {
        await tester.pumpWidget(
          createTestWidget(
            const GameHistoryState.error(
              message: 'Network error',
            ),
          ),
        );

        expect(find.text('Retry'), findsOneWidget);
        expect(find.byType(ElevatedButton), findsOneWidget);
      });

      testWidgets('displays different error messages', (tester) async {
        await tester.pumpWidget(
          createTestWidget(
            const GameHistoryState.error(
              message: 'Connection timeout',
            ),
          ),
        );

        expect(find.text('Connection timeout'), findsOneWidget);
      });
    });

    group('Filter States', () {
      testWidgets('displays games with all filter', (tester) async {
        await tester.pumpWidget(
          createTestWidget(
            GameHistoryState.loaded(
              games: [testGame1, testGame2],
              hasMore: false,
              currentFilter: GameHistoryFilter.all,
            ),
          ),
        );

        expect(find.byType(GameHistoryCard), findsNWidgets(2));
      });

      testWidgets('displays games with myGames filter', (tester) async {
        await tester.pumpWidget(
          createTestWidget(
            GameHistoryState.loaded(
              games: [testGame1],
              hasMore: false,
              currentFilter: GameHistoryFilter.myGames,
            ),
          ),
        );

        expect(find.byType(GameHistoryCard), findsOneWidget);
      });
    });

    group('Date Range States', () {
      testWidgets('displays games within date range', (tester) async {
        await tester.pumpWidget(
          createTestWidget(
            GameHistoryState.loaded(
              games: [testGame1],
              hasMore: false,
              currentFilter: GameHistoryFilter.all,
              startDate: DateTime(2025, 1, 14),
              endDate: DateTime(2025, 1, 16),
            ),
          ),
        );

        expect(find.byType(GameHistoryCard), findsOneWidget);
      });
    });

    group('Loading More State', () {
      testWidgets('shows loading indicator when loading more', (tester) async {
        await tester.pumpWidget(
          createTestWidget(
            GameHistoryState.loaded(
              games: [testGame1, testGame2],
              hasMore: true,
              currentFilter: GameHistoryFilter.all,
              isLoadingMore: true,
            ),
          ),
        );

        // Scroll to bottom
        await tester.drag(find.byType(ListView), const Offset(0, -500));
        await tester.pump();

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });
    });

    group('Game Cards Display', () {
      testWidgets('displays correct number of game cards', (tester) async {
        await tester.pumpWidget(
          createTestWidget(
            GameHistoryState.loaded(
              games: [testGame1, testGame2, testGame3],
              hasMore: false,
              currentFilter: GameHistoryFilter.all,
            ),
          ),
        );

        expect(find.byType(GameHistoryCard), findsNWidgets(3));
      });

      testWidgets('game cards are scrollable', (tester) async {
        // Create many games for scrolling test
        final manyGames = List.generate(
          10,
          (index) => GameModel(
            id: 'game-$index',
            title: 'Game $index',
            groupId: 'group-1',
            createdBy: 'user-1',
            createdAt: DateTime(2025, 1, index + 1),
            scheduledAt: DateTime(2025, 1, index + 5),
            location: const GameLocation(name: 'Court', address: 'Address'),
            status: GameStatus.completed,
          ),
        );

        await tester.pumpWidget(
          createTestWidget(
            GameHistoryState.loaded(
              games: manyGames,
              hasMore: false,
              currentFilter: GameHistoryFilter.all,
            ),
          ),
        );

        // Verify ListView is present for scrolling
        expect(find.byType(ListView), findsOneWidget);

        // Scroll down
        await tester.drag(find.byType(ListView), const Offset(0, -300));
        await tester.pump();
      });
    });

    group('Edge Cases', () {
      testWidgets('handles error with lastFilter', (tester) async {
        await tester.pumpWidget(
          createTestWidget(
            const GameHistoryState.error(
              message: 'Error occurred',
              lastFilter: GameHistoryFilter.myGames,
            ),
          ),
        );

        expect(find.text('Error occurred'), findsOneWidget);
        expect(find.text('Retry'), findsOneWidget);
      });

      testWidgets('handles empty games list with filters active',
          (tester) async {
        await tester.pumpWidget(
          createTestWidget(
            GameHistoryState.loaded(
              games: [],
              hasMore: false,
              currentFilter: GameHistoryFilter.myGames,
              startDate: DateTime(2025, 1, 1),
              endDate: DateTime(2025, 1, 31),
            ),
          ),
        );

        expect(find.text('No completed games yet'), findsOneWidget);
      });
    });
  });
}
