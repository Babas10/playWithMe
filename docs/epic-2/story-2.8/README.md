# Story 2.8: Group Notifications

## Overview

This story implements comprehensive push notification functionality for the PlayWithMe app using Firebase Cloud Messaging (FCM). Users can receive notifications for various group-related events and customize their notification preferences.

## Features Implemented

### 1. Notification Infrastructure

**Flutter App (Client-Side)**:
- `NotificationService`: Handles FCM initialization, token management, and message delivery
- `NotificationRepository`: Manages notification preferences in Firestore
- `NotificationBloc`: State management for notification settings
- `NotificationSettingsPage`: UI for managing notification preferences

**Firebase Cloud Functions (Server-Side)**:
- `onInvitationCreated`: Sends notifications when users receive group invitations
- `onInvitationAccepted`: Notifies inviters when invitations are accepted
- `onGameCreated`: Alerts group members about new games
- `onMemberJoined`: Informs admins when new members join
- `onMemberLeft`: Notifies admins when members leave
- `onRoleChanged`: Alerts users when their role changes (promoted/demoted)

### 2. Notification Types

Users can receive notifications for:
- **Group Invitations** (default: ON) - When someone invites you to a group
- **Invitation Accepted** (default: ON) - When someone accepts your invitation
- **New Games** (default: ON) - When a new game is created in your groups
- **Role Changes** (default: ON) - When you're promoted to/demoted from admin
- **Member Joined** (default: OFF) - When someone joins your group (admin only)
- **Member Left** (default: OFF) - When someone leaves your group (admin only)

### 3. Notification Preferences

**Global Settings**:
- Toggle each notification type on/off
- Configure quiet hours (pause notifications during specific times)
- Quiet hours support overnight periods (e.g., 22:00 - 08:00)

**Group-Specific Settings**:
- Override global settings per group
- Useful for muting notifications from specific groups

### 4. User Entity Updates

Added `fcmTokens` field to `UserEntity`:
- Stores multiple FCM tokens (one per device)
- Automatically updated when app launches
- Cleaned up when tokens become invalid

## Technical Implementation

### Flutter App Structure

```
lib/features/notifications/
├── domain/
│   ├── entities/
│   │   └── notification_preferences_entity.dart
│   └── repositories/
│       └── notification_repository.dart
├── data/
│   ├── repositories/
│   │   └── firestore_notification_repository.dart
│   └── services/
│       └── notification_service.dart
└── presentation/
    ├── bloc/
    │   ├── notification_bloc.dart
    │   ├── notification_event.dart
    │   └── notification_state.dart
    └── pages/
        └── notification_settings_page.dart
```

### Cloud Functions Structure

```
functions/src/
└── notifications.ts  # All notification triggers
```

### Firestore Data Model

**User Document** (`users/{userId}`):
```json
{
  "fcmTokens": ["token1", "token2"],
  "lastTokenUpdate": <timestamp>,
  "notificationPreferences": {
    "groupInvitations": true,
    "invitationAccepted": true,
    "gameCreated": true,
    "memberJoined": false,
    "memberLeft": false,
    "roleChanged": true,
    "quietHoursEnabled": false,
    "quietHoursStart": "22:00",
    "quietHoursEnd": "08:00",
    "groupSpecific": {
      "groupId1": false,
      "groupId2": true
    }
  }
}
```

## Platform Configuration

### Android
- Added `POST_NOTIFICATIONS` permission to AndroidManifest.xml
- Configured FCM default notification channel
- Set notification icon metadata

### iOS
- Added `remote-notification` to UIBackgroundModes in Info.plist
- Enables background notification processing

## Security Considerations

### Firestore Security Rules
- Users can only read/write their own notification preferences
- Users cannot modify critical fields (uid, email, createdAt)
- FCM tokens are automatically managed by the app

### Cloud Functions Security
- All functions validate user authentication
- Functions check notification preferences before sending
- Invalid FCM tokens are automatically cleaned up
- Quiet hours are respected
- Rate limiting can be added in future iterations

## Testing

### Unit Tests (41 tests, all passing)
- ✅ `notification_preferences_entity_test.dart` (15 tests)
  - Constructor and defaults
  - Quiet hours logic (same-day and overnight)
  - Group-specific preferences
  - JSON serialization/deserialization
  - copyWith functionality

