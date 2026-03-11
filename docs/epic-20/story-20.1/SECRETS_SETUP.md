# Story 20.1 — GitHub Secrets Setup for CD Pipeline

This document covers every account, credential, and GitHub Secret required to run the
Gatherli CD pipeline for both the Apple App Store and Google Play Store.

---

## Overview of Required Secrets

| Secret Name | Platform | Description |
|-------------|----------|-------------|
| `APP_STORE_CONNECT_API_KEY_BASE64` | iOS | Base64-encoded `.p8` private key |
| `APP_STORE_CONNECT_API_KEY_ID` | iOS | 10-char Key ID from App Store Connect |
| `APP_STORE_CONNECT_API_ISSUER_ID` | iOS | UUID Issuer ID from App Store Connect |
| `IOS_BUNDLE_ID` | iOS | App bundle identifier |
| `ANDROID_KEYSTORE_BASE64` | Android | Base64-encoded `.jks` keystore file |
| `ANDROID_KEY_ALIAS` | Android | Key alias inside the keystore |
| `ANDROID_KEY_PASSWORD` | Android | Password for the key |
| `ANDROID_STORE_PASSWORD` | Android | Password for the keystore |
| `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON` | Android | Base64-encoded Google Cloud service account JSON |

---

## Part 1: Apple App Store (iOS)

### 1.1 Prerequisites — Apple Developer Account

You need an active **Apple Developer Account** at developer.apple.com ($99/year).
The account must have the app already created in App Store Connect.

### 1.2 Create an App Store Connect API Key

