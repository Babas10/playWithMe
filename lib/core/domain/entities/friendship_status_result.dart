import 'package:freezed_annotation/freezed_annotation.dart';

part 'friendship_status_result.freezed.dart';
part 'friendship_status_result.g.dart';

/// Result of checking friendship status with a specific user
@freezed
class FriendshipStatusResult with _$FriendshipStatusResult {
  const factory FriendshipStatusResult({
    required bool isFriend,
    required bool hasPendingRequest,
    String? requestDirection, // 'sent' | 'received'
    String? friendshipId,
  }) = _FriendshipStatusResult;

  factory FriendshipStatusResult.fromJson(Map<String, dynamic> json) =>
      _$FriendshipStatusResultFromJson(json);
}
