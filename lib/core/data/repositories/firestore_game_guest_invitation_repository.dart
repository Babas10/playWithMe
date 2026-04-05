// Firestore-backed implementation of GameGuestInvitationRepository (Epic 28).
// All mutations go through Cloud Functions — no direct Firestore writes.

import 'package:cloud_functions/cloud_functions.dart';

import '../../domain/exceptions/repository_exceptions.dart';
import '../../domain/repositories/game_guest_invitation_repository.dart';
import '../models/invitable_player_model.dart';

class FirestoreGameGuestInvitationRepository
    implements GameGuestInvitationRepository {
  final FirebaseFunctions _functions;

  FirestoreGameGuestInvitationRepository({FirebaseFunctions? functions})
      : _functions = functions ??
            FirebaseFunctions.instanceFor(region: 'europe-west6');

  @override
  Future<List<InvitablePlayerModel>> getInvitablePlayers(String gameId) async {
    try {
      final callable =
          _functions.httpsCallable('getInvitablePlayersForGame');
      final result = await callable.call({'gameId': gameId});

      final data = result.data as Map<String, dynamic>;
      final players = (data['players'] as List<dynamic>? ?? [])
          .cast<Map<String, dynamic>>()
          .map(InvitablePlayerModel.fromMap)
          .toList();
      return players;
    } on FirebaseFunctionsException catch (e) {
      throw GameInvitationException(
        _mapFunctionsError(e),
        code: e.code,
      );
    } catch (e) {
      throw GameInvitationException(
          'Failed to load invitable players: $e');
    }
  }

  @override
  Future<String> inviteGuestPlayer({
    required String gameId,
    required String inviteeId,
  }) async {
    try {
      final callable = _functions.httpsCallable('inviteGuestToGame');
      final result = await callable.call({
        'gameId': gameId,
        'inviteeId': inviteeId,
      });

      final data = result.data as Map<String, dynamic>;
      return data['invitationId'] as String;
    } on FirebaseFunctionsException catch (e) {
      throw GameInvitationException(
        _mapFunctionsError(e),
        code: e.code,
      );
    } catch (e) {
      throw GameInvitationException('Failed to send invitation: $e');
    }
  }

  String _mapFunctionsError(FirebaseFunctionsException e) {
    switch (e.code) {
      case 'unauthenticated':
        return 'You must be logged in to perform this action';
      case 'permission-denied':
        return e.message ?? 'You don\'t have permission for this action';
      case 'not-found':
        return e.message ?? 'Game or player not found';
      case 'already-exists':
        return e.message ?? 'Invitation already exists';
      case 'invalid-argument':
        return e.message ?? 'Invalid parameters';
      default:
        return e.message ?? 'An unexpected error occurred';
    }
  }
}
