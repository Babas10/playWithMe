# Story 11.4 — Data Reset & Friendship Validation

## Overview

This document describes the data reset performed as part of Story 11.4 to enable clean implementation of mandatory friendship validation for group invitations.

## Why Reset Instead of Migration?

We chose a **clean reset** approach over backward compatibility migration for several strategic reasons:

| Benefit | Description |
|---------|-------------|
| ✅ **Cleaner Implementation** | No complex backward compatibility code cluttering the codebase |
| ✅ **Simpler Logic** | No migration date checks or conditional branching |
| ✅ **Fresh Architecture** | Start with proper friendship validation from day one |
| ✅ **Minimal Data Loss** | Very little existing production data to preserve |
| ✅ **Faster Development** | No grandfathering logic or edge case handling |
| ✅ **Lower Technical Debt** | No legacy code paths to maintain long-term |

## What Was Reset

The reset script deleted:

1. **Friendships Collection**: All friendship documents
2. **Groups Collection**: All group documents
3. **Users Collection**: All user documents (including invitations subcollection)
4. **Firebase Authentication**: Optional (users can re-register with same email)

## Reset Script

Location: `functions/scripts/reset-data.ts`

### Safety Features

- ✅ **Environment Check**: Only runs on `playwithme-dev`
- ✅ **Explicit Warning**: Shows clear warning before execution
- ✅ **Progress Logging**: Reports deletion counts for each collection
- ✅ **Error Handling**: Catches and reports errors gracefully

### Usage

```bash
cd functions
npx ts-node scripts/reset-data.ts
```

### Expected Output

```
⚠️  WARNING: You are about to delete ALL data from playwithme-dev
   This operation cannot be undone!

🗑️  Starting data reset for playwithme-dev...

📋 Deleting friendships collection...
✅ Deleted 15 friendship documents

📋 Deleting groups collection...
✅ Deleted 8 group documents

📋 Deleting users collection...
✅ Deleted 12 user documents (including subcollections)

✅ Data reset complete!

📝 Next steps:
   1. Register 3-5 test users via the app
   2. Have them send friend requests to each other
   3. Accept friend requests
   4. Create test groups
   5. Verify friendship validation works

🎉 Script completed successfully
```

## Post-Reset Setup

After running the reset script, follow these steps to create a clean test dataset:

### 1. Register Test Users

Create 3-5 test users via the app:
- `user1@test.com`
- `user2@test.com`
- `user3@test.com`
- `user4@test.com`
- `user5@test.com`

### 2. Establish Friendships

Have users send and accept friend requests:

```
user1 ←→ user2 (friends)
user1 ←→ user3 (friends)
user2 ←→ user3 (friends)
user2 ←→ user4 (friends)
user3 ←→ user5 (friends)
```

### 3. Create Test Groups

Create 2-3 test groups:
- **Beach Volleyball**: user1 (admin), user2, user3
- **Saturday Games**: user2 (admin), user3, user4
- **Weekend Warriors**: user3 (admin), user5

### 4. Verify Friendship Validation

Test the new friendship requirement:

