import 'package:freezed_annotation/freezed_annotation.dart';

part 'partner_detail_event.freezed.dart';

@freezed
class PartnerDetailEvent with _$PartnerDetailEvent {
  const factory PartnerDetailEvent.loadPartnerDetails({
    required String userId,
    required String partnerId,
  }) = LoadPartnerDetails;
}
