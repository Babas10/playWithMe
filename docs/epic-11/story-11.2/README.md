# Story 11.2 — Implement Friendship Callable Functions

**Status:** ✅ Completed
**Epic:** [Epic 11 - My Community Social Graph](#163)
**Issue:** #165

---

## 📋 Overview

This story implements 6 Firebase Callable Functions that provide secure, server-side management of friendship relationships in the PlayWithMe social graph. All functions include comprehensive validation, error handling, and structured error responses.

---

## ✅ Implemented Functions

### 1. `sendFriendRequest`

Send a friend request to another user.

**Request:**
```typescript
{
  targetUserId: string
}
```

**Response:**
```typescript
{
  success: boolean
  friendshipId: string
}
```

**Validations:**
- ✅ User must be authenticated
- ✅ Cannot friend yourself
- ✅ Target user must exist
- ✅ Users are not already friends
- ✅ No pending request exists (either direction)

**Error Codes:**
- `unauthenticated` - User not logged in
- `invalid-argument` - Missing or invalid targetUserId, or trying to friend yourself
- `not-found` - Target user doesn't exist
- `already-exists` - Users are already friends or pending request exists

**Special Behavior:**
- Allows creating a new request if a previous request was declined (audit trail preserved)

---

###  2. `acceptFriendRequest`

Accept a pending friend request.

**Request:**
```typescript
{
  friendshipId: string
}
```

**Response:**
```typescript
{
  success: boolean
}
```

**Validations:**
- ✅ User must be authenticated
- ✅ Caller must be the recipient (not initiator)
- ✅ Friendship must exist
- ✅ Friendship must be in `pending` status

**Error Codes:**
- `unauthenticated` - User not logged in
- `invalid-argument` - Missing friendshipId
- `not-found` - Friendship doesn't exist
- `permission-denied` - User is not the recipient
- `failed-precondition` - Friendship is not pending

**Transaction Safety:**
- Uses Firestore transaction to prevent race conditions

---

### 3. `declineFriendRequest`

Decline a pending friend request.

**Request:**
```typescript
{
  friendshipId: string
}
```

**Response:**
```typescript
{
  success: boolean
}
```

**Validations:**
- ✅ User must be authenticated
- ✅ Caller must be the recipient
- ✅ Friendship must exist
- ✅ Friendship must be in `pending` status

**Error Codes:**
- Same as `acceptFriendRequest`

**Transaction Safety:**
- Uses Firestore transaction to prevent race conditions

**Special Behavior:**
- Declined friendships are kept for audit trail (not deleted)

---

### 4. `removeFriend`

Remove an existing friendship (delete the friendship document).

**Request:**
```typescript
{
  friendshipId: string
}
```

**Response:**
```typescript
{
  success: boolean
}
```

**Validations:**
- ✅ User must be authenticated
- ✅ Caller must be either initiator or recipient
- ✅ Friendship must exist

**Error Codes:**
- `unauthenticated` - User not logged in
- `invalid-argument` - Missing friendshipId
- `not-found` - Friendship doesn't exist
- `permission-denied` - User not involved in friendship

**Special Behavior:**
- Permanently deletes the friendship document
- Either party can remove the friendship

---

### 5. `getFriends`

Get a list of all accepted friends for the current user.

**Request:**
```typescript
{
  userId?: string  // Optional, defaults to current user
}
```

**Response:**
```typescript
{
  friends: UserProfile[]
}

interface UserProfile {
  uid: string
  displayName: string | null
  email: string
  photoUrl?: string | null
}
```

**Validations:**
- ✅ User must be authenticated
- ✅ Caller can only get their own friends list (privacy)

**Error Codes:**
- `unauthenticated` - User not logged in
- `permission-denied` - Trying to get another user's friends

**Performance:**
- Queries friendships in both directions (as initiator and recipient)
- Batches user profile fetches (10 at a time) for efficiency
- Returns only accepted friendships

---

### 6. `checkFriendshipStatus`

Check the friendship status between the current user and another user.

**Request:**
```typescript
{
  userId: string
}
```

**Response:**
```typescript
{
  isFriend: boolean
  hasPendingRequest: boolean
  requestDirection?: 'sent' | 'received'  // Only if hasPendingRequest is true
}
```

**Validations:**
- ✅ User must be authenticated
- ✅ Cannot check friendship with yourself

**Error Codes:**
- `unauthenticated` - User not logged in
- `invalid-argument` - Missing userId or trying to check with yourself

**Response Examples:**
```typescript
// No relationship
{ isFriend: false, hasPendingRequest: false }

// Friends
{ isFriend: true, hasPendingRequest: false }

// Pending request sent by current user
{ isFriend: false, hasPendingRequest: true, requestDirection: 'sent' }

// Pending request received by current user
{ isFriend: false, hasPendingRequest: true, requestDirection: 'received' }

// Declined friendship (treated as no relationship)
{ isFriend: false, hasPendingRequest: false }
```

---

## 🔄 Updated Functions

### `searchUserByEmail`

Updated to include friendship status in the response.

**Updated Response:**
```typescript
{
  found: boolean
  user?: UserProfile
  isFriend?: boolean  // NEW
  hasPendingRequest?: boolean  // NEW
}
```

**Implementation:**
- Safely queries friendships collection to check status
- Returns false for both fields if friendship query fails (non-blocking)
- Only checks friendship if users are different

---

## 🏗️ Architecture

### File Structure

```
functions/
├── src/
│   ├── friendships.ts              # All 6 friendship functions
│   ├── searchUserByEmail.ts        # Updated with friendship status
│   └── index.ts                    # Exports all functions
├── test/
│   ├── unit/
│   │   └── friendships.test.ts     # 39 comprehensive unit tests
│   └── helpers/
│       └── mockFirestore.ts        # Reusable test helper
```

### Helper Functions (Internal)

The following helper functions are used internally by the callable functions:

```typescript
async function userExists(userId: string): Promise<boolean>
async function getUserProfile(userId: string): Promise<UserProfile | null>
async function findExistingFriendship(userId1: string, userId2: string): Promise<DocumentSnapshot | null>
```

**Benefits:**
- DRY principle - reused across multiple functions
- Consistent error handling
- Type-safe return values

---

## 🧪 Testing

### Test Coverage

- **Total Tests:** 81 (including existing tests)
- **New Tests:** 39 for friendship functions
- **Pass Rate:** 100% ✅
- **Coverage:** All error paths and success paths tested

### Test Structure

Using a clean, maintainable approach with:
- Reusable `createMockFirestore()` helper
- Partial string matching for error messages (resilient to message changes)
- Proper mocking of Firestore transactions
- Consistent test patterns across all functions

### Example Test

```typescript
it("should successfully create friend request", async () => {
  const mockFirestore = createMockFirestore({
    users: {
      user1: {exists: true, data: {displayName: "User 1", email: "user1@example.com"}},
      user2: {exists: true, data: {displayName: "User 2", email: "user2@example.com"}},
    },
    friendships: {
      empty: true,
      addResult: {id: "friendship123"},
    },
  });
  admin.firestore.mockReturnValue(mockFirestore);

  const result = await sendFriendRequestHandler({targetUserId: "user2"}, mockContext);

  expect(result).toEqual({
    success: true,
    friendshipId: "friendship123",
  });
});
```

---

## 🔒 Security

### Authentication
- All functions require authenticated users
- Uses `context.auth.uid` for user identification
- Throws `unauthenticated` error if not logged in

### Authorization
- Users can only accept/decline requests sent to them
- Users can only get their own friends list
- Users can only remove friendships they're involved in
- Prevents self-friending

### Data Privacy
- `getFriends` enforces that users can only view their own friends
- `searchUserByEmail` safely handles friendship check errors
- No sensitive data exposed in error messages

### Transaction Safety
- `acceptFriendRequest` and `declineFriendRequest` use Firestore transactions
- Prevents race conditions during status updates
- Ensures data consistency

---

## 📊 Error Handling

All functions use structured error responses with Firebase HttpsError:

```typescript
throw new functions.https.HttpsError(
  'error-code',       // Machine-readable code
  'User-friendly message'  // Human-readable description
);
```

### Standard Error Codes

| Code | Usage |
|------|-------|
| `unauthenticated` | User not logged in |
| `invalid-argument` | Bad input (missing/invalid parameters) |
| `not-found` | Resource doesn't exist (user, friendship) |
| `already-exists` | Duplicate resource (already friends, pending request) |
| `permission-denied` | Insufficient permissions |
| `failed-precondition` | Invalid state transition (e.g., accepting non-pending request) |
| `internal` | Server error (caught exceptions) |

---

## 🚀 Deployment

Functions are automatically deployed via Firebase:

```bash
# Build TypeScript
npm run build

# Deploy to dev
firebase deploy --only functions --project playwithme-dev

# Deploy to staging
firebase deploy --only functions --project playwithme-stg

# Deploy to production
firebase deploy --only functions --project playwithme-prod
```

---

## 🔗 Integration with Flutter

### Example Usage

```dart
// Send friend request
final sendRequest = FirebaseFunctions.instance.httpsCallable('sendFriendRequest');
final result = await sendRequest.call({'targetUserId': 'user123'});
print(result.data['friendshipId']);  // friendship-abc-123

// Accept friend request
final acceptRequest = FirebaseFunctions.instance.httpsCallable('acceptFriendRequest');
await acceptRequest.call({'friendshipId': 'friendship-abc-123'});

// Get friends list
final getFriends = FirebaseFunctions.instance.httpsCallable('getFriends');
final friends = await getFriends.call({});
print(friends.data['friends'].length);  // 5

// Error handling
try {
  await sendRequest.call({'targetUserId': 'invalid-user'});
} on FirebaseFunctionsException catch (e) {
  if (e.code == 'not-found') {
    print('User not found');
  }
}
```

---

## 📈 Performance Considerations

### Read Optimization
- `getFriends`: Batches user profile reads (10 at a time)
- `checkFriendshipStatus`: Single query in both directions
- Uses Firestore indexes for efficient querying

### Write Optimization
- Uses `FieldValue.serverTimestamp()` for consistency
- Transactions only where needed (accept/decline)
- Denormalized user names to avoid extra reads

### Recommended Indexes

Already configured in `firestore.indexes.json`:
```json
{
  "collectionGroup": "friendships",
  "fields": [
    {"fieldPath": "initiatorId", "order": "ASCENDING"},
    {"fieldPath": "status", "order": "ASCENDING"}
  ]
},
{
  "collectionGroup": "friendships",
  "fields": [
    {"fieldPath": "recipientId", "order": "ASCENDING"},
    {"fieldPath": "status", "order": "ASCENDING"}
  ]
}
```

---

## 🔄 Next Steps

This story lays the foundation for:
- **Story 11.3:** Trigger functions for friendship events
- **Story 11.7:** Security rules updates
- **Story 11.11:** Flutter repository layer
- **Story 11.5:** UI components

---

## 📝 Notes

### Idempotency
All functions are designed to be safely retried:
- `sendFriendRequest`: Returns error if already exists
- `acceptFriendRequest`: Only works on pending requests
- `removeFriend`: Returns error if not found (safe to retry)

### Audit Trail
- Declined friendships are kept (not deleted)
- Status transitions are one-way: pending → accepted/declined
- No status rollback allowed

### Future Enhancements
- Rate limiting (prevent spam)
- Friendship suggestions
- Mutual friends count
- Block/unblock functionality

---

**Implemented by:** Claude Code
**Date:** 2024-11-04
**Tests:** 100% passing (81/81)
