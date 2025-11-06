import 'package:freezed_annotation/freezed_annotation.dart';

part 'friendship_entity.freezed.dart';
part 'friendship_entity.g.dart';

/// Represents a friendship relationship between two users
@freezed
class FriendshipEntity with _$FriendshipEntity {
  const factory FriendshipEntity({
    required String id,
    required String initiatorId,
    required String recipientId,
    required String initiatorName,
    required String recipientName,
    required FriendshipStatus status,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _FriendshipEntity;

  factory FriendshipEntity.fromJson(Map<String, dynamic> json) =>
      _$FriendshipEntityFromJson(json);
}

/// Status of a friendship
enum FriendshipStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('accepted')
  accepted,
  @JsonValue('declined')
  declined,
}
