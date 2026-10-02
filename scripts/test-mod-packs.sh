#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TEST_DIR="$(mktemp -d /tmp/harkinianpad-mod-test.XXXXXX)"
trap 'rm -rf "$TEST_DIR"' EXIT
# These native tests need libzip; the player app build does not use this helper.
read -r -a ZIP_CFLAGS <<< "$(pkg-config --cflags libzip)"
read -r -a ZIP_LIBS <<< "$(pkg-config --libs libzip)"
MPQ_CFLAGS=()
MPQ_LIBS=()
if [ -f "$ROOT/build-ios-soh/_deps/stormlib-src/CMakeLists.txt" ]; then
    # Portable resource generation no longer builds the native archive tool.
    # Build only StormLib so the OTR fixture still runs after an iOS build.
    STORM_SOURCE="$ROOT/build-ios-soh/_deps/stormlib-src"
    STORM_BUILD="$ROOT/build-host-mod-tests/stormlib"
    cmake -S "$STORM_SOURCE" -B "$STORM_BUILD" \
        -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=OFF \
        -DSTORM_SKIP_INSTALL=ON -DSTORM_USE_BUNDLED_LIBRARIES=ON
    cmake --build "$STORM_BUILD" --target storm --parallel 2
    MPQ_CFLAGS=(-DINCLUDE_MPQ_SUPPORT -I"$STORM_SOURCE/src")
    MPQ_LIBS=("$STORM_BUILD/libstorm.a")
elif [ -f "$ROOT/build-host-soh/_deps/stormlib-build/libstorm.a" ]; then
    MPQ_CFLAGS=(-DINCLUDE_MPQ_SUPPORT -I"$ROOT/build-host-soh/_deps/stormlib-src/src")
    MPQ_LIBS=("$ROOT/build-host-soh/_deps/stormlib-build/libstorm.a" -lz -lbz2)
else
    echo "OTR fixture unavailable: run scripts/build-ios.sh --device first" >&2
    exit 1
fi
"${CXX:-c++}" -std=c++20 -Wall -Wextra -Werror \
    "${ZIP_CFLAGS[@]}" ${MPQ_CFLAGS[@]+"${MPQ_CFLAGS[@]}"} -I"$ROOT/sources/Shipwright/soh/soh/Enhancements" \
    "$ROOT/tests/mod_packs_test.cpp" \
    "$ROOT/sources/Shipwright/soh/soh/Enhancements/ModPackImport.cpp" \
    "${ZIP_LIBS[@]}" ${MPQ_LIBS[@]+"${MPQ_LIBS[@]}"} -o "$TEST_DIR/mod_packs_test"
if [ "$#" -eq 1 ]; then set -- "$1" "$TEST_DIR/real-pack"; fi
"$TEST_DIR/mod_packs_test" "$TEST_DIR" "$@"
