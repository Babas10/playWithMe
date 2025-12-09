// Tests for GameHistoryBloc (Story 14.7)

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:play_with_me/core/data/models/game_model.dart';
import 'package:play_with_me/features/games/presentation/bloc/game_history/game_history_bloc.dart';
import 'package:play_with_me/features/games/presentation/bloc/game_history/game_history_event.dart';
import 'package:play_with_me/features/games/presentation/bloc/game_history/game_history_state.dart';

import '../../../../../../unit/core/data/repositories/mock_game_repository.dart';

void main() {
  late MockGameRepository mockRepository;

  setUp(() {
    mockRepository = MockGameRepository();
  });

  tearDown(() {
    mockRepository.dispose();
  });

  group('GameHistoryBloc', () {
    final testGame1 = GameModel(
      id: 'game1',
      title: 'Game 1',
      groupId: 'group1',
      createdBy: 'user1',
      createdAt: DateTime(2024, 1, 1),
      scheduledAt: DateTime(2024, 1, 5),
      location: const GameLocation(name: 'Test Location', latitude: 0, longitude: 0),
      status: GameStatus.completed,
      completedAt: DateTime(2024, 1, 5, 14, 0),
      playerIds: ['user1', 'user2'],
    );

    final testGame2 = GameModel(
      id: 'game2',
      title: 'Game 2',
      groupId: 'group1',
      createdBy: 'user1',
      createdAt: DateTime(2024, 1, 2),
      scheduledAt: DateTime(2024, 1, 6),
      location: const GameLocation(name: 'Test Location 2', latitude: 0, longitude: 0),
      status: GameStatus.completed,
      completedAt: DateTime(2024, 1, 6, 14, 0),
      playerIds: ['user2', 'user3'],
    );

    blocTest<GameHistoryBloc, GameHistoryState>(
      'emits [loading, loaded] when games are loaded successfully',
      build: () {
        mockRepository.addGame(testGame1);
        mockRepository.addGame(testGame2);
        return GameHistoryBloc(gameRepository: mockRepository);
      },
      act: (bloc) => bloc.add(const GameHistoryEvent.load(
        groupId: 'group1',
        userId: 'user1',
      )),
      expect: () => [
        const GameHistoryState.loading(),
        isA<GameHistoryLoaded>()
            .having((s) => s.games.length, 'games length', 2)
            .having((s) => s.currentFilter, 'filter', GameHistoryFilter.all),
      ],
    );

    blocTest<GameHistoryBloc, GameHistoryState>(
      'filters games by user when myGames filter is applied',
      build: () {
        mockRepository.addGame(testGame1);
        mockRepository.addGame(testGame2);
        return GameHistoryBloc(gameRepository: mockRepository);
      },
      act: (bloc) => bloc.add(const GameHistoryEvent.load(
        groupId: 'group1',
        userId: 'user1',
        filter: GameHistoryFilter.myGames,
      )),
      expect: () => [
        const GameHistoryState.loading(),
        isA<GameHistoryLoaded>()
            .having((s) => s.games.length, 'games length', 1)
            .having((s) => s.games.first.id, 'game id', 'game1'),
      ],
    );

    blocTest<GameHistoryBloc, GameHistoryState>(
      'emits empty list when no completed games exist',
      build: () => GameHistoryBloc(gameRepository: mockRepository),
      act: (bloc) => bloc.add(const GameHistoryEvent.load(
        groupId: 'group1',
        userId: 'user1',
      )),
      expect: () => [
        const GameHistoryState.loading(),
        isA<GameHistoryLoaded>().having((s) => s.games, 'games', isEmpty),
      ],
    );

    blocTest<GameHistoryBloc, GameHistoryState>(
      'changes filter when filterChanged event is added',
      build: () {
        mockRepository.addGame(testGame1);
        mockRepository.addGame(testGame2);
        return GameHistoryBloc(gameRepository: mockRepository);
      },
      act: (bloc) async {
        bloc.add(const GameHistoryEvent.load(
          groupId: 'group1',
          userId: 'user1',
        ));
        await Future.delayed(const Duration(milliseconds: 100));
        bloc.add(const GameHistoryEvent.filterChanged(
          filter: GameHistoryFilter.myGames,
        ));
      },
      skip: 2, // Skip initial loading and loaded states
      expect: () => [
        const GameHistoryState.loading(),
        isA<GameHistoryLoaded>()
            .having((s) => s.games.length, 'games length', 1)
            .having((s) => s.currentFilter, 'filter', GameHistoryFilter.myGames),
      ],
    );

    blocTest<GameHistoryBloc, GameHistoryState>(
      'reloads games when refresh event is added',
      build: () {
        mockRepository.addGame(testGame1);
        return GameHistoryBloc(gameRepository: mockRepository);
      },
      act: (bloc) async {
        bloc.add(const GameHistoryEvent.load(
          groupId: 'group1',
          userId: 'user1',
        ));
        await Future.delayed(const Duration(milliseconds: 100));
        // Add another game
        mockRepository.addGame(testGame2);
        bloc.add(const GameHistoryEvent.refresh());
      },
      skip: 2,
      expect: () => [
        const GameHistoryState.loading(),
        isA<GameHistoryLoaded>().having((s) => s.games.length, 'games length', 2),
      ],
    );
  });
}
