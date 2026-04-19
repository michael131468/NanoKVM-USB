#!/usr/bin/env bash
set -euo pipefail

if [[ "$(uname)" != "Darwin" ]]; then
  echo "Error: build-mac.sh must run on macOS (got $(uname))" >&2
  exit 1
fi

DESKTOP_DIR="$(cd "$(dirname "$0")/.." && pwd)"
NATIVE_DIR="$DESKTOP_DIR/native/macos"
APP="dist/mac-arm64/NanoKVM-USB.app"

# Build native mouse hook addon against Electron's Node headers
ELECTRON_VERSION=$(node -e "console.log(require('$DESKTOP_DIR/node_modules/electron/package.json').version)")
echo "Building native mouse hook for Electron $ELECTRON_VERSION..."
cd "$NATIVE_DIR"
npm install --ignore-scripts
npx node-gyp rebuild \
  --target="$ELECTRON_VERSION" \
  --arch=arm64 \
  --dist-url=https://electronjs.org/headers

# Copy built .node into resources so electron-builder picks it up via asarUnpack
mkdir -p "$DESKTOP_DIR/resources/native"
cp "$NATIVE_DIR/build/Release/mouse_hook.node" "$DESKTOP_DIR/resources/native/"

cd "$DESKTOP_DIR"
pnpm build:mac

echo "Re-signing app bundle..."
codesign --force --deep --sign - "$APP"

echo "Removing quarantine..."
xattr -dr com.apple.quarantine "$APP"

echo "Done. Opening app..."
open "$APP"
