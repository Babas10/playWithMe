/// Repository interface for group invite link operations.
///
/// All methods call Cloud Functions (createGroupInvite, revokeGroupInvite)
/// to generate shareable invite links and manage their lifecycle.
abstract class GroupInviteLinkRepository {
  /// Creates a new group invite link by calling the createGroupInvite Cloud Function.
  ///
  /// Returns a record with the invite ID, token, and deep link URL.
  /// Throws [GroupInviteLinkException] on failure.
  Future<({String inviteId, String token, String deepLinkUrl})>
      createGroupInvite({
    required String groupId,
    int? expiresInHours,
    int? usageLimit,
  });

  /// Revokes an existing group invite link by calling the revokeGroupInvite Cloud Function.
  ///
  /// Throws [GroupInviteLinkException] on failure.
  Future<void> revokeGroupInvite({
    required String groupId,
    required String inviteId,
  });
}
