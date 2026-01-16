import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:play_with_me/core/domain/repositories/user_repository.dart';
import 'head_to_head_event.dart';
import 'head_to_head_state.dart';

/// BLoC for managing head-to-head rivalry screen state.
/// Fetches comprehensive statistics against a specific opponent.
class HeadToHeadBloc extends Bloc<HeadToHeadEvent, HeadToHeadState> {
  final UserRepository userRepository;

  HeadToHeadBloc({
    required this.userRepository,
  }) : super(const HeadToHeadState.initial()) {
    on<LoadHeadToHead>(_onLoadHeadToHead);
  }

  Future<void> _onLoadHeadToHead(
    LoadHeadToHead event,
    Emitter<HeadToHeadState> emit,
  ) async {
    emit(const HeadToHeadState.loading());

    try {
      // Fetch head-to-head stats (opponent info is cached in the stats document)
      final stats = await userRepository.getHeadToHeadStats(
        event.userId,
        event.opponentId,
      );

      if (stats == null) {
        emit(const HeadToHeadState.error(
          message: 'No head-to-head statistics found for this opponent',
        ));
        return;
      }

      emit(HeadToHeadState.loaded(stats: stats));
    } catch (e) {
      emit(HeadToHeadState.error(
        message: 'Failed to load head-to-head details: ${e.toString()}',
      ));
    }
  }
}
