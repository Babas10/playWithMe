# Story 19.1 — Smart Redirect: `/invite/{token}` Platform-Aware Store Redirect

## Overview

Deploys a minimal web page at `https://gatherli.org/invite/{token}` that acts as the **transport mechanism** for the invite token when the Gatherli app is not installed on the user's device.

This page is never seen when the app is already installed — iOS Universal Links and Android App Links intercept the URL and open the app directly (implemented in Story 17.7).

## Files Changed

| File | Change |
|------|--------|
| `public/invite.html` | New — platform-aware redirect page |
| `firebase.json` | Added `rewrites` rule: `/invite/**` → `invite.html` |
| `public/404.html` | Added safety-net redirect for `/invite/` paths |

## How It Works

### When the app IS installed (unchanged from Story 17.7)
```
User taps https://gatherli.org/invite/{token}
    ↓
iOS Universal Link / Android App Link intercepts
    ↓
App opens directly to invite screen ✅
(invite.html is never loaded)
```

### When the app is NOT installed — Android
```
User taps https://gatherli.org/invite/{token}
    ↓
Android falls back to browser → invite.html loads
    ↓
JS detects Android (navigator.userAgent)
    ↓
Auto-redirects immediately (window.location.replace) to:
https://play.google.com/store/apps/details
  ?id=org.gatherli.app
  &referrer=invite_token%3D{token}
    ↓
Play Store installs app.
On first launch, Story 19.2 reads the referrer → recovers token ✅
```

### When the app is NOT installed — iOS
```
User taps https://gatherli.org/invite/{token}
    ↓
iOS falls back to Safari → invite.html loads
    ↓
JS detects iOS (navigator.userAgent)
    ↓
Shows single-tap UI: "Get Gatherli on the App Store"
    ↓
User taps button:
  1. navigator.clipboard.writeText('gatherli://invite/{token}')
  2. window.location.href = APP_STORE_URL
    ↓
App Store installs app.
On first launch, Story 19.3 reads clipboard → recovers token ✅
```

### Desktop / unknown platform
Fallback view shows both App Store and Play Store links with no auto-redirect.

## Key Design Decisions

### No landing page content
The page is intentionally minimal. It is a transport mechanism, not a marketing page. The Android user barely sees it (instant redirect). The iOS user sees only a single action button.

### Clipboard write requires user gesture (iOS)
`navigator.clipboard.writeText()` can only be called from a user-initiated event handler. This is an Apple/browser security requirement — it cannot be triggered on page load. The single-tap button satisfies this constraint.

### `window.location.replace()` for Android
Using `replace()` instead of `href` means the redirect page is not added to browser history. The user cannot tap "Back" and land on the redirect page again.

### Graceful clipboard failure
If the clipboard write is denied or unavailable, the App Store redirect still happens. The token is simply not recovered (falls back to Option 1 behaviour — user taps link again after installing).

### `noindex` meta tag
Invite URLs must not be indexed by search engines. The `robots: noindex, nofollow` meta tag prevents this.

## Firebase Hosting Configuration

```json
"rewrites": [
  {
    "source": "/invite/**",
    "destination": "/invite.html"
  }
]
```

With `cleanUrls: true`, the path `/invite/abc123` has no matching static file, so Firebase evaluates the rewrite rules and serves `invite.html`. The full path remains in `window.location.pathname`, allowing JS to extract the token.

## Play Store Referrer Format

The referrer string passed to the Play Store must be URL-encoded:

| Value | Encoded |
|-------|---------|
| `invite_token=abc123` | `invite_token%3Dabc123` |

The full Play Store URL:
```
https://play.google.com/store/apps/details
  ?id=org.gatherli.app
  &referrer=invite_token%3Dabc123
```

This referrer string is preserved by the Play Store and made available to the app via the Play Install Referrer API (Story 19.2).

## TODO

- [ ] Replace `APP_STORE_URL` placeholder (`id000000000`) with the real App Store ID once Gatherli is published on the App Store.

## Testing

This story contains no Dart code. Validation is manual:

| Test | Steps | Expected |
|------|-------|----------|
| Android redirect | Open `gatherli.org/invite/abc123` in Chrome on Android (app not installed) | Auto-redirects to Play Store URL containing `referrer=invite_token%3Dabc123` |
| iOS tap | Open `gatherli.org/invite/abc123` in Safari on iOS (app not installed) | Single button shown; tap writes `gatherli://invite/abc123` to clipboard and opens App Store |
| No token | Open `gatherli.org/invite/` | Redirect still happens, no referrer/clipboard content |
| Desktop | Open in desktop browser | Both store links shown, no auto-redirect |
| App installed (iOS) | Tap link with app installed | Safari does not load page — app opens directly (Universal Link) |
| App installed (Android) | Tap link with app installed | Browser does not load page — app opens directly (App Link) |

## Deployment

```bash
# Deploy hosting only (no functions needed)
firebase deploy --only hosting --project gatherli-dev
firebase deploy --only hosting --project gatherli-prod
```