1. Go to **App Store Connect** → [appstoreconnect.apple.com](https://appstoreconnect.apple.com)
2. Navigate to **Users and Access → Integrations → App Store Connect API**
3. Click the **"+"** button to generate a new key
4. Name: `Gatherli CD Pipeline`
5. Role: **App Manager**
6. Click **Generate**
7. **Download the `.p8` file immediately** — it can only be downloaded once

> The file will be named `AuthKey_XXXXXXXXXX.p8` where `XXXXXXXXXX` is your Key ID.

### 1.3 Find Your Credentials

**`APP_STORE_CONNECT_API_KEY_ID`**
The Key ID is the alphanumeric string in the `.p8` filename:
```
AuthKey_ABC123DEF4.p8  →  Key ID = ABC123DEF4
```
Also visible in the App Store Connect API keys list under the "Key ID" column.

**`APP_STORE_CONNECT_API_ISSUER_ID`**
On the same App Store Connect API page, the Issuer ID appears at the **top of the page**
above the keys list. Format: `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx`

**`IOS_BUNDLE_ID`**
Found in App Store Connect → your app → **App Information → Bundle ID**.
Example: `org.gatherli.app`

### 1.4 Encode and Add Secrets to GitHub

```bash
# Encode the .p8 file
base64 -i AuthKey_XXXXXXXXXX.p8 | pbcopy
```

Then go to **GitHub → Repository → Settings → Secrets and variables → Actions → New repository secret**
and add:

| Secret Name | Value |
|-------------|-------|
| `APP_STORE_CONNECT_API_KEY_BASE64` | Paste clipboard (base64 output) |
| `APP_STORE_CONNECT_API_KEY_ID` | The Key ID (e.g. `ABC123DEF4`) |
| `APP_STORE_CONNECT_API_ISSUER_ID` | The Issuer ID UUID |
| `IOS_BUNDLE_ID` | e.g. `org.gatherli.app` |

---

## Part 2: Google Play Store (Android)

### 2.1 Create a Google Play Console Account

Google Play Console requires a one-time **$25 registration fee**.

1. Go to [play.google.com/console](https://play.google.com/console)
2. Sign in with a Google account
   - If using a custom domain email (e.g. `admin@gatherli.org`) on Google Workspace,
     it will show organization account types only
   - If using a personal Gmail, select **Individual**
3. Select account type: **Individual**
4. Fill in:
   - Developer name: `Gatherli` (this is what users see in the Play Store)
   - Email address
   - Phone number
   - Website URL (can be your GitHub repo URL if no website exists yet)
5. Pay the $25 fee
6. Complete identity verification (government ID required)

> **Note:** Even as an Individual account, the public developer name can be set to
> "Gatherli" — users will see "Gatherli" not your personal name.

### 2.2 Create the App in Google Play Console

You must create the app before setting up API access.

1. Google Play Console → click **"Create app"**
2. Fill in:
   - App name: `Gatherli`
   - Default language: `English`
   - App or game: `App`
   - Free or paid: `Free`
3. Accept declarations → **Create app**

You do not need to fill in store listings or upload a build at this stage.

### 2.3 Create the Android Keystore (one-time)

> **Critical:** The keystore is permanently tied to your app on Google Play.
> If you lose it, you can never update the app again. Back it up securely
> (e.g. 1Password, encrypted cloud storage, offline USB).

Run this command in your terminal:

```bash
keytool -genkey -v -keystore gatherli-release.jks \
  -alias gatherli -keyalg RSA -keysize 2048 -validity 10000
```

You will be prompted for:
- **Keystore password** → choose a strong password → this is `ANDROID_STORE_PASSWORD`
- **Key password** → press Enter to use same as keystore → this is `ANDROID_KEY_PASSWORD`
- Name, organization, city, country → fill in as appropriate
- Confirm with `yes`

The file `gatherli-release.jks` is created in your current directory.

**Encode and copy:**
```bash
base64 -i gatherli-release.jks | pbcopy
```

Add to GitHub Secrets:

| Secret Name | Value |
|-------------|-------|
| `ANDROID_KEYSTORE_BASE64` | Paste clipboard (base64 output) |
| `ANDROID_KEY_ALIAS` | `gatherli` (the value you passed to `-alias`) |
| `ANDROID_KEY_PASSWORD` | The key password you chose |
| `ANDROID_STORE_PASSWORD` | The keystore password you chose |

### 2.4 Create a Google Cloud Service Account

Google removed the API access tab from Play Console. Service accounts are now
created directly in Google Cloud Console.

1. Go to **[console.cloud.google.com](https://console.cloud.google.com)**
2. Select or create a project (e.g. `gatherli`)
3. Left sidebar → **IAM & Admin → Service Accounts**
4. Click **"Create Service Account"**
   - Name: `gatherli-cd-pipeline`
   - Click **Create and Continue**
   - Skip the role assignment here → **Continue → Done**
5. Click on your new service account in the list
6. Go to the **Keys** tab → **Add Key → Create new key → JSON → Create**
7. The JSON file downloads automatically — store it securely

The service account email looks like:
```
gatherli-cd-pipeline@your-project-id.iam.gserviceaccount.com
```

### 2.5 Grant the Service Account Access in Play Console

1. Google Play Console → **Users and permissions** (left sidebar)
2. Click **"Invite new users"**
3. Email: paste the service account email from Step 2.4
4. Under **Account permissions → Releases**, check:
   - ✅ **Release to production, exclude devices, and use Play App Signing**
   - ✅ **Release apps to testing tracks**
5. Under **Account permissions → App access**, check:
   - ✅ **View app information and download bulk reports (read-only)**
6. Click **Apply → Invite user**

### 2.6 Encode and Add the JSON to GitHub

```bash
base64 -i path/to/downloaded-key.json | pbcopy
```

Add to GitHub Secrets:

| Secret Name | Value |
|-------------|-------|
| `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON` | Paste clipboard (base64 output) |

---

## Part 3: Verify All Secrets Are Present

Go to **GitHub → Repository → Settings → Secrets and variables → Actions**
and confirm all 9 secrets exist:

```
APP_STORE_CONNECT_API_KEY_BASE64     ✅
APP_STORE_CONNECT_API_KEY_ID         ✅
APP_STORE_CONNECT_API_ISSUER_ID      ✅
IOS_BUNDLE_ID                        ✅
ANDROID_KEYSTORE_BASE64              ✅
ANDROID_KEY_ALIAS                    ✅
ANDROID_KEY_PASSWORD                 ✅
ANDROID_STORE_PASSWORD               ✅
GOOGLE_PLAY_SERVICE_ACCOUNT_JSON     ✅
```

---

## Security Notes

- **Never commit** the `.jks` keystore, `.p8` key file, or service account JSON to Git
- **Back up the keystore** outside the repository — losing it means losing the ability
  to publish updates to Google Play
- The `.p8` file can only be downloaded once from App Store Connect — if lost,
  revoke and create a new key, then update the GitHub Secret
- Rotate secrets immediately if any are exposed or a team member with access leaves
- Add to `.gitignore`:
  ```
  *.jks
  *.p8
  *.mobileprovision
  service-account*.json
  ```
