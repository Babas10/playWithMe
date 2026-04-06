// DTO returned by getInvitablePlayersForGame Cloud Function (Story 28.3).
// Simple class — not freezed, as it is never persisted to Firestore.

class InvitablePlayerModel {
  final String uid;
  final String displayName;
  final String? photoUrl;
  final String sourceGroupId;
  final String sourceGroupName;

  const InvitablePlayerModel({
    required this.uid,
    required this.displayName,
    this.photoUrl,
    required this.sourceGroupId,
    required this.sourceGroupName,
  });

  factory InvitablePlayerModel.fromMap(Map<String, dynamic> map) {
    return InvitablePlayerModel(
      uid: map['uid'] as String,
      displayName: map['displayName'] as String? ?? '',
      photoUrl: map['photoUrl'] as String?,
      sourceGroupId: map['sourceGroupId'] as String,
      sourceGroupName: map['sourceGroupName'] as String,
    );
  }
}
