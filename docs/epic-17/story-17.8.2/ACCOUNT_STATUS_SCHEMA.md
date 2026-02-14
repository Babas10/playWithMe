# Story 17.8.2 — Account Status Model & Firestore Schema

## Overview

This document describes the account status data model, Firestore schema additions, and migration plan for enforcing email verification grace periods.

## AccountStatus Enum

```dart
enum AccountStatus {
  active,               // Email verified OR within 7-day grace period
  pendingVerification,  // Within 7-day grace period, email not verified
  restricted,           // Past 7 days, email not verified
  scheduledForDeletion, // Past 30 days, email not verified
}
```

## Firestore Schema (`users/{userId}`)

### New Fields

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `emailVerifiedAt` | `timestamp?` | `null` | When email was verified (null if not verified) |
| `accountStatus` | `string` | `"pendingVerification"` | Current account status enum value |
| `gracePeriodExpiresAt` | `timestamp` | 7 days after creation | When the 7-day grace period expires |
| `deletionScheduledAt` | `timestamp?` | `null` | 30 days after creation (set when restricted) |

### Existing Fields Used

| Field | Type | Description |
|-------|------|-------------|
| `createdAt` | `timestamp` | When account was created (serves as `accountCreatedAt`) |
| `isEmailVerified` | `boolean` | Whether email has been verified |

## Grace Period Timeline

| Period | Duration | `accountStatus` | Behavior |
|--------|----------|-----------------|----------|
| Active | 0-7 days | `pendingVerification` | Full access. Warning banner shown. |
| Restricted | 7-30 days | `restricted` | Limited access. Only profile, settings, group viewing. |
| Deletion | 30+ days | `scheduledForDeletion` | Account deleted by scheduled Cloud Function. |
| Verified | Any time | `active` | Full access. No restrictions. |

## Status Computation

The `computeAccountStatus()` function in `lib/core/domain/entities/account_status.dart` computes the status purely from:
- `isEmailVerified` (boolean)
- `accountCreatedAt` (DateTime)

This allows both client-side computation and server-side enforcement via Cloud Functions.

## Cloud Function Changes

### `createUserDocument` (Auth onCreate trigger)

Updated to set new fields when a user account is created:

```typescript
emailVerifiedAt: isVerified ? serverTimestamp() : null,
accountStatus: isVerified ? "active" : "pendingVerification",
gracePeriodExpiresAt: Timestamp.fromDate(now + 7 days),
deletionScheduledAt: null,
```

## Migration Plan for Existing Users

### Strategy: Lazy Migration + Backfill Script

**Phase 1: Lazy Migration (Immediate)**
- New `UserModel` fields have safe defaults (`accountStatus: pendingVerification`, others: `null`)
- Existing users without these fields will get defaults when their document is read
- The `AccountStatusBloc` computes status from `isEmailVerified` and `createdAt` regardless of stored `accountStatus`

**Phase 2: Backfill Script (Before Story 17.8.4)**
- Run a one-time Cloud Function to backfill existing user documents:
  - Users with `isEmailVerified: true`: Set `emailVerifiedAt = createdAt`, `accountStatus = "active"`
  - Users with `isEmailVerified: false`: Compute status from `createdAt` and set fields accordingly
  - Set `gracePeriodExpiresAt = createdAt + 7 days` for all users
  - Set `deletionScheduledAt = createdAt + 30 days` for users past 30 days

**Phase 3: Scheduled Functions (Story 17.8.4)**
- Daily Cloud Function to update `accountStatus` based on time elapsed
- Separate function to delete accounts past 30 days

### Backfill Script (To Be Implemented in Story 17.8.4)

```typescript
// backfillAccountStatus.ts (one-time migration)
const usersSnapshot = await admin.firestore().collection('users').get();

for (const doc of usersSnapshot.docs) {
  const data = doc.data();
  const createdAt = data.createdAt?.toDate() || new Date();
  const isVerified = data.isEmailVerified || false;

  const gracePeriodExpiresAt = new Date(createdAt.getTime() + 7 * 24 * 60 * 60 * 1000);

  let accountStatus = 'pendingVerification';
  let emailVerifiedAt = null;
  let deletionScheduledAt = null;

  if (isVerified) {
    accountStatus = 'active';
    emailVerifiedAt = data.createdAt; // Best estimate
  } else {
    const daysSinceCreation = (Date.now() - createdAt.getTime()) / (1000 * 60 * 60 * 24);
    if (daysSinceCreation > 30) {
      accountStatus = 'scheduledForDeletion';
      deletionScheduledAt = new Date(createdAt.getTime() + 30 * 24 * 60 * 60 * 1000);
    } else if (daysSinceCreation > 7) {
      accountStatus = 'restricted';
    }
  }

  await doc.ref.update({
    emailVerifiedAt,
    accountStatus,
    gracePeriodExpiresAt: admin.firestore.Timestamp.fromDate(gracePeriodExpiresAt),
    deletionScheduledAt,
  });
}
```

## File Structure

```
lib/core/domain/entities/account_status.dart          # Enum + computation logic
lib/core/data/models/user_model.dart                   # Freezed model with new fields
lib/core/presentation/bloc/account_status/             # BLoC for status management
  account_status_bloc.dart
  account_status_event.dart
  account_status_state.dart
functions/src/createUserDocument.ts                     # Updated Cloud Function
```

## Testing

- `test/unit/core/domain/entities/account_status_test.dart` — Pure function tests
- `test/unit/core/presentation/bloc/account_status/account_status_bloc_test.dart` — BLoC state tests
- `test/unit/core/data/models/user_model_test.dart` — Serialization tests for new fields
