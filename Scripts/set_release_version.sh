#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="${1:-$HOME/Desktop/BUILT}"
VERSION="${2:-}"
BUILD="${3:-}"
PBXPROJ="$ROOT/BUILT.xcodeproj/project.pbxproj"

usage() {
    echo "Usage:"
    echo "  $0 [project-root] <marketing-version> <build-number>"
    echo
    echo "Example:"
    echo "  $0 ~/Desktop/BUILT 1.0 2"
}

[[ -f "$PBXPROJ" ]] || {
    echo "Missing project: $PBXPROJ" >&2
    exit 1
}

if [[ -z "$VERSION" || -z "$BUILD" ]]; then
    usage
    exit 1
fi

[[ "$VERSION" =~ ^[0-9]+(\.[0-9]+){1,2}$ ]] || {
    echo "Marketing version must look like 1.0 or 1.0.1." >&2
    exit 1
}

[[ "$BUILD" =~ ^[1-9][0-9]*$ ]] || {
    echo "Build number must be a positive integer." >&2
    exit 1
}

python3 - "$PBXPROJ" "$VERSION" "$BUILD" <<'PY'
from pathlib import Path
import re
import sys

path = Path(sys.argv[1])
version = sys.argv[2]
build = sys.argv[3]
text = path.read_text()

updated, version_count = re.subn(
    r"MARKETING_VERSION = [^;]+;",
    f"MARKETING_VERSION = {version};",
    text,
)

updated, build_count = re.subn(
    r"CURRENT_PROJECT_VERSION = [^;]+;",
    f"CURRENT_PROJECT_VERSION = {build};",
    updated,
)

if version_count == 0 or build_count == 0:
    raise SystemExit("Version settings were not found in project.pbxproj.")

path.write_text(updated)

print(
    f"Updated {version_count} marketing-version settings "
    f"and {build_count} build-number settings."
)
PY

echo
echo "BUILT is now version $VERSION ($BUILD)."
echo "Review with:"
echo "  git diff -- BUILT.xcodeproj/project.pbxproj"
