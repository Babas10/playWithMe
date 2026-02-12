# Invite System — Cloud Function API Contract

**Epic:** 17 — Invite-Based Onboarding & Deep Link Group Join
**Story:** 17.2 — Define the Cloud Function Contract
**Depends on:** Story 17.1 (Firestore Schema)
**Blocks:** Story 17.3 (Implementation)

---

## Overview

This document defines the complete callable Cloud Functions API contract for the group invite system. It covers four functions:

1. **`createGroupInvite`** — Generate a shareable invite link
2. **`validateInviteToken`** — Validate a token and return group info
3. **`joinGroupViaInvite`** — Join a group via invite token
4. **`revokeGroupInvite`** — Revoke an existing invite link

All functions are `https.onCall` callables. All mutations use the Admin SDK and are protected by Firestore security rules that deny direct client writes (`allow write: if false`).

---

## Shared Standards

All functions in this contract follow CLAUDE.md Section 11 (Cloud Functions Development Standards):

- **Idempotent** — Safe to retry; duplicate calls produce the same outcome
- **Atomic** — Multi-document writes use Firestore batch/transaction
- **Fail-Fast** — Authentication and input validation before any write
- **Observable** — Structured logging at every significant branch
- **Minimal Surface** — Return only non-sensitive data

### Standard Error Format

All errors use `functions.https.HttpsError`:

```typescript
throw new functions.https.HttpsError(
  'error-code',       // One of the standard codes below
  'User-friendly message'
);
```

### Standard Error Codes

| Code | Description |
|------|-------------|
| `unauthenticated` | User not logged in |
| `permission-denied` | Insufficient privileges |
| `invalid-argument` | Bad or missing input |
| `not-found` | Resource does not exist |
| `already-exists` | Duplicate operation or entity |
| `failed-precondition` | State conflict (e.g., at capacity, revoked, expired) |
| `internal` | Unexpected server error |

### Authentication Pattern

Every function starts with:

```typescript
if (!context.auth) {
  throw new functions.https.HttpsError(
    'unauthenticated',
    'You must be logged in to perform this operation.'
  );
}
const uid = context.auth.uid;
```

---

## 1. `createGroupInvite`

**Purpose:** Generate a new shareable invite link for a group.

### Type Definitions

```typescript
interface CreateGroupInviteRequest {
  groupId: string;
  expiresInHours?: number;   // Optional: hours until expiration (null = never)
  usageLimit?: number;        // Optional: max uses (null = unlimited)
}

interface CreateGroupInviteResponse {
  success: boolean;
  inviteId: string;
  token: string;
  deepLinkUrl: string;        // Full deep link URL for sharing
  expiresAt: string | null;   // ISO 8601 timestamp or null
}
```

### Validation Rules

| Step | Rule | Error Code |
|------|------|------------|
| 1 | User must be authenticated | `unauthenticated` |
| 2 | `groupId` must be a non-empty string | `invalid-argument` |
| 3 | `expiresInHours` (if provided) must be a positive number | `invalid-argument` |
| 4 | `usageLimit` (if provided) must be a positive integer | `invalid-argument` |
| 5 | Group must exist in Firestore | `not-found` |
| 6 | User must be a member of the group (`memberIds` contains `auth.uid`) | `permission-denied` |
| 7 | Group must have `allowMembersToInviteOthers == true`, OR user must be in `adminIds` or be `createdBy` | `permission-denied` |
| 8 | Group must not be at capacity (`memberIds.length < maxMembers`) | `failed-precondition` |

### Server-Side Logic

```
1. Validate authentication
2. Validate input parameters (groupId, expiresInHours, usageLimit)
3. Fetch group document from Firestore (Admin SDK)
4. Validate group exists
5. Validate user is a member
6. Validate invite permission (allowMembersToInviteOthers OR admin/creator)
7. Validate group is not at capacity
8. Generate secure random token: crypto.randomBytes(24).toString('base64url')
   → Produces 32 URL-safe characters with 192 bits of entropy
9. Calculate expiresAt: if expiresInHours provided, now + expiresInHours; else null
10. Create invite document and token lookup atomically (batch write):
    a. groups/{groupId}/invites/{inviteId} — full invite data
    b. invite_tokens/{token} — lookup entry {groupId, inviteId, createdAt, active: true}
11. Construct deep link URL
12. Return response with inviteId, token, deepLinkUrl, expiresAt
```

### Atomic Write Detail

Both documents must be written in a single batch:

