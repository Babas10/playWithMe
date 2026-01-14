import 'package:equatable/equatable.dart';

import '../../data/models/training_feedback_model.dart';

/// Repository for managing anonymous feedback for training sessions
/// Feedback is stored in a subcollection under training sessions
///
/// Key principles:
/// - Only participants can submit feedback
/// - Feedback is anonymous (no direct user ID stored)
/// - Participant hash prevents duplicate submissions
/// - Aggregated statistics available for session creators
abstract class TrainingFeedbackRepository {
  /// Submit anonymous feedback for a training session
  ///
  /// This method should use a Cloud Function to:
  /// - Validate the user is a participant of the session
  /// - Generate a participant hash to prevent duplicates
  /// - Submit the feedback anonymously
  ///
  /// Throws:
  /// - [Exception] if user is not a participant
  /// - [Exception] if user has already submitted feedback
  /// - [Exception] if ratings are invalid (not 1-5)
  Future<void> submitFeedback({
    required String trainingSessionId,
    required int exercisesQuality,
    required int trainingIntensity,
    required int coachingClarity,
    String? comment,
  });

  /// Get aggregated feedback statistics for a training session
  ///
  /// Returns summary statistics without exposing individual responses:
  /// - averageRating: Average of all ratings
  /// - totalCount: Total number of feedback submissions
  /// - ratingDistribution: Count of each rating (1-5)
  ///
  /// Only accessible by the session creator
  Future<FeedbackAggregation?> getAggregatedFeedback(String trainingSessionId);

  /// Stream aggregated feedback statistics
  ///
  /// Real-time updates of aggregated statistics as feedback is submitted
  /// Only accessible by the session creator
  Stream<FeedbackAggregation?> getAggregatedFeedbackStream(
      String trainingSessionId);

  /// Check if user has already submitted feedback for a session
  ///
  /// Uses Cloud Function to check without exposing individual feedback
  Future<bool> hasUserSubmittedFeedback(String trainingSessionId);

  /// Get list of individual feedback entries for a training session
  ///
  /// Returns all feedback entries sorted by submission time (most recent first)
  /// Note: All feedback is anonymous - no user information is exposed
  Stream<List<TrainingFeedbackModel>> getFeedbackListStream(
      String trainingSessionId);

  /// Delete all feedback for a training session
  ///
  /// Only the session creator can delete all feedback
  /// Used when deleting a training session
  Future<void> deleteFeedbackForSession(String trainingSessionId);
}

/// Aggregated feedback statistics
class FeedbackAggregation extends Equatable {
  final String trainingSessionId;
  final double averageExercisesQuality;
  final double averageTrainingIntensity;
  final double averageCoachingClarity;
  final int totalCount;
  final Map<int, int> exercisesDistribution; // rating -> count
  final Map<int, int> intensityDistribution; // rating -> count
  final Map<int, int> coachingDistribution; // rating -> count
  final List<String> comments; // Non-empty comments (still anonymous)

  const FeedbackAggregation({
    required this.trainingSessionId,
    required this.averageExercisesQuality,
    required this.averageTrainingIntensity,
    required this.averageCoachingClarity,
    required this.totalCount,
    required this.exercisesDistribution,
    required this.intensityDistribution,
    required this.coachingDistribution,
    required this.comments,
  });

  @override
  List<Object?> get props => [
        trainingSessionId,
        averageExercisesQuality,
        averageTrainingIntensity,
        averageCoachingClarity,
        totalCount,
        exercisesDistribution,
        intensityDistribution,
        coachingDistribution,
        comments,
      ];

  factory FeedbackAggregation.empty(String trainingSessionId) {
    return FeedbackAggregation(
      trainingSessionId: trainingSessionId,
      averageExercisesQuality: 0.0,
      averageTrainingIntensity: 0.0,
      averageCoachingClarity: 0.0,
      totalCount: 0,
      exercisesDistribution: const {1: 0, 2: 0, 3: 0, 4: 0, 5: 0},
      intensityDistribution: const {1: 0, 2: 0, 3: 0, 4: 0, 5: 0},
      coachingDistribution: const {1: 0, 2: 0, 3: 0, 4: 0, 5: 0},
      comments: const [],
    );
  }

  /// Calculate from list of feedback
  factory FeedbackAggregation.fromFeedbackList(
    String trainingSessionId,
    List<TrainingFeedbackModel> feedbackList,
  ) {
    if (feedbackList.isEmpty) {
      return FeedbackAggregation.empty(trainingSessionId);
    }

    final exercisesDistribution = <int, int>{1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
    final intensityDistribution = <int, int>{1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
    final coachingDistribution = <int, int>{1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
    final comments = <String>[];
    var totalExercisesQuality = 0;
    var totalTrainingIntensity = 0;
    var totalCoachingClarity = 0;

    for (final feedback in feedbackList) {
      totalExercisesQuality += feedback.exercisesQuality;
      totalTrainingIntensity += feedback.trainingIntensity;
      totalCoachingClarity += feedback.coachingClarity;

      exercisesDistribution[feedback.exercisesQuality] =
          (exercisesDistribution[feedback.exercisesQuality] ?? 0) + 1;
      intensityDistribution[feedback.trainingIntensity] =
          (intensityDistribution[feedback.trainingIntensity] ?? 0) + 1;
      coachingDistribution[feedback.coachingClarity] =
          (coachingDistribution[feedback.coachingClarity] ?? 0) + 1;

      if (feedback.hasComment) {
        comments.add(feedback.comment!);
      }
    }

    return FeedbackAggregation(
      trainingSessionId: trainingSessionId,
      averageExercisesQuality: totalExercisesQuality / feedbackList.length,
      averageTrainingIntensity: totalTrainingIntensity / feedbackList.length,
      averageCoachingClarity: totalCoachingClarity / feedbackList.length,
      totalCount: feedbackList.length,
      exercisesDistribution: exercisesDistribution,
      intensityDistribution: intensityDistribution,
      coachingDistribution: coachingDistribution,
      comments: comments,
    );
  }

  /// Get percentage for a specific exercises quality rating
  double getPercentageForExercisesRating(int rating) {
    if (totalCount == 0) return 0.0;
    return ((exercisesDistribution[rating] ?? 0) / totalCount) * 100;
  }

  /// Get percentage for a specific training intensity rating
  double getPercentageForIntensityRating(int rating) {
    if (totalCount == 0) return 0.0;
    return ((intensityDistribution[rating] ?? 0) / totalCount) * 100;
  }

  /// Get percentage for a specific coaching clarity rating
  double getPercentageForCoachingRating(int rating) {
    if (totalCount == 0) return 0.0;
    return ((coachingDistribution[rating] ?? 0) / totalCount) * 100;
  }

  /// Check if there is any feedback
  bool get hasFeedback => totalCount > 0;

  /// Get rounded average exercises quality for display (e.g., 4.5)
  double get roundedAverageExercises {
    return (averageExercisesQuality * 2).round() / 2;
  }

  /// Get rounded average training intensity for display (e.g., 4.5)
  double get roundedAverageIntensity {
    return (averageTrainingIntensity * 2).round() / 2;
  }

  /// Get rounded average coaching clarity for display (e.g., 4.5)
  double get roundedAverageCoaching {
    return (averageCoachingClarity * 2).round() / 2;
  }

  /// Get overall average (average of all three ratings)
  double get overallAverage => (averageExercisesQuality + averageTrainingIntensity + averageCoachingClarity) / 3;
}
