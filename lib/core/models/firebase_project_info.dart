import 'package:freezed_annotation/freezed_annotation.dart';

part 'firebase_project_info.freezed.dart';
part 'firebase_project_info.g.dart';

/// Firebase project information for tracking Story 0.2.1 completion
@freezed
class FirebaseProjectInfo with _$FirebaseProjectInfo {
  const factory FirebaseProjectInfo({
    required String environment,
    required String expectedProjectId,
    String? actualProjectId,
    required FirebaseProjectStatus status,
    DateTime? createdAt,
    @Default(false) bool matchesExpected,
  }) = _FirebaseProjectInfo;

  factory FirebaseProjectInfo.fromJson(Map<String, dynamic> json) =>
      _$FirebaseProjectInfoFromJson(json);
}

/// Status of Firebase project creation
@freezed
class FirebaseProjectTracker with _$FirebaseProjectTracker {
  const factory FirebaseProjectTracker({
    required String storyVersion,
    required DateTime trackedAt,
    required List<FirebaseProjectInfo> projects,
  }) = _FirebaseProjectTracker;

  factory FirebaseProjectTracker.fromJson(Map<String, dynamic> json) =>
      _$FirebaseProjectTrackerFromJson(json);
}

/// Firebase project creation status
enum FirebaseProjectStatus {
  @JsonValue('not_started')
  notStarted,
  @JsonValue('pending')
  pending,
  @JsonValue('created')
  created,
  @JsonValue('error')
  error,
}

extension FirebaseProjectStatusX on FirebaseProjectStatus {
  String get displayName {
    switch (this) {
      case FirebaseProjectStatus.notStarted:
        return 'Not Started';
      case FirebaseProjectStatus.pending:
        return 'Pending';
      case FirebaseProjectStatus.created:
        return 'Created';
      case FirebaseProjectStatus.error:
        return 'Error';
    }
  }

  String get emoji {
    switch (this) {
      case FirebaseProjectStatus.notStarted:
        return '❌';
      case FirebaseProjectStatus.pending:
        return '📋';
      case FirebaseProjectStatus.created:
        return '✅';
      case FirebaseProjectStatus.error:
        return '🚫';
    }
  }
}