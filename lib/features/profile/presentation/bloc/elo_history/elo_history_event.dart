import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:play_with_me/core/domain/entities/time_period.dart';

part 'elo_history_event.freezed.dart';

@freezed
class EloHistoryEvent with _$EloHistoryEvent {
  const factory EloHistoryEvent.loadHistory({
    required String userId,
    @Default(100) int limit,
  }) = LoadEloHistory;

  /// Filter history by time period (Story 302.3)
  const factory EloHistoryEvent.filterByPeriod(TimePeriod period) =
      FilterByPeriod;

  const factory EloHistoryEvent.filterByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) = FilterByDateRange;

  const factory EloHistoryEvent.clearFilter() = ClearFilter;
}
