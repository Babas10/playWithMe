# Story 3.2: Implement Cloud Function for New Game Notifications

**Epic:** Epic 3 - Core Game Lifecycle (Creation & Basic RSVP)
**Status:** ✅ Completed
**Branch:** `feature/story-3.2-game-notifications`

## Overview

Implements a Firebase Cloud Function that automatically notifies group members when a new game is created. The function triggers on game creation and sends push notifications to all eligible members while respecting their notification preferences and quiet hours settings.

## Implementation Details

### Cloud Function

**Function:** `onGameCreated`
**Type:** Firestore Trigger (`onCreate`)
**Path:** `groups/{groupId}/games/{gameId}`
**Language:** TypeScript
**Location:** `functions/src/notifications.ts`

### Flow Diagram

```
Game Created in Firestore
         ↓
   onGameCreated Trigger
         ↓
   Fetch Group Details
         ↓
   Get Group Members
         ↓
   For Each Member (except creator):
     - Check FCM tokens exist
     - Check notification preferences
     - Check quiet hours
     - Collect eligible tokens
         ↓
   Send Push Notification (FCM)
         ↓
   Handle Invalid Tokens
     - Remove from user documents
         ↓
   Log Results
```

### Key Features

1. **Automatic Triggering**
   - Fires when new document created in `groups/{groupId}/games/{gameId}`
   - No manual invocation needed
   - Real-time response to game creation

2. **Smart Notification Logic**
   - Excludes game creator (no self-notification)
   - Respects user's global notification preferences
   - Honors group-specific notification settings
   - Observes quiet hours (if configured)
   - Skips users without FCM tokens

3. **Robust Error Handling**
   - Cleans up invalid/expired FCM tokens
   - Logs all steps for debugging
   - Graceful degradation (continues if one member fails)
   - Comprehensive error logging with stack traces

4. **Rich Notification Content**
   - Title: "New Game in {Group Name}"
   - Body: "{Creator Name} created a new game{: Game Title}"
   - Includes group photo (if available)
   - Contains data payload for deep linking:
     - `type`: "game_created"
     - `groupId`: ID of the group
     - `gameId`: ID of the new game

5. **Platform-Specific Configuration**
   - **Android**: High priority, specific channel ID
   - **iOS**: Badge update, default sound

## Code Structure

### Function Signature

```typescript
export const onGameCreated = functions.firestore
  .document("groups/{groupId}/games/{gameId}")
  .onCreate(async (snapshot, context) => {
    // Implementation
  });
```

### Key Steps

1. **Extract Parameters**
   ```typescript
   const game = snapshot.data();
   const groupId = context.params.groupId;
   const gameId = context.params.gameId;
   ```

2. **Fetch Group and Creator Data**
   ```typescript
   const groupDoc = await admin.firestore()
     .collection("groups")
     .doc(groupId)
     .get();

   const creatorDoc = await admin.firestore()
     .collection("users")
     .doc(game.createdBy)
     .get();
   ```

3. **Collect Eligible Member Tokens**
   - Loop through group members
   - Skip creator
   - Check notification preferences
   - Check quiet hours
   - Track tokens per user (for cleanup)

4. **Send Notification**
   ```typescript
   const message: admin.messaging.MulticastMessage = {
     tokens: allTokens,
     notification: {...},
     data: {...},
     android: {...},
     apns: {...}
   };

   const response = await admin.messaging()
     .sendEachForMulticast(message);
   ```

5. **Clean Up Invalid Tokens**
   ```typescript
   if (response.failureCount > 0) {
     // Remove invalid tokens from user documents
   }
   ```

## Notification Preferences Structure

Users can control game notifications at two levels:

### Global Preference
```typescript
{
  notificationPreferences: {
    gameCreated: true | false  // Default: true
  }
}
```

### Group-Specific Preference
```typescript
{
  notificationPreferences: {
    gameCreated: true,  // Global default
    groupSpecific: {
      "{groupId}": {
        gameCreated: false  // Override for specific group
      }
    }
  }
}
```

**Priority:** Group-specific settings override global settings.

## Quiet Hours

Users can configure quiet hours to prevent notifications during specific times:

```typescript
{
  notificationPreferences: {
    quietHours: {
      enabled: true,
      start: "22:00",  // 10 PM
      end: "08:00"     // 8 AM
    }
  }
}
```

- Supports same-day periods (e.g., 14:00 to 18:00)
- Supports overnight periods (e.g., 22:00 to 08:00)
- Time format: "HH:mm" (24-hour)

## Testing

### Unit Tests (13 tests)

**File:** `functions/test/unit/onGameCreated.test.ts`

