// Tests for TrainingSessionModel cancel-related functionality (Story 15.14)

import 'package:flutter_test/flutter_test.dart';
import 'package:play_with_me/core/data/models/game_model.dart';
import 'package:play_with_me/core/data/models/training_session_model.dart';

void main() {
  group('TrainingSessionModel - Cancel functionality', () {
    late TrainingSessionModel scheduledSession;
    late TrainingSessionModel completedSession;
    late TrainingSessionModel cancelledSession;

    const creatorUserId = 'creator-123';
    const otherUserId = 'other-456';

    setUp(() {
      scheduledSession = TrainingSessionModel(
        id: 'session-1',
        groupId: 'group-1',
        title: 'Test Training',
        location: const GameLocation(name: 'Beach Court 1', address: '123 Beach Rd'),
        startTime: DateTime.now().add(const Duration(days: 1)),
        endTime: DateTime.now().add(const Duration(days: 1, hours: 2)),
        minParticipants: 4,
        maxParticipants: 8,
        createdBy: creatorUserId,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        status: TrainingStatus.scheduled,
        participantIds: ['user1', 'user2'],
      );

      completedSession = scheduledSession.copyWith(
        status: TrainingStatus.completed,
      );

      cancelledSession = scheduledSession.copyWith(
        status: TrainingStatus.cancelled,
        cancelledBy: creatorUserId,
        cancelledAt: DateTime.now(),
      );
    });

    group('canUserCancel', () {
      test('returns true when user is creator and session is scheduled', () {
        expect(scheduledSession.canUserCancel(creatorUserId), isTrue);
      });

      test('returns false when user is not the creator', () {
        expect(scheduledSession.canUserCancel(otherUserId), isFalse);
      });

      test('returns false when session is already completed', () {
        expect(completedSession.canUserCancel(creatorUserId), isFalse);
      });

      test('returns false when session is already cancelled', () {
        expect(cancelledSession.canUserCancel(creatorUserId), isFalse);
      });

      test('returns false when user is not creator and session is completed', () {
        expect(completedSession.canUserCancel(otherUserId), isFalse);
      });

      test('returns false when user is not creator and session is cancelled', () {
        expect(cancelledSession.canUserCancel(otherUserId), isFalse);
      });
    });

    group('cancelSession', () {
      test('sets status to cancelled when session is scheduled', () {
        final result = scheduledSession.cancelSession(creatorUserId);

        expect(result.status, equals(TrainingStatus.cancelled));
      });

      test('sets cancelledBy to the user who cancelled', () {
        final result = scheduledSession.cancelSession(creatorUserId);

        expect(result.cancelledBy, equals(creatorUserId));
      });

      test('sets cancelledAt to current time', () {
        final before = DateTime.now();
        final result = scheduledSession.cancelSession(creatorUserId);
        final after = DateTime.now();

        expect(result.cancelledAt, isNotNull);
        expect(result.cancelledAt!.isAfter(before.subtract(const Duration(seconds: 1))), isTrue);
        expect(result.cancelledAt!.isBefore(after.add(const Duration(seconds: 1))), isTrue);
      });

      test('sets updatedAt to current time', () {
        final before = DateTime.now();
        final result = scheduledSession.cancelSession(creatorUserId);
        final after = DateTime.now();

        expect(result.updatedAt, isNotNull);
        expect(result.updatedAt!.isAfter(before.subtract(const Duration(seconds: 1))), isTrue);
        expect(result.updatedAt!.isBefore(after.add(const Duration(seconds: 1))), isTrue);
      });

      test('returns same session when already completed (no-op)', () {
        final result = completedSession.cancelSession(creatorUserId);

        // Should return the same session without changes
        expect(result.status, equals(TrainingStatus.completed));
        expect(result.cancelledBy, isNull);
        expect(result.cancelledAt, isNull);
      });

      test('returns same session when already cancelled (no-op)', () {
        final originalCancelledAt = cancelledSession.cancelledAt;
        final result = cancelledSession.cancelSession(creatorUserId);

        // Should return the same session without changes
        expect(result.status, equals(TrainingStatus.cancelled));
        expect(result.cancelledAt, equals(originalCancelledAt));
      });

      test('allows cancellation without userId for system-triggered cancellations', () {
        final result = scheduledSession.cancelSession();

        expect(result.status, equals(TrainingStatus.cancelled));
        expect(result.cancelledBy, isNull); // No user specified for system cancellation
        expect(result.cancelledAt, isNotNull);
      });

      test('preserves other session properties when cancelling', () {
        final result = scheduledSession.cancelSession(creatorUserId);

        expect(result.id, equals(scheduledSession.id));
        expect(result.groupId, equals(scheduledSession.groupId));
        expect(result.title, equals(scheduledSession.title));
        expect(result.location, equals(scheduledSession.location));
        expect(result.startTime, equals(scheduledSession.startTime));
        expect(result.endTime, equals(scheduledSession.endTime));
        expect(result.minParticipants, equals(scheduledSession.minParticipants));
        expect(result.maxParticipants, equals(scheduledSession.maxParticipants));
        expect(result.createdBy, equals(scheduledSession.createdBy));
        expect(result.participantIds, equals(scheduledSession.participantIds));
      });
    });

    group('isCreator', () {
      test('returns true for the creator', () {
        expect(scheduledSession.isCreator(creatorUserId), isTrue);
      });

      test('returns false for non-creator', () {
        expect(scheduledSession.isCreator(otherUserId), isFalse);
      });
    });
  });
}
