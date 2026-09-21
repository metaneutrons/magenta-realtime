#!/usr/bin/env bash
# Copyright 2026 Google LLC
#
# Submit a distributable archive to Apple's notary service. Authentication is
# selected at runtime so CMake targets work in CI and non-interactive shells:
#
#   1. App Store Connect API key supplied through APPLE_API_KEY,
#      APPLE_API_ISSUER, and base64-encoded APPLE_API_KEY_CONTENT; or
#   2. a preconfigured notarytool keychain profile.

set -euo pipefail

if [[ "$#" -ne 2 ]]; then
    echo "Usage: $0 <archive.zip> <keychain-profile>" >&2
    exit 2
fi

ARCHIVE_PATH="$1"
KEYCHAIN_PROFILE="$2"

if [[ ! -f "$ARCHIVE_PATH" ]]; then
    echo "Notarization archive does not exist: $ARCHIVE_PATH" >&2
    exit 2
fi

if [[ -n "${APPLE_API_KEY:-}" && -n "${APPLE_API_ISSUER:-}" && -n "${APPLE_API_KEY_CONTENT:-}" ]]; then
    # notarytool requires a file for an API private key. Keep it private and
    # delete it when this process exits; no credential is copied into the repo
    # or persistent keychain.
    NOTARY_KEY_PATH="$(mktemp "${TMPDIR:-/tmp}/magentart-notary-key.XXXXXX")"
    cleanup_notary_key() {
        command rm -f -- "$NOTARY_KEY_PATH"
    }
    trap cleanup_notary_key EXIT HUP INT TERM
    chmod 600 "$NOTARY_KEY_PATH"
    if [[ "$APPLE_API_KEY_CONTENT" == *'-----BEGIN '*'PRIVATE KEY-----'* ]]; then
        # Local developer configuration may retain the original PEM. CI always
        # uses the base64 form validated by the release preflight.
        printf '%s' "$APPLE_API_KEY_CONTENT" > "$NOTARY_KEY_PATH"
    else
        printf '%s' "$APPLE_API_KEY_CONTENT" | base64 -D > "$NOTARY_KEY_PATH"
    fi
    openssl pkey -in "$NOTARY_KEY_PATH" -noout >/dev/null

    echo "Submitting with the App Store Connect API key."
    xcrun notarytool submit "$ARCHIVE_PATH" \
        --key "$NOTARY_KEY_PATH" \
        --key-id "$APPLE_API_KEY" \
        --issuer "$APPLE_API_ISSUER" \
        --wait
else
    echo "Submitting with notarytool keychain profile: $KEYCHAIN_PROFILE"
    xcrun notarytool submit "$ARCHIVE_PATH" \
        --keychain-profile "$KEYCHAIN_PROFILE" \
        --wait
fi
