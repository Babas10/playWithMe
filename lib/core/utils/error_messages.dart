import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

import '../domain/exceptions/repository_exceptions.dart';

/// Utility class for converting exceptions to user-friendly error messages.
class ErrorMessages {
  /// Convert a Firebase exception to a user-friendly error message.
  ///
  /// Returns a tuple of (message, isRetryable).
  static (String message, bool isRetryable) getErrorMessage(Exception e) {
    // Check for custom repository exceptions first
    if (e is GameException ||
        e is TrainingSessionException ||
        e is GroupException ||
        e is InvitationException ||
        e is UserException ||
        e is ExerciseException ||
        e is ImageStorageException ||
        e is GroupInviteLinkException) {
      return (e.toString(), _isRetryableByCode(_getExceptionCode(e)));
    }
    // Check FirebaseFunctionsException first as it may extend FirebaseException
    if (e is FirebaseFunctionsException) {
      return _getCloudFunctionErrorMessage(e);
    } else if (e is FirebaseException) {
      return _getFirestoreErrorMessage(e);
    } else {
      return ('An unexpected error occurred. Please try again.', true);
    }
  }

  /// Get the error code from a custom exception
  static String? _getExceptionCode(Exception e) {
    if (e is GameException) return e.code;
    if (e is TrainingSessionException) return e.code;
    if (e is GroupException) return e.code;
    if (e is InvitationException) return e.code;
    if (e is UserException) return e.code;
    if (e is ExerciseException) return e.code;
    if (e is ImageStorageException) return e.code;
    if (e is GroupInviteLinkException) return e.code;
    return null;
  }

  /// Check if an error code indicates a retryable error
  static bool _isRetryableByCode(String? code) {
    if (code == null) return true;
    const nonRetryableCodes = {
      'permission-denied',
      'not-found',
      'already-exists',
      'unauthenticated',
      'invalid-argument',
    };
    return !nonRetryableCodes.contains(code);
  }

  /// Convert a Firestore exception to a user-friendly error message.
  static (String message, bool isRetryable) _getFirestoreErrorMessage(
    FirebaseException e,
  ) {
    switch (e.code) {
      case 'permission-denied':
        return (
          'You don\'t have permission to perform this action',
          false,
        );
      case 'unavailable':
        return (
          'Service temporarily unavailable. Please try again.',
          true,
        );
      case 'already-exists':
        return (
          'This action has already been performed',
          false,
        );
      case 'not-found':
        return (
          'The requested resource was not found',
          false,
        );
      case 'deadline-exceeded':
        return (
          'Request timed out. Check your connection.',
          true,
        );
      case 'cancelled':
        return (
          'Operation was cancelled',
          true,
        );
      case 'aborted':
        return (
          'Operation was interrupted. Please try again.',
          true,
        );
      case 'resource-exhausted':
        return (
          'Too many requests. Please wait a moment.',
          true,
        );
      case 'unauthenticated':
        return (
          'You must be logged in to perform this action',
          false,
        );
      case 'failed-precondition':
        return (
          'Cannot complete this action right now',
          false,
        );
      default:
        return (
          e.message ?? 'An unexpected error occurred. Please try again.',
          true,
        );
    }
  }

  /// Convert a Cloud Function exception to a user-friendly error message.
  ///
  /// Note: For specific error codes, we return the original function message
  /// as Cloud Functions are responsible for providing user-friendly messages.
  /// We only provide generic messages for codes where the function didn't.
  static (String message, bool isRetryable) _getCloudFunctionErrorMessage(
    FirebaseFunctionsException e,
  ) {
    switch (e.code) {
      case 'unauthenticated':
        return (
          'You must be logged in to perform this action',
          false,
        );
      case 'permission-denied':
        return (
          'You don\'t have permission to perform this action',
          false,
        );
      case 'invalid-argument':
      case 'not-found':
      case 'already-exists':
      case 'internal':
        // Return the cloud function's message for these codes
        return (
          e.message ?? 'An unexpected error occurred. Please try again.',
          e.code == 'internal',
        );
      case 'unavailable':
        return (
          'Service temporarily unavailable. Please try again.',
          true,
        );
      case 'deadline-exceeded':
        return (
          'Request timed out. Check your connection.',
          true,
        );
      default:
        return (
          e.message ?? 'An unexpected error occurred. Please try again.',
          true,
        );
    }
  }

