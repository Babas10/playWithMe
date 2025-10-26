// Mock repository for InvitationRepository used in testing
import 'dart:async';

import 'package:play_with_me/core/data/models/invitation_model.dart';
import 'package:play_with_me/core/domain/repositories/invitation_repository.dart';
import 'package:rxdart/rxdart.dart';

class MockInvitationRepository implements InvitationRepository {
  // Use BehaviorSubject for synchronous, deterministic emissions
  final BehaviorSubject<List<InvitationModel>> _invitationsController =
      BehaviorSubject<List<InvitationModel>>.seeded([]);
  final Map<String, Map<String, InvitationModel>> _invitationsByUser = {};
  String _lastCreatedInvitationId = '';

  MockInvitationRepository();

  BehaviorSubject<List<InvitationModel>> get invitationsController =>
      _invitationsController;

  // Helper methods for testing
  void addInvitation(InvitationModel invitation) {
    final userInvitations = _invitationsByUser[invitation.invitedUserId] ?? {};
    userInvitations[invitation.id] = invitation;
    _invitationsByUser[invitation.invitedUserId] = userInvitations;
    _emitInvitationsForUser(invitation.invitedUserId);
  }

  void clearInvitations() {
    _invitationsByUser.clear();
    _invitationsController.add([]);
  }

  void _emitInvitationsForUser(String userId) {
    if (!_invitationsController.isClosed) {
      final invitations = _invitationsByUser[userId]?.values.toList() ?? [];
      _invitationsController.add(invitations);
    }
  }

  void dispose() {
    _invitationsController.close();
  }

  List<InvitationModel> _getUserInvitations(String userId) {
    return _invitationsByUser[userId]?.values.toList() ?? [];
  }

  @override
  Future<String> sendInvitation({
    required String groupId,
    required String groupName,
    required String invitedUserId,
    required String invitedBy,
    required String inviterName,
  }) async {
    final invitationId =
        'invitation-${DateTime.now().millisecondsSinceEpoch}';
    final invitation = InvitationModel(
      id: invitationId,
      groupId: groupId,
      groupName: groupName,
      invitedUserId: invitedUserId,
      invitedBy: invitedBy,
      inviterName: inviterName,
      status: InvitationStatus.pending,
      createdAt: DateTime.now(),
    );

    addInvitation(invitation);
    _lastCreatedInvitationId = invitationId;
    return invitationId;
  }

  @override
  Stream<List<InvitationModel>> getPendingInvitations(String userId) async* {
    // Immediately yield the current value
    yield _getUserInvitations(userId)
        .where((inv) => inv.status == InvitationStatus.pending)
        .toList();

    // Then continue listening for future updates
    yield* _invitationsController.stream.map(
      (invitations) => invitations
          .where((inv) =>
              inv.invitedUserId == userId &&
              inv.status == InvitationStatus.pending)
          .toList(),
    );
  }

  @override
  Future<List<InvitationModel>> getInvitations(String userId) async {
    return _getUserInvitations(userId);
  }

  @override
  Future<InvitationModel?> getInvitationById({
    required String userId,
    required String invitationId,
  }) async {
    return _invitationsByUser[userId]?[invitationId];
  }

  @override
  Future<void> acceptInvitation({
    required String userId,
    required String invitationId,
  }) async {
    final invitation = _invitationsByUser[userId]?[invitationId];
    if (invitation == null) {
      throw Exception('Invitation not found');
    }

    final updatedInvitation = invitation.accept();
    _invitationsByUser[userId]![invitationId] = updatedInvitation;
    _emitInvitationsForUser(userId);
  }

  @override
  Future<void> declineInvitation({
    required String userId,
    required String invitationId,
  }) async {
    final invitation = _invitationsByUser[userId]?[invitationId];
    if (invitation == null) {
      throw Exception('Invitation not found');
    }

    final updatedInvitation = invitation.decline();
    _invitationsByUser[userId]![invitationId] = updatedInvitation;
    _emitInvitationsForUser(userId);
  }

  @override
  Future<void> deleteInvitation({
    required String userId,
    required String invitationId,
  }) async {
    _invitationsByUser[userId]?.remove(invitationId);
    _emitInvitationsForUser(userId);
  }

  @override
  Future<bool> hasPendingInvitation({
    required String userId,
    required String groupId,
  }) async {
    return _getUserInvitations(userId).any(
      (inv) =>
          inv.groupId == groupId && inv.status == InvitationStatus.pending,
    );
  }

  @override
  Future<List<InvitationModel>> getInvitationsSentByUser(String userId) async {
    return _invitationsByUser.values
        .expand((invitations) => invitations.values)
        .where((inv) => inv.invitedBy == userId)
        .toList();
  }

  @override
  Future<void> cancelInvitation({
    required String userId,
    required String invitationId,
  }) async {
    await deleteInvitation(userId: userId, invitationId: invitationId);
  }
}
