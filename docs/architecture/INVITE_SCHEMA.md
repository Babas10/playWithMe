# Invite Schema — Firestore Data Design

**Epic:** 17 — Invite-Based Onboarding & Deep Link Group Join
**Story:** 17.1 — Design the Firestore Schema for Invites

---

## Overview

This document describes the Firestore data model for **group invite links**. The schema supports:

- Shareable invite links with secure tokens
- Optional expiration timestamps
- Manual revocation
- Optional usage limits
- Efficient O(1) token lookup via a secondary collection

---

## Collections

### 1. Primary: `groups/{groupId}/invites/{inviteId}`

Stores invite metadata as a subcollection of the group it belongs to.

| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| `inviteId` | `string` | Yes | auto-generated | Document ID |
| `token` | `string` | Yes | — | Secure random string (URL-safe, 32+ chars) |
| `createdBy` | `string` | Yes | — | User ID of the invite creator |
| `createdAt` | `timestamp` | Yes | — | Server timestamp when invite was created |
| `expiresAt` | `timestamp` | No | `null` | Expiration timestamp (`null` = never expires) |
| `revoked` | `boolean` | Yes | `false` | Whether the invite has been manually revoked |
| `usageLimit` | `int` | No | `null` | Maximum number of uses (`null` = unlimited) |
| `usageCount` | `int` | Yes | `0` | Number of times the invite has been used |
| `groupId` | `string` | Yes | — | Redundant group ID for cross-reference safety |
| `inviteType` | `string` | Yes | `"group_link"` | Type discriminator for future invite types |

### 2. Token Lookup: `invite_tokens/{token}`

Enables O(1) token lookup without scanning all groups' invite subcollections.

| Field | Type | Description |
|-------|------|-------------|
| `groupId` | `string` | The group this token belongs to |
| `inviteId` | `string` | The invite document ID |
| `createdAt` | `timestamp` | When the token was created |
| `active` | `boolean` | Quick check if token is still valid |

---

## Design Decisions

### Subcollection vs Root Collection

Using `groups/{groupId}/invites/` keeps invites scoped to their group:

- Efficient group-level queries (list all invites for a group)
- Natural security rule inheritance (group membership check)
- Avoids a single large root collection

### Token Lookup Collection

The `invite_tokens/` root collection is necessary because deep link resolution receives only the token — not the group ID. Without this secondary collection, resolving a token would require scanning every group's invites subcollection.

### Atomic Writes

Both `invite_tokens/{token}` and `groups/{groupId}/invites/{inviteId}` must be written atomically (batch write or transaction) during invite creation to prevent orphaned records.

### Token Format

Tokens use `crypto.randomBytes(24).toString('base64url')` producing 32 URL-safe characters with 192 bits of entropy. This prevents brute-force guessing while remaining compact for URLs.

---

## Firestore Security Rules

```javascript
// Invite documents: only group members can read, only Cloud Functions can write
match /groups/{groupId}/invites/{inviteId} {
  allow read: if request.auth != null &&
    request.auth.uid in get(/databases/$(database)/documents/groups/$(groupId)).data.memberIds;
  allow write: if false; // Only via Cloud Functions (Admin SDK)
}

// Token lookup: authenticated users can read, only Cloud Functions can write
match /invite_tokens/{token} {
  allow read: if request.auth != null;
  allow write: if false; // Only via Cloud Functions (Admin SDK)
}
```

**Rationale:**

- **Invites read** — restricted to group members so non-members cannot enumerate active invites.
- **Invites write** — all mutations go through Cloud Functions for validation, idempotency, and atomic writes.
- **Token read** — any authenticated user can resolve a token (needed for deep link join flow).
- **Token write** — Cloud Functions only, ensures tokens are created atomically with their invite document.

---

## Required Indexes

| Collection | Fields | Order | Purpose |
|-----------|--------|-------|---------|
| `groups/{groupId}/invites` | `createdBy`, `createdAt` | ASC, DESC | List a user's created invites |
| `groups/{groupId}/invites` | `revoked`, `createdAt` | ASC, DESC | List active (non-revoked) invites |

---

## Flutter Data Model

```dart
@freezed
class GroupInviteLinkModel with _$GroupInviteLinkModel {
  const factory GroupInviteLinkModel({
    required String id,
    required String token,
    required String createdBy,
    @RequiredTimestampConverter() required DateTime createdAt,
    @TimestampConverter() DateTime? expiresAt,
    @Default(false) bool revoked,
    int? usageLimit,
    @Default(0) int usageCount,
    required String groupId,
    @Default('group_link') String inviteType,
  }) = _GroupInviteLinkModel;
}
```

### Business Logic Methods

| Method | Returns | Description |
|--------|---------|-------------|
| `isExpired` | `bool` | `true` if `expiresAt` is non-null and in the past |
| `isRevoked` | `bool` | `true` if `revoked == true` |
| `isUsageLimitReached` | `bool` | `true` if `usageCount >= usageLimit` |
| `isActive` | `bool` | `true` if not expired, not revoked, and limit not reached |
| `remainingUses` | `int?` | `usageLimit - usageCount`, or `null` if unlimited |

---

## File Structure

```
lib/core/data/models/group_invite_link_model.dart           # Freezed model + Firestore conversion
lib/core/data/models/group_invite_link_model.freezed.dart    # Generated
lib/core/data/models/group_invite_link_model.g.dart          # Generated
firestore.rules                                              # Security rules (updated)
docs/architecture/INVITE_SCHEMA.md                           # This document
```

---

## Architectural Compliance

- Belongs to the **Groups layer** only
- No dependency on Games or Social Graph (MyCommunity)
- All write operations go through **Cloud Functions** (Admin SDK)
- Security rules enforce read-only client access
- Designed for millions of invites (scalable subcollection pattern)
