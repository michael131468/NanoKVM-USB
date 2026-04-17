#!/usr/bin/env bash
set -euo pipefail

APP="dist/mac-arm64/NanoKVM-USB.app"

pnpm build:mac

echo "Re-signing app bundle..."
codesign --force --deep --sign - "$APP"

echo "Removing quarantine..."
xattr -dr com.apple.quarantine "$APP"

echo "Done. Opening app..."
open "$APP"
