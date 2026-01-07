import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'game_model.dart'; // For TimestampConverter

part 'training_session_participant_model.freezed.dart';
part 'training_session_participant_model.g.dart';

/// Represents a participant in a training session
/// Stored as a subcollection under trainingSessions/{sessionId}/participants/{userId}
@freezed
class TrainingSessionParticipantModel with _$TrainingSessionParticipantModel {
  const factory TrainingSessionParticipantModel({
    /// User ID of the participant
    required String userId,

    /// When the user joined the training session
    @TimestampConverter() required DateTime joinedAt,

    /// Participant status
    @Default(ParticipantStatus.joined) ParticipantStatus status,
  }) = _TrainingSessionParticipantModel;

  const TrainingSessionParticipantModel._();

  factory TrainingSessionParticipantModel.fromJson(Map<String, dynamic> json) =>
      _$TrainingSessionParticipantModelFromJson(json);

  /// Factory constructor for creating from Firestore DocumentSnapshot
  factory TrainingSessionParticipantModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Convert Firestore Timestamps to DateTime strings for JSON deserialization
    final jsonData = Map<String, dynamic>.from(data);

    if (data['joinedAt'] is Timestamp) {
      jsonData['joinedAt'] =
          (data['joinedAt'] as Timestamp).toDate().toIso8601String();
    }

    return TrainingSessionParticipantModel.fromJson({
      ...jsonData,
      'userId': doc.id, // Document ID is the user ID
    });
  }

  /// Convert to Firestore-compatible map (excludes userId since it's the document ID)
  Map<String, dynamic> toFirestore() {
    final json = toJson();
    json.remove('userId'); // Remove userId as it's the document ID

    // Convert DateTime fields to Firestore Timestamps
    if (json['joinedAt'] is String) {
      json['joinedAt'] = Timestamp.fromDate(joinedAt);
    }

    return json;
  }

  /// Check if participant is currently joined
  bool get isJoined => status == ParticipantStatus.joined;

  /// Check if participant has left
  bool get hasLeft => status == ParticipantStatus.left;
}

/// Status of a training session participant
enum ParticipantStatus {
  @JsonValue('joined')
  joined,

  @JsonValue('left')
  left,
}
