// Repository interface for game guest invitation operations (Epic 28).
import '../../data/models/invitable_player_model.dart';

abstract class GameGuestInvitationRepository {
  /// Returns users eligible to be invited as guest players for [gameId].
  /// Calls the `getInvitablePlayersForGame` Cloud Function (Story 28.3).
  Future<List<InvitablePlayerModel>> getInvitablePlayers(String gameId);

  /// Sends a guest invitation for [inviteeId] to join [gameId].
  /// Calls the `inviteGuestToGame` Cloud Function (Story 28.2).
  /// Returns the created invitation document ID.
  Future<String> inviteGuestPlayer({
    required String gameId,
    required String inviteeId,
  });
}
