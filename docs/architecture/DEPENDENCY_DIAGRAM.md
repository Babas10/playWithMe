# Architecture Dependency Diagrams

Visual representations of the **Gatherli** layered architecture and data flow patterns.

---

## 🏗️ High-Level Layer Dependency

```
┌─────────────────────────────────────────────────────────┐
│                      GAMES LAYER                        │
│  ┌────────────────────────────────────────────────────┐ │
│  │ • Game Scheduling                                  │ │
│  │ • Player RSVPs & Waitlists                        │ │
│  │ • Game Results & Scoring                          │ │
│  │ • ELO Ratings                                     │ │
│  └────────────────────────────────────────────────────┘ │
│                          ▲                              │
│                          │ Depends on                   │
│                          │ (via group.memberIds)        │
└──────────────────────────┼──────────────────────────────┘
                           │
┌──────────────────────────▼──────────────────────────────┐
│                     GROUPS LAYER                        │
│  ┌────────────────────────────────────────────────────┐ │
│  │ • Group Creation & Management                      │ │
│  │ • Membership Management                            │ │
│  │ • Group Invitations                                │ │
│  │ • Member Roles & Permissions                       │ │
│  └────────────────────────────────────────────────────┘ │
│                          ▲                              │
│                          │ Depends on                   │
│                          │ (via Cloud Functions)        │
└──────────────────────────┼──────────────────────────────┘
                           │
┌──────────────────────────▼──────────────────────────────┐
│                MY COMMUNITY LAYER                       │
│                  (Social Graph)                         │
│  ┌────────────────────────────────────────────────────┐ │
│  │ • Friend Requests                                  │ │
│  │ • Friendship Validation                            │ │
│  │ • Social Network Queries                           │ │
│  │ • Exposed via Cloud Functions                      │ │
│  └────────────────────────────────────────────────────┘ │
│                          ▲                              │
│                          │ Depends on                   │
│                          │                              │
└──────────────────────────┼──────────────────────────────┘
                           │
┌──────────────────────────▼──────────────────────────────┐
│                      USERS LAYER                        │
│  ┌────────────────────────────────────────────────────┐ │
│  │ • Authentication                                   │ │
│  │ • User Profiles                                    │ │
│  │ • User Preferences                                 │ │
│  │ • Foundation Layer                                 │ │
│  └────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────┘
```

---

## 🔄 Data Flow: Game Creation

```
User Action: Create Game
         │
         ▼
┌─────────────────────┐
│   Game Creation     │
│   Page (UI)         │
└──────────┬──────────┘
           │
           │ 1. User selects group
           │
           ▼
    ┌──────────────┐
    │  Game BLoC   │
    └──────┬───────┘
           │
           │ 2. CreateGame event
           │
           ▼
  ┌──────────────────┐
  │ Game Repository  │
  └────────┬─────────┘
           │
           │ 3. Validate groupId
           │    (read group document)
           ▼
  ┌──────────────────────┐
  │  Group Repository    │
  └────────┬─────────────┘
           │
           │ 4. Return group data
           │    (including memberIds)
           ▼
  ┌──────────────────┐
  │ Game Repository  │ 5. Create game document
  │                  │    with groupId reference
  └────────┬─────────┘
           │
           │ 6. Firestore trigger
           │
           ▼
  ┌──────────────────────┐
  │ Cloud Function:      │
  │ onGameCreated        │
  └────────┬─────────────┘
           │
           │ 7. Notify group members
           │    (use group.memberIds)
           ▼
    Group Members
    Receive Notification

✅ No interaction with My Community layer
✅ Players accessed via group membership
```

---

## 🔄 Data Flow: Group Invitation

