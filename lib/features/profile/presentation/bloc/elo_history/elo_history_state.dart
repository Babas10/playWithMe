import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:play_with_me/core/data/models/rating_history_entry.dart';
import 'package:play_with_me/core/domain/entities/time_period.dart';

part 'elo_history_state.freezed.dart';

@freezed
class EloHistoryState with _$EloHistoryState {
  const factory EloHistoryState.initial() = EloHistoryInitial;

  const factory EloHistoryState.loading() = EloHistoryLoading;

  const factory EloHistoryState.loaded({
    required List<RatingHistoryEntry> history,
    required List<RatingHistoryEntry> filteredHistory,
    DateTime? filterStartDate,
    DateTime? filterEndDate,
    @Default(TimePeriod.allTime) TimePeriod selectedPeriod,
  }) = EloHistoryLoaded;

  const factory EloHistoryState.error({
    required String message,
  }) = EloHistoryError;
}
