#!/usr/bin/env bash
# Configure the iOS Xcode project for Ship of Harkinian.
#
# STATUS: this invocation configures both libultraship and the full Ship of
# Harkinian app. HarkinianPad's maintained source patches close plan work
# items 1-4; the full unsigned arm64 iOS app links successfully.
#
# Requires: macOS, Xcode + command line tools, CMake >= 3.24.
#
# Usage:
#   scripts/configure-ios.sh                 # configure LUS alone
#   scripts/generate-port-archive.sh         # required before full app packaging
#   scripts/configure-ios.sh --soh           # configure the full SoH app
#   IOS_PLATFORM=SIMULATORARM64 scripts/configure-ios.sh --soh
#   BUNDLE_ID=com.example.soh DEVELOPMENT_TEAM=ABCDE12345 scripts/configure-ios.sh --soh
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SRC="$ROOT/sources/Shipwright"
"$ROOT/scripts/verify-sources.py" >/dev/null
# Xcode 27 accepts iOS deployment targets from 15.0 (14.0 fails CMake's try-compile).
DEPLOYMENT_TARGET="${DEPLOYMENT_TARGET:-15.0}"
BUNDLE_ID="${BUNDLE_ID:-com.chrissotraidis.harkinianpad}"
# One version for the app, its release and PadMint: version.json.
HARKINIANPAD_VERSION="${HARKINIANPAD_VERSION:-$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1]))["version"])' "$ROOT/version.json")}"
HARKINIANPAD_BUILD_NUMBER="${HARKINIANPAD_BUILD_NUMBER:-$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1]))["build"])' "$ROOT/version.json")}"
IOS_PLATFORM="${IOS_PLATFORM:-OS64COMBINED}"

if [[ ! "$HARKINIANPAD_VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "HARKINIANPAD_VERSION must use numeric major.minor.patch form." >&2
    exit 2
fi
if [[ ! "$HARKINIANPAD_BUILD_NUMBER" =~ ^[1-9][0-9]*$ ]]; then
    echo "HARKINIANPAD_BUILD_NUMBER must be a positive integer." >&2
    exit 2
fi

if [ ! -d "$SRC" ]; then
    echo "sources/Shipwright not found — run scripts/clone-sources.sh first." >&2
    exit 1
fi

TARGET_DIR="$SRC/libultraship"
BUILD_DIR="$ROOT/build-ios-lus"
if [ "${1:-}" = "--soh" ]; then
    TARGET_DIR="$SRC"
    BUILD_DIR="$ROOT/build-ios-soh"
    if [ ! -f "$SRC/soh/soh.o2r" ]; then
        echo "ROM-free soh.o2r not found." >&2
        echo "Run scripts/generate-port-archive.sh before configuring the full app." >&2
        exit 1
    fi
fi
if [ "$IOS_PLATFORM" = "SIMULATORARM64" ]; then
    BUILD_DIR="${BUILD_DIR}-sim"
fi

set -- cmake -Wno-unused-cli \
    -S "$TARGET_DIR" -B "$BUILD_DIR" \
    -GXcode \
    -DCMAKE_SYSTEM_NAME=iOS \
    -DCMAKE_SYSTEM_VERSION="$DEPLOYMENT_TARGET" \
    -DDEPLOYMENT_TARGET="$DEPLOYMENT_TARGET" \
    -DCMAKE_OSX_DEPLOYMENT_TARGET="$DEPLOYMENT_TARGET" \
    -DCMAKE_OSX_ARCHITECTURES=arm64 \
    -DCMAKE_BUILD_TYPE:STRING=Release \
    -DENABLE_SCRIPTING=OFF \
    -DPLATFORM="$IOS_PLATFORM" \
    -DBUNDLE_ID="$BUNDLE_ID" \
    -DHARKINIANPAD_VERSION="$HARKINIANPAD_VERSION" \
    -DHARKINIANPAD_BUILD_NUMBER="$HARKINIANPAD_BUILD_NUMBER"

if [ -n "${DEVELOPMENT_TEAM:-}" ]; then
    set -- "$@" \
        "-DCMAKE_XCODE_ATTRIBUTE_DEVELOPMENT_TEAM=$DEVELOPMENT_TEAM" \
        -DSIGN_LIBRARY=ON
fi

"$@"

echo
echo "Configured: $BUILD_DIR (open the generated .xcodeproj in Xcode, or:"
echo "  cmake --build \"$BUILD_DIR\" --config Release -- -destination 'generic/platform=iOS')"