```
User Action: Invite Friend to Group
         │
         ▼
┌─────────────────────┐
│   Group Members     │
│   Page (UI)         │
└──────────┬──────────┘
           │
           │ 1. User enters friend's email
           │
           ▼
    ┌──────────────┐
    │  Group BLoC  │
    └──────┬───────┘
           │
           │ 2. InviteToGroup event
           │
           ▼
  ┌──────────────────┐
  │ Group Repository │
  └────────┬─────────┘
           │
           │ 3. Call Cloud Function
           │    verifyFriendship()
           ▼
  ┌───────────────────────────────┐
  │ Cloud Function:               │
  │ verifyFriendship()            │
  │                               │
  │ 4. Query friendships          │
  │    collection (server-side)   │
  │                               │
  │ 5. Return validation result   │
  └────────┬──────────────────────┘
           │
           │ 6. If valid friendship
           ▼
  ┌──────────────────┐
  │ Group Repository │ 7. Create invitation
  │                  │    document
  └────────┬─────────┘
           │
           │ 8. Firestore trigger
           │
           ▼
  ┌──────────────────────┐
  │ Cloud Function:      │
  │ onInvitationCreated  │
  └────────┬─────────────┘
           │
           │ 9. Send notification
           ▼
     Invited User
     Receives Notification

✅ Groups use Cloud Function interface
✅ Never queries friendships directly
```

---

## 🔄 Data Flow: Game RSVP Validation

```
User Action: RSVP to Game
         │
         ▼
┌─────────────────────┐
│   Game Details      │
│   Page (UI)         │
└──────────┬──────────┘
           │
           │ 1. User taps "Going"
           │
           ▼
    ┌──────────────┐
    │  Game BLoC   │
    └──────┬───────┘
           │
           │ 2. RSVPToGame event
           │
           ▼
  ┌──────────────────┐
  │ Game Repository  │
  └────────┬─────────┘
           │
           │ 3. Load game document
           │
           ▼
    Game Document
    { groupId: "group-123" }
           │
           │ 4. Validate membership
           │    Check if userId in group.memberIds
           ▼
  ┌──────────────────────┐
  │  Group Repository    │
  └────────┬─────────────┘
           │
           │ 5. Return membership status
           │
           ▼
  ┌──────────────────┐
  │ Game Repository  │
  └────────┬─────────┘
           │
           │ 6a. If member: add to RSVPs
           │ 6b. If not member: return error
           │
           ▼
     Game Updated
     (or error shown)

✅ No friendship check needed
✅ Group membership sufficient
```

---

## 🚫 Forbidden Dependency: Game → My Community

```
         ❌ WRONG ❌

┌─────────────────────┐
│   Games Layer       │
│                     │
│   Game BLoC         │───────────┐
└─────────────────────┘           │
                                  │ Direct dependency
                                  │ (FORBIDDEN)
                                  │
                                  ▼
                       ┌──────────────────────┐
                       │ My Community Layer   │
                       │                      │
                       │ Friend Repository    │
                       └──────────────────────┘

Why forbidden?
• Breaks layered architecture
• Creates tight coupling
• Bypasses group-based access control
• Makes testing difficult
• Prevents independent evolution


         ✅ CORRECT ✅

┌─────────────────────┐
│   Games Layer       │
│                     │
│   Game BLoC         │
└──────────┬──────────┘
           │
           │ Depends on
           │ (via groupId reference)
           ▼
┌─────────────────────┐
│   Groups Layer      │
│                     │
│   Group Repository  │
└──────────┬──────────┘
           │
           │ Depends on
           │ (via Cloud Function)
           ▼
┌──────────────────────┐
│ My Community Layer   │
│                      │
│ verifyFriendship()   │
└──────────────────────┘

Why correct?
• Respects layer boundaries
• Loose coupling via interfaces
• Group-based access control maintained
• Easy to test with mocks
• Layers can evolve independently
```

---

## 📦 Module Dependency Graph

