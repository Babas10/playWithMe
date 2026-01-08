import '../../data/models/exercise_model.dart';

/// Repository for managing exercises within training sessions
/// Exercises are stored as a subcollection under training sessions
///
/// ARCHITECTURE RULE: This repository operates in the Games layer
/// - ✅ CAN import: TrainingSessionRepository
/// - ❌ CANNOT import: FriendRepository or any My Community layer code
/// - Exercises belong to training sessions and are managed accordingly
abstract class ExerciseRepository {
  /// Get exercise by ID
  ///
  /// Returns the exercise with the specified ID from the specified training session
  Future<ExerciseModel?> getExerciseById(
    String trainingSessionId,
    String exerciseId,
  );

  /// Stream exercise by ID (real-time updates)
  ///
  /// Returns a stream of the exercise with real-time updates
  Stream<ExerciseModel?> getExerciseStream(
    String trainingSessionId,
    String exerciseId,
  );

  /// Get all exercises for a training session
  ///
  /// Returns a stream of all exercises belonging to the specified training session
  /// Ordered by creation time (oldest first)
  Stream<List<ExerciseModel>> getExercisesForTrainingSession(
    String trainingSessionId,
  );

  /// Get exercise count for a training session
  ///
  /// Returns a real-time count of exercises in the training session
  Stream<int> getExerciseCount(String trainingSessionId);

  /// Create a new exercise
  ///
  /// Creates a new exercise in the specified training session
  ///
  /// Validates that:
  /// - The training session exists
  /// - The training session has not started yet
  /// - The user has permission to modify the training session
  ///
  /// Returns the ID of the created exercise
  ///
  /// Throws:
  /// - [Exception] if training session does not exist
  /// - [Exception] if training session has already started
  /// - [Exception] if user does not have permission
  Future<String> createExercise(
    String trainingSessionId,
    ExerciseModel exercise,
  );

  /// Update exercise information
  ///
  /// Updates the specified exercise
  ///
  /// Only allowed if:
  /// - The training session has not started yet
  /// - The user has permission to modify the training session
  ///
  /// Throws:
  /// - [Exception] if exercise does not exist
  /// - [Exception] if training session has already started
  /// - [Exception] if user does not have permission
  Future<void> updateExercise(
    String trainingSessionId,
    String exerciseId, {
    String? name,
    String? description,
    int? durationMinutes,
  });

  /// Delete exercise
  ///
  /// Deletes the specified exercise from the training session
  ///
  /// Only allowed if:
  /// - The training session has not started yet
  /// - The user has permission to modify the training session
  ///
  /// Throws:
  /// - [Exception] if exercise does not exist
  /// - [Exception] if training session has already started
  /// - [Exception] if user does not have permission
  Future<void> deleteExercise(
    String trainingSessionId,
    String exerciseId,
  );

  /// Check if exercise exists
  ///
  /// Returns true if the exercise exists in the specified training session
  Future<bool> exerciseExists(
    String trainingSessionId,
    String exerciseId,
  );

  /// Check if training session allows exercise modifications
  ///
  /// Returns true if the training session has not started yet
  /// Used to lock exercise editing after session begins
  Future<bool> canModifyExercises(String trainingSessionId);

  /// Delete all exercises for a training session
  ///
  /// Deletes all exercises when a training session is deleted
  /// This is an internal method used by training session deletion
  Future<void> deleteAllExercisesForSession(String trainingSessionId);
}
