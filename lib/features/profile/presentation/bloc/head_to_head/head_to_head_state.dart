import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:play_with_me/core/data/models/head_to_head_stats.dart';

part 'head_to_head_state.freezed.dart';

@freezed
class HeadToHeadState with _$HeadToHeadState {
  const factory HeadToHeadState.initial() = HeadToHeadInitial;

  const factory HeadToHeadState.loading() = HeadToHeadLoading;

  const factory HeadToHeadState.loaded({
    required HeadToHeadStats stats,
  }) = HeadToHeadLoaded;

  const factory HeadToHeadState.error({
    required String message,
  }) = HeadToHeadError;
}
