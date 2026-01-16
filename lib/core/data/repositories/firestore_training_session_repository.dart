import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

import '../../domain/exceptions/repository_exceptions.dart';
import '../../domain/repositories/group_repository.dart';
import '../../domain/repositories/training_session_repository.dart';
import '../models/game_model.dart';
import '../models/training_session_model.dart';
import '../models/training_session_participant_model.dart';

/// Firestore implementation of TrainingSessionRepository
///
/// ARCHITECTURE: This repository operates in the Games layer
/// - ✅ Uses Cloud Function for creation (server-side validation)
/// - ✅ Validates group membership via Cloud Function (not direct Firestore)
/// - ❌ Never imports FriendRepository or My Community code
/// - Participants are resolved via group.memberIds only
class FirestoreTrainingSessionRepository implements TrainingSessionRepository {
  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions;
  final GroupRepository _groupRepository;

  static const String _collection = 'trainingSessions';

  FirestoreTrainingSessionRepository({
    FirebaseFirestore? firestore,
    FirebaseFunctions? functions,
    required GroupRepository groupRepository,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _functions = functions ?? FirebaseFunctions.instance,
        _groupRepository = groupRepository;

  @override
  Future<TrainingSessionModel?> getTrainingSessionById(String sessionId) async {
    try {
      final doc =
          await _firestore.collection(_collection).doc(sessionId).get();
      return doc.exists ? TrainingSessionModel.fromFirestore(doc) : null;
    } on FirebaseException catch (e) {
      throw TrainingSessionException(
          'Failed to get training session: ${e.message}',
          code: e.code);
    } catch (e) {
      throw TrainingSessionException('Failed to get training session: $e',
          code: 'unknown');
    }
  }

  @override
  Stream<TrainingSessionModel?> getTrainingSessionStream(String sessionId) {
    try {
      return _firestore
          .collection(_collection)
          .doc(sessionId)
          .snapshots()
          .map((snapshot) => snapshot.exists
              ? TrainingSessionModel.fromFirestore(snapshot)
              : null)
          .handleError((error) {
        if (error is FirebaseException) {
          throw TrainingSessionException(
              'Failed to stream training session: ${error.message}',
              code: error.code);
        }
        throw TrainingSessionException(
            'Failed to stream training session: $error',
            code: 'stream-error');
      });
    } catch (e) {
      throw TrainingSessionException('Failed to stream training session: $e',
          code: 'stream-error');
    }
  }

  @override
  Stream<List<TrainingSessionModel>> getTrainingSessionsForGroup(
      String groupId) {
    try {
      return _firestore
          .collection(_collection)
          .where('groupId', isEqualTo: groupId)
          .orderBy('startTime', descending: false)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .where((doc) => doc.exists)
              .map((doc) => TrainingSessionModel.fromFirestore(doc))
              .toList())
          .handleError((error) {
        if (error is FirebaseException) {
          throw TrainingSessionException(
              'Failed to get training sessions for group: ${error.message}',
              code: error.code);
        }
        throw TrainingSessionException(
            'Failed to get training sessions for group: $error',
            code: 'stream-error');
      });
    } catch (e) {
      throw TrainingSessionException(
          'Failed to get training sessions for group: $e',
          code: 'stream-error');
    }
  }

  @override
  Stream<List<TrainingSessionModel>> getUpcomingTrainingSessionsForGroup(
      String groupId) {
    try {
      final now = Timestamp.now();
      return _firestore
          .collection(_collection)
          .where('groupId', isEqualTo: groupId)
          .where('startTime', isGreaterThan: now)
          .where('status', isEqualTo: 'scheduled')
          .orderBy('startTime', descending: false)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .where((doc) => doc.exists)
              .map((doc) => TrainingSessionModel.fromFirestore(doc))
              .toList())
          .handleError((error) {
        if (error is FirebaseException) {
          throw TrainingSessionException(
              'Failed to get upcoming training sessions for group: ${error.message}',
              code: error.code);
        }
        throw TrainingSessionException(
            'Failed to get upcoming training sessions for group: $error',
            code: 'stream-error');
      });
    } catch (e) {
      throw TrainingSessionException(
          'Failed to get upcoming training sessions for group: $e',
          code: 'stream-error');
    }
  }

