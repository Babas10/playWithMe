// Validates NotificationPreferencesEntity logic and utility methods

import 'package:flutter_test/flutter_test.dart';
import 'package:play_with_me/features/notifications/domain/entities/notification_preferences_entity.dart';

void main() {
  group('NotificationPreferencesEntity', () {
    group('constructor and defaults', () {
      test('creates instance with default values', () {
        const preferences = NotificationPreferencesEntity();

        expect(preferences.groupInvitations, true);
        expect(preferences.invitationAccepted, true);
        expect(preferences.gameCreated, true);
        expect(preferences.memberJoined, false);
        expect(preferences.memberLeft, false);
        expect(preferences.roleChanged, true);
        expect(preferences.friendRequestReceived, true);
        expect(preferences.friendRequestAccepted, true);
        expect(preferences.friendRemoved, false);
        expect(preferences.quietHoursEnabled, false);
        expect(preferences.quietHoursStart, null);
        expect(preferences.quietHoursEnd, null);
        expect(preferences.groupSpecific, {});
      });

      test('creates instance with custom values', () {
        const preferences = NotificationPreferencesEntity(
          groupInvitations: false,
          invitationAccepted: false,
          gameCreated: false,
          memberJoined: true,
          memberLeft: true,
          roleChanged: false,
          friendRequestReceived: false,
          friendRequestAccepted: false,
          friendRemoved: true,
          quietHoursEnabled: true,
          quietHoursStart: '22:00',
          quietHoursEnd: '08:00',
          groupSpecific: {'group1': false, 'group2': true},
        );

        expect(preferences.groupInvitations, false);
        expect(preferences.invitationAccepted, false);
        expect(preferences.gameCreated, false);
        expect(preferences.memberJoined, true);
        expect(preferences.memberLeft, true);
        expect(preferences.roleChanged, false);
        expect(preferences.friendRequestReceived, false);
        expect(preferences.friendRequestAccepted, false);
        expect(preferences.friendRemoved, true);
        expect(preferences.quietHoursEnabled, true);
        expect(preferences.quietHoursStart, '22:00');
        expect(preferences.quietHoursEnd, '08:00');
        expect(preferences.groupSpecific, {'group1': false, 'group2': true});
      });
    });

    group('isInQuietHours', () {
      test('returns false when quiet hours are disabled', () {
        const preferences = NotificationPreferencesEntity(
          quietHoursEnabled: false,
          quietHoursStart: '22:00',
          quietHoursEnd: '08:00',
        );

        final now = DateTime(2024, 1, 1, 23, 30); // 11:30 PM
        expect(preferences.isInQuietHours(now), false);
      });

      test('returns false when quiet hours times are not set', () {
        const preferences = NotificationPreferencesEntity(
          quietHoursEnabled: true,
        );

        final now = DateTime(2024, 1, 1, 23, 30);
        expect(preferences.isInQuietHours(now), false);
      });

      test('returns true when current time is within same-day quiet hours', () {
        const preferences = NotificationPreferencesEntity(
          quietHoursEnabled: true,
          quietHoursStart: '14:00',
          quietHoursEnd: '18:00',
        );

        // Time within quiet hours
        final now = DateTime(2024, 1, 1, 15, 30); // 3:30 PM
        expect(preferences.isInQuietHours(now), true);
      });

      test('returns false when current time is before same-day quiet hours', () {
        const preferences = NotificationPreferencesEntity(
          quietHoursEnabled: true,
          quietHoursStart: '14:00',
          quietHoursEnd: '18:00',
        );

        final now = DateTime(2024, 1, 1, 12, 0); // 12:00 PM
        expect(preferences.isInQuietHours(now), false);
      });

      test('returns false when current time is after same-day quiet hours', () {
        const preferences = NotificationPreferencesEntity(
          quietHoursEnabled: true,
          quietHoursStart: '14:00',
          quietHoursEnd: '18:00',
        );

        final now = DateTime(2024, 1, 1, 19, 0); // 7:00 PM
        expect(preferences.isInQuietHours(now), false);
      });

      test('returns true when current time is within overnight quiet hours (after start)', () {
        const preferences = NotificationPreferencesEntity(
          quietHoursEnabled: true,
          quietHoursStart: '22:00',
          quietHoursEnd: '08:00',
        );

        final now = DateTime(2024, 1, 1, 23, 30); // 11:30 PM
        expect(preferences.isInQuietHours(now), true);
      });

      test('returns true when current time is within overnight quiet hours (before end)', () {
        const preferences = NotificationPreferencesEntity(
          quietHoursEnabled: true,
          quietHoursStart: '22:00',
          quietHoursEnd: '08:00',
        );

        final now = DateTime(2024, 1, 1, 6, 30); // 6:30 AM
        expect(preferences.isInQuietHours(now), true);
      });

      test('returns false when current time is outside overnight quiet hours', () {
        const preferences = NotificationPreferencesEntity(
          quietHoursEnabled: true,
          quietHoursStart: '22:00',
          quietHoursEnd: '08:00',
        );

        final now = DateTime(2024, 1, 1, 15, 0); // 3:00 PM
        expect(preferences.isInQuietHours(now), false);
      });

      test('handles exact start time boundary', () {
        const preferences = NotificationPreferencesEntity(
          quietHoursEnabled: true,
          quietHoursStart: '22:00',
          quietHoursEnd: '08:00',
        );

        final now = DateTime(2024, 1, 1, 22, 0); // Exact start time
        expect(preferences.isInQuietHours(now), true);
      });

      test('handles exact end time boundary', () {
        const preferences = NotificationPreferencesEntity(
          quietHoursEnabled: true,
          quietHoursStart: '22:00',
          quietHoursEnd: '08:00',
        );

        final now = DateTime(2024, 1, 1, 8, 0); // Exact end time
        expect(preferences.isInQuietHours(now), true);
      });
    });

    group('isEnabledForGroup', () {
      test('returns default value when group has no specific override', () {
        const preferences = NotificationPreferencesEntity(
          groupSpecific: {},
        );

        expect(preferences.isEnabledForGroup('group1', true), true);
        expect(preferences.isEnabledForGroup('group1', false), false);
      });

      test('returns group-specific value when override exists', () {
        const preferences = NotificationPreferencesEntity(
          groupSpecific: {'group1': false, 'group2': true},
        );

        expect(preferences.isEnabledForGroup('group1', true), false);
        expect(preferences.isEnabledForGroup('group2', false), true);
      });

      test('ignores default value when group override exists', () {
        const preferences = NotificationPreferencesEntity(
          groupSpecific: {'group1': true},
        );

        // Even though default is false, group override is true
        expect(preferences.isEnabledForGroup('group1', false), true);
      });
    });

    group('JSON serialization', () {
      test('toJson converts entity to map correctly', () {
        const preferences = NotificationPreferencesEntity(
          groupInvitations: true,
          invitationAccepted: false,
          gameCreated: true,
          memberJoined: false,
          memberLeft: true,
          roleChanged: false,
          friendRequestReceived: true,
          friendRequestAccepted: false,
          friendRemoved: true,
          quietHoursEnabled: true,
          quietHoursStart: '22:00',
          quietHoursEnd: '08:00',
          groupSpecific: {'group1': false},
        );

        final json = preferences.toJson();

        expect(json['groupInvitations'], true);
        expect(json['invitationAccepted'], false);
        expect(json['gameCreated'], true);
        expect(json['memberJoined'], false);
        expect(json['memberLeft'], true);
        expect(json['roleChanged'], false);
        expect(json['friendRequestReceived'], true);
        expect(json['friendRequestAccepted'], false);
        expect(json['friendRemoved'], true);
        expect(json['quietHoursEnabled'], true);
        expect(json['quietHoursStart'], '22:00');
        expect(json['quietHoursEnd'], '08:00');
        expect(json['groupSpecific'], {'group1': false});
      });

      test('fromJson creates entity from map correctly', () {
        final json = {
          'groupInvitations': false,
          'invitationAccepted': true,
          'gameCreated': false,
          'memberJoined': true,
          'memberLeft': false,
          'roleChanged': true,
          'friendRequestReceived': false,
          'friendRequestAccepted': true,
          'friendRemoved': false,
          'quietHoursEnabled': true,
          'quietHoursStart': '21:00',
          'quietHoursEnd': '07:00',
          'groupSpecific': {'group1': true, 'group2': false},
        };

        final preferences = NotificationPreferencesEntity.fromJson(json);

        expect(preferences.groupInvitations, false);
        expect(preferences.invitationAccepted, true);
        expect(preferences.gameCreated, false);
        expect(preferences.memberJoined, true);
        expect(preferences.memberLeft, false);
        expect(preferences.roleChanged, true);
        expect(preferences.friendRequestReceived, false);
        expect(preferences.friendRequestAccepted, true);
        expect(preferences.friendRemoved, false);
        expect(preferences.quietHoursEnabled, true);
        expect(preferences.quietHoursStart, '21:00');
        expect(preferences.quietHoursEnd, '07:00');
        expect(preferences.groupSpecific, {'group1': true, 'group2': false});
      });

      test('fromJson handles missing fields with defaults', () {
        final json = <String, dynamic>{};

        final preferences = NotificationPreferencesEntity.fromJson(json);

        expect(preferences.groupInvitations, true);
        expect(preferences.invitationAccepted, true);
        expect(preferences.gameCreated, true);
        expect(preferences.memberJoined, false);
        expect(preferences.memberLeft, false);
        expect(preferences.roleChanged, true);
        expect(preferences.friendRequestReceived, true);
        expect(preferences.friendRequestAccepted, true);
        expect(preferences.friendRemoved, false);
        expect(preferences.quietHoursEnabled, false);
        expect(preferences.quietHoursStart, null);
        expect(preferences.quietHoursEnd, null);
        expect(preferences.groupSpecific, {});
      });

      test('JSON round-trip preserves all data', () {
        const original = NotificationPreferencesEntity(
          groupInvitations: false,
          invitationAccepted: true,
          gameCreated: false,
          memberJoined: true,
          memberLeft: true,
          roleChanged: false,
          friendRequestReceived: false,
          friendRequestAccepted: true,
          friendRemoved: true,
          quietHoursEnabled: true,
          quietHoursStart: '23:00',
          quietHoursEnd: '07:30',
          groupSpecific: {'group1': true, 'group2': false, 'group3': true},
        );

        final json = original.toJson();
        final restored = NotificationPreferencesEntity.fromJson(json);

        expect(restored, original);
      });
    });

    group('copyWith', () {
      test('creates copy with modified values', () {
        const original = NotificationPreferencesEntity();

        final modified = original.copyWith(
          groupInvitations: false,
          quietHoursEnabled: true,
          quietHoursStart: '22:00',
        );

        expect(modified.groupInvitations, false);
        expect(modified.quietHoursEnabled, true);
        expect(modified.quietHoursStart, '22:00');
        // Other values should remain unchanged
        expect(modified.invitationAccepted, true);
        expect(modified.gameCreated, true);
      });

      test('creates copy with null values explicitly set', () {
        const original = NotificationPreferencesEntity(
          quietHoursStart: '22:00',
          quietHoursEnd: '08:00',
        );

        final modified = original.copyWith(
          quietHoursStart: null,
          quietHoursEnd: null,
        );

        expect(modified.quietHoursStart, null);
        expect(modified.quietHoursEnd, null);
      });
    });
  });
}
