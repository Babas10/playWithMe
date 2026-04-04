import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:play_with_me/core/data/models/game_model.dart';

part 'game_invitation_model.freezed.dart';
part 'game_invitation_model.g.dart';

/// Status of a cross-group game invitation (Story 28.1)
enum GameInvitationStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('accepted')
  accepted,
  @JsonValue('declined')
  declined,
  @JsonValue('expired')
  expired,
}

/// Represents an invitation sent to a user outside the game's group (Story 28.1)
/// Stored in the `gameInvitations` Firestore collection.
/// Created and mutated exclusively via Cloud Functions (Admin SDK).
@freezed
class GameInvitationModel with _$GameInvitationModel {
  const factory GameInvitationModel({
    required String id,
    required String gameId,
    required String groupId,
    required String inviteeId,
    required String inviterId,
    @Default(GameInvitationStatus.pending) GameInvitationStatus status,
    @TimestampConverter() required DateTime createdAt,
    @TimestampConverter() DateTime? updatedAt,
    // Optional: when the invitation expires (set to game scheduledAt by CF)
    @TimestampConverter() DateTime? expiresAt,
  }) = _GameInvitationModel;

  const GameInvitationModel._();

  factory GameInvitationModel.fromJson(Map<String, dynamic> json) =>
      _$GameInvitationModelFromJson(json);

  /// Factory constructor for creating from Firestore DocumentSnapshot
  factory GameInvitationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final jsonData = Map<String, dynamic>.from(data);

    for (final field in ['createdAt', 'updatedAt', 'expiresAt']) {
      if (data[field] is Timestamp) {
        jsonData[field] = (data[field] as Timestamp).toDate().toIso8601String();
      }
    }

    return GameInvitationModel.fromJson({...jsonData, 'id': doc.id});
  }

  /// Whether this invitation is still actionable
  bool get isPending => status == GameInvitationStatus.pending;

  /// Whether the invitee accepted and is now a guest player
  bool get isAccepted => status == GameInvitationStatus.accepted;
}
