import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

import '../../domain/repositories/group_repository.dart';
import '../../domain/repositories/training_session_repository.dart';
import '../models/game_model.dart';
import '../models/training_session_model.dart';

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
      final doc = await _firestore.collection(_collection).doc(sessionId).get();
      return doc.exists ? TrainingSessionModel.fromFirestore(doc) : null;
    } catch (e) {
      throw Exception('Failed to get training session: $e');
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
              : null);
    } catch (e) {
      throw Exception('Failed to stream training session: $e');
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
              .toList());
    } catch (e) {
      throw Exception('Failed to get training sessions for group: $e');
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
              .toList());
    } catch (e) {
      throw Exception('Failed to get upcoming training sessions for group: $e');
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
    } catch (e) {
      throw Exception('Failed to get past training sessions for group: $e');
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
              .toList());
    } catch (e) {
      throw Exception('Failed to get training sessions for user: $e');
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
          .map((snapshot) => snapshot.docs.length);
    } catch (e) {
      throw Exception('Failed to get upcoming training sessions count: $e');
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
      if (session.recurrenceRule != null && session.recurrenceRule!.isRecurring) {
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
          throw Exception('You must be logged in to create a training session');
        case 'permission-denied':
          throw Exception('Creator is not a member of the group');
        case 'not-found':
          throw Exception('Group not found');
        case 'invalid-argument':
          throw Exception(e.message ?? 'Invalid session data');
        default:
          throw Exception('Failed to create training session: ${e.message}');
      }
    } catch (e) {
      throw Exception('Failed to create training session: $e');
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
        throw Exception('Training session not found');
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
    } catch (e) {
      throw Exception('Failed to update training session info: $e');
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
        throw Exception('Training session not found');
      }

      final updatedSession = currentSession.updateSettings(
        maxParticipants: maxParticipants,
        minParticipants: minParticipants,
      );

      await _firestore
          .collection(_collection)
          .doc(sessionId)
          .set(updatedSession.toFirestore(), SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to update training session settings: $e');
    }
  }

  @override
  Future<void> addParticipant(String sessionId, String userId) async {
    try {
      final currentSession = await getTrainingSessionById(sessionId);
      if (currentSession == null) {
        throw Exception('Training session not found');
      }

      // Validate user is a member of the group
      final groupMembers =
          await _groupRepository.getGroupMembers(currentSession.groupId);
      if (!groupMembers.contains(userId)) {
        throw Exception('User is not a member of the group');
      }

      // Check if session is full
      if (currentSession.isFull) {
        throw Exception('Training session is full');
      }

      // Check if session is still scheduled
      if (currentSession.status != TrainingStatus.scheduled) {
        throw Exception('Training session is not scheduled');
      }

      final updatedSession = currentSession.addParticipant(userId);

      await _firestore
          .collection(_collection)
          .doc(sessionId)
          .set(updatedSession.toFirestore(), SetOptions(merge: true));
    } catch (e) {
      if (e.toString().contains('Training session not found') ||
          e.toString().contains('User is not a member') ||
          e.toString().contains('Training session is full') ||
          e.toString().contains('Training session is not scheduled')) {
        rethrow;
      }
      throw Exception('Failed to add participant: $e');
    }
  }

  @override
  Future<void> removeParticipant(String sessionId, String userId) async {
    try {
      final currentSession = await getTrainingSessionById(sessionId);
      if (currentSession == null) {
        throw Exception('Training session not found');
      }

      final updatedSession = currentSession.removeParticipant(userId);

      await _firestore
          .collection(_collection)
          .doc(sessionId)
          .set(updatedSession.toFirestore(), SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to remove participant: $e');
    }
  }

  @override
  Future<void> cancelTrainingSession(String sessionId) async {
    try {
      final currentSession = await getTrainingSessionById(sessionId);
      if (currentSession == null) {
        throw Exception('Training session not found');
      }

      final updatedSession = currentSession.cancelSession();

      await _firestore
          .collection(_collection)
          .doc(sessionId)
          .set(updatedSession.toFirestore(), SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to cancel training session: $e');
    }
  }

  @override
  Future<void> completeTrainingSession(String sessionId) async {
    try {
      final currentSession = await getTrainingSessionById(sessionId);
      if (currentSession == null) {
        throw Exception('Training session not found');
      }

      final updatedSession = currentSession.completeSession();

      await _firestore
          .collection(_collection)
          .doc(sessionId)
          .set(updatedSession.toFirestore(), SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to complete training session: $e');
    }
  }

  @override
  Future<void> deleteTrainingSession(String sessionId) async {
    try {
      await _firestore.collection(_collection).doc(sessionId).delete();
    } catch (e) {
      throw Exception('Failed to delete training session: $e');
    }
  }

  @override
  Future<bool> trainingSessionExists(String sessionId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(sessionId).get();
      return doc.exists;
    } catch (e) {
      throw Exception('Failed to check if training session exists: $e');
    }
  }

  @override
  Future<List<String>> getTrainingSessionParticipants(String sessionId) async {
    try {
      final session = await getTrainingSessionById(sessionId);
      return session?.participantIds ?? [];
    } catch (e) {
      throw Exception('Failed to get training session participants: $e');
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
    } catch (e) {
      throw Exception('Failed to check if user can join training session: $e');
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
              .toList());
    } catch (e) {
      throw Exception('Failed to get recurring session instances: $e');
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
              .toList());
    } catch (e) {
      throw Exception(
          'Failed to get upcoming recurring session instances: $e');
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
          throw Exception(
              'You must be logged in to generate recurring sessions');
        case 'permission-denied':
          throw Exception('Only the creator can generate recurring instances');
        case 'not-found':
          throw Exception('Parent training session not found');
        case 'invalid-argument':
          throw Exception(e.message ??
              'Invalid recurrence rule or parent session configuration');
        default:
          throw Exception(
              'Failed to generate recurring instances: ${e.message}');
      }
    } catch (e) {
      throw Exception('Failed to generate recurring instances: $e');
    }
  }

  @override
  Future<void> cancelRecurringSessionInstance(String instanceId) async {
    try {
      final session = await getTrainingSessionById(instanceId);
      if (session == null) {
        throw Exception('Training session instance not found');
      }

      // Verify this is actually an instance (has parentSessionId)
      if (!session.isRecurrenceInstance) {
        throw Exception(
            'This is not a recurring session instance. Use cancelTrainingSession instead.');
      }

      // Cancel the instance using the standard cancel method
      await cancelTrainingSession(instanceId);
    } catch (e) {
      if (e.toString().contains('Training session instance not found') ||
          e.toString().contains('This is not a recurring session instance')) {
        rethrow;
      }
      throw Exception('Failed to cancel recurring session instance: $e');
    }
  }
}
