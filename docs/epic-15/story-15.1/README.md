# Story 15.1: Create Training Session (Group-Scoped)

**Epic**: 15 - Training Sessions (Games-Layer Event Type)
**Status**: ✅ Completed
**Implemented**: January 2026

---

## Overview

Implemented the ability for group members to create training sessions within their groups. Training sessions are practice events that do not affect ELO ratings and are strictly scoped to group membership.

---

## Architecture

### Layer Positioning

Training sessions operate in the **Games Layer** and follow strict architectural boundaries:

```
Training Sessions → Groups → My Community
❌ Training Sessions → My Community (FORBIDDEN)
```

**Key Principles:**
- ✅ Training sessions validate membership via `GroupRepository` only
- ✅ Participants are ALWAYS resolved via `group.memberIds`
- ❌ NO imports of `FriendRepository` or My Community layer code
- ❌ NO direct queries to `friendships` collection

### Enforcement

Architecture compliance is enforced through:
1. **Architecture Tests** (`test/architecture/dependency_test.dart`)
   - Validates no friendship imports in training module
   - Validates no friendship imports in training repositories
   - Validates no friendship imports in training BLoCs

2. **Code Review**
   - Manual verification of import statements
   - Validation of dependency flow

---

## Implementation

### 1. Domain Model

**File**: `lib/core/data/models/training_session_model.dart`

```dart
@freezed
class TrainingSessionModel with _$TrainingSessionModel {
  const factory TrainingSessionModel({
    required String id,
    required String groupId,
    required String title,
    String? description,
    required GameLocation location,
    required DateTime startTime,
    required DateTime endTime,
    required int minParticipants,
    required int maxParticipants,
    required String createdBy,
    required DateTime createdAt,
    DateTime? updatedAt,
    String? recurrenceRule, // Future: Story 15.2
    @Default(TrainingStatus.scheduled) TrainingStatus status,
    @Default([]) List<String> participantIds,
    String? notes,
  }) = _TrainingSessionModel;
}
```

**Business Logic Methods:**
- `canUserJoin(userId)` - Check if user can join
- `canUserLeave(userId)` - Check if user can leave
- `isFull` - Check if session is at capacity
- `hasMinimumParticipants` - Check minimum participant requirement
- `addParticipant(userId)` - Add participant (returns new instance)
- `removeParticipant(userId)` - Remove participant (returns new instance)

---

### 2. Repository Layer

**Interface**: `lib/core/domain/repositories/training_session_repository.dart`
**Implementation**: `lib/core/data/repositories/firestore_training_session_repository.dart`

**Key Methods:**
- `createTrainingSession(session)` - Calls Cloud Function for server-side validation
- `getTrainingSessionById(sessionId)` - Fetch single session
- `getUpcomingTrainingSessionsForGroup(groupId)` - Stream upcoming sessions
- `addParticipant(sessionId, userId)` - Add participant with validation
- `removeParticipant(sessionId, userId)` - Remove participant

**Security Approach:**
- Creation uses **Cloud Function** (`createTrainingSession`) for server-side validation
- All other operations go through Firestore with security rules
- Group membership validation happens server-side

---

### 3. Cloud Function

**File**: `functions/src/createTrainingSession.ts`

**Purpose**: Server-side validation and creation of training sessions

**Validation Steps:**
1. **Authentication** - Verify user is logged in
2. **Input Validation**:
   - Required fields present
   - Title length (3-100 characters)
   - Location provided
   - Valid date/time format (ISO 8601)
   - Start time in future
   - End time after start time
   - Minimum 30-minute duration
   - Participant limits (2-30)
3. **Group Membership Validation**:
   - Group exists
   - User is a member of the group (via Admin SDK)
4. **Document Creation**:
   - Uses Admin SDK to bypass Firestore rules
   - Returns session ID

**Error Codes:**
- `unauthenticated` - User not logged in
- `permission-denied` - User not a member of group
- `not-found` - Group doesn't exist
- `invalid-argument` - Invalid input data
- `internal` - Server error

**Deployment:**
- ✅ Deployed to `playwithme-dev`
- ✅ Deployed to `playwithme-stg`
- ✅ Deployed to `playwithme-prod`

---

### 4. BLoC Layer

**Files**:
- `lib/features/training/presentation/bloc/training_session_creation/training_session_creation_bloc.dart`
- `training_session_creation_event.dart`
- `training_session_creation_state.dart`

