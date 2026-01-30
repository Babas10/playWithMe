import '../../data/models/game_model.dart';
import '../../data/models/training_session_model.dart';
import '../../data/models/training_session_participant_model.dart';

/// Repository for managing training sessions in the Games layer
/// Training sessions are group-bound practice events that do not affect ELO ratings
///
/// ARCHITECTURE RULE: This repository operates in the Games layer
/// - ✅ CAN import: GroupRepository
/// - ❌ CANNOT import: FriendRepository or any My Community layer code
/// - Participants are ALWAYS resolved via group.memberIds
abstract class TrainingSessionRepository {
  /// Get training session by ID
  Future<TrainingSessionModel?> getTrainingSessionById(String sessionId);

  /// Stream training session by ID (real-time updates)
  Stream<TrainingSessionModel?> getTrainingSessionStream(String sessionId);

  /// Get training sessions for a group
  Stream<List<TrainingSessionModel>> getTrainingSessionsForGroup(
      String groupId);

  /// Get upcoming training sessions for a group
  Stream<List<TrainingSessionModel>> getUpcomingTrainingSessionsForGroup(
      String groupId);

  /// Get past training sessions for a group
  Future<List<TrainingSessionModel>> getPastTrainingSessionsForGroup(
    String groupId, {
    int limit = 20,
  });

  /// Get training sessions for a user (across all groups they're members of)
  Stream<List<TrainingSessionModel>> getTrainingSessionsForUser(String userId);

  /// Get the next upcoming training session for a user (chronologically first)
  /// Returns the single next scheduled training session where user has joined
  /// and session is not cancelled.
  Stream<TrainingSessionModel?> getNextTrainingSessionForUser(String userId);

  /// Get count of upcoming training sessions for a group
  Stream<int> getUpcomingTrainingSessionsCount(String groupId);

  /// Create a new training session
  ///
  /// Validates that:
  /// - The creator is a member of the specified group
  /// - The group exists and is accessible
  ///
  /// Throws:
  /// - [Exception] if creator is not a member of the group
  /// - [Exception] if group does not exist
  Future<String> createTrainingSession(TrainingSessionModel session);

  /// Update training session information
  Future<void> updateTrainingSessionInfo(
    String sessionId, {
    String? title,
    String? description,
    DateTime? startTime,
    DateTime? endTime,
    GameLocation? location,
    String? notes,
  });

  /// Update training session settings
  Future<void> updateTrainingSessionSettings(
    String sessionId, {
    int? maxParticipants,
    int? minParticipants,
  });

  /// Join training session (via Cloud Function for atomic operations)
  ///
  /// Uses Cloud Function to atomically:
  /// - Validate user is a member of the group
  /// - Check session is not full (with race condition protection)
  /// - Add participant to participants subcollection
  /// - Update denormalized participantIds array
  ///
  /// Throws:
  /// - [Exception] if user is not a member of the group
  /// - [Exception] if session is full
  /// - [Exception] if session has already started or is not scheduled
  /// - [Exception] if user has already joined
  Future<void> joinTrainingSession(String sessionId);

  /// Leave training session (via Cloud Function for atomic operations)
  ///
  /// Uses Cloud Function to atomically:
  /// - Update participant status to 'left'
  /// - Remove from denormalized participantIds array
  ///
  /// Only allowed if:
  /// - The session is still scheduled (not started or completed)
  /// - User is currently a participant
  ///
  /// Throws:
  /// - [Exception] if user is not a participant
  /// - [Exception] if session is not scheduled
  Future<void> leaveTrainingSession(String sessionId);

  /// Add participant to training session (DEPRECATED - use joinTrainingSession instead)
  ///
  /// Legacy method maintained for backward compatibility.
  /// New code should use joinTrainingSession() which uses Cloud Functions.
  ///
  /// Validates that:
  /// - The user is a member of the group
  /// - The session is not full
  /// - The session is still scheduled (not cancelled or completed)
  ///
  /// Throws:
  /// - [Exception] if user is not a member of the group
  /// - [Exception] if session is full
  @Deprecated('Use joinTrainingSession() instead for atomic operations')
  Future<void> addParticipant(String sessionId, String userId);

