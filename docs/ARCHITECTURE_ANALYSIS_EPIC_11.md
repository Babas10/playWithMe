# PlayWithMe App - Current Architecture Analysis

**Date**: November 2, 2025  
**Branch**: feature/story-2.5-offline-error-handling  
**Purpose**: Validate multi-community (Epic 11) implementation plan against current architecture

---

## 1. FIRESTORE STRUCTURE & DATA PATHS

### Current Collections and Subcollections

```
/groups/{groupId}
  - id: string (document ID)
  - name: string
  - description: string (optional)
  - photoUrl: string (optional)
  - createdBy: string (user ID)
  - createdAt: Timestamp
  - updatedAt: Timestamp
  - memberIds: array<string>
  - adminIds: array<string>
  - gameIds: array<string>
  - privacy: enum (public|private|invite_only)
  - requiresApproval: boolean
  - maxMembers: int (default 20)
  - location: string (optional)
  - allowMembersToCreateGames: boolean (default true)
  - allowMembersToInviteOthers: boolean (default true)
  - notifyMembersOfNewGames: boolean (default true)
  - totalGamesPlayed: int
  - lastActivity: Timestamp

/users/{userId}
  - uid: string (document ID, Firebase Auth UID)
  - email: string
  - displayName: string (optional)
  - photoUrl: string (optional)
  - isEmailVerified: boolean
  - createdAt: Timestamp
  - lastSignInAt: Timestamp
  - updatedAt: Timestamp
  - isAnonymous: boolean
  - firstName: string (optional)
  - lastName: string (optional)
  - phoneNumber: string (optional)
  - dateOfBirth: DateTime (optional)
  - location: string (optional)
  - bio: string (optional)
  - groupIds: array<string>
  - gameIds: array<string>
  - notificationsEnabled: boolean
  - emailNotifications: boolean
  - pushNotifications: boolean
  - privacyLevel: enum (public|friends|private)
  - showEmail: boolean
  - showPhoneNumber: boolean
  - gamesPlayed: int
  - gamesWon: int
  - totalScore: int
  - fcmTokens: array<string> (for push notifications)
  - notificationPreferences: object
    - groupInvitations: boolean
    - invitationAccepted: boolean
    - gameCreated: boolean
    - memberJoined: boolean
    - memberLeft: boolean
    - roleChanged: boolean
    - quietHours: object
      - enabled: boolean
      - start: string (HH:mm format)
      - end: string (HH:mm format)
    - groupSpecific: object<groupId, settings>

/users/{userId}/invitations/{invitationId}
  - id: string (document ID)
  - groupId: string
  - groupName: string
  - invitedBy: string (user ID)
  - inviterName: string
  - invitedUserId: string
  - status: enum (pending|accepted|declined)
  - createdAt: Timestamp
  - respondedAt: Timestamp (optional)

/groups/{groupId}/games/{gameId}
  - id: string (document ID)
  - groupId: string (parent group)
  - name: string
  - description: string (optional)
  - createdBy: string (user ID)
  - createdAt: Timestamp
  - scheduledFor: Timestamp
  - location: string
  - maxPlayers: int
  - currentPlayers: int
  - rsvpList: array<string>
  - ... (other game fields)
```

### Key Observations:

1. **No communityId field** exists anywhere in current models
2. **Flat structure**: Groups are stored at root level, not nested under communities
3. **User-centric design**: Users maintain lists of groupIds, games, and invitations
4. **Subcollection pattern**: Invitations and games use subcollections for data isolation
5. **No tenant isolation**: All queries and access control are based on arrays (memberIds, adminIds)

---

## 2. CLOUD FUNCTIONS (Callable & Trigger)

### Callable Cloud Functions

These are HTTP callable functions that can be invoked from the Flutter client. They all require authentication.

#### 1. **searchUserByEmail(data: SearchUserByEmailRequest) → SearchUserByEmailResponse**
- **Location**: `functions/src/searchUserByEmail.ts`
- **Purpose**: Search for users by email (bypasses Firestore security rules)
- **Request**:
  ```typescript
  {
    email: string
  }
  ```
