import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/exceptions/repository_exceptions.dart';
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
    } on FirebaseException catch (e) {
      throw ExerciseException('Failed to get exercise: ${e.message}',
          code: e.code);
    } catch (e) {
      throw ExerciseException('Failed to get exercise: $e', code: 'unknown');
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
              snapshot.exists ? ExerciseModel.fromFirestore(snapshot) : null)
          .handleError((error) {
        if (error is FirebaseException) {
          throw ExerciseException('Failed to stream exercise: ${error.message}',
              code: error.code);
        }
        throw ExerciseException('Failed to stream exercise: $error',
            code: 'stream-error');
      });
    } catch (e) {
      throw ExerciseException('Failed to stream exercise: $e',
          code: 'stream-error');
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
              .toList())
          .handleError((error) {
        if (error is FirebaseException) {
          throw ExerciseException(
              'Failed to get exercises for training session: ${error.message}',
              code: error.code);
        }
        throw ExerciseException(
            'Failed to get exercises for training session: $error',
            code: 'stream-error');
      });
    } catch (e) {
      throw ExerciseException(
          'Failed to get exercises for training session: $e',
          code: 'stream-error');
    }
  }

  @override
  Stream<int> getExerciseCount(String trainingSessionId) {
    try {
      return _getExercisesCollection(trainingSessionId)
          .snapshots()
          .map((snapshot) => snapshot.docs.where((doc) => doc.exists).length)
          .handleError((error) {
        if (error is FirebaseException) {
          throw ExerciseException(
              'Failed to get exercise count: ${error.message}',
              code: error.code);
        }
        throw ExerciseException('Failed to get exercise count: $error',
            code: 'stream-error');
      });
    } catch (e) {
      throw ExerciseException('Failed to get exercise count: $e',
          code: 'stream-error');
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
        throw ExerciseException(
            'Cannot create exercise: Training session has already started or does not exist',
            code: 'failed-precondition');
      }

      // Validate exercise data
      if (!exercise.hasValidName) {
        throw ExerciseException('Exercise name cannot be empty',
            code: 'invalid-argument');
      }

      if (!exercise.hasValidDuration) {
        throw ExerciseException(
            'Exercise duration must be between 1 and 300 minutes',
            code: 'invalid-argument');
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
    } on ExerciseException {
      rethrow;
    } on FirebaseException catch (e) {
      throw ExerciseException('Failed to create exercise: ${e.message}',
          code: e.code);
    } catch (e) {
      throw ExerciseException('Failed to create exercise: $e', code: 'unknown');
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
        throw ExerciseException(
            'Cannot update exercise: Training session has already started',
            code: 'failed-precondition');
      }

      // Get existing exercise
      final existingExercise = await getExerciseById(
        trainingSessionId,
        exerciseId,
      );

      if (existingExercise == null) {
        throw ExerciseException('Exercise not found', code: 'not-found');
      }

      // Update exercise
      final updatedExercise = existingExercise.updateInfo(
        name: name,
        description: description,
        durationMinutes: durationMinutes,
      );

      // Validate updated exercise
      if (!updatedExercise.hasValidName) {
        throw ExerciseException('Exercise name cannot be empty',
            code: 'invalid-argument');
      }

      if (!updatedExercise.hasValidDuration) {
        throw ExerciseException(
            'Exercise duration must be between 1 and 300 minutes',
            code: 'invalid-argument');
      }

      await _getExercisesCollection(trainingSessionId)
          .doc(exerciseId)
          .update(updatedExercise.toFirestore());
    } on ExerciseException {
      rethrow;
    } on FirebaseException catch (e) {
      throw ExerciseException('Failed to update exercise: ${e.message}',
          code: e.code);
    } catch (e) {
      throw ExerciseException('Failed to update exercise: $e', code: 'unknown');
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
        throw ExerciseException(
            'Cannot delete exercise: Training session has already started',
            code: 'failed-precondition');
      }

      // Check if exercise exists
      if (!await exerciseExists(trainingSessionId, exerciseId)) {
        throw ExerciseException('Exercise not found', code: 'not-found');
      }

      await _getExercisesCollection(trainingSessionId).doc(exerciseId).delete();
    } on ExerciseException {
      rethrow;
    } on FirebaseException catch (e) {
      throw ExerciseException('Failed to delete exercise: ${e.message}',
          code: e.code);
    } catch (e) {
      throw ExerciseException('Failed to delete exercise: $e', code: 'unknown');
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
    } on FirebaseException catch (e) {
      throw ExerciseException(
          'Failed to check if exercise exists: ${e.message}',
          code: e.code);
    } catch (e) {
      throw ExerciseException('Failed to check if exercise exists: $e',
          code: 'unknown');
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
    } on TrainingSessionException {
      rethrow;
    } catch (e) {
      throw ExerciseException(
          'Failed to check if exercises can be modified: $e',
          code: 'unknown');
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
    } on FirebaseException catch (e) {
      throw ExerciseException(
          'Failed to delete all exercises for session: ${e.message}',
          code: e.code);
    } catch (e) {
      throw ExerciseException('Failed to delete all exercises for session: $e',
          code: 'unknown');
    }
  }
}
