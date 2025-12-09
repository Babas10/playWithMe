// BLoC for managing game history with pagination and filters (Story 14.7)

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/domain/repositories/game_repository.dart';
import 'game_history_event.dart';
import 'game_history_state.dart';

class GameHistoryBloc extends Bloc<GameHistoryEvent, GameHistoryState> {
  final GameRepository _gameRepository;

  DocumentSnapshot? _lastDocument;
  String? _currentGroupId; // null means all groups
  String? _currentUserId;
  GameHistoryFilter _currentFilter = GameHistoryFilter.all;
  DateTime? _startDate;
  DateTime? _endDate;

  GameHistoryBloc({
    required GameRepository gameRepository,
  })  : _gameRepository = gameRepository,
        super(const GameHistoryState.initial()) {
    on<GameHistoryLoadEvent>(_onLoad);
    on<GameHistoryLoadMoreEvent>(_onLoadMore);
    on<GameHistoryRefreshEvent>(_onRefresh);
    on<GameHistoryFilterChangedEvent>(_onFilterChanged);
    on<GameHistoryDateRangeChangedEvent>(_onDateRangeChanged);
  }

  Future<void> _onLoad(
    GameHistoryLoadEvent event,
    Emitter<GameHistoryState> emit,
  ) async {
    emit(const GameHistoryState.loading());

    _currentGroupId = event.groupId;
    _currentUserId = event.userId;
    _currentFilter = event.filter;
    _startDate = event.startDate;
    _endDate = event.endDate;
    _lastDocument = null; // Reset pagination

    try {
      final page = await _gameRepository
          .getCompletedGames(
            groupId: event.groupId,
            userId: event.filter == GameHistoryFilter.myGames
                ? event.userId
                : null,
            startDate: event.startDate,
            endDate: event.endDate,
            lastDocument: null,
          )
          .first;

      _lastDocument = page.lastDocument;
      emit(GameHistoryState.loaded(
        games: page.games,
        hasMore: page.hasMore,
        currentFilter: _currentFilter,
        startDate: _startDate,
        endDate: _endDate,
      ));
    } catch (e) {
      emit(GameHistoryState.error(
        message: 'Failed to load games: $e',
        lastFilter: _currentFilter,
      ));
    }
  }

  Future<void> _onLoadMore(
    GameHistoryLoadMoreEvent event,
    Emitter<GameHistoryState> emit,
  ) async {
    final currentState = state;
    if (currentState is! GameHistoryLoaded) return;
    if (!currentState.hasMore || currentState.isLoadingMore) return;

    // Emit loading more state
    emit(currentState.copyWith(isLoadingMore: true));

    try {
      final page = await _gameRepository
          .getCompletedGames(
            groupId: _currentGroupId,
            userId: _currentFilter == GameHistoryFilter.myGames
                ? _currentUserId
                : null,
            startDate: _startDate,
            endDate: _endDate,
            lastDocument: _lastDocument,
          )
          .first;

      _lastDocument = page.lastDocument;

      emit(GameHistoryState.loaded(
        games: [...currentState.games, ...page.games],
        hasMore: page.hasMore,
        currentFilter: _currentFilter,
        startDate: _startDate,
        endDate: _endDate,
        isLoadingMore: false,
      ));
    } catch (e) {
      emit(currentState.copyWith(isLoadingMore: false));
      // Don't emit error, just stop loading more
    }
  }

  Future<void> _onRefresh(
    GameHistoryRefreshEvent event,
    Emitter<GameHistoryState> emit,
  ) async {
    if (_currentUserId == null) return;

    // Reload with current filters
    add(GameHistoryEvent.load(
      groupId: _currentGroupId,
      userId: _currentUserId!,
      filter: _currentFilter,
      startDate: _startDate,
      endDate: _endDate,
    ));
  }

  Future<void> _onFilterChanged(
    GameHistoryFilterChangedEvent event,
    Emitter<GameHistoryState> emit,
  ) async {
    if (_currentUserId == null) return;

    _currentFilter = event.filter;

    // Reload with new filter
    add(GameHistoryEvent.load(
      groupId: _currentGroupId,
      userId: _currentUserId!,
      filter: event.filter,
      startDate: _startDate,
      endDate: _endDate,
    ));
  }

  Future<void> _onDateRangeChanged(
    GameHistoryDateRangeChangedEvent event,
    Emitter<GameHistoryState> emit,
  ) async {
    if (_currentUserId == null) return;

    _startDate = event.startDate;
    _endDate = event.endDate;

    // Reload with new date range
    add(GameHistoryEvent.load(
      groupId: _currentGroupId,
      userId: _currentUserId!,
      filter: _currentFilter,
      startDate: event.startDate,
      endDate: event.endDate,
    ));
  }
}
