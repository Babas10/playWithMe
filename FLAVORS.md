# Flutter Flavors Configuration

This document explains how to use the configured Flutter flavors for different environments.

## Available Flavors

The project has three configured flavors:

### 1. Development (`dev`)
- **Application ID**: `com.playwithme.play_with_me.dev`
- **Firebase Project**: `playwithme-dev`
- **Purpose**: Local development and testing
- **App Title**: PlayWithMe (Dev)

### 2. Staging (`stg`)
- **Application ID**: `com.playwithme.play_with_me.stg`
- **Firebase Project**: `playwithme-stg`
- **Purpose**: Internal testing and QA
- **App Title**: PlayWithMe (Staging)

### 3. Production (`prod`)
- **Application ID**: `com.playwithme.play_with_me`
- **Firebase Project**: `playwithme-prod`
- **Purpose**: Live application for end users
- **App Title**: PlayWithMe

## Running the App

### Command Line
```bash
# Development flavor
flutter run --flavor dev -t lib/main_dev.dart

# Staging flavor
flutter run --flavor stg -t lib/main_stg.dart

# Production flavor
flutter run --flavor prod -t lib/main_prod.dart

# Default (production)
flutter run
```

### Building for Release
```bash
# Development build
flutter build apk --flavor dev -t lib/main_dev.dart
flutter build ios --flavor dev -t lib/main_dev.dart

# Staging build
flutter build apk --flavor stg -t lib/main_stg.dart
flutter build ios --flavor stg -t lib/main_stg.dart

# Production build
flutter build apk --flavor prod -t lib/main_prod.dart
flutter build ios --flavor prod -t lib/main_prod.dart
```

## Firebase Configuration

Each flavor uses a separate Firebase project to isolate data and prevent cross-environment contamination:

### Android
Firebase configuration files are stored in:
- `android/app/src/dev/google-services.json`
- `android/app/src/stg/google-services.json`
- `android/app/src/prod/google-services.json`

### iOS
Firebase configuration files are stored in:
- `ios/Runner/Firebase/dev/GoogleService-Info.plist`
- `ios/Runner/Firebase/stg/GoogleService-Info.plist`
- `ios/Runner/Firebase/prod/GoogleService-Info.plist`

## Setting Up Firebase Projects

1. Create three Firebase projects:
   - `playwithme-dev`
   - `playwithme-stg`
   - `playwithme-prod`

2. For each project, create Android and iOS apps with the appropriate bundle IDs

3. Download the configuration files and replace the placeholder files in this repository

4. Ensure each project has the same Firebase services enabled (Authentication, Firestore, etc.)

## Environment Detection

The app automatically detects which environment it's running in and displays:
- Environment name in the app title
- Color-coded environment indicator on the home screen
- Firebase project ID for verification

## VS Code Configuration

Add these launch configurations to `.vscode/launch.json`:

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Development",
      "request": "launch",
      "type": "dart",
      "program": "lib/main_dev.dart",
      "args": ["--flavor", "dev"]
    },
    {
      "name": "Staging",
      "request": "launch",
      "type": "dart",
      "program": "lib/main_stg.dart",
      "args": ["--flavor", "stg"]
    },
    {
      "name": "Production",
      "request": "launch",
      "type": "dart",
      "program": "lib/main_prod.dart",
      "args": ["--flavor", "prod"]
    }
  ]
}
```

## Testing

To verify that flavors are working correctly:

1. Run each flavor and check the app title and environment indicator
2. Verify that the Firebase project ID matches the expected environment
3. Check that the app can install multiple versions simultaneously (different bundle IDs)

## Notes

- **Important**: Replace the placeholder Firebase configuration files with real ones from your Firebase projects
- Each flavor can be installed simultaneously on the same device due to different application IDs
- The environment configuration is set at app startup and persists throughout the app lifecycle