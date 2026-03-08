# Story 19.4 — Orchestration: Wire Deferred Deep Links into App Startup

## Overview

Wires the platform-specific deferred token services (Android Story 19.2, iOS Story 19.3) into the app startup sequence so the full deferred deep link flow works end-to-end.

**Depends on:** Story 19.2 (Android service), Story 19.3 (iOS service)

## How It Works

```
App launched for first time after install via invite link
    ↓
main_common.dart: Firebase init → DI init
    ↓
DeferredDeepLinkOrchestrator.checkOnce()
    ↓
Platform service (Android/iOS) retrieves token
    ↓
Token stored in PendingInviteStorage
    ↓
SharedPreferences flag set → guard prevents any future run
    ↓
runApp(PlayWithMeApp())
    ↓
DeepLinkBloc receives InitializeDeepLinks
    ↓
Finds token in PendingInviteStorage → emits DeepLinkPendingInvite
    ↓
App shows invite join flow ✅
```

On all **subsequent launches**, `checkOnce()` finds the SharedPreferences flag and returns `null` immediately — the platform service is never called again.

## Files Changed

| File | Change |
|------|--------|
| `lib/core/services/deferred_deep_link/deferred_deep_link_orchestrator.dart` | New — one-shot orchestrator |
| `lib/core/services/service_locator.dart` | Register orchestrator (always) |
| `lib/main_common.dart` | Call `checkOnce()` before `runApp()` |
| `test/unit/core/services/deferred_deep_link/deferred_deep_link_orchestrator_test.dart` | New — 16 unit tests |
| `docs/epic-19/README.md` | Epic-level documentation |

## Design Decisions

### Why before `runApp()` and not inside `DeepLinkBloc`?

`InitializeDeepLinks` already reads `PendingInviteStorage` as its first action (from Story 17.5). By storing the deferred token into `PendingInviteStorage` **before** `runApp()`, the orchestrator requires zero changes to `DeepLinkBloc` — the existing flow picks it up automatically.

### Why SharedPreferences for the one-shot guard?

The guard must survive:
- App restart (SharedPreferences is persistent)
- OS killing the app mid-startup (flag is written before the service is called)
- Hot restart during development (same behaviour as cold restart)

### Why is the flag set before calling the service?

```dart
await _prefs.setBool(checkedKey, true);  // Written first
final token = await _service!.retrieveDeferredToken();  // Then called
```

Setting the flag before calling the service guarantees that even if the service throws or the app crashes mid-call, the check is never retried. This prevents infinite retry loops on broken devices.

### Why nullable `DeferredDeepLinkService?`

On Web and desktop, no `DeferredDeepLinkService` is registered in `get_it`. The orchestrator accepts a nullable service and returns null immediately when it is null — making it a complete no-op with no side effects.

```dart
if (_service == null) return null;
```

The orchestrator is always registered in `get_it`, with a runtime check:
```dart
service: sl.isRegistered<DeferredDeepLinkService>()
    ? sl<DeferredDeepLinkService>()
    : null,
```

## Unit Tests (16 total)

| Group | Tests |
|-------|-------|
| First launch — with token | returns token, stores in storage, sets flag, calls service once |
| First launch — no token | returns null, does not store, still sets flag |
| Subsequent launches | returns null, never calls service, never calls storage |
| Exception handling | returns null, sets flag (no retry), does not retry on second call |
| No-op (null service) | returns null, does not call storage, safe to call repeatedly |

## Integration Points

| Component | Interaction |
|-----------|-------------|
| `DeferredDeepLinkService` | Called by orchestrator (platform-specific impl injected) |
| `PendingInviteStorage` | Receives token if found; read by `DeepLinkBloc.InitializeDeepLinks` |
| `SharedPreferences` | Stores one-shot guard flag `deferred_deep_link_checked` |
| `DeepLinkBloc` | No changes — reads from `PendingInviteStorage` as before |
| `main_common.dart` | Calls `checkOnce()` after DI init, before `runApp()` |