- **Response**:
  ```typescript
  {
    found: boolean,
    user?: {
      uid: string,
      displayName: string | null,
      email: string,
      photoUrl?: string | null
    },
    error?: string
  }
  ```
- **Security**: ✅ Requires authentication, returns only public data
- **Implementation**: Direct Firestore query using Admin SDK
- **Impact for Epic 11**: Query needs to filter by communityId or search across all communities

#### 2. **checkPendingInvitation(data: CheckPendingInvitationRequest) → CheckPendingInvitationResponse**
- **Location**: `functions/src/checkPendingInvitation.ts`
- **Purpose**: Check if user has pending invitation to a group
- **Request**:
  ```typescript
  {
    targetUserId: string,
    groupId: string
  }
  ```
- **Response**:
  ```typescript
  {
    exists: boolean
  }
  ```
- **Security**: ✅ Requires authentication, returns only boolean
- **Implementation**: Query subcollection `/users/{targetUserId}/invitations`
- **Impact for Epic 11**: Need to add communityId to query filter

#### 3. **acceptInvitation(data: AcceptInvitationRequest) → AcceptInvitationResponse**
- **Location**: `functions/src/acceptInvitation.ts`
- **Purpose**: Accept group invitation and add user to group
- **Request**:
  ```typescript
  {
    invitationId: string
  }
  ```
- **Response**:
  ```typescript
  {
    success: boolean,
    groupId: string,
    message: string
  }
  ```
- **Security**: ✅ Requires authentication, validates ownership
- **Operations**:
  1. Fetch invitation from `/users/{userId}/invitations/{invitationId}`
  2. Verify status is "pending" and user is recipient
  3. Batch update: Update invitation status + Add user to group's memberIds
- **Atomicity**: Uses batch write for consistency
- **Impact for Epic 11**: Need to validate communityId matches group's community

#### 4. **declineInvitation(data: DeclineInvitationRequest) → DeclineInvitationResponse**
- **Location**: `functions/src/declineInvitation.ts`
- **Purpose**: Decline group invitation
- **Request**:
  ```typescript
  {
    invitationId: string
  }
  ```
- **Response**:
  ```typescript
  {
    success: boolean,
    message: string
  }
  ```
- **Security**: ✅ Requires authentication, validates ownership
- **Operations**: Single update to invitation status
- **Impact for Epic 11**: Need to validate communityId

#### 5. **getUsersByIds(data: GetUsersByIdsRequest) → GetUsersByIdsResponse**
- **Location**: `functions/src/getUsersByIds.ts`
- **Purpose**: Fetch multiple users' public data (for group member lists)
- **Request**:
  ```typescript
  {
    userIds: string[]  // Limited to 100 max
  }
  ```
- **Response**:
  ```typescript
  {
    users: Array<{
      uid: string,
      displayName: string | null,
      email: string,
      photoUrl: string | null
    }>
  }
  ```
- **Security**: ✅ Requires authentication, returns public data only, rate-limited to 100 users
- **Implementation**: Batch queries using "in" operator (10 items per batch)
- **Impact for Epic 11**: No community filtering needed (returns public user data only)

#### 6. **leaveGroup(data: LeaveGroupRequest) → LeaveGroupResponse**
- **Location**: `functions/src/leaveGroup.ts`
- **Purpose**: User leaves a group
- **Request**:
  ```typescript
  {
    groupId: string
  }
  ```
- **Response**:
  ```typescript
  {
    success: boolean,
    message: string
  }
  ```
- **Security**: ✅ Requires authentication
- **Validations**:
  - User must be member of group
  - User cannot be the last admin (prevents group abandonment)
- **Operations**: Batch update to remove user from memberIds and adminIds
- **Impact for Epic 11**: Add communityId validation

### Trigger Cloud Functions

These are Firestore trigger functions that fire when specific documents change:

#### 1. **onInvitationCreated(snapshot, context)**
- **Trigger**: `onCreate` on `users/{userId}/invitations/{invitationId}`
- **Purpose**: Send notification when user receives invitation
- **Actions**:
  1. Get user's FCM tokens
  2. Check notification preferences (groupInvitations, quiet hours)
  3. Get group details
  4. Send multicast notification with group image
  5. Clean up invalid FCM tokens
