import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'exercise_model.freezed.dart';
part 'exercise_model.g.dart';

/// Represents an exercise within a training session
/// Exercises define specific drills or activities to be practiced during training
/// They are stored as a subcollection under training sessions
@freezed
class ExerciseModel with _$ExerciseModel {
  const factory ExerciseModel({
    required String id,
    required String name,
    String? description,
    /// Duration in minutes (optional)
    int? durationMinutes,
    @TimestampConverter() required DateTime createdAt,
    @TimestampConverter() DateTime? updatedAt,
  }) = _ExerciseModel;

  const ExerciseModel._();

  factory ExerciseModel.fromJson(Map<String, dynamic> json) =>
      _$ExerciseModelFromJson(json);

  /// Factory constructor for creating from Firestore DocumentSnapshot
  factory ExerciseModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Convert Firestore Timestamps to DateTime strings for JSON deserialization
    final jsonData = Map<String, dynamic>.from(data);

    if (data['createdAt'] is Timestamp) {
      jsonData['createdAt'] =
          (data['createdAt'] as Timestamp).toDate().toIso8601String();
    }
    if (data['updatedAt'] is Timestamp) {
      jsonData['updatedAt'] =
          (data['updatedAt'] as Timestamp).toDate().toIso8601String();
    }

    return ExerciseModel.fromJson({
      ...jsonData,
      'id': doc.id,
    });
  }

  /// Convert to Firestore-compatible map (excludes id since it's the document ID)
  Map<String, dynamic> toFirestore() {
    final json = toJson();
    json.remove('id'); // Remove id as it's the document ID

    // Convert DateTime fields to Firestore Timestamps
    if (json['createdAt'] is String) {
      json['createdAt'] = Timestamp.fromDate(createdAt);
    }
    if (updatedAt != null && json['updatedAt'] is String) {
      json['updatedAt'] = Timestamp.fromDate(updatedAt!);
    } else {
      json.remove('updatedAt'); // Remove null updatedAt from Firestore data
    }

    return json;
  }

  /// Business logic methods

  /// Check if exercise has a duration
  bool get hasDuration => durationMinutes != null && durationMinutes! > 0;

  /// Get formatted duration string
  String get formattedDuration {
    if (!hasDuration) return 'No duration set';

    final minutes = durationMinutes!;
    if (minutes < 60) {
      return '$minutes min';
    }

    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;

    if (remainingMinutes == 0) {
      return '$hours h';
    }

    return '$hours h $remainingMinutes min';
  }

  /// Update exercise information
  ExerciseModel updateInfo({
    String? name,
    String? description,
    int? durationMinutes,
  }) {
    return copyWith(
      name: name ?? this.name,
      description: description ?? this.description,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      updatedAt: DateTime.now(),
    );
  }

  /// Validation methods

  /// Validate exercise name is not empty
  bool get hasValidName => name.trim().isNotEmpty;

  /// Validate duration is reasonable (if set)
  bool get hasValidDuration =>
      durationMinutes == null ||
      (durationMinutes! > 0 && durationMinutes! <= 300); // Max 5 hours
}

/// Custom converter for DateTime to/from JSON
class TimestampConverter implements JsonConverter<DateTime, String> {
  const TimestampConverter();

  @override
  DateTime fromJson(String json) => DateTime.parse(json);

  @override
  String toJson(DateTime object) => object.toIso8601String();
}
