# Story 15.6: Training Session Participation Tracking - Technical Documentation

**Epic:** #345 - Training Sessions (Games-Layer Event Type)
**Story:** #351 - Track Training Participation (Stats Foundation)
**Status:** ✅ Implemented
**Date:** January 2026

---

## Overview

This story implements the foundational infrastructure for tracking user participation in training sessions. The system captures participation events (join/leave), stores them with timestamps, and maintains participation status for future statistics and analytics.

**Key principle:** This is a **foundation story** — no statistics are calculated or displayed yet. The goal is to establish a robust data model and collection mechanism that will support future analytics (Stories 15.7, 15.8, etc.).

---

## Architecture

### Data Flow

```
User Action (Join/Leave)
    ↓
TrainingSessionParticipationBloc
    ↓
TrainingSessionRepository
    ↓
Cloud Function (joinTrainingSession / leaveTrainingSession)
    ↓
Firestore Transaction (Atomic)
    ↓
Participants Subcollection + Denormalized Array
```

### Layering

- **Presentation Layer:** `TrainingSessionParticipationBloc` manages UI state
- **Repository Layer:** `TrainingSessionRepository` abstracts Firestore operations
- **Cloud Functions:** Enforce business rules and perform atomic operations
- **Data Layer:** Firestore with subcollections and denormalized arrays

---

## Data Model

### TrainingSessionParticipantModel

**Location:** `lib/core/data/models/training_session_participant_model.dart`

**Fields:**
```dart
class TrainingSessionParticipantModel {
  /// User ID of the participant (stored as document ID in Firestore)
  final String userId;

  /// Timestamp when the user joined the training session
  /// - Uses @TimestampConverter() for Firestore serialization
  /// - Stored as Firestore Timestamp in database
  /// - Exposed as DateTime in Dart
  final DateTime joinedAt;

  /// Current participation status
  /// - 'joined': User is currently participating
  /// - 'left': User has left the session
  final ParticipantStatus status;
}

enum ParticipantStatus {
  joined,  // User is actively participating
  left,    // User has withdrawn from the session
}
```

**Helper Methods:**
- `isJoined` - Returns true if status is 'joined'
- `hasLeft` - Returns true if status is 'left'

