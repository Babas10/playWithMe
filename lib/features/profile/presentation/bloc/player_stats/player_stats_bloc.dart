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

    await _userSubscription?.cancel();
    _userSubscription = _userRepository.getUserStream(event.userId).listen(
      (user) {
        if (user != null) {
          add(UpdateUserStats(user));
        }
      },
      onError: (error) {
        // We can't easily emit from here, but the error will be handled locally or logged.
        // For now, we assume the stream might have transient errors or the bloc will error on initial fetch if needed.
        // But UpdateUserStats is the main way to update state.
      },
    );

    try {
      // Fetch history initially.
      // Note: We wait for the first stream event to actually emit "Loaded",
      // but we can fetch history in parallel or inside the listener.
      // However, since we need BOTH to be Loaded, it's better to fetch history here
      // and maybe store it, but UpdateUserStats is what drives the UI.
      // Actually, let's fetch history and emit it when we get the user.
      // Or better: The stream gives us the user. We need to pair it with history.
      // Since history doesn't change as often (only on game complete), maybe we fetch it once?
      // Or we should reload history when user stats change (e.g. gamesPlayed increments).

      // For simplicity, let's just fetch history once on load.
      // Real-time history updates might require a stream for history too, but that's expensive.
      // The user model has 'recentGameIds', so if that changes, we could re-fetch history.

      // We'll rely on the stream listener to trigger updates, but we need to hold the history.
      // The state object holds both.
    } catch (e) {
      emit(PlayerStatsError(e.toString()));
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
        history = await _userRepository.getRatingHistory(event.user.uid).first;
      } else {
        // Check if we need to refresh history (simple check: gamesPlayed count)
        // If state.user.gamesPlayed < event.user.gamesPlayed, then a new game finished.
        if (state is PlayerStatsLoaded &&
            (state as PlayerStatsLoaded).user.gamesPlayed < event.user.gamesPlayed) {
             history = await _userRepository.getRatingHistory(event.user.uid).first;
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
