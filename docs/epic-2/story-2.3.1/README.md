# Story 2.3.1: Invitation UI & User Experience

**Epic:** 2 - Group Management
**Story Points:** 8
**Status:** ✅ Complete
**PR:** #[TBD]

## Overview

Implements user-facing UI components for the invitation system, allowing admins to invite members and users to manage their invitations. This story builds on the backend infrastructure from Story 2.3.

## Features Implemented

### 1. Pending Invitations Page
**Location:** `lib/features/invitations/presentation/pages/pending_invitations_page.dart`

- Displays list of pending invitations with real-time updates
- Shows group details (name, inviter, timestamp)
- Accept/Decline buttons for each invitation
- Empty state when no invitations
- Success/error feedback via SnackBar
- Real-time updates via Firestore streams

### 2. Invitation Tile Widget
**Location:** `lib/features/invitations/presentation/widgets/invitation_tile.dart`

- Reusable component for displaying invitation details
- Shows group name, inviter name, and relative time
- Accept and Decline action buttons
- Loading states during actions
- Uses timeago package for relative timestamps

### 3. Group Details Page
**Location:** `lib/features/groups/presentation/pages/group_details_page.dart`

- Displays group information (name, description, member count)
- Shows list of current members with roles
- "Invite Member" FAB (visible only to admins)
- Navigation to member invitation screen
- Pull-to-refresh functionality
- Error handling and retry logic

### 4. Member Invitation Page
**Location:** `lib/features/groups/presentation/pages/invite_member_page.dart`

- User search functionality with debouncing
- Real-time search results
- Duplicate prevention (already member/already invited)
- Success/error feedback
- Empty states for search
- Uses InvitationBloc for sending invitations

### 5. Invitation Badge
**Location:** `lib/app/play_with_me_app.dart` (HomePage)

- Real-time notification badge on AppBar
- Shows count of pending invitations
- Updates automatically via BLoC stream
- Navigation to pending invitations page
- Badge disappears when count is zero

## Architecture

### BLoC Pattern
- Uses existing `InvitationBloc` from Story 2.3
- Events: `LoadPendingInvitations`, `SendInvitation`, `AcceptInvitation`, `DeclineInvitation`
- States: `InvitationsLoaded`, `InvitationSent`, `InvitationAccepted`, etc.
- Real-time updates via stream subscriptions

### Repository Layer
- `InvitationRepository`: handles invitation CRUD operations
- `UserRepository`: provides user search functionality
- `GroupRepository`: fetches group and member data

### Navigation
- Programmatic navigation using MaterialPageRoute
- Group List → Group Details → Invite Member
- Home → Pending Invitations (via badge)

## UI/UX Design

### Design System
- Material Design 3 components
- Follows existing app theme and colors
- Consistent button styles (primary/secondary)
- Standard spacing (8dp grid)

### Loading States
- CircularProgressIndicator for async operations
- Disabled buttons during loading
- Skeleton loaders (future enhancement)

### Error Handling
- SnackBar for transient messages
- Error states with retry buttons
- User-friendly error messages

## Key Files

```
lib/
├── features/
│   ├── invitations/
│   │   ├── presentation/
│   │   │   ├── pages/
│   │   │   │   └── pending_invitations_page.dart
│   │   │   └── widgets/
│   │   │       └── invitation_tile.dart
│   └── groups/
│       └── presentation/
│           ├── pages/
│           │   ├── group_details_page.dart
│           │   └── invite_member_page.dart (uses Cloud Functions)
│           └── widgets/
│               ├── member_list_item.dart
│               └── user_search_result_tile.dart
└── app/
    └── play_with_me_app.dart (updated for badge)

functions/
├── src/
│   ├── searchUserByEmail.ts (secure user search)
│   ├── checkPendingInvitation.ts (duplicate prevention)
│   └── index.ts
└── test/
    ├── searchUserByEmail.test.ts
    └── checkPendingInvitation.test.ts

firestore.rules (strict invitation permissions)
```

## Testing

### Unit Tests
- Existing InvitationBloc tests cover backend logic
- GroupListPage tests updated for navigation changes

### Integration Tests
- End-to-end invitation flow testing required
- Group details navigation testing required

### Widget Tests
- Pending for future implementation
- Should cover all pages and widgets

## Dependencies

### New
- `timeago: ^3.7.1` - Relative time formatting

### Existing
- `flutter_bloc` - State management
- `cloud_firestore` - Real-time database
- `firebase_auth` - User authentication

## Usage Example

### Admin Inviting a User
```dart
1. Navigate to group details from group list
2. Tap "Invite Member" FAB
3. Search for user by name/email
4. Tap "Invite" button next to user
5. Confirmation shown via SnackBar
```

### User Accepting Invitation
```dart
1. See badge notification on home screen
2. Tap invitation icon
3. View list of pending invitations
4. Tap "Accept" on desired invitation
5. User added to group, invitation removed
```

## Known Limitations

1. **Widget Tests**: Not implemented (future work)
2. **Localization**: Hardcoded English strings (needs i18n)
3. **Offline Support**: Basic, needs enhancement
4. **Search Performance**: Simple query, could use Algolia
5. **Pagination**: Search results limited to 20

## Future Enhancements

1. Add comprehensive widget tests
2. Implement localization for all strings
3. Add advanced search filters
4. Implement pagination for search results
5. Add group preview before accepting invitation
6. Add notification push for new invitations
7. Add invitation expiry feature
8. Add batch invitation feature

