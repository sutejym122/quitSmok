#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="${1:-$HOME/Desktop/BUILT}"
PROJECT="$ROOT/BUILT.xcodeproj"
SCHEME="BUILT"

fail() {
    echo "❌ $*" >&2
    exit 1
}

pass() {
    echo "✅ $*"
}

[[ -d "$PROJECT" ]] || fail "Missing Xcode project: $PROJECT"

for command in xcodebuild plutil python3; do
    command -v "$command" >/dev/null 2>&1 \
        || fail "Required command is unavailable: $command"
done

echo "Auditing BUILT App Store readiness..."
echo

PLISTS=(
    "$ROOT/BUILT/PrivacyInfo.xcprivacy"
    "$ROOT/BUILTWidgets/PrivacyInfo.xcprivacy"
    "$ROOT/BUILT/BUILT.entitlements"
    "$ROOT/BUILTWidgetsExtension.entitlements"
    "$ROOT/BUILT/Info.plist"
    "$ROOT/BUILTWidgets/Info.plist"
)

for plist in "${PLISTS[@]}"; do
    [[ -f "$plist" ]] || fail "Missing required file: $plist"
    plutil -lint "$plist" >/dev/null \
        || fail "Invalid plist: $plist"
done
pass "Privacy manifests, entitlements, and Info plists are valid."

python3 - "$ROOT" <<'PY'
from pathlib import Path
import plistlib
import sys

root = Path(sys.argv[1])

def load(path: Path):
    with path.open("rb") as handle:
        return plistlib.load(handle)

main_manifest = load(root / "BUILT/PrivacyInfo.xcprivacy")
widget_manifest = load(root / "BUILTWidgets/PrivacyInfo.xcprivacy")

for name, manifest in [
    ("main app", main_manifest),
    ("widget", widget_manifest),
]:
    if manifest.get("NSPrivacyTracking") is not False:
        raise SystemExit(f"{name} privacy manifest must declare no tracking.")
    if manifest.get("NSPrivacyCollectedDataTypes") != []:
        raise SystemExit(
            f"{name} privacy manifest unexpectedly declares collected data."
        )

def reasons(manifest):
    result = set()
    for entry in manifest.get("NSPrivacyAccessedAPITypes", []):
        if (
            entry.get("NSPrivacyAccessedAPIType")
            == "NSPrivacyAccessedAPICategoryUserDefaults"
        ):
            result.update(entry.get("NSPrivacyAccessedAPITypeReasons", []))
    return result

if not {"CA92.1", "1C8F.1"}.issubset(reasons(main_manifest)):
    raise SystemExit(
        "Main app privacy manifest is missing UserDefaults reasons."
    )

if "1C8F.1" not in reasons(widget_manifest):
    raise SystemExit(
        "Widget privacy manifest is missing the App Group UserDefaults reason."
    )

app_entitlements = load(root / "BUILT/BUILT.entitlements")
widget_entitlements = load(root / "BUILTWidgetsExtension.entitlements")

expected_group = "group.com.sutej.built"

for name, entitlements in [
    ("main app", app_entitlements),
    ("widget", widget_entitlements),
]:
    groups = entitlements.get(
        "com.apple.security.application-groups",
        [],
    )
    if expected_group not in groups:
        raise SystemExit(
            f"{name} is missing app group {expected_group}."
        )

if app_entitlements.get("com.apple.developer.healthkit") is not True:
    raise SystemExit(
        "The main app is missing the HealthKit entitlement."
    )

print("Privacy and entitlement semantics validated.")
PY
pass "Privacy declarations match BUILT's local-only architecture."

PBXPROJ="$PROJECT/project.pbxproj"
SCHEME_FILE="$PROJECT/xcshareddata/xcschemes/BUILT.xcscheme"

[[ -f "$PBXPROJ" ]] || fail "Missing project.pbxproj."
[[ -f "$SCHEME_FILE" ]] || fail "Missing shared BUILT scheme."

if grep -q "Products.storekit in Resources" "$PBXPROJ"; then
    fail "Products.storekit is still copied into the shipping app bundle."
fi

grep -q "StoreKitConfigurationFileReference" "$SCHEME_FILE" \
    || fail "The BUILT scheme no longer references Products.storekit."

grep -q "Products.storekit" "$SCHEME_FILE" \
    || fail "The BUILT scheme StoreKit reference is missing."

pass "Products.storekit is development-only and remains available to the scheme."

APP_SETTINGS="$(
    xcodebuild \
        -project "$PROJECT" \
        -target BUILT \
        -configuration Release \
        -showBuildSettings
)"

WIDGET_SETTINGS="$(
    xcodebuild \
        -project "$PROJECT" \
        -target BUILTWidgetsExtension \
        -configuration Release \
        -showBuildSettings
)"

setting() {
    local text="$1"
    local key="$2"

    printf '%s\n' "$text" \
        | awk -F ' = ' -v wanted="$key" '
            $1 ~ "^[[:space:]]*" wanted "$" {
                print $2
                exit
            }
        '
}

