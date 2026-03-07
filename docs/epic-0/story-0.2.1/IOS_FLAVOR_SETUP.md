# iOS Flavor Setup Instructions

This document provides step-by-step instructions to set up iOS build configurations for Flutter flavors.

## Why Manual Setup?

The iOS Xcode project file (`project.pbxproj`) is complex and fragile. Programmatic modifications often cause corruption or merge conflicts. The manual approach through Xcode UI is safer and more reliable.

## Step-by-Step Setup

### 1. Open Xcode Project

```bash
open ios/Runner.xcworkspace
```

### 2. Add Build Configurations

1. **Click on "Runner" in the project navigator** (the top-level project, not the target)
2. **Ensure the Runner PROJECT is selected** (not the Runner TARGET)
3. **Go to Editor → Add Configuration → Duplicate "Debug" Configuration**
4. **Name the new configuration**: `Debug-dev`
5. **Repeat for all flavors**:
   - Duplicate "Debug" → `Debug-dev`
   - Duplicate "Debug" → `Debug-stg`
   - Duplicate "Debug" → `Debug-prod`
   - Duplicate "Release" → `Release-dev`
   - Duplicate "Release" → `Release-stg`
   - Duplicate "Release" → `Release-prod`
   - Duplicate "Profile" → `Profile-dev`
   - Duplicate "Profile" → `Profile-stg`
   - Duplicate "Profile" → `Profile-prod`

### 3. Update Bundle Identifiers

For each flavor configuration, update the bundle identifier:

1. **Select the Runner TARGET** (not project)
2. **Go to Build Settings tab**
3. **Find "Product Bundle Identifier"**
4. **Set the correct bundle ID for each configuration**:
   - `Debug-dev`, `Release-dev`, `Profile-dev` → `org.gatherli.app.dev`
   - `Debug-stg`, `Release-stg`, `Profile-stg` → `org.gatherli.app.stg`
   - `Debug-prod`, `Release-prod`, `Profile-prod` → `org.gatherli.app`

### 4. Add Firebase Config Copy Script

1. **Select the Runner TARGET**
2. **Go to Build Phases tab**
3. **Click the "+" button → New Run Script Phase**
4. **Name the script**: "Copy Firebase Config"
5. **Add this script**:

```bash
#!/bin/sh

# Determine the flavor based on configuration
if [[ "${CONFIGURATION}" == *"dev"* ]]; then
    FLAVOR="dev"
elif [[ "${CONFIGURATION}" == *"stg"* ]]; then
    FLAVOR="stg"
elif [[ "${CONFIGURATION}" == *"prod"* ]]; then
    FLAVOR="prod"
else
    FLAVOR="prod"  # Default to prod
fi

SOURCE_FILE="${SRCROOT}/Runner/Firebase/${FLAVOR}/GoogleService-Info.plist"
DEST_FILE="${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.app/GoogleService-Info.plist"

echo "🔥 Copying Firebase config for ${FLAVOR} flavor"
echo "📂 From: ${SOURCE_FILE}"
echo "📂 To: ${DEST_FILE}"

if [ -f "${SOURCE_FILE}" ]; then
    cp "${SOURCE_FILE}" "${DEST_FILE}"
    echo "✅ Successfully copied Firebase config"
else
    echo "❌ Firebase config not found: ${SOURCE_FILE}"
    exit 1
fi
```

### 5. Update Schemes

The schemes should already be configured correctly:
- `dev.xcscheme` uses Debug configuration
- `stg.xcscheme` uses Debug configuration
- `prod.xcscheme` uses Debug configuration

Flutter will automatically map `--flavor dev` to `Debug-dev` configuration, etc.

## Verification

After completing the setup, test each flavor:

```bash
# Test dev environment
flutter run --flavor dev -t lib/main_dev.dart

# Test staging environment
flutter run --flavor stg -t lib/main_stg.dart

# Test production environment
flutter run --flavor prod -t lib/main_prod.dart
```

## What This Achieves

✅ **Separate iOS app bundles** with different bundle identifiers
✅ **Automatic Firebase config switching** based on flavor
✅ **Clean separation** between dev, staging, and production environments
✅ **No hardcoded sensitive data** in the project

## Troubleshooting

### "Build configuration not found" Error

If you still get build configuration errors:

1. **Double-check configuration names** in Xcode match exactly:
   - `Debug-dev`, `Debug-stg`, `Debug-prod`
   - `Release-dev`, `Release-stg`, `Release-prod`
   - `Profile-dev`, `Profile-stg`, `Profile-prod`

2. **Ensure all configurations exist** for both PROJECT and TARGET

3. **Clean and rebuild**:
   ```bash
   flutter clean
   cd ios && rm -rf build/ && cd ..
   flutter run --flavor dev -t lib/main_dev.dart
   ```

### Firebase Config Not Found Error

Make sure you have:

1. **Downloaded Firebase config files** from Firebase Console
2. **Placed them in the correct locations**:
   - `ios/Runner/Firebase/dev/GoogleService-Info.plist`
   - `ios/Runner/Firebase/stg/GoogleService-Info.plist`
   - `ios/Runner/Firebase/prod/GoogleService-Info.plist`

3. **Added the Firebase copy script** as described above

## Alternative: Xcode Command Line

If you prefer command line, you can also add configurations using `xcodebuild`:

```bash
# This is more advanced and requires careful handling
# The manual Xcode UI method is recommended
```

---

**Note**: This manual setup is a one-time process. Once completed, all team members can use the standard Flutter flavor commands without additional iOS-specific setup.