**Events:**
- `SelectTrainingGroup` - Select group for session
- `SetStartTime` / `SetEndTime` - Set session times
- `SetTrainingLocation` - Set location
- `SetTrainingTitle` / `SetTrainingDescription` - Set session details
- `SetMaxParticipants` / `SetMinParticipants` - Set capacity
- `SetSessionNotes` - Add session notes
- `ValidateTrainingForm` - Trigger validation
- `SubmitTrainingSession` - Create session
- `ResetTrainingForm` - Reset form state

**States:**
- `TrainingSessionCreationInitial` - Initial state
- `TrainingSessionCreationFormState` - Form being filled (with validation errors)
- `TrainingSessionCreationSubmitting` - Submitting to Cloud Function
- `TrainingSessionCreationSuccess` - Session created successfully
- `TrainingSessionCreationError` - Creation failed

**Validation Rules:**
- Group must be selected
- Start time must be in future
- End time must be after start time
- Minimum 30-minute duration
- Location required
- Title: 3-100 characters
- Min participants: ≥ 2
- Max participants: ≤ 30, ≥ min participants

---

### 5. Firestore Security Rules

**File**: `firestore.rules`

```javascript
match /trainingSessions/{sessionId} {
  // Read: Group members only
  allow get, list: if isAuthenticated() &&
    request.auth.uid in get(/databases/$(database)/documents/groups/$(resource.data.groupId)).data.memberIds;

  // CRITICAL: Creation via Cloud Function ONLY
  allow create: if false;

  // Update: Creator or group members
  allow update: if isAuthenticated() &&
    (request.auth.uid == resource.data.createdBy ||
     request.auth.uid in get(/databases/$(database)/documents/groups/$(resource.data.groupId)).data.memberIds);

  // Delete: Creator only
  allow delete: if isAuthenticated() &&
    request.auth.uid == resource.data.createdBy;
}
```

**Security Approach:**
- ✅ Creation restricted to Cloud Function only (`allow create: if false`)
- ✅ Reads require group membership validation
- ✅ Updates allowed for creator and group members
- ✅ Deletes restricted to creator only

**Deployment:**
- ✅ Deployed to `playwithme-dev`
- ✅ Deployed to `playwithme-stg`
- ✅ Deployed to `playwithme-prod`

---

## Testing

### Unit Tests

**File**: `test/unit/features/training/presentation/bloc/training_session_creation/training_session_creation_bloc_test.dart`

**Coverage**: 27 comprehensive tests

**Test Categories:**
1. **Initial State** (1 test)
2. **Form Field Updates** (8 tests)
   - Group selection
   - Start/end time
   - Location
   - Title/description
   - Participants
   - Notes
3. **Validation** (12 tests)
   - Future date validation
   - Time ordering validation
   - Minimum duration (30 min)
   - Title length validation
   - Participant limits
4. **Submission** (5 tests)
   - Invalid form rejection
   - Successful creation
   - Error handling (not a member, group not found, generic errors)
5. **Form Reset** (1 test)

**Result**: ✅ All 27 tests passing

### Architecture Tests

**File**: `test/architecture/dependency_test.dart`

**Tests Added:**
1. Training module should not import FriendRepository
2. Training repositories should not import FriendRepository
3. Training BLoCs should not import FriendRepository

**Result**: ✅ All architecture tests passing

### Integration Tests

**Status**: ⏸️ Deferred to future story

Integration tests with Firebase Emulator will be added when UI implementation begins (Story 15.1.1 or similar).

---

## Data Model

### Firestore Collection

**Collection**: `trainingSessions`

**Document Structure:**
```json
{
  "id": "auto-generated",
  "groupId": "group-123",
  "title": "Advanced Serving Practice",
  "description": "Focus on jump serves and float serves",
  "location": {
    "name": "Beach Court 1",
    "address": "123 Beach Street, Venice Beach"
  },
  "startTime": Timestamp,
  "endTime": Timestamp,
  "minParticipants": 4,
  "maxParticipants": 12,
  "createdBy": "user-456",
  "createdAt": Timestamp,
  "updatedAt": Timestamp | null,
  "recurrenceRule": null,
  "status": "scheduled",
  "participantIds": ["user-789", "user-101"],
  "notes": "Bring water and sunscreen"
}
```

---

## Dependencies

