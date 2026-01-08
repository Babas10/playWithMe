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
  /// - [Exception] if rating is invalid (not 1-5)
  Future<void> submitFeedback({
    required String trainingSessionId,
    required int rating,
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

  /// Delete all feedback for a training session
  ///
  /// Only the session creator can delete all feedback
  /// Used when deleting a training session
  Future<void> deleteFeedbackForSession(String trainingSessionId);
}

/// Aggregated feedback statistics
class FeedbackAggregation extends Equatable {
  final String trainingSessionId;
  final double averageRating;
  final int totalCount;
  final Map<int, int> ratingDistribution; // rating -> count
  final List<String> comments; // Non-empty comments (still anonymous)

  const FeedbackAggregation({
    required this.trainingSessionId,
    required this.averageRating,
    required this.totalCount,
    required this.ratingDistribution,
    required this.comments,
  });

  @override
  List<Object?> get props => [
        trainingSessionId,
        averageRating,
        totalCount,
        ratingDistribution,
        comments,
      ];

  factory FeedbackAggregation.empty(String trainingSessionId) {
    return FeedbackAggregation(
      trainingSessionId: trainingSessionId,
      averageRating: 0.0,
      totalCount: 0,
      ratingDistribution: const {1: 0, 2: 0, 3: 0, 4: 0, 5: 0},
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

    final ratingDistribution = <int, int>{1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
    final comments = <String>[];
    var totalRating = 0;

    for (final feedback in feedbackList) {
      totalRating += feedback.rating;
      ratingDistribution[feedback.rating] =
          (ratingDistribution[feedback.rating] ?? 0) + 1;

      if (feedback.hasComment) {
        comments.add(feedback.comment!);
      }
    }

    return FeedbackAggregation(
      trainingSessionId: trainingSessionId,
      averageRating: totalRating / feedbackList.length,
      totalCount: feedbackList.length,
      ratingDistribution: ratingDistribution,
      comments: comments,
    );
  }

  /// Get percentage for a specific rating
  double getPercentageForRating(int rating) {
    if (totalCount == 0) return 0.0;
    return ((ratingDistribution[rating] ?? 0) / totalCount) * 100;
  }

  /// Check if there is any feedback
  bool get hasFeedback => totalCount > 0;

  /// Get rounded average rating for display (e.g., 4.5)
  double get roundedAverageRating {
    return (averageRating * 2).round() / 2;
  }
}
