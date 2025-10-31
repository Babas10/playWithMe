# Story 2.8: Group Notifications - Cloud Functions Implementation Guide

## Overview

This document provides implementation requirements for the Firebase Cloud Functions that send notifications to users when group events occur.

## Prerequisites

- Firebase Cloud Functions set up with Python (as per project standards)
- Firebase Admin SDK configured
- FCM (Firebase Cloud Messaging) enabled in Firebase project

## Required Cloud Functions

### 1. On Invitation Created (`onInvitationCreated`)

**Trigger:** Firestore `onCreate` on `users/{userId}/invitations/{invitationId}`

**Purpose:** Notify user when they receive a group invitation

**Implementation Steps:**

1. Extract invitation data from the created document
2. Get the invitee's FCM tokens from `users/{userId}`
3. Check notification preferences (`notificationPreferences.groupInvitations`)
4. Check quiet hours (`notificationPreferences.quietHours`)
5. Fetch group details for display name and image
6. Send FCM multicast message to all user tokens
7. Handle invalid tokens by removing them from Firestore

**Payload Structure:**
```json
{
  "notification": {
    "title": "Group Invitation",
    "body": "{inviterName} invited you to join {groupName}",
    "imageUrl": "{groupPhotoUrl}"
  },
  "data": {
    "type": "invitation",
    "groupId": "{groupId}",
    "invitationId": "{invitationId}"
  }
}
```

---

### 2. On Invitation Accepted (`onInvitationAccepted`)

**Trigger:** Firestore `onUpdate` on `users/{userId}/invitations/{invitationId}` where `status` changes to `'accepted'`

**Purpose:** Notify the inviter when their invitation is accepted

**Implementation Steps:**

1. Verify status changed from `'pending'` to `'accepted'`
2. Get inviter ID from invitation document
3. Fetch inviter's FCM tokens
4. Check notification preferences (`notificationPreferences.invitationAccepted`)
5. Check quiet hours
6. Get accepter's display name and photo
7. Get group name
8. Send notification to inviter

**Payload Structure:**
```json
{
  "notification": {
    "title": "Invitation Accepted",
    "body": "{accepterName} accepted your invitation to {groupName}",
    "imageUrl": "{accepterPhotoUrl}"
  },
  "data": {
    "type": "invitation_accepted",
    "groupId": "{groupId}",
    "userId": "{accepterUserId}"
  }
}
```

---

### 3. On Game Created (`onGameCreated`)

**Trigger:** Firestore `onCreate` on `groups/{groupId}/games/{gameId}`

**Purpose:** Notify all group members (except creator) when a new game is posted

**Implementation Steps:**

1. Get group document to retrieve member IDs
2. Loop through all members (excluding game creator)
3. For each member:
   - Fetch notification preferences
   - Check global `gameCreated` preference
   - Check group-specific override in `groupSpecific.{groupId}.gameCreated`
   - Check quiet hours
   - Collect FCM tokens
4. Batch send notifications to all eligible members
5. Handle failed sends and remove invalid tokens

**Payload Structure:**
```json
{
  "notification": {
    "title": "New Game in {groupName}",
    "body": "{creatorName} created a new game",
    "imageUrl": "{groupPhotoUrl}"
  },
  "data": {
    "type": "game_created",
    "groupId": "{groupId}",
    "gameId": "{gameId}"
  }
}
```

---

### 4. On Member Joined (`onMemberJoined`)

**Trigger:** Firestore `onUpdate` on `groups/{groupId}` where `memberIds` array grows

**Purpose:** Notify group admins when a new member joins

**Implementation Steps:**

1. Compare before/after `memberIds` arrays to find new member
2. Get all admin IDs from group document
3. For each admin:
   - Check `memberJoined` preference (default: false)
   - Check quiet hours
   - Collect FCM tokens
4. Get new member's display name and photo
5. Send notifications to admins

**Payload Structure:**
```json
{
  "notification": {
    "title": "New Member Joined",
    "body": "{memberName} joined {groupName}",
    "imageUrl": "{memberPhotoUrl}"
  },
  "data": {
    "type": "member_joined",
    "groupId": "{groupId}",
    "userId": "{newMemberUserId}"
  }
}
```

---

### 5. On Member Left (`onMemberLeft`)

**Trigger:** Firestore `onUpdate` on `groups/{groupId}` where `memberIds` array shrinks

**Purpose:** Notify group admins when a member leaves

