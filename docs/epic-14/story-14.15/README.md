# Story 14.15: Notifications for Game Result Verification

## Overview

This story implements push notifications to alert players when a game result has been submitted for verification, enabling timely confirmation and preventing games from getting stuck in pending verification state.

## User Story

As a player, I want to receive a notification when a game result is submitted, so that I can promptly review and confirm the score.

## Context

With the Verification Flow (Story 14.11), games require a second player to confirm the result before ELO is calculated. Without notifications, players might not know they need to take action, leaving games in a 'Verification Pending' state indefinitely.

## Implementation

### Cloud Function: `onGameResultSubmitted`

**Location:** `functions/src/notifications.ts`

**Trigger:** Firestore document update on `games/{gameId}`

**Condition:** Triggers when game status changes to `verification`

**Logic:**
1. Detects status transition from any state to `verification`
2. Retrieves submitter's name (firstName + lastName, displayName, email, or "Someone")
3. Collects FCM tokens from all confirmed participants except the submitter
4. Respects notification preferences:
   - Global `gameResultSubmitted` preference
   - Group-specific `gameResultSubmitted` preference
   - Quiet hours settings
5. Sends multicast FCM notification
6. Cleans up invalid FCM tokens

**Notification Content:**
- **Title:** "Game Result Posted"
- **Body:** "[Submitter Name] posted the score for [Game Title]. Please confirm the result."
- **Data Payload:**
  - `type`: "game_result_submitted"
  - `groupId`: The group ID
  - `gameId`: The game ID
  - `submitterId`: User who submitted the result
  - `submitterName`: Display name of submitter

**Deep Linking:**
The notification data includes `gameId` which the Flutter app uses to navigate directly to `GameDetailsPage`.

## Testing

### Unit Tests

**Location:** `functions/test/unit/onGameResultSubmitted.test.ts`

**Coverage:** 19 test cases covering:
- Status transition detection (3 tests)
- Notification sending (6 tests)
- Notification preferences (2 tests)
- Quiet hours (1 test)
- Edge cases (4 tests)
- Invalid token cleanup (2 tests)
- Error handling (1 test)

**Test Results:** ✅ All 19 tests passing

### Key Test Scenarios

1. **Status Transition Detection**
   - ✅ Triggers when status changes to 'verification'
   - ✅ Does not trigger if status was already 'verification'
   - ✅ Does not trigger for other status changes

2. **Notification Sending**
   - ✅ Sends to all players except submitter
   - ✅ Handles missing game title
   - ✅ Uses correct name fallback order (firstName+lastName → displayName → email → "Someone")

3. **Preferences & Privacy**
   - ✅ Respects global `gameResultSubmitted` preference
   - ✅ Respects group-specific preferences
   - ✅ Honors quiet hours

4. **Edge Cases**
   - ✅ Handles games with no players
   - ✅ Handles players without FCM tokens
   - ✅ Handles games with only the submitter
   - ✅ Handles missing submitter document

5. **Token Management**
   - ✅ Removes invalid FCM tokens
   - ✅ Preserves valid tokens on non-token errors

## Deployment

The Cloud Function has been deployed to all environments:

- ✅ `playwithme-dev`
- ✅ `playwithme-stg`
- ✅ `playwithme-prod`

**Deployment Command:**
```bash
firebase use <project-id>
firebase deploy --only functions:onGameResultSubmitted
```

## Idempotency

The function is idempotent due to the status check:
- Only triggers when transitioning **to** `verification`
- Does not re-trigger if status remains `verification`
- If a result is edited and re-submitted, the status transitions again (scheduled → verification), triggering a new notification

This ensures players are notified of every meaningful update requiring verification, without duplicate notifications for the same submission.

## Security & Privacy

- ✅ Only notifies confirmed participants (players in `playerIds`)
- ✅ Excludes the submitter from notifications
- ✅ Respects user notification preferences at global and group levels
- ✅ Honors quiet hours settings
- ✅ Uses secure FCM token handling with automatic cleanup
- ✅ Logs all actions for audit trail

## Integration with Existing Features

### Story 14.11: Game Result Verification Flow
- Complements the verification UI by notifying players when action is required
- Notification deep-links to the game details page where players can confirm results

### Story 14.14: Democratize Game Result Entry
- Works seamlessly with democratized result entry
- Any participant can submit results, triggering notifications to all others

### Notification Infrastructure
- Reuses existing FCM infrastructure from `functions/src/notifications.ts`
- Follows the same patterns as other game notifications (`onGameCreated`, `onPlayerJoinedGame`, etc.)
- Integrates with notification preferences system

## User Experience Flow

1. **Player A** enters game results after the game ends
2. Game status changes from `completed` to `verification`
3. **Cloud Function** detects the status change
4. **Notification sent** to all other players (B, C, D) except Player A
5. **Players B, C, D** receive push notification: "Player A posted the score for Beach Volleyball. Please confirm the result."
6. **Player taps notification** → Deep-links to Game Details Page
7. **Player confirms** result → Game status changes to `completed`
8. ELO calculation proceeds (Story 14.5)

## Future Enhancements

Potential improvements for future stories:
- Add a "reminder" notification if result remains unconfirmed after 24 hours
- Include score summary in notification body
- Support notification customization (e.g., different tones for different game types)
- Add notification batching for users in multiple games

## Files Changed

### Cloud Functions
- `functions/src/notifications.ts` - Added `onGameResultSubmitted` function
- `functions/src/index.ts` - Exported new function
- `functions/test/unit/onGameResultSubmitted.test.ts` - Added comprehensive unit tests

### Documentation
- `docs/epic-14/story-14.15/README.md` - This file

## Acceptance Criteria Status

- ✅ **Trigger:** Function triggers when game enters `verification` state
- ✅ **Audience:** Sends to all confirmed participants except the submitter
- ✅ **Content:** Notification includes correct title and body with submitter name and game title
- ✅ **Navigation:** Data payload includes `gameId` for deep-linking to GameDetailsPage
- ✅ **Idempotency:** Only one notification per status transition to `verification`

## Related Stories

- **Story 14.11:** Game Result Verification Flow
- **Story 14.14:** Democratize Game Result Entry
- **Story 14.5:** ELO Rating Calculation
- **Story 3.2:** Game Created Notifications (notification infrastructure foundation)

---

**Status:** ✅ Completed
**Deployed:** Yes (all environments)
**Tests:** 19/19 passing
