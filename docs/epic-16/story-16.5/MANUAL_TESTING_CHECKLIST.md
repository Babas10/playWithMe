# PlayWithMe - Manual Testing Checklist

**Story**: 16.5 - Create Manual Testing Checklist
**Version**: 1.1
**Last Updated**: January 2026

---

## Table of Contents

1. [Test Data Setup](#1-test-data-setup)
2. [Authentication Flows](#2-authentication-flows)
3. [Profile Management](#3-profile-management)
4. [My Community (Friends)](#4-my-community-friends)
5. [Groups](#5-groups)
6. [Games](#6-games)
7. [Training Sessions](#7-training-sessions)
8. [Notifications](#8-notifications)
9. [Edge Cases & Error Scenarios](#9-edge-cases--error-scenarios)
10. [Cross-Platform Testing](#10-cross-platform-testing)
11. [Test Execution Log](#11-test-execution-log)

---

## 1. Test Data Setup

### 1.1 Prerequisites

Before starting manual testing, ensure:

- [ ] Firebase Emulator Suite is running (for local testing)
- [ ] App is built for the target platform (Android/iOS/Web)
- [ ] Test accounts are ready (see below)
- [ ] Network connectivity is available

### 1.2 Test Accounts

Create the following test accounts for comprehensive testing:

| Account | Email | Password | Purpose |
|---------|-------|----------|---------|
| User A (Primary) | `tester.a@playwithme.test` | `TestPass123!` | Main test user |
| User B (Friend) | `tester.b@playwithme.test` | `TestPass123!` | Friend/opponent |
| User C (Stranger) | `tester.c@playwithme.test` | `TestPass123!` | Non-friend user |
| User D (Admin) | `tester.d@playwithme.test` | `TestPass123!` | Group admin tests |

### 1.3 Test Data Setup Steps

```bash
# Start Firebase Emulators (for local testing)
firebase emulators:start --only auth,firestore,functions --project playwithme-dev

# Clear existing test data (if needed)
# Use Firebase Console or emulator UI to clear collections
```

**Initial Setup Checklist:**

- [ ] Create all 4 test accounts via registration flow
- [ ] Verify email for all accounts (if required)
- [ ] Create at least one test group with User A as admin
- [ ] Add User B as friend of User A
- [ ] User C should remain as stranger (no friendship)

---

## 2. Authentication Flows

### 2.1 Registration

| ID | Test Case | Steps | Expected Result | Status |
|----|-----------|-------|-----------------|--------|
| AUTH-001 | Register with valid email | 1. Open app<br>2. Tap "Register"<br>3. Enter valid email, password, display name<br>4. Tap "Register" | Account created, navigated to email verification or home | [ ] |
| AUTH-002 | Register with invalid email | 1. Open register page<br>2. Enter invalid email format (e.g., "notanemail")<br>3. Tap "Register" | Error message: "Invalid email format" | [ ] |
| AUTH-003 | Register with weak password | 1. Open register page<br>2. Enter valid email<br>3. Enter weak password (e.g., "123")<br>4. Tap "Register" | Error message about password requirements | [ ] |
| AUTH-004 | Register with existing email | 1. Open register page<br>2. Enter email that already exists<br>3. Complete form and submit | Error message: "Email already in use" | [ ] |
| AUTH-005 | Register with empty fields | 1. Open register page<br>2. Leave fields empty<br>3. Tap "Register" | Validation errors shown for required fields | [ ] |

### 2.2 Login

| ID | Test Case | Steps | Expected Result | Status |
|----|-----------|-------|-----------------|--------|
| AUTH-010 | Login with valid credentials | 1. Open app<br>2. Enter valid email/password<br>3. Tap "Login" | Successfully logged in, navigated to home | [ ] |
| AUTH-011 | Login with wrong password | 1. Open app<br>2. Enter valid email<br>3. Enter wrong password<br>4. Tap "Login" | Error message: "Invalid credentials" | [ ] |
| AUTH-012 | Login with non-existent email | 1. Open app<br>2. Enter email that doesn't exist<br>3. Tap "Login" | Error message: "User not found" | [ ] |
| AUTH-013 | Login with empty fields | 1. Open login page<br>2. Leave fields empty<br>3. Tap "Login" | Validation errors shown | [ ] |
| AUTH-014 | Anonymous login (if enabled) | 1. Open app<br>2. Tap "Continue as Guest" | Logged in anonymously, limited features | [ ] |

### 2.3 Password Reset

| ID | Test Case | Steps | Expected Result | Status |
|----|-----------|-------|-----------------|--------|
| AUTH-020 | Request password reset | 1. Tap "Forgot Password"<br>2. Enter registered email<br>3. Tap "Send Reset Email" | Success message, email sent | [ ] |
| AUTH-021 | Reset with non-existent email | 1. Tap "Forgot Password"<br>2. Enter unregistered email<br>3. Tap "Send" | Error or generic success (security) | [ ] |
| AUTH-022 | Reset with invalid email | 1. Tap "Forgot Password"<br>2. Enter invalid email format<br>3. Tap "Send" | Validation error | [ ] |

### 2.4 Logout

| ID | Test Case | Steps | Expected Result | Status |
|----|-----------|-------|-----------------|--------|
| AUTH-030 | Logout from profile | 1. Login<br>2. Go to Profile<br>3. Tap "Logout" | Logged out, returned to login page | [ ] |
| AUTH-031 | Session persistence | 1. Login<br>2. Close app completely<br>3. Reopen app | Still logged in | [ ] |

---

## 3. Profile Management

### 3.1 View Profile

| ID | Test Case | Steps | Expected Result | Status |
|----|-----------|-------|-----------------|--------|
| PROF-001 | View own profile | 1. Login<br>2. Navigate to Profile | Profile page shows user info, stats, ELO | [ ] |
| PROF-002 | View ELO rating | 1. Go to Profile | ELO rating displayed (or "Unrated" if new) | [ ] |
| PROF-003 | View game statistics | 1. Go to Profile<br>2. Check stats section | Games played, wins, losses displayed | [ ] |

### 3.2 Edit Profile

| ID | Test Case | Steps | Expected Result | Status |
|----|-----------|-------|-----------------|--------|
| PROF-010 | Edit display name | 1. Go to Profile<br>2. Tap "Edit"<br>3. Change display name<br>4. Save | Name updated, visible in profile | [ ] |
| PROF-011 | Upload avatar | 1. Go to Profile Edit<br>2. Tap avatar<br>3. Select image<br>4. Confirm upload | Avatar updated and displayed | [ ] |
| PROF-012 | Remove avatar | 1. Go to Profile Edit<br>2. Tap remove avatar option | Avatar removed, default shown | [ ] |
| PROF-013 | Edit with empty name | 1. Go to Profile Edit<br>2. Clear display name<br>3. Try to save | Validation error: name required | [ ] |

### 3.3 Email Verification

| ID | Test Case | Steps | Expected Result | Status |
|----|-----------|-------|-----------------|--------|
| PROF-020 | Send verification email | 1. Go to Email Verification<br>2. Tap "Send Verification Email" | Email sent, success message | [ ] |
| PROF-021 | Check verification status | 1. Verify email via link<br>2. Return to app<br>3. Check status | Status shows "Verified" | [ ] |
| PROF-022 | Resend before cooldown | 1. Send verification email<br>2. Immediately try to resend | Cooldown message (60 seconds) | [ ] |

### 3.4 ELO History

| ID | Test Case | Steps | Expected Result | Status |
|----|-----------|-------|-----------------|--------|
| PROF-030 | View ELO chart | 1. Go to Profile<br>2. Tap ELO section | ELO history chart displayed | [ ] |
| PROF-031 | View full ELO history | 1. Tap "View Full History" | Full ELO history page with all entries | [ ] |

### 3.5 Head-to-Head Stats

| ID | Test Case | Steps | Expected Result | Status |
|----|-----------|-------|-----------------|--------|
| PROF-040 | View H2H section | 1. Go to Profile<br>2. Check H2H section | H2H stats shown (or empty state) | [ ] |
| PROF-041 | View H2H details | 1. Tap on H2H opponent | Detailed H2H page with win/loss record | [ ] |

### 3.6 Partner Statistics

| ID | Test Case | Steps | Expected Result | Status |
|----|-----------|-------|-----------------|--------|
| PROF-050 | View teammates | 1. Go to Profile<br>2. Check Partners section | List of teammates with stats | [ ] |
| PROF-051 | View partner details | 1. Tap on a partner | Partner detail page with games together | [ ] |

---

## 4. My Community (Friends)

### 4.1 Friend List

| ID | Test Case | Steps | Expected Result | Status |
|----|-----------|-------|-----------------|--------|
| FRIEND-001 | View friends list | 1. Go to My Community<br>2. Select Friends tab | List of friends displayed | [ ] |
| FRIEND-002 | Empty friends list | 1. Login as new user<br>2. Go to My Community | Empty state: "No friends yet" | [ ] |
| FRIEND-003 | Search friends | 1. Go to Friends tab<br>2. Use search/filter | Friends filtered by name | [ ] |

### 4.2 Friend Requests

| ID | Test Case | Steps | Expected Result | Status |
|----|-----------|-------|-----------------|--------|
| FRIEND-010 | Send friend request | 1. Go to Add Friend<br>2. Search for User C by email<br>3. Tap "Add Friend" | Request sent, pending status | [ ] |
| FRIEND-011 | Accept friend request | 1. Login as User C<br>2. Go to Requests tab<br>3. Tap "Accept" | Friend added to list | [ ] |
| FRIEND-012 | Decline friend request | 1. Receive request<br>2. Go to Requests tab<br>3. Tap "Decline" | Request removed | [ ] |
| FRIEND-013 | View pending requests count | 1. Login with pending requests | Badge shows request count | [ ] |
| FRIEND-014 | Search non-existent user | 1. Go to Add Friend<br>2. Search for invalid email | "User not found" message | [ ] |
| FRIEND-015 | Send request to self | 1. Go to Add Friend<br>2. Search for own email | Cannot send request to self | [ ] |
| FRIEND-016 | Send duplicate request | 1. Send request to User C<br>2. Try to send again | "Request already pending" | [ ] |

### 4.3 Remove Friend

| ID | Test Case | Steps | Expected Result | Status |
|----|-----------|-------|-----------------|--------|
| FRIEND-020 | Remove friend | 1. Go to Friends list<br>2. Select friend<br>3. Tap "Remove Friend"<br>4. Confirm | Friend removed from list | [ ] |
| FRIEND-021 | Removed friend notification | 1. Remove User B as friend<br>2. Check User B's friend list | User A no longer in User B's list | [ ] |

---

## 5. Groups

### 5.1 Group List

| ID | Test Case | Steps | Expected Result | Status |
|----|-----------|-------|-----------------|--------|
| GROUP-001 | View groups list | 1. Login<br>2. Navigate to Groups/Home | List of user's groups displayed | [ ] |
| GROUP-002 | Empty groups list | 1. Login as new user<br>2. View groups | Empty state: "No groups yet" | [ ] |

### 5.2 Create Group

| ID | Test Case | Steps | Expected Result | Status |
|----|-----------|-------|-----------------|--------|
| GROUP-010 | Create group | 1. Tap "Create Group" FAB<br>2. Enter name, description<br>3. Save | Group created, user is admin | [ ] |
| GROUP-011 | Create with empty name | 1. Open create group<br>2. Leave name empty<br>3. Try to save | Validation error | [ ] |
| GROUP-012 | Create and invite friends | 1. Create group<br>2. Select friends to invite<br>3. Complete | Group created, invitations sent | [ ] |

### 5.3 Group Details

| ID | Test Case | Steps | Expected Result | Status |
|----|-----------|-------|-----------------|--------|
| GROUP-020 | View group details | 1. Tap on a group | Group details page with tabs | [ ] |
| GROUP-021 | View members tab | 1. Go to group<br>2. Select Members tab | List of group members | [ ] |
| GROUP-022 | View games tab | 1. Go to group<br>2. Select Games tab | List of group games | [ ] |
| GROUP-023 | View training tab | 1. Go to group<br>2. Select Training tab | List of training sessions | [ ] |

### 5.4 Invite Members

| ID | Test Case | Steps | Expected Result | Status |
|----|-----------|-------|-----------------|--------|
| GROUP-030 | Invite friend to group | 1. Go to group<br>2. Tap "Invite"<br>3. Select friend<br>4. Send | Invitation sent | [ ] |
| GROUP-031 | Accept group invitation | 1. Login as invitee<br>2. Go to Invitations<br>3. Accept | Added to group members | [ ] |
| GROUP-032 | Decline group invitation | 1. Receive invitation<br>2. Decline | Invitation removed | [ ] |
| GROUP-033 | Invite non-friend | 1. Try to invite User C (stranger) | Only friends can be invited | [ ] |
| GROUP-034 | Invite existing member | 1. Try to invite existing member | "Already a member" error | [ ] |

### 5.5 Pending Invitations Page

| ID | Test Case | Steps | Expected Result | Status |
|----|-----------|-------|-----------------|--------|
| GROUP-035 | View pending invitations | 1. Have pending invitations<br>2. Tap invitations badge/icon | Pending invitations page shows all invites | [ ] |
| GROUP-036 | Empty invitations state | 1. Login with no pending invites<br>2. Go to invitations | Empty state: "No pending invitations" | [ ] |
| GROUP-037 | Invitations badge count | 1. Have 3 pending invitations<br>2. Check badge | Badge shows "3" | [ ] |

### 5.6 Leave Group

| ID | Test Case | Steps | Expected Result | Status |
|----|-----------|-------|-----------------|--------|
| GROUP-040 | Leave group (member) | 1. Go to group as member<br>2. Tap "Leave Group"<br>3. Confirm | Removed from group | [ ] |
| GROUP-041 | Leave group (last admin) | 1. As only admin, try to leave | Must assign another admin first | [ ] |

### 5.7 Group Admin Actions

| ID | Test Case | Steps | Expected Result | Status |
|----|-----------|-------|-----------------|--------|
| GROUP-050 | Promote member to admin | 1. As admin, go to members<br>2. Select member<br>3. Promote to admin | Member becomes admin | [ ] |
| GROUP-051 | Demote admin | 1. As admin, demote another admin | Admin becomes regular member | [ ] |
| GROUP-052 | Remove member | 1. As admin, remove member | Member removed from group | [ ] |
| GROUP-053 | Delete group | 1. As admin, delete group | Group deleted, members notified | [ ] |

---

## 6. Games

### 6.1 Games List

| ID | Test Case | Steps | Expected Result | Status |
|----|-----------|-------|-----------------|--------|
| GAME-001 | View upcoming games | 1. Go to group<br>2. Games tab | Upcoming games displayed | [ ] |
| GAME-002 | View past games | 1. Go to group<br>2. Games tab<br>3. Toggle to past | Past/completed games shown | [ ] |
| GAME-003 | Empty games list | 1. Go to new group<br>2. Games tab | Empty state message | [ ] |

### 6.2 Create Game

| ID | Test Case | Steps | Expected Result | Status |
|----|-----------|-------|-----------------|--------|
| GAME-010 | Create game | 1. Tap "Create Game"<br>2. Fill details (date, time, location)<br>3. Save | Game created, visible in list | [ ] |
| GAME-011 | Create game in past | 1. Try to create game with past date | Validation error | [ ] |
| GAME-012 | Create with player limits | 1. Create game with min/max players<br>2. Save | Limits enforced on join | [ ] |
| GAME-013 | Create with empty fields | 1. Leave required fields empty<br>2. Try to save | Validation errors | [ ] |

### 6.3 Game Details

| ID | Test Case | Steps | Expected Result | Status |
|----|-----------|-------|-----------------|--------|
| GAME-020 | View game details | 1. Tap on a game | Game details page displayed | [ ] |
| GAME-021 | View players list | 1. Go to game details | List of players shown | [ ] |
| GAME-022 | View game location | 1. Go to game details | Location/court info displayed | [ ] |

### 6.4 Join/Leave Game

| ID | Test Case | Steps | Expected Result | Status |
|----|-----------|-------|-----------------|--------|
| GAME-030 | Join game | 1. Go to game details<br>2. Tap "Join" | Added to players list | [ ] |
| GAME-031 | Leave game | 1. As player, go to game<br>2. Tap "Leave" | Removed from players | [ ] |
| GAME-032 | Join full game (waitlist) | 1. Try to join game at max capacity | Added to waitlist | [ ] |
| GAME-033 | Auto-promote from waitlist | 1. Be on waitlist<br>2. Someone leaves | Promoted to player | [ ] |
| GAME-034 | Join as non-member | 1. As non-group member try to join | Cannot join | [ ] |

### 6.5 Record Results

| ID | Test Case | Steps | Expected Result | Status |
|----|-----------|-------|-----------------|--------|
| GAME-040 | Record game result | 1. After game time<br>2. Tap "Record Results"<br>3. Select teams<br>4. Enter scores<br>5. Submit | Result recorded, pending confirmation | [ ] |
| GAME-041 | Confirm result | 1. As other player<br>2. View submitted result<br>3. Confirm | Game completed, ELO updated | [ ] |
| GAME-042 | Dispute result | 1. As other player<br>2. View submitted result<br>3. Dispute | Dispute recorded | [ ] |
| GAME-043 | View game result | 1. Go to completed game | Final scores and teams shown | [ ] |

### 6.6 Game History

| ID | Test Case | Steps | Expected Result | Status |
|----|-----------|-------|-----------------|--------|
| GAME-050 | View game history | 1. Go to Profile/History<br>2. View past games | All completed games listed | [ ] |
| GAME-051 | Filter by group | 1. Go to game history<br>2. Filter by group | Only group games shown | [ ] |
| GAME-052 | Filter by date | 1. Go to game history<br>2. Set date range | Games within range shown | [ ] |

---

## 7. Training Sessions

### 7.1 Training List

| ID | Test Case | Steps | Expected Result | Status |
|----|-----------|-------|-----------------|--------|
| TRAIN-001 | View training sessions | 1. Go to group<br>2. Training tab | List of sessions displayed | [ ] |
| TRAIN-002 | View upcoming sessions | 1. Go to Training tab | Upcoming sessions shown first | [ ] |
| TRAIN-003 | Empty training list | 1. Go to new group<br>2. Training tab | Empty state message | [ ] |

### 7.2 Create Training Session

| ID | Test Case | Steps | Expected Result | Status |
|----|-----------|-------|-----------------|--------|
| TRAIN-010 | Create training session | 1. Tap "Create Training"<br>2. Fill details<br>3. Save | Session created | [ ] |
| TRAIN-011 | Create with recurrence | 1. Create session<br>2. Enable recurrence<br>3. Set weekly pattern<br>4. Save | Recurring sessions generated | [ ] |
| TRAIN-012 | Create with participant limit | 1. Create with max participants<br>2. Save | Limit enforced on join | [ ] |
| TRAIN-013 | Create in past | 1. Try to set past date | Validation error | [ ] |

### 7.3 Training Details

| ID | Test Case | Steps | Expected Result | Status |
|----|-----------|-------|-----------------|--------|
| TRAIN-020 | View training details | 1. Tap on session | Details page displayed | [ ] |
| TRAIN-021 | View participants | 1. Go to details<br>2. Participants tab | List of participants | [ ] |
| TRAIN-022 | View exercises | 1. Go to details<br>2. Exercises tab | List of exercises | [ ] |

### 7.4 Join/Leave Training

| ID | Test Case | Steps | Expected Result | Status |
|----|-----------|-------|-----------------|--------|
| TRAIN-030 | Join training | 1. Go to session<br>2. Tap "Join" | Added to participants | [ ] |
| TRAIN-031 | Leave training | 1. As participant<br>2. Tap "Leave" | Removed from participants | [ ] |
| TRAIN-032 | Join full session | 1. Try to join at capacity | "Session full" message | [ ] |

### 7.5 Cancel Training

| ID | Test Case | Steps | Expected Result | Status |
|----|-----------|-------|-----------------|--------|
| TRAIN-040 | Cancel session (organizer) | 1. As organizer<br>2. Tap "Cancel"<br>3. Confirm | Session cancelled, participants notified | [ ] |
| TRAIN-041 | Cancel as non-organizer | 1. As participant<br>2. Try to cancel | Cannot cancel (no option) | [ ] |

### 7.6 Exercises

| ID | Test Case | Steps | Expected Result | Status |
|----|-----------|-------|-----------------|--------|
| TRAIN-050 | Add exercise | 1. As organizer<br>2. Go to Exercises tab<br>3. Add exercise | Exercise added to list | [ ] |
| TRAIN-051 | Edit exercise | 1. Select exercise<br>2. Edit details<br>3. Save | Exercise updated | [ ] |
| TRAIN-052 | Delete exercise | 1. Select exercise<br>2. Delete | Exercise removed | [ ] |
| TRAIN-053 | Add exercise after start | 1. After session starts<br>2. Try to add exercise | Cannot add (session started) | [ ] |

### 7.7 Feedback

| ID | Test Case | Steps | Expected Result | Status |
|----|-----------|-------|-----------------|--------|
| TRAIN-060 | Submit feedback | 1. After session ends<br>2. Go to Feedback<br>3. Rate and comment<br>4. Submit | Feedback submitted (anonymous) | [ ] |
| TRAIN-061 | View feedback (organizer) | 1. As organizer<br>2. Go to Feedback tab | Aggregated feedback shown | [ ] |
| TRAIN-062 | Submit duplicate feedback | 1. Submit feedback<br>2. Try to submit again | "Already submitted" message | [ ] |
| TRAIN-063 | Submit before session ends | 1. Before session ends<br>2. Try to submit feedback | Cannot submit yet | [ ] |

---

## 8. Notifications

### 8.1 Notification Types

| ID | Test Case | Steps | Expected Result | Status |
|----|-----------|-------|-----------------|--------|
| NOTIF-001 | Friend request notification | 1. User B sends request<br>2. Check User A notifications | Notification received | [ ] |
| NOTIF-002 | Friend accepted notification | 1. Accept friend request<br>2. Check sender notifications | Notification received | [ ] |
| NOTIF-003 | Group invitation notification | 1. Invite user to group<br>2. Check invitee notifications | Notification received | [ ] |
| NOTIF-004 | Game created notification | 1. Create game in group<br>2. Check member notifications | All members notified | [ ] |
| NOTIF-005 | Player joined notification | 1. Join a game<br>2. Check other players' notifications | Players notified | [ ] |
| NOTIF-006 | Game result notification | 1. Submit game result<br>2. Check player notifications | Players notified | [ ] |
| NOTIF-007 | Training created notification | 1. Create training session<br>2. Check member notifications | Members notified | [ ] |
| NOTIF-008 | Training cancelled notification | 1. Cancel training<br>2. Check participant notifications | Participants notified | [ ] |
| NOTIF-009 | Member joined group notification | 1. User joins group<br>2. Check other member notifications | Members notified | [ ] |
| NOTIF-010 | Member left group notification | 1. User leaves group<br>2. Check other member notifications | Members notified | [ ] |
| NOTIF-011 | Role changed notification | 1. Promote/demote member<br>2. Check user notification | User notified of role change | [ ] |
| NOTIF-012 | Player left game notification | 1. Player leaves game<br>2. Check other player notifications | Players notified | [ ] |
| NOTIF-013 | Waitlist promoted notification | 1. Player leaves full game<br>2. Check waitlisted user notification | Waitlisted user notified | [ ] |
| NOTIF-014 | Game cancelled notification | 1. Cancel a game<br>2. Check player notifications | All players notified | [ ] |
| NOTIF-015 | Training feedback received notification | 1. Submit training feedback<br>2. Check organizer notification | Organizer notified of new feedback | [ ] |
| NOTIF-016 | Training min participants reached | 1. Enough players join training<br>2. Check organizer notification | Organizer notified threshold reached | [ ] |
| NOTIF-017 | Invitation accepted notification | 1. Accept group invitation<br>2. Check inviter/admin notifications | Group admins notified | [ ] |

### 8.2 Notification Settings

| ID | Test Case | Steps | Expected Result | Status |
|----|-----------|-------|-----------------|--------|
| NOTIF-020 | Toggle notification type | 1. Go to Notification Settings<br>2. Toggle a type off<br>3. Trigger that notification | No notification received | [ ] |
| NOTIF-021 | Set quiet hours | 1. Go to Notification Settings<br>2. Enable quiet hours<br>3. Set time range | No notifications during quiet hours | [ ] |
| NOTIF-022 | Disable all notifications | 1. Toggle master switch off | No notifications received | [ ] |

---

## 9. Edge Cases & Error Scenarios

### 9.1 Network & Connectivity

| ID | Test Case | Steps | Expected Result | Status |
|----|-----------|-------|-----------------|--------|
| EDGE-001 | Offline mode | 1. Disable network<br>2. Try to use app | Offline message, cached data shown | [ ] |
| EDGE-002 | Slow network | 1. Use network throttling<br>2. Perform actions | Loading states shown, no crashes | [ ] |
| EDGE-003 | Network loss during action | 1. Start an action<br>2. Disable network mid-action | Error handled, retry option | [ ] |
| EDGE-004 | Reconnection | 1. Go offline<br>2. Reconnect | Data syncs, app recovers | [ ] |

### 9.2 Concurrent Actions

| ID | Test Case | Steps | Expected Result | Status |
|----|-----------|-------|-----------------|--------|
| EDGE-010 | Same game joined simultaneously | 1. Two users join last spot at same time | One succeeds, one gets waitlist/error | [ ] |
| EDGE-011 | Result submitted simultaneously | 1. Two players submit different results | Conflict handled gracefully | [ ] |
| EDGE-012 | Invitation accepted while cancelled | 1. Accept invitation as it's being revoked | Handled gracefully | [ ] |

### 9.3 Boundary Conditions

| ID | Test Case | Steps | Expected Result | Status |
|----|-----------|-------|-----------------|--------|
| EDGE-020 | Very long text inputs | 1. Enter 500+ character description | Truncated or error shown | [ ] |
| EDGE-021 | Special characters in name | 1. Use emojis, unicode in name | Handled correctly or validated | [ ] |
| EDGE-022 | Large image upload | 1. Try to upload very large image | Resized or error shown | [ ] |
| EDGE-023 | Many groups (50+) | 1. User in 50+ groups | Performance acceptable | [ ] |
| EDGE-024 | Many games in group (100+) | 1. Group with 100+ games | Pagination works | [ ] |

### 9.4 Authentication Edge Cases

| ID | Test Case | Steps | Expected Result | Status |
|----|-----------|-------|-----------------|--------|
| EDGE-030 | Session expiry | 1. Leave app for extended period<br>2. Return | Session refreshed or re-login | [ ] |
| EDGE-031 | Account deleted externally | 1. Delete account via Firebase Console<br>2. Try to use app | Logged out, appropriate message | [ ] |
| EDGE-032 | Password changed on another device | 1. Change password elsewhere<br>2. Use app | Session invalidated | [ ] |

### 9.5 Permission Edge Cases

| ID | Test Case | Steps | Expected Result | Status |
|----|-----------|-------|-----------------|--------|
| EDGE-040 | Access removed group | 1. Leave/get removed from group<br>2. Try to access via deep link | "Access denied" message | [ ] |
| EDGE-041 | Access private game | 1. Try to join game in non-member group | Cannot access | [ ] |
| EDGE-042 | Admin action after demotion | 1. Get demoted<br>2. Try admin action | Permission denied | [ ] |

---

## 10. Cross-Platform Testing

### 10.1 Platform-Specific Tests

#### Android

| ID | Test Case | Steps | Expected Result | Status |
|----|-----------|-------|-----------------|--------|
| PLAT-A01 | Back button navigation | 1. Navigate deep into app<br>2. Press back button | Proper back navigation | [ ] |
| PLAT-A02 | App backgrounding | 1. Background app<br>2. Resume | State preserved | [ ] |
| PLAT-A03 | Rotation handling | 1. Rotate device<br>2. Check all screens | UI adapts correctly | [ ] |
| PLAT-A04 | Push notifications | 1. Receive notification while app closed<br>2. Tap notification | Opens correct screen | [ ] |
| PLAT-A05 | Camera permission | 1. Try to upload avatar<br>2. Check permission request | Permission requested properly | [ ] |

#### iOS

| ID | Test Case | Steps | Expected Result | Status |
|----|-----------|-------|-----------------|--------|
| PLAT-I01 | Swipe back gesture | 1. Navigate into screen<br>2. Swipe from left edge | Goes back | [ ] |
| PLAT-I02 | App backgrounding | 1. Background app<br>2. Resume | State preserved | [ ] |
| PLAT-I03 | Safe area handling | 1. Check screens on notched device | No content under notch | [ ] |
| PLAT-I04 | Push notifications | 1. Receive notification<br>2. Tap notification | Opens correct screen | [ ] |
| PLAT-I05 | Photo library access | 1. Try to upload avatar<br>2. Check permission | Permission dialog shown | [ ] |

#### Web

| ID | Test Case | Steps | Expected Result | Status |
|----|-----------|-------|-----------------|--------|
| PLAT-W01 | Browser back/forward | 1. Navigate app<br>2. Use browser buttons | Correct navigation | [ ] |
| PLAT-W02 | URL deep linking | 1. Copy URL of a page<br>2. Paste in new tab | Page loads correctly | [ ] |
| PLAT-W03 | Responsive layout | 1. Resize browser window<br>2. Check various sizes | UI adapts | [ ] |
| PLAT-W04 | Browser refresh | 1. Refresh page | State maintained (if logged in) | [ ] |
| PLAT-W05 | Tab switching | 1. Open multiple tabs<br>2. Switch between | Sessions independent | [ ] |

### 10.2 Device-Specific Tests

| ID | Test Case | Device Type | Expected Result | Status |
|----|-----------|-------------|-----------------|--------|
| DEV-001 | Small phone | 4" screen | UI usable, no overflow | [ ] |
| DEV-002 | Large phone | 6.5"+ screen | UI fills space well | [ ] |
| DEV-003 | Tablet | 10"+ screen | Layout adapts (or works) | [ ] |
| DEV-004 | Low-end device | Budget Android | Acceptable performance | [ ] |
| DEV-005 | Desktop browser | Large screen | Responsive or centered | [ ] |

---

## 11. Test Execution Log

### Test Run Template

| Run ID | Date | Tester | Platform | Version | Status |
|--------|------|--------|----------|---------|--------|
| TR-001 | YYYY-MM-DD | Name | Android/iOS/Web | X.X.X | In Progress/Complete |

### Bug Report Template

```markdown
## Bug Report

**ID**: BUG-XXX
**Test Case**: [Test Case ID]
**Platform**: Android/iOS/Web
**Device**: [Device name and OS version]
**App Version**: X.X.X

### Description
[Brief description of the bug]

### Steps to Reproduce
1. Step 1
2. Step 2
3. Step 3

### Expected Result
[What should happen]

### Actual Result
[What actually happened]

### Screenshots/Videos
[Attach if available]

### Severity
Critical/High/Medium/Low

### Status
Open/In Progress/Fixed/Closed
```

---

## Summary Statistics

| Category | Total Tests |
|----------|-------------|
| Authentication | 15 |
| Profile | 17 |
| Friends | 11 |
| Groups | 20 |
| Games | 20 |
| Training | 18 |
| Notifications | 19 |
| Edge Cases | 18 |
| Cross-Platform | 15 |
| **Total** | **153** |

---

## Document History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | Jan 2026 | Initial checklist creation |
| 1.1 | Jan 2026 | Added 12 additional tests: 9 notification types (NOTIF-009 to NOTIF-017), 3 pending invitations tests (GROUP-035 to GROUP-037). Total tests: 153 |