  @override
  Future<List<TrainingSessionModel>> getPastTrainingSessionsForGroup(
    String groupId, {
    int limit = 20,
  }) async {
    try {
      final now = Timestamp.now();
      final query = await _firestore
          .collection(_collection)
          .where('groupId', isEqualTo: groupId)
          .where('startTime', isLessThan: now)
          .orderBy('startTime', descending: true)
          .limit(limit)
          .get();

      return query.docs
          .where((doc) => doc.exists)
          .map((doc) => TrainingSessionModel.fromFirestore(doc))
          .toList();
    } on FirebaseException catch (e) {
      throw TrainingSessionException(
          'Failed to get past training sessions for group: ${e.message}',
          code: e.code);
    } catch (e) {
      throw TrainingSessionException(
          'Failed to get past training sessions for group: $e',
          code: 'unknown');
    }
  }

  @override
  Stream<List<TrainingSessionModel>> getTrainingSessionsForUser(
      String userId) {
    try {
      return _firestore
          .collection(_collection)
          .where('participantIds', arrayContains: userId)
          .orderBy('startTime', descending: false)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .where((doc) => doc.exists)
              .map((doc) => TrainingSessionModel.fromFirestore(doc))
              .toList())
          .handleError((error) {
        if (error is FirebaseException) {
          throw TrainingSessionException(
              'Failed to get training sessions for user: ${error.message}',
              code: error.code);
        }
        throw TrainingSessionException(
            'Failed to get training sessions for user: $error',
            code: 'stream-error');
      });
    } catch (e) {
      throw TrainingSessionException(
          'Failed to get training sessions for user: $e',
          code: 'stream-error');
    }
  }

  @override
  Stream<int> getUpcomingTrainingSessionsCount(String groupId) {
    try {
      final now = Timestamp.now();
      return _firestore
          .collection(_collection)
          .where('groupId', isEqualTo: groupId)
          .where('startTime', isGreaterThan: now)
          .where('status', isEqualTo: 'scheduled')
          .snapshots()
          .map((snapshot) => snapshot.docs.length)
          .handleError((error) {
        if (error is FirebaseException) {
          throw TrainingSessionException(
              'Failed to get upcoming training sessions count: ${error.message}',
              code: error.code);
        }
        throw TrainingSessionException(
            'Failed to get upcoming training sessions count: $error',
            code: 'stream-error');
      });
    } catch (e) {
      throw TrainingSessionException(
          'Failed to get upcoming training sessions count: $e',
          code: 'stream-error');
    }
  }

  @override
  Future<String> createTrainingSession(TrainingSessionModel session) async {
    try {
      // Call Cloud Function for server-side validation and creation
      // This enforces security and keeps Firestore rules minimal
      final callable = _functions.httpsCallable('createTrainingSession');

      // Prepare recurrence rule for Cloud Function if present
      Map<String, dynamic>? recurrenceRuleData;
      if (session.recurrenceRule != null &&
          session.recurrenceRule!.isRecurring) {
        recurrenceRuleData = session.recurrenceRule!.toJson();
      }

      final result = await callable.call<Map<String, dynamic>>({
        'groupId': session.groupId,
        'title': session.title,
        'description': session.description,
        'locationName': session.location.name,
        'locationAddress': session.location.address,
        'startTime': session.startTime.toIso8601String(),
        'endTime': session.endTime.toIso8601String(),
        'minParticipants': session.minParticipants,
        'maxParticipants': session.maxParticipants,
        'notes': session.notes,
        if (recurrenceRuleData != null) 'recurrenceRule': recurrenceRuleData,
      });

      final sessionId = result.data['sessionId'] as String;
      return sessionId;
    } on FirebaseFunctionsException catch (e) {
      // Handle specific Cloud Function errors with user-friendly messages
      switch (e.code) {
        case 'unauthenticated':
          throw TrainingSessionException(
              'You must be logged in to create a training session',
              code: e.code);
        case 'permission-denied':
          throw TrainingSessionException(
              'Creator is not a member of the group',
              code: e.code);
        case 'not-found':
          throw TrainingSessionException('Group not found', code: e.code);
        case 'invalid-argument':
          throw TrainingSessionException(e.message ?? 'Invalid session data',
              code: e.code);
        default:
          throw TrainingSessionException(
              'Failed to create training session: ${e.message}',
              code: e.code);
      }
    } on FirebaseException catch (e) {
      throw TrainingSessionException(
          'Failed to create training session: ${e.message}',
          code: e.code);
    } catch (e) {
      throw TrainingSessionException('Failed to create training session: $e',
          code: 'unknown');
    }
  }

  @override
  Future<void> updateTrainingSessionInfo(
    String sessionId, {
    String? title,
    String? description,
    DateTime? startTime,
    DateTime? endTime,
    GameLocation? location,
    String? notes,
  }) async {
    try {
      final currentSession = await getTrainingSessionById(sessionId);
      if (currentSession == null) {
        throw TrainingSessionException('Training session not found',
            code: 'not-found');
      }

      final updatedSession = currentSession.updateInfo(
        title: title,
        description: description,
        startTime: startTime,
        endTime: endTime,
        location: location,
        notes: notes,
      );

      await _firestore
          .collection(_collection)
          .doc(sessionId)
          .set(updatedSession.toFirestore(), SetOptions(merge: true));
    } on TrainingSessionException {
      rethrow;
    } on FirebaseException catch (e) {
      throw TrainingSessionException(
          'Failed to update training session info: ${e.message}',
          code: e.code);
    } catch (e) {
      throw TrainingSessionException(
          'Failed to update training session info: $e',
          code: 'unknown');
    }
  }

  @override
  Future<void> updateTrainingSessionSettings(
    String sessionId, {
    int? maxParticipants,
    int? minParticipants,
  }) async {
    try {
      final currentSession = await getTrainingSessionById(sessionId);
      if (currentSession == null) {
        throw TrainingSessionException('Training session not found',
            code: 'not-found');
      }

      final updatedSession = currentSession.updateSettings(
        maxParticipants: maxParticipants,
        minParticipants: minParticipants,
      );

      await _firestore
          .collection(_collection)
          .doc(sessionId)
          .set(updatedSession.toFirestore(), SetOptions(merge: true));
    } on TrainingSessionException {
      rethrow;
    } on FirebaseException catch (e) {
      throw TrainingSessionException(
          'Failed to update training session settings: ${e.message}',
          code: e.code);
    } catch (e) {
      throw TrainingSessionException(
          'Failed to update training session settings: $e',
          code: 'unknown');
    }
  }

  @override
  Future<void> joinTrainingSession(String sessionId) async {
    try {
      // Call Cloud Function for atomic join operation
      final callable = _functions.httpsCallable('joinTrainingSession');

      await callable.call<Map<String, dynamic>>({
        'sessionId': sessionId,
      });
    } on FirebaseFunctionsException catch (e) {
      // Handle specific Cloud Function errors with user-friendly messages
      switch (e.code) {
        case 'unauthenticated':
          throw TrainingSessionException(
              'You must be logged in to join a training session',
              code: e.code);
        case 'permission-denied':
          throw TrainingSessionException(
              'You must be a member of the group to join',
              code: e.code);
        case 'not-found':
          throw TrainingSessionException('Training session not found',
              code: e.code);
        case 'failed-precondition':
          throw TrainingSessionException(
              e.message ?? 'Cannot join this training session',
              code: e.code);
        case 'already-exists':
          throw TrainingSessionException(
              'You have already joined this training session',
              code: e.code);
        default:
          throw TrainingSessionException(
              'Failed to join training session: ${e.message}',
              code: e.code);
      }
    } catch (e) {
      throw TrainingSessionException('Failed to join training session: $e',
          code: 'unknown');
    }
  }

  @override
  Future<void> leaveTrainingSession(String sessionId) async {
    try {
      // Call Cloud Function for atomic leave operation
      final callable = _functions.httpsCallable('leaveTrainingSession');

      await callable.call<Map<String, dynamic>>({
        'sessionId': sessionId,
      });
    } on FirebaseFunctionsException catch (e) {
      // Handle specific Cloud Function errors with user-friendly messages
      switch (e.code) {
        case 'unauthenticated':
          throw TrainingSessionException(
              'You must be logged in to leave a training session',
              code: e.code);
        case 'not-found':
          throw TrainingSessionException('Training session not found',
              code: e.code);
        case 'failed-precondition':
          throw TrainingSessionException(
              e.message ?? 'Cannot leave this training session',
              code: e.code);
        default:
          throw TrainingSessionException(
              'Failed to leave training session: ${e.message}',
              code: e.code);
      }
    } catch (e) {
      throw TrainingSessionException('Failed to leave training session: $e',
          code: 'unknown');
    }
  }

  @override
  Future<void> addParticipant(String sessionId, String userId) async {
    try {
      final currentSession = await getTrainingSessionById(sessionId);
      if (currentSession == null) {
        throw TrainingSessionException('Training session not found',
            code: 'not-found');
      }

      // Validate user is a member of the group
      final groupMembers =
          await _groupRepository.getGroupMembers(currentSession.groupId);
      if (!groupMembers.contains(userId)) {
        throw TrainingSessionException('User is not a member of the group',
            code: 'permission-denied');
      }

      // Check if session is full
      if (currentSession.isFull) {
        throw TrainingSessionException('Training session is full',
            code: 'failed-precondition');
      }

      // Check if session is still scheduled
      if (currentSession.status != TrainingStatus.scheduled) {
        throw TrainingSessionException('Training session is not scheduled',
            code: 'invalid-state');
      }

      final updatedSession = currentSession.addParticipant(userId);

      await _firestore
          .collection(_collection)
          .doc(sessionId)
          .set(updatedSession.toFirestore(), SetOptions(merge: true));
    } on TrainingSessionException {
      rethrow;
    } on FirebaseException catch (e) {
      throw TrainingSessionException('Failed to add participant: ${e.message}',
          code: e.code);
    } catch (e) {
      throw TrainingSessionException('Failed to add participant: $e',
          code: 'unknown');
    }
  }

  @override
  Future<void> removeParticipant(String sessionId, String userId) async {
    try {
      final currentSession = await getTrainingSessionById(sessionId);
      if (currentSession == null) {
        throw TrainingSessionException('Training session not found',
            code: 'not-found');
      }

      final updatedSession = currentSession.removeParticipant(userId);

      await _firestore
          .collection(_collection)
          .doc(sessionId)
          .set(updatedSession.toFirestore(), SetOptions(merge: true));
    } on TrainingSessionException {
      rethrow;
    } on FirebaseException catch (e) {
      throw TrainingSessionException(
          'Failed to remove participant: ${e.message}',
          code: e.code);
    } catch (e) {
      throw TrainingSessionException('Failed to remove participant: $e',
          code: 'unknown');
    }
  }

  @override
  Future<void> cancelTrainingSession(String sessionId) async {
    try {
      // Call Cloud Function for cancel operation with permission validation
      final callable = _functions.httpsCallable('cancelTrainingSession');

      await callable.call<Map<String, dynamic>>({
        'sessionId': sessionId,
      });
    } on FirebaseFunctionsException catch (e) {
      // Handle specific Cloud Function errors with user-friendly messages
      switch (e.code) {
        case 'unauthenticated':
          throw TrainingSessionException(
              'You must be logged in to cancel a training session',
              code: e.code);
        case 'permission-denied':
          throw TrainingSessionException(
              'Only the session creator can cancel this training session',
              code: e.code);
        case 'not-found':
          throw TrainingSessionException('Training session not found',
              code: e.code);
        case 'failed-precondition':
          throw TrainingSessionException(
              e.message ?? 'Cannot cancel this training session',
              code: e.code);
        default:
          throw TrainingSessionException(
              'Failed to cancel training session: ${e.message}',
              code: e.code);
      }
    } catch (e) {
      throw TrainingSessionException('Failed to cancel training session: $e',
          code: 'unknown');
    }
  }

  @override
  Future<void> completeTrainingSession(String sessionId) async {
    try {
      final currentSession = await getTrainingSessionById(sessionId);
      if (currentSession == null) {
        throw TrainingSessionException('Training session not found',
            code: 'not-found');
      }

      final updatedSession = currentSession.completeSession();

      await _firestore
          .collection(_collection)
          .doc(sessionId)
          .set(updatedSession.toFirestore(), SetOptions(merge: true));
    } on TrainingSessionException {
      rethrow;
    } on FirebaseException catch (e) {
      throw TrainingSessionException(
          'Failed to complete training session: ${e.message}',
          code: e.code);
    } catch (e) {
      throw TrainingSessionException('Failed to complete training session: $e',
          code: 'unknown');
    }
  }

  @override
  Future<TrainingStatus> updateSessionStatusIfNeeded(String sessionId) async {
    try {
      final currentSession = await getTrainingSessionById(sessionId);
      if (currentSession == null) {
        throw TrainingSessionException('Training session not found',
            code: 'not-found');
      }

      // Only update if session is scheduled and past endTime
      if (currentSession.status != TrainingStatus.scheduled) {
        return currentSession.status;
      }

      final now = DateTime.now();
      if (currentSession.endTime.isAfter(now)) {
        // Session hasn't ended yet
        return TrainingStatus.scheduled;
      }

      // Session has ended - determine final status based on participants
      final hasEnoughParticipants =
          currentSession.participantIds.length >= currentSession.minParticipants;

      TrainingSessionModel updatedSession;
      if (hasEnoughParticipants) {
        // Enough participants → mark as completed
        updatedSession = currentSession.completeSession();
      } else {
        // Not enough participants → mark as cancelled
        updatedSession = currentSession.cancelSession();
      }

      // Update in Firestore
      await _firestore
          .collection(_collection)
          .doc(sessionId)
          .set(updatedSession.toFirestore(), SetOptions(merge: true));

      return updatedSession.status;
    } on TrainingSessionException {
      rethrow;
    } on FirebaseException catch (e) {
      throw TrainingSessionException(
          'Failed to update training session status: ${e.message}',
          code: e.code);
    } catch (e) {
      throw TrainingSessionException(
          'Failed to update training session status: $e',
          code: 'unknown');
    }
  }

  @override
  Future<void> deleteTrainingSession(String sessionId) async {
    try {
      await _firestore.collection(_collection).doc(sessionId).delete();
    } on FirebaseException catch (e) {
      throw TrainingSessionException(
          'Failed to delete training session: ${e.message}',
          code: e.code);
    } catch (e) {
      throw TrainingSessionException('Failed to delete training session: $e',
          code: 'unknown');
    }
  }

  @override
  Future<bool> trainingSessionExists(String sessionId) async {
    try {
      final doc =
          await _firestore.collection(_collection).doc(sessionId).get();
      return doc.exists;
    } on FirebaseException catch (e) {
      throw TrainingSessionException(
          'Failed to check if training session exists: ${e.message}',
          code: e.code);
    } catch (e) {
      throw TrainingSessionException(
          'Failed to check if training session exists: $e',
          code: 'unknown');
    }
  }

  @override
  Future<List<String>> getTrainingSessionParticipants(String sessionId) async {
    try {
      final session = await getTrainingSessionById(sessionId);
      return session?.participantIds ?? [];
    } on TrainingSessionException {
      rethrow;
    } catch (e) {
      throw TrainingSessionException(
          'Failed to get training session participants: $e',
          code: 'unknown');
    }
  }

  @override
  Future<bool> canUserJoinTrainingSession(
      String sessionId, String userId) async {
    try {
      final session = await getTrainingSessionById(sessionId);
      if (session == null) return false;

      // Check if user is a member of the group
      final groupMembers =
          await _groupRepository.getGroupMembers(session.groupId);
      if (!groupMembers.contains(userId)) return false;

      return session.canUserJoin(userId);
    } on TrainingSessionException {
      rethrow;
    } catch (e) {
      throw TrainingSessionException(
          'Failed to check if user can join training session: $e',
          code: 'unknown');
    }
  }

  @override
  Stream<List<TrainingSessionParticipantModel>>
      getTrainingSessionParticipantsStream(String sessionId) {
    try {
      return _firestore
          .collection(_collection)
          .doc(sessionId)
          .collection('participants')
          .where('status', isEqualTo: 'joined')
          .snapshots()
          .map((snapshot) => snapshot.docs
              .where((doc) => doc.exists)
              .map((doc) => TrainingSessionParticipantModel.fromFirestore(doc))
              .toList())
          .handleError((error) {
        if (error is FirebaseException) {
          throw TrainingSessionException(
              'Failed to stream training session participants: ${error.message}',
              code: error.code);
        }
        throw TrainingSessionException(
            'Failed to stream training session participants: $error',
            code: 'stream-error');
      });
    } catch (e) {
      throw TrainingSessionException(
          'Failed to stream training session participants: $e',
          code: 'stream-error');
    }
  }

  @override
  Stream<int> getTrainingSessionParticipantCount(String sessionId) {
    try {
      return _firestore
          .collection(_collection)
          .doc(sessionId)
          .collection('participants')
          .where('status', isEqualTo: 'joined')
          .snapshots()
          .map((snapshot) => snapshot.docs.length)
          .handleError((error) {
        if (error is FirebaseException) {
          throw TrainingSessionException(
              'Failed to stream training session participant count: ${error.message}',
              code: error.code);
        }
        throw TrainingSessionException(
            'Failed to stream training session participant count: $error',
            code: 'stream-error');
      });
    } catch (e) {
      throw TrainingSessionException(
          'Failed to stream training session participant count: $e',
          code: 'stream-error');
    }
  }

  // ============================================================================
  // Recurring Training Sessions (Story 15.2)
  // ============================================================================

  @override
  Stream<List<TrainingSessionModel>> getRecurringSessionInstances(
      String parentSessionId) {
    try {
      return _firestore
          .collection(_collection)
          .where('parentSessionId', isEqualTo: parentSessionId)
          .orderBy('startTime', descending: false)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .where((doc) => doc.exists)
              .map((doc) => TrainingSessionModel.fromFirestore(doc))
              .toList())
          .handleError((error) {
        if (error is FirebaseException) {
          throw TrainingSessionException(
              'Failed to get recurring session instances: ${error.message}',
              code: error.code);
        }
        throw TrainingSessionException(
            'Failed to get recurring session instances: $error',
            code: 'stream-error');
      });
    } catch (e) {
      throw TrainingSessionException(
          'Failed to get recurring session instances: $e',
          code: 'stream-error');
    }
  }

  @override
  Stream<List<TrainingSessionModel>> getUpcomingRecurringSessionInstances(
      String parentSessionId) {
    try {
      final now = Timestamp.now();
      return _firestore
          .collection(_collection)
          .where('parentSessionId', isEqualTo: parentSessionId)
          .where('startTime', isGreaterThan: now)
          .where('status', isEqualTo: 'scheduled')
          .orderBy('startTime', descending: false)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .where((doc) => doc.exists)
              .map((doc) => TrainingSessionModel.fromFirestore(doc))
              .toList())
          .handleError((error) {
        if (error is FirebaseException) {
          throw TrainingSessionException(
              'Failed to get upcoming recurring session instances: ${error.message}',
              code: error.code);
        }
        throw TrainingSessionException(
            'Failed to get upcoming recurring session instances: $error',
            code: 'stream-error');
      });
    } catch (e) {
      throw TrainingSessionException(
          'Failed to get upcoming recurring session instances: $e',
          code: 'stream-error');
    }
  }

  @override
  Future<List<String>> generateRecurringInstances(
      String parentSessionId) async {
    try {
      // Call Cloud Function to generate instances
      final callable =
          _functions.httpsCallable('generateRecurringTrainingSessions');

      final result = await callable.call<Map<String, dynamic>>({
        'parentSessionId': parentSessionId,
      });

      final sessionIds = List<String>.from(result.data['sessionIds'] as List);
      return sessionIds;
    } on FirebaseFunctionsException catch (e) {
      // Handle specific Cloud Function errors with user-friendly messages
      switch (e.code) {
        case 'unauthenticated':
          throw TrainingSessionException(
              'You must be logged in to generate recurring sessions',
              code: e.code);
        case 'permission-denied':
          throw TrainingSessionException(
              'Only the creator can generate recurring instances',
              code: e.code);
        case 'not-found':
          throw TrainingSessionException('Parent training session not found',
              code: e.code);
        case 'invalid-argument':
          throw TrainingSessionException(
              e.message ??
                  'Invalid recurrence rule or parent session configuration',
              code: e.code);
        default:
          throw TrainingSessionException(
              'Failed to generate recurring instances: ${e.message}',
              code: e.code);
      }
    } catch (e) {
      throw TrainingSessionException(
          'Failed to generate recurring instances: $e',
          code: 'unknown');
    }
  }

  @override
  Future<void> cancelRecurringSessionInstance(String instanceId) async {
    try {
      final session = await getTrainingSessionById(instanceId);
      if (session == null) {
        throw TrainingSessionException('Training session instance not found',
            code: 'not-found');
      }

      // Verify this is actually an instance (has parentSessionId)
      if (!session.isRecurrenceInstance) {
        throw TrainingSessionException(
            'This is not a recurring session instance. Use cancelTrainingSession instead.',
            code: 'invalid-argument');
      }

      // Cancel the instance using the standard cancel method
      await cancelTrainingSession(instanceId);
    } on TrainingSessionException {
      rethrow;
    } catch (e) {
      throw TrainingSessionException(
          'Failed to cancel recurring session instance: $e',
          code: 'unknown');
    }
  }
}
