#!/usr/bin/env bash
# Lint only staged files covered by the repository's type-aware ESLint setup.
set -euo pipefail

files=()
for file in "$@"; do
  case "$file" in
    examples/mrt2/react_ui/*.{ts,tsx,mts,cts})
      files+=("${file#examples/}")
      ;;
  esac
done

[[ ${#files[@]} -gt 0 ]] || exit 0
cd examples
pnpm --filter magenta-rt-v2-ui exec eslint \
  --config mrt2/react_ui/config/eslint.config.js \
  --fix \
  --max-warnings=0 \
  "${files[@]}"
