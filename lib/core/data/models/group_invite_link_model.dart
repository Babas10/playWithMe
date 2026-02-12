import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:play_with_me/core/data/models/friendship_model.dart';

part 'group_invite_link_model.freezed.dart';
part 'group_invite_link_model.g.dart';

/// Data model for group invite links stored in Firestore.
///
/// Supports expiration, revocation, and optional usage limits.
///
/// Firestore collection: /groups/{groupId}/invites/{inviteId}
/// Token lookup collection: /invite_tokens/{token}
@freezed
class GroupInviteLinkModel with _$GroupInviteLinkModel {
  const factory GroupInviteLinkModel({
    required String id,
    required String token,
    required String createdBy,
    @RequiredTimestampConverter() required DateTime createdAt,
    @TimestampConverter() DateTime? expiresAt,
    @Default(false) bool revoked,
    int? usageLimit,
    @Default(0) int usageCount,
    required String groupId,
    @Default('group_link') String inviteType,
  }) = _GroupInviteLinkModel;

  const GroupInviteLinkModel._();

  factory GroupInviteLinkModel.fromJson(Map<String, dynamic> json) =>
      _$GroupInviteLinkModelFromJson(json);

  /// Factory constructor for creating from Firestore DocumentSnapshot
  factory GroupInviteLinkModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return GroupInviteLinkModel.fromJson({
      ...data,
      'id': doc.id,
    });
  }

  /// Convert to Firestore-compatible map (excludes id since it's the document ID)
  Map<String, dynamic> toFirestore() {
    final json = toJson();
    json.remove('id');
    return json;
  }

  /// Whether the invite has expired based on expiresAt timestamp
  bool get isExpired => expiresAt != null && expiresAt!.isBefore(DateTime.now());

  /// Whether the invite has been manually revoked
  bool get isRevoked => revoked;

  /// Whether the usage limit has been reached
  bool get isUsageLimitReached =>
      usageLimit != null && usageCount >= usageLimit!;

  /// Whether the invite is currently active (not expired, not revoked, not at limit)
  bool get isActive => !isExpired && !isRevoked && !isUsageLimitReached;

  /// Number of remaining uses, or null if unlimited
  int? get remainingUses =>
      usageLimit != null ? usageLimit! - usageCount : null;
}
