#!/usr/bin/env bash
# Generate the pinned ROM-free resources without compiling native host tools.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SRC="$ROOT/sources/Shipwright"
"$ROOT/scripts/verify-sources.py" >/dev/null

# Preserve the established archive locations used by configure-ios and the
# maintained engine. The generator verifies an existing archive before reuse
# and refuses to replace different contents.
for ARCHIVE in "$SRC/soh/soh.o2r" "$SRC/soh.o2r" "$ROOT/build-host-soh/soh/soh.o2r"; do
    python3 "$ROOT/scripts/build-port-archive.py" \
        "$SRC/soh/assets/custom" "$SRC/libultraship/src/fast/shaders" "$ARCHIVE"
done
