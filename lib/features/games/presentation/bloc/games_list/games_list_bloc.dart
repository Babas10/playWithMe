// Manages group activity feed state with real-time Firestore updates (games + training sessions).
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:play_with_me/core/data/models/training_session_model.dart';
import 'package:play_with_me/core/domain/exceptions/repository_exceptions.dart';
import 'package:play_with_me/core/domain/repositories/game_repository.dart';
import 'package:play_with_me/core/domain/repositories/training_session_repository.dart';
import 'package:play_with_me/core/data/models/game_model.dart';
import 'package:play_with_me/core/data/models/group_activity_item.dart';
import 'games_list_event.dart';
import 'games_list_state.dart';

class GamesListBloc extends Bloc<GamesListEvent, GamesListState> {
  final GameRepository _gameRepository;
  final TrainingSessionRepository _trainingSessionRepository;
  StreamSubscription<List<GameModel>>? _gamesSubscription;
  StreamSubscription<List<TrainingSessionModel>>? _trainingsSubscription;
  List<GameModel> _currentGames = [];
  List<TrainingSessionModel> _currentTrainings = [];
  String? _currentGroupId;
  String? _currentUserId;

  GamesListBloc({
    required GameRepository gameRepository,
    required TrainingSessionRepository trainingSessionRepository,
  })  : _gameRepository = gameRepository,
        _trainingSessionRepository = trainingSessionRepository,
        super(const GamesListInitial()) {
    on<LoadGamesForGroup>(_onLoadGamesForGroup);
    on<ActivityListUpdated>(_onActivityListUpdated);
    on<RefreshGamesList>(_onRefreshGamesList);
    on<LoadOlderActivities>(_onLoadOlderActivities);
  }

  Future<void> _onLoadGamesForGroup(
    LoadGamesForGroup event,
    Emitter<GamesListState> emit,
  ) async {
    try {
      emit(const GamesListLoading());

      _currentGroupId = event.groupId;
      _currentUserId = event.userId;
      _currentGames = [];
      _currentTrainings = [];

      await _gamesSubscription?.cancel();
      await _trainingsSubscription?.cancel();

      // Subscribe to games — emits independently as soon as data arrives
      _gamesSubscription = _gameRepository
          .getRecentGamesForGroup(event.groupId)
          .listen(
        (games) {
          _currentGames = games;
          _emitMerged();
        },
        onError: (error) {
          debugPrint('❌ GamesListBloc: Games stream error: $error');
        },
      );

      // Subscribe to trainings — emits independently as soon as data arrives
      _trainingsSubscription = _trainingSessionRepository
          .getRecentTrainingSessionsForGroup(event.groupId)
          .listen(
        (trainings) {
          _currentTrainings = trainings;
          _emitMerged();
        },
        onError: (error) {
          debugPrint('❌ GamesListBloc: Trainings stream error: $error');
        },
      );
    } on GameException catch (e) {
      emit(GamesListError(message: e.message));
    } on TrainingSessionException catch (e) {
      emit(GamesListError(message: e.message));
    } catch (e) {
      emit(GamesListError(
          message: 'Failed to load activities: ${e.toString()}'));
    }
  }

  void _emitMerged() {
    final gameActivities =
        _currentGames.map((game) => GroupActivityItem.game(game)).toList();
    final trainingActivities = _currentTrainings
        .map((session) => GroupActivityItem.training(session))
        .toList();
    add(ActivityListUpdated(
        activities: [...gameActivities, ...trainingActivities]));
  }

  Future<void> _onActivityListUpdated(
    ActivityListUpdated event,
    Emitter<GamesListState> emit,
  ) async {
    final now = DateTime.now();

    final upcomingActivities = event.activities
        .where((activity) => activity.startTime.isAfter(now))
        .toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));

    final pastActivities = event.activities
        .where((activity) => !activity.startTime.isAfter(now))
        .toList()
      ..sort((a, b) => b.startTime.compareTo(a.startTime));

    if (upcomingActivities.isEmpty && pastActivities.isEmpty) {
      emit(GamesListEmpty(userId: _currentUserId ?? ''));
      return;
    }

    // Preserve older activities if already loaded
    final previousOlder = state is GamesListLoaded
        ? (state as GamesListLoaded).olderPastActivities
        : <GroupActivityItem>[];
    final previousOlderLoaded = state is GamesListLoaded
        ? (state as GamesListLoaded).olderActivitiesLoaded
        : false;

    emit(GamesListLoaded(
      upcomingActivities: upcomingActivities,
      pastActivities: pastActivities,
      olderPastActivities: previousOlder,
      olderActivitiesLoaded: previousOlderLoaded,
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

  Future<void> _onLoadOlderActivities(
    LoadOlderActivities event,
    Emitter<GamesListState> emit,
  ) async {
    if (state is! GamesListLoaded || _currentGroupId == null) return;
    final current = state as GamesListLoaded;
    if (current.isLoadingOlderActivities || current.olderActivitiesLoaded) {
      return;
    }

    emit(current.copyWith(isLoadingOlderActivities: true));

    try {
      final results = await Future.wait([
        _gameRepository.getOlderGamesForGroup(_currentGroupId!),
        _trainingSessionRepository
            .getOlderTrainingSessionsForGroup(_currentGroupId!),
      ]);

      final olderGames = (results[0] as List<GameModel>)
          .map((g) => GroupActivityItem.game(g))
          .toList();
      final olderTrainings =
          (results[1] as List<TrainingSessionModel>)
              .map((s) => GroupActivityItem.training(s))
              .toList();

      final olderActivities = [...olderGames, ...olderTrainings]
        ..sort((a, b) => b.startTime.compareTo(a.startTime));

      if (state is GamesListLoaded) {
        emit((state as GamesListLoaded).copyWith(
          olderPastActivities: olderActivities,
          isLoadingOlderActivities: false,
          olderActivitiesLoaded: true,
        ));
      }
    } catch (e) {
      if (state is GamesListLoaded) {
        emit((state as GamesListLoaded).copyWith(
          isLoadingOlderActivities: false,
        ));
      }
      debugPrint('❌ GamesListBloc: Failed to load older activities: $e');
    }
  }

  @override
  Future<void> close() {
    _gamesSubscription?.cancel();
    _trainingsSubscription?.cancel();
    return super.close();
  }
}