  /// Check if an error is retryable based on the error code.
  static bool isRetryableError(Exception e) {
    // Check FirebaseFunctionsException first as it may extend FirebaseException
    if (e is FirebaseFunctionsException) {
      return _isRetryableCloudFunctionError(e);
    } else if (e is FirebaseException) {
      return _isRetryableFirestoreError(e);
    }
    return true;
  }

  /// Check if a Firestore error is retryable.
  static bool _isRetryableFirestoreError(FirebaseException e) {
    const retryableCodes = {
      'unavailable',
      'deadline-exceeded',
      'aborted',
      'cancelled',
      'resource-exhausted',
    };
    return retryableCodes.contains(e.code);
  }

  /// Check if a Cloud Function error is retryable.
  static bool _isRetryableCloudFunctionError(FirebaseFunctionsException e) {
    const retryableCodes = {
      'unavailable',
      'deadline-exceeded',
      'internal',
    };
    return retryableCodes.contains(e.code);
  }
}

/// Group-specific error messages.
class GroupErrorMessages {
  /// Get error message for group operations.
  static (String message, bool isRetryable) getErrorMessage(Exception e) {
    // Check for custom GroupException first
    if (e is GroupException) {
      return (e.message, ErrorMessages._isRetryableByCode(e.code));
    }

    final errorMessage = e.toString().toLowerCase();

    // Check for specific group-related errors
    if (errorMessage.contains('already a member')) {
      return (
        'You\'re already a member of this group',
        false,
      );
    } else if (errorMessage.contains('group deleted') ||
        errorMessage.contains('group not found')) {
      return (
        'Group deleted or unavailable',
        false,
      );
    } else if (errorMessage.contains('group is full') ||
        errorMessage.contains('at capacity')) {
      return (
        'This group is full',
        false,
      );
    } else if (errorMessage.contains('not an admin')) {
      return (
        'Only group admins can perform this action',
        false,
      );
    }

    // Fall back to generic error message handling
    return ErrorMessages.getErrorMessage(e);
  }
}

/// Invitation-specific error messages.
class InvitationErrorMessages {
  /// Get error message for invitation operations.
  static (String message, bool isRetryable) getErrorMessage(Exception e) {
    // Check for custom InvitationException first
    if (e is InvitationException) {
      return (e.message, ErrorMessages._isRetryableByCode(e.code));
    }

    final errorMessage = e.toString().toLowerCase();

    // Check for specific invitation-related errors
    if (errorMessage.contains('user not found') ||
        errorMessage.contains('invitee not found')) {
      return (
        'User not found. Please check the email address.',
        false,
      );
    } else if (errorMessage.contains('already invited') ||
        errorMessage.contains('invitation exists')) {
      return (
        'This user has already been invited',
        false,
      );
    } else if (errorMessage.contains('already a member')) {
      return (
        'This user is already a member of the group',
        false,
      );
    } else if (errorMessage.contains('invitation not found')) {
      return (
        'Invitation not found or has expired',
        false,
      );
    } else if (errorMessage.contains('cannot invite yourself')) {
      return (
        'You cannot invite yourself to a group',
        false,
      );
    }

    // Fall back to generic error message handling
    return ErrorMessages.getErrorMessage(e);
  }
}

/// Group invite link-specific error messages.
class GroupInviteLinkErrorMessages {
  /// Get error message for group invite link operations.
  static (String message, bool isRetryable) getErrorMessage(Exception e) {
    if (e is GroupInviteLinkException) {
      return (e.message, ErrorMessages._isRetryableByCode(e.code));
    }

    // Fall back to generic error message handling
    return ErrorMessages.getErrorMessage(e);
  }
}
