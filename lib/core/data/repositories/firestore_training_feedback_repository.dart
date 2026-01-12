import 'dart:developer' as developer;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/repositories/training_feedback_repository.dart';
import '../models/training_feedback_model.dart';

/// Firestore implementation of TrainingFeedbackRepository
/// Manages anonymous feedback in a subcollection under training sessions
class FirestoreTrainingFeedbackRepository
    implements TrainingFeedbackRepository {
  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions;
  final FirebaseAuth _auth;

  /// Collection paths
  static const String _trainingSessions = 'trainingSessions';
  static const String _feedback = 'feedback';

  FirestoreTrainingFeedbackRepository({
    FirebaseFirestore? firestore,
    FirebaseFunctions? functions,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _functions = functions ?? FirebaseFunctions.instance,
        _auth = auth ?? FirebaseAuth.instance;

  /// Get feedback collection reference for a training session
  CollectionReference _getFeedbackCollection(String trainingSessionId) {
    return _firestore
        .collection(_trainingSessions)
        .doc(trainingSessionId)
        .collection(_feedback);
  }

  @override
  Future<void> submitFeedback({
    required String trainingSessionId,
    required int exercisesQuality,
    required int trainingIntensity,
    required int coachingClarity,
    String? comment,
  }) async {
    try {
      developer.log(
        '[FirestoreTrainingFeedbackRepository] Submitting feedback',
        name: 'training.feedback',
      );

      // Validate ratings
      if (exercisesQuality < 1 || exercisesQuality > 5) {
        throw Exception('Exercises quality rating must be between 1 and 5');
      }
      if (trainingIntensity < 1 || trainingIntensity > 5) {
        throw Exception('Training intensity rating must be between 1 and 5');
      }
      if (coachingClarity < 1 || coachingClarity > 5) {
        throw Exception('Coaching clarity rating must be between 1 and 5');
      }

      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User must be authenticated to submit feedback');
      }

      // Call Cloud Function to submit feedback anonymously
      // The function will:
      // 1. Validate user is a participant
      // 2. Generate participant hash
      // 3. Check for duplicate submission
      // 4. Store feedback
      final callable = _functions.httpsCallable('submitTrainingFeedback');
      await callable.call({
        'trainingSessionId': trainingSessionId,
        'exercisesQuality': exercisesQuality,
        'trainingIntensity': trainingIntensity,
        'coachingClarity': coachingClarity,
        'comment': comment,
      });

      developer.log(
        '[FirestoreTrainingFeedbackRepository] Feedback submitted successfully',
        name: 'training.feedback',
      );
    } catch (e) {
      developer.log(
        '[FirestoreTrainingFeedbackRepository] Error submitting feedback: $e',
        name: 'training.feedback',
        error: e,
      );
      rethrow;
    }
  }

  @override
  Future<FeedbackAggregation?> getAggregatedFeedback(
      String trainingSessionId) async {
    try {
      final feedbackSnapshot = await _getFeedbackCollection(trainingSessionId)
          .orderBy('submittedAt', descending: true)
          .get();

      if (feedbackSnapshot.docs.isEmpty) {
        return FeedbackAggregation.empty(trainingSessionId);
      }

      final feedbackList = feedbackSnapshot.docs
          .map((doc) =>
              TrainingFeedbackModel.fromFirestore(doc, trainingSessionId))
          .toList();

      return FeedbackAggregation.fromFeedbackList(
          trainingSessionId, feedbackList);
    } catch (e) {
      developer.log(
        '[FirestoreTrainingFeedbackRepository] Error getting aggregated feedback: $e',
        name: 'training.feedback',
        error: e,
      );
      rethrow;
    }
  }

  @override
  Stream<FeedbackAggregation?> getAggregatedFeedbackStream(
      String trainingSessionId) {
    return _getFeedbackCollection(trainingSessionId)
        .orderBy('submittedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) {
        return FeedbackAggregation.empty(trainingSessionId);
      }

      final feedbackList = snapshot.docs
          .map((doc) =>
              TrainingFeedbackModel.fromFirestore(doc, trainingSessionId))
          .toList();

      return FeedbackAggregation.fromFeedbackList(
          trainingSessionId, feedbackList);
    }).handleError((error) {
      developer.log(
        '[FirestoreTrainingFeedbackRepository] Error streaming aggregated feedback: $error',
        name: 'training.feedback',
        error: error,
      );
      return FeedbackAggregation.empty(trainingSessionId);
    });
  }

  @override
  Future<bool> hasUserSubmittedFeedback(String trainingSessionId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return false;
      }

      // Call Cloud Function to check if user has submitted feedback
      // This uses the same hashing mechanism without exposing the logic
      final callable = _functions.httpsCallable('hasSubmittedTrainingFeedback');
      final result = await callable.call({
        'trainingSessionId': trainingSessionId,
      });

      return result.data['hasSubmitted'] as bool? ?? false;
    } catch (e) {
      developer.log(
        '[FirestoreTrainingFeedbackRepository] Error checking feedback submission: $e',
        name: 'training.feedback',
        error: e,
      );
      return false;
    }
  }

  @override
  Future<void> deleteFeedbackForSession(String trainingSessionId) async {
    try {
      developer.log(
        '[FirestoreTrainingFeedbackRepository] Deleting feedback for session: $trainingSessionId',
        name: 'training.feedback',
      );

      // Get all feedback documents
      final feedbackSnapshot =
          await _getFeedbackCollection(trainingSessionId).get();

      // Delete in batches (Firestore limit is 500 operations per batch)
      final batch = _firestore.batch();
      var count = 0;

      for (final doc in feedbackSnapshot.docs) {
        batch.delete(doc.reference);
        count++;

        // Commit and start new batch if limit reached
        if (count >= 500) {
          await batch.commit();
          count = 0;
        }
      }

      // Commit remaining operations
      if (count > 0) {
        await batch.commit();
      }

      developer.log(
        '[FirestoreTrainingFeedbackRepository] Deleted ${feedbackSnapshot.docs.length} feedback documents',
        name: 'training.feedback',
      );
    } catch (e) {
      developer.log(
        '[FirestoreTrainingFeedbackRepository] Error deleting feedback: $e',
        name: 'training.feedback',
        error: e,
      );
      rethrow;
    }
  }
}
