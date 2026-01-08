import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/repositories/exercise_repository.dart';
import '../../domain/repositories/training_session_repository.dart';
import '../models/exercise_model.dart';

/// Firestore implementation of ExerciseRepository
///
/// ARCHITECTURE: This repository operates in the Games layer
/// - ✅ Exercises are stored as subcollections under training sessions
/// - ✅ Validates session state before allowing modifications
/// - ❌ Never imports FriendRepository or My Community code
/// - Exercises are bound to training sessions
class FirestoreExerciseRepository implements ExerciseRepository {
  final FirebaseFirestore _firestore;
  final TrainingSessionRepository _trainingSessionRepository;

  static const String _trainingSessions = 'trainingSessions';
  static const String _exercises = 'exercises';

  FirestoreExerciseRepository({
    FirebaseFirestore? firestore,
    required TrainingSessionRepository trainingSessionRepository,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _trainingSessionRepository = trainingSessionRepository;

  /// Get reference to exercises subcollection for a training session
  CollectionReference _getExercisesCollection(String trainingSessionId) {
    return _firestore
        .collection(_trainingSessions)
        .doc(trainingSessionId)
        .collection(_exercises);
  }

  @override
  Future<ExerciseModel?> getExerciseById(
    String trainingSessionId,
    String exerciseId,
  ) async {
    try {
      final doc = await _getExercisesCollection(trainingSessionId)
          .doc(exerciseId)
          .get();
      return doc.exists ? ExerciseModel.fromFirestore(doc) : null;
    } catch (e) {
      throw Exception('Failed to get exercise: $e');
    }
  }

  @override
  Stream<ExerciseModel?> getExerciseStream(
    String trainingSessionId,
    String exerciseId,
  ) {
    try {
      return _getExercisesCollection(trainingSessionId)
          .doc(exerciseId)
          .snapshots()
          .map((snapshot) =>
              snapshot.exists ? ExerciseModel.fromFirestore(snapshot) : null);
    } catch (e) {
      throw Exception('Failed to stream exercise: $e');
    }
  }

  @override
  Stream<List<ExerciseModel>> getExercisesForTrainingSession(
    String trainingSessionId,
  ) {
    try {
      return _getExercisesCollection(trainingSessionId)
          .orderBy('createdAt', descending: false)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .where((doc) => doc.exists)
              .map((doc) => ExerciseModel.fromFirestore(doc))
              .toList());
    } catch (e) {
      throw Exception('Failed to get exercises for training session: $e');
    }
  }

  @override
  Stream<int> getExerciseCount(String trainingSessionId) {
    try {
      return _getExercisesCollection(trainingSessionId).snapshots().map(
          (snapshot) => snapshot.docs.where((doc) => doc.exists).length);
    } catch (e) {
      throw Exception('Failed to get exercise count: $e');
    }
  }

  @override
  Future<String> createExercise(
    String trainingSessionId,
    ExerciseModel exercise,
  ) async {
    try {
      // Validate that training session exists and can be modified
      if (!await canModifyExercises(trainingSessionId)) {
        throw Exception(
            'Cannot create exercise: Training session has already started or does not exist');
      }

      // Validate exercise data
      if (!exercise.hasValidName) {
        throw Exception('Exercise name cannot be empty');
      }

      if (!exercise.hasValidDuration) {
        throw Exception('Exercise duration must be between 1 and 300 minutes');
      }

      // Create exercise with server timestamp
      final exerciseData = exercise
          .copyWith(
            createdAt: DateTime.now(),
            updatedAt: null,
          )
          .toFirestore();

      final docRef = await _getExercisesCollection(trainingSessionId).add(
        exerciseData,
      );

      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create exercise: $e');
    }
  }

  @override
  Future<void> updateExercise(
    String trainingSessionId,
    String exerciseId, {
    String? name,
    String? description,
    int? durationMinutes,
  }) async {
    try {
      // Validate that training session can be modified
      if (!await canModifyExercises(trainingSessionId)) {
        throw Exception(
            'Cannot update exercise: Training session has already started');
      }

      // Get existing exercise
      final existingExercise = await getExerciseById(
        trainingSessionId,
        exerciseId,
      );

      if (existingExercise == null) {
        throw Exception('Exercise not found');
      }

      // Update exercise
      final updatedExercise = existingExercise.updateInfo(
        name: name,
        description: description,
        durationMinutes: durationMinutes,
      );

      // Validate updated exercise
      if (!updatedExercise.hasValidName) {
        throw Exception('Exercise name cannot be empty');
      }

      if (!updatedExercise.hasValidDuration) {
        throw Exception('Exercise duration must be between 1 and 300 minutes');
      }

      await _getExercisesCollection(trainingSessionId)
          .doc(exerciseId)
          .update(updatedExercise.toFirestore());
    } catch (e) {
      throw Exception('Failed to update exercise: $e');
    }
  }

  @override
  Future<void> deleteExercise(
    String trainingSessionId,
    String exerciseId,
  ) async {
    try {
      // Validate that training session can be modified
      if (!await canModifyExercises(trainingSessionId)) {
        throw Exception(
            'Cannot delete exercise: Training session has already started');
      }

      // Check if exercise exists
      if (!await exerciseExists(trainingSessionId, exerciseId)) {
        throw Exception('Exercise not found');
      }

      await _getExercisesCollection(trainingSessionId).doc(exerciseId).delete();
    } catch (e) {
      throw Exception('Failed to delete exercise: $e');
    }
  }

  @override
  Future<bool> exerciseExists(
    String trainingSessionId,
    String exerciseId,
  ) async {
    try {
      final doc = await _getExercisesCollection(trainingSessionId)
          .doc(exerciseId)
          .get();
      return doc.exists;
    } catch (e) {
      throw Exception('Failed to check if exercise exists: $e');
    }
  }

  @override
  Future<bool> canModifyExercises(String trainingSessionId) async {
    try {
      final trainingSession =
          await _trainingSessionRepository.getTrainingSessionById(
        trainingSessionId,
      );

      if (trainingSession == null) {
        return false;
      }

      // Can only modify if session hasn't started yet
      return !trainingSession.isPast;
    } catch (e) {
      throw Exception('Failed to check if exercises can be modified: $e');
    }
  }

  @override
  Future<void> deleteAllExercisesForSession(String trainingSessionId) async {
    try {
      final exercisesSnapshot =
          await _getExercisesCollection(trainingSessionId).get();

      // Delete all exercises in batches
      final batch = _firestore.batch();
      for (final doc in exercisesSnapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to delete all exercises for session: $e');
    }
  }
}
