import 'package:freezed_annotation/freezed_annotation.dart';

part 'head_to_head_event.freezed.dart';

@freezed
class HeadToHeadEvent with _$HeadToHeadEvent {
  const factory HeadToHeadEvent.loadHeadToHead({
    required String userId,
    required String opponentId,
  }) = LoadHeadToHead;
}
