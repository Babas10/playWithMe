# Story 17.8.4 — Scheduled Cloud Functions for Account Cleanup

**Epic:** 17 — Invite-Based Onboarding & Deep Link Group Join
**Parent:** Story 17.8 (Account Status Enforcement)
**Issue:** #481

---

## Overview

Two scheduled Cloud Functions that automate account status enforcement:

1. **`updateAccountStatuses`** — Transitions expired grace-period accounts from `pendingVerification` to `restricted`
2. **`cleanupUnverifiedAccounts`** — Deletes accounts past the 30-day deadline

Both functions run daily via Cloud Scheduler and are deployed in **dry-run mode** by default.

---

## Functions

### updateAccountStatuses

**Schedule:** Every 24 hours
**File:** `functions/src/scheduled/updateAccountStatuses.ts`

**Logic:**
1. Queries users where `accountStatus == 'pendingVerification'`, `emailVerifiedAt == null`, and `gracePeriodExpiresAt < now`
2. Updates `accountStatus` to `'restricted'`
3. Sets `deletionScheduledAt` to 30 days from `createdAt`
4. Processes up to 500 accounts per run (batch write)
5. Logs each transition for audit

### cleanupUnverifiedAccounts

**Schedule:** Every 24 hours
**File:** `functions/src/scheduled/cleanupUnverifiedAccounts.ts`

**Logic:**
1. Queries users where `accountStatus == 'scheduledForDeletion'` and `deletionScheduledAt < now`
2. For each user:
   - Removes from all groups (`memberIds`, `adminIds`)
   - Cancels pending invitations
   - Updates friendships to `'declined'` (audit trail)
   - Deletes user Firestore document
   - Deletes Firebase Auth account
3. Processes up to 500 accounts per run
4. Continues processing on per-user errors (no single failure blocks the batch)
5. Logs each operation for audit

**Dry-Run Mode:**
- Controlled by `DRY_RUN` constant (default: `true`)
- When enabled, logs what _would_ be deleted without performing any writes
- Must be changed to `false` and redeployed to enable live deletion
- Recommended rollout: dev → staging → production

---

## File Structure

```
functions/src/scheduled/
├── index.ts                        # Re-exports both functions
├── updateAccountStatuses.ts        # Grace period → restricted transition
└── cleanupUnverifiedAccounts.ts    # Account deletion after 30 days

functions/test/unit/scheduled/
├── updateAccountStatuses.test.ts   # 7 unit tests
└── cleanupUnverifiedAccounts.test.ts  # 7 unit tests
```

---

## Deployment

Both functions are deployed to all 3 environments in dry-run mode:
- `gatherli-dev`
- `gatherli-stg`
- `gatherli-prod`

To enable live mode, change `DRY_RUN = false` in `cleanupUnverifiedAccounts.ts` and redeploy.

---

## Testing

14 unit tests covering:
- Empty query scenarios (no accounts to process)
- Correct Firestore query filters
- Batch processing of multiple accounts
- Deletion date computation (30 days from `createdAt`)
- Batch size limit (500)
- Error handling (per-user and top-level)
- Structured logging verification
- Dry-run mode behavior (no writes performed)
