# Client-Side Analytics Event Catalogue — Story 24.4

All events are logged via `FirebaseAnalytics.logEvent()` from BLoC handlers (never from widgets).
`FirebaseAnalytics` is injected via `get_it`.

## Privacy Rules

- No user IDs, display names, or email addresses in any event parameter.
- Group and game IDs are acceptable (they are non-PII resource identifiers).
- All events fire in release mode; Firebase SDK respects debug/release collection settings.

---

## Events

### `onboarding_completed`

Fires when a user successfully creates an account and reaches `RegistrationSuccess`.

| Property | Value |
|----------|-------|
| **BLoC** | `RegistrationBloc` |
| **Handler** | `_onRegistrationSubmitted` |
| **Trigger** | Account created + email verification sent |
| **Parameters** | none |

```dart
await _analytics.logEvent(name: 'onboarding_completed');
```

**Use case:** Primary activation metric. Measures top-of-funnel conversion from sign-up attempt to completed registration.

---

### `create_game_started`

Fires when a user opens the game creation screen (intent signal, not completion).

| Property | Value |
|----------|-------|
| **BLoC** | `GameCreationBloc` |
| **Handler** | `_onSelectGroup` |
| **Trigger** | `SelectGroup` event dispatched from `GameCreationPage.initState` — only fires from `GameCreationInitial` state |
| **Parameters** | none |

```dart
// Only logs on first SelectGroup from initial state
if (state is GameCreationInitial) {
  await _analytics.logEvent(name: 'create_game_started');
}
```

**Use case:** Funnel analysis. Compare against `game_created` (server-side) to measure form abandonment rate.

---

### `rsvp_screen_opened`

Fires when a user opens the game details / RSVP screen for the first time.

| Property | Value |
|----------|-------|
| **BLoC** | `GameDetailsBloc` |
| **Handler** | `_onGameDetailsUpdated` |
| **Trigger** | First `GameDetailsLoaded` transition (state was `GameDetailsLoading` or `GameDetailsInitial`) |
| **Parameters** | `game_status: String` — one of `scheduled`, `full`, `completed`, `cancelled`, `verification` |

```dart
FirebaseAnalytics.logEvent(
  name: 'rsvp_screen_opened',
  parameters: {'game_status': game.status.name},
)
```

**Use case:** Track engagement with game details. The `game_status` parameter helps identify if users are opening cancelled/completed games (navigation issues) vs active games.

---

### `create_group_started`

Fires when a user opens the group creation screen (intent signal).

| Property | Value |
|----------|-------|
| **BLoC** | `GroupBloc` |
| **Handler** | `_onGroupCreationStarted` |
| **Trigger** | `GroupCreationStarted` event dispatched from `GroupCreationPage.initState` |
| **Parameters** | none |

```dart
await _analytics.logEvent(name: 'create_group_started');
```

**Use case:** Funnel analysis. Compare against `group_created` (server-side) to measure group creation form abandonment.

---

### `invite_link_tapped`

Fires when an invite deep link is received and processed — covers both foreground links and deferred links (app not installed at tap time).

| Property | Value |
|----------|-------|
| **BLoC** | `DeepLinkBloc` |
| **Handlers** | `_onInviteTokenReceived` (foreground link), `_onInitialize` when stored token found (deferred link) |
| **Trigger** | Invite token received via `app_links` or restored from `PendingInviteStorage` |
| **Parameters** | none |

```dart
await _analytics.logEvent(name: 'invite_link_tapped');
```

**Use case:** Measure invite link effectiveness. Compare against `member_joined` (server-side) to calculate invite-to-join conversion rate.

---

## Event Summary Table

| Event | Layer | BLoC | Server-side Counterpart |
|-------|-------|------|------------------------|
| `onboarding_completed` | Client | `RegistrationBloc` | — |
| `create_game_started` | Client | `GameCreationBloc` | `game_created` |
| `rsvp_screen_opened` | Client | `GameDetailsBloc` | — |
| `create_group_started` | Client | `GroupBloc` | `group_created` (via `onInvitationCreated`) |
| `invite_link_tapped` | Client | `DeepLinkBloc` | `invitation_accepted` |

## Related Documentation

- Server-side events: `functions/src/helpers/analytics.ts`
- BigQuery schema: `docs/epic-24/story-24.3/EVENT_SCHEMA.md`