```
lib/features/
│
├── games/                    ❌ Cannot import
│   ├── presentation/             from friends/
│   │   ├── pages/
│   │   ├── widgets/
│   │   └── bloc/
│   └── ✅ CAN import:
│       • core/domain/repositories/game_repository.dart
│       • core/domain/repositories/group_repository.dart
│       • core/domain/repositories/user_repository.dart
│
├── groups/                   ✅ Can use Cloud Functions
│   ├── presentation/             from My Community
│   │   ├── pages/
│   │   └── widgets/
│   └── ✅ CAN:
│       • Call verifyFriendship() Cloud Function
│       • Import core repositories
│       ❌ CANNOT:
│       • Import features/friends/
│       • Query friendships collection directly
│
└── friends/                  ❌ Cannot import
    ├── presentation/             from groups/ or games/
    │   ├── pages/
    │   ├── widgets/
    │   └── bloc/
    └── ✅ CAN import:
        • core/domain/repositories/user_repository.dart
        • core/domain/repositories/friend_repository.dart

lib/core/
├── domain/
│   └── repositories/
│       ├── user_repository.dart      (Foundation)
│       ├── friend_repository.dart    (Social Graph)
│       ├── group_repository.dart     (Groups)
│       └── game_repository.dart      (Games)
│
└── data/
    └── repositories/
        ├── firestore_user_repository.dart
        ├── firestore_friend_repository.dart
        ├── firestore_group_repository.dart
        └── firestore_game_repository.dart ❌ No friend_repository import
```

---

## 🔐 Security Rules Enforcement

```
Firestore Security Rules enforce layer boundaries:

┌─────────────────────────────────────────────┐
│            CLIENT (Flutter App)             │
└──────────────────┬──────────────────────────┘
                   │
                   │ Firestore Queries
                   │
                   ▼
┌─────────────────────────────────────────────┐
│          Firestore Security Rules           │
│                                             │
│  /games/{gameId}                            │
│    ✅ allow read: if isGroupMember()        │
│    ❌ No cross-collection queries           │
│                                             │
│  /friendships/{friendshipId}                │
│    ❌ allow read: if false                  │
│    → Force use of Cloud Functions           │
│                                             │
│  /groups/{groupId}                          │
│    ✅ allow read: if isGroupMember()        │
│                                             │
└──────────────────┬──────────────────────────┘
                   │
                   │ Rejected queries
                   │ return permission-denied
                   ▼
          Client Error Handling


┌─────────────────────────────────────────────┐
│         CLOUD FUNCTIONS (Backend)           │
│                                             │
│  Admin SDK - Bypasses Security Rules        │
│  ✅ Can query any collection                │
│  ✅ Validates logic server-side             │
│  ✅ Returns only non-sensitive data         │
└─────────────────────────────────────────────┘
```

---

## 📊 Repository Dependency Matrix

| Repository          | Can Depend On | Cannot Depend On |
|---------------------|---------------|------------------|
| UserRepository      | (none)        | All others       |
| FriendRepository    | User          | Group, Game      |
| GroupRepository     | User, Friend* | Game             |
| GameRepository      | User, Group   | Friend           |

\* GroupRepository uses Friend via Cloud Functions, not direct imports

---

## ✅ Validation: Architecture Test Flow

```
CI Pipeline
    │
    ├─ flutter test test/architecture/dependency_test.dart
    │
    ├─ Check: Games module imports
    │   └─ ❌ Fail if contains 'FriendRepository'
    │
    ├─ Check: Game repositories imports
    │   └─ ❌ Fail if contains 'friend_repository'
    │
    ├─ Check: Game BLoCs imports
    │   └─ ❌ Fail if contains 'features/friends'
    │
    └─ Check: Documentation exists
        └─ ✅ Pass if LAYERED_DEPENDENCIES.md exists

✅ All checks pass → Merge allowed
❌ Any check fails → PR blocked
```

---

## 🎯 Summary: The Golden Rule

```
┌────────────────────────────────────────────────┐
│                                                │
│   Games → Groups → My Community → Users        │
│                                                │
│   One-way dependencies only                    │
│   Lower layers never query higher layers       │
│   Use Cloud Functions for cross-layer access   │
│                                                │
└────────────────────────────────────────────────┘
```

---

## 📚 Related Documentation

- [LAYERED_DEPENDENCIES.md](./LAYERED_DEPENDENCIES.md) - Detailed rules and examples
- [CLAUDE.md](../../CLAUDE.md) - Project engineering standards
- [Firestore Security Rules](../../firestore.rules) - Access control implementation

---

**Last Updated**: December 17, 2025
**Related Story**: Story 11.18 - Enforce Games Depend Only on Groups
**Visual Style**: ASCII diagrams for version control compatibility