**Test Categories:**
1. **Notification sending** (3 tests)
   - Sends to all members except creator
   - Handles games with/without titles

2. **Notification preferences** (2 tests)
   - Respects global gameCreated preference
   - Respects group-specific preferences

3. **Quiet hours** (1 test)
   - Skips users in quiet hours

4. **Edge cases** (4 tests)
   - Group not found
   - Members without FCM tokens
   - No eligible members
   - Missing creator (falls back to "Someone")

5. **Invalid token cleanup** (2 tests)
   - Removes invalid tokens
   - Ignores other error types

6. **Error handling** (1 test)
   - Logs errors and returns null

**Coverage:** 100% of onGameCreated function logic

### Integration Tests (7 test suites)

**File:** `functions/test/integration/gameNotifications.test.ts`

**Test Scenarios:**
1. **Notification trigger** - Verifies function fires on game creation
2. **Preference handling** - Tests global and group-specific settings
3. **Data integrity** - Validates game documents
4. **Multiple games** - Tests concurrent game creation
5. **Edge cases** - Solo groups, missing tokens

**Emulator Usage:**
- Firestore Emulator (localhost:8080)
- Auth Emulator (localhost:9099)
- FCM mocked to avoid actual sending

### Running Tests

```bash
# Unit tests only
cd functions
npm test -- test/unit/onGameCreated.test.ts

# Integration tests (requires emulators)
firebase emulators:start --only firestore,auth
npm test -- test/integration/gameNotifications.test.ts

# All tests
npm test
```

## Logging

The function logs extensively for debugging:

- **Info**: Normal flow events
  - Game created event
  - Member processing count
  - Notification sent success
  - No members to notify

- **Debug**: Detailed member-by-member info
  - Member not found
  - Member has no FCM tokens
  - Notifications disabled for member
  - Member in quiet hours

- **Warn**: Unexpected but non-fatal issues
  - Group not found

- **Error**: Fatal errors with stack traces
  - Firestore failures
  - FCM failures
  - Unexpected exceptions

## Performance Considerations

1. **Database Reads**
   - 1 read for group
   - 1 read for creator
   - N reads for members (where N = number of group members)

2. **Database Writes**
   - 0-M writes for invalid token cleanup (where M = users with invalid tokens)

3. **FCM Calls**
   - 1 multicast message (up to 500 tokens per call)

4. **Optimization**
   - Uses multicast instead of individual sends
   - Batches token cleanup per user
   - Short-circuits when no eligible members

## Deployment

The function is automatically deployed with the Firebase Functions deployment:

```bash
firebase deploy --only functions:onGameCreated
```

**Environments:**
- `playwithme-dev` - Development
- `playwithme-stg` - Staging
- `playwithme-prod` - Production

## Error Scenarios

| Scenario | Handling |
|----------|----------|
| Group not found | Log warning, return null (no notification) |
| Creator not found | Use "Someone" as creator name |
| Member not found | Skip member, continue with others |
| No FCM tokens | Skip member, log debug |
| Preferences disabled | Skip member, log debug |
| Quiet hours active | Skip member, log debug |
| Invalid FCM token | Send to others, clean up invalid tokens |
| FCM service error | Log error, return null |
| Firestore error | Log error with stack trace, return null |

## Security

- ✅ No sensitive data in logs
- ✅ No API keys in code
- ✅ Runs with Firebase Admin SDK (elevated privileges)
- ✅ Validates all inputs
- ✅ No user-controllable execution paths

## Related Files

- **Function:** `functions/src/notifications.ts` (lines 310-525)
- **Export:** `functions/src/index.ts` (line 45)
- **Unit Tests:** `functions/test/unit/onGameCreated.test.ts`
- **Integration Tests:** `functions/test/integration/gameNotifications.test.ts`

## Related Stories

- **Story 3.1:** Game Creation UI (triggers this function)
- **Story 3.3:** Game Details Screen with RSVP (receives notifications)

## Future Enhancements

Potential improvements for future stories:

1. **Digest Notifications**
   - Batch multiple game notifications
   - Send summary instead of individual alerts

2. **Custom Notification Templates**
   - Per-group notification styling
   - User-defined notification text

3. **Advanced Scheduling**
   - Delay notifications until X hours before game
   - Smart timing based on user activity patterns

4. **Analytics**
   - Track notification delivery rates
   - Monitor user engagement with notifications

## Notes

- Function was already implemented but lacked tests and proper error handling
- This story enhanced the existing implementation:
  - Added comprehensive logging
  - Improved token cleanup logic
  - Added 13 unit tests (100% coverage)
  - Added 7 integration test suites
  - Improved error handling
  - Added JSDoc comments