**Serialization:**
- `fromFirestore(DocumentSnapshot)` - Converts Firestore document to model
- `toFirestore()` - Converts model to Firestore-compatible map (excludes userId since it's the document ID)
- Automatic Timestamp ↔ DateTime conversion

---

## Firestore Schema

### Collection Structure

```
trainingSessions/
  {sessionId}/                              # Training session document
    - participantIds: [userId1, userId2]    # Denormalized array for fast reads
    - maxParticipants: 20                   # Capacity limit
    - status: "scheduled"                   # Session status

    participants/                           # Subcollection (source of truth)
      {userId1}/                            # Document ID = user ID
        - joinedAt: Timestamp(2026-01-07...)
        - status: "joined"

      {userId2}/
        - joinedAt: Timestamp(2026-01-07...)
        - status: "left"                    # User withdrew
```

### Design Decisions

**Why Both Subcollection AND Denormalized Array?**

1. **Subcollection (`participants/`):**
   - **Source of truth** for participation history
   - Supports complex queries (filter by status, order by joinedAt)
   - Scalable (doesn't bloat parent document)
   - Preserves historical data (left participants remain)
   - Enables future analytics (participation rate, attendance patterns)

2. **Denormalized Array (`participantIds`):**
   - **Fast capacity checks** without subcollection query
   - Simple client-side validation (is session full?)
   - Quick count of active participants
   - Updated atomically by Cloud Functions

**Trade-off:** Slight write overhead (update both structures) for significantly faster reads and better scalability.

---

## Cloud Functions

### joinTrainingSession

**Location:** `functions/src/joinTrainingSession.ts`

**Purpose:** Atomically add a user to a training session while enforcing capacity limits and validation rules.

**Validation Steps:**
1. **Authentication:** User must be logged in
2. **Input:** `sessionId` must be provided
3. **Session Exists:** Training session must exist in Firestore
4. **Session Status:** Only 'scheduled' sessions can be joined
5. **Start Time:** Session must not have started yet
6. **Group Membership:** User must be a member of the associated group

**Atomic Transaction:**
```typescript
runTransaction(async (transaction) => {
  // 1. Count current participants (status = 'joined')
  const currentParticipants = await transaction.get(
    participants.where('status', '==', 'joined')
  );

  // 2. Check if user already joined
  const existingParticipant = await transaction.get(participantDoc);
  if (existingParticipant.exists && status === 'joined') {
    throw 'already-exists';
  }

  // 3. Check capacity
  if (currentParticipants.size >= maxParticipants) {
    throw 'failed-precondition: Session is full';
  }

  // 4. Create participant document
  transaction.set(participantDoc, {
    userId,
    joinedAt: FieldValue.serverTimestamp(),
    status: 'joined',
  });

  // 5. Update denormalized participantIds array
  transaction.update(sessionDoc, {
    participantIds: [...currentIds, userId],
    updatedAt: FieldValue.serverTimestamp(),
  });
});
```

**Error Codes:**
- `unauthenticated` - User not logged in
- `invalid-argument` - Missing or invalid sessionId
- `not-found` - Training session doesn't exist
- `failed-precondition` - Session full, already started, or not scheduled
- `already-exists` - User already joined
- `permission-denied` - Not a group member
- `internal` - Unexpected server error

---

### leaveTrainingSession

**Location:** `functions/src/leaveTrainingSession.ts`

**Purpose:** Allow a user to leave a training session by updating their status to 'left' (preserves historical data).

**Validation Steps:**
1. **Authentication:** User must be logged in
2. **Input:** `sessionId` must be provided
3. **Session Exists:** Training session must exist
4. **Session Status:** Only 'scheduled' sessions can be left

**Atomic Transaction:**
```typescript
runTransaction(async (transaction) => {
  // 1. Check if user is participant
  const participantDoc = await transaction.get(participantRef);
  if (!participantDoc.exists) {
    throw 'failed-precondition: Not a participant';
  }

  // 2. Check if already left
  if (participantData.status === 'left') {
    throw 'failed-precondition: Already left';
  }

  // 3. Update status to 'left' (preserve history)
  transaction.update(participantRef, {
    status: 'left',
  });

  // 4. Update denormalized participantIds array (remove user)
  const remainingParticipants = allParticipants
    .filter(id => id !== userId);

  transaction.update(sessionDoc, {
    participantIds: remainingParticipants,
    updatedAt: FieldValue.serverTimestamp(),
  });
});
```

**Key Design:** Status is updated to 'left' rather than deleting the document, preserving participation history for analytics.

---

## BLoC Layer

### TrainingSessionParticipationBloc

**Location:** `lib/features/training/presentation/bloc/training_session_participation/`

**Responsibilities:**
- Manage participation state (loading, loaded, joining, leaving, errors)
- Stream participant lists in real-time
- Handle join/leave operations with Cloud Functions
- Provide user-friendly error messages

**Events:**
```dart
LoadParticipants(sessionId)      // Subscribe to participant stream
JoinTrainingSession(sessionId)   // User joins session
LeaveTrainingSession(sessionId)  // User leaves session
```

**States:**
```dart
ParticipationInitial()                 // Initial state
ParticipationLoading()                 // Loading participants
ParticipationLoaded(participants, count)  // Participants loaded
JoiningSession(sessionId)              // Joining in progress
JoinedSession(sessionId, message)      // Successfully joined
LeavingSession(sessionId)              // Leaving in progress
LeftSession(sessionId, message)        // Successfully left
ParticipationError(message, errorCode) // Operation failed
```

**Features:**
- **Real-time updates:** Automatically subscribes to participant streams
- **Auto-reload:** After join/leave, participants list is refreshed
- **Stream cleanup:** Cancels subscriptions on BLoC disposal
- **Error mapping:** Converts Cloud Function errors to user-friendly messages

**Example Usage:**
```dart
// Load participants
bloc.add(LoadParticipants('session123'));

// Join session
bloc.add(JoinTrainingSession('session123'));

// Listen to state
BlocBuilder<TrainingSessionParticipationBloc, TrainingSessionParticipationState>(
  builder: (context, state) {
    if (state is ParticipationLoaded) {
      return Text('${state.participantCount} participants');
    }
    return CircularProgressIndicator();
  },
);
```

---

## Repository Layer

### TrainingSessionRepository (Interface)

**Methods for Participation:**
```dart
// Join/Leave operations (use Cloud Functions)
Future<void> joinTrainingSession(String sessionId);
Future<void> leaveTrainingSession(String sessionId);

// Stream participants (real-time)
Stream<List<TrainingSessionParticipantModel>> getTrainingSessionParticipantsStream(String sessionId);

// Get participant count (real-time)
Stream<int> getTrainingSessionParticipantCount(String sessionId);

// Validate eligibility
Future<bool> canUserJoinTrainingSession(String sessionId, String userId);
```

### FirestoreTrainingSessionRepository (Implementation)

**Participant Stream:**
```dart
Stream<List<TrainingSessionParticipantModel>> getTrainingSessionParticipantsStream(String sessionId) {
  return _firestore
    .collection('trainingSessions')
    .doc(sessionId)
    .collection('participants')
    .where('status', isEqualTo: 'joined')  // Only active participants
    .snapshots()
    .map((snapshot) => snapshot.docs
      .map((doc) => TrainingSessionParticipantModel.fromFirestore(doc))
      .toList()
    );
}
```

**Participant Count Stream:**
```dart
Stream<int> getTrainingSessionParticipantCount(String sessionId) {
  return getTrainingSessionParticipantsStream(sessionId)
    .map((participants) => participants.length);
}
```

---

## Firestore Security Rules

**Location:** `firestore.rules`

```javascript
match /trainingSessions/{sessionId} {
  // Read: Group members only
  allow get, list: if isGroupMember(resource.data.groupId);

  // Write: Cloud Functions only (no direct client writes)
  allow create, update, delete: if false;

  // Participants subcollection
  match /participants/{userId} {
    // Read: Group members only
    allow get, list: if isGroupMember(
      get(/databases/$(database)/documents/trainingSessions/$(sessionId)).data.groupId
    );

    // Write: Cloud Functions only (enforce validation and atomic operations)
    allow create, update, delete: if false;
  }
}
```

**Key Principles:**
- ✅ Read access for group members (validated by security rules)
- ❌ No direct writes from client (all writes through Cloud Functions)
- ✅ Centralized validation and business logic on server
- ✅ Atomic operations prevent race conditions

---

## Query Patterns for Future Analytics

The data model is designed to support the following future queries:

### User-Level Analytics (Future Stories)

```dart
// Get all trainings a user participated in
firestore
  .collectionGroup('participants')
  .where('userId', isEqualTo: userId)
  .where('status', isEqualTo: 'joined')
  .orderBy('joinedAt', descending: true);

// Get user's participation history for a group
firestore
  .collection('trainingSessions')
  .where('groupId', isEqualTo: groupId)
  .snapshots()
  .asyncMap((sessions) async {
    // For each session, check if user participated
    final participation = await Future.wait(
      sessions.docs.map((session) =>
        session.ref.collection('participants').doc(userId).get()
      )
    );
    return participation.where((doc) => doc.exists);
  });
```

### Group-Level Analytics (Future Stories)

```dart
// Average participation rate
// (Count participants who marked 'joined' vs total group members)

// Most active participants
// (Count 'joined' status per user across all sessions)

// Attendance consistency
// (Ratio of 'joined' to 'left' status per user)
```

### Performance Considerations

- **Collection group queries** require composite indexes
- **Denormalized participantIds** array enables fast capacity checks without querying subcollection
- **Status field** allows filtering active vs historical participants
- **joinedAt timestamp** supports chronological ordering

---

## Testing Strategy

### Unit Tests

**Location:** `test/unit/features/training/presentation/bloc/training_session_participation_bloc_test.dart`

**Coverage:** 17 test cases covering:
- Initial state verification
- Loading participants (success, empty list, errors)
- Joining sessions (success, various error codes)
- Leaving sessions (success, various error codes)
- Error message mapping
- Stream subscription cleanup

**Test Approach:**
✅ Mock repository with `mocktail` (not fake_cloud_firestore)
✅ Test BLoC state transitions
✅ Verify error handling for all Cloud Function error codes
✅ Test stream lifecycle management

**Why not test Firestore directly in unit tests?**
- Unit tests focus on BLoC logic and state management
- Firestore query correctness is tested in integration tests
- Mocking the repository interface is faster and more reliable

### Integration Tests

**Recommended (for future story or CI enhancement):**

```dart
// integration_test/training_participation_flow_test.dart
testWidgets('user can join and leave training session', (tester) async {
  await FirebaseEmulatorHelper.initialize();

  // Create test user and training session
  final user = await FirebaseEmulatorHelper.createCompleteTestUser(...);
  final session = await createTestTrainingSession(...);

  // Join session via Cloud Function
  final callable = FirebaseFunctions.instance.httpsCallable('joinTrainingSession');
  await callable.call({'sessionId': session.id});

  // Verify participant document created
  final participantDoc = await FirebaseFirestore.instance
    .collection('trainingSessions')
    .doc(session.id)
    .collection('participants')
    .doc(user.uid)
    .get();

  expect(participantDoc.exists, isTrue);
  expect(participantDoc.data()?['status'], equals('joined'));

  // Leave session
  final leaveCallable = FirebaseFunctions.instance.httpsCallable('leaveTrainingSession');
  await leaveCallable.call({'sessionId': session.id});

  // Verify status updated to 'left'
  final updatedDoc = await participantDoc.ref.get();
  expect(updatedDoc.data()?['status'], equals('left'));
});
```

---

## Future Enhancements (Out of Scope for Story 15.6)

The following features are **NOT** implemented in this story but the data model supports them:

### Story 15.7: Add Exercises to Training Session
- Associate exercises/drills with sessions
- Track which exercises users participated in

### Story 15.8: Anonymous Feedback After Training
- Collect feedback linked to participation records
- Aggregate feedback by session

### Future Statistics Dashboard
- User participation rate (joinedSessions / totalSessions)
- Attendance consistency (joined / (joined + left))
- Group engagement metrics
- Most active participants leaderboard
- Participation trends over time

---

## Deployment

### Cloud Functions

**Verify deployment:**
```bash
# Check if functions are deployed
firebase functions:list --project playwithme-dev

# Expected output should include:
# ✓ joinTrainingSession (callable)
# ✓ leaveTrainingSession (callable)
```

**Deploy to all environments:**
```bash
# Development
firebase deploy --only functions:joinTrainingSession,functions:leaveTrainingSession --project playwithme-dev

# Staging
firebase deploy --only functions:joinTrainingSession,functions:leaveTrainingSession --project playwithme-stg

# Production
firebase deploy --only functions:joinTrainingSession,functions:leaveTrainingSession --project playwithme-prod
```

### Firestore Indexes

**Required indexes:**
- `trainingSessions/{sessionId}/participants`: `status` (ascending)
- Collection group `participants`: `userId` (ascending), `joinedAt` (descending)

**Deploy indexes:**
```bash
firebase deploy --only firestore:indexes
```

---

## Acceptance Criteria Validation

✅ **Participation records include:**
- User ID ✅ (stored as document ID)
- Join timestamp ✅ (`joinedAt` field with Timestamp converter)
- Attendance status ✅ (`status` enum: joined/left)

✅ **Stored in Games-layer collections**
- Subcollection under `trainingSessions/{sessionId}/participants/` ✅
- No dependency on My Community or friendship data ✅

✅ **No user stats are calculated yet**
- Data collection only ✅
- No aggregation or statistics computation ✅

✅ **Data model supports later aggregation:**
- Timestamp for chronological analysis ✅
- Status field for filtering active vs historical ✅
- User ID for per-user aggregation ✅
- Subcollection structure for scalability ✅

---

## Related Documentation

- [Epic 15: Training Sessions](../README.md)
- [Story 15.2: Recurring Training Sessions](../story-15.2/)
- [Story 15.4: Training Sessions Activity Feed](../story-15.4/)
- [Architecture: Layered Dependencies](../../architecture/LAYERED_DEPENDENCIES.md)
- [Firebase Security](../../security/FIREBASE_CONFIG_SECURITY.md)

---

## Summary

Story 15.6 establishes the **foundational infrastructure** for tracking training session participation:

1. **Data Model:** `TrainingSessionParticipantModel` with userId, joinedAt, and status
2. **Storage:** Firestore subcollection + denormalized array pattern
3. **Cloud Functions:** Atomic join/leave operations with validation
4. **BLoC Layer:** Real-time participant streaming and state management
5. **Testing:** Comprehensive unit tests for BLoC logic
6. **Security:** Cloud Function-enforced validation, no direct client writes
7. **Future-Ready:** Query patterns and data structure support future analytics

This foundation enables future stories to build statistics dashboards, leaderboards, and participation analytics without modifying the core data model.