  /// Remove participant from training session (DEPRECATED - use leaveTrainingSession instead)
  ///
  /// Legacy method maintained for backward compatibility.
  /// New code should use leaveTrainingSession() which uses Cloud Functions.
  ///
  /// Only allowed if:
  /// - The session is still scheduled (not started or completed)
  @Deprecated('Use leaveTrainingSession() instead for atomic operations')
  Future<void> removeParticipant(String sessionId, String userId);

  /// Cancel training session (via Cloud Function for permission validation)
  ///
  /// Uses Cloud Function to:
  /// - Validate user is authenticated
  /// - Validate user is the session creator (permission check)
  /// - Set status to 'cancelled' with cancelledBy and cancelledAt tracking
  ///
  /// Throws:
  /// - [Exception] if user is not authenticated
  /// - [Exception] if user is not the session creator
  /// - [Exception] if session is already cancelled or completed
  /// - [Exception] if session not found
  Future<void> cancelTrainingSession(String sessionId);

  /// Complete training session
  ///
  /// Marks the session as completed
  /// This does NOT affect ELO ratings (training sessions are practice only)
  Future<void> completeTrainingSession(String sessionId);

  /// Auto-update session status based on time and participants
  ///
  /// Automatically determines the session status after endTime has passed:
  /// - If participantIds.length >= minParticipants → status = completed
  /// - If participantIds.length < minParticipants → status = cancelled
  ///
  /// Only updates sessions that are:
  /// - Currently in 'scheduled' status
  /// - Past their endTime
  ///
  /// Returns:
  /// - The updated status ('completed', 'cancelled', or 'scheduled' if no update)
  Future<TrainingStatus> updateSessionStatusIfNeeded(String sessionId);

  /// Delete training session
  ///
  /// Only the creator can delete a training session
  /// Only allowed if the session hasn't started yet
  Future<void> deleteTrainingSession(String sessionId);

  /// Check if training session exists
  Future<bool> trainingSessionExists(String sessionId);

  /// Get training session participants (deprecated - returns only IDs from denormalized array)
  ///
  /// This method returns participant IDs from the denormalized participantIds array.
  /// For full participant information, use getTrainingSessionParticipantsStream().
  @Deprecated('Use getTrainingSessionParticipantsStream() for full participant information')
  Future<List<String>> getTrainingSessionParticipants(String sessionId);

  /// Stream training session participants from participants subcollection
  ///
  /// Returns a stream of participants with their join timestamps and status.
  /// Only includes participants with 'joined' status (excludes those who left).
  Stream<List<TrainingSessionParticipantModel>> getTrainingSessionParticipantsStream(
      String sessionId);

  /// Stream participant count for a training session
  ///
  /// Returns a real-time count of currently joined participants.
  /// Updates whenever participants join or leave.
  Stream<int> getTrainingSessionParticipantCount(String sessionId);

  /// Check if user can join training session
  ///
  /// Validates:
  /// - User is a member of the group
  /// - Session is not full
  /// - Session is scheduled (not cancelled or completed)
  /// - Session hasn't started yet
  Future<bool> canUserJoinTrainingSession(String sessionId, String userId);

  // ============================================================================
  // Recurring Training Sessions (Story 15.2)
  // ============================================================================

  /// Get all instances of a recurring training session
  ///
  /// Returns all training sessions that have the specified parentSessionId
  Stream<List<TrainingSessionModel>> getRecurringSessionInstances(
      String parentSessionId);

  /// Get upcoming instances of a recurring training session
  ///
  /// Returns only future instances that are scheduled
  Stream<List<TrainingSessionModel>> getUpcomingRecurringSessionInstances(
      String parentSessionId);

  /// Generate recurring training session instances via Cloud Function
  ///
  /// This calls the Cloud Function to generate all instances based on
  /// the parent session's recurrence rule
  ///
  /// Throws:
  /// - [Exception] if user is not the creator of the parent session
  /// - [Exception] if parent session doesn't have a recurrence rule
  Future<List<String>> generateRecurringInstances(String parentSessionId);

  /// Cancel a single instance of a recurring session
  ///
  /// This allows cancelling one occurrence without affecting the entire series
  ///
  /// Only the creator of the parent session can cancel instances
  Future<void> cancelRecurringSessionInstance(String instanceId);
}
