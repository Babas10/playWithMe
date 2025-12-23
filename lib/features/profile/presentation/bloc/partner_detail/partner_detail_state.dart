import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:play_with_me/core/data/models/teammate_stats.dart';
import 'package:play_with_me/core/data/models/user_model.dart';

part 'partner_detail_state.freezed.dart';

@freezed
class PartnerDetailState with _$PartnerDetailState {
  const factory PartnerDetailState.initial() = PartnerDetailInitial;

  const factory PartnerDetailState.loading() = PartnerDetailLoading;

  const factory PartnerDetailState.loaded({
    required TeammateStats stats,
    required UserModel partnerProfile,
  }) = PartnerDetailLoaded;

  const factory PartnerDetailState.error({
    required String message,
  }) = PartnerDetailError;
}
