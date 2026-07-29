#!/usr/bin/env bash
set -euo pipefail

ROOT="${1:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
PROJECT="$ROOT/BUILT.xcodeproj"
SCHEME="BUILT"
TEST_PLAN="BUILT UI Tests"
DESTINATION="${DESTINATION:-platform=iOS Simulator,name=iPhone 16 Pro}"
UI_DERIVED_DATA="$HOME/Library/Developer/Xcode/DerivedData/BUILT-CLI-UIRelease"
RELEASE_DERIVED_DATA="$HOME/Library/Developer/Xcode/DerivedData/BUILT-CLI-ReleaseBuild"
RESULTS_DIR="$ROOT/ReleasePreflight"
UI_RESULT="$RESULTS_DIR/BUILT-UI-Release.xcresult"
UI_LOG="$RESULTS_DIR/BUILT-UI-Release.log"
BUILD_LOG="$RESULTS_DIR/BUILT-Release-Build.log"

mkdir -p "$RESULTS_DIR"
rm -rf "$UI_RESULT"

echo "1/3 Running the 50 unit tests..."
"$ROOT/Scripts/run_unit_tests.sh"

echo "2/3 Running UI smoke and launch-performance tests..."

set -o pipefail

xcodebuild test \
    -project "$PROJECT" \
    -scheme "$SCHEME" \
    -testPlan "$TEST_PLAN" \
    -destination "$DESTINATION" \
    -derivedDataPath "$UI_DERIVED_DATA" \
    -resultBundlePath "$UI_RESULT" \
    | tee "$UI_LOG"

echo "3/3 Building the complete app in Release configuration..."

xcodebuild build \
    -project "$PROJECT" \
    -scheme "$SCHEME" \
    -configuration Release \
    -destination "generic/platform=iOS Simulator" \
    -derivedDataPath "$RELEASE_DERIVED_DATA" \
    CODE_SIGNING_ALLOWED=NO \
    | tee "$BUILD_LOG"

echo "✅ BUILT release preflight passed."
echo "UI result bundle: $UI_RESULT"
echo "Release build log: $BUILD_LOG"
