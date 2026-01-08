import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'training_feedback_model.freezed.dart';
part 'training_feedback_model.g.dart';

/// Represents anonymous feedback for a training session
/// Feedback is stored in a subcollection under training sessions
/// The participant's identity is hashed to prevent duplicates while maintaining anonymity
@freezed
class TrainingFeedbackModel with _$TrainingFeedbackModel {
  const factory TrainingFeedbackModel({
    required String id,
    required String trainingSessionId,
    /// Rating from 1-5 stars
    required int rating,
    /// Optional written feedback
    String? comment,
    /// Hash of participant ID to prevent duplicates without exposing identity
    /// Hash is SHA-256 of: trainingSessionId + userId + salt
    required String participantHash,
    /// Timestamp when feedback was submitted
    @TimestampConverter() required DateTime submittedAt,
  }) = _TrainingFeedbackModel;

  const TrainingFeedbackModel._();

  factory TrainingFeedbackModel.fromJson(Map<String, dynamic> json) =>
      _$TrainingFeedbackModelFromJson(json);

  /// Factory constructor for creating from Firestore DocumentSnapshot
  factory TrainingFeedbackModel.fromFirestore(
      DocumentSnapshot doc, String trainingSessionId) {
    final data = doc.data() as Map<String, dynamic>;

    // Convert Firestore Timestamps to DateTime strings for JSON deserialization
    final jsonData = Map<String, dynamic>.from(data);

    if (data['submittedAt'] is Timestamp) {
      jsonData['submittedAt'] =
          (data['submittedAt'] as Timestamp).toDate().toIso8601String();
    }

    return TrainingFeedbackModel.fromJson({
      ...jsonData,
      'id': doc.id,
      'trainingSessionId': trainingSessionId,
    });
  }

  /// Convert to Firestore-compatible map (excludes id since it's the document ID)
  Map<String, dynamic> toFirestore() {
    final json = toJson();
    json.remove('id'); // Remove id as it's the document ID
    json.remove(
        'trainingSessionId'); // Remove trainingSessionId as it's in the path

    // Convert DateTime fields to Firestore Timestamps
    if (json['submittedAt'] is String) {
      json['submittedAt'] = Timestamp.fromDate(submittedAt);
    }

    return json;
  }

  /// Validation methods

  /// Validate rating is in valid range (1-5)
  bool get hasValidRating => rating >= 1 && rating <= 5;

  /// Check if feedback has a comment
  bool get hasComment => comment != null && comment!.trim().isNotEmpty;

  /// Get sanitized comment (null if empty)
  String? get sanitizedComment {
    if (comment == null) return null;
    final trimmed = comment!.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}

/// Timestamp converter for Freezed models
class TimestampConverter implements JsonConverter<DateTime, dynamic> {
  const TimestampConverter();

  @override
  DateTime fromJson(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    } else if (value is String) {
      return DateTime.parse(value);
    } else {
      throw ArgumentError('Invalid timestamp format: $value');
    }
  }

  @override
  dynamic toJson(DateTime dateTime) {
    return dateTime.toIso8601String();
  }
}
