#!/usr/bin/env bash
# Copyright 2026 Google LLC
#
# Run a command with the Developer ID identities from APPLE_CERT_P12_BASE64
# available to codesign. The certificate is imported into a temporary keychain
# that is removed when the command exits. APPLE_CERT_P12_BASE64 must be
# base64-encoded PKCS#12 data and APPLE_CERT_PASSWORD its import password.

set -euo pipefail

if [[ "$#" -eq 0 ]]; then
    echo "Usage: $0 <command> [arguments...]" >&2
    exit 2
fi

if [[ -z "${APPLE_CERT_P12_BASE64:-}" || -z "${APPLE_CERT_PASSWORD:-}" ]]; then
    echo "APPLE_CERT_P12_BASE64 and APPLE_CERT_PASSWORD must be exported." >&2
    exit 2
fi

TEMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/magentart-signing.XXXXXX")"
KEYCHAIN_PATH="$TEMP_DIR/release.keychain-db"
P12_PATH="$TEMP_DIR/developer-id.p12"
KEYCHAIN_PASSWORD="$(uuidgen)"
ORIGINAL_KEYCHAINS=()

while IFS= read -r keychain_line; do
    keychain_path="${keychain_line#*\"}"
    keychain_path="${keychain_path%\"*}"
    [[ -n "$keychain_path" ]] && ORIGINAL_KEYCHAINS+=("$keychain_path")
done < <(security list-keychains -d user)

cleanup() {
    if [[ "${#ORIGINAL_KEYCHAINS[@]}" -gt 0 ]]; then
        security list-keychains -d user -s "${ORIGINAL_KEYCHAINS[@]}" >/dev/null 2>&1 || true
    fi
    security delete-keychain "$KEYCHAIN_PATH" >/dev/null 2>&1 || true
    command rm -rf -- "$TEMP_DIR"
}
trap cleanup EXIT HUP INT TERM

printf '%s' "$APPLE_CERT_P12_BASE64" | base64 -D > "$P12_PATH"
security create-keychain -p "$KEYCHAIN_PASSWORD" "$KEYCHAIN_PATH"
security set-keychain-settings -lut 21600 "$KEYCHAIN_PATH"
security unlock-keychain -p "$KEYCHAIN_PASSWORD" "$KEYCHAIN_PATH"
security import "$P12_PATH" -k "$KEYCHAIN_PATH" -P "$APPLE_CERT_PASSWORD" -A >/dev/null
security set-key-partition-list -S apple-tool:,apple:,codesign: -s \
    -k "$KEYCHAIN_PASSWORD" "$KEYCHAIN_PATH" >/dev/null
security list-keychains -d user -s "$KEYCHAIN_PATH" "${ORIGINAL_KEYCHAINS[@]}"

export MAGENTART_SIGNING_KEYCHAIN_READY=1
"$@"