APP_VERSION="$(setting "$APP_SETTINGS" MARKETING_VERSION)"
APP_BUILD="$(setting "$APP_SETTINGS" CURRENT_PROJECT_VERSION)"
APP_BUNDLE_ID="$(setting "$APP_SETTINGS" PRODUCT_BUNDLE_IDENTIFIER)"
APP_DEPLOYMENT="$(setting "$APP_SETTINGS" IPHONEOS_DEPLOYMENT_TARGET)"
APP_TEAM="$(setting "$APP_SETTINGS" DEVELOPMENT_TEAM)"

WIDGET_VERSION="$(setting "$WIDGET_SETTINGS" MARKETING_VERSION)"
WIDGET_BUILD="$(setting "$WIDGET_SETTINGS" CURRENT_PROJECT_VERSION)"
WIDGET_BUNDLE_ID="$(setting "$WIDGET_SETTINGS" PRODUCT_BUNDLE_IDENTIFIER)"
WIDGET_DEPLOYMENT="$(setting "$WIDGET_SETTINGS" IPHONEOS_DEPLOYMENT_TARGET)"
WIDGET_TEAM="$(setting "$WIDGET_SETTINGS" DEVELOPMENT_TEAM)"

[[ -n "$APP_VERSION" ]] || fail "Main app marketing version is empty."
[[ "$APP_BUILD" =~ ^[1-9][0-9]*$ ]] \
    || fail "Main app build must be a positive integer."
[[ "$APP_VERSION" == "$WIDGET_VERSION" ]] \
    || fail "App and widget marketing versions differ."
[[ "$APP_BUILD" == "$WIDGET_BUILD" ]] \
    || fail "App and widget build numbers differ."
[[ "$APP_TEAM" == "$WIDGET_TEAM" && -n "$APP_TEAM" ]] \
    || fail "App and widget development teams differ."
[[ "$APP_DEPLOYMENT" == "17.0" ]] \
    || fail "Expected app deployment target 17.0, found $APP_DEPLOYMENT."
[[ "$WIDGET_DEPLOYMENT" == "17.0" ]] \
    || fail "Expected widget deployment target 17.0, found $WIDGET_DEPLOYMENT."
[[ "$WIDGET_BUNDLE_ID" == "$APP_BUNDLE_ID".* ]] \
    || fail "Widget bundle ID is not nested below the app bundle ID."

pass "Version $APP_VERSION ($APP_BUILD) is synchronized."
pass "Bundle IDs and signing team are internally consistent."
pass "The release supports iOS 17.0 and later."

python3 - "$ROOT" <<'PY'
from pathlib import Path
import json
import subprocess
import sys

root = Path(sys.argv[1])
contents = root / "BUILT/Assets.xcassets/AppIcon.appiconset/Contents.json"

if not contents.exists():
    raise SystemExit(f"Missing AppIcon catalog: {contents}")

payload = json.loads(contents.read_text())
candidates = []

for image in payload.get("images", []):
    filename = image.get("filename")
    size = image.get("size")
    if filename and size == "1024x1024":
        candidates.append(contents.parent / filename)

if not candidates:
    raise SystemExit(
        "AppIcon catalog does not reference a 1024x1024 marketing icon."
    )

for image in candidates:
    if not image.exists():
        raise SystemExit(f"Missing app icon image: {image}")

    details = subprocess.check_output(
        [
            "sips",
            "-g",
            "pixelWidth",
            "-g",
            "pixelHeight",
            "-g",
            "hasAlpha",
            str(image),
        ],
        text=True,
        stderr=subprocess.STDOUT,
    )

    if "pixelWidth: 1024" not in details:
        raise SystemExit(f"{image.name} is not 1024 pixels wide.")
    if "pixelHeight: 1024" not in details:
        raise SystemExit(f"{image.name} is not 1024 pixels high.")
    if "hasAlpha: yes" in details.lower():
        raise SystemExit(f"{image.name} contains an alpha channel.")

print("1024x1024 app icon validated.")
PY
pass "App Store icon dimensions and transparency are valid."

for page in \
    "$ROOT/docs/privacy/index.html" \
    "$ROOT/docs/support/index.html"; do
    [[ -s "$page" ]] || fail "Missing public page: $page"
done

if grep -RqiE \
    'YOUR_DOMAIN|YOUR_EMAIL|REPLACE_ME|example\.com' \
    "$ROOT/docs"; then
    fail "Public pages still contain placeholder values."
fi

pass "Privacy and support pages contain no placeholders."

echo
echo "Release identity"
echo "  App:        $APP_BUNDLE_ID"
echo "  Widget:     $WIDGET_BUNDLE_ID"
echo "  Version:    $APP_VERSION"
echo "  Build:      $APP_BUILD"
echo "  Minimum OS: iOS $APP_DEPLOYMENT"
echo "  Team:       $APP_TEAM"
echo
echo "Manual App Store Connect checks still required:"
echo "  • App record exists for $APP_BUNDLE_ID"
echo "  • Lifetime Pro IAP exists and is submitted with the app"
echo "  • Agreements, tax, and banking are active"
echo "  • Privacy and support pages are publicly reachable"
echo "  • App privacy answers match the local-only implementation"
echo "  • Screenshots and review notes are complete"
echo
echo "✅ BUILT App Store readiness audit passed."
