# Epic 19 — Deferred Deep Linking

## Overview

Implements **Option 2B** custom deferred deep linking — preserving invite tokens through the app install process so users land on the correct group invitation screen on first launch.

This epic adds zero third-party SDK cost. It uses native platform APIs that are free, privacy-compliant, and deterministic.

## Problem

When a user receives an invite link (`https://gatherli.org/invite/{token}`) and the app is **not installed**, tapping the link sends them to the App Store or Play Store. The token is lost during the install process. On first launch, the app has no token to process.

## Solution

Preserve the token through the install via platform-specific mechanisms:

| Platform | Mechanism | Reliability |
|----------|-----------|-------------|
| Android | Play Install Referrer API | ~100% (deterministic) |
| iOS | Clipboard write on user tap | ~65–80% (requires iOS 16+ consent) |

## Stories

| Story | Title | Key Files |
|-------|-------|-----------|
| 19.1 | Smart Redirect: `/invite/{token}` | `public/invite.html`, `firebase.json` |
| 19.2 | Android: Play Install Referrer | `android_deferred_deep_link_service.dart`, `MainActivity.kt` |
| 19.3 | iOS: Clipboard Deferred Token | `ios_deferred_deep_link_service.dart` |
| 19.4 | Orchestration & App Startup | `deferred_deep_link_orchestrator.dart`, `main_common.dart` |

## End-to-End Flow

### Android (fresh install)

```
1. User taps https://gatherli.org/invite/{token}
2. App not installed → invite.html loads in Chrome
3. JS detects Android → window.location.replace():
   https://play.google.com/store/apps/details?id=org.gatherli.app&referrer=invite_token%3D{token}
4. Play Store installs app, stores referrer string
5. First launch:
   - DeferredDeepLinkOrchestrator.checkOnce() runs
   - AndroidDeferredDeepLinkService reads referrer via MethodChannel
   - Parses invite_token={token} → stores in PendingInviteStorage
6. DeepLinkBloc.InitializeDeepLinks finds token → emits DeepLinkPendingInvite
7. App shows invite join flow ✅
```

### iOS (fresh install)

```
1. User taps https://gatherli.org/invite/{token}
2. App not installed → invite.html loads in Safari
3. User taps "Download on the App Store" button:
   - JS writes 'gatherli://invite/{token}' to clipboard
   - Redirects to App Store
4. iOS 16+ shows consent prompt "Allow Gatherli to paste from Safari?"
5. App Store installs app
6. First launch:
   - DeferredDeepLinkOrchestrator.checkOnce() runs
   - IosDeferredDeepLinkService reads clipboard
   - Matches gatherli://invite/{token} prefix → extracts token
   - Clears clipboard → stores token in PendingInviteStorage
7. DeepLinkBloc.InitializeDeepLinks finds token → emits DeepLinkPendingInvite
8. App shows invite join flow ✅
```

### App already installed (all platforms)

Story 17.7 Universal Links / App Links intercept the URL directly:
```
User taps https://gatherli.org/invite/{token}
    ↓
iOS Universal Link / Android App Link intercepts
    ↓
App opens directly → DeepLinkBloc receives token via app_links ✅
(invite.html never loads — deferred flow not involved)
```

## Key Files

```
lib/core/services/deferred_deep_link/
├── deferred_deep_link_service.dart           # Abstract interface
├── android_deferred_deep_link_service.dart   # Android: Play Install Referrer
├── ios_deferred_deep_link_service.dart       # iOS: Clipboard
└── deferred_deep_link_orchestrator.dart      # One-shot startup orchestrator

android/app/src/main/kotlin/org/gatherli/app/
└── MainActivity.kt                           # MethodChannel for referrer API

public/
├── invite.html                               # Platform-aware redirect page
├── badge-app-store.svg                       # App Store badge
└── badge-google-play.png                     # Play Store badge

lib/main_common.dart                          # Startup wiring
lib/core/services/service_locator.dart        # DI registrations
```

## No Changes Required to DeepLinkBloc

The orchestrator stores the recovered token in `PendingInviteStorage` before `runApp()`. `DeepLinkBloc.InitializeDeepLinks` already reads from `PendingInviteStorage` as its first action (from Story 17.5). The existing BLoC flow handles the token automatically.

## Cost

Zero. The Play Install Referrer API and Flutter's `Clipboard` API are free, require no third-party SDK, and are GDPR-compliant.

## Known Limitation (iOS)

iOS 16+ requires user consent to read the clipboard (`"Allow Gatherli to paste from Safari?"`). If denied, the token is silently lost. The user falls back to re-tapping the invite link after installing (which Universal Links handle directly).
