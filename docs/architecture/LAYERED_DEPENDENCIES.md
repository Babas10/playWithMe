# Layered Dependency Model

**PlayWithMe** follows a strict **layered architecture** with one-way dependencies to maintain clear separation of concerns, prevent circular dependencies, and enable independent scaling of each layer.

## 🏗️ Architecture Overview

```
Users → My Community (Social Graph) → Groups → Games
```

Each layer can only depend on the layers below it. Higher layers never query lower layers directly through Firestore - they use well-defined Cloud Function interfaces.

---

## 📐 Layer Definitions

### 1. Users Layer (Foundation)
- **Purpose**: User authentication and profile management
- **Responsibilities**:
  - Firebase Authentication integration
  - User profile CRUD operations
  - User preferences and settings
- **Dependencies**: None (foundation layer)
- **Exposed via**: Direct Firestore access (user's own profile only)

### 2. My Community Layer (Social Graph)
- **Purpose**: Manage social relationships between users
- **Responsibilities**:
  - Friend requests and acceptances
  - Friendship validation
  - Social network queries
- **Dependencies**: Users
- **Exposed via**: Cloud Functions (callable)
  - `sendFriendRequest()`
  - `acceptFriendRequest()`
  - `declineFriendRequest()`
  - `getFriends()`
  - `verifyFriendship()`
  - `checkFriendshipStatus()`
- **Key Rule**: ❌ Never queries Groups or Games

### 3. Groups Layer
- **Purpose**: Organize users into activity-based groups
- **Responsibilities**:
  - Group creation and management
  - Membership management
  - Group invitations (validated against social graph)
  - Member roles and permissions
- **Dependencies**: Users + My Community (via Cloud Functions)
- **Access Pattern**:
  - ✅ Calls `verifyFriendship()` before allowing invitations
  - ✅ Queries group membership directly from Firestore
  - ❌ Never queries friendships collection directly
- **Key Rule**: ❌ Never queries Games

### 4. Games Layer
- **Purpose**: Schedule and manage volleyball games within groups
- **Responsibilities**:
  - Game scheduling
  - Player RSVPs and waitlists
  - Game results and scoring
  - ELO rating updates
- **Dependencies**: Groups only
- **Access Pattern**:
  - ✅ Accesses players via `group.memberIds`
  - ✅ Validates player participation using group membership
  - ❌ Never queries friendships
  - ❌ Never calls friendship Cloud Functions
- **Key Rule**: Games are always scoped to a single group

---

## ✅ Dependency Rules

### Rule 1: One-Way Dependencies Only

```
❌ FORBIDDEN: Circular dependencies
✅ ALLOWED: Higher layers depend on lower layers
```

**Examples:**
- ✅ Groups can call `verifyFriendship()` from My Community
- ✅ Games can query group membership
- ❌ My Community cannot query Groups
- ❌ Groups cannot query Games
- ❌ Games cannot query My Community

### Rule 2: Use Cloud Function Interfaces

When one layer needs data from another:

```typescript
// ✅ CORRECT: Group uses Cloud Function to verify friendship
const result = await FirebaseFunctions.instance
  .httpsCallable('verifyFriendship')
  .call({'userId': invitedUserId});

// ❌ WRONG: Direct Firestore query
final snapshot = await FirebaseFirestore.instance
  .collection('friendships')
  .where('users', arrayContains: currentUserId)
  .get();
```

**Why?**
- Centralizes security logic
- Prevents permission-denied errors
- Enables rate limiting and audit trails
- Allows independent evolution of lower layers

### Rule 3: Games Access Players Only via Groups

```dart
// ✅ CORRECT: Get players from group membership
final group = await groupRepository.getGroup(gameData.groupId);
final playerIds = group.memberIds;
final players = await userRepository.getUsersByIds(playerIds);

// ❌ WRONG: Query friendships to find players
final friends = await friendRepository.getFriends(currentUserId);
```

**Why?**
- Games are scoped to groups, not friendships
- Membership is already validated when user joins group
- Allows non-friends to play together in public groups (future feature)

---

## 🔒 Enforcement Mechanisms

### 1. Architecture Tests

```dart
// test/architecture/dependency_test.dart
test('Games module should not import FriendRepository', () {
  // Scans lib/features/games/ for forbidden imports
  // Fails CI if violations found
});
```

### 2. Code Review Checklist

Before approving any PR:
- [ ] No friendship imports in `lib/features/games/`
- [ ] No direct Firestore queries across layers
- [ ] Cloud Functions used for cross-layer data access
- [ ] Security rules prevent unauthorized cross-layer queries

### 3. Firestore Security Rules

```javascript
// games collection - accessible only via group membership
match /games/{gameId} {
  allow read: if isGroupMember(resource.data.groupId);
  allow write: if isGroupAdmin(resource.data.groupId);
}

// friendships collection - no direct access from client
match /friendships/{friendshipId} {
  allow read, write: if false; // Force use of Cloud Functions
}
```

---

## 📊 Data Flow Examples

### Example 1: Creating a Game

```
1. User selects a group (Groups layer)
2. GameRepository.createGame(groupId, ...) (Games layer)
3. Game validates groupId exists
4. Game retrieves players via group.memberIds
5. Game sends notifications to group members
```

**No interaction with My Community layer.**

### Example 2: Inviting to a Group

```
1. User enters friend's email (Groups layer)
2. GroupRepository calls verifyFriendship() (My Community layer)
3. Cloud Function validates friendship exists
4. If valid, create invitation document
5. Send notification to invited user
```

**Group layer uses Cloud Function, never queries friendships directly.**

### Example 3: Checking Game Eligibility

```
1. User opens game details (Games layer)
2. Game checks if user is in group.memberIds
3. If yes, allow RSVP
4. If no, show "Join group to RSVP"
```

**No friendship check needed - group membership is sufficient.**

---

## 🚫 Common Anti-Patterns

### ❌ Anti-Pattern 1: Games Querying Friendships

```dart
// DON'T DO THIS
class GameBloc {
  final FriendRepository friendRepository; // ❌ Wrong layer

  Future<void> inviteFriends() async {
    final friends = await friendRepository.getFriends(userId);
    // Send invites...
  }
}
```

**Fix**: Invite via group, not friendships.

```dart
// DO THIS
class GameBloc {
  final GroupRepository groupRepository; // ✅ Correct layer

  Future<void> notifyGroupMembers() async {
    final group = await groupRepository.getGroup(gameData.groupId);
    // Notify group.memberIds...
  }
}
```

### ❌ Anti-Pattern 2: Direct Firestore Cross-Layer Queries

```dart
// DON'T DO THIS
final friends = await FirebaseFirestore.instance
  .collection('friendships')
  .where('userId', isEqualTo: currentUserId)
  .get();
```

**Fix**: Use Cloud Function.

```dart
// DO THIS
final result = await FirebaseFunctions.instance
  .httpsCallable('getFriends')
  .call();
```

### ❌ Anti-Pattern 3: Circular Dependencies

```dart
// DON'T DO THIS
class FriendRepository {
  final GroupRepository groupRepository; // ❌ Upward dependency

  Future<void> suggestGroups() async {
    // My Community should not query Groups
  }
}
```

**Fix**: Move suggestion logic to Groups layer or separate service.

---

## 🎯 Benefits of Layered Architecture

1. **Clear Ownership**: Each layer has well-defined responsibilities
2. **Independent Scaling**: Can optimize each layer separately
3. **Security**: Centralized permission checks in Cloud Functions
4. **Testability**: Easy to mock lower layers with well-defined interfaces
5. **Evolution**: Can change My Community implementation without affecting Games
6. **Debugging**: Data flow is predictable and traceable

---

## 📚 Related Documentation

- [DEPENDENCY_DIAGRAM.md](./DEPENDENCY_DIAGRAM.md) - Visual architecture diagrams
- [CLAUDE.md](../../CLAUDE.md) - Full project engineering standards
- [Firebase Data Access Rules](../../CLAUDE.md#firebase-data-access-rules-critical) - Security guidelines

---

## ✅ Validation Checklist

When implementing new features:

- [ ] Feature only depends on layers below
- [ ] Uses Cloud Functions for cross-layer queries
- [ ] No direct Firestore queries to higher/unrelated layers
- [ ] Architecture tests pass
- [ ] Security rules prevent unauthorized access
- [ ] Documentation updated if new layer added

---

**Last Updated**: December 17, 2025
**Related Epic**: Epic 11 - My Community Social Graph
**Related Story**: Story 11.18 - Enforce Games Depend Only on Groups