**Implementation Steps:**

1. Compare before/after `memberIds` arrays to find removed member
2. Get all admin IDs from group document
3. For each admin:
   - Check `memberLeft` preference (default: false)
   - Check quiet hours
   - Collect FCM tokens
4. Get departed member's name from before snapshot
5. Send notifications to admins

**Payload Structure:**
```json
{
  "notification": {
    "title": "Member Left",
    "body": "{memberName} left {groupName}"
  },
  "data": {
    "type": "member_left",
    "groupId": "{groupId}",
    "userId": "{departedMemberUserId}"
  }
}
```

---

### 6. On Role Changed (`onRoleChanged`)

**Trigger:** Firestore `onUpdate` on `groups/{groupId}` where `adminIds` array changes

**Purpose:** Notify user when they are promoted to/demoted from admin

**Implementation Steps:**

1. Compare before/after `adminIds` arrays
2. Find users added to admin list (promoted)
3. Find users removed from admin list (demoted)
4. For each affected user:
   - Check `roleChanged` preference
   - Check quiet hours
   - Send appropriate notification

**Payload Structure (Promoted):**
```json
{
  "notification": {
    "title": "Promoted to Admin",
    "body": "You are now an admin of {groupName}"
  },
  "data": {
    "type": "role_changed",
    "groupId": "{groupId}",
    "newRole": "admin"
  }
}
```

---

## Shared Utility Functions

### `isQuietHours(quietHoursConfig)`

Checks if current time falls within user's quiet hours.

**Logic:**
- If `quietHours.enabled` is false, return false
- Parse `quietHours.start` and `quietHours.end` (format: "HH:MM")
- Convert to minutes since midnight
- Handle overnight quiet hours (e.g., 22:00 - 08:00)

```python
def is_quiet_hours(quiet_hours: dict) -> bool:
    if not quiet_hours or not quiet_hours.get('enabled', False):
        return False

    now = datetime.now()
    current_minutes = now.hour * 60 + now.minute

    start_parts = quiet_hours['start'].split(':')
    start_minutes = int(start_parts[0]) * 60 + int(start_parts[1])

    end_parts = quiet_hours['end'].split(':')
    end_minutes = int(end_parts[0]) * 60 + int(end_parts[1])

    if start_minutes <= end_minutes:
        # Same day quiet hours
        return start_minutes <= current_minutes <= end_minutes
    else:
        # Overnight quiet hours
        return current_minutes >= start_minutes or current_minutes <= end_minutes
```

### `cleanupInvalidTokens(userId, failedTokens)`

Removes invalid FCM tokens from user document.

```python
def cleanup_invalid_tokens(user_id: str, failed_tokens: list):
    db.collection('users').document(user_id).update({
        'fcmTokens': firestore.ArrayRemove(failed_tokens)
    })
```

---

## Security Considerations

1. **Token Validation:** Always validate FCM tokens exist before sending
2. **Permission Checks:** Verify user has permission to receive notification
3. **Rate Limiting:** Consider implementing rate limits to prevent spam
4. **Error Handling:** Log all failures but don't crash function
5. **Privacy:** Never include sensitive data in notification payloads

---

## Testing Cloud Functions

### Unit Tests Required

For each function:
1. Test notification sent when conditions met
2. Test notification skipped when preferences disabled
3. Test notification skipped during quiet hours
4. Test invalid tokens are removed
5. Test error handling for missing data
6. Test group-specific preference overrides (for game notifications)

### Integration Tests

1. Create invitation → verify notification received
2. Accept invitation → verify inviter notified
3. Create game → verify all members notified (except creator)
4. Member joins → verify admins notified
5. Promote to admin → verify user notified

---

## Deployment Checklist

- [ ] Functions deployed to `playwithme-dev`
- [ ] Functions deployed to `playwithme-stg`
- [ ] Functions deployed to `playwithme-prod`
- [ ] Function logs monitored for errors
- [ ] Test notifications sent successfully
- [ ] Invalid token cleanup working
- [ ] Quiet hours logic tested across timezones

---

## Future Enhancements

1. **Notification Grouping:** Group multiple notifications from same source
2. **Action Buttons:** Add accept/decline buttons to invitation notifications
3. **Notification History:** Store sent notifications in Firestore
4. **Email Fallback:** Send email if FCM fails
5. **Localization:** Support multiple languages in notification text
6. **Rich Media:** Add more images and interactive elements