- **Preferences**: Respects groupInvitations setting and quiet hours
- **Impact for Epic 11**: Filter notifications by community preferences

#### 2. **onInvitationAccepted(snapshot, context)**
- **Trigger**: `onUpdate` on `users/{userId}/invitations/{invitationId}` (when status changes to "accepted")
- **Purpose**: Notify inviter that invitation was accepted
- **Actions**:
  1. Get inviter's FCM tokens
  2. Check inviter's preferences
  3. Get accepter's details
  4. Get group details
  5. Send notification
- **Impact for Epic 11**: Scope notifications to community

#### 3. **onGameCreated(snapshot, context)**
- **Trigger**: `onCreate` on `groups/{groupId}/games/{gameId}`
- **Purpose**: Notify group members when new game is created
- **Actions**:
  1. Get group members
  2. For each member (excluding creator):
     - Get member's preferences (gameCreated setting, quiet hours, group-specific)
     - Collect FCM tokens
  3. Send multicast notification
- **Preferences**: Respects gameCreated and group-specific preferences
- **Impact for Epic 11**: No additional changes needed (group-specific)

#### 4. **onMemberJoined(snapshot, context)**
- **Trigger**: `onUpdate` on `groups/{groupId}` (when memberIds array changes)
- **Purpose**: Notify group admins when new member joins
- **Actions**:
  1. Detect new members in memberIds array
  2. For each new member, notify all admins
  3. Check admin preferences (memberJoined setting, quiet hours)
- **Impact for Epic 11**: No additional changes needed (group-specific)

#### 5. **onMemberLeft(snapshot, context)**
- **Trigger**: `onUpdate` on `groups/{groupId}` (when memberIds array changes)
- **Purpose**: Notify group admins when member leaves
- **Impact for Epic 11**: No additional changes needed (group-specific)

#### 6. **onRoleChanged(snapshot, context)**
- **Trigger**: `onUpdate` on `groups/{groupId}` (when adminIds array changes)
- **Purpose**: Notify users when promoted to/demoted from admin
- **Impact for Epic 11**: No additional changes needed (group-specific)

---

## 3. DATA MODELS & DOMAIN STRUCTURES

### GroupModel (Freezed)
```dart
@freezed
class GroupModel with _$GroupModel {
  const factory GroupModel({
    required String id,
    required String name,
    String? description,
    String? photoUrl,
    required String createdBy,
    @TimestampConverter() required DateTime createdAt,
    @TimestampConverter() DateTime? updatedAt,
    @Default([]) List<String> memberIds,
    @Default([]) List<String> adminIds,
    @Default([]) List<String> gameIds,
    @Default(GroupPrivacy.private) GroupPrivacy privacy,
    @Default(false) bool requiresApproval,
    @Default(20) int maxMembers,
    String? location,
    @Default(true) bool allowMembersToCreateGames,
    @Default(true) bool allowMembersToInviteOthers,
    @Default(true) bool notifyMembersOfNewGames,
    @Default(0) int totalGamesPlayed,
    @TimestampConverter() DateTime? lastActivity,
  }) = _GroupModel;
}

enum GroupPrivacy { public, private, inviteOnly }
```
- **No communityId field exists**
- **Business logic methods**: isMember(), isAdmin(), canManage(), isAtCapacity, etc.
- **Update methods**: updateInfo(), updateSettings(), addMember(), removeMember(), etc.

### InvitationModel (Freezed)
```dart
@freezed
class InvitationModel with _$InvitationModel {
  const factory InvitationModel({
    required String id,
    required String groupId,
    required String groupName,
    required String invitedBy,
    required String inviterName,
    required String invitedUserId,
    @Default(InvitationStatus.pending) InvitationStatus status,
    @TimestampConverter() required DateTime createdAt,
    @TimestampConverter() DateTime? respondedAt,
  }) = _InvitationModel;
}

enum InvitationStatus { pending, accepted, declined }
```
- **No communityId field exists**
- **Stored in subcollection**: `/users/{userId}/invitations/{invitationId}`
- **Minimal data**: Only essential fields for display and status tracking

