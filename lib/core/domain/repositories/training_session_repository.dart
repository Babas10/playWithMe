import '../../data/models/game_model.dart';
import '../../data/models/training_session_model.dart';

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

  /// Add participant to training session
  ///
  /// Validates that:
  /// - The user is a member of the group
  /// - The session is not full
  /// - The session is still scheduled (not cancelled or completed)
  ///
  /// Throws:
  /// - [Exception] if user is not a member of the group
  /// - [Exception] if session is full
  Future<void> addParticipant(String sessionId, String userId);

  /// Remove participant from training session
  ///
  /// Only allowed if:
  /// - The session is still scheduled (not started or completed)
  Future<void> removeParticipant(String sessionId, String userId);

  /// Cancel training session
  ///
  /// Only the creator can cancel a training session
  Future<void> cancelTrainingSession(String sessionId);

  /// Complete training session
  ///
  /// Marks the session as completed
  /// This does NOT affect ELO ratings (training sessions are practice only)
  Future<void> completeTrainingSession(String sessionId);

  /// Delete training session
  ///
  /// Only the creator can delete a training session
  /// Only allowed if the session hasn't started yet
  Future<void> deleteTrainingSession(String sessionId);

  /// Check if training session exists
  Future<bool> trainingSessionExists(String sessionId);

  /// Get training session participants
  Future<List<String>> getTrainingSessionParticipants(String sessionId);

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
