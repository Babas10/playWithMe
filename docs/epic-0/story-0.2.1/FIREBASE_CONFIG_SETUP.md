# Firebase Configuration Setup

This document explains how to configure Firebase for the PlayWithMe app's multi-environment setup using **dynamic configuration generation**.

## ⚠️ Security Notice

Firebase configuration files contain **sensitive API keys and project IDs** that should **never** be committed to version control. This setup uses a secure approach where:

- ✅ Raw Firebase config files are in `.gitignore`
- ✅ Generated Dart config files are also in `.gitignore`
- ✅ Only the configuration generation tools are tracked in git
- ✅ No hardcoded sensitive values anywhere

## How It Works

1. **You download** Firebase config files and place them locally (never committed)
2. **Build-time generation** reads your config files and creates type-safe Dart classes
3. **Your app uses** the generated Dart configs instead of raw Firebase files
4. **Everything sensitive** stays local and secure

## Required Firebase Projects

Create three separate Firebase projects:

1. **playwithme-dev** - Development environment
2. **playwithme-stg** - Staging environment
3. **playwithme-prod** - Production environment

## Setup Instructions

### 1. Create Firebase Projects

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create three projects with the names above
3. Enable the required services (Authentication, Firestore, etc.) for each project

### 2. Configure Android Apps

For each Firebase project, add an Android app with these package names:

- **Dev**: `com.playwithme.playWithMe.dev`
- **Staging**: `com.playwithme.playWithMe.stg`
- **Production**: `com.playwithme.playWithMe`

### 3. Configure iOS Apps

For each Firebase project, add an iOS app with these bundle IDs:

- **Dev**: `com.playwithme.playWithMe.dev`
- **Staging**: `com.playwithme.playWithMe.stg`
- **Production**: `com.playwithme.playWithMe`

### 4. Download Configuration Files

Download the configuration files from Firebase Console and place them in these **exact locations**:

#### Android Configuration Files
```
android/app/src/dev/google-services.json     # From playwithme-dev
android/app/src/stg/google-services.json     # From playwithme-stg
android/app/src/prod/google-services.json    # From playwithme-prod
```

#### iOS Configuration Files
```
ios/Runner/Firebase/dev/GoogleService-Info.plist    # From playwithme-dev
ios/Runner/Firebase/stg/GoogleService-Info.plist    # From playwithme-stg
ios/Runner/Firebase/prod/GoogleService-Info.plist   # From playwithme-prod
```

### 5. Generate Configuration Files

After placing the Firebase config files, generate the Dart configuration:

```bash
# Generate config for each environment
dart tools/generate_firebase_config.dart dev
dart tools/generate_firebase_config.dart stg
dart tools/generate_firebase_config.dart prod
```

This creates type-safe Dart classes in `lib/core/config/` that your app will use.

## Usage in Code

```dart
import 'package:play_with_me/core/config/firebase_config_factory.dart';

// Get the Firebase config for current environment
final firebaseConfig = FirebaseConfigFactory.getConfig();

// Use the config
print('Project ID: ${firebaseConfig.projectId}');
print('App Name: ${firebaseConfig.displayName}');
print('Is Production: ${firebaseConfig.isProduction}');
```

## Verification

After setup, verify the configuration works:

```bash
# Test each environment
flutter run --flavor dev -t lib/main_dev.dart
flutter run --flavor stg -t lib/main_stg.dart
flutter run --flavor prod -t lib/main_prod.dart
```

## Build Process Integration

The system works seamlessly with the existing flavor system:

- **Android**: Gradle uses the correct `google-services.json` based on flavor
- **iOS**: Schemes use the correct `GoogleService-Info.plist` based on configuration
- **Dart**: Generated config classes provide type-safe access to Firebase settings

## Team Setup

When a new team member joins:

1. **Get Firebase access** - They need access to the Firebase projects
2. **Download config files** - From Firebase Console to the correct local paths
3. **Generate configs** - Run the generation commands above
4. **Start developing** - Everything works with normal Flutter commands

## Generated Files

The system generates these files (all in `.gitignore`):

```
lib/core/config/firebase_config_dev.dart     # Generated from dev configs
lib/core/config/firebase_config_stg.dart     # Generated from stg configs
lib/core/config/firebase_config_prod.dart    # Generated from prod configs
```

## Security Benefits

- 🔒 **No sensitive data in git** - Config files never committed
- 🛠️ **Type-safe** - Generated Dart classes prevent runtime errors
- 🔄 **Dynamic** - Reads from actual Firebase files, no manual data entry
- 🚀 **Build-time** - Configs generated when needed, not stored
- 👥 **Team-friendly** - Clear process for new developers

## Troubleshooting

### "Firebase configuration not found" Error

This means the Dart config files haven't been generated. Run:

```bash
dart tools/generate_firebase_config.dart <environment>
```

### "Config file not found" Error

This means the Firebase config files aren't in the expected locations. Check that you've placed:

- `android/app/src/<env>/google-services.json`
- `ios/Runner/Firebase/<env>/GoogleService-Info.plist`

### Build Errors

Make sure you've generated configs for the environment you're building:

```bash
# Before running flutter run --flavor dev
dart tools/generate_firebase_config.dart dev
```