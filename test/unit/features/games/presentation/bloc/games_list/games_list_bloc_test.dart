// Validates GamesListBloc emits correct states during game list operations.
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:play_with_me/core/data/models/game_model.dart';
import 'package:play_with_me/features/games/presentation/bloc/games_list/games_list_bloc.dart';
import 'package:play_with_me/features/games/presentation/bloc/games_list/games_list_event.dart';
import 'package:play_with_me/features/games/presentation/bloc/games_list/games_list_state.dart';
import '../../../../../core/data/repositories/mock_game_repository.dart';

void main() {
  const testGroupId = 'group-123';
  const testUserId = 'user-123';

  GameModel _createTestGame({
    required String id,
    required String title,
    required String groupId,
    required DateTime scheduledAt,
    List<String> playerIds = const [],
    List<String> waitlistIds = const [],
    GameStatus status = GameStatus.scheduled,
  }) {
    return GameModel(
      id: id,
      title: title,
      groupId: groupId,
      createdBy: 'creator-1',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      scheduledAt: scheduledAt,
      location: const GameLocation(
        name: 'Test Court',
        latitude: 0.0,
        longitude: 0.0,
      ),
      playerIds: playerIds,
      waitlistIds: waitlistIds,
      status: status,
    );
  }

  group('GamesListBloc', () {
    test('initial state is GamesListInitial', () {
      final mockGameRepository = MockGameRepository();
      final bloc = GamesListBloc(gameRepository: mockGameRepository);
      expect(bloc.state, const GamesListInitial());
      bloc.close();
      mockGameRepository.dispose();
    });

    blocTest<GamesListBloc, GamesListState>(
      'emits [Loading, Empty] when no games exist',
      build: () {
        final mockGameRepository = MockGameRepository();
        mockGameRepository.clearGames();
        return GamesListBloc(gameRepository: mockGameRepository);
      },
      act: (bloc) => bloc.add(
        const LoadGamesForGroup(groupId: testGroupId, userId: testUserId),
      ),
      expect: () => [
        const GamesListLoading(),
        const GamesListEmpty(userId: testUserId),
      ],
    );

    blocTest<GamesListBloc, GamesListState>(
      'emits [Loading, Loaded] with upcoming games when games exist in future',
      build: () {
        final mockGameRepository = MockGameRepository();
        final futureGame = _createTestGame(
          id: 'game-1',
          title: 'Future Game',
          groupId: testGroupId,
          scheduledAt: DateTime.now().add(const Duration(days: 2)),
        );
        mockGameRepository.addGame(futureGame);
        return GamesListBloc(gameRepository: mockGameRepository);
      },
      act: (bloc) => bloc.add(
        const LoadGamesForGroup(groupId: testGroupId, userId: testUserId),
      ),
      expect: () => [
        const GamesListLoading(),
        isA<GamesListLoaded>()
            .having((s) => s.upcomingGames.length, 'upcoming games count', 1)
            .having((s) => s.pastGames.length, 'past games count', 0)
            .having((s) => s.userId, 'userId', testUserId),
      ],
    );

    blocTest<GamesListBloc, GamesListState>(
      'emits [Loading, Loaded] with past games when games exist in past',
      build: () {
        final mockGameRepository = MockGameRepository();
        final pastGame = _createTestGame(
          id: 'game-1',
          title: 'Past Game',
          groupId: testGroupId,
          scheduledAt: DateTime.now().subtract(const Duration(days: 2)),
        );
        mockGameRepository.addGame(pastGame);
        return GamesListBloc(gameRepository: mockGameRepository);
      },
      act: (bloc) => bloc.add(
        const LoadGamesForGroup(groupId: testGroupId, userId: testUserId),
      ),
      expect: () => [
        const GamesListLoading(),
        isA<GamesListLoaded>()
            .having((s) => s.upcomingGames.length, 'upcoming games count', 0)
            .having((s) => s.pastGames.length, 'past games count', 1)
            .having((s) => s.userId, 'userId', testUserId),
      ],
    );

    blocTest<GamesListBloc, GamesListState>(
      'separates upcoming and past games correctly',
      build: () {
        final mockGameRepository = MockGameRepository();
        final pastGame1 = _createTestGame(
          id: 'game-1',
          title: 'Past Game 1',
          groupId: testGroupId,
          scheduledAt: DateTime.now().subtract(const Duration(days: 3)),
        );
        final pastGame2 = _createTestGame(
          id: 'game-2',
          title: 'Past Game 2',
          groupId: testGroupId,
          scheduledAt: DateTime.now().subtract(const Duration(days: 1)),
        );
        final futureGame1 = _createTestGame(
          id: 'game-3',
          title: 'Future Game 1',
          groupId: testGroupId,
          scheduledAt: DateTime.now().add(const Duration(days: 1)),
        );
        final futureGame2 = _createTestGame(
          id: 'game-4',
          title: 'Future Game 2',
          groupId: testGroupId,
          scheduledAt: DateTime.now().add(const Duration(days: 3)),
        );

        mockGameRepository.addGame(pastGame1);
        mockGameRepository.addGame(pastGame2);
        mockGameRepository.addGame(futureGame1);
        mockGameRepository.addGame(futureGame2);
        return GamesListBloc(gameRepository: mockGameRepository);
      },
      act: (bloc) => bloc.add(
        const LoadGamesForGroup(groupId: testGroupId, userId: testUserId),
      ),
      expect: () => [
        const GamesListLoading(),
        isA<GamesListLoaded>()
            .having((s) => s.upcomingGames.length, 'upcoming games count', 2)
            .having((s) => s.pastGames.length, 'past games count', 2),
      ],
    );

    blocTest<GamesListBloc, GamesListState>(
      'sorts upcoming games by scheduledAt (ascending)',
      build: () {
        final mockGameRepository = MockGameRepository();
        final game1 = _createTestGame(
          id: 'game-1',
          title: 'Game Far Future',
          groupId: testGroupId,
          scheduledAt: DateTime.now().add(const Duration(days: 5)),
        );
        final game2 = _createTestGame(
          id: 'game-2',
          title: 'Game Near Future',
          groupId: testGroupId,
          scheduledAt: DateTime.now().add(const Duration(days: 1)),
        );
        final game3 = _createTestGame(
          id: 'game-3',
          title: 'Game Mid Future',
          groupId: testGroupId,
          scheduledAt: DateTime.now().add(const Duration(days: 3)),
        );

        mockGameRepository.addGame(game1);
        mockGameRepository.addGame(game2);
        mockGameRepository.addGame(game3);
        return GamesListBloc(gameRepository: mockGameRepository);
      },
      act: (bloc) => bloc.add(
        const LoadGamesForGroup(groupId: testGroupId, userId: testUserId),
      ),
      verify: (bloc) {
        final state = bloc.state as GamesListLoaded;
        expect(state.upcomingGames[0].id, 'game-2'); // Nearest first
        expect(state.upcomingGames[1].id, 'game-3');
        expect(state.upcomingGames[2].id, 'game-1'); // Farthest last
      },
    );

    blocTest<GamesListBloc, GamesListState>(
      'sorts past games by scheduledAt (descending - most recent first)',
      build: () {
        final mockGameRepository = MockGameRepository();
        final game1 = _createTestGame(
          id: 'game-1',
          title: 'Game Long Ago',
          groupId: testGroupId,
          scheduledAt: DateTime.now().subtract(const Duration(days: 5)),
        );
        final game2 = _createTestGame(
          id: 'game-2',
          title: 'Game Recently',
          groupId: testGroupId,
          scheduledAt: DateTime.now().subtract(const Duration(days: 1)),
        );
        final game3 = _createTestGame(
          id: 'game-3',
          title: 'Game Moderately Ago',
          groupId: testGroupId,
          scheduledAt: DateTime.now().subtract(const Duration(days: 3)),
        );

        mockGameRepository.addGame(game1);
        mockGameRepository.addGame(game2);
        mockGameRepository.addGame(game3);
        return GamesListBloc(gameRepository: mockGameRepository);
      },
      act: (bloc) => bloc.add(
        const LoadGamesForGroup(groupId: testGroupId, userId: testUserId),
      ),
      verify: (bloc) {
        final state = bloc.state as GamesListLoaded;
        expect(state.pastGames[0].id, 'game-2'); // Most recent first
        expect(state.pastGames[1].id, 'game-3');
        expect(state.pastGames[2].id, 'game-1'); // Oldest last
      },
    );

    blocTest<GamesListBloc, GamesListState>(
      'filters games by groupId correctly',
      build: () {
        final mockGameRepository = MockGameRepository();
        final game1 = _createTestGame(
          id: 'game-1',
          title: 'Group 1 Game',
          groupId: 'group-1',
          scheduledAt: DateTime.now().add(const Duration(days: 1)),
        );
        final game2 = _createTestGame(
          id: 'game-2',
          title: 'Group 123 Game',
          groupId: testGroupId,
          scheduledAt: DateTime.now().add(const Duration(days: 1)),
        );
        final game3 = _createTestGame(
          id: 'game-3',
          title: 'Group 2 Game',
          groupId: 'group-2',
          scheduledAt: DateTime.now().add(const Duration(days: 1)),
        );

        mockGameRepository.addGame(game1);
        mockGameRepository.addGame(game2);
        mockGameRepository.addGame(game3);
        return GamesListBloc(gameRepository: mockGameRepository);
      },
      act: (bloc) => bloc.add(
        const LoadGamesForGroup(groupId: testGroupId, userId: testUserId),
      ),
      verify: (bloc) {
        final state = bloc.state as GamesListLoaded;
        expect(state.upcomingGames.length, 1);
        expect(state.upcomingGames[0].id, 'game-2');
        expect(state.upcomingGames[0].groupId, testGroupId);
      },
    );

    blocTest<GamesListBloc, GamesListState>(
      'treats game scheduled at current time as past game',
      build: () {
        final mockGameRepository = MockGameRepository();
        final now = DateTime.now();
        final gameNow = _createTestGame(
          id: 'game-now',
          title: 'Game Right Now',
          groupId: testGroupId,
          scheduledAt: now,
        );
        mockGameRepository.addGame(gameNow);
        return GamesListBloc(gameRepository: mockGameRepository);
      },
      act: (bloc) => bloc.add(
        const LoadGamesForGroup(groupId: testGroupId, userId: testUserId),
      ),
      verify: (bloc) {
        final state = bloc.state as GamesListLoaded;
        expect(state.upcomingGames.length, 0);
        expect(state.pastGames.length, 1);
        expect(state.pastGames[0].id, 'game-now');
      },
    );

    blocTest<GamesListBloc, GamesListState>(
      'RefreshGamesList triggers reload with same groupId and userId',
      build: () {
        final mockGameRepository = MockGameRepository();
        final game = _createTestGame(
          id: 'game-1',
          title: 'Test Game',
          groupId: testGroupId,
          scheduledAt: DateTime.now().add(const Duration(days: 1)),
        );
        mockGameRepository.addGame(game);
        return GamesListBloc(gameRepository: mockGameRepository);
      },
      act: (bloc) async {
        bloc.add(const LoadGamesForGroup(
          groupId: testGroupId,
          userId: testUserId,
        ));
        await Future.delayed(const Duration(milliseconds: 100));
        bloc.add(const RefreshGamesList());
      },
      expect: () => [
        const GamesListLoading(),
        isA<GamesListLoaded>(),
        const GamesListLoading(),
      ],
      wait: const Duration(milliseconds: 300),
    );
  });
}