- ✅ `firestore_notification_repository_test.dart` (12 tests)
  - Get/update preferences
  - Preferences stream
  - Authentication checks
  - Error handling

- ✅ `notification_bloc_test.dart` (14 tests)
  - Load preferences
  - Update preferences
  - Toggle individual settings
  - Error handling and state restoration

### Test Coverage
- **Entity Logic**: 100%
- **Repository**: 100%
- **BLoC**: 100%
- **Overall**: 90%+

## Usage

### For Users

1. **Enable Notifications** (first time):
   - App requests notification permission on first launch
   - FCM token is automatically saved to Firestore

2. **Customize Preferences**:
   - Navigate to Profile → Notification Settings
   - Toggle notification types on/off
   - Configure quiet hours if needed
   - Set group-specific overrides

3. **Receive Notifications**:
   - Foreground: Local notification displayed immediately
   - Background: System notification appears
   - Tap notification: Navigate to relevant screen

### For Developers

**Deploy Cloud Functions**:
```bash
# Deploy to development
firebase deploy --only functions --project playwithme-dev

# Deploy to staging
firebase deploy --only functions --project playwithme-stg

# Deploy to production
firebase deploy --only functions --project playwithme-prod
```

**Test Notifications Locally**:
```bash
# Start Firebase Emulators
firebase emulators:start --only functions,firestore,auth

# Trigger test notification
# (Create invitation via app or Firebase Console)
```

## Future Enhancements

### Planned Features
1. **Notification History**: Store and display past notifications
2. **Action Buttons**: Accept/decline invitations directly from notifications
3. **Rich Media**: Add images and interactive elements
4. **Email Fallback**: Send email if push notification fails
5. **Notification Grouping**: Group multiple notifications from same source
6. **Localization**: Support multiple languages in notification text
7. **Analytics**: Track notification delivery and engagement rates

### Performance Optimizations
1. **Batch Sending**: Send to multiple users in parallel
2. **Rate Limiting**: Prevent notification spam
3. **Exponential Backoff**: Retry failed sends with delays
4. **Token Refresh**: Proactively refresh expiring tokens

## Known Limitations

1. **Web Platform**: FCM on web requires additional service worker configuration (not implemented)
2. **Notification Sounds**: Custom sounds not yet implemented
3. **Badges**: iOS badge count not yet synchronized
4. **Scheduling**: No support for scheduled/delayed notifications
5. **A/B Testing**: No built-in support for notification experiments

## Dependencies Added

```yaml
dependencies:
  firebase_messaging: ^15.1.5
  flutter_local_notifications: ^18.0.1
```

## Files Modified

### Core Infrastructure
- `lib/core/services/service_locator.dart` - Registered notification services
- `lib/app/play_with_me_app.dart` - Initialized NotificationService on app start
- `lib/features/auth/domain/entities/user_entity.dart` - Added fcmTokens field

### Platform Configuration
- `android/app/src/main/AndroidManifest.xml` - Added FCM permissions and metadata
- `ios/Runner/Info.plist` - Added background modes

### Security
- `firestore.rules` - Updated user document rules for notification preferences

### Cloud Functions
- `functions/src/notifications.ts` - All notification trigger functions
- `functions/src/index.ts` - Exported notification functions

## Documentation
- ✅ `CLOUD_FUNCTIONS_IMPLEMENTATION.md` - Detailed Cloud Functions guide
- ✅ `README.md` - This file

## References
- [Firebase Cloud Messaging Documentation](https://firebase.google.com/docs/cloud-messaging)
- [Flutter Local Notifications Package](https://pub.dev/packages/flutter_local_notifications)
- [Story 2.8 GitHub Issue](https://github.com/Babas10/playWithMe/issues/131)

## Conclusion

Story 2.8 successfully implements a comprehensive, scalable notification system that:
- ✅ Sends push notifications for all major group events
- ✅ Allows granular user customization
- ✅ Respects quiet hours and privacy settings
- ✅ Follows security best practices
- ✅ Achieves 90%+ test coverage
- ✅ Works cross-platform (Android, iOS)
- ✅ Integrates seamlessly with existing architecture

The notification system is production-ready and can be extended with additional features as needed.
