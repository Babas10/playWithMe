# Firebase Configuration Security Guide

⚠️ **CRITICAL SECURITY NOTICE** ⚠️

Firebase configuration files contain sensitive API keys and project identifiers that must NEVER be committed to version control.

## 🚫 What NOT to Do

- **NEVER** commit `google-services.json` files
- **NEVER** commit `GoogleService-Info.plist` files
- **NEVER** commit `.firebase_projects.json` files
- **NEVER** share these files in public repositories

## ✅ Secure Setup Process

### Step 1: Download Firebase Config Files
1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your project (playwithme-dev, playwithme-stg, or playwithme-prod)
3. Go to Project Settings → General tab
4. Download configuration files for your platforms

### Step 2: Place Files in Correct Locations
```bash
# Android files
android/app/src/dev/google-services.json      # From playwithme-dev
android/app/src/stg/google-services.json      # From playwithme-stg
android/app/src/prod/google-services.json     # From playwithme-prod

# iOS files
ios/Runner/Firebase/dev/GoogleService-Info.plist    # From playwithme-dev
ios/Runner/Firebase/stg/GoogleService-Info.plist    # From playwithme-stg
ios/Runner/Firebase/prod/GoogleService-Info.plist   # From playwithme-prod
```

### Step 3: Generate Type-Safe Configuration
```bash
# Generate Dart configuration files from downloaded configs
dart run tools/generate_firebase_config.dart dev
dart run tools/generate_firebase_config.dart stg
dart run tools/generate_firebase_config.dart prod
```

### Step 4: Validate Configuration
```bash
# Validate all configurations are correct
dart run tools/validate_firebase_config.dart
```

## 🔒 Security Features

### Gitignore Protection
The following patterns are automatically ignored:
- `android/app/src/*/google-services.json`
- `ios/Runner/Firebase/*/GoogleService-Info.plist`
- `.firebase_projects.json`
- `lib/core/config/firebase_config_*.dart` (generated files)

### Helper Scripts
- `tools/replace_firebase_configs.dart` - Interactive replacement guide
- `tools/generate_firebase_config.dart` - Generate type-safe Dart configs
- `tools/validate_firebase_config.dart` - Validate configuration files

## 🚨 If Secrets Are Exposed

If Firebase configuration files are accidentally committed:

1. **Immediately rotate API keys** in Firebase Console
2. **Remove files from git history**:
   ```bash
   git filter-branch --force --index-filter \
     'git rm --cached --ignore-unmatch android/app/src/*/google-services.json ios/Runner/Firebase/*/GoogleService-Info.plist' \
     --prune-empty --tag-name-filter cat -- --all
   ```
3. **Force push to update remote**:
   ```bash
   git push --force-with-lease --all
   git push --force-with-lease --tags
   ```
4. **Verify secrets are removed** from GitHub/repository

## 📋 Bundle ID Requirements

Ensure downloaded configuration files have correct bundle IDs:

### Android
- Dev: `com.playwithme.play_with_me.dev`
- Staging: `com.playwithme.play_with_me.stg`
- Production: `com.playwithme.play_with_me`

### iOS
- Dev: `com.playwithme.playWithMe.dev`
- Staging: `com.playwithme.playWithMe.stg`
- Production: `com.playwithme.playWithMe`

## 🔄 Team Setup

When new team members join:
1. Share this security guide
2. Grant them access to Firebase projects
3. Have them follow the secure setup process
4. **Never share config files directly**

---

Remember: **Security is everyone's responsibility!** 🔐