#!/usr/bin/env bash
set -euo pipefail

ROOT="${1:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
PROJECT="$ROOT/BUILT.xcodeproj"
SCHEME="BUILT"
TEST_PLAN="BUILT UI Tests"
DESTINATION="${DESTINATION:-platform=iOS Simulator,name=iPhone 16 Pro}"
DERIVED_DATA="$HOME/Library/Developer/Xcode/DerivedData/BUILT-CLI-UISmoke"
RESULTS_DIR="$ROOT/UITestResults"
RESULT_BUNDLE="$RESULTS_DIR/BUILT-UI-Smoke.xcresult"
LOG_FILE="$RESULTS_DIR/BUILT-UI-Smoke.log"

mkdir -p "$RESULTS_DIR"
rm -rf "$RESULT_BUNDLE"

echo "Running BUILT UI smoke tests..."
echo "Destination: $DESTINATION"

set -o pipefail

xcodebuild test \
    -project "$PROJECT" \
    -scheme "$SCHEME" \
    -testPlan "$TEST_PLAN" \
    -destination "$DESTINATION" \
    -derivedDataPath "$DERIVED_DATA" \
    -resultBundlePath "$RESULT_BUNDLE" \
    -only-testing:BUILTUITests/BUILTUISmokeTests \
    | tee "$LOG_FILE"

echo "✅ BUILT UI smoke tests passed."
echo "Result bundle: $RESULT_BUNDLE"
