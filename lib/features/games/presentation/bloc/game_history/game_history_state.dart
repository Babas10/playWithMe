// Manages state for game history page with pagination (Story 14.7)

import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../../core/data/models/game_model.dart';

part 'game_history_state.freezed.dart';

enum GameHistoryFilter {
  all,     // All group games
  myGames, // Only games user played in
}

@freezed
class GameHistoryState with _$GameHistoryState {
  const factory GameHistoryState.initial() = GameHistoryInitial;

  const factory GameHistoryState.loading() = GameHistoryLoading;

  const factory GameHistoryState.loaded({
    required List<GameModel> games,
    required bool hasMore,
    required GameHistoryFilter currentFilter,
    DateTime? startDate,
    DateTime? endDate,
    @Default(false) bool isLoadingMore,
  }) = GameHistoryLoaded;

  const factory GameHistoryState.error({
    required String message,
    GameHistoryFilter? lastFilter,
  }) = GameHistoryError;
}
