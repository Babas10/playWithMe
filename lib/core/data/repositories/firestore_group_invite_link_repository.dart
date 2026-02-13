// Firestore implementation of GroupInviteLinkRepository.
// Calls Cloud Functions for invite link creation and revocation.
import 'package:cloud_functions/cloud_functions.dart';
import 'package:play_with_me/core/domain/exceptions/repository_exceptions.dart';
import 'package:play_with_me/core/domain/repositories/group_invite_link_repository.dart';

class FirestoreGroupInviteLinkRepository implements GroupInviteLinkRepository {
  final FirebaseFunctions _functions;

  FirestoreGroupInviteLinkRepository({
    required FirebaseFunctions functions,
  }) : _functions = functions;

  @override
  Future<({String inviteId, String token, String deepLinkUrl})>
      createGroupInvite({
    required String groupId,
    int? expiresInHours,
    int? usageLimit,
  }) async {
    try {
      final callable = _functions.httpsCallable('createGroupInvite');
      final params = <String, dynamic>{
        'groupId': groupId,
      };
      if (expiresInHours != null) {
        params['expiresInHours'] = expiresInHours;
      }
      if (usageLimit != null) {
        params['usageLimit'] = usageLimit;
      }

      final result = await callable.call(params);
      final data = Map<String, dynamic>.from(result.data as Map);

      return (
        inviteId: data['inviteId'] as String,
        token: data['token'] as String,
        deepLinkUrl: data['deepLinkUrl'] as String,
      );
    } on FirebaseFunctionsException catch (e) {
      throw _handleError(e);
    } catch (e) {
      throw GroupInviteLinkException(
          'Failed to create invite link: $e');
    }
  }

  @override
  Future<void> revokeGroupInvite({
    required String groupId,
    required String inviteId,
  }) async {
    try {
      final callable = _functions.httpsCallable('revokeGroupInvite');
      await callable.call({
        'groupId': groupId,
        'inviteId': inviteId,
      });
    } on FirebaseFunctionsException catch (e) {
      throw _handleError(e);
    } catch (e) {
      throw GroupInviteLinkException(
          'Failed to revoke invite link: $e');
    }
  }

  GroupInviteLinkException _handleError(FirebaseFunctionsException e) {
    switch (e.code) {
      case 'not-found':
        return GroupInviteLinkException(
          e.message ?? 'Resource not found',
          code: e.code,
        );
      case 'permission-denied':
        return GroupInviteLinkException(
          e.message ?? 'You do not have permission to perform this action',
          code: e.code,
        );
      case 'unauthenticated':
        return GroupInviteLinkException(
          'You must be logged in to perform this action',
          code: e.code,
        );
      case 'invalid-argument':
        return GroupInviteLinkException(
          e.message ?? 'Invalid input provided',
          code: e.code,
        );
      case 'already-exists':
        return GroupInviteLinkException(
          e.message ?? 'This invite is already revoked',
          code: e.code,
        );
      case 'failed-precondition':
        return GroupInviteLinkException(
          e.message ?? 'Cannot complete this action right now',
          code: e.code,
        );
      default:
        return GroupInviteLinkException(
          e.message ?? 'An error occurred. Please try again.',
          code: e.code,
        );
    }
  }
}