### UserModel (Freezed)
```dart
@freezed
class UserModel with _$UserModel {
  const factory UserModel({
    required String uid,
    required String email,
    String? displayName,
    String? photoUrl,
    required bool isEmailVerified,
    @TimestampConverter() DateTime? createdAt,
    @TimestampConverter() DateTime? lastSignInAt,
    @TimestampConverter() DateTime? updatedAt,
    required bool isAnonymous,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    DateTime? dateOfBirth,
    String? location,
    String? bio,
    @Default([]) List<String> groupIds,
    @Default([]) List<String> gameIds,
    @Default(true) bool notificationsEnabled,
    @Default(true) bool emailNotifications,
    @Default(true) bool pushNotifications,
    @Default(UserPrivacyLevel.public) UserPrivacyLevel privacyLevel,
    @Default(true) bool showEmail,
    @Default(true) bool showPhoneNumber,
    @Default(0) int gamesPlayed,
    @Default(0) int gamesWon,
    @Default(0) int totalScore,
  }) = _UserModel;
}

enum UserPrivacyLevel { public, friends, private }
```
- **No communityId field exists**
- **User-centric data**: Lists of groupIds and gameIds
- **No community membership tracking**

### GameModel (Freezed)
```dart
// Fields not shown, but structure similar to GroupModel
// - groupId: string (parent group reference)
// - createdBy: string
// - rsvpList: array<string>
// - location: string
// - scheduledFor: Timestamp
```
- **No communityId field exists**
- **Group-scoped**: Games are children of groups

---

## 4. REPOSITORIES & DATA ACCESS PATTERNS

### Domain Layer (Interfaces)

#### GroupRepository
```dart
abstract class GroupRepository {
  Future<GroupModel?> getGroupById(String groupId);
  Future<List<GroupModel>> getGroupsByIds(List<String> groupIds);
  Stream<List<GroupModel>> getGroupsForUser(String userId);  // Query: memberIds contains userId
  Future<String> createGroup(GroupModel group);
  Future<void> updateGroupInfo(String groupId, {...});
  Future<void> updateGroupSettings(String groupId, {...});
  Future<void> addMember(String groupId, String userId);
  Future<void> removeMember(String groupId, String userId);
  Future<void> leaveGroup(String groupId);  // Calls Cloud Function
  Future<void> promoteToAdmin(String groupId, String userId);
  Future<void> demoteFromAdmin(String groupId, String userId);
  Future<void> addGame(String groupId, String gameId);
  Future<void> removeGame(String groupId, String gameId);
  Future<void> updateActivity(String groupId);
  Future<List<GroupModel>> searchPublicGroups(String query, {int limit = 20});
  Future<List<String>> getGroupMembers(String groupId);
  Future<List<String>> getGroupAdmins(String groupId);
  Future<bool> canUserJoinGroup(String groupId, String userId);
  Future<void> deleteGroup(String groupId);
  Future<bool> groupExists(String groupId);
  Future<Map<String, dynamic>> getGroupStats(String groupId);
}
```

#### InvitationRepository
```dart
abstract class InvitationRepository {
  Future<String> sendInvitation({
    required String groupId,
    required String groupName,
    required String invitedUserId,
    required String invitedBy,
    required String inviterName,
  });
  Stream<List<InvitationModel>> getPendingInvitations(String userId);
  Future<List<InvitationModel>> getInvitations(String userId);
  Future<InvitationModel?> getInvitationById({
    required String userId,
    required String invitationId,
  });
  Future<void> acceptInvitation({
    required String userId,
    required String invitationId,
  });  // Uses Cloud Function
  Future<void> declineInvitation({
    required String userId,
    required String invitationId,
  });  // Uses Cloud Function
  Future<void> deleteInvitation({
    required String userId,
    required String invitationId,
  });
  Future<bool> hasPendingInvitation({
    required String userId,
    required String groupId,
  });
  Future<List<InvitationModel>> getInvitationsSentByUser(String userId);
  Future<void> cancelInvitation({
    required String userId,
    required String invitationId,
  });
}
```

