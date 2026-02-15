# Story 17.9 — Idempotent Group Join Logic

**Epic:** 17 — Invite-Based Onboarding & Deep Link Group Join
**Issue:** #471
**Depends on:** 17.3 (Cloud Functions)

---

## Summary

This story ensures the `joinGroupViaInvite` Cloud Function is fully idempotent: re-clicking an invite link, retrying after a network error, or processing a pending invite twice never produces duplicate membership entries or incorrect state.

---

## Changes Made

### Cloud Function (`functions/src/invites/joinGroupViaInvite.ts`)

**Critical Fix:** Reordered validation checks inside the Firestore transaction to ensure idempotency takes priority over usage limits and capacity checks.

**Previous order (buggy):**
1. Invite exists
2. Invite not revoked
3. Invite not expired
4. **Usage limit check** (could reject already-members)
5. Group exists
6. **Already member check** (too late)
7. Capacity check

**New order (correct):**
1. Invite exists
2. Invite not revoked
3. Invite not expired
4. Group exists
5. **Already member check** (idempotent no-op, returns immediately)
6. Usage limit check (only for new joins)
7. Capacity check (only for new joins)

This ensures an existing group member always receives `{ success: true, alreadyMember: true }` regardless of whether the invite token has reached its usage limit or the group is at capacity.

### Transaction Design

```
Transaction {
  READ inviteDoc, groupDoc

  VALIDATE invite (exists, not revoked, not expired)
  VALIDATE group exists

  IF user already in memberIds → return alreadyMember: true (NO writes)

  VALIDATE usage limit (new joins only)
  VALIDATE capacity (new joins only)

  WRITE: arrayUnion(uid) to group.memberIds
  WRITE: increment(1) to invite.usageCount
  WRITE: serverTimestamp() to group.lastActivity
}
```

### Key Idempotency Properties

| Property | Implementation |
|----------|----------------|
| `arrayUnion` is inherently idempotent | Adding an already-present ID is a Firestore no-op |
| Usage count skipped on re-join | Membership check happens before increment |
| Transaction serialization | Firestore auto-retries prevent duplicate concurrent joins |
| No side effects outside transaction | All writes happen atomically inside the transaction |

---

## Edge Cases Covered

| Scenario | Expected Behavior | Tested |
|----------|-------------------|--------|
| First join (new user, valid token) | User added, usageCount incremented | Yes |
| Second join (same user, same token) | `alreadyMember: true`, no writes | Yes |
| Join after direct add | `alreadyMember: true`, no writes | Yes |
| Already member + usage limit reached | `alreadyMember: true` (NOT error) | Yes |
| Already member + group at capacity | `alreadyMember: true` (NOT error) | Yes |
| New user + usage limit reached | `failed-precondition` error | Yes |
| New user + group at capacity | `failed-precondition` error | Yes |
| Expired token | `failed-precondition` error | Yes |
| Revoked token | `failed-precondition` error | Yes |
| Non-existent token | `not-found` error | Yes |
| Inactive token | `failed-precondition` error | Yes |
| Group deleted | `not-found` error | Yes |

---

## Test Coverage

### Cloud Function Unit Tests (21 tests)
- `functions/test/unit/invites/joinGroupViaInvite.test.ts`
- Covers: authentication, input validation, token validation, transaction logic, idempotency (5 tests), successful join (5 tests), error handling

### Flutter BLoC Unit Tests
- `test/unit/features/invitations/presentation/bloc/invite_join/invite_join_bloc_test.dart`
- Covers: `alreadyMember: true` state handling, error states, pending invite processing

### Flutter UI
- `JoinGroupConfirmationPage` shows "You're already a member" message via `l10n.alreadyAMember` when `alreadyMember: true`

---

## Files Modified

| File | Change |
|------|--------|
| `functions/src/invites/joinGroupViaInvite.ts` | Reordered validation checks for idempotency |
| `functions/test/unit/invites/joinGroupViaInvite.test.ts` | Added 6 new edge case tests |
| `docs/epic-17/story-17.9/IDEMPOTENT_GROUP_JOIN.md` | This documentation |
