# Story 19.3 — iOS: Deferred Token Recovery via Clipboard

## Overview

On iOS, when the app is launched for the first time after being installed via the App Store (following the clipboard-write redirect in Story 19.1), this story recovers the invite token from the clipboard and makes it available to the existing `DeepLinkBloc` flow.

**Depends on:**
- Story 19.1 (invite.html writes `gatherli://invite/{token}` to clipboard on iOS tap)
- Story 19.2 (defines the `DeferredDeepLinkService` interface)

## How It Works

```
User taps https://gatherli.org/invite/{token} on iOS (app not installed)
    ↓
Safari falls back to browser → invite.html loads
    ↓
User taps "Download on the App Store" button:
    1. navigator.clipboard.writeText('gatherli://invite/{token}')
    2. window.location.href = APP_STORE_URL
    ↓
App Store installs app
    ↓
First launch → IosDeferredDeepLinkService.retrieveDeferredToken()
    ↓
Reads clipboard → finds 'gatherli://invite/{token}'
    ↓
Extracts token → clears clipboard → returns token
    ↓
Story 19.4 feeds token into DeepLinkBloc via InviteTokenReceived ✅
```

## Files Changed

| File | Change |
|------|--------|
| `lib/core/services/deferred_deep_link/ios_deferred_deep_link_service.dart` | New — iOS implementation |
| `lib/core/services/service_locator.dart` | Added iOS branch to DI registration |
| `test/unit/core/services/deferred_deep_link/ios_deferred_deep_link_service_test.dart` | New — 10 unit tests |

## Architecture

### Why `ClipboardReader` abstraction?

`FlutterClipboardReader` (which calls `Clipboard.getData`) is injected into `IosDeferredDeepLinkService`. Unit tests inject a `MockClipboardReader` instead, making the parsing and clear logic fully testable without platform bindings.

This mirrors the `InstallReferrerClient` pattern from Story 19.2.

### iOS 16+ Consent Prompt

iOS 16 and later shows a system prompt when an app reads the clipboard programmatically:
> *"Allow Gatherli to paste from Safari?"*

| User action | Result |
|-------------|--------|
| Taps **Allow** | Clipboard is read, token recovered ✅ |
| Taps **Don't Allow** | `Clipboard.getData` returns null, token silently lost ✅ |

This is an Apple platform constraint. The implementation handles denial gracefully — no crash, no retry, the invite flow falls back to manual link-tap.

### Clipboard clear after extraction

The clipboard is cleared immediately after a valid token is extracted:

```dart
await _clipboard.clear();
```

This prevents the same token from firing on subsequent cold starts (e.g., if the user force-quits and relaunches without opening a group).

### DI registration

```dart
// service_locator.dart
if (!kIsWeb && Platform.isAndroid) {
  sl.registerLazySingleton<DeferredDeepLinkService>(
    () => AndroidDeferredDeepLinkService(),
  );
} else if (!kIsWeb && Platform.isIOS) {
  sl.registerLazySingleton<DeferredDeepLinkService>(
    () => IosDeferredDeepLinkService(),
  );
}
```

The `kIsWeb` guard is required because `dart:io Platform` is not available on Flutter Web.

## Unit Tests

All 10 tests in `test/unit/core/services/deferred_deep_link/ios_deferred_deep_link_service_test.dart`:

| Test | Scenario |
|------|----------|
| returns token from valid `gatherli://invite/` content | `gatherli://invite/abc123` → `abc123` |
| clears clipboard after extracting valid token | `clear()` called exactly once |
| returns null for wrong scheme (https URL) | `https://gatherli.org/invite/abc123` → null |
| returns null for unrelated clipboard content | `some random text` → null |
| returns null when clipboard is empty string | `""` → null |
| returns null when clipboard read returns null | null → null |
| returns null for `gatherli://invite/` with empty token | `gatherli://invite/` → null |
| returns null when clipboard throws (iOS consent denied) | exception → null |
| does not clear clipboard when no valid token found | `clear()` never called |
| trims whitespace from extracted token | `gatherli://invite/  token123  ` → `token123` |

## Reliability Note

iOS clipboard-based deferred deep linking has ~65–80% success rate depending on:
- iOS version (16+ requires user consent)
- Whether the user grants clipboard permission
- Whether the clipboard is overwritten before first launch

This is an inherent platform limitation. The fallback (Option 1 — user must tap the invite link again after installing) is seamless since Universal Links will open the app directly if it is installed.

## Testing

| Test | Steps | Expected |
|------|-------|----------|
| iOS fresh install | Tap invite link in Safari (app not installed) → tap App Store button → install → open | First launch shows invite join flow |
| Consent denied | Same as above, tap "Don't Allow" on clipboard prompt | App opens normally, no invite shown |
| No invite | Install app directly from App Store | `retrieveDeferredToken()` returns null |
| Token whitespace | Clipboard contains `gatherli://invite/ abc123 ` | Token extracted as `abc123` |
