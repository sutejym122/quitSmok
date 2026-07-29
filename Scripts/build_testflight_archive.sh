#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="${1:-$HOME/Desktop/BUILT}"
PROJECT="$ROOT/BUILT.xcodeproj"
SCHEME="BUILT"
ARTIFACT_ROOT="$ROOT/ReleaseArtifacts"
ARCHIVE_PATH="$ARTIFACT_ROOT/BUILT.xcarchive"
DERIVED_DATA="$HOME/Library/Developer/Xcode/DerivedData/BUILT-AppStore-Archive"
AUDIT_SCRIPT="$ROOT/Scripts/audit_app_store_readiness.sh"
PREFLIGHT_SCRIPT="$ROOT/Scripts/run_release_preflight.sh"

[[ -d "$PROJECT" ]] || {
    echo "Missing project: $PROJECT" >&2
    exit 1
}

[[ -x "$AUDIT_SCRIPT" ]] || {
    echo "Missing readiness audit: $AUDIT_SCRIPT" >&2
    exit 1
}

[[ -x "$PREFLIGHT_SCRIPT" ]] || {
    echo "Missing release preflight: $PREFLIGHT_SCRIPT" >&2
    exit 1
}

echo "1/4 Running release preflight..."
"$PREFLIGHT_SCRIPT"

echo
echo "2/4 Running App Store readiness audit..."
"$AUDIT_SCRIPT" "$ROOT"

echo
echo "3/4 Creating signed App Store archive..."

rm -rf "$ARCHIVE_PATH"
rm -rf "$DERIVED_DATA"
mkdir -p "$ARTIFACT_ROOT"

PROVISIONING_ARGS=()

if [[ "${ALLOW_PROVISIONING_UPDATES:-0}" == "1" ]]; then
    PROVISIONING_ARGS+=(
        -allowProvisioningUpdates
    )
fi

xcodebuild archive \
    -project "$PROJECT" \
    -scheme "$SCHEME" \
    -configuration Release \
    -destination "generic/platform=iOS" \
    -archivePath "$ARCHIVE_PATH" \
    -derivedDataPath "$DERIVED_DATA" \
    "${PROVISIONING_ARGS[@]}"

echo
echo "4/4 Verifying archive contents..."

APP_PATH="$ARCHIVE_PATH/Products/Applications/BUILT.app"
WIDGET_PATH="$APP_PATH/PlugIns/BUILTWidgetsExtension.appex"

[[ -d "$APP_PATH" ]] || {
    echo "Archive does not contain BUILT.app." >&2
    exit 1
}

[[ -d "$WIDGET_PATH" ]] || {
    echo "Archive does not contain the widget extension." >&2
    exit 1
}

[[ -f "$APP_PATH/PrivacyInfo.xcprivacy" ]] || {
    echo "Main app privacy manifest is missing from archive." >&2
    exit 1
}

[[ -f "$WIDGET_PATH/PrivacyInfo.xcprivacy" ]] || {
    echo "Widget privacy manifest is missing from archive." >&2
    exit 1
}

if find "$APP_PATH" -name 'Products.storekit' -print -quit \
    | grep -q .; then
    echo "Products.storekit was found inside the archive." >&2
    exit 1
fi

codesign --verify --deep --strict --verbose=2 "$APP_PATH"
codesign --verify --strict --verbose=2 "$WIDGET_PATH"

APP_VERSION="$(
    /usr/libexec/PlistBuddy \
        -c 'Print :CFBundleShortVersionString' \
        "$APP_PATH/Info.plist"
)"

APP_BUILD="$(
    /usr/libexec/PlistBuddy \
        -c 'Print :CFBundleVersion' \
        "$APP_PATH/Info.plist"
)"

APP_BUNDLE_ID="$(
    /usr/libexec/PlistBuddy \
        -c 'Print :CFBundleIdentifier' \
        "$APP_PATH/Info.plist"
)"

cat > "$ARTIFACT_ROOT/archive-summary.txt" <<SUMMARY
BUILT archive verification passed.

Bundle ID: $APP_BUNDLE_ID
Version: $APP_VERSION
Build: $APP_BUILD
Archive: $ARCHIVE_PATH

Privacy manifests:
- Main app: present
- Widget: present

Local StoreKit configuration:
- Not bundled

Code signatures:
- Main app: valid
- Widget: valid
SUMMARY

echo
cat "$ARTIFACT_ROOT/archive-summary.txt"
echo
echo "✅ BUILT App Store archive passed local verification."
echo
echo "Open it in Organizer:"
echo "  open \"$ARCHIVE_PATH\""
