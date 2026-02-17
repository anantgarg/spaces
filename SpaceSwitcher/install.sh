#!/bin/bash
set -e

cd "$(dirname "$0")"

APP_NAME="SpaceSwitcher"
PROD_NAME="Spaces"
PROD_BUNDLE_ID="com.spaceswitcher.Spaces"
DEST="/Applications/$PROD_NAME.app"

# Kill the running production app if any
pkill -x "$PROD_NAME" 2>/dev/null && sleep 0.5 || true

# Build release
echo "Building $PROD_NAME..."
xcodebuild -project SpaceSwitcher.xcodeproj -scheme SpaceSwitcher -configuration Release build -quiet

# Find the built app
BUILD_DIR=$(xcodebuild -project SpaceSwitcher.xcodeproj -scheme SpaceSwitcher -configuration Release -showBuildSettings 2>/dev/null | grep -m1 'BUILT_PRODUCTS_DIR' | awk '{print $3}')
BUILT_APP="$BUILD_DIR/$APP_NAME.app"

# Copy to a temp location for renaming
TEMP_APP="/tmp/$PROD_NAME.app"
rm -rf "$TEMP_APP"
cp -R "$BUILT_APP" "$TEMP_APP"

# Patch bundle ID and display name
PLIST="$TEMP_APP/Contents/Info.plist"
/usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier $PROD_BUNDLE_ID" "$PLIST"
/usr/libexec/PlistBuddy -c "Set :CFBundleDisplayName $PROD_NAME" "$PLIST"
/usr/libexec/PlistBuddy -c "Set :CFBundleName $PROD_NAME" "$PLIST"

# Re-sign after modifying the plist
codesign --force --sign - "$TEMP_APP"

# Install to /Applications
echo "Installing to $DEST..."
rm -rf "$DEST"
mv "$TEMP_APP" "$DEST"

# Reset accessibility so macOS re-prompts
tccutil reset Accessibility "$PROD_BUNDLE_ID" 2>/dev/null || true

# Launch the app
echo "Launching $PROD_NAME..."
open "$DEST"

echo "Done!"
