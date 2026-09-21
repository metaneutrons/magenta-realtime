#!/bin/bash
# Copyright 2026 Google LLC

# Script to notarize all MRT projects and externals into separate ZIP files.
# Authenticates with App Store Connect API variables when available, otherwise
# with a pre-configured notarytool keychain profile (default: "notarytool-creds").

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
CMAKE_CMD="${CMAKE_COMMAND:-cmake}"
BUILD_DIR="$REPO_ROOT/build"

# A base64 PKCS#12 certificate can be supplied through the environment for a
# non-interactive release. Re-exec under the temporary keychain only once.
if [[ "${MAGENTART_SIGNING_KEYCHAIN_READY:-}" != "1" &&
      -n "${APPLE_CERT_P12_BASE64:-}" && -n "${APPLE_CERT_PASSWORD:-}" ]]; then
    exec bash "$SCRIPT_DIR/with-signing-keychain.sh" "$0" "$@"
fi

KEYCHAIN_PROFILE="notarytool-creds"
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --keychain-profile) KEYCHAIN_PROFILE="$2"; shift ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

echo "================================================================================"
echo "Notarizing all MRT targets using profile: $KEYCHAIN_PROFILE"
echo "================================================================================"

notarize_cmake_target() {
    local target=$1
    local name=$2
    echo ""
    echo "--------------------------------------------------------------------------------"
    echo "Notarizing $name (target: $target)..."
    echo "--------------------------------------------------------------------------------"
    "$CMAKE_CMD" --build "$BUILD_DIR" --target "$target"
}

# Notarize the four apps and three supported host plug-ins. Plug-in packaging
# stays inside the build directory; it must never populate a user's host paths.
notarize_cmake_target "notarize_mrt2_standalone" "Standalone"
notarize_cmake_target "notarize_mrt2_au" "AUv3"
notarize_cmake_target "notarize_mrt2_jam" "Jam App"
notarize_cmake_target "notarize_mrt2_collider" "Collider App"
notarize_cmake_target "notarize_mrt2_max" "Max MSP External"
notarize_cmake_target "notarize_mrt2_pd" "Pure Data External"
notarize_cmake_target "notarize_mrt2_sc" "SuperCollider UGen"

echo ""
echo "================================================================================"
echo "✓ All ZIP files successfully notarized and located in: $BUILD_DIR"
ls -la "$BUILD_DIR"/*.zip
echo "================================================================================"
