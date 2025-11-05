# Security Rules Documentation - Epic 11: Friendship System

**Version:** 1.0
**Last Updated:** 2025-11-05
**Part of:** Epic 11 - Friendship Management
**Related Stories:** Story 11.2, Story 11.3, Story 11.7

---

## 📋 Table of Contents

- [Overview](#overview)
- [Friendships Collection Rules](#friendships-collection-rules)
- [Users Collection Updates](#users-collection-updates)
- [Security Principles](#security-principles)
- [Testing Strategy](#testing-strategy)
- [Deployment Guide](#deployment-guide)
- [Troubleshooting](#troubleshooting)

---

## Overview

This document describes the Firestore Security Rules implemented for the Friendship Management feature in Epic 11. The rules enforce strict access control to ensure that:

1. Users can only manage their own friendships
2. Friend requests follow a proper lifecycle (pending → accepted/declined)
3. Cached friendship data (friendIds, friendCount) cannot be modified directly by clients
4. All operations are authenticated and authorized

### Architecture

The friendship system uses a **two-tier security model**:

1. **Firestore Security Rules** - Enforce document-level access control at the database layer
2. **Cloud Functions** - Handle business logic, cache updates, and notifications

This separation ensures that security cannot be bypassed, even if client code is compromised.

---

## Friendships Collection Rules

### Data Model

```typescript
interface Friendship {
  initiatorId: string;      // User who sent the friend request
  recipientId: string;      // User who received the request
  status: 'pending' | 'accepted' | 'declined';
  createdAt: Timestamp;
  acceptedAt?: Timestamp;   // Set when status changes to 'accepted'
}
```

### Read Access

**Rule:**
```javascript
allow read: if isAuthenticated() &&
               (request.auth.uid == resource.data.initiatorId ||
                request.auth.uid == resource.data.recipientId);
```

**Rationale:**
- Users can only read friendships where they are either the initiator or recipient
- Prevents users from discovering other users' friend connections
- Supports both direct document reads and queries

**Allowed Operations:**
- ✅ `friendships/{friendshipId}.get()` where user is initiator or recipient
- ✅ `.where('initiatorId', '==', currentUserId)` queries
- ✅ `.where('recipientId', '==', currentUserId)` queries

**Denied Operations:**
- ❌ Reading another user's friendship document
- ❌ Listing all friendships without filtering
- ❌ Unauthenticated access

### Create Access

**Rule:**
```javascript
allow create: if isAuthenticated() &&
                 request.auth.uid == request.resource.data.initiatorId &&
                 request.resource.data.status == 'pending' &&
                 request.resource.data.initiatorId != request.resource.data.recipientId &&
                 exists(/databases/$(database)/documents/users/$(request.resource.data.recipientId));
```

**Rationale:**
- Only the initiator can create the friend request (prevents impersonation)
- All new requests must start in 'pending' status (enforces lifecycle)
- Users cannot send friend requests to themselves (prevents data corruption)
- Recipient must exist in the database (prevents orphaned documents)

**Validation Checks:**
1. **Authentication:** User must be logged in
2. **Ownership:** `initiatorId` must match authenticated user's UID
3. **Initial Status:** Must be 'pending' on creation
4. **Self-Friending:** `initiatorId != recipientId`
5. **Recipient Existence:** User document must exist

**Example:**
```dart
// ✅ Valid creation
await FirebaseFirestore.instance.collection('friendships').add({
  'initiatorId': currentUser.uid,     // Matches auth.uid
  'recipientId': 'other-user-id',     // Different user
  'status': 'pending',                // Must be pending
  'createdAt': FieldValue.serverTimestamp(),
});

// ❌ Invalid - wrong initiator
await FirebaseFirestore.instance.collection('friendships').add({
  'initiatorId': 'other-user-id',     // Doesn't match auth.uid
  'recipientId': currentUser.uid,
  'status': 'pending',
});
```

### Update Access

**Rule:**
```javascript
allow update: if isAuthenticated() &&
                 request.auth.uid == resource.data.recipientId &&
                 request.resource.data.status in ['accepted', 'declined'] &&
                 resource.data.status == 'pending' &&
                 // Prevent modifying other fields
                 request.resource.data.initiatorId == resource.data.initiatorId &&
                 request.resource.data.recipientId == resource.data.recipientId;
```

**Rationale:**
- Only the recipient can accept or decline (prevents initiator from forcing acceptance)
- Can only transition from 'pending' to 'accepted'/'declined' (one-way state machine)
- Cannot modify initiator/recipient IDs (prevents hijacking)
- Declined friendships cannot be re-accepted (must create new request)

**Lifecycle Enforcement:**
```
pending ──(recipient)──> accepted  ✅
pending ──(recipient)──> declined  ✅
accepted ──> declined  ❌
declined ──> accepted  ❌
pending ──(initiator)──> accepted  ❌
```

**Example:**
```dart
// ✅ Valid update (recipient accepting)
await friendshipRef.update({
  'status': 'accepted',
  'acceptedAt': FieldValue.serverTimestamp(),
});

// ❌ Invalid - initiator cannot update
// (auth.uid == initiatorId, but rule requires recipientId)

// ❌ Invalid - cannot modify IDs
await friendshipRef.update({
  'status': 'accepted',
  'recipientId': 'different-user',  // Blocked
});
```

### Delete Access

**Rule:**
```javascript
allow delete: if isAuthenticated() &&
                 (request.auth.uid == resource.data.initiatorId ||
                  request.auth.uid == resource.data.recipientId);
```

**Rationale:**
- Both users can delete the friendship (supports "unfriend" action)
- Deleting triggers Cloud Functions to clean up cached data
- Works for both pending and accepted friendships

**Example:**
```dart
// ✅ Valid - initiator deleting
await friendshipRef.delete();

// ✅ Valid - recipient deleting
await friendshipRef.delete();

// ❌ Invalid - third party deleting
// (auth.uid is neither initiatorId nor recipientId)
```

---

## Users Collection Updates

### Protected Fields (Epic 11)

The `/users/{userId}` collection has been updated to protect friendship-related fields that are managed by Cloud Functions triggers.

**Updated Rule:**
```javascript
allow update: if isAuthenticated() &&
                 request.auth.uid == userId &&
                 // Ensure only safe fields are updated
                 (!request.resource.data.diff(resource.data).affectedKeys()
                   .hasAny(['uid', 'email', 'createdAt', 'friendIds', 'friendCount']));
```

### Field Protection Summary

| Field | Description | Managed By | Direct Modification |
|-------|-------------|------------|---------------------|
| `uid` | User ID | Firebase Auth | ❌ Never |
| `email` | Email address | Firebase Auth | ❌ Never |
| `createdAt` | Account creation timestamp | System | ❌ Never |
| `friendIds` | Array of friend user IDs | Cloud Functions | ❌ New: Protected in Epic 11 |
| `friendCount` | Total number of friends | Cloud Functions | ❌ New: Protected in Epic 11 |
| `displayName` | Display name | User | ✅ Allowed |
| `photoUrl` | Profile photo URL | User | ✅ Allowed |
| `notificationPreferences` | Notification settings | User | ✅ Allowed |
| `fcmTokens` | Push notification tokens | User/System | ✅ Allowed |

### Why Protect friendIds and friendCount?

**Security Risks if Unprotected:**
1. **Data Corruption:** Users could add fake friends to their list
2. **Count Manipulation:** Users could inflate their friend count for social status
3. **Cache Inconsistency:** Manual updates bypass Cloud Functions that maintain bidirectional consistency
4. **Trigger Bypass:** Cloud Functions notifications wouldn't fire for fake friendships

**How It's Managed:**
- `onFriendRequestAccepted` trigger adds users to each other's `friendIds` and increments `friendCount`
- `onFriendRemoved` trigger removes users from each other's `friendIds` and decrements `friendCount`
- All updates use Firestore transactions to ensure atomicity

**Example:**
```dart
// ❌ Invalid - cannot update friendIds directly
await userRef.update({
  'friendIds': FieldValue.arrayUnion(['fake-friend-id']),  // Blocked
});

// ✅ Valid - friendIds updated by Cloud Function after accepting request
await friendshipRef.update({'status': 'accepted'});
// → Trigger automatically updates both users' friendIds

// ✅ Valid - can update other fields
await userRef.update({
  'displayName': 'New Name',  // Allowed
  'photoUrl': 'https://example.com/photo.jpg',  // Allowed
});
```

---

## Security Principles

### 1. **Defense in Depth**

Multiple layers of security:
- Firebase Authentication (user identity)
- Firestore Rules (database access)
- Cloud Functions (business logic)
- Client-side validation (UX)

### 2. **Least Privilege**

Users can only:
- Read their own data
- Write their own data with restrictions
- Cannot read or write other users' sensitive information

### 3. **Zero Trust**

Assumptions:
- Client code can be modified or bypassed
- All data from clients is untrusted
- Rules must validate every field on every operation

### 4. **Fail Secure**

Default behavior:
- All access denied unless explicitly allowed
- Catch-all rule at bottom: `allow read, write: if false;`
- Missing fields fail validation

### 5. **Audit Trail**

All operations are logged:
- Firebase Auth logs authentication events
- Firestore logs all read/write operations
- Cloud Functions log trigger executions

---

## Testing Strategy

### Test Coverage

Security rules are tested at three levels:

#### 1. **Unit Tests** (Firebase Rules Emulator)

Location: `functions/test/security-rules/`

**Friendships Tests** (`friendships.test.ts`):
- ✅ 35+ test cases covering all CRUD operations
- ✅ Edge cases (self-friending, duplicate requests, invalid status)
- ✅ Authentication and authorization scenarios
- ✅ State machine enforcement (pending → accepted/declined)

**Users Tests** (`users.test.ts`):
- ✅ 25+ test cases for user document access
- ✅ Protection of friendIds and friendCount
- ✅ Core field protection (uid, email, createdAt)
- ✅ Allowed field updates (displayName, photoUrl, etc.)

#### 2. **Integration Tests** (Flutter + Emulator)

Location: `functions/test/integration/`

- Tests Cloud Functions + Security Rules together
- Validates trigger-based cache updates
- Ensures notifications fire correctly
- Tests complete user flows

#### 3. **Manual Testing** (Dev Environment)

Checklist:
- [ ] Create friend request as user A
- [ ] Accept/decline as user B
- [ ] Verify cannot accept as user A
- [ ] Verify friendIds updated after acceptance
- [ ] Verify cannot manually modify friendIds
- [ ] Delete friendship and verify cleanup

### Running Tests

```bash
# Install dependencies
cd functions
npm install

# Run security rules tests
npm run test:security-rules

# Run with coverage
npm run test:security-rules -- --coverage

# Run specific test suite
npm test -- friendships.test.ts
```

### Test Environment Setup

The tests use Firebase Emulator Suite:

```bash
# Start emulators (in separate terminal)
firebase emulators:start --only firestore

# Tests automatically connect to emulator
# No real Firebase project affected
```

---

## Deployment Guide

### Prerequisites

- Firebase CLI installed (`npm install -g firebase-tools`)
- Authenticated with correct project (`firebase login`)
- Access to dev/staging/production projects

### Deployment Steps

#### 1. **Development Environment**

```bash
# Deploy to dev
firebase deploy --only firestore:rules --project playwithme-dev

# Verify deployment
firebase firestore:rules --project playwithme-dev
```

#### 2. **Staging Environment**

```bash
# Deploy to staging
firebase deploy --only firestore:rules --project playwithme-stg

# Test with staging app
flutter run --flavor stg -t lib/main_stg.dart
```

#### 3. **Production Environment**

⚠️ **CRITICAL:** Always test in dev and staging first!

```bash
# Final review
cat firestore.rules

# Deploy to production
firebase deploy --only firestore:rules --project playwithme-prod

# Monitor for errors
firebase firestore:logs --project playwithme-prod
```

### Rollback Procedure

If rules cause issues in production:

```bash
# List recent deployments
firebase firestore:rules:list --project playwithme-prod

# Get previous version
firebase firestore:rules:get <release-id> --project playwithme-prod > firestore.rules.backup

# Deploy previous version
firebase deploy --only firestore:rules --project playwithme-prod
```

### Validation Checklist

Before deploying to production:

- [ ] All unit tests pass (`npm test`)
- [ ] All integration tests pass
- [ ] Tested in dev environment
- [ ] Tested in staging environment
- [ ] Code reviewed by team member
- [ ] No breaking changes for existing users
- [ ] Monitoring and logging configured

---

## Troubleshooting

### Common Errors

#### **Error: `PERMISSION_DENIED: Missing or insufficient permissions`**

**Cause:** User trying to access data they don't own

**Solution:**
```dart
// ❌ Wrong - trying to read another user's data
await FirebaseFirestore.instance
    .collection('users')
    .doc('other-user-id')
    .get();

// ✅ Correct - read own data
await FirebaseFirestore.instance
    .collection('users')
    .doc(currentUser.uid)
    .get();
```

#### **Error: Friend request creation fails**

**Debugging Steps:**
1. Check `initiatorId` matches authenticated user's UID
2. Verify `status` is set to 'pending'
3. Ensure `recipientId` exists in `/users` collection
4. Confirm not trying to friend yourself

**Example Debug:**
```dart
try {
  await FirebaseFirestore.instance.collection('friendships').add({
    'initiatorId': currentUser.uid,  // Must match
    'recipientId': recipientId,      // Must exist
    'status': 'pending',             // Must be pending
    'createdAt': FieldValue.serverTimestamp(),
  });
} catch (e) {
  if (e is FirebaseException && e.code == 'permission-denied') {
    print('Check: initiatorId=${currentUser.uid}, recipientId=$recipientId');
    // Verify recipientId exists in /users collection
  }
}
```

#### **Error: Cannot update friendship status**

**Common Causes:**
1. Initiator trying to accept (only recipient can)
2. Trying to update non-pending friendship
3. Trying to modify initiatorId or recipientId

**Solution:**
```dart
// ✅ Correct - recipient accepting
if (currentUser.uid == friendship.recipientId &&
    friendship.status == 'pending') {
  await friendshipRef.update({'status': 'accepted'});
}

// ❌ Wrong - initiator cannot accept
if (currentUser.uid == friendship.initiatorId) {
  await friendshipRef.update({'status': 'accepted'});  // Fails
}
```

#### **Error: Cannot update friendIds**

**This is expected behavior!**

**Cause:** Trying to modify `friendIds` or `friendCount` directly

**Solution:** Don't. These fields are managed by Cloud Functions:
```dart
// ❌ Wrong - cannot update directly
await userRef.update({
  'friendIds': FieldValue.arrayUnion(['friend-id']),
});

// ✅ Correct - update happens automatically via trigger
await friendshipRef.update({'status': 'accepted'});
// Cloud Function will update both users' friendIds
```

### Debug Mode

Enable detailed logging in Cloud Functions:

```typescript
// functions/src/notifications.ts
export const onFriendRequestAccepted = functions.firestore
  .document("friendships/{friendshipId}")
  .onUpdate(async (change, context) => {
    console.log("🔍 DEBUG: Friendship update detected", {
      before: change.before.data(),
      after: change.after.data(),
    });
    // ... rest of function
  });
```

View logs:
```bash
firebase functions:log --only onFriendRequestAccepted
```

### Testing Security Rules Locally

Use the Firebase Emulator:

```bash
# Start emulator with UI
firebase emulators:start --only firestore,auth

# Open UI
open http://localhost:4000
```

Test operations in the Firestore UI:
1. Create test users in Auth emulator
2. Try CRUD operations in Firestore emulator
3. Check for permission errors in console

---

## References

- [Firestore Security Rules Documentation](https://firebase.google.com/docs/firestore/security/get-started)
- [Security Rules Testing](https://firebase.google.com/docs/rules/unit-tests)
- [Epic 11 Schema](./SCHEMA.md)
- [Story 11.2 - Callable Functions](./story-11.2/IMPLEMENTATION.md)
- [Story 11.3 - Trigger Functions](./IMPLEMENTATION_11.3.md)
- [CLAUDE.md - Firebase Data Access Rules](../../CLAUDE.md#firebase-data-access-rules-critical)

---

## Version History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2025-11-05 | Claude | Initial security rules for Epic 11 |

---

**⚠️ Security Reminder:** Never commit Firebase configuration files or modify security rules without thorough testing in dev/staging environments first!
