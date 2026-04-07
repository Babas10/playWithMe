// Firestore-backed implementation of GameInvitationsRepository (Story 28.7).
// All operations are delegated to Cloud Functions via the Admin SDK.

import 'package:cloud_functions/cloud_functions.dart';
import 'package:play_with_me/core/data/models/game_invitation_details.dart';
import 'package:play_with_me/core/domain/exceptions/repository_exceptions.dart';
import 'package:play_with_me/core/domain/repositories/game_invitations_repository.dart';

class FirestoreGameInvitationsRepository implements GameInvitationsRepository {
  final FirebaseFunctions _functions;

  FirestoreGameInvitationsRepository({FirebaseFunctions? functions})
      : _functions =
            functions ?? FirebaseFunctions.instanceFor(region: 'europe-west6');

  @override
  Future<List<GameInvitationDetails>> getGameInvitations() async {
    try {
      final callable =
          _functions.httpsCallable('getGameInvitationsForUser');
      final result = await callable.call<Map<String, dynamic>>();
      final data = Map<String, dynamic>.from(result.data as Map);
      final raw = data['invitations'] as List<dynamic>;
      return raw
          .map((e) => Map<String, dynamic>.from(e as Map))
          .map(GameInvitationDetails.fromMap)
          .toList();
    } on FirebaseFunctionsException catch (e) {
      throw GameInvitationException(
        e.message ?? 'Failed to load game invitations',
        code: e.code,
      );
    } catch (e) {
      throw GameInvitationException('Failed to load game invitations: $e');
    }
  }

  @override
  Future<void> acceptGameInvitation(String invitationId) async {
    try {
      final callable =
          _functions.httpsCallable('acceptGameGuestInvitation');
      await callable.call<Map<String, dynamic>>({'invitationId': invitationId});
    } on FirebaseFunctionsException catch (e) {
      throw GameInvitationException(
        e.message ?? 'Failed to accept game invitation',
        code: e.code,
      );
    } catch (e) {
      throw GameInvitationException('Failed to accept game invitation: $e');
    }
  }

  @override
  Future<void> declineGameInvitation(String invitationId) async {
    try {
      final callable =
          _functions.httpsCallable('declineGameGuestInvitation');
      await callable.call<Map<String, dynamic>>({'invitationId': invitationId});
    } on FirebaseFunctionsException catch (e) {
      throw GameInvitationException(
        e.message ?? 'Failed to decline game invitation',
        code: e.code,
      );
    } catch (e) {
      throw GameInvitationException('Failed to decline game invitation: $e');
    }
  }
}