### Implementation Layer (Firestore)

#### FirestoreGroupRepository
- **Constructor**: Takes FirebaseFirestore instance (for testing)
- **Retry logic**: Exponential backoff for retryable errors
- **Key queries**:
  - `getGroupsForUser()`: `where('memberIds', arrayContains: userId).orderBy('lastActivity', descending: true)`
  - `searchPublicGroups()`: `where('privacy', isEqualTo: 'public').where('name', isGreaterThanOrEqualTo: ...)`
- **Write operations**: Use `set(..., SetOptions(merge: true))` for updates
- **Batch operations**: Manual batch handling for atomic updates

#### FirestoreInvitationRepository
- **Constructor**: Takes FirebaseFirestore and FirebaseFunctions instances
- **Subcollection path**: `/users/{userId}/invitations/{invitationId}`
- **Key queries**:
  - `getPendingInvitations()`: `where('status', isEqualTo: 'pending').orderBy('createdAt', descending: true)`
- **Cloud Function calls**: Uses `FirebaseFunctions.instance.httpsCallable()` for accept/decline
- **Security note**: Duplicate checks now delegated to Cloud Function via `checkPendingInvitation`

---

## 5. FIRESTORE SECURITY RULES

### Current Rules (`firestore.rules`)

```javascript
// ✅ User Documents - Owner-only access
match /users/{userId} {
  allow read: if isAuthenticated() && request.auth.uid == userId;
  allow create: if isAuthenticated() && request.auth.uid == userId;
  allow update: if isAuthenticated() && 
                   request.auth.uid == userId &&
                   !request.resource.data.diff(resource.data).affectedKeys().hasAny(['uid', 'email', 'createdAt']);

  // ✅ User Invitations Subcollection - Invited user can read/write status
  match /invitations/{invitationId} {
    allow create: if isAuthenticated() && isGroupAdmin(request.resource.data.groupId);
    allow get: if isAuthenticated() && request.auth.uid == userId;
    allow list: if isAuthenticated() && request.auth.uid == userId;
    allow update: if isAuthenticated() && 
                     request.auth.uid == userId &&
                     request.resource.data.status in ['accepted', 'declined'] &&
                     request.resource.data.groupId == resource.data.groupId &&
                     request.resource.data.invitedBy == resource.data.invitedBy;
    allow delete: if isAuthenticated() &&
                     (request.auth.uid == userId ||
                      request.auth.uid == resource.data.invitedBy);
  }
}

// ✅ Groups - Members can read, admins can write
match /groups/{groupId} {
  allow get: if isAuthenticated() &&
                (request.auth.uid in resource.data.memberIds ||
                 request.auth.uid == resource.data.createdBy);
  allow list: if isAuthenticated();
  allow create: if isAuthenticated() &&
                   request.auth.uid == request.resource.data.createdBy &&
                   request.auth.uid in request.resource.data.memberIds &&
                   request.auth.uid in request.resource.data.adminIds;
  allow update: if isAuthenticated() &&
                   request.auth.uid in resource.data.adminIds &&
                   request.resource.data.adminIds.size() > 0;
  allow delete: if isAuthenticated() &&
                   request.auth.uid in resource.data.adminIds;
}

// ⚠️ Games - Issue with reference to 'members' field (doesn't exist - should be 'memberIds')
match /games/{gameId} {
  allow read: if request.auth != null &&
                 request.auth.uid in get(...).data.members;  // ❌ BROKEN - should be memberIds
  allow create/update/delete: ...
}
```

### Key Security Patterns:
1. **User-only access**: Users can only read/write their own `/users/{userId}` document
2. **Array-based membership**: Uses `memberIds` and `adminIds` arrays for access control
3. **Helper functions**: `isAuthenticated()`, `isGroupMember()`, `isGroupAdmin()` encapsulate common checks
4. **Cross-document reads**: Uses `get()` to check group membership for game access
5. **Atomic constraints**: Ensures adminIds array is never empty

