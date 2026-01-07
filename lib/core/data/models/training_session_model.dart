import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'game_model.dart'; // For GameLocation reuse
import 'recurrence_rule_model.dart';

part 'training_session_model.freezed.dart';
part 'training_session_model.g.dart';

/// Represents a training session within a group
/// Training sessions are practice events that do not affect ELO ratings
/// They are bound to groups and participants are resolved via group membership only
@freezed
class TrainingSessionModel with _$TrainingSessionModel {
  const factory TrainingSessionModel({
    required String id,
    required String groupId,
    required String title,
    String? description,
    required GameLocation location,
    @TimestampConverter() required DateTime startTime,
    @TimestampConverter() required DateTime endTime,
    required int minParticipants,
    required int maxParticipants,
    required String createdBy,
    @TimestampConverter() required DateTime createdAt,
    @TimestampConverter() DateTime? updatedAt,
    // Recurrence support (Story 15.2)
    RecurrenceRuleModel? recurrenceRule,
    // Parent session ID (for recurring session instances)
    // If this is set, this session is an instance of a recurring parent
    String? parentSessionId,
    // Session status
    @Default(TrainingStatus.scheduled) TrainingStatus status,
    // Participant tracking
    @Default([]) List<String> participantIds,
    // Session notes
    String? notes,
  }) = _TrainingSessionModel;

  const TrainingSessionModel._();

  factory TrainingSessionModel.fromJson(Map<String, dynamic> json) =>
      _$TrainingSessionModelFromJson(json);

  /// Factory constructor for creating from Firestore DocumentSnapshot
  factory TrainingSessionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Convert Firestore Timestamps to DateTime strings for JSON deserialization
    final jsonData = Map<String, dynamic>.from(data);

    if (data['createdAt'] is Timestamp) {
      jsonData['createdAt'] =
          (data['createdAt'] as Timestamp).toDate().toIso8601String();
    }
    if (data['startTime'] is Timestamp) {
      jsonData['startTime'] =
          (data['startTime'] as Timestamp).toDate().toIso8601String();
    }
    if (data['endTime'] is Timestamp) {
      jsonData['endTime'] =
          (data['endTime'] as Timestamp).toDate().toIso8601String();
    }
    if (data['updatedAt'] is Timestamp) {
      jsonData['updatedAt'] =
          (data['updatedAt'] as Timestamp).toDate().toIso8601String();
    }

