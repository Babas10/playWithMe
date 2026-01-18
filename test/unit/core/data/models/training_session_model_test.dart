// Tests TrainingSessionModel for training session functionality (Story 16.3.3.2).

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:play_with_me/core/data/models/game_model.dart';
import 'package:play_with_me/core/data/models/recurrence_rule_model.dart';
import 'package:play_with_me/core/data/models/training_session_model.dart';

void main() {
  group('TrainingSessionModel', () {
    late DateTime now;
    late DateTime futureStart;
    late DateTime futureEnd;
    late DateTime pastStart;
    late DateTime pastEnd;
    late DateTime createdAt;
    late TrainingSessionModel baseSession;

    const testLocation = GameLocation(name: 'Beach Court 1', address: '123 Beach Rd');

    setUp(() {
      now = DateTime.now();
      futureStart = now.add(const Duration(days: 1));
      futureEnd = now.add(const Duration(days: 1, hours: 2));
      pastStart = now.subtract(const Duration(days: 1));
      pastEnd = now.subtract(const Duration(days: 1)).add(const Duration(hours: 2));
      createdAt = now.subtract(const Duration(days: 7));

      baseSession = TrainingSessionModel(
        id: 'session-123',
        groupId: 'group-456',
        title: 'Morning Practice',
        description: 'Beach volleyball drills',
        location: testLocation,
        startTime: futureStart,
        endTime: futureEnd,
        minParticipants: 4,
        maxParticipants: 8,
        createdBy: 'creator-user',
        createdAt: createdAt,
        participantIds: ['user-1', 'user-2', 'user-3'],
      );
    });

    group('constructor', () {
      test('creates instance with all required fields', () {
        expect(baseSession.id, equals('session-123'));
        expect(baseSession.groupId, equals('group-456'));
        expect(baseSession.title, equals('Morning Practice'));
        expect(baseSession.description, equals('Beach volleyball drills'));
        expect(baseSession.location, equals(testLocation));
        expect(baseSession.startTime, equals(futureStart));
        expect(baseSession.endTime, equals(futureEnd));
        expect(baseSession.minParticipants, equals(4));
        expect(baseSession.maxParticipants, equals(8));
        expect(baseSession.createdBy, equals('creator-user'));
        expect(baseSession.createdAt, equals(createdAt));
        expect(baseSession.participantIds.length, equals(3));
      });

      test('creates instance with default values', () {
        final session = TrainingSessionModel(
          id: 'session-1',
          groupId: 'group-1',
          title: 'Test Session',
          location: testLocation,
          startTime: futureStart,
          endTime: futureEnd,
          minParticipants: 2,
          maxParticipants: 4,
          createdBy: 'creator',
          createdAt: createdAt,
        );

        expect(session.description, isNull);
        expect(session.updatedAt, isNull);
        expect(session.recurrenceRule, isNull);
        expect(session.parentSessionId, isNull);
        expect(session.status, equals(TrainingStatus.scheduled));
        expect(session.participantIds, isEmpty);
        expect(session.notes, isNull);
        expect(session.cancelledBy, isNull);
        expect(session.cancelledAt, isNull);
      });
    });

    group('isParticipant', () {
      test('returns true for existing participant', () {
        expect(baseSession.isParticipant('user-1'), isTrue);
        expect(baseSession.isParticipant('user-2'), isTrue);
      });

      test('returns false for non-participant', () {
        expect(baseSession.isParticipant('user-99'), isFalse);
      });
    });

    group('isCreator', () {
      test('returns true for creator', () {
        expect(baseSession.isCreator('creator-user'), isTrue);
      });

      test('returns false for non-creator', () {
        expect(baseSession.isCreator('other-user'), isFalse);
      });
    });

    group('canManage', () {
      test('returns true for creator', () {
        expect(baseSession.canManage('creator-user'), isTrue);
      });

      test('returns false for non-creator', () {
        expect(baseSession.canManage('other-user'), isFalse);
      });
    });

    group('isFull', () {
      test('returns false when not at max capacity', () {
        expect(baseSession.isFull, isFalse); // 3 of 8
      });

      test('returns true when at max capacity', () {
        final fullSession = baseSession.copyWith(
          participantIds: ['u1', 'u2', 'u3', 'u4', 'u5', 'u6', 'u7', 'u8'],
        );
        expect(fullSession.isFull, isTrue);
      });
    });

    group('hasMinimumParticipants', () {
      test('returns false when below minimum', () {
        expect(baseSession.hasMinimumParticipants, isFalse); // 3 of 4 minimum
      });

      test('returns true when at or above minimum', () {
        final session = baseSession.copyWith(
          participantIds: ['u1', 'u2', 'u3', 'u4'],
        );
        expect(session.hasMinimumParticipants, isTrue);
      });
    });

    group('availableSpots', () {
      test('calculates available spots correctly', () {
        expect(baseSession.availableSpots, equals(5)); // 8 - 3
      });

      test('returns 0 when full', () {
        final fullSession = baseSession.copyWith(
          participantIds: ['u1', 'u2', 'u3', 'u4', 'u5', 'u6', 'u7', 'u8'],
        );
        expect(fullSession.availableSpots, equals(0));
      });
    });

    group('currentParticipantCount', () {
      test('returns correct count', () {
        expect(baseSession.currentParticipantCount, equals(3));
      });

      test('returns 0 for empty session', () {
        final emptySession = baseSession.copyWith(participantIds: []);
        expect(emptySession.currentParticipantCount, equals(0));
      });
    });

    group('isPast', () {
      test('returns false for future session', () {
        expect(baseSession.isPast, isFalse);
      });

      test('returns true for past session', () {
        final pastSession = baseSession.copyWith(startTime: pastStart);
        expect(pastSession.isPast, isTrue);
      });
    });

    group('isToday', () {
      test('returns true for session starting today', () {
        final todaySession = baseSession.copyWith(
          startTime: DateTime(now.year, now.month, now.day, 18, 0),
        );
        expect(todaySession.isToday, isTrue);
      });

      test('returns false for session not today', () {
        expect(baseSession.isToday, isFalse); // Tomorrow
      });
    });

    group('isThisWeek', () {
      test('returns true for session this week', () {
        // Create a session in the middle of this week
        final midWeek = now.add(Duration(days: (7 - now.weekday) ~/ 2));
        final thisWeekSession = baseSession.copyWith(startTime: midWeek);
        expect(thisWeekSession.isThisWeek, isTrue);
      });
    });

    group('duration', () {
      test('calculates duration correctly', () {
        expect(baseSession.duration, equals(const Duration(hours: 2)));
      });

      test('handles different durations', () {
        final longSession = baseSession.copyWith(
          endTime: futureStart.add(const Duration(hours: 4)),
        );
        expect(longSession.duration, equals(const Duration(hours: 4)));
      });
    });

    group('canUserJoin', () {
      test('returns true for eligible user', () {
        expect(baseSession.canUserJoin('new-user'), isTrue);
      });

      test('returns false for existing participant', () {
        expect(baseSession.canUserJoin('user-1'), isFalse);
      });

      test('returns false when session is full', () {
        final fullSession = baseSession.copyWith(
          participantIds: ['u1', 'u2', 'u3', 'u4', 'u5', 'u6', 'u7', 'u8'],
        );
        expect(fullSession.canUserJoin('new-user'), isFalse);
      });

      test('returns false when session is cancelled', () {
        final cancelledSession = baseSession.copyWith(
          status: TrainingStatus.cancelled,
        );
        expect(cancelledSession.canUserJoin('new-user'), isFalse);
      });

      test('returns false when session is completed', () {
        final completedSession = baseSession.copyWith(
          status: TrainingStatus.completed,
        );
        expect(completedSession.canUserJoin('new-user'), isFalse);
      });

      test('returns false when session is past', () {
        final pastSession = baseSession.copyWith(startTime: pastStart);
        expect(pastSession.canUserJoin('new-user'), isFalse);
      });
    });

    group('canUserLeave', () {
      test('returns true for participant in scheduled session', () {
        expect(baseSession.canUserLeave('user-1'), isTrue);
      });

      test('returns false for non-participant', () {
        expect(baseSession.canUserLeave('non-participant'), isFalse);
      });

      test('returns false when session is cancelled', () {
        final cancelledSession = baseSession.copyWith(
          status: TrainingStatus.cancelled,
        );
        expect(cancelledSession.canUserLeave('user-1'), isFalse);
      });

      test('returns false when session is completed', () {
        final completedSession = baseSession.copyWith(
          status: TrainingStatus.completed,
        );
        expect(completedSession.canUserLeave('user-1'), isFalse);
      });
    });

    group('hasValidTiming', () {
      test('returns true for valid future session', () {
        expect(baseSession.hasValidTiming, isTrue);
      });

      test('returns false for past session', () {
        final pastSession = baseSession.copyWith(
          startTime: pastStart,
          endTime: pastEnd,
        );
        expect(pastSession.hasValidTiming, isFalse);
      });

      test('returns false when endTime is before startTime', () {
        final invalidSession = baseSession.copyWith(
          startTime: futureStart,
          endTime: futureStart.subtract(const Duration(hours: 1)),
        );
        expect(invalidSession.hasValidTiming, isFalse);
      });
    });

    group('hasValidParticipantLimits', () {
      test('returns true for valid limits', () {
        expect(baseSession.hasValidParticipantLimits, isTrue);
      });

      test('returns false when min > max', () {
        final invalidSession = baseSession.copyWith(
          minParticipants: 10,
          maxParticipants: 5,
        );
        expect(invalidSession.hasValidParticipantLimits, isFalse);
      });

      test('returns false when min < 2', () {
        final invalidSession = baseSession.copyWith(
          minParticipants: 1,
          maxParticipants: 4,
        );
        expect(invalidSession.hasValidParticipantLimits, isFalse);
      });

      test('returns true when min equals max', () {
        final session = baseSession.copyWith(
          minParticipants: 4,
          maxParticipants: 4,
        );
        expect(session.hasValidParticipantLimits, isTrue);
      });
    });

    group('updateInfo', () {
      test('updates title', () {
        final updated = baseSession.updateInfo(title: 'New Title');
        expect(updated.title, equals('New Title'));
        expect(updated.updatedAt, isNotNull);
      });

      test('updates description', () {
        final updated = baseSession.updateInfo(description: 'New description');
        expect(updated.description, equals('New description'));
      });

      test('updates startTime and endTime', () {
        final newStart = now.add(const Duration(days: 3));
        final newEnd = now.add(const Duration(days: 3, hours: 3));
        final updated = baseSession.updateInfo(startTime: newStart, endTime: newEnd);
        expect(updated.startTime, equals(newStart));
        expect(updated.endTime, equals(newEnd));
      });

      test('updates location', () {
        const newLocation = GameLocation(name: 'New Court', address: '456 New Rd');
        final updated = baseSession.updateInfo(location: newLocation);
        expect(updated.location, equals(newLocation));
      });

      test('updates notes', () {
        final updated = baseSession.updateInfo(notes: 'Bring sunscreen');
        expect(updated.notes, equals('Bring sunscreen'));
      });

      test('preserves unchanged fields', () {
        final updated = baseSession.updateInfo(title: 'New Title');
        expect(updated.groupId, equals(baseSession.groupId));
        expect(updated.createdBy, equals(baseSession.createdBy));
        expect(updated.participantIds, equals(baseSession.participantIds));
      });
    });

    group('updateSettings', () {
      test('updates maxParticipants', () {
        final updated = baseSession.updateSettings(maxParticipants: 12);
        expect(updated.maxParticipants, equals(12));
        expect(updated.updatedAt, isNotNull);
      });

      test('updates minParticipants', () {
        final updated = baseSession.updateSettings(minParticipants: 6);
        expect(updated.minParticipants, equals(6));
      });

      test('updates both settings', () {
        final updated = baseSession.updateSettings(
          minParticipants: 6,
          maxParticipants: 12,
        );
        expect(updated.minParticipants, equals(6));
        expect(updated.maxParticipants, equals(12));
      });
    });

    group('addParticipant', () {
      test('adds new participant', () {
        final updated = baseSession.addParticipant('new-user');
        expect(updated.participantIds.contains('new-user'), isTrue);
        expect(updated.participantIds.length, equals(4));
        expect(updated.updatedAt, isNotNull);
      });

      test('does not add existing participant', () {
        final updated = baseSession.addParticipant('user-1');
        expect(updated.participantIds.length, equals(3)); // No change
      });

      test('does not add when full', () {
        final fullSession = baseSession.copyWith(
          participantIds: ['u1', 'u2', 'u3', 'u4', 'u5', 'u6', 'u7', 'u8'],
        );
        final updated = fullSession.addParticipant('new-user');
        expect(updated.participantIds.length, equals(8)); // No change
      });
    });

    group('removeParticipant', () {
      test('removes existing participant', () {
        final updated = baseSession.removeParticipant('user-1');
        expect(updated.participantIds.contains('user-1'), isFalse);
        expect(updated.participantIds.length, equals(2));
        expect(updated.updatedAt, isNotNull);
      });

      test('handles removing non-existent participant', () {
        final updated = baseSession.removeParticipant('non-existent');
        expect(updated.participantIds.length, equals(3)); // No change
      });
    });

    group('completeSession', () {
      test('sets status to completed when scheduled', () {
        final completed = baseSession.completeSession();
        expect(completed.status, equals(TrainingStatus.completed));
        expect(completed.updatedAt, isNotNull);
      });

      test('does not change already cancelled session', () {
        final cancelledSession = baseSession.copyWith(
          status: TrainingStatus.cancelled,
        );
        final result = cancelledSession.completeSession();
        expect(result.status, equals(TrainingStatus.cancelled));
      });

      test('does not change already completed session', () {
        final completedSession = baseSession.copyWith(
          status: TrainingStatus.completed,
        );
        final result = completedSession.completeSession();
        expect(result.status, equals(TrainingStatus.completed));
      });
    });

    group('getTimeUntilSession', () {
      test('returns "Past" for past session', () {
        final pastSession = baseSession.copyWith(startTime: pastStart);
        expect(pastSession.getTimeUntilSession(), equals('Past'));
      });

      test('returns formatted days and hours for far future', () {
        final farFuture = now.add(const Duration(days: 5, hours: 12));
        final session = baseSession.copyWith(startTime: farFuture);
        final result = session.getTimeUntilSession();
        expect(result, contains('d'));
        expect(result, contains('h'));
      });

      test('returns formatted hours and minutes for same day', () {
        final soonStart = now.add(const Duration(hours: 3, minutes: 30));
        final session = baseSession.copyWith(startTime: soonStart);
        final result = session.getTimeUntilSession();
        expect(result, contains('h'));
        expect(result, contains('m'));
      });

      test('returns formatted minutes for very soon', () {
        final verySoon = now.add(const Duration(minutes: 45));
        final session = baseSession.copyWith(startTime: verySoon);
        final result = session.getTimeUntilSession();
        expect(result, contains('m'));
      });
    });

    group('recurrence-related getters', () {
      test('isRecurring returns false when no recurrence rule', () {
        expect(baseSession.isRecurring, isFalse);
      });

      test('isRecurring returns true when has valid recurrence rule', () {
        final recurringSession = baseSession.copyWith(
          recurrenceRule: RecurrenceRuleModel.weekly(count: 10),
        );
        expect(recurringSession.isRecurring, isTrue);
      });

      test('isRecurring returns false when recurrence is none', () {
        final session = baseSession.copyWith(
          recurrenceRule: RecurrenceRuleModel.none(),
        );
        expect(session.isRecurring, isFalse);
      });

      test('isRecurrenceInstance returns false when no parent', () {
        expect(baseSession.isRecurrenceInstance, isFalse);
      });

      test('isRecurrenceInstance returns true when has parent', () {
        final childSession = baseSession.copyWith(
          parentSessionId: 'parent-session-123',
        );
        expect(childSession.isRecurrenceInstance, isTrue);
      });

      test('isParentRecurringSession returns true for parent', () {
        final parentSession = baseSession.copyWith(
          recurrenceRule: RecurrenceRuleModel.weekly(count: 10),
        );
        expect(parentSession.isParentRecurringSession, isTrue);
      });

      test('isParentRecurringSession returns false for child', () {
        final childSession = baseSession.copyWith(
          recurrenceRule: RecurrenceRuleModel.weekly(count: 10),
          parentSessionId: 'parent-session-123',
        );
        expect(childSession.isParentRecurringSession, isFalse);
      });

      test('recurrenceDescription returns null when no rule', () {
        expect(baseSession.recurrenceDescription, isNull);
      });

      test('recurrenceDescription returns description when has rule', () {
        final recurringSession = baseSession.copyWith(
          recurrenceRule: RecurrenceRuleModel.weekly(count: 10),
        );
        expect(recurringSession.recurrenceDescription, isNotNull);
        expect(recurringSession.recurrenceDescription, contains('weekly'));
      });
    });

    group('fromJson', () {
      test('deserializes from JSON with all fields', () {
        // Note: fromJson expects ISO8601 strings for DateTime fields
        // Timestamps are handled by fromFirestore method
        final json = {
          'id': 'session-123',
          'groupId': 'group-456',
          'title': 'Morning Practice',
          'description': 'Beach volleyball drills',
          'location': {'name': 'Beach Court 1', 'address': '123 Beach Rd'},
          'startTime': futureStart.toIso8601String(),
          'endTime': futureEnd.toIso8601String(),
          'minParticipants': 4,
          'maxParticipants': 8,
          'createdBy': 'creator-user',
          'createdAt': createdAt.toIso8601String(),
          'participantIds': ['user-1', 'user-2'],
          'status': 'scheduled',
        };

        final session = TrainingSessionModel.fromJson(json);

        expect(session.id, equals('session-123'));
        expect(session.groupId, equals('group-456'));
        expect(session.title, equals('Morning Practice'));
        expect(session.description, equals('Beach volleyball drills'));
        expect(session.location.name, equals('Beach Court 1'));
        expect(session.minParticipants, equals(4));
        expect(session.maxParticipants, equals(8));
        expect(session.createdBy, equals('creator-user'));
        expect(session.participantIds.length, equals(2));
        expect(session.status, equals(TrainingStatus.scheduled));
      });

      test('deserializes with ISO string dates', () {
        final json = {
          'id': 'session-123',
          'groupId': 'group-456',
          'title': 'Morning Practice',
          'location': {'name': 'Beach Court 1'},
          'startTime': futureStart.toIso8601String(),
          'endTime': futureEnd.toIso8601String(),
          'minParticipants': 4,
          'maxParticipants': 8,
          'createdBy': 'creator-user',
          'createdAt': createdAt.toIso8601String(),
          'status': 'scheduled',
        };

        final session = TrainingSessionModel.fromJson(json);

        expect(session.startTime.year, equals(futureStart.year));
        expect(session.startTime.month, equals(futureStart.month));
        expect(session.startTime.day, equals(futureStart.day));
      });

      test('deserializes with recurrence rule', () {
        final json = {
          'id': 'session-123',
          'groupId': 'group-456',
          'title': 'Recurring Session',
          'location': {'name': 'Beach Court 1'},
          'startTime': futureStart.toIso8601String(),
          'endTime': futureEnd.toIso8601String(),
          'minParticipants': 4,
          'maxParticipants': 8,
          'createdBy': 'creator-user',
          'createdAt': createdAt.toIso8601String(),
          'recurrenceRule': {
            'frequency': 'weekly',
            'interval': 1,
            'count': 10,
          },
          'status': 'scheduled',
        };

        final session = TrainingSessionModel.fromJson(json);

        expect(session.recurrenceRule, isNotNull);
        expect(session.recurrenceRule!.frequency, equals(RecurrenceFrequency.weekly));
      });
    });

    group('toJson', () {
      test('serializes to JSON correctly', () {
        final json = baseSession.toJson();

        expect(json['id'], equals('session-123'));
        expect(json['groupId'], equals('group-456'));
        expect(json['title'], equals('Morning Practice'));
        expect(json['minParticipants'], equals(4));
        expect(json['maxParticipants'], equals(8));
        expect(json['participantIds'], equals(['user-1', 'user-2', 'user-3']));
        expect(json['status'], equals('scheduled'));
      });

      test('round-trip serialization preserves data', () {
        // Note: Nested freezed objects require explicit JSON conversion
        // This tests the values directly
        final json = baseSession.toJson();

        // Verify the JSON has correct structure
        expect(json['id'], equals(baseSession.id));
        expect(json['groupId'], equals(baseSession.groupId));
        expect(json['title'], equals(baseSession.title));
        expect(json['minParticipants'], equals(baseSession.minParticipants));
        expect(json['maxParticipants'], equals(baseSession.maxParticipants));
        expect(json['participantIds'], equals(baseSession.participantIds));
        expect(json['status'], equals('scheduled'));

        // Verify we can deserialize from a properly formatted JSON
        final properJson = {
          'id': baseSession.id,
          'groupId': baseSession.groupId,
          'title': baseSession.title,
          'location': baseSession.location.toJson(),
          'startTime': baseSession.startTime.toIso8601String(),
          'endTime': baseSession.endTime.toIso8601String(),
          'minParticipants': baseSession.minParticipants,
          'maxParticipants': baseSession.maxParticipants,
          'createdBy': baseSession.createdBy,
          'createdAt': baseSession.createdAt.toIso8601String(),
          'participantIds': baseSession.participantIds,
          'status': 'scheduled',
        };

        final restored = TrainingSessionModel.fromJson(properJson);
        expect(restored.id, equals(baseSession.id));
        expect(restored.title, equals(baseSession.title));
        expect(restored.participantIds, equals(baseSession.participantIds));
      });
    });

    group('toFirestore', () {
      test('excludes id from output', () {
        final firestoreData = baseSession.toFirestore();
        expect(firestoreData.containsKey('id'), isFalse);
      });

      test('converts DateTime to Timestamp', () {
        final firestoreData = baseSession.toFirestore();
        expect(firestoreData['startTime'], isA<Timestamp>());
        expect(firestoreData['endTime'], isA<Timestamp>());
        expect(firestoreData['createdAt'], isA<Timestamp>());
      });

      test('includes all other fields', () {
        final firestoreData = baseSession.toFirestore();
        expect(firestoreData['groupId'], equals('group-456'));
        expect(firestoreData['title'], equals('Morning Practice'));
        expect(firestoreData['minParticipants'], equals(4));
      });
    });

    group('equality', () {
      test('two sessions with same values are equal', () {
        final session1 = TrainingSessionModel(
          id: 'session-1',
          groupId: 'group-1',
          title: 'Test',
          location: testLocation,
          startTime: futureStart,
          endTime: futureEnd,
          minParticipants: 4,
          maxParticipants: 8,
          createdBy: 'creator',
          createdAt: createdAt,
        );

        final session2 = TrainingSessionModel(
          id: 'session-1',
          groupId: 'group-1',
          title: 'Test',
          location: testLocation,
          startTime: futureStart,
          endTime: futureEnd,
          minParticipants: 4,
          maxParticipants: 8,
          createdBy: 'creator',
          createdAt: createdAt,
        );

        expect(session1, equals(session2));
        expect(session1.hashCode, equals(session2.hashCode));
      });

      test('two sessions with different id are not equal', () {
        final session1 = TrainingSessionModel(
          id: 'session-1',
          groupId: 'group-1',
          title: 'Test',
          location: testLocation,
          startTime: futureStart,
          endTime: futureEnd,
          minParticipants: 4,
          maxParticipants: 8,
          createdBy: 'creator',
          createdAt: createdAt,
        );

        final session2 = TrainingSessionModel(
          id: 'session-2',
          groupId: 'group-1',
          title: 'Test',
          location: testLocation,
          startTime: futureStart,
          endTime: futureEnd,
          minParticipants: 4,
          maxParticipants: 8,
          createdBy: 'creator',
          createdAt: createdAt,
        );

        expect(session1, isNot(equals(session2)));
      });
    });

    group('copyWith', () {
      test('creates copy with updated title', () {
        final copy = baseSession.copyWith(title: 'New Title');
        expect(copy.title, equals('New Title'));
        expect(copy.id, equals(baseSession.id));
        expect(copy.groupId, equals(baseSession.groupId));
      });

      test('creates copy with updated status', () {
        final copy = baseSession.copyWith(status: TrainingStatus.completed);
        expect(copy.status, equals(TrainingStatus.completed));
      });

      test('creates copy with updated participantIds', () {
        final copy = baseSession.copyWith(participantIds: ['user-a', 'user-b']);
        expect(copy.participantIds, equals(['user-a', 'user-b']));
      });

      test('creates identical copy when no parameters provided', () {
        final copy = baseSession.copyWith();
        expect(copy, equals(baseSession));
      });
    });
  });

  group('TrainingStatus enum', () {
    test('has correct JSON values', () {
      expect(TrainingStatus.scheduled.name, equals('scheduled'));
      expect(TrainingStatus.completed.name, equals('completed'));
      expect(TrainingStatus.cancelled.name, equals('cancelled'));
    });
  });
}