### Issues Identified:
1. **Game access rule is broken**: References `.data.members` which doesn't exist (should be `memberIds`)
2. **No community isolation**: Rules don't enforce community boundaries
3. **Global list() permission**: Anyone authenticated can list all groups (filtered by memberIds in app)

---

## 6. BLoC LAYER (State Management)

### GroupBloc
```dart
class GroupBloc extends Bloc<GroupEvent, GroupState> {
  final GroupRepository _groupRepository;
  StreamSubscription<dynamic>? _groupsSubscription;

  // Events handled:
  on<LoadGroupById>() -> GroupLoaded | GroupNotFound | GroupError
  on<LoadGroupsForUser>() -> GroupsLoaded | GroupError (stream-based)
  on<CreateGroup>() -> GroupCreated | GroupError
  on<UpdateGroupInfo>() -> GroupInfoUpdated | GroupError
  on<UpdateGroupSettings>() -> GroupSettingsUpdated | GroupError
  on<AddMemberToGroup>() -> MemberAdded | GroupError
  on<RemoveMemberFromGroup>() -> MemberRemoved | GroupError
  on<PromoteToAdmin>() -> PromotedToAdmin | GroupError
  on<DemoteFromAdmin>() -> DemotedFromAdmin | GroupError
  on<SearchPublicGroups>() -> PublicGroupsSearched | GroupError
  on<LoadGroupStats>() -> GroupStatsLoaded | GroupError
  on<DeleteGroup>() -> GroupDeleted | GroupError
}
```
- **States**: GroupInitial, GroupLoading, GroupLoaded, GroupsLoaded, GroupNotFound, GroupError
- **Error handling**: Uses ErrorMessages utility for user-friendly messages
- **Stream management**: Manages stream subscriptions with proper cleanup
- **No community awareness**: Events and state don't include community context

### InvitationBloc
```dart
class InvitationBloc extends Bloc<InvitationEvent, InvitationState> {
  final InvitationRepository _invitationRepository;

  // Events handled:
  on<SendInvitation>() -> InvitationSent | InvitationError
  on<LoadPendingInvitations>() -> InvitationsLoaded | InvitationError (stream-based)
  on<LoadInvitations>() -> InvitationsLoaded | InvitationError
  on<AcceptInvitation>() -> InvitationAccepted | InvitationError
  on<DeclineInvitation>() -> InvitationDeclined | InvitationError
  on<DeleteInvitation>() -> InvitationDeleted | InvitationError
}
```
- **Stream-based loading**: Uses `emit.forEach` for real-time updates
- **Cloud Function integration**: Accept/Decline use Cloud Functions
- **Error handling**: Comprehensive error messages with error codes

### Other BLoCs:
- **UserBloc**: User authentication and profile management
- **GameBloc**: Game creation and management
- **GroupMemberBloc**: Group member management

---

## 7. CURRENT ARCHITECTURE SUMMARY

### Strengths:
1. ✅ **Clear separation of concerns**: Domain (interfaces) → Data (implementation) → Presentation (BLoCs)
2. ✅ **Secure Cloud Functions**: Uses Admin SDK to enforce permissions
3. ✅ **Array-based membership**: Efficient for checking group access
4. ✅ **Comprehensive error handling**: Typed error codes and messages
5. ✅ **Stream-based real-time updates**: Firebase Firestore snapshots for live data
6. ✅ **Immutable models**: Freezed for type-safe data classes
7. ✅ **Subcollection pattern**: Invitations organized per-user for scalability
8. ✅ **Notification preferences**: Granular controls with quiet hours support
9. ✅ **Batch operations**: Atomic updates for data consistency