```typescript
const batch = admin.firestore().batch();

// 1. Invite document
batch.set(
  admin.firestore().doc(`groups/${groupId}/invites/${inviteId}`),
  {
    token,
    createdBy: uid,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    expiresAt: expiresAt ? admin.firestore.Timestamp.fromDate(expiresAt) : null,
    revoked: false,
    usageLimit: usageLimit ?? null,
    usageCount: 0,
    groupId,
    inviteType: 'group_link',
  }
);

// 2. Token lookup document
batch.set(
  admin.firestore().doc(`invite_tokens/${token}`),
  {
    groupId,
    inviteId,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    active: true,
  }
);

await batch.commit();
```

### Error Codes Summary

| Code | Condition |
|------|-----------|
| `unauthenticated` | User not logged in |
| `invalid-argument` | Missing or invalid `groupId`, `expiresInHours`, or `usageLimit` |
| `not-found` | Group does not exist |
| `permission-denied` | User not a group member, or invite creation not allowed |
| `failed-precondition` | Group is at capacity |
| `internal` | Unexpected server error |

### Logging

```typescript
console.log('[createGroupInvite] Creating invite', {
  uid,
  groupId,
  expiresInHours: data.expiresInHours ?? 'never',
  usageLimit: data.usageLimit ?? 'unlimited',
});

// On success:
console.log('[createGroupInvite] Invite created', {
  uid,
  groupId,
  inviteId,
  tokenPrefix: token.substring(0, 8) + '...',
});

// On error:
console.error('[createGroupInvite] Error', { uid, groupId, error });
```

---

## 2. `validateInviteToken`

**Purpose:** Validate an invite token and return group information for the pre-join screen.

### Type Definitions

```typescript
interface ValidateInviteTokenRequest {
  token: string;
}

interface ValidateInviteTokenResponse {
  valid: boolean;
  groupId: string;
  groupName: string;
  groupDescription?: string;
  groupPhotoUrl?: string;
  groupMemberCount: number;
  inviterName: string;
  inviterPhotoUrl?: string;
  expiresAt: string | null;       // ISO 8601 timestamp or null
  remainingUses: number | null;   // null = unlimited
}
```

### Validation Rules

| Step | Rule | Error Code |
|------|------|------------|
| 1 | User must be authenticated (can be a newly created account) | `unauthenticated` |
| 2 | `token` must be a non-empty string | `invalid-argument` |
| 3 | Token must exist in `invite_tokens/{token}` collection | `not-found` |
| 4 | Token must be active (`active == true`) | `failed-precondition` |
| 5 | Invite must not be revoked (`revoked == false`) | `failed-precondition` |
| 6 | Invite must not be expired (`expiresAt == null` OR `expiresAt > now`) | `failed-precondition` |
| 7 | Usage limit must not be exceeded (`usageLimit == null` OR `usageCount < usageLimit`) | `failed-precondition` |

### Server-Side Logic

```
1. Validate authentication
2. Validate token is a non-empty string
3. Fetch token lookup document from invite_tokens/{token}
4. If not found → throw not-found
5. If not active → throw failed-precondition ("This invite link is no longer active")
6. Fetch invite document from groups/{groupId}/invites/{inviteId}
7. Validate invite is not revoked
8. Validate invite is not expired
9. Validate usage limit not reached
10. Fetch group document (for name, description, photoUrl, memberCount)
11. Fetch inviter profile (for displayName, photoUrl) using invite.createdBy
12. Calculate remainingUses: if usageLimit != null → usageLimit - usageCount; else null
13. Return response with group info and invite metadata
```

### Error Codes Summary

| Code | Condition |
|------|-----------|
| `unauthenticated` | User not logged in |
| `invalid-argument` | Token is empty or malformed |
| `not-found` | Token does not exist in `invite_tokens/` |
| `failed-precondition` | Token is inactive, invite is revoked, expired, or usage limit reached |
| `internal` | Unexpected server error |

### Logging

```typescript
console.log('[validateInviteToken] Validating token', {
  uid,
  tokenPrefix: data.token.substring(0, 8) + '...',
});

// On success:
console.log('[validateInviteToken] Token valid', {
  uid,
  groupId,
  inviteId,
});

// On failure:
console.warn('[validateInviteToken] Token invalid', {
  uid,
  reason: 'revoked' | 'expired' | 'usage_limit_reached' | 'inactive',
});
```

---

## 3. `joinGroupViaInvite`

**Purpose:** Join the authenticated user to the group associated with the invite token.

### Type Definitions

```typescript
interface JoinGroupViaInviteRequest {
  token: string;
}

interface JoinGroupViaInviteResponse {
  success: boolean;
  groupId: string;
  groupName: string;
  alreadyMember: boolean;     // True if user was already in the group
}
```

### Validation Rules

