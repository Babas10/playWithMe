# Story 20.9 — iOS Distribution Certificate & Provisioning Profile for CI Signing

## Problem This Solves

The beta and production CD pipelines were failing with:

```
Error (Xcode): No Accounts: Add a new account in Accounts settings.
Error (Xcode): No profiles for '***' were found: Xcode couldn't find any
iOS App Development provisioning profiles matching '***'.
```

Root cause: `ios/ExportOptions.plist` used `signingStyle: automatic`.
Automatic signing requires Xcode to connect to Apple servers to download
provisioning profiles — this is impossible on a headless CI runner.

**Fix:** Switch to manual signing. CI installs the distribution certificate
into a temporary keychain and the provisioning profile directly into the
expected system directory before calling `flutter build ipa`.

---

## Two Things That Look Similar But Are Different

Before setting this up, it's important to understand the two separate Apple
credentials used in the pipeline:

| Credential | File type | Secret name | Purpose |
|-----------|-----------|-------------|---------|
| App Store Connect API Key | `.p8` | `APP_STORE_CONNECT_API_KEY_BASE64` | **Upload** the built IPA to TestFlight / App Store Connect |
| Apple Distribution Certificate | `.p12` | `IOS_DISTRIBUTION_CERT_BASE64` | **Sign** the binary so Apple accepts it |

Both are required. You already have the API key. This story adds the
distribution certificate and provisioning profile.

---

## Step 1 — Create the Apple Distribution Certificate

You only need to do this once. If a valid Apple Distribution certificate
already exists in your Keychain, skip to Step 2.

### Option A — via Xcode (easiest)

1. Open Xcode on your Mac.
2. Go to **Xcode → Settings → Accounts**.
3. Select your Apple ID → click **Manage Certificates**.
4. Click **+** → choose **Apple Distribution**.
5. Xcode creates the certificate and installs it into Keychain Access automatically.

### Option B — via Apple Developer Portal

