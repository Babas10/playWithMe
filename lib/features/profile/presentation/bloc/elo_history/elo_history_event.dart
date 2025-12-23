import 'package:freezed_annotation/freezed_annotation.dart';

part 'elo_history_event.freezed.dart';

@freezed
class EloHistoryEvent with _$EloHistoryEvent {
  const factory EloHistoryEvent.loadHistory({
    required String userId,
    @Default(100) int limit,
  }) = LoadEloHistory;

  const factory EloHistoryEvent.filterByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) = FilterByDateRange;

  const factory EloHistoryEvent.clearFilter() = ClearFilter;
}
