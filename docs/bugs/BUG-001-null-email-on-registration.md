# BUG-001 — Null Email on New User Registration

| Field | Value |
|-------|-------|
| **ID** | BUG-001 |
| **Severity** | High |
| **Status** | Fixed (PR #718) |
| **Discovered** | 2026-04-10 |
| **Fixed** | 2026-04-10 |
| **Affected users** | 2 production users |
| **Environment** | Production (`gatherli-prod`) |

---

## Symptom

After accepting a friend request, all friends disappeared from the **My Community** screen. The same crash occurred when trying to invite someone to a group:

> `Failed to get friends: Type Null is not a subtype of type 'String' in type cast`

The friends list appeared completely empty even though the friendships existed correctly in Firestore.

---

## Root Cause

A **race condition** between two Cloud Functions during user registration:

1. The Flutter app creates the Firebase Auth account, then immediately calls the `updateUserNames` callable function to persist `firstName`, `lastName`, and `gender`.
2. Simultaneously, Firebase fires the `createUserDocument` Auth `onCreate` trigger.

**When `updateUserNames` wins the race** (faster cold start or faster network path):
- It creates the Firestore user document via `set({merge: true})` with `{firstName, lastName, displayName}` — **no `email` field**.
- When `createUserDocument` fires shortly after, it finds the document already exists and returns early due to its idempotency check (line 33–38 of `createUserDocument.ts`).
- The `email` field is **never written** to the user document.

```
updateUserNames callable         createUserDocument trigger
        │                                   │
        │  set(merge:true)                  │
        │  {firstName, lastName}            │
        │  ← no email field                 │  fires after Auth account created
        ▼                                   ▼
   doc created (no email)         doc already exists → return early
                                       email never patched ❌
```

**When `createUserDocument` wins the race** (the normal case):
- It creates the document with `email: user.email` first.
- `updateUserNames` then merges on top, preserving the existing `email` field.
- Everything works correctly ✅

---

## Confirmed via Logs

Cloud Function logs for the 2 affected users showed:

```
"message": "User document already exists for RQThGNXg1IbwbMV3zJUu6VfVJOl1, skipping creation"
"message": "User document already exists for fsJvi9QoioTqxBV5nys6kx4FOYD2, skipping creation"
```

Both had `email: undefined` in their Firestore documents at the time of the fix.

---

## Secondary Symptom: Crash in Flutter

The `getFriends` Cloud Function returned these users' data with `email: null`. The Flutter parser in `firestore_friend_repository.dart` cast it directly:

```dart
email: friendData['email'] as String,  // ❌ crashes when email is null
```

The `_safeCall` wrapper in `FriendBloc` silently swallowed the `TypeError`, returning an empty list — making the entire friends list disappear with no visible error.

---

## Fix

### 1. `functions/src/updateUserNames.ts`
Include `email` from the authenticated token on every write, so the document is always complete regardless of execution order:

```typescript
const update: Record<string, unknown> = {
  firstName: trimmedFirstName,
  lastName: trimmedLastName,
  displayName: `${trimmedFirstName} ${trimmedLastName}`,
  email: context.auth.token.email || "",   // ← added
  updatedAt: admin.firestore.FieldValue.serverTimestamp(),
};
```

### 2. `functions/src/createUserDocument.ts`
When the document already exists, check if `email` is missing and patch it from the Auth user object instead of always returning early:

```typescript
const existingDoc = await userRef.get();
if (existingDoc.exists) {
  const existingEmail = existingDoc.data()?.email;
  if (!existingEmail && user.email) {
    await userRef.update({ email: user.email });  // ← patch missing email
  }
  return;
}
```

### 3. `lib/core/data/repositories/firestore_friend_repository.dart`
Safe-cast `email` in the `getFriends` and `searchUserByEmail` parsers to prevent a crash if a null email exists in any historical document:

```dart
// Before
email: friendData['email'] as String,

// After
email: friendData['email'] as String? ?? '',
```

---

## Data Remediation

The 2 affected production users were patched directly via Admin SDK on 2026-04-10:

| UID | Email patched |
|-----|--------------|
| `RQThGNXg1IbwbMV3zJUu6VfVJOl1` | geokyrpapa@gmail.com |
| `fsJvi9QoioTqxBV5nys6kx4FOYD2` | ivoteixeira37@yahoo.com.br |

Both had `email: undefined` confirmed in Firestore before the patch.

---

## Prevention

- **Primary**: `updateUserNames` now always writes `email`, so the race condition has no harmful outcome regardless of which function runs first.
- **Defensive fallback**: `createUserDocument` patches `email` if it finds an existing document with a missing email.
- **Client resilience**: The Flutter parsers now use safe casts for `email` so that historical documents with null email cannot crash the app.

---

## Related Files

- `functions/src/updateUserNames.ts`
- `functions/src/createUserDocument.ts`
- `lib/core/data/repositories/firestore_friend_repository.dart`
- PR: [#718](https://github.com/Babas10/gatherli/pull/718)
