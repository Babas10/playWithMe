# iOS Apple Developer Account Setup — Gatherli

**Date:** March 2026
**Context:** Epic 18 — App Rename: Gatherli → Gatherli

This document covers all steps taken to configure the Apple Developer account, iOS signing,
and Firebase push notification integration for the Gatherli app.

---

## 1. Apple Developer Account

- Upgraded from a free Personal Team to a paid **Apple Developer Program** membership.
- Account: **Etienne Dubois**
- Team ID: available in Apple Developer Portal → Account → Membership Details (10-character alphanumeric code)

---

## 2. App IDs Registered

Two App IDs were registered at [developer.apple.com](https://developer.apple.com) →
Certificates, Identifiers & Profiles → Identifiers:

| App ID | Environment | Description |
|--------|-------------|-------------|
| `org.gatherli.app` | Production | Gatherli — organize and join sports games with your friends |
| `org.gatherli.app.dev` | Development | Gatherli Development — development build for testing |

### Capabilities enabled on both App IDs:
- ✅ **Push Notifications**
- ✅ **Associated Domains** (required for Universal Links — Story 18.7)

> **Note:** The "Broadcast" push notification capability was intentionally **not** enabled.
> Gatherli sends targeted, per-user notifications (game invites, friend requests, RSVPs)
> via Firebase Cloud Messaging. Broadcast is designed for public mass-audience alerts,
> which is not applicable here.

---

## 3. Certificates

Two certificates were created and installed in the **login** keychain (not System, not Local Items):

| Certificate | Purpose | Expires |
|-------------|---------|---------|
| Apple Development — Etienne Dubois | Local development builds & testing | 2027/03/05 |
| Apple Distribution — Etienne Dubois | App Store distribution | 2027/03/05 |

### How certificates were generated:

1. Open **Keychain Access** → Certificate Assistant → Request a Certificate from a Certificate Authority
2. Fill in email, set Common Name (e.g. `Gatherli Development`), select **Saved to disk**
3. Save the `.certSigningRequest` file
4. Upload the CSR to Apple Developer Portal when creating each certificate
5. Download the `.cer` file
6. Import into **login** keychain via **File → Import Items** (double-clicking may fail with error 25294 if the private key is not found — use File → Import Items instead)

> **Note:** The same CSR file can be reused for both Development and Distribution certificates.
> The Common Name is purely a label and has no technical impact.

### Stale certificate cleanup:

An old auto-generated Development certificate (`eodubois-mac`, expiring 2026/09/24) was found
and revoked from the Apple Developer Portal to keep the certificate list clean.

---

## 4. Provisioning Profiles

Two provisioning profiles were created and installed:

| Profile Name | Type | App ID | Certificate |
|---|---|---|---|
| `Gatherli Dev – Development` | iOS App Development | `org.gatherli.app.dev` | Apple Development |
| `Gatherli Prod – App Store` | App Store Connect | `org.gatherli.app` | Apple Distribution |

### Notes:
- **Offline support (7-day validity)** was not enabled — not needed for normal development and App Store distribution.
- Profiles were installed by double-clicking the downloaded `.mobileprovision` files.
- Device registration: iPhone was connected via USB, paired in Xcode (Window → Devices and Simulators), which automatically registered it with Apple Developer Portal.

---

## 5. Xcode Signing Configuration

Opened `ios/Runner.xcworkspace` in Xcode (**always open `.xcworkspace`, not `.xcodeproj`**).

**Automatic signing** was enabled with the paid Etienne Dubois team. Xcode successfully:
- Generated `Xcode Managed Profile` for both `org.gatherli.app.dev` and `org.gatherli.app`
- Assigned the Apple Development certificate (K4YBW6F3... prefix)
- Resolved Push Notifications and Associated Domains capability errors (these require a paid account)

### Signing configuration per build flavor:

| Configuration | Bundle ID | Signing |
|---|---|---|
| Debug-dev, Profile-dev, Release-dev | `org.gatherli.app.dev` | Xcode Managed Profile |
| Debug-prod, Profile-prod | `org.gatherli.app` | Xcode Managed Profile |
| Release-prod | `org.gatherli.app` | Xcode Managed Profile (App Store) |

---

## 6. Staging (stg) Removal from Xcode

As part of Epic 18 (Story 18.5 removed stg from all Dart/Flutter code), the stg build
configurations were also removed from the Xcode project:

**Removed from `ios/Runner.xcodeproj/project.pbxproj`:**
- 6 PBXFileReference entries for stg xcconfig files (debug/release/profile for Runner and RunnerTests)
- 9 XCBuildConfiguration blocks (Debug-stg, Release-stg, Profile-stg × 3 targets)
- All references to stg UUIDs in XCConfigurationList sections
- The `stg` branch from the Firebase config copy shell script

**Deleted:** `ios/Runner.xcodeproj/xcshareddata/xcschemes/stg.xcscheme`

**Remaining schemes:** `dev.xcscheme`, `prod.xcscheme`, `Runner.xcscheme`

---

## 7. APNs Key — Firebase Push Notifications

An APNs Authentication Key was created in Apple Developer Portal → Keys:

| Setting | Value |
|---------|-------|
| Key Name | `Gatherli APNs` |
| Service | Apple Push Notifications service (APNs) |
| Environment | Sandbox & Production |
| Key Restriction | Team Scoped (applies to all apps under the developer account) |

> The `.p8` key file can only be downloaded **once** from the Apple Developer Portal.
> Store it securely — if lost, a new key must be generated and re-uploaded to Firebase.

The key was uploaded to both Firebase projects:

**Firebase Console → Project Settings → Cloud Messaging → Apple app configuration:**

| Firebase Project | iOS App | APNs Key |
|---|---|---|
| `gatherli-dev` | `org.gatherli.app.dev` | Uploaded ✅ |
| `gatherli-prod` | `org.gatherli.app` | Uploaded ✅ |

Required values when uploading:
- **Key ID:** shown next to the key in Apple Developer Portal → Keys
- **Team ID:** found in Apple Developer Portal → Account → Membership Details

---

## 8. Current Status & Next Steps

### Completed ✅
- Apple Developer Program membership active
- App IDs registered with correct capabilities
- Development and Distribution certificates installed
- Provisioning profiles created and installed
- Xcode signing configured and verified (no errors)
- APNs key uploaded to both Firebase projects
- stg build configurations removed from Xcode

### Pending
- **Story 18.7** — Deep Linking: update domain to `gatherli.org` and URL scheme to `gatherli://`
  - Requires `gatherli.org` domain to be registered and DNS active for Universal Links (AASA file)
  - Custom URL scheme (`gatherli://`) can be implemented and tested immediately
- **Story 18.8** — Cloud Functions: update branding references and deploy to Gatherli projects

---

## 9. Key File Locations

| File | Purpose |
|------|---------|
| `ios/Runner/Firebase/dev/GoogleService-Info.plist` | Firebase config for dev flavor |
| `ios/Runner/Firebase/prod/GoogleService-Info.plist` | Firebase config for prod flavor |
| `ios/Runner/Firebase/copy-firebase-config.sh` | Script that copies the correct plist at build time |
| `ios/Runner.xcodeproj/project.pbxproj` | Xcode project — bundle IDs and signing config |
| `ios/Runner.xcodeproj/xcshareddata/xcschemes/` | Build schemes (dev, prod, Runner) |