### Gaps & Limitations (for Epic 11):
1. ❌ **No multi-community support**: Single-community architecture
2. ❌ **No communityId field**: Would need to be added to all models
3. ❌ **Global group listing**: Rules allow authenticated users to list all groups
4. ❌ **No community-scoped queries**: All queries are either user-scoped or group-scoped
5. ❌ **Game access rule broken**: References non-existent `.data.members` field
6. ❌ **No community isolation in Firestore rules**: Security rules don't enforce community boundaries
7. ❌ **User model lacks community membership**: No way to track which communities user belongs to
8. ❌ **Invitation model needs community scope**: Can't distinguish invitations across communities
9. ❌ **Cloud Functions don't validate community context**: No community parameter in callable functions
10. ❌ **Notification triggers not community-aware**: Notifications sent globally without community filtering

---

## 8. PROPOSED CHANGES FOR EPIC 11 (Multi-Community)

### Data Models - Required Additions

#### GroupModel
```dart
// Add field:
String communityId,  // Required - which community owns this group
```

#### InvitationModel
```dart
// Add field:
String communityId,  // Required - must match group's community
```

#### UserModel
```dart
// Add field:
@Default([]) List<String> communityIds,  // Communities user is a member of
```

#### New: CommunityModel
```dart
@freezed
class CommunityModel with _$CommunityModel {
  const factory CommunityModel({
    required String id,
    required String name,
    String? description,
    String? photoUrl,
    required String createdBy,
    @TimestampConverter() required DateTime createdAt,
    @TimestampConverter() DateTime? updatedAt,
    @Default([]) List<String> memberIds,
    @Default([]) List<String> adminIds,
    @Default([]) List<String> groupIds,
    @Default([]) List<String> gameIds,
    @Default(CommunityPrivacy.private) CommunityPrivacy privacy,
    @Default(20) int maxMembers,
    @Default(0) int totalGroups,
    @Default(0) int totalGames,
    @TimestampConverter() DateTime? lastActivity,
  }) = _CommunityModel;
}
```

### Firestore Structure Changes

```
/communities/{communityId}
  - id, name, description, photoUrl
  - createdBy, createdAt, updatedAt
  - memberIds[], adminIds[]
  - groupIds[], gameIds[]
  - privacy, maxMembers
  - totalGroups, totalGames, lastActivity

/groups/{groupId}
  - + communityId: string (NEW)
  - (all existing fields)

/users/{userId}
  - + communityIds: array<string> (NEW)
  - (all existing fields)

/users/{userId}/invitations/{invitationId}
  - + communityId: string (NEW)
  - (all existing fields)
```

### Cloud Functions Changes

All callable functions need to add communityId validation:

1. **searchUserByEmail**: No change needed (searches across all communities)
2. **checkPendingInvitation**: Add communityId parameter, validate match
3. **acceptInvitation**: Validate communityId in group and invitation
4. **declineInvitation**: Validate communityId in group and invitation
5. **getUsersByIds**: No change needed (returns public user data)
6. **leaveGroup**: Validate communityId in group

All trigger functions need community context awareness

### Repository Changes

#### GroupRepository
```dart
// Update queries to filter by community:
Future<List<GroupModel>> getGroupsForCommunity(String communityId);
Future<List<GroupModel>> getGroupsForUserInCommunity(String userId, String communityId);
// New community-scoped search
Future<List<GroupModel>> searchGroupsInCommunity(String communityId, String query);
```

#### New: CommunityRepository
```dart
abstract class CommunityRepository {
  Future<CommunityModel?> getCommunityById(String communityId);
  Stream<List<CommunityModel>> getCommunitiesForUser(String userId);
  Future<String> createCommunity(CommunityModel community);
  Future<void> updateCommunity(String communityId, {...});
  Future<void> joinCommunity(String communityId, String userId);
  Future<void> leaveCommunity(String communityId, String userId);
  // ... other operations
}
```

### Firestore Rules Changes

```javascript
// New community rules
match /communities/{communityId} {
  allow get: if isAuthenticated() && 
                request.auth.uid in resource.data.memberIds;
  allow list: if isAuthenticated();
  allow create: if isAuthenticated() &&
                   request.auth.uid == request.resource.data.createdBy;
  allow update: if isAuthenticated() &&
                   request.auth.uid in resource.data.adminIds;
  allow delete: if isAuthenticated() &&
                   request.auth.uid in resource.data.adminIds;
}

// Updated group rules - add community validation
match /groups/{groupId} {
  allow get: if isAuthenticated() &&
                request.auth.uid in resource.data.memberIds &&
                // Verify user is member of the community
                request.auth.uid in get(/databases/$(database)/documents/communities/$(resource.data.communityId)).data.memberIds;
  // ... other rules with community context
}
```

