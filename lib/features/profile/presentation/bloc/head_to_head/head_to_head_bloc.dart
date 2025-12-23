import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:play_with_me/core/domain/repositories/user_repository.dart';
import 'package:play_with_me/core/data/models/head_to_head_stats.dart';
import 'package:play_with_me/core/data/models/user_model.dart';
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
      // Fetch head-to-head stats and opponent profile in parallel
      final results = await Future.wait([
        userRepository.getHeadToHeadStats(event.userId, event.opponentId),
        userRepository.getUserById(event.opponentId),
      ]);

      final stats = results[0] as HeadToHeadStats?;
      final opponentProfile = results[1] as UserModel?;

      if (stats == null) {
        emit(const HeadToHeadState.error(
          message: 'No head-to-head statistics found for this opponent',
        ));
        return;
      }

      if (opponentProfile == null) {
        emit(const HeadToHeadState.error(
          message: 'Opponent profile not found',
        ));
        return;
      }

      emit(HeadToHeadState.loaded(
        stats: stats,
        opponentProfile: opponentProfile,
      ));
    } catch (e) {
      emit(HeadToHeadState.error(
        message: 'Failed to load head-to-head details: ${e.toString()}',
      ));
    }
  }
}