| Step | Rule | Error Code |
|------|------|------------|
| 1 | User must be authenticated | `unauthenticated` |
| 2 | `token` must be a non-empty string | `invalid-argument` |
| 3 | Token must exist in `invite_tokens/` | `not-found` |
| 4 | Token must be active (`active == true`) | `failed-precondition` |
| 5 | Invite must not be revoked | `failed-precondition` |
| 6 | Invite must not be expired | `failed-precondition` |
| 7 | Usage limit must not be exceeded | `failed-precondition` |
| 8 | Group must not be at capacity (unless user is already a member) | `failed-precondition` |

### Server-Side Logic (Transaction)

This function uses a Firestore **transaction** to ensure atomicity and prevent race conditions (e.g., two users joining simultaneously near capacity).

```
1. Validate authentication
2. Validate token is a non-empty string
3. Run Firestore transaction:
   a. Read token lookup document (invite_tokens/{token})
   b. If not found → throw not-found
   c. If not active → throw failed-precondition
   d. Read invite document (groups/{groupId}/invites/{inviteId})
   e. Validate invite not revoked, not expired, usage limit not reached
   f. Read group document (groups/{groupId})
   g. Check if user is already a member:
      - If YES → return { success: true, alreadyMember: true } (no writes)
   h. Check group capacity: memberIds.length < maxMembers
      - If at capacity → throw failed-precondition
   i. Transaction writes:
      - Update group: arrayUnion(uid) to memberIds, update lastActivity
      - Update invite: increment usageCount by 1
4. Return response with groupId, groupName, alreadyMember: false
```

### Transaction Detail

```typescript
await admin.firestore().runTransaction(async (transaction) => {
  // Reads (must come before writes in transactions)
  const tokenDoc = await transaction.get(tokenRef);
  const inviteDoc = await transaction.get(inviteRef);
  const groupDoc = await transaction.get(groupRef);

  // Validations...

  // Check already member (idempotent no-op)
  if (groupData.memberIds.includes(uid)) {
    alreadyMember = true;
    return; // No writes needed
  }

  // Check capacity
  if (groupData.memberIds.length >= groupData.maxMembers) {
    throw new functions.https.HttpsError(
      'failed-precondition',
      'This group is at capacity.'
    );
  }

  // Writes
  transaction.update(groupRef, {
    memberIds: admin.firestore.FieldValue.arrayUnion(uid),
    lastActivity: admin.firestore.FieldValue.serverTimestamp(),
  });

  transaction.update(inviteRef, {
    usageCount: admin.firestore.FieldValue.increment(1),
  });
});
```

### Idempotency

- If the user is already a member, the function returns `{ success: true, alreadyMember: true }` without performing any writes.
- `FieldValue.arrayUnion` is inherently idempotent — adding an existing element is a no-op.
- Safe to call multiple times (retry, re-click, deep link re-open).

### Error Codes Summary

| Code | Condition |
|------|-----------|
| `unauthenticated` | User not logged in |
| `invalid-argument` | Token is empty or malformed |
| `not-found` | Token does not exist |
| `failed-precondition` | Token invalid (revoked/expired/limit reached) or group at capacity |
| `internal` | Unexpected server error |

### Logging

```typescript
console.log('[joinGroupViaInvite] Join attempt', {
  uid,
  tokenPrefix: data.token.substring(0, 8) + '...',
});

// On success (new member):
console.log('[joinGroupViaInvite] User joined group', {
  uid,
  groupId,
  inviteId,
  newMemberCount: groupData.memberIds.length + 1,
});

// On success (already member):
console.log('[joinGroupViaInvite] User already member', {
  uid,
  groupId,
});

// On error:
console.error('[joinGroupViaInvite] Error', { uid, error });
```

---

## 4. `revokeGroupInvite`

**Purpose:** Revoke an existing invite link so it can no longer be used.

### Type Definitions

```typescript
interface RevokeGroupInviteRequest {
  groupId: string;
  inviteId: string;
}

interface RevokeGroupInviteResponse {
  success: boolean;
}
```

### Validation Rules

| Step | Rule | Error Code |
|------|------|------------|
| 1 | User must be authenticated | `unauthenticated` |
| 2 | `groupId` must be a non-empty string | `invalid-argument` |
| 3 | `inviteId` must be a non-empty string | `invalid-argument` |
| 4 | Invite must exist in `groups/{groupId}/invites/{inviteId}` | `not-found` |
| 5 | User must be admin/creator of the group, OR be the original invite creator (`invite.createdBy == uid`) | `permission-denied` |
| 6 | Invite must not already be revoked | `already-exists` |

### Server-Side Logic

```
1. Validate authentication
2. Validate groupId and inviteId are non-empty strings
3. Fetch invite document from groups/{groupId}/invites/{inviteId}
4. If not found → throw not-found
5. If already revoked → throw already-exists ("Invite is already revoked")
6. Fetch group document to check permissions
7. Validate user is admin, creator, or the invite creator
8. Batch write:
   a. Update invite: set revoked = true
   b. Update token lookup: set active = false in invite_tokens/{invite.token}
9. Return { success: true }
```

