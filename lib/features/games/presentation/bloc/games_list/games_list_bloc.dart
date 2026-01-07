// Manages group activity feed state with real-time Firestore updates (games + training sessions).
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:play_with_me/core/domain/repositories/game_repository.dart';
import 'package:play_with_me/core/domain/repositories/training_session_repository.dart';
import 'package:play_with_me/core/data/models/group_activity_item.dart';
import 'package:rxdart/rxdart.dart';
import 'games_list_event.dart';
import 'games_list_state.dart';

class GamesListBloc extends Bloc<GamesListEvent, GamesListState> {
  final GameRepository _gameRepository;
  final TrainingSessionRepository _trainingSessionRepository;
  StreamSubscription<dynamic>? _activitiesSubscription;
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
  }

  Future<void> _onLoadGamesForGroup(
    LoadGamesForGroup event,
    Emitter<GamesListState> emit,
  ) async {
    try {
      emit(const GamesListLoading());

      _currentGroupId = event.groupId;
      _currentUserId = event.userId;

      await _activitiesSubscription?.cancel();

      // Combine games and training sessions streams
      final gamesStream = _gameRepository.getGamesForGroup(event.groupId);
      final trainingsStream = _trainingSessionRepository
          .getTrainingSessionsForGroup(event.groupId);

      _activitiesSubscription =
          Rx.combineLatest2(gamesStream, trainingsStream, (games, trainings) {
        // Convert to GroupActivityItem
        final gameActivities =
            games.map((game) => GroupActivityItem.game(game)).toList();
        final trainingActivities = trainings
            .map((session) => GroupActivityItem.training(session))
            .toList();

        return [...gameActivities, ...trainingActivities];
      }).listen(
        (activities) {
          add(ActivityListUpdated(activities: activities));
        },
        onError: (error) {
          print('❌ GamesListBloc: Stream error: $error');
          add(const ActivityListUpdated(activities: []));
        },
      );
    } catch (e) {
      emit(GamesListError(
          message: 'Failed to load activities: ${e.toString()}'));
    }
  }

  Future<void> _onActivityListUpdated(
    ActivityListUpdated event,
    Emitter<GamesListState> emit,
  ) async {
    final now = DateTime.now();

    // Separate into upcoming and past activities
    final upcomingActivities = event.activities
        .where((activity) => activity.startTime.isAfter(now))
        .toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));

    final pastActivities = event.activities
        .where((activity) => !activity.startTime.isAfter(now))
        .toList()
      ..sort((a, b) => b.startTime.compareTo(a.startTime));

    // Emit empty state only if both lists are empty after filtering
    if (upcomingActivities.isEmpty && pastActivities.isEmpty) {
      emit(GamesListEmpty(userId: _currentUserId ?? ''));
      return;
    }

    emit(GamesListLoaded(
      upcomingActivities: upcomingActivities,
      pastActivities: pastActivities,
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
    _activitiesSubscription?.cancel();
    return super.close();
  }
}
