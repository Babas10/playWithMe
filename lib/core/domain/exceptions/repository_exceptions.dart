// Custom exception classes for repository error handling.
// Following the FriendshipException pattern for consistent error handling across the app.

/// Exception thrown by GameRepository operations.
class GameException implements Exception {
  final String message;
  final String? code;

  GameException(this.message, {this.code});

  @override
  String toString() => message;
}

/// Exception thrown by TrainingSessionRepository operations.
class TrainingSessionException implements Exception {
  final String message;
  final String? code;

  TrainingSessionException(this.message, {this.code});

  @override
  String toString() => message;
}

/// Exception thrown by GroupRepository operations.
class GroupException implements Exception {
  final String message;
  final String? code;

  GroupException(this.message, {this.code});

  @override
  String toString() => message;
}

/// Exception thrown by InvitationRepository operations.
class InvitationException implements Exception {
  final String message;
  final String? code;

  InvitationException(this.message, {this.code});

  @override
  String toString() => message;
}

/// Exception thrown by UserRepository operations.
class UserException implements Exception {
  final String message;
  final String? code;

  UserException(this.message, {this.code});

  @override
  String toString() => message;
}

/// Exception thrown by ExerciseRepository operations.
class ExerciseException implements Exception {
  final String message;
  final String? code;

  ExerciseException(this.message, {this.code});

  @override
  String toString() => message;
}

/// Exception thrown by ImageStorageRepository operations.
class ImageStorageException implements Exception {
  final String message;
  final String? code;

  ImageStorageException(this.message, {this.code});

  @override
  String toString() => message;
}
