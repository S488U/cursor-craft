#!/usr/bin/env bash
# Build Firefox & Chromium compatible packages in dist/
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
src="$root/src"
version="$(sed -n 's/.*"version": *"\([^"]*\)".*/\1/p' "$src/manifest.json" | head -n 1)"
dist="$root/dist"
out_zip="$dist/cursor-craft-$version.zip"
out_xpi="$dist/cursor-craft-$version.xpi"

mkdir -p "$dist"
rm -f "$out_zip" "$out_xpi"

# Create extension zip
(cd "$src" && zip -r -X -q "$out_zip" manifest.json background.js swarm.js icons -x '*.DS_Store')
# Firefox signed/installable package (.xpi is a zip package)
cp "$out_zip" "$out_xpi"

echo "✅ Built packages in $dist:"
echo "   - $out_zip (for web-ext / Chrome / Firefox)"
echo "   - $out_xpi (direct Firefox add-on file)"
