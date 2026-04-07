// DTO returned by the getGameInvitationsForUser Cloud Function (Story 28.7).
// Enriched server-side with game, group, and inviter details.

/// Enriched game invitation returned by [getGameInvitationsForUser] CF.
class GameInvitationDetails {
  final String invitationId;
  final String gameId;
  final String groupId;
  final String inviterId;
  final String status;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final String gameTitle;
  final DateTime gameScheduledAt;
  final String gameLocationName;
  final String groupName;
  final String inviterDisplayName;

  const GameInvitationDetails({
    required this.invitationId,
    required this.gameId,
    required this.groupId,
    required this.inviterId,
    required this.status,
    required this.createdAt,
    this.expiresAt,
    required this.gameTitle,
    required this.gameScheduledAt,
    required this.gameLocationName,
    required this.groupName,
    required this.inviterDisplayName,
  });

  factory GameInvitationDetails.fromMap(Map<String, dynamic> map) {
    return GameInvitationDetails(
      invitationId: map['invitationId'] as String? ?? '',
      gameId: map['gameId'] as String? ?? '',
      groupId: map['groupId'] as String? ?? '',
      inviterId: map['inviterId'] as String? ?? '',
      status: map['status'] as String? ?? '',
      createdAt: DateTime.parse(map['createdAt'] as String? ?? DateTime.now().toIso8601String()),
      expiresAt: map['expiresAt'] != null
          ? DateTime.parse(map['expiresAt'] as String)
          : null,
      gameTitle: map['gameTitle'] as String? ?? '',
      gameScheduledAt: DateTime.parse(map['gameScheduledAt'] as String? ?? DateTime.now().toIso8601String()),
      gameLocationName: map['gameLocationName'] as String? ?? '',
      groupName: map['groupName'] as String? ?? '',
      inviterDisplayName: map['inviterDisplayName'] as String? ?? '',
    );
  }
}
