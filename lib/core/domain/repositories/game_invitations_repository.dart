// Repository interface for game guest invitations (Story 28.7).
// Covers fetching the invitee's pending invitations and accepting / declining them.

import 'package:play_with_me/core/data/models/game_invitation_details.dart';

abstract class GameInvitationsRepository {
  /// Returns all pending game invitations for the authenticated user,
  /// enriched with game, group, and inviter details.
  Future<List<GameInvitationDetails>> getGameInvitations();

  /// Accepts the invitation with [invitationId].
  /// Adds the user as a guest player on the game.
  Future<void> acceptGameInvitation(String invitationId);

  /// Declines the invitation with [invitationId].
  Future<void> declineGameInvitation(String invitationId);
}
