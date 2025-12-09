// Events for game history page (Story 14.7)

import 'package:freezed_annotation/freezed_annotation.dart';

import 'game_history_state.dart';

part 'game_history_event.freezed.dart';

@freezed
class GameHistoryEvent with _$GameHistoryEvent {
  /// Load initial game history
  const factory GameHistoryEvent.load({
    String? groupId,
    required String userId,
    @Default(GameHistoryFilter.all) GameHistoryFilter filter,
    DateTime? startDate,
    DateTime? endDate,
  }) = GameHistoryLoadEvent;

  /// Load more games (pagination)
  const factory GameHistoryEvent.loadMore() = GameHistoryLoadMoreEvent;

  /// Refresh game history (pull-to-refresh)
  const factory GameHistoryEvent.refresh() = GameHistoryRefreshEvent;

  /// Apply filter
  const factory GameHistoryEvent.filterChanged({
    required GameHistoryFilter filter,
  }) = GameHistoryFilterChangedEvent;

  /// Apply date range filter
  const factory GameHistoryEvent.dateRangeChanged({
    DateTime? startDate,
    DateTime? endDate,
  }) = GameHistoryDateRangeChangedEvent;
}
