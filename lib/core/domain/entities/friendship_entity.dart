import 'package:freezed_annotation/freezed_annotation.dart';

part 'friendship_entity.freezed.dart';

/// Domain entity representing a friendship relationship between two users.
///
/// This entity represents the core friendship concept in the social graph.
/// Status transitions: pending → accepted, pending → declined
/// Declined friendships are kept for audit trail.
@freezed
class FriendshipEntity with _$FriendshipEntity {
  const factory FriendshipEntity({
    required String id,
    required String initiatorId,
    required String recipientId,
    required FriendshipStatus status,
    required DateTime createdAt,
    required DateTime updatedAt,
    required String initiatorName,
    required String recipientName,
  }) = _FriendshipEntity;

  const FriendshipEntity._();

  /// Check if friendship is pending
  bool get isPending => status == FriendshipStatus.pending;

  /// Check if friendship is accepted
  bool get isAccepted => status == FriendshipStatus.accepted;

  /// Check if friendship is declined
  bool get isDeclined => status == FriendshipStatus.declined;

  /// Check if user is the initiator
  bool isInitiator(String userId) => initiatorId == userId;

  /// Check if user is the recipient
  bool isRecipient(String userId) => recipientId == userId;

  /// Check if user is involved in this friendship
  bool involves(String userId) => initiatorId == userId || recipientId == userId;

  /// Get the other user's ID given one user's ID
  String? getOtherUserId(String userId) {
    if (initiatorId == userId) return recipientId;
    if (recipientId == userId) return initiatorId;
    return null;
  }

  /// Get the other user's name given one user's ID
  String? getOtherUserName(String userId) {
    if (initiatorId == userId) return recipientName;
    if (recipientId == userId) return initiatorName;
    return null;
  }

  /// Check if friendship can be accepted (must be pending and user must be recipient)
  bool canBeAcceptedBy(String userId) {
    return isPending && recipientId == userId;
  }

  /// Check if friendship can be declined (must be pending and user must be recipient)
  bool canBeDeclinedBy(String userId) {
    return isPending && recipientId == userId;
  }

  /// Check if friendship can be cancelled (must be pending and user must be initiator)
  bool canBeCancelledBy(String userId) {
    return isPending && initiatorId == userId;
  }
}

/// Enum representing the status of a friendship
enum FriendshipStatus {
  /// Friend request is pending acceptance
  @JsonValue('pending')
  pending,

  /// Friend request has been accepted
  @JsonValue('accepted')
  accepted,

  /// Friend request has been declined
  @JsonValue('declined')
  declined,
}
