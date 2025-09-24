# Firebase Configuration Files Replacement Guide

This document provides step-by-step instructions for replacing placeholder Firebase configuration files with real ones from your Firebase projects.

## Prerequisites

Before replacing configuration files, ensure:
- [ ] Firebase projects have been created:
  - `playwithme-dev`
  - `playwithme-stg`
  - `playwithme-prod`
- [ ] Android and iOS apps have been registered in each Firebase project with correct bundle IDs
- [ ] You have administrative access to all Firebase projects

## Bundle ID Requirements

Each Firebase app must be registered with the following bundle IDs:

| Environment | Android Package Name | iOS Bundle ID |
|-------------|---------------------|---------------|
| Development | `com.playwithme.play_with_me.dev` | `com.playwithme.playWithMe.dev` |
| Staging | `com.playwithme.play_with_me.stg` | `com.playwithme.playWithMe.stg` |
| Production | `com.playwithme.play_with_me` | `com.playwithme.playWithMe` |

## Step 1: Download Configuration Files from Firebase Console

### For Each Environment (dev, stg, prod):

#### Android Configuration
1. Go to Firebase Console → Project Settings → Your Apps
2. Select the Android app for the environment
3. Download the `google-services.json` file
4. Verify the file contains the correct `package_name` in the JSON

#### iOS Configuration
1. Go to Firebase Console → Project Settings → Your Apps
2. Select the iOS app for the environment
3. Download the `GoogleService-Info.plist` file
4. Verify the file contains the correct `BUNDLE_ID` in the plist

## Step 2: Replace Placeholder Files

### Android Files
Replace the following placeholder files with your downloaded configs:

```bash
# Development
android/app/src/dev/google-services.json

# Staging
android/app/src/stg/google-services.json

# Production
android/app/src/prod/google-services.json
```

### iOS Files
Replace the following placeholder files with your downloaded configs:

```bash
# Development
ios/Runner/Firebase/dev/GoogleService-Info.plist

# Staging
ios/Runner/Firebase/stg/GoogleService-Info.plist

# Production
ios/Runner/Firebase/prod/GoogleService-Info.plist
```

## Step 3: Validation

After replacing the files, run the validation script to ensure everything is correctly configured:

```bash
# Run the validation script (to be created)
dart run tools/validate_firebase_config.dart
```

## Step 4: Test the Configuration

### Build Test
Test that each flavor builds correctly:

```bash
# Test dev flavor
flutter build apk --flavor dev -t lib/main_dev.dart --debug

# Test staging flavor
flutter build apk --flavor stg -t lib/main_stg.dart --debug

# Test production flavor
flutter build apk --flavor prod -t lib/main_prod.dart --debug
```

### Runtime Test
Run each flavor and verify the Firebase connection:

```bash
# Run dev and check logs for Firebase initialization
flutter run --flavor dev -t lib/main_dev.dart

# Run staging and check logs for Firebase initialization
flutter run --flavor stg -t lib/main_stg.dart

# Run production and check logs for Firebase initialization
flutter run --flavor prod -t lib/main_prod.dart
```

Look for log messages indicating successful Firebase initialization with the correct project ID.

## Verification Checklist

After replacement, verify:

- [ ] All placeholder files have been replaced with real configuration files
- [ ] Bundle IDs in config files match the flavor requirements
- [ ] Project IDs in config files match your Firebase projects
- [ ] All flavors build successfully
- [ ] Firebase initialization logs show correct project connections
- [ ] No placeholder API keys remain (keys starting with "AIzaSy" followed by "DEV", "STG", or "PROD")

## Security Notes

- **Never commit real Firebase configuration files to public repositories**
- Consider using environment variables for sensitive configuration in CI/CD
- Real API keys should not contain placeholder text
- Ensure `.gitignore` is configured appropriately if needed

## Troubleshooting

### Build Errors
- Verify bundle IDs match exactly between config files and flavor configuration
- Ensure all required Firebase services are enabled in Firebase Console
- Check that configuration files are valid JSON/plist format

### Runtime Errors
- Check Flutter logs for Firebase initialization errors
- Verify internet connectivity for Firebase services
- Ensure Firebase services (Auth, Firestore) are enabled in the correct projects

### Bundle ID Mismatches
- Double-check bundle IDs in both the Firebase Console and config files
- Ensure iOS bundle ID uses camelCase: `com.playwithme.playWithMe.dev`
- Ensure Android package name uses snake_case: `com.playwithme.play_with_me.dev`

## Next Steps

Once all configuration files are replaced and validated:
1. Test basic Firebase operations (authentication, database reads/writes)
2. Verify environment isolation (data in dev doesn't appear in staging/prod)
3. Set up CI/CD pipeline with appropriate configuration management
4. Document any environment-specific Firebase settings or rules