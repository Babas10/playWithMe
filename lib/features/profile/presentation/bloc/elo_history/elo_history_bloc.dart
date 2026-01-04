import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:play_with_me/core/data/models/best_elo_record.dart';
import 'package:play_with_me/core/domain/repositories/user_repository.dart';
import 'package:play_with_me/core/data/models/rating_history_entry.dart';
import 'package:play_with_me/core/domain/entities/time_period.dart';
import 'elo_history_event.dart';
import 'elo_history_state.dart';

/// BLoC for managing ELO history screen state.
/// Provides full rating history with filtering and zoom capabilities.
class EloHistoryBloc extends Bloc<EloHistoryEvent, EloHistoryState> {
  final UserRepository userRepository;

  EloHistoryBloc({
    required this.userRepository,
  }) : super(const EloHistoryState.initial()) {
    on<LoadEloHistory>(_onLoadHistory);
    on<FilterByPeriod>(_onFilterByPeriod);
    on<FilterByDateRange>(_onFilterByDateRange);
    on<ClearFilter>(_onClearFilter);
  }

  Future<void> _onLoadHistory(
    LoadEloHistory event,
    Emitter<EloHistoryState> emit,
  ) async {
    emit(const EloHistoryState.loading());

    try {
      await emit.forEach<List<RatingHistoryEntry>>(
        userRepository.getRatingHistory(event.userId, limit: event.limit),
        onData: (history) {
          final bestElo = _calculateBestElo(history);
          return EloHistoryState.loaded(
            history: history,
            filteredHistory: history,
            filterStartDate: null,
            filterEndDate: null,
            bestEloInPeriod: bestElo,
          );
        },
        onError: (error, stackTrace) => EloHistoryState.error(
          message: 'Failed to load ELO history: ${error.toString()}',
        ),
      );
    } catch (e) {
      emit(EloHistoryState.error(
        message: 'Failed to load ELO history: ${e.toString()}',
      ));
    }
  }

  /// Handle filtering by time period (Story 302.3)
  void _onFilterByPeriod(
    FilterByPeriod event,
    Emitter<EloHistoryState> emit,
  ) {
    final currentState = state;
    if (currentState is! EloHistoryLoaded) return;

    final startDate = event.period.getStartDate();
    final endDate = DateTime.now();

    final filtered = currentState.history.where((entry) {
      return entry.timestamp.isAfter(startDate) &&
          entry.timestamp.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();

    // Calculate best ELO in filtered period (Story 302.6)
    final bestElo = _calculateBestElo(filtered);

    emit(EloHistoryState.loaded(
      history: currentState.history,
      filteredHistory: filtered,
      filterStartDate: startDate,
      filterEndDate: endDate,
      selectedPeriod: event.period,
      bestEloInPeriod: bestElo,
    ));
  }

  void _onFilterByDateRange(
    FilterByDateRange event,
    Emitter<EloHistoryState> emit,
  ) {
    final currentState = state;
    if (currentState is! EloHistoryLoaded) return;

    final filtered = currentState.history.where((entry) {
      final timestamp = entry.timestamp;
      return timestamp.isAfter(event.startDate) &&
          timestamp.isBefore(event.endDate.add(const Duration(days: 1)));
    }).toList();

    // Calculate best ELO in filtered period (Story 302.6)
    final bestElo = _calculateBestElo(filtered);

    emit(EloHistoryState.loaded(
      history: currentState.history,
      filteredHistory: filtered,
      filterStartDate: event.startDate,
      filterEndDate: event.endDate,
      selectedPeriod: currentState.selectedPeriod,
      bestEloInPeriod: bestElo,
    ));
  }

  void _onClearFilter(
    ClearFilter event,
    Emitter<EloHistoryState> emit,
  ) {
    final currentState = state;
    if (currentState is! EloHistoryLoaded) return;

    // Calculate best ELO for all-time (Story 302.6)
    final bestElo = _calculateBestElo(currentState.history);

    emit(EloHistoryState.loaded(
      history: currentState.history,
      filteredHistory: currentState.history,
      filterStartDate: null,
      filterEndDate: null,
      selectedPeriod: TimePeriod.allTime,
      bestEloInPeriod: bestElo,
    ));
  }

  /// Calculate the best ELO from a list of rating history entries.
  /// Returns null if the list is empty.
  BestEloRecord? _calculateBestElo(List<RatingHistoryEntry> entries) {
    if (entries.isEmpty) return null;

    final best = entries.reduce((a, b) =>
      a.newRating > b.newRating ? a : b
    );

    return BestEloRecord(
      elo: best.newRating,
      date: best.timestamp,
      gameId: best.gameId,
    );
  }
}