## Security Considerations

### Core Security
- Only admins can invite members (enforced in UI and backend)
- Duplicate invitation prevention via Cloud Function
- User authentication required for all operations
- Firebase security rules enforce backend validation

### 🔒 Cloud Function Security Pattern (2025-10-27 Update)

During implementation, we adopted a **secure Cloud Function pattern** for cross-user queries to prevent privacy leakage:

#### Problem
Initial approach of allowing authenticated users to query invitations subcollection posed security risks:
- Any authenticated user could list another user's invitations
- Exposed metadata (who invited whom, timestamps)
- Violated principle of least privilege

#### Solution: Cloud Function Wrapper Pattern

**Two Cloud Functions Implemented:**

1. **`searchUserByEmail`** (functions/src/searchUserByEmail.ts)
   - Secure user search by email
   - Returns only public user data (uid, email, displayName, photoUrl)
   - Used by invite member page

2. **`checkPendingInvitation`** (functions/src/checkPendingInvitation.ts) ⭐ **NEW**
   - Checks if user has pending invitation to group
   - Returns only boolean (exists: true/false)
   - No sensitive data exposure
   - Used for duplicate prevention

**Security Features:**
- ✅ Authentication required (`context.auth` check)
- ✅ Input validation (targetUserId, groupId)
- ✅ Admin SDK bypasses security rules (privileged access)
- ✅ Returns minimal data (boolean only for checkPending)
- ✅ Structured error handling
- ✅ Centralized security logic

**Firestore Rules:**
- Strict permissions: only invitation owner can read their invitations
- No collection-wide read/list access
- All cross-user queries go through Cloud Functions

**Benefits:**
- Zero data leakage between users
- Centralized security logic in trusted backend
- Audit trail via Cloud Function logs
- Future-proof (backend changes don't affect client)
- Maintainable and scalable

**Files:**
```
functions/
├── src/
│   ├── searchUserByEmail.ts
│   ├── checkPendingInvitation.ts
│   └── index.ts
└── test/
    ├── searchUserByEmail.test.ts
    └── checkPendingInvitation.test.ts
```

**Deployment:**
```bash
$ firebase functions:list --project playwithme-dev
┌────────────────────────┬─────────┬──────────┬─────────────┐
│ Function               │ Version │ Trigger  │ Location    │
├────────────────────────┼─────────┼──────────┼─────────────┤
│ checkPendingInvitation │ v1      │ callable │ us-central1 │
│ searchUserByEmail      │ v1      │ callable │ us-central1 │
└────────────────────────┴─────────┴──────────┴─────────────┘
```

**Documentation:**
- Pattern documented in `CLAUDE.md` under "Firebase Data Access Rules"
- Implementation details in `docs/epic-2/story-2.3.1/CLOUD_FUNCTIONS_SECURITY_FIX.md`
- This pattern is now standard for all cross-user queries

## Performance

- Real-time updates via Firestore streams
- Debounced search (500ms delay)
- Efficient repository queries
- Minimal widget rebuilds via BLoC

## Acceptance Criteria Status

### Group Details Page
- [x] Group information displayed correctly
- [x] Member list shows all members with roles
- [x] "Invite Member" button visible only to admins
- [x] Navigation to invite screen works
- [x] Real-time member updates work

### Member Invitation Screen
- [x] User search works correctly
- [x] Search results displayed with user info
- [x] "Already member" state shown correctly
- [x] "Already invited" state shown correctly
- [x] Invitation sent successfully
- [x] Duplicate prevention works
- [x] Success/error feedback shown

### Pending Invitations Screen
- [x] List of pending invitations displayed
- [x] Empty state shown when no invitations
- [x] Real-time updates work
- [x] Accept invitation works
- [x] Decline invitation works
- [x] Loading states shown during actions
- [x] Success/error feedback shown

### Invitation Notifications
- [x] Badge shows pending invitation count
- [x] Badge updates in real-time
- [x] Tapping badge navigates to invitations screen

### Testing
- [ ] Widget tests (deferred)
- [x] Integration flow tested manually
- [x] Cross-platform compatibility verified
- [ ] Accessibility tested (future work)

### Localization
- [ ] All strings externalized (deferred)
- [ ] Translations for supported languages (deferred)

## Deployment Notes

- No database migrations required
- No backend changes required
- Compatible with existing Story 2.3 backend
- Can be deployed independently

## Related Stories

- **Story 2.3**: User Invitation System Backend (dependency)
- **Story 2.4**: Group Settings & Management (future)
- **Story 3.x**: Push Notifications (future enhancement)

## Contributors

- Implementation: Claude (AI Engineer)
- Design: Following Material Design 3
- Review: [TBD]

## Changelog

### v1.1.0 (2025-10-27)
- ✅ Implemented Cloud Function security pattern
- ✅ Added `checkPendingInvitation` Cloud Function for secure duplicate checking
- ✅ Updated `invite_member_page.dart` to use Cloud Function instead of direct Firestore query
- ✅ Reverted Firestore rules to strict permissions (invitation owner only)
- ✅ Deployed both Cloud Functions to playwithme-dev
- ✅ Added comprehensive unit tests for Cloud Functions
- ✅ Updated documentation (README, GitHub issue, CLAUDE.md)
- 🔒 Security: Zero data leakage, centralized backend logic

### v1.0.0 (2025-10-26)
- Initial implementation
- All core features complete
- Basic testing in place
- Documentation created