    return TrainingSessionModel.fromJson({
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
    if (json['startTime'] is String) {
      json['startTime'] = Timestamp.fromDate(startTime);
    }
    if (json['endTime'] is String) {
      json['endTime'] = Timestamp.fromDate(endTime);
    }
    if (updatedAt != null && json['updatedAt'] is String) {
      json['updatedAt'] = Timestamp.fromDate(updatedAt!);
    }

    // Ensure location is properly serialized
    if (json['location'] is GameLocation) {
      json['location'] = (json['location'] as GameLocation).toJson();
    }

    return json;
  }

  /// Business logic methods

  /// Check if user is participating in the training session
  bool isParticipant(String userId) => participantIds.contains(userId);

  /// Check if user is the creator
  bool isCreator(String userId) => createdBy == userId;

  /// Check if user can manage the training session
  bool canManage(String userId) => createdBy == userId;

  /// Check if training session is full
  bool get isFull => participantIds.length >= maxParticipants;

  /// Check if training session has minimum participants
  bool get hasMinimumParticipants =>
      participantIds.length >= minParticipants;

  /// Get available spots
  int get availableSpots => maxParticipants - participantIds.length;

  /// Get current participant count
  int get currentParticipantCount => participantIds.length;

  /// Check if training session is in the past
  bool get isPast => startTime.isBefore(DateTime.now());

  /// Check if training session is today
  bool get isToday {
    final now = DateTime.now();
    final sessionDate = startTime;
    return now.year == sessionDate.year &&
        now.month == sessionDate.month &&
        now.day == sessionDate.day;
  }

  /// Check if training session is this week
  bool get isThisWeek {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    return startTime.isAfter(startOfWeek) && startTime.isBefore(endOfWeek);
  }

  /// Get training session duration
  Duration get duration => endTime.difference(startTime);

  /// Check if user can join the training session
  bool canUserJoin(String userId) {
    if (isParticipant(userId)) return false;
    if (status != TrainingStatus.scheduled) return false;
    if (isPast) return false;
    return !isFull;
  }

  /// Check if user can leave the training session
  bool canUserLeave(String userId) {
    return isParticipant(userId) && status == TrainingStatus.scheduled;
  }

  /// Validation methods

  /// Validate training session timing
  bool get hasValidTiming => startTime.isAfter(DateTime.now()) && endTime.isAfter(startTime);

  /// Validate participant limits
  bool get hasValidParticipantLimits =>
      minParticipants <= maxParticipants && minParticipants >= 2;

  /// Update methods that return new instances

  /// Update basic training session information
  TrainingSessionModel updateInfo({
    String? title,
    String? description,
    DateTime? startTime,
    DateTime? endTime,
    GameLocation? location,
    String? notes,
  }) {
    return copyWith(
      title: title ?? this.title,
      description: description ?? this.description,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      location: location ?? this.location,
      notes: notes ?? this.notes,
      updatedAt: DateTime.now(),
    );
  }

  /// Update training session settings
  TrainingSessionModel updateSettings({
    int? maxParticipants,
    int? minParticipants,
  }) {
    return copyWith(
      maxParticipants: maxParticipants ?? this.maxParticipants,
      minParticipants: minParticipants ?? this.minParticipants,
      updatedAt: DateTime.now(),
    );
  }

  /// Add a participant to the training session
  TrainingSessionModel addParticipant(String userId) {
    if (isParticipant(userId) || isFull) return this;

    return copyWith(
      participantIds: [...participantIds, userId],
      updatedAt: DateTime.now(),
    );
  }

  /// Remove a participant from the training session
  TrainingSessionModel removeParticipant(String userId) {
    return copyWith(
      participantIds: participantIds.where((id) => id != userId).toList(),
      updatedAt: DateTime.now(),
    );
  }

  /// Cancel the training session
  TrainingSessionModel cancelSession() {
    if (status == TrainingStatus.completed) return this;
    return copyWith(
      status: TrainingStatus.cancelled,
      updatedAt: DateTime.now(),
    );
  }

  /// Complete the training session
  TrainingSessionModel completeSession() {
    if (status != TrainingStatus.scheduled) return this;
    return copyWith(
      status: TrainingStatus.completed,
      updatedAt: DateTime.now(),
    );
  }

  /// Get formatted time until training session
  String getTimeUntilSession() {
    final now = DateTime.now();
    if (startTime.isBefore(now)) return 'Past';

    final difference = startTime.difference(now);
    if (difference.inDays > 0) {
      return '${difference.inDays}d ${difference.inHours.remainder(24)}h';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ${difference.inMinutes.remainder(60)}m';
    } else {
      return '${difference.inMinutes}m';
    }
  }

  /// Recurrence-related methods

  /// Check if this is a recurring training session (has a recurrence rule)
  bool get isRecurring => recurrenceRule != null && recurrenceRule!.isRecurring;

  /// Check if this is a recurrence instance (child of a recurring parent)
  bool get isRecurrenceInstance => parentSessionId != null;

  /// Check if this is a parent recurring session
  bool get isParentRecurringSession => isRecurring && !isRecurrenceInstance;

  /// Get recurrence description (human-readable)
  String? get recurrenceDescription => recurrenceRule?.getDescription();
}

enum TrainingStatus {
  @JsonValue('scheduled')
  scheduled,
  @JsonValue('completed')
  completed,
  @JsonValue('cancelled')
  cancelled,
}