1. Go to [developer.apple.com → Certificates](https://developer.apple.com/account/resources/certificates/list).
2. Click **+** → choose **Apple Distribution**.
3. Follow the CSR instructions (you'll need to generate a Certificate Signing Request from Keychain Access).
4. Download the `.cer` file and double-click it to install it into Keychain Access.

---

## Step 2 — Export the Certificate as a .p12 File

The CI runner needs the certificate in PKCS#12 format (`.p12`), which bundles
the certificate and its private key together.

1. Open **Keychain Access** on your Mac.
2. Select the **My Certificates** category in the left sidebar.
3. Find the certificate named **Apple Distribution: [Your Name/Team]**.
4. Right-click it → **Export "Apple Distribution: ..."**.
5. Choose **Personal Information Exchange (.p12)** format.
6. Save the file (e.g., `distribution.p12`).
7. Set a **strong password** when prompted — you will store this as a secret.

---

## Step 3 — Create the Provisioning Profile

1. Go to [developer.apple.com → Profiles](https://developer.apple.com/account/resources/profiles/list).
2. Click **+** → choose **App Store Connect** (under Distribution).
3. Select the App ID for `org.gatherli.app`.
4. Select the **Apple Distribution** certificate you just created.
5. Name the profile (e.g., `Gatherli App Store Distribution`).
6. Click **Generate** → **Download** the `.mobileprovision` file.

> Note the **exact profile name** you chose — you will need it as a secret.

---

## Step 4 — Add GitHub Secrets

Base64-encode the certificate and profile, then add them to GitHub.

```bash
# On your Mac terminal:

# Encode the certificate
base64 -i distribution.p12 | pbcopy
# → paste into GitHub Secret: IOS_DISTRIBUTION_CERT_BASE64

# Encode the provisioning profile
base64 -i profile.mobileprovision | pbcopy
# → paste into GitHub Secret: IOS_PROVISIONING_PROFILE_BASE64
```

Add these 4 secrets in **GitHub → Settings → Secrets → Actions**:

| Secret | Value |
|--------|-------|
| `IOS_DISTRIBUTION_CERT_BASE64` | Output of `base64 -i distribution.p12` |
| `IOS_DISTRIBUTION_CERT_PASSWORD` | Password you set when exporting the `.p12` |
| `IOS_PROVISIONING_PROFILE_BASE64` | Output of `base64 -i profile.mobileprovision` |
| `IOS_PROVISIONING_PROFILE_NAME` | Exact profile name from Apple Developer Portal (e.g. `Gatherli App Store Distribution`) |

---

## What the Pipeline Does (Technical Details)

The `deploy_ios` job in `cd-beta.yml` and `cd-production.yml` now runs these
steps before building:

```
1. Decode IOS_DISTRIBUTION_CERT_BASE64 → distribution.p12
2. Create a temporary keychain (app-signing.keychain-db)
3. Import the .p12 into the temporary keychain
4. Set the keychain as the active keychain for codesigning
5. Decode IOS_PROVISIONING_PROFILE_BASE64 → profile.mobileprovision
6. Extract the UUID from the profile and copy it to
   ~/Library/MobileDevice/Provisioning Profiles/<UUID>.mobileprovision
7. Install the App Store Connect API Key (.p8) for the upload step
8. Run: flutter build ipa --export-options-plist=ios/ExportOptions.plist
   (with IOS_PROVISIONING_PROFILE_NAME injected as env var)
9. Delete the temporary keychain (cleanup, always runs even on failure)
```

### ExportOptions.plist

Changed from automatic to manual signing:

```xml
<key>signingStyle</key>
<string>manual</string>
<key>signingCertificate</key>
<string>Apple Distribution</string>
<key>provisioningProfiles</key>
<dict>
    <key>org.gatherli.app</key>
    <string>$(IOS_PROVISIONING_PROFILE_NAME)</string>
</dict>
```

---

## Secrets Checklist

Before pushing a beta tag, confirm these secrets are all set:

| Secret | Status |
|--------|--------|
| `APP_STORE_CONNECT_API_KEY_BASE64` | ✅ Already set |
| `APP_STORE_CONNECT_API_KEY_ID` | ✅ Already set |
| `APP_STORE_CONNECT_API_ISSUER_ID` | ✅ Already set |
| `IOS_BUNDLE_ID` | ✅ Already set |
| `IOS_DISTRIBUTION_CERT_BASE64` | ❌ Add now |
| `IOS_DISTRIBUTION_CERT_PASSWORD` | ❌ Add now |
| `IOS_PROVISIONING_PROFILE_BASE64` | ❌ Add now |
| `IOS_PROVISIONING_PROFILE_NAME` | ❌ Add now |

---

## Certificate Expiry

Apple Distribution certificates expire after **1 year**. When it expires:

1. Repeat Steps 1–4 above to generate a new certificate and profile.
2. Update the 4 GitHub secrets with the new values.
3. No code changes required.

---

## Troubleshooting

### "No profiles found" still appears
- Verify the `IOS_PROVISIONING_PROFILE_NAME` secret matches the profile name
  **exactly** as it appears in Apple Developer Portal (case-sensitive).
- Check that the profile was created for the correct bundle ID (`org.gatherli.app`)
  and is of type **App Store Connect** (not Ad Hoc or Development).

### "Certificate not found" / codesigning error
- Verify the `.p12` was exported with both the certificate AND its private key.
  In Keychain Access, the certificate must show an expandable arrow (▶) revealing
  the private key underneath before you export it.

### Build succeeds but upload fails
- The upload uses the App Store Connect API key (`.p8`), not the distribution cert.
  If upload fails, check `APP_STORE_CONNECT_API_KEY_BASE64`, `APP_STORE_CONNECT_API_KEY_ID`,
  and `APP_STORE_CONNECT_API_ISSUER_ID`.
