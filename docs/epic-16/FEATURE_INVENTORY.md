# PlayWithMe - Feature Inventory

**Document Version**: 1.0
**Last Updated**: January 2026
**Story Reference**: Story 16.1 (#379)

---

## Table of Contents

1. [Overview](#overview)
2. [App Architecture Summary](#app-architecture-summary)
3. [Screens & Pages](#screens--pages)
4. [Cloud Functions](#cloud-functions)
5. [BLoCs (Business Logic Components)](#blocs-business-logic-components)
6. [Repositories](#repositories)
7. [User Flows](#user-flows)
8. [Key Findings](#key-findings)

---

## Overview

PlayWithMe is a Flutter mobile app for organizing beach volleyball games and training sessions. The app follows a **BLoC with Repository Pattern** architecture and uses **Firebase** as the backend.

### Quick Stats

| Component | Count |
|-----------|-------|
| Screens/Pages | 27 |
| Cloud Functions | 46 |
| BLoCs | 30 |
| Repositories | 9 |
| Feature Areas | 7 |

---

## App Architecture Summary

```
┌─────────────────────────────────────────────────────────────┐
│                        UI Layer                              │
│  (Pages, Widgets - "Dumb" components, display only)         │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                       BLoC Layer                             │
│  (Business Logic - handles events, emits states)            │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                    Repository Layer                          │
│  (Data abstraction - interfaces for data access)            │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                      Data Sources                            │
│  (Firebase Firestore, Cloud Functions, Storage)             │
└─────────────────────────────────────────────────────────────┘
```

---

## Screens & Pages

### 1. Authentication (3 pages)

| Page | File Location | Purpose | Key Features |
|------|---------------|---------|--------------|
| **Login** | `lib/features/auth/presentation/pages/login_page.dart` | User authentication | Email/password login, anonymous login option |
| **Registration** | `lib/features/auth/presentation/pages/registration_page.dart` | New user signup | Email, password, display name |
| **Password Reset** | `lib/features/auth/presentation/pages/password_reset_page.dart` | Recover account | Send reset email |

**Navigation Flow:**
```
App Start → Login Page
         ├── Success → Home (Group List)
         ├── Register → Registration Page → Email Verification
         └── Forgot Password → Password Reset Page
```

---

### 2. Profile (6 pages)

| Page | File Location | Purpose | Key Features |
|------|---------------|---------|--------------|
| **Profile** | `lib/features/profile/presentation/pages/profile_page.dart` | View own profile | Stats, ELO, game history |
| **Profile Edit** | `lib/features/profile/presentation/pages/profile_edit_page.dart` | Edit profile info | Name, avatar upload |
| **Email Verification** | `lib/features/profile/presentation/pages/email_verification_page.dart` | Verify email | Send verification, check status |
| **Full ELO History** | `lib/features/profile/presentation/pages/full_elo_history_page.dart` | ELO progression | Chart, history list |
| **Head to Head** | `lib/features/profile/presentation/pages/head_to_head_page.dart` | H2H statistics | Win/loss vs specific player |
| **Partner Detail** | `lib/features/profile/presentation/pages/partner_detail_page.dart` | Teammate stats | Games played together, win rate |

**Navigation Flow:**
```
Profile Page
├── Edit → Profile Edit Page
├── ELO Chart → Full ELO History Page
├── H2H Section → Head to Head Page
└── Partners Section → Partner Detail Page
```

---

### 3. Friends / My Community (2 pages)

| Page | File Location | Purpose | Key Features |
|------|---------------|---------|--------------|
| **My Community** | `lib/features/friends/presentation/pages/my_community_page.dart` | Friend management | Friend list, pending requests |
| **Add Friend** | `lib/features/friends/presentation/pages/add_friend_page.dart` | Find & add friends | Search by email/name |

**Navigation Flow:**
```
My Community Page
├── Friends Tab → Friend List → Remove Friend
├── Requests Tab → Accept/Decline Requests
└── Add Friend FAB → Add Friend Page → Send Request
```

---

### 4. Groups (4 pages)

| Page | File Location | Purpose | Key Features |
|------|---------------|---------|--------------|
| **Group List** | `lib/features/groups/presentation/pages/group_list_page.dart` | View all groups | List, create button |
| **Group Details** | `lib/features/groups/presentation/pages/group_details_page.dart` | Group hub | Members, games, training tabs |
| **Group Creation** | `lib/features/groups/presentation/pages/group_creation_page.dart` | Create group | Name, description, sport type |
| **Invite Member** | `lib/features/groups/presentation/pages/invite_member_page.dart` | Invite to group | Select from friends list |

**Navigation Flow:**
```
Group List Page (Home)
├── Create FAB → Group Creation Page
└── Group Card → Group Details Page
                 ├── Members Tab → Invite Member Page
                 ├── Games Tab → Games List
                 └── Training Tab → Training List
```

---

### 5. Invitations (1 page)

| Page | File Location | Purpose | Key Features |
|------|---------------|---------|--------------|
| **Pending Invitations** | `lib/features/invitations/presentation/pages/pending_invitations_page.dart` | Manage invitations | Accept/decline group invites |

**Navigation Flow:**
```
App Bar Badge → Pending Invitations Page → Accept/Decline
```

---

### 6. Games (7 pages)

| Page | File Location | Purpose | Key Features |
|------|---------------|---------|--------------|
| **Games List** | `lib/features/games/presentation/pages/games_list_page.dart` | Group games | Upcoming, past games |
| **Game Details** | `lib/features/games/presentation/pages/game_details_page.dart` | Game info | Players, teams, results |
| **Game Creation** | `lib/features/games/presentation/pages/game_creation_page.dart` | Create game | Date, time, location, limits |
| **Game History** | `lib/features/games/presentation/pages/game_history_screen.dart` | Past games | All completed games |
| **Record Results** | `lib/features/games/presentation/pages/record_results_page.dart` | Enter results | Team selection, scores |
| **Score Entry** | `lib/features/games/presentation/pages/score_entry_page.dart` | Set scores | Per-set score entry |
| **Game Result View** | `lib/features/games/presentation/pages/game_result_view_page.dart` | View results | Final scores display |

**Navigation Flow:**
```
Group Details → Games Tab → Games List Page
                            ├── Create FAB → Game Creation Page
                            └── Game Card → Game Details Page
                                            ├── Join/Leave Button
                                            ├── Record Results → Record Results Page
                                            │                    └── Score Entry Page
                                            └── View Results → Game Result View Page
```

---

### 7. Training Sessions (3 pages)

| Page | File Location | Purpose | Key Features |
|------|---------------|---------|--------------|
| **Training Details** | `lib/features/training/presentation/pages/training_session_details_page.dart` | Session hub | Participants, exercises, feedback |
| **Training Creation** | `lib/features/training/presentation/pages/training_session_creation_page.dart` | Create session | Date, time, location, recurrence |
| **Training Feedback** | `lib/features/training/presentation/pages/training_session_feedback_page.dart` | Submit feedback | Anonymous rating & comments |

**Navigation Flow:**
```
Group Details → Training Tab → Training List
                               ├── Create FAB → Training Creation Page
                               └── Training Card → Training Details Page
                                                   ├── Participants Tab
                                                   ├── Exercises Tab
                                                   ├── Feedback Tab → Training Feedback Page
                                                   ├── Join/Leave FAB
                                                   └── Cancel (organizer only)
```

---

### 8. Notifications (1 page)

| Page | File Location | Purpose | Key Features |
|------|---------------|---------|--------------|
| **Notification Settings** | `lib/features/notifications/presentation/pages/notification_settings_page.dart` | Manage notifications | Toggle by type, quiet hours |

**Navigation Flow:**
```
Profile/Settings → Notification Settings Page
```

---

## Cloud Functions

### Summary by Category

| Category | Count | Purpose |
|----------|-------|---------|
| Auth Triggers | 2 | User document lifecycle |
| User Management | 4 | Search, profiles |
| Groups & Invitations | 5 | Group membership |
| Friendships | 10 | Social graph |
| Games | 3 | Game queries |
| Training Sessions | 8 | Training CRUD |
| Stats & Rankings | 3 | ELO, H2H |
| Notification Triggers | 15 | Push notifications |
| Training Notifications | 5 | Training-specific notifications |
| Game Updates | 2 | ELO calculation triggers |
| Cache Triggers | 2 | Friendship cache |

### Complete Function List

#### Auth Triggers
| Function | Trigger | Purpose |
|----------|---------|---------|
| `createUserDocument` | `onCreate` auth | Create Firestore user doc |
| `deleteUserDocument` | `onDelete` auth | Clean up user data |

#### User Management (Callable)
| Function | Purpose |
|----------|---------|
| `searchUserByEmail` | Find user by exact email |
| `searchUsers` | Search users by query string |
| `getUsersByIds` | Batch get users by ID list |
| `getPublicUserProfile` | Get public profile data |

#### Groups & Invitations (Callable)
| Function | Purpose |
|----------|---------|
| `checkPendingInvitation` | Check if invitation exists |
| `acceptInvitation` | Accept group invitation |
| `declineInvitation` | Decline group invitation |
| `leaveGroup` | Leave a group |
| `inviteToGroup` | Invite user to group |

#### Friendships (Callable)
| Function | Purpose |
|----------|---------|
| `sendFriendRequest` | Send friend request |
| `acceptFriendRequest` | Accept friend request |
| `declineFriendRequest` | Decline friend request |
| `removeFriend` | Remove existing friend |
| `getFriends` | Get friend list |
| `checkFriendshipStatus` | Check status between two users |
| `getFriendshipRequests` | Get pending requests |
| `getFriendships` | Get all friendships |
| `verifyFriendship` | Verify friendship exists |
| `batchCheckFriendship` | Batch check multiple friendships |

#### Games (Callable)
| Function | Purpose |
|----------|---------|
| `getGamesForGroup` | Get games for a group |
| `getCompletedGames` | Get completed games |
| `autoAbortGames` | Scheduled: auto-abort stale games |

#### Training Sessions (Callable)
| Function | Purpose |
|----------|---------|
| `createTrainingSession` | Create training session |
| `generateRecurringTrainingSessions` | Generate recurring instances |
| `joinTrainingSession` | Join training session |
| `leaveTrainingSession` | Leave training session |
| `cancelTrainingSession` | Cancel training session |
| `submitTrainingFeedback` | Submit anonymous feedback |
| `hasSubmittedTrainingFeedback` | Check if user submitted feedback |
| `getTrainingFeedback` | Get aggregated feedback |

#### Stats & Rankings (Callable)
| Function | Purpose |
|----------|---------|
| `getHeadToHeadStats` | Get H2H statistics |
| `calculateUserRanking` | Calculate user ranking |
| `onHeadToHeadStatsUpdated` | Update nemesis stats |

#### Notification Triggers (Firestore)
| Function | Trigger | Purpose |
|----------|---------|---------|
| `onInvitationCreated` | `onCreate` invitation | Notify invitee |
| `onInvitationAccepted` | `onUpdate` invitation | Notify group |
| `onGameCreated` | `onCreate` game | Notify group members |
| `onMemberJoined` | `onCreate` member | Notify group |
| `onMemberLeft` | `onDelete` member | Notify group |
| `onRoleChanged` | `onUpdate` member | Notify user |
| `onFriendRequestSent` | `onCreate` request | Notify recipient |
| `onFriendRequestAccepted` | `onUpdate` request | Notify sender |
| `onFriendRequestDeclined` | `onUpdate` request | Notify sender |
| `onFriendRemoved` | `onDelete` friendship | Notify friend |
| `onPlayerJoinedGame` | `onCreate` player | Notify game members |
| `onPlayerLeftGame` | `onDelete` player | Notify game members |
| `onWaitlistPromoted` | `onUpdate` player | Notify promoted user |
| `onGameResultSubmitted` | `onUpdate` game | Notify players |
| `onGameCancelled` | `onUpdate` game | Notify players |

#### Training Notification Triggers
| Function | Trigger | Purpose |
|----------|---------|---------|
| `onTrainingSessionCreated` | `onCreate` session | Notify group |
| `onTrainingSessionUpdated` | `onUpdate` session | Notify on cancel |
| `onTrainingFeedbackCreated` | `onCreate` feedback | Notify participants |
| `onParticipantJoined` | `onCreate` participant | Notify others |
| `onParticipantLeft` | `onUpdate` participant | Notify organizer |

#### Game Update Triggers
| Function | Trigger | Purpose |
|----------|---------|---------|
| `onGameStatusChanged` | `onUpdate` game | Calculate ELO |
| `onEloCalculationComplete` | `onUpdate` game | Update H2H stats |

#### Cache Triggers
| Function | Trigger | Purpose |
|----------|---------|---------|
| `onFriendshipCacheUpdate` | `onUpdate` friendship | Update cache |
| `onFriendshipCacheRemove` | `onDelete` friendship | Remove from cache |

---

## BLoCs (Business Logic Components)

### Summary by Feature

| Feature | BLoC Count | BLoCs |
|---------|------------|-------|
| Core | 5 | Game, Group, GroupMember, Invitation, User |
| Auth | 4 | Authentication, Login, Registration, PasswordReset |
| Friends | 2 | Friend, FriendRequestCount |
| Games | 6 | GameCreation, GameDetails, GamesList, GameHistory, RecordResults, ScoreEntry |
| Profile | 8 | ProfileEdit, AvatarUpload, EmailVerification, EloHistory, HeadToHead, PartnerDetail, PlayerStats, LocalePreferences |
| Training | 4 | TrainingSessionCreation, TrainingSessionParticipation, Exercise, TrainingFeedback |
| Notifications | 1 | Notification |

### Complete BLoC List

#### Core BLoCs
| BLoC | File | Purpose |
|------|------|---------|
| `GameBloc` | `core/presentation/bloc/game/game_bloc.dart` | Game state management |
| `GroupBloc` | `core/presentation/bloc/group/group_bloc.dart` | Group state management |
| `GroupMemberBloc` | `core/presentation/bloc/group_member/group_member_bloc.dart` | Member management |
| `InvitationBloc` | `core/presentation/bloc/invitation/invitation_bloc.dart` | Invitation handling |
| `UserBloc` | `core/presentation/bloc/user/user_bloc.dart` | User state management |

#### Auth BLoCs
| BLoC | File | Purpose |
|------|------|---------|
| `AuthenticationBloc` | `features/auth/presentation/bloc/authentication/authentication_bloc.dart` | Auth state (logged in/out) |
| `LoginBloc` | `features/auth/presentation/bloc/login/login_bloc.dart` | Login flow handling |
| `RegistrationBloc` | `features/auth/presentation/bloc/registration/registration_bloc.dart` | Registration flow |
| `PasswordResetBloc` | `features/auth/presentation/bloc/password_reset/password_reset_bloc.dart` | Password reset flow |

#### Friends BLoCs
| BLoC | File | Purpose |
|------|------|---------|
| `FriendBloc` | `features/friends/presentation/bloc/friend_bloc.dart` | Friend list & requests |
| `FriendRequestCountBloc` | `features/friends/presentation/bloc/friend_request_count_bloc.dart` | Badge count |

#### Games BLoCs
| BLoC | File | Purpose |
|------|------|---------|
| `GameCreationBloc` | `features/games/presentation/bloc/game_creation/game_creation_bloc.dart` | Create game flow |
| `GameDetailsBloc` | `features/games/presentation/bloc/game_details/game_details_bloc.dart` | Game details state |
| `GamesListBloc` | `features/games/presentation/bloc/games_list/games_list_bloc.dart` | Games list for group |
| `GameHistoryBloc` | `features/games/presentation/bloc/game_history/game_history_bloc.dart` | Game history |
| `RecordResultsBloc` | `features/games/presentation/bloc/record_results/record_results_bloc.dart` | Record results |
| `ScoreEntryBloc` | `features/games/presentation/bloc/score_entry/score_entry_bloc.dart` | Score entry |

#### Profile BLoCs
| BLoC | File | Purpose |
|------|------|---------|
| `ProfileEditBloc` | `features/profile/presentation/bloc/profile_edit/profile_edit_bloc.dart` | Edit profile |
| `AvatarUploadBloc` | `features/profile/presentation/bloc/avatar_upload/avatar_upload_bloc.dart` | Avatar upload |
| `EmailVerificationBloc` | `features/profile/presentation/bloc/email_verification/email_verification_bloc.dart` | Email verification |
| `EloHistoryBloc` | `features/profile/presentation/bloc/elo_history/elo_history_bloc.dart` | ELO history |
| `HeadToHeadBloc` | `features/profile/presentation/bloc/head_to_head/head_to_head_bloc.dart` | H2H statistics |
| `PartnerDetailBloc` | `features/profile/presentation/bloc/partner_detail/partner_detail_bloc.dart` | Partner stats |
| `PlayerStatsBloc` | `features/profile/presentation/bloc/player_stats/player_stats_bloc.dart` | Player statistics |
| `LocalePreferencesBloc` | `features/profile/presentation/bloc/locale_preferences/locale_preferences_bloc.dart` | Language prefs |

#### Training BLoCs
| BLoC | File | Purpose |
|------|------|---------|
| `TrainingSessionCreationBloc` | `features/training/presentation/bloc/training_session_creation/training_session_creation_bloc.dart` | Create training |
| `TrainingSessionParticipationBloc` | `features/training/presentation/bloc/training_session_participation/training_session_participation_bloc.dart` | Join/leave/cancel |
| `ExerciseBloc` | `features/training/presentation/bloc/exercise/exercise_bloc.dart` | Exercise management |
| `TrainingFeedbackBloc` | `features/training/presentation/bloc/feedback/training_feedback_bloc.dart` | Feedback handling |

#### Notifications BLoC
| BLoC | File | Purpose |
|------|------|---------|
| `NotificationBloc` | `features/notifications/presentation/bloc/notification_bloc.dart` | Notification settings |

---

## Repositories

| Repository | File | Purpose | Key Methods |
|------------|------|---------|-------------|
| `UserRepository` | `user_repository.dart` | User data operations | `getCurrentUser`, `updateProfile`, `getUserById` |
| `GroupRepository` | `group_repository.dart` | Group CRUD | `createGroup`, `getGroups`, `addMember`, `removeMember` |
| `GameRepository` | `game_repository.dart` | Game operations | `createGame`, `joinGame`, `leaveGame`, `submitResults` |
| `InvitationRepository` | `invitation_repository.dart` | Invitations | `sendInvitation`, `acceptInvitation`, `declineInvitation` |
| `FriendRepository` | `friend_repository.dart` | Friendships | `sendRequest`, `acceptRequest`, `getFriends`, `removeFriend` |
| `TrainingSessionRepository` | `training_session_repository.dart` | Training ops | `createSession`, `joinSession`, `leaveSession`, `cancelSession` |
| `TrainingFeedbackRepository` | `training_feedback_repository.dart` | Feedback | `submitFeedback`, `getAggregatedFeedback` |
| `ExerciseRepository` | `exercise_repository.dart` | Exercises | `addExercise`, `updateExercise`, `deleteExercise` |
| `ImageStorageRepository` | `image_storage_repository.dart` | Image storage | `uploadImage`, `deleteImage` |

---

## User Flows

### Complete App Navigation Map

```
┌─────────────────────────────────────────────────────────────────┐
│                         APP START                                │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
                    ┌─────────────────┐
                    │   Login Page    │
                    └─────────────────┘
                     │      │      │
          ┌──────────┘      │      └──────────┐
          ▼                 ▼                 ▼
   ┌─────────────┐  ┌─────────────┐  ┌─────────────────┐
   │  Register   │  │   Success   │  │ Password Reset  │
   └─────────────┘  └─────────────┘  └─────────────────┘
          │                 │
          ▼                 ▼
   ┌─────────────┐  ┌─────────────────────────────────────────────┐
   │Email Verify │  │              HOME (Group List)               │
   └─────────────┘  └─────────────────────────────────────────────┘
                              │
        ┌─────────────────────┼─────────────────────┐
        ▼                     ▼                     ▼
┌───────────────┐    ┌───────────────┐    ┌───────────────┐
│  My Community │    │ Group Details │    │    Profile    │
└───────────────┘    └───────────────┘    └───────────────┘
        │                     │                     │
        ▼                     ▼                     ▼
┌───────────────┐    ┌───────────────┐    ┌───────────────┐
│  Add Friend   │    │ Members Tab   │    │  Edit Profile │
│  Friend List  │    │ Games Tab     │    │  ELO History  │
│  Requests     │    │ Training Tab  │    │  H2H Stats    │
└───────────────┘    └───────────────┘    └───────────────┘
                              │
              ┌───────────────┴───────────────┐
              ▼                               ▼
     ┌───────────────┐               ┌───────────────┐
     │  Game Details │               │Training Detail│
     └───────────────┘               └───────────────┘
              │                               │
              ▼                               ▼
     ┌───────────────┐               ┌───────────────┐
     │Record Results │               │   Exercises   │
     │ Score Entry   │               │   Feedback    │
     └───────────────┘               └───────────────┘
```

---

## Key Findings

### Strengths

1. **Comprehensive Feature Set**: The app covers the full lifecycle of volleyball game organization
2. **Clean Architecture**: Consistent BLoC pattern across all features
3. **Robust Backend**: 46 Cloud Functions provide secure server-side logic
4. **Real-time Updates**: Firestore streams for live data
5. **Notification System**: Complete notification coverage for all events
6. **Statistics**: ELO rating, H2H stats, partner analytics

### Areas of Complexity

1. **Games Feature**: Most complex with 7 pages, 6 BLoCs - handles scoring, results, ELO
2. **Profile Feature**: Rich stats with 6 pages, 8 BLoCs
3. **Training Feature**: Full CRUD + feedback system with 8 Cloud Functions
4. **Friendships**: 10 Cloud Functions for social graph management

### Feature Distribution

```
Pages by Feature:
├── Games:     7 pages (26%)
├── Profile:   6 pages (22%)
├── Groups:    4 pages (15%)
├── Auth:      3 pages (11%)
├── Training:  3 pages (11%)
├── Friends:   2 pages (7%)
├── Invites:   1 page  (4%)
└── Notifs:    1 page  (4%)

BLoCs by Feature:
├── Profile:   8 BLoCs (27%)
├── Games:     6 BLoCs (20%)
├── Core:      5 BLoCs (17%)
├── Auth:      4 BLoCs (13%)
├── Training:  4 BLoCs (13%)
├── Friends:   2 BLoCs (7%)
└── Notifs:    1 BLoC  (3%)
```

### Integration Points

| Feature | Integrates With |
|---------|-----------------|
| Groups | Games, Training, Members, Invitations |
| Games | Groups, Players, Results, ELO, Notifications |
| Training | Groups, Participants, Exercises, Feedback, Notifications |
| Friends | Users, Groups (invitations), Notifications |
| Profile | Games (stats), ELO, H2H, Partners |

---

## Document History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | Jan 2026 | Initial inventory |