**✅ Should Work:**
- user1 invites user2 to "Beach Volleyball" → ✅ (they're friends)
- user2 accepts invitation → ✅

**❌ Should Fail:**
- user1 tries to invite user4 → ❌ (not friends yet)
- Error: "You can only accept invitations from friends"

## Changes Implemented

### 1. `checkFriendship` Helper Function

Location: `functions/src/friendships.ts`

```typescript
export async function checkFriendship(
  userAId: string,
  userBId: string
): Promise<boolean>
```

**Features:**
- Uses cached `friendIds` from Story 11.6 for O(1) lookup
- Validates bidirectional friendship
- Fails closed (returns `false` on error)
- Comprehensive error logging

### 2. `acceptInvitation` Updated

Location: `functions/src/acceptInvitation.ts`

**Changes:**
- ✅ Always validates friendship (no exceptions)
- ✅ Clear, user-friendly error messages
- ✅ No backward compatibility code
- ✅ No migration date checks

**New Logic:**
```typescript
// Story 11.4: Always validate friendship (no backward compatibility)
const inviterId = invitationData.invitedBy;
const areFriends = await checkFriendship(inviterId, userId);

if (!areFriends) {
  throw new functions.https.HttpsError(
    "permission-denied",
    "You can only accept invitations from friends. Please add them as a friend first."
  );
}
```

## Testing Strategy

### Manual Testing Checklist

- [ ] Reset script runs successfully on dev
- [ ] Can register new users
- [ ] Can send friend requests
- [ ] Can accept friend requests
- [ ] Can create groups
- [ ] Cannot invite non-friends ❌
- [ ] Can invite friends ✅
- [ ] Cannot accept invitation from non-friend ❌
- [ ] Can accept invitation from friend ✅
- [ ] Error messages are clear and actionable

### Automated Testing

Unit tests cover:
- ✅ `checkFriendship` returns `true` for friends
- ✅ `checkFriendship` returns `false` for non-friends
- ✅ `acceptInvitation` rejects non-friend invitations
- ✅ `acceptInvitation` accepts friend invitations
- ✅ Error messages are user-friendly

See: `test/unit/functions/friendship-validation_test.dart`

## Deployment Strategy

### Staged Rollout

| Environment | Action | Timeline |
|-------------|--------|----------|
| **Dev** | Run reset script → Deploy functions | Week 1 |
| **Staging** | Run reset script → Deploy functions → Full QA | Week 2 |
| **Production** | Run reset script → Deploy functions → Monitor | Week 3 |

### Pre-Deployment Checklist

**Dev Environment:**
- [ ] Run reset script
- [ ] Deploy Cloud Functions
- [ ] Create test users
- [ ] Verify friendship validation
- [ ] Run automated tests

**Staging Environment:**
- [ ] Announce to internal testers
- [ ] Run reset script
- [ ] Deploy Cloud Functions
- [ ] Internal team testing
- [ ] Document any issues

**Production Environment:**
- [ ] Final stakeholder approval
- [ ] Run reset script during low-traffic window
- [ ] Deploy Cloud Functions
- [ ] Monitor error rates
- [ ] Have rollback plan ready

## Rollback Plan

If issues arise post-deployment:

### Option 1: Quick Fix
If friendship validation has bugs:
1. Deploy hotfix to `checkFriendship` function
2. No data changes needed

### Option 2: Temporary Disable
If critical issues occur:
1. Comment out friendship check in `acceptInvitation`
2. Deploy emergency patch
3. Re-enable after fix

### Option 3: Full Rollback
If fundamental issues found:
1. Revert Cloud Functions to previous version
2. Data cannot be un-deleted (reset is permanent)
3. Would need to recreate test data manually

**Note**: Full rollback is not ideal since data has been deleted.

## Monitoring & Observability

Post-deployment, monitor these metrics:

### Key Metrics
- Invitation acceptance success rate
- `permission-denied` error rate for invitations
- Friend request acceptance rate
- Time to first group creation

### Cloud Function Logs

Monitor for:
```
Error checking friendship
```
```
You can only accept invitations from friends
```

### Expected Behavior

**Healthy System:**
- Low `permission-denied` errors (users understand friendship requirement)
- High friend request→acceptance rate
- Smooth invitation flow

**Potential Issues:**
- Spike in `permission-denied` errors (users trying to invite non-friends)
- Users confused about friendship requirement (check error message clarity)

## FAQ

### Q: Can we restore deleted data?
**A:** No. The reset is permanent. This is why we only reset dev/staging first.

### Q: What if users had important group data?
**A:** In dev/staging, minimal important data exists. In production, we'd announce the reset in advance and provide data export if needed (not applicable for this early-stage project).

### Q: Can we skip friendship validation for admins?
**A:** No. The requirement is universal for simplicity and consistency. All users must be friends to invite.

### Q: What about existing invitations after reset?
**A:** All invitations are deleted. Users start fresh with new groups and invitations.

### Q: Can invitation sender and recipient not be friends?
**A:** No. After Story 11.4, invitations require friendship. This is enforced in `acceptInvitation`.

## Architecture Alignment

This reset strategy aligns with our architectural principles:

**From CLAUDE.md:**
- ✅ **Security First**: Friendship validation prevents spam invitations
- ✅ **Zero Warnings**: Clean implementation without legacy code
- ✅ **Single Responsibility**: `checkFriendship` does one thing well
- ✅ **DRY Principle**: Reusable helper function for friendship checks
- ✅ **Full Coverage**: Comprehensive testing of validation logic

**Social Graph Design:**
```
Users → My Community (Friendships) → Groups → Games
```

Groups now properly query the social graph to validate invitations. This enforces the layered architecture where groups depend on the friendship layer.

## Future Enhancements

Potential improvements (not in scope for Story 11.4):

1. **Friendship Suggestions**: Suggest friends based on group memberships
2. **Batch Invitations**: Invite multiple friends at once
3. **Invitation Templates**: Pre-fill invitations with group details
4. **Invitation Reminders**: Notify users of pending invitations
5. **Group Discovery**: Find public groups without invitation

## Related Documentation

- [Epic 11: My Community Social Graph](./SCHEMA.md)
- [Story 11.6: Performance Optimization](./PERFORMANCE_OPTIMIZATION.md)
- [Security Rules](./SECURITY_RULES.md)
- [Cloud Function Standards](../../CLAUDE.md#-11-cloud-functions-development-standards)

## Changelog

| Date | Version | Change |
|------|---------|--------|
| 2025-01-10 | 1.0 | Initial reset guide (Story 11.4) |
