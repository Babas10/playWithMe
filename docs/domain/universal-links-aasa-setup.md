# Universal Links & AASA File Setup — Gatherli

**Date:** March 2026
**Context:** Story 18.7 — Deep Linking: Update Domain & URL Schemes to gatherli.org

---

## What is this about?

When a user receives a Gatherli invite link like:

```
https://gatherli.org/invite/abc123
```

We want tapping that link to **open the Gatherli app directly** instead of opening a browser.
This is called **Universal Links** on iOS (and **App Links** on Android).

For Universal Links to work, Apple requires proof that you own both:
- The **domain** (`gatherli.org`)
- The **app** (`org.gatherli.app`)

This proof is established through a special file called the **AASA file**.

---

## What is the AASA file?

**AASA** stands for **Apple App Site Association**.

It is a JSON file hosted at a specific URL on your domain:

```
https://gatherli.org/.well-known/apple-app-site-association
```

Apple's servers automatically fetch this file when the app is installed on a device.
The file tells Apple:

> "The app with bundle ID `2FN99DA6RR.org.gatherli.app` is allowed to handle
> links that match the pattern `/invite/*` on this domain."

Our AASA file content:

```json
{
  "applinks": {
    "details": [
      {
        "appIDs": [
          "2FN99DA6RR.org.gatherli.app",
          "2FN99DA6RR.org.gatherli.app.dev"
        ],
        "components": [
          {
            "/": "/invite/*",
            "comment": "Matches all Gatherli group invite deep links"
          }
        ]
      }
    ]
  }
}
```

Key elements:
- `2FN99DA6RR` — your Apple Developer **Team ID**
- `org.gatherli.app` — production app bundle ID
- `org.gatherli.app.dev` — development app bundle ID
- `/invite/*` — the URL pattern that should open the app (any invite link)

---

## What is Firebase Hosting?

Firebase Hosting is a service that serves static files (HTML, JSON, etc.) over HTTPS.

We use it here for one specific purpose: to serve the AASA file at the exact URL
Apple requires, with the correct `Content-Type: application/json` header.

Firebase Hosting also handles the **SSL certificate** automatically — which is
critical because Apple will only fetch the AASA file over **HTTPS** (never HTTP).

---

## How everything connects

Here is the full flow from invite link → app opening:

```
1. User taps: https://gatherli.org/invite/abc123

2. iOS checks if gatherli.org has an AASA file
   → fetches https://gatherli.org/.well-known/apple-app-site-association

3. iOS reads the AASA file and finds:
   → "links matching /invite/* should open org.gatherli.app"

4. iOS opens the Gatherli app directly (no browser)

5. The app receives the URL and extracts the token: abc123

6. The app uses the token to join the group
```

Without the AASA file, step 2 fails and the link opens in Safari instead of the app.

---

## What we set up

### 1. Firebase Hosting configuration (`firebase.json`)

Added a `hosting` section that:
- Serves files from the `public/` directory
- Sets `Content-Type: application/json` on the AASA file (required by Apple)

### 2. AASA file (`public/.well-known/apple-app-site-association`)

Created the JSON file listing the Gatherli app IDs and the `/invite/*` path pattern.

### 3. Deployed to Firebase

- `gatherli-dev` → accessible at `https://gatherli-dev.web.app/.well-known/apple-app-site-association`
- `gatherli-prod` → accessible at `https://gatherli-prod.web.app/.well-known/apple-app-site-association`

### 4. Custom domain on Firebase (`gatherli.org` → `gatherli-prod`)

Added `gatherli.org` as a custom domain in the Firebase Console for `gatherli-prod`.
Firebase issued DNS records (A records + TXT verification record).

### 5. GoDaddy DNS records

Added the Firebase-provided DNS records to GoDaddy:
- **TXT record** — proves to Firebase that you own the domain
- **A records** — points `gatherli.org` traffic to Firebase Hosting servers

Once DNS propagates, `https://gatherli.org` is served by Firebase Hosting,
and the AASA file becomes reachable at the exact URL Apple requires.

---

## iOS app configuration

Two files in the iOS project tell the app to handle `gatherli.org` links:

**`ios/Runner/Runner.entitlements`**
```xml
<key>com.apple.developer.associated-domains</key>
<array>
  <string>applinks:gatherli.org</string>
</array>
```
This registers the app with iOS as a handler for `gatherli.org` links.

**`ios/Runner/Info.plist`**
```xml
<key>CFBundleURLSchemes</key>
<array>
  <string>gatherli</string>
</array>
```
This registers the custom URL scheme `gatherli://` as a fallback
for older iOS versions or when Universal Links are unavailable.

---

## Android configuration

Android uses **App Links** (the Android equivalent of Universal Links).
Already configured in `android/app/src/main/AndroidManifest.xml`:

```xml
<!-- HTTPS App Links -->
<data android:scheme="https"
      android:host="gatherli.org"
      android:pathPrefix="/invite"/>

<!-- Custom scheme fallback -->
<data android:scheme="gatherli"
      android:host="invite"/>
```

Android verification works differently — it fetches a similar file called
`assetlinks.json` at `https://gatherli.org/.well-known/assetlinks.json`.
This will need to be set up when Android App Link verification is required.

---

## Two types of deep links

| Type | Format | How it works | When used |
|------|--------|-------------|-----------|
| **Universal Link** | `https://gatherli.org/invite/abc123` | Opens app via AASA verification | Primary — iOS 13+, shared links |
| **Custom scheme** | `gatherli://invite/abc123` | Opens app directly by scheme | Fallback — in-app sharing, older flows |

The app handles both in `lib/core/services/app_links_deep_link_service.dart`.

---

## Current status

| Item | Status |
|------|--------|
| AASA file created | ✅ |
| Firebase Hosting deployed (dev) | ✅ |
| Firebase Hosting deployed (prod) | ✅ |
| `gatherli.org` custom domain added to Firebase | ✅ |
| GoDaddy DNS records added | ✅ |
| iOS entitlements updated (`applinks:gatherli.org`) | ✅ |
| iOS URL scheme registered (`gatherli`) | ✅ |
| Android App Links configured | ✅ |
| DNS propagation complete | ⏳ Allow up to 48h |
| Universal Links working end-to-end on device | ⏳ After DNS propagation |
| Android `assetlinks.json` | 🔲 Pending (future story) |

---

## Key file locations

| File | Purpose |
|------|---------|
| `public/.well-known/apple-app-site-association` | AASA file served by Firebase Hosting |
| `public/404.html` | Required fallback page for Firebase Hosting |
| `firebase.json` | Firebase Hosting config with AASA Content-Type header |
| `ios/Runner/Runner.entitlements` | Registers `applinks:gatherli.org` with iOS |
| `ios/Runner/Info.plist` | Registers `gatherli://` custom URL scheme |
| `android/app/src/main/AndroidManifest.xml` | Android App Links + custom scheme config |
| `lib/core/services/app_links_deep_link_service.dart` | Dart service that parses incoming deep links |
| `functions/src/invites/createGroupInvite.ts` | Cloud Function that generates invite URLs |