### BLoC Changes

New BLoCs needed:
- **CommunityBloc**: Community management (create, join, leave, etc.)
- **CommunitySelectionBloc**: Handle switching between communities
- **MultiCommunityGroupBloc**: Extended GroupBloc with community context

Existing BLoCs need updates:
- **GroupBloc**: Add communityId to events
- **InvitationBloc**: Add communityId context
- **UserBloc**: Track current community

---

## 9. VALIDATION & CONFLICT ANALYSIS

### Conflicts Identified:

1. **Game access rule is broken**
   - Current: `request.auth.uid in get(...).data.members`
   - Should be: `request.auth.uid in get(...).data.memberIds`
   - **Action**: Fix in parallel task

2. **Invitation model needs community context**
   - Current: Groups identified only by groupId
   - Risk: Same group ID could exist in multiple communities if not properly isolated
   - **Action**: Add communityId field to InvitationModel

3. **User model needs community awareness**
   - Current: Users only track groupIds and gameIds
   - Gap: Can't efficiently query which communities a user belongs to
   - **Action**: Add communityIds array to UserModel

4. **Cloud Functions lack community validation**
   - Current: Functions validate groupId and userId but not communityId
   - Risk: Cross-community access if users manipulate parameters
   - **Action**: All callable functions must validate communityId

5. **Notification triggers are global**
   - Current: Triggers fire for all groups/communities
   - Gap: No way to filter notifications by community context
   - **Action**: Notification preferences need community-scoping

### High-Risk Areas for Epic 11:

1. **Data Model Migrations**: Adding communityId to existing documents requires migration script
2. **Firestore Indices**: May need new composite indexes for community + other fields
3. **Query Performance**: Community filtering might require new indices
4. **Backward Compatibility**: Existing groups have no communityId
5. **Security Rules**: Complex rules with community validation could impact performance

---

## 10. RECOMMENDATIONS

### For Epic 11 Implementation:

1. **Phase 1: Infrastructure**
   - Create CommunityModel and CommunityRepository
   - Add communityId fields to GroupModel, InvitationModel, UserModel
   - Create migration strategy for existing data

2. **Phase 2: Security**
   - Update Firestore rules for community isolation
   - Update Cloud Functions to validate communityId
   - Add community authorization checks

3. **Phase 3: BLoCs & UI**
   - Create CommunityBloc
   - Update GroupBloc to include communityId in events
   - Create community selection UI

4. **Phase 4: Testing**
   - Security rule tests for community isolation
   - Integration tests for cross-community access (should fail)
   - Cloud Function tests with communityId validation

5. **Quick Wins**:
   - Fix game access rule immediately
   - Add new Firestore indices before heavy data changes
   - Create data migration utilities early

### Estimated Impact:

- **Dart models**: 4 files modified + 1 new (CommunityModel)
- **Repositories**: 1 new repository, 4 existing updated
- **Cloud Functions**: 6 callable functions + 6 trigger functions updated
- **Firestore rules**: Complete rewrite with community context
- **BLoCs**: 1 new BLoC, 3+ existing updated
- **Firestore indices**: Add ~5-10 new composite indices

---

## CONCLUSION

The current architecture is well-structured and secure for single-community use. Epic 11's multi-community feature is **feasible but requires systematic changes** across all layers:

1. **Data layer**: Add communityId to models and firestore structure
2. **Security layer**: Implement community-scoped firestore rules
3. **Function layer**: Add community validation to all callable/trigger functions
4. **Repository layer**: Create new CommunityRepository and update existing repos
5. **BLoC layer**: Add CommunityBloc and update existing BLoCs
6. **UI layer**: Add community selection and scoping

**Key Success Factor**: Community isolation must be enforced at the Firestore rule level, not just in application code.

---
