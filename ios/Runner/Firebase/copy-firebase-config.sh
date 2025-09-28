#!/bin/sh

# This script copies the appropriate Firebase configuration file based on the scheme

echo "🔥 Firebase Config Copy Script"
echo "Scheme: ${CONFIGURATION}"

# Determine the flavor based on environment or configuration
if [[ "${CONFIGURATION}" == *"dev"* ]] || [[ "${FLUTTER_BUILD_MODE}" == *"dev"* ]]; then
    FLAVOR="dev"
elif [[ "${CONFIGURATION}" == *"stg"* ]] || [[ "${FLUTTER_BUILD_MODE}" == *"stg"* ]]; then
    FLAVOR="stg"
elif [[ "${CONFIGURATION}" == *"prod"* ]] || [[ "${FLUTTER_BUILD_MODE}" == *"prod"* ]]; then
    FLAVOR="prod"
else
    # Default to production if no flavor detected
    FLAVOR="prod"
    echo "⚠️  No specific flavor detected, defaulting to production"
fi

SOURCE_FILE="${SRCROOT}/Runner/Firebase/${FLAVOR}/GoogleService-Info.plist"
DEST_FILE="${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.app/GoogleService-Info.plist"

echo "📂 Source: ${SOURCE_FILE}"
echo "📂 Destination: ${DEST_FILE}"

if [ -f "${SOURCE_FILE}" ]; then
    cp "${SOURCE_FILE}" "${DEST_FILE}"
    echo "✅ Successfully copied Firebase config for ${FLAVOR} flavor"
else
    echo "❌ Error: Firebase config file not found for ${FLAVOR} flavor"
    echo "   Expected: ${SOURCE_FILE}"
    exit 1
fi

echo "🔥 Firebase config copy completed"