**Dart/Flutter Packages:**
- `freezed` - Immutable data models
- `cloud_firestore` - Firestore database access
- `cloud_functions` - Cloud Functions callable interface
- `flutter_bloc` - State management
- `get_it` - Dependency injection

**Cloud Functions:**
- `firebase-functions` - Cloud Functions SDK
- `firebase-admin` - Admin SDK for Firestore access

---

## Future Enhancements

This story provides the foundation for:

- **Story 15.2**: Recurring Training Sessions
- **Story 15.3**: Join/Leave Training Session
- **Story 15.4**: Training Sessions in Group Activity Feed
- **Story 15.5**: No ELO or Competitive Impact (enforcement)
- **Story 15.6**: Track Training Participation (Stats Foundation)
- **Story 15.7**: Add Exercises to Training Session
- **Story 15.8**: Anonymous Feedback After Training

---

## API Reference

### Cloud Function

**Function**: `createTrainingSession`

**Request:**
```typescript
{
  groupId: string;
  title: string;
  description?: string;
  locationName: string;
  locationAddress?: string;
  startTime: string; // ISO 8601
  endTime: string; // ISO 8601
  minParticipants: number;
  maxParticipants: number;
  notes?: string;
}
```

**Response:**
```typescript
{
  success: boolean;
  sessionId: string;
}
```

**Usage (Dart):**
```dart
final callable = FirebaseFunctions.instance.httpsCallable('createTrainingSession');

final result = await callable.call({
  'groupId': 'group-123',
  'title': 'Advanced Training',
  'locationName': 'Beach Court 1',
  'locationAddress': '123 Beach St',
  'startTime': DateTime.now().add(Duration(days: 1)).toIso8601String(),
  'endTime': DateTime.now().add(Duration(days: 1, hours: 2)).toIso8601String(),
  'minParticipants': 4,
  'maxParticipants': 12,
});

final sessionId = result.data['sessionId'];
```

---

## Acceptance Criteria

✅ **All Acceptance Criteria Met:**

- [x] Training Session can only be created within an existing Group
- [x] Creator must be a member of the Group
- [x] Required fields validated: Title, Location, Start Time, End Time, Min/Max Participants
- [x] No access to friendship or social graph data
- [x] Group membership validation performed via `GroupRepository` only (through Cloud Function)
- [x] Stored under the Games layer Firestore namespace
- [x] Architecture tests ensure no social graph imports
- [x] Security rules prevent non-members from creating sessions (via Cloud Function restriction)
- [x] Code passes `flutter analyze` with 0 warnings
- [x] Unit tests with 90%+ coverage (27 comprehensive tests)
- [x] Documentation updated

---

## Related Files

### Source Code
- `lib/core/data/models/training_session_model.dart`
- `lib/core/domain/repositories/training_session_repository.dart`
- `lib/core/data/repositories/firestore_training_session_repository.dart`
- `lib/features/training/presentation/bloc/training_session_creation/`
- `functions/src/createTrainingSession.ts`

### Configuration
- `firestore.rules` (lines 212-243)
- `functions/src/index.ts` (export createTrainingSession)
- `lib/core/services/service_locator.dart` (dependency injection)

### Tests
- `test/unit/features/training/presentation/bloc/training_session_creation/training_session_creation_bloc_test.dart`
- `test/architecture/dependency_test.dart`

### Documentation
- `CLAUDE.md` (Section 2: Architecture Overview)
- `docs/architecture/LAYERED_DEPENDENCIES.md`

---

## Deployment History

| Environment | Date | Status | Notes |
|------------|------|--------|-------|
| Dev | 2026-01-07 | ✅ Deployed | Cloud Function + Rules deployed successfully |
| Staging | 2026-01-07 | ✅ Deployed | Cloud Function + Rules deployed successfully |
| Production | 2026-01-07 | ✅ Deployed | Cloud Function + Rules deployed successfully |

---

## Notes

- Training sessions are **peer to Games**, not a sub-type of Game
- Training sessions **do not affect ELO ratings** (enforced in Story 15.5)
- Participant management (join/leave) implemented in Story 15.3
- UI implementation deferred to separate story
- Recurrence support (Story 15.2) foundation added but not implemented

---

**Implemented by**: Babas10
**Reviewed by**: [Pending PR Review]
**GitHub Issue**: [#346](https://github.com/Babas10/playWithMe/issues/346)
