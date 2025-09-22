#!/bin/bash

# This script copies the appropriate Firebase configuration file
# based on the Flutter flavor being built

FLAVOR="$1"
if [ -z "$FLAVOR" ]; then
    FLAVOR="prod"
fi

SOURCE_DIR="${SRCROOT}/Runner/Firebase/$FLAVOR"
DEST_DIR="${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.app"

echo "Copying Firebase config for flavor: $FLAVOR"
echo "Source: $SOURCE_DIR/GoogleService-Info.plist"
echo "Destination: $DEST_DIR/GoogleService-Info.plist"

if [ -f "$SOURCE_DIR/GoogleService-Info.plist" ]; then
    cp "$SOURCE_DIR/GoogleService-Info.plist" "$DEST_DIR/GoogleService-Info.plist"
    echo "Successfully copied Firebase config for $FLAVOR flavor"
else
    echo "Error: Firebase config file not found for $FLAVOR flavor"
    exit 1
fi