### Batch Write Detail

```typescript
const batch = admin.firestore().batch();

// 1. Revoke invite
batch.update(
  admin.firestore().doc(`groups/${groupId}/invites/${inviteId}`),
  { revoked: true }
);

// 2. Deactivate token lookup
batch.update(
  admin.firestore().doc(`invite_tokens/${inviteData.token}`),
  { active: false }
);

await batch.commit();
```

### Error Codes Summary

| Code | Condition |
|------|-----------|
| `unauthenticated` | User not logged in |
| `invalid-argument` | Missing or empty `groupId` or `inviteId` |
| `not-found` | Invite does not exist |
| `permission-denied` | User is not group admin/creator and not the invite creator |
| `already-exists` | Invite is already revoked |
| `internal` | Unexpected server error |

### Logging

```typescript
console.log('[revokeGroupInvite] Revoking invite', {
  uid,
  groupId,
  inviteId,
});

// On success:
console.log('[revokeGroupInvite] Invite revoked', {
  uid,
  groupId,
  inviteId,
  token: inviteData.token.substring(0, 8) + '...',
});

// On error:
console.error('[revokeGroupInvite] Error', { uid, groupId, inviteId, error });
```

---

## Deep Link URL Format

### Primary Format

```
https://playwithme.page.link/invite?token={token}
```

### Fallback Format (if Dynamic Links not configured)

```
https://playwithme.app/invite/{token}
```

### URL Construction (in `createGroupInvite`)

```typescript
const BASE_URL = 'https://playwithme.app/invite';
const deepLinkUrl = `${BASE_URL}/${token}`;
```

The URL format may be updated in Story 17.5 (Deep Link Handling) when the deep linking infrastructure is configured.

---

## Cross-Layer Boundaries

This contract strictly respects the layered architecture defined in CLAUDE.md Section 2.

| Operation | Layer | Allowed | Notes |
|-----------|-------|---------|-------|
| Create invite | Groups | Yes | Validates group membership only |
| Validate token | Groups | Yes | Reads group and invite data |
| Join group | Groups | Yes | Modifies group membership |
| Revoke invite | Groups | Yes | Modifies invite and token data |
| Create friendship | Social Graph | **NO** | Invite join does NOT create a MyCommunity connection |
| Notify game players | Games | **NO** | Not relevant to invite flow |
| Auto-add to community | Social Graph | **NO** | Must be manual action by user |

**Explicit constraint:** Joining a group via invite link does **not** trigger any Social Graph (MyCommunity) mutations. The inviter and joiner are not automatically added as friends. This is a deliberate architectural decision to keep layers decoupled.

---

## Firestore Collections Referenced

| Collection | Access Pattern | SDK |
|-----------|---------------|-----|
| `groups/{groupId}` | Read group data, update memberIds | Admin SDK |
| `groups/{groupId}/invites/{inviteId}` | Create, read, update invites | Admin SDK |
| `invite_tokens/{token}` | Create, read, update token lookups | Admin SDK |
| `users/{userId}` | Read inviter profile (displayName, photoUrl) | Admin SDK |

---

## Function Registration (index.ts)

When implemented in Story 17.3, the functions will be exported from `functions/src/index.ts`:

```typescript
// Epic 17: Invite-Based Onboarding
export { createGroupInvite } from "./createGroupInvite";       // Story 17.3
export { validateInviteToken } from "./validateInviteToken";   // Story 17.3
export { joinGroupViaInvite } from "./joinGroupViaInvite";     // Story 17.3
export { revokeGroupInvite } from "./revokeGroupInvite";       // Story 17.3
```

---

## Testing Requirements (Story 17.3)

When implemented, each function must have:

### Unit Tests

- All validation branches (authenticated, unauthenticated, invalid input)
- All error conditions (not-found, permission-denied, failed-precondition)
- Happy path with expected response shape
- Idempotency for `joinGroupViaInvite` (already member case)

### Integration Tests (Firebase Emulator)

- End-to-end: create invite → validate token → join group
- Revocation flow: create invite → revoke → validate fails
- Expiration: create invite with expiry → wait → validate fails
- Usage limit: create invite with limit → use N times → (N+1)th fails
- Capacity: fill group to max → join via invite fails

---

## Deployment

| Environment | Deploy Rule |
|-------------|------------|
| `playwithme-dev` | Deploy on merge to `main` |
| `playwithme-stg` | Manual deploy after QA validation |
| `playwithme-prod` | Deploy via CI/CD pipeline after staging approval |

---

## Revision History

| Date | Story | Change |
|------|-------|--------|
| 2026-02-12 | 17.2 | Initial contract definition |
