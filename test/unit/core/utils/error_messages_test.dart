// Validates error message utility functions convert exceptions to user-friendly messages.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:play_with_me/core/utils/error_messages.dart';

void main() {
  group('ErrorMessages', () {
    group('Firestore errors', () {
      test('returns friendly message for permission-denied error', () {
        final exception = FirebaseException(
          plugin: 'firestore',
          code: 'permission-denied',
        );

        final (message, isRetryable) = ErrorMessages.getErrorMessage(exception);

        expect(message, 'You don\'t have permission to perform this action');
        expect(isRetryable, false);
      });

      test('returns friendly message for unavailable error', () {
        final exception = FirebaseException(
          plugin: 'firestore',
          code: 'unavailable',
        );

        final (message, isRetryable) = ErrorMessages.getErrorMessage(exception);

        expect(message, 'Service temporarily unavailable. Please try again.');
        expect(isRetryable, true);
      });

      test('returns friendly message for not-found error', () {
        final exception = FirebaseException(
          plugin: 'firestore',
          code: 'not-found',
        );

        final (message, isRetryable) = ErrorMessages.getErrorMessage(exception);

        expect(message, 'The requested resource was not found');
        expect(isRetryable, false);
      });

      test('returns friendly message for deadline-exceeded error', () {
        final exception = FirebaseException(
          plugin: 'firestore',
          code: 'deadline-exceeded',
        );

        final (message, isRetryable) = ErrorMessages.getErrorMessage(exception);

        expect(message, 'Request timed out. Check your connection.');
        expect(isRetryable, true);
      });

      test('returns friendly message for already-exists error', () {
        final exception = FirebaseException(
          plugin: 'firestore',
          code: 'already-exists',
        );

        final (message, isRetryable) = ErrorMessages.getErrorMessage(exception);

        expect(message, 'This action has already been performed');
        expect(isRetryable, false);
      });

      test('returns friendly message for unauthenticated error', () {
        final exception = FirebaseException(
          plugin: 'firestore',
          code: 'unauthenticated',
        );

        final (message, isRetryable) = ErrorMessages.getErrorMessage(exception);

        expect(message, 'You must be logged in to perform this action');
        expect(isRetryable, false);
      });

      test('returns friendly message for aborted error', () {
        final exception = FirebaseException(
          plugin: 'firestore',
          code: 'aborted',
        );

        final (message, isRetryable) = ErrorMessages.getErrorMessage(exception);

        expect(message, 'Operation was interrupted. Please try again.');
        expect(isRetryable, true);
      });

      test('returns friendly message for resource-exhausted error', () {
        final exception = FirebaseException(
          plugin: 'firestore',
          code: 'resource-exhausted',
        );

        final (message, isRetryable) = ErrorMessages.getErrorMessage(exception);

        expect(message, 'Too many requests. Please wait a moment.');
        expect(isRetryable, true);
      });

      test('returns custom message for unknown Firestore error', () {
        final exception = FirebaseException(
          plugin: 'firestore',
          code: 'unknown-error',
          message: 'Custom error message',
        );

        final (message, isRetryable) = ErrorMessages.getErrorMessage(exception);

        expect(message, 'Custom error message');
        expect(isRetryable, true);
      });
    });

    group('Cloud Function errors', () {
      test('returns friendly message for unauthenticated error', () {
        final exception = FirebaseFunctionsException(
          code: 'unauthenticated',
          message: 'User not authenticated',
        );

        final (message, isRetryable) = ErrorMessages.getErrorMessage(exception);

        expect(message, 'You must be logged in to perform this action');
        expect(isRetryable, false);
      });

      test('returns friendly message for permission-denied error', () {
        final exception = FirebaseFunctionsException(
          code: 'permission-denied',
          message: 'Permission denied',
        );

        final (message, isRetryable) = ErrorMessages.getErrorMessage(exception);

        expect(message, 'You don\'t have permission to perform this action');
        expect(isRetryable, false);
      });

      test('returns friendly message for not-found error', () {
        final exception = FirebaseFunctionsException(
          code: 'not-found',
          message: 'Resource not found',
        );

        final (message, isRetryable) = ErrorMessages.getErrorMessage(exception);

        // Cloud Functions return their own message for not-found
        expect(message, 'Resource not found');
        expect(isRetryable, false);
      });

      test('returns friendly message for invalid-argument error', () {
        final exception = FirebaseFunctionsException(
          code: 'invalid-argument',
          message: 'Invalid argument',
        );

        final (message, isRetryable) = ErrorMessages.getErrorMessage(exception);

        // Cloud Functions return their own message, not a generic one
        expect(message, 'Invalid argument');
        expect(isRetryable, false);
      });

      test('returns friendly message for internal error', () {
        final exception = FirebaseFunctionsException(
          code: 'internal',
          message: 'Internal error',
        );

        final (message, isRetryable) = ErrorMessages.getErrorMessage(exception);

        // Cloud Functions return their own message, not a generic one
        expect(message, 'Internal error');
        expect(isRetryable, true);
      });

      test('returns friendly message for unavailable error', () {
        final exception = FirebaseFunctionsException(
          code: 'unavailable',
          message: 'Service unavailable',
        );

        final (message, isRetryable) = ErrorMessages.getErrorMessage(exception);

        expect(message, 'Service temporarily unavailable. Please try again.');
        expect(isRetryable, true);
      });
    });

    group('isRetryableError', () {
      test('returns true for unavailable Firestore error', () {
        final exception = FirebaseException(
          plugin: 'firestore',
          code: 'unavailable',
        );

        expect(ErrorMessages.isRetryableError(exception), true);
      });

      test('returns true for deadline-exceeded Firestore error', () {
        final exception = FirebaseException(
          plugin: 'firestore',
          code: 'deadline-exceeded',
        );

        expect(ErrorMessages.isRetryableError(exception), true);
      });

      test('returns true for aborted Firestore error', () {
        final exception = FirebaseException(
          plugin: 'firestore',
          code: 'aborted',
        );

        expect(ErrorMessages.isRetryableError(exception), true);
      });

      test('returns false for permission-denied Firestore error', () {
        final exception = FirebaseException(
          plugin: 'firestore',
          code: 'permission-denied',
        );

        expect(ErrorMessages.isRetryableError(exception), false);
      });

      test('returns false for not-found Firestore error', () {
        final exception = FirebaseException(
          plugin: 'firestore',
          code: 'not-found',
        );

        expect(ErrorMessages.isRetryableError(exception), false);
      });

      test('returns true for unavailable Cloud Function error', () {
        final exception = FirebaseFunctionsException(
          code: 'unavailable',
          message: 'Service unavailable',
        );

        expect(ErrorMessages.isRetryableError(exception), true);
      });

      test('returns false for invalid-argument Cloud Function error', () {
        final exception = FirebaseFunctionsException(
          code: 'invalid-argument',
          message: 'Invalid argument',
        );

        expect(ErrorMessages.isRetryableError(exception), false);
      });

      test('returns true for non-Firebase exception', () {
        final exception = Exception('Generic error');

        expect(ErrorMessages.isRetryableError(exception), true);
      });
    });

    group('Generic errors', () {
      test('returns default message for non-Firebase exception', () {
        final exception = Exception('Generic error');

        final (message, isRetryable) = ErrorMessages.getErrorMessage(exception);

        expect(message, 'An unexpected error occurred. Please try again.');
        expect(isRetryable, true);
      });
    });
  });

  group('GroupErrorMessages', () {
    test('returns specific message for "already a member" error', () {
      final exception = Exception('User already a member of this group');

      final (message, isRetryable) = GroupErrorMessages.getErrorMessage(exception);

      expect(message, 'You\'re already a member of this group');
      expect(isRetryable, false);
    });

    test('returns specific message for "group deleted" error', () {
      final exception = Exception('Group deleted by admin');

      final (message, isRetryable) = GroupErrorMessages.getErrorMessage(exception);

      expect(message, 'Group deleted or unavailable');
      expect(isRetryable, false);
    });

    test('returns specific message for "group not found" error', () {
      final exception = Exception('Group not found in database');

      final (message, isRetryable) = GroupErrorMessages.getErrorMessage(exception);

      expect(message, 'Group deleted or unavailable');
      expect(isRetryable, false);
    });

    test('returns specific message for "group is full" error', () {
      final exception = Exception('Group is full, cannot add more members');

      final (message, isRetryable) = GroupErrorMessages.getErrorMessage(exception);

      expect(message, 'This group is full');
      expect(isRetryable, false);
    });

    test('returns specific message for "at capacity" error', () {
      final exception = Exception('Group at capacity');

      final (message, isRetryable) = GroupErrorMessages.getErrorMessage(exception);

      expect(message, 'This group is full');
      expect(isRetryable, false);
    });

    test('returns specific message for "not an admin" error', () {
      final exception = Exception('User not an admin of this group');

      final (message, isRetryable) = GroupErrorMessages.getErrorMessage(exception);

      expect(message, 'Only group admins can perform this action');
      expect(isRetryable, false);
    });

    test('falls back to generic error handler for unknown error', () {
      final exception = FirebaseException(
        plugin: 'firestore',
        code: 'permission-denied',
      );

      final (message, isRetryable) = GroupErrorMessages.getErrorMessage(exception);

      expect(message, 'You don\'t have permission to perform this action');
      expect(isRetryable, false);
    });
  });

  group('InvitationErrorMessages', () {
    test('returns specific message for "user not found" error', () {
      final exception = Exception('User not found in system');

      final (message, isRetryable) = InvitationErrorMessages.getErrorMessage(exception);

      expect(message, 'User not found. Please check the email address.');
      expect(isRetryable, false);
    });

    test('returns specific message for "invitee not found" error', () {
      final exception = Exception('Invitee not found');

      final (message, isRetryable) = InvitationErrorMessages.getErrorMessage(exception);

      expect(message, 'User not found. Please check the email address.');
      expect(isRetryable, false);
    });

    test('returns specific message for "already invited" error', () {
      final exception = Exception('User already invited to this group');

      final (message, isRetryable) = InvitationErrorMessages.getErrorMessage(exception);

      expect(message, 'This user has already been invited');
      expect(isRetryable, false);
    });

    test('returns specific message for "invitation exists" error', () {
      final exception = Exception('Invitation exists for this user');

      final (message, isRetryable) = InvitationErrorMessages.getErrorMessage(exception);

      expect(message, 'This user has already been invited');
      expect(isRetryable, false);
    });

    test('returns specific message for "already a member" error', () {
      final exception = Exception('User already a member of group');

      final (message, isRetryable) = InvitationErrorMessages.getErrorMessage(exception);

      expect(message, 'This user is already a member of the group');
      expect(isRetryable, false);
    });

    test('returns specific message for "invitation not found" error', () {
      final exception = Exception('Invitation not found in database');

      final (message, isRetryable) = InvitationErrorMessages.getErrorMessage(exception);

      expect(message, 'Invitation not found or has expired');
      expect(isRetryable, false);
    });

    test('returns specific message for "cannot invite yourself" error', () {
      final exception = Exception('Cannot invite yourself to a group');

      final (message, isRetryable) = InvitationErrorMessages.getErrorMessage(exception);

      expect(message, 'You cannot invite yourself to a group');
      expect(isRetryable, false);
    });

    test('falls back to generic error handler for unknown error', () {
      final exception = FirebaseException(
        plugin: 'firestore',
        code: 'unavailable',
      );

      final (message, isRetryable) = InvitationErrorMessages.getErrorMessage(exception);

      expect(message, 'Service temporarily unavailable. Please try again.');
      expect(isRetryable, true);
    });
  });
}
