// Manages games list state with real-time Firestore updates for a group.
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:play_with_me/core/domain/repositories/game_repository.dart';
import 'games_list_event.dart';
import 'games_list_state.dart';

class GamesListBloc extends Bloc<GamesListEvent, GamesListState> {
  final GameRepository _gameRepository;
  StreamSubscription<dynamic>? _gamesSubscription;
  String? _currentGroupId;
  String? _currentUserId;

  GamesListBloc({required GameRepository gameRepository})
      : _gameRepository = gameRepository,
        super(const GamesListInitial()) {
    on<LoadGamesForGroup>(_onLoadGamesForGroup);
    on<GamesListUpdated>(_onGamesListUpdated);
    on<RefreshGamesList>(_onRefreshGamesList);
  }

  Future<void> _onLoadGamesForGroup(
    LoadGamesForGroup event,
    Emitter<GamesListState> emit,
  ) async {
    try {
      emit(const GamesListLoading());

      _currentGroupId = event.groupId;
      _currentUserId = event.userId;

      await _gamesSubscription?.cancel();
      _gamesSubscription = _gameRepository.getGamesForGroup(event.groupId).listen(
        (games) {
          add(GamesListUpdated(games: games));
        },
        onError: (error) {
          print('❌ GamesListBloc: Stream error: $error');
          add(const GamesListUpdated(games: []));
        },
      );
    } catch (e) {
      emit(GamesListError(message: 'Failed to load games: ${e.toString()}'));
    }
  }

  Future<void> _onGamesListUpdated(
    GamesListUpdated event,
    Emitter<GamesListState> emit,
  ) async {
    final now = DateTime.now();
    final upcomingGames = event.games
        .where((game) => game.scheduledAt.isAfter(now))
        .toList()
      ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));

    final pastGames = event.games
        .where((game) => !game.scheduledAt.isAfter(now))
        .toList()
      ..sort((a, b) => b.scheduledAt.compareTo(a.scheduledAt));

    // Emit empty state only if both lists are empty after filtering
    if (upcomingGames.isEmpty && pastGames.isEmpty) {
      emit(GamesListEmpty(userId: _currentUserId ?? ''));
      return;
    }

    emit(GamesListLoaded(
      upcomingGames: upcomingGames,
      pastGames: pastGames,
      userId: _currentUserId ?? '',
    ));
  }

  Future<void> _onRefreshGamesList(
    RefreshGamesList event,
    Emitter<GamesListState> emit,
  ) async {
    if (_currentGroupId != null && _currentUserId != null) {
      add(LoadGamesForGroup(
        groupId: _currentGroupId!,
        userId: _currentUserId!,
      ));
    }
  }

  @override
  Future<void> close() {
    _gamesSubscription?.cancel();
    return super.close();
  }
}
