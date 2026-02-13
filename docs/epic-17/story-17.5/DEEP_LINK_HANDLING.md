# Story 17.5 — Deep Link Handling in Flutter

## Overview

Implements deep link handling for invite links using native App Links (Android) and Universal Links (iOS). Firebase Dynamic Links is deprecated (August 2025), so this uses the `app_links` package instead.

## Architecture

### Link Format
```
https://playwithme.app/invite/{token}
playwithme://invite/{token}  (fallback custom scheme)
```

### Components

| Component | Location | Purpose |
|-----------|----------|---------|
| `DeepLinkService` | `lib/core/services/deep_link_service.dart` | Abstract interface for deep link handling |
| `AppLinksDeepLinkService` | `lib/core/services/app_links_deep_link_service.dart` | Implementation using `app_links` package |
| `PendingInviteStorage` | `lib/core/services/pending_invite_storage.dart` | SharedPreferences storage for pending tokens |
| `DeepLinkBloc` | `lib/core/presentation/bloc/deep_link/` | BLoC managing deep link state |
| `RouteGenerator` | `lib/app/route_generator.dart` | Centralized route generation with deep link support |

### Data Flow

```
Deep Link URL → AppLinksDeepLinkService → DeepLinkBloc → PendingInviteStorage
                                                ↓
                                        UI (Auth check)
                                                ↓
                              Authenticated: process invite (Story 17.6)
                              Unauthenticated: store token → auth flow
```

### Link Handling Scenarios

| Scenario | Behavior |
|----------|----------|
| Cold start with deep link | `getInitialInviteToken()` extracts token → stored → BLoC emits `DeepLinkPendingInvite` |
| Foreground deep link | `inviteTokenStream` emits token → BLoC stores and emits |
| App restart with stored token | `PendingInviteStorage.retrieve()` returns token → BLoC emits pending state |
| After invite processed | `ClearPendingInvite` event → storage cleared → `DeepLinkNoInvite` state |

## Routing Refactor

Replaced `routes:` map with `onGenerateRoute` in `play_with_me_app.dart`:

- All existing routes preserved (`/login`, `/register`, `/forgot-password`, `/my-community`)
- Deep link routes handled (`/invite/{token}`)
- Unknown routes show localized "Page Not Found" page

## Platform Configuration

### Android
- Intent filter for `https://playwithme.app/invite/*` with `autoVerify=true`
- Custom URL scheme fallback: `playwithme://invite/*`
- Digital Asset Links file (`assetlinks.json`) needs deployment to web host

### iOS
- Associated Domains entitlement: `applinks:playwithme.app`
- Custom URL scheme: `playwithme`
- Apple App Site Association file needs deployment to web host

## Testing

- **Unit tests**: `PendingInviteStorage` (4 tests), `DeepLinkBloc` (7 tests), `RouteGenerator` (9 tests)
- **Integration tests**: Deep link flow with Firebase Emulator (deferred to Story 17.6+)

## Dependencies

- `app_links: ^6.4.0` — Native App Links / Universal Links handling

## What's Next

- **Story 17.6**: Auth routing — process pending invite after authentication
- **Story 17.7**: Account creation with invite context
- **Story 17.11**: Deferred deep linking evaluation (Branch.io)
