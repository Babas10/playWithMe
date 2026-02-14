# Story 17.8.3 — Feature Restriction Logic

## Overview

This story implements feature restrictions for users whose accounts are in the `restricted` status (7-30 days after creation, email not verified).

## Architecture

### UI Components

#### RestrictedModeBanner (`lib/core/presentation/widgets/restricted_mode_banner.dart`)
- Red banner shown at the top of the app for restricted users
- Displays account restriction message with days until deletion countdown
- Contains a "Verify Email" button to trigger email verification
- Integrated in `play_with_me_app.dart` alongside the existing `EmailVerificationBanner`

#### RestrictedActionGuard (`lib/core/presentation/widgets/restricted_action_guard.dart`)
- Static utility class that checks account status before allowing actions
- `isActionAllowed(state)` — returns `true` for Active, Pending, or Loading states
- `check(context, onAllowed, onVerifyEmail)` — either executes the action or shows a restriction dialog
- Dialog explains the restriction and offers email verification

### Feature Restrictions

| Feature | Allowed in Restricted Mode |
|---------|---------------------------|
| View profile | Yes |
| Edit profile | Yes |
| View groups | Yes |
| Create games | No |
| RSVP to games | No |
| Enter results | No |
| Create groups | No |
| Send invites | No |
| Send friend requests | No |

### Usage

UI components that trigger restricted actions should wrap their callbacks:

```dart
RestrictedActionGuard.check(
  context: context,
  onAllowed: () {
    // Proceed with the action (e.g., create game, send friend request)
  },
  onVerifyEmail: () {
    context.read<EmailVerificationBloc>().add(
      const EmailVerificationEvent.sendVerificationEmail(),
    );
  },
);
```

## Localization

New strings added to all 5 ARB files (EN, FR, DE, ES, IT):
- `accountDeletionWarning` — "Account will be deleted in {daysRemaining} days."
- `featureRestricted` — "This feature requires email verification."
- `verifyToUnlock` — "Verify your email to use this feature."
- `featureRestrictedTitle` — "Feature Restricted"
- `verifyEmail` — "Verify Email"

## Tests

- `test/widget/core/presentation/widgets/restricted_mode_banner_test.dart` — 9 tests
- `test/widget/core/presentation/widgets/restricted_action_guard_test.dart` — 14 tests (4 unit + 10 widget)

## Dependencies

- **Depends on:** Story 17.8.2 (Account Status Schema) — provides `AccountStatusBloc` and states
- **Depends on:** Story 17.8.1 (Email Verification Banner) — provides `EmailVerificationBloc`
