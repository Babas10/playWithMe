import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:play_with_me/core/domain/repositories/user_repository.dart';
import 'package:play_with_me/core/data/models/teammate_stats.dart';
import 'package:play_with_me/core/data/models/user_model.dart';
import 'partner_detail_event.dart';
import 'partner_detail_state.dart';

/// BLoC for managing partner detail screen state.
/// Fetches comprehensive statistics for a specific teammate.
class PartnerDetailBloc extends Bloc<PartnerDetailEvent, PartnerDetailState> {
  final UserRepository userRepository;

  PartnerDetailBloc({
    required this.userRepository,
  }) : super(const PartnerDetailState.initial()) {
    on<LoadPartnerDetails>(_onLoadPartnerDetails);
  }

  Future<void> _onLoadPartnerDetails(
    LoadPartnerDetails event,
    Emitter<PartnerDetailState> emit,
  ) async {
    emit(const PartnerDetailState.loading());

    try {
      // Fetch teammate stats and partner profile in parallel
      final results = await Future.wait([
        userRepository.getTeammateStats(event.userId, event.partnerId),
        userRepository.getUserById(event.partnerId),
      ]);

      final stats = results[0] as TeammateStats?;
      final partnerProfile = results[1] as UserModel?;

      if (stats == null) {
        emit(const PartnerDetailState.error(
          message: 'No statistics found for this partner',
        ));
        return;
      }

      if (partnerProfile == null) {
        emit(const PartnerDetailState.error(
          message: 'Partner profile not found',
        ));
        return;
      }

      emit(PartnerDetailState.loaded(
        stats: stats,
        partnerProfile: partnerProfile,
      ));
    } catch (e) {
      emit(PartnerDetailState.error(
        message: 'Failed to load partner details: ${e.toString()}',
      ));
    }
  }
}
