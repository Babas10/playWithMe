# Story 19.2 — Android: Deferred Token Recovery via Play Install Referrer

## Overview

On Android, when the app is launched for the first time after being installed via a Gatherli invite link, this story recovers the invite token and makes it available to the existing `DeepLinkBloc` flow.

**Depends on:** Story 19.1 (invite.html embeds the token in the Play Store referrer URL)

## How It Works

```
User taps https://gatherli.org/invite/{token}
    ↓
App not installed → Android falls back to browser → invite.html loads
    ↓
JS detects Android → window.location.replace(Play Store URL):
    https://play.google.com/store/apps/details
      ?id=org.gatherli.app
      &referrer=invite_token%3D{token}
    ↓
Play Store installs app, preserves referrer string
    ↓
First launch → AndroidDeferredDeepLinkService.retrieveDeferredToken()
    ↓
Native MethodChannel calls com.android.installreferrer API
    ↓
Referrer string "invite_token={token}" parsed → token returned
    ↓
Story 19.4 feeds token into DeepLinkBloc via InviteTokenReceived ✅
```

## Files Changed

| File | Change |
|------|--------|
| `lib/core/services/deferred_deep_link/deferred_deep_link_service.dart` | New — abstract interface |
| `lib/core/services/deferred_deep_link/android_deferred_deep_link_service.dart` | New — Android implementation |
| `lib/core/services/service_locator.dart` | DI registration (Android-only) |
| `android/app/build.gradle.kts` | Added `com.android.installreferrer:installreferrer:2.2` |
| `android/app/src/main/kotlin/org/gatherli/app/MainActivity.kt` | MethodChannel handler |
| `test/unit/core/services/deferred_deep_link/android_deferred_deep_link_service_test.dart` | New — 9 unit tests |

## Architecture

### Why a MethodChannel instead of a Flutter package?

The `install_referrer` Flutter package (v1.2.1) detects **which store** installed the app (an enum: Google Play, App Store, etc.) — it does **not** expose the custom referrer string.

The correct Google Play Install Referrer Library (`com.android.installreferrer:installreferrer:2.2`) is a native Android library. It is accessed via a `MethodChannel` named `org.gatherli.app/install_referrer`.

### Why an `InstallReferrerClient` abstraction?

The `PlayInstallReferrerClient` (which calls the MethodChannel) is injected into `AndroidDeferredDeepLinkService`. Unit tests inject a `MockInstallReferrerClient` instead, making the parsing logic fully testable without Android hardware.

### Referrer string format

Story 19.1 sets the Play Store URL as:
```
https://play.google.com/store/apps/details
  ?id=org.gatherli.app
  &referrer=invite_token%3D{token}
```

The `%3D` is URL-encoded `=`. The Play Store URL-decodes the `referrer` parameter once before delivery, so `AndroidDeferredDeepLinkService` receives:
```
invite_token=abc123
```

The service also handles the double-encoded form (`invite_token%3Dabc123`) seen on some Play Store versions.

### Platform guard in DI

```dart
// service_locator.dart
if (!kIsWeb && Platform.isAndroid) {
  if (!sl.isRegistered<DeferredDeepLinkService>()) {
    sl.registerLazySingleton<DeferredDeepLinkService>(
      () => AndroidDeferredDeepLinkService(),
    );
  }
}
```

The `kIsWeb` check is required because `dart:io Platform` is not available on Flutter Web and would throw at runtime.

## Native Android Implementation

`MainActivity.kt` implements the `getReferrerString` method by calling the `com.android.installreferrer` library asynchronously:

```kotlin
val referrerClient = InstallReferrerClient.newBuilder(this).build()
referrerClient.startConnection(object : InstallReferrerStateListener {
    override fun onInstallReferrerSetupFinished(responseCode: Int) {
        when (responseCode) {
            InstallReferrerClient.InstallReferrerResponse.OK -> {
                val referrer = referrerClient.installReferrer?.installReferrer
                // deliver referrer string back to Flutter
            }
            else -> // deliver null (not installed via Play Store)
        }
    }
    override fun onInstallReferrerServiceDisconnected() {
        // deliver null
    }
})
```

The referrer string is only available for a short window after install. Subsequent calls return null or an error, which the service handles gracefully.

## Unit Tests

All 9 tests in `test/unit/core/services/deferred_deep_link/android_deferred_deep_link_service_test.dart`:

| Test | Scenario |
|------|----------|
| returns token for valid `invite_token` referrer | `invite_token=abc123` → `abc123` |
| returns token for referrer with multiple params | `utm_source=email&invite_token=xyz789` → `xyz789` |
| returns null when referrer has no `invite_token` | `utm_source=other` → null |
| returns null when referrer is empty string | `""` → null |
| returns null when client returns null | null → null |
| returns null when client throws | exception → null (graceful) |
| handles URL-encoded referrer string | `invite_token%3Dabc123` → `abc123` |
| returns null for malformed referrer string | `%%%invalid%%%` → null |
| returns null when `invite_token` value is empty | `invite_token=` → null |

## Error Handling

All error paths return `null` silently. The invite flow degrades gracefully:
- App opens normally with no pending invite
- User can still accept the invite manually if they have the link

## Testing

This story contains no UI. Validation beyond unit tests is manual:

| Test | Steps | Expected |
|------|-------|----------|
| Android fresh install | Install app via Play Store link with token | First launch recovers token (Story 19.4 feeds it to DeepLinkBloc) |
| Non-invite install | Install app from Play Store search | `retrieveDeferredToken()` returns null |
| Error path | Disconnect Play Store services before launch | Returns null, no crash |
