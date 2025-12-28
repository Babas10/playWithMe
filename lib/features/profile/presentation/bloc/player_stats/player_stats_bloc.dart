import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:play_with_me/core/data/models/rating_history_entry.dart';
import 'package:play_with_me/core/domain/repositories/user_repository.dart';

import 'player_stats_event.dart';
import 'player_stats_state.dart';

class PlayerStatsBloc extends Bloc<PlayerStatsEvent, PlayerStatsState> {
  final UserRepository _userRepository;
  StreamSubscription? _userSubscription;

  PlayerStatsBloc({required UserRepository userRepository})
      : _userRepository = userRepository,
        super(PlayerStatsInitial()) {
    on<LoadPlayerStats>(_onLoadPlayerStats);
    on<UpdateUserStats>(_onUpdateUserStats);
  }

  Future<void> _onLoadPlayerStats(
    LoadPlayerStats event,
    Emitter<PlayerStatsState> emit,
  ) async {
    emit(PlayerStatsLoading());

    try {
      // Fetch user immediately to ensure we don't hang forever
      final initialUser = await _userRepository
          .getUserStream(event.userId)
          .timeout(
            const Duration(seconds: 5),
            onTimeout: (sink) {
              sink.addError(TimeoutException('Failed to load user data'));
            },
          )
          .first;

      if (initialUser != null) {
        // Trigger the update with the initial user
        add(UpdateUserStats(initialUser));

        // Set up stream for future updates
        await _userSubscription?.cancel();
        _userSubscription = _userRepository.getUserStream(event.userId).listen(
          (user) {
            if (user != null) {
              add(UpdateUserStats(user));
            }
          },
          onError: (error) {
            // Log error but don't crash
            print('PlayerStatsBloc: Error in user stream: $error');
          },
        );
      } else {
        emit(PlayerStatsError('User not found'));
      }
    } catch (e) {
      emit(PlayerStatsError('Failed to load player stats: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateUserStats(
    UpdateUserStats event,
    Emitter<PlayerStatsState> emit,
  ) async {
    try {
      // If we already have history in the current state, reuse it unless we want to refresh.
      List<RatingHistoryEntry> history = [];
      if (state is PlayerStatsLoaded) {
        history = (state as PlayerStatsLoaded).history;
      }

      // If history is empty (first load) or we want to refresh (e.g. gamesPlayed changed), fetch it.
      // For now, let's fetch if empty.
      if (history.isEmpty) {
        history = await _userRepository
            .getRatingHistory(event.user.uid)
            .timeout(const Duration(seconds: 5), onTimeout: (sink) {
          sink.add([]); // Return empty list on timeout
        }).first;
      } else {
        // Check if we need to refresh history (simple check: gamesPlayed count)
        // If state.user.gamesPlayed < event.user.gamesPlayed, then a new game finished.
        if (state is PlayerStatsLoaded &&
            (state as PlayerStatsLoaded).user.gamesPlayed < event.user.gamesPlayed) {
          history = await _userRepository
              .getRatingHistory(event.user.uid)
              .timeout(const Duration(seconds: 5), onTimeout: (sink) {
            sink.add([]); // Return empty list on timeout
          }).first;
        }
      }

      emit(PlayerStatsLoaded(user: event.user, history: history));
    } catch (e) {
      emit(PlayerStatsError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _userSubscription?.cancel();
    return super.close();
  }
}
