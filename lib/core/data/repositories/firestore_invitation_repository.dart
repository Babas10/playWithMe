import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

import '../../domain/repositories/group_repository.dart';
import '../../domain/repositories/invitation_repository.dart';
import '../models/invitation_model.dart';

class FirestoreInvitationRepository implements InvitationRepository {
  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions;

  static const String _usersCollection = 'users';
  static const String _invitationsSubcollection = 'invitations';

  FirestoreInvitationRepository({
    FirebaseFirestore? firestore,
    FirebaseFunctions? functions,
    GroupRepository? groupRepository,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _functions = functions ?? FirebaseFunctions.instance;

  @override
  Future<String> sendInvitation({
    required String groupId,
    required String groupName,
    required String invitedUserId,
    required String invitedBy,
    required String inviterName,
  }) async {
    try {
      // Note: Duplicate check is now handled in the UI layer via Cloud Function
      // (checkPendingInvitation) before calling this method for better security

      // Create invitation
      final invitation = InvitationModel(
        id: '', // Will be set by Firestore
        groupId: groupId,
        groupName: groupName,
        invitedUserId: invitedUserId,
        invitedBy: invitedBy,
        inviterName: inviterName,
        status: InvitationStatus.pending,
        createdAt: DateTime.now(),
      );

      final docRef = await _firestore
          .collection(_usersCollection)
          .doc(invitedUserId)
          .collection(_invitationsSubcollection)
          .add(invitation.toFirestore());

      return docRef.id;
    } catch (e) {
      throw Exception('Failed to send invitation: $e');
    }
  }

  @override
  Stream<List<InvitationModel>> getPendingInvitations(String userId) {
    try {
      return _firestore
          .collection(_usersCollection)
          .doc(userId)
          .collection(_invitationsSubcollection)
          .where('status', isEqualTo: 'pending')
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .where((doc) => doc.exists)
            .map((doc) => InvitationModel.fromFirestore(doc))
            .toList();
      });
    } catch (e) {
      throw Exception('Failed to get pending invitations: $e');
    }
  }

  @override
  Future<List<InvitationModel>> getInvitations(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .collection(_invitationsSubcollection)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .where((doc) => doc.exists)
          .map((doc) => InvitationModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get invitations: $e');
    }
  }

  @override
  Future<InvitationModel?> getInvitationById({
    required String userId,
    required String invitationId,
  }) async {
    try {
      final doc = await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .collection(_invitationsSubcollection)
          .doc(invitationId)
          .get();

      return doc.exists ? InvitationModel.fromFirestore(doc) : null;
    } catch (e) {
      throw Exception('Failed to get invitation: $e');
    }
  }

  @override
  Future<void> acceptInvitation({
    required String userId,
    required String invitationId,
  }) async {
    try {
      // Use Cloud Function for secure invitation acceptance
      // This bypasses Firestore security rules and ensures atomic operation
      final callable = _functions.httpsCallable('acceptInvitation');
      await callable.call({
        'invitationId': invitationId,
      });
    } on FirebaseFunctionsException catch (e) {
      throw Exception('Failed to accept invitation: ${e.message ?? e.code}');
    } catch (e) {
      throw Exception('Failed to accept invitation: $e');
    }
  }

  @override
  Future<void> declineInvitation({
    required String userId,
    required String invitationId,
  }) async {
    try {
      // Use Cloud Function for secure invitation decline
      final callable = _functions.httpsCallable('declineInvitation');
      await callable.call({
        'invitationId': invitationId,
      });
    } on FirebaseFunctionsException catch (e) {
      throw Exception('Failed to decline invitation: ${e.message ?? e.code}');
    } catch (e) {
      throw Exception('Failed to decline invitation: $e');
    }
  }

  @override
  Future<void> deleteInvitation({
    required String userId,
    required String invitationId,
  }) async {
    try {
      await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .collection(_invitationsSubcollection)
          .doc(invitationId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete invitation: $e');
    }
  }

  @override
  Future<bool> hasPendingInvitation({
    required String userId,
    required String groupId,
  }) async {
    try {
      final snapshot = await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .collection(_invitationsSubcollection)
          .where('groupId', isEqualTo: groupId)
          .where('status', isEqualTo: 'pending')
          .limit(1)
          .get();

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      throw Exception('Failed to check pending invitation: $e');
    }
  }

  @override
  Future<List<InvitationModel>> getInvitationsSentByUser(String userId) async {
    try {
      // This would require a different schema or collection structure
      // For now, we'll query all users' invitations where invitedBy == userId
      // Note: This is inefficient and should use a separate collection in production
      // This is a simplified implementation
      throw UnimplementedError(
          'Getting invitations sent by user requires different schema');
    } catch (e) {
      throw Exception('Failed to get invitations sent by user: $e');
    }
  }

  @override
  Future<void> cancelInvitation({
    required String userId,
    required String invitationId,
  }) async {
    try {
      // For now, canceling is the same as deleting
      await deleteInvitation(
        userId: userId,
        invitationId: invitationId,
      );
    } catch (e) {
      throw Exception('Failed to cancel invitation: $e');
    }
  }
}
