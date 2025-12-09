# Project Actions & User Journeys

This document lists all user-facing actions available in the **PlayWithMe** application. It serves as a master checklist for designing End-to-End (E2E) Integration Tests.

## 1. Authentication

### Login Screen (`LoginPage`)
- [ ] **Sign In with Email/Password**: User enters valid credentials and taps "Login".
- [ ] **Sign In Anonymously**: User taps "Skip" or "Guest" (if enabled).
- [ ] **Navigate to Registration**: User taps "Create Account".
- [ ] **Navigate to Forgot Password**: User taps "Forgot Password".

### Registration Screen (`RegistrationPage`)
- [ ] **Register**: User enters email, password, display name and taps "Sign Up".

### Password Reset Screen (`PasswordResetPage`)
- [ ] **Send Reset Link**: User enters email and taps "Send Reset Link".

---

## 2. User Profile

### Profile Screen (`ProfilePage`)
- [ ] **View Stats**: Verify ELO, Win Rate, and Charts are visible.
- [ ] **Sign Out**: User taps "Sign Out" -> Confirm Dialog -> Logout.
- [ ] **Navigate to Edit Profile**: User taps "Edit Profile" button.
- [ ] **Navigate to Notification Settings**: User taps "Settings" icon.
- [ ] **Navigate to Email Verification**: User taps verification banner (if unverified).

### Edit Profile Screen (`ProfileEditPage`)
- [ ] **Update Display Name**: Change text and Save.
- [ ] **Update Bio**: Change text and Save.
- [ ] **Upload Avatar**: Tap camera icon -> Select Image -> Save.
- [ ] **Delete Avatar**: Tap delete icon -> Confirm -> Save.

### Email Verification Screen (`EmailVerificationPage`)
- [ ] **Resend Verification Email**: User taps "Resend".
- [ ] **Refresh Status**: User taps "I've verified".

---

## 3. Friends & Community

### My Community Screen (`MyCommunityPage`)
- [ ] **View Friends List**: Scroll through accepted friends.
- [ ] **View Friend Requests**: See "Received" and "Sent" tabs/sections.
- [ ] **Accept Friend Request**: Tap "Accept" on a received request.
- [ ] **Decline Friend Request**: Tap "Decline" on a received request.
- [ ] **Cancel Sent Request**: Tap "Cancel" on a sent request.
- [ ] **Remove Friend**: Tap friend -> Action Menu -> "Remove Friend".
- [ ] **Navigate to Add Friend**: Tap "Add Friend" (FAB or button).

### Add Friend Screen (`AddFriendPage`)
- [ ] **Search User**: Enter email in search bar.
- [ ] **Send Friend Request**: Tap "Add" next to search result.

---

## 4. Groups

### Group List Screen (`GroupListPage`)
- [ ] **List Groups**: View groups user belongs to.
- [ ] **Refresh List**: Pull-to-refresh.
- [ ] **Navigate to Group Details**: Tap a group item.
- [ ] **Navigate to Create Group**: Tap "Create Group" FAB.

### Group Creation Screen (`GroupCreationPage`)
- [ ] **Create Group**: Enter Name, Description, Privacy -> Tap "Create".

### Group Details Screen (`GroupDetailsPage`)
- [ ] **View Members**: See list of members/admins.
- [ ] **View Group Games**: See list of games for this group.
- [ ] **Invite Member**: Tap "Invite" -> Navigate to Invite Screen (Admin/Member depending on privacy).
- [ ] **Leave Group**: Action Menu -> "Leave Group" -> Confirm.
- [ ] **Edit Group**: Action Menu -> "Edit" (Admin only).
- [ ] **Delete Group**: Action Menu -> "Delete" (Owner only).
- [ ] **Promote Member**: Tap Member -> "Promote to Admin" (Admin only).
- [ ] **Remove Member**: Tap Member -> "Remove from Group" (Admin only).

### Invite Member Screen (`InviteMemberPage`)
- [ ] **Search Friend to Invite**: Filter friends list.
- [ ] **Send Invitation**: Select friend -> Tap "Send Invite".

---

## 5. Games

### Games List Screen (`GamesListPage`)
- [ ] **Filter Upcoming/Past**: Toggle tabs.
- [ ] **Refresh List**: Pull-to-refresh.
- [ ] **Navigate to Game Details**: Tap a game card.
- [ ] **Navigate to Create Game**: Tap "Create Game" FAB.

### Game Creation Screen (`GameCreationPage`)
- [ ] **Create Game**: Select Group, Date, Time, Location, Type -> Tap "Create".

### Game Details Screen (`GameDetailsPage`)
- [ ] **Join Game (RSVP Yes)**: Tap "I'm In".
- [ ] **Leave Game (RSVP No)**: Tap "I'm Out".
- [ ] **Join Waitlist**: Tap "Join Waitlist" (if full).
- [ ] **Start Game**: Tap "Start Game" (Creator/Admin, on day of game).
- [ ] **Cancel Game**: Tap "Cancel Game" (Creator/Admin).
- [ ] **Navigate to Record Results**: Tap "Record Results" (after game started).
- [ ] **Navigate to View Result**: Tap "View Result" (completed game).

### Record Results Screen (`RecordResultsPage`)
- [ ] **Assign Teams**: Drag/Drop or Select players for Team A/B.
- [ ] **Save Teams**: Tap "Next" or "Save Teams".

### Score Entry Screen (`ScoreEntryPage`)
- [ ] **Enter Score**: Input scores for sets.
- [ ] **Save Result**: Tap "Finish Game" -> Triggers ELO calc.

### Game History Screen (`GameHistoryScreen`)
- [ ] **View Completed Games**: Scroll list of globally completed games (or user specific).

---

## 6. Invitations

### Pending Invitations Screen (`PendingInvitationsPage`)
- [ ] **Accept Group Invite**: Tap "Join".
- [ ] **Decline Group Invite**: Tap "Decline".

---

## 7. Notifications

### Notification Settings Screen (`NotificationSettingsPage`)
- [ ] **Toggle Push Notifications**: Switch On/Off.
- [ ] **Toggle Email Notifications**: Switch On/Off.
- [ ] **Set Quiet Hours**: Configure time range.

---

## 8. System/Background Journeys (Test via Side Effects)

- [ ] **Receive Push Notification**: Triggered when added to group or game created.
- [ ] **ELO Update**: Triggered after Game Result saved. Verify Profile Stats updated.
- [ ] **Streak Update**: Triggered after Game Result. Verify Profile Stats.
