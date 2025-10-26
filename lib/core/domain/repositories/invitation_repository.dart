import '../../data/models/invitation_model.dart';

abstract class InvitationRepository {
  /// Send an invitation to a user to join a group
  /// Returns the invitation ID
  Future<String> sendInvitation({
    required String groupId,
    required String groupName,
    required String invitedUserId,
    required String invitedBy,
    required String inviterName,
  });

  /// Get all pending invitations for a user
  Stream<List<InvitationModel>> getPendingInvitations(String userId);

  /// Get all invitations for a user (any status)
  Future<List<InvitationModel>> getInvitations(String userId);

  /// Get a specific invitation by ID
  Future<InvitationModel?> getInvitationById({
    required String userId,
    required String invitationId,
  });

  /// Accept an invitation
  /// - Updates invitation status to accepted
  /// - Adds user to group members
  Future<void> acceptInvitation({
    required String userId,
    required String invitationId,
  });

  /// Decline an invitation
  /// - Updates invitation status to declined
  Future<void> declineInvitation({
    required String userId,
    required String invitationId,
  });

  /// Delete an invitation
  Future<void> deleteInvitation({
    required String userId,
    required String invitationId,
  });

  /// Check if user has pending invitation for a group
  Future<bool> hasPendingInvitation({
    required String userId,
    required String groupId,
  });

  /// Get all invitations sent by a user
  Future<List<InvitationModel>> getInvitationsSentByUser(String userId);

  /// Cancel an invitation (admin only)
  Future<void> cancelInvitation({
    required String userId,
    required String invitationId,
  });
}
