#!/usr/bin/env bash
set -euo pipefail

ROOT="${1:-$HOME/Desktop/BUILT}"
PROJECT="$ROOT/BUILT.xcodeproj"
SCHEME="BUILT"

if [[ ! -d "$PROJECT" ]]; then
    echo "Error: could not find $PROJECT"
    exit 1
fi

if ! command -v xcodebuild >/dev/null 2>&1; then
    echo "Error: xcodebuild is unavailable."
    echo "Open Xcode once and install its command-line components."
    exit 1
fi

if ! command -v xcrun >/dev/null 2>&1; then
    echo "Error: xcrun is unavailable."
    exit 1
fi

echo "Xcode:"
xcodebuild -version
echo

SIMULATOR_JSON="$(
    xcrun simctl list devices available --json
)"

SIMULATOR_INFO="$(
    printf '%s' "$SIMULATOR_JSON" |
    python3 -c '
import json
import sys

payload = json.load(sys.stdin)
devices = []

for runtime, runtime_devices in payload.get("devices", {}).items():
    for device in runtime_devices:
        name = device.get("name", "")
        udid = device.get("udid", "")
        state = device.get("state", "")

        if "iPhone" not in name or not udid:
            continue

        devices.append(
            {
                "name": name,
                "udid": udid,
                "state": state,
                "runtime": runtime,
            }
        )

if not devices:
    raise SystemExit(
        "No available iPhone simulator was found."
    )

preferred_names = [
    "iPhone 17 Pro",
    "iPhone 17",
    "iPhone 16 Pro",
    "iPhone 16",
    "iPhone 15 Pro",
    "iPhone 15",
]

booted = [
    device
    for device in devices
    if device["state"] == "Booted"
]

if booted:
    selected = booted[0]
else:
    selected = None

    for preferred in preferred_names:
        selected = next(
            (
                device
                for device in devices
                if device["name"] == preferred
            ),
            None,
        )

        if selected:
            break

    selected = selected or devices[0]

print(
    selected["udid"]
    + "\t"
    + selected["name"]
    + "\t"
    + selected["runtime"]
)
'
)"

IFS=$'\t' read -r \
    SIMULATOR_UDID \
    SIMULATOR_NAME \
    SIMULATOR_RUNTIME \
    <<< "$SIMULATOR_INFO"

echo "Simulator:"
echo "  $SIMULATOR_NAME"
echo "  $SIMULATOR_RUNTIME"
echo "  $SIMULATOR_UDID"
echo

open -a Simulator >/dev/null 2>&1 || true
xcrun simctl boot \
    "$SIMULATOR_UDID" \
    >/dev/null 2>&1 \
    || true

xcrun simctl bootstatus \
    "$SIMULATOR_UDID" \
    -b

RESULT_DIRECTORY="$ROOT/TestResults"
DERIVED_DATA="$ROOT/.derivedData-tests"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
RESULT_BUNDLE="$RESULT_DIRECTORY/BUILTTests-$TIMESTAMP.xcresult"
LOG_FILE="$RESULT_DIRECTORY/BUILTTests-$TIMESTAMP.log"

mkdir -p "$RESULT_DIRECTORY"
rm -rf "$RESULT_BUNDLE"

echo
echo "Running BUILT unit tests..."
echo "Result bundle:"
echo "  $RESULT_BUNDLE"
echo

set +e
set -o pipefail

xcodebuild test \
    -project "$PROJECT" \
    -scheme "$SCHEME" \
    -destination \
        "platform=iOS Simulator,id=$SIMULATOR_UDID" \
    -derivedDataPath "$DERIVED_DATA" \
    -resultBundlePath "$RESULT_BUNDLE" \
    -enableCodeCoverage YES \
    -parallel-testing-enabled NO \
    -only-testing:BUILTTests \
    2>&1 |
    tee "$LOG_FILE"

TEST_STATUS="${PIPESTATUS[0]}"
set -e

echo
echo "Test summary:"
xcrun xcresulttool get \
    test-results summary \
    --path "$RESULT_BUNDLE" \
    2>/dev/null \
    || true

echo
echo "Full log:"
echo "  $LOG_FILE"
echo
echo "Xcode result bundle:"
echo "  $RESULT_BUNDLE"

if [[ "$TEST_STATUS" -ne 0 ]]; then
    echo
    echo "❌ BUILT unit tests failed."
    exit "$TEST_STATUS"
fi

echo
echo "✅ BUILT unit tests passed."
