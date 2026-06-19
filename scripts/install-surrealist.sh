#!/usr/bin/env bash
# Install Surrealist (SurrealDB GUI) on macOS from the latest GitHub release.
# No Homebrew cask exists; the release ships per-arch .dmg files. Idempotent.
set -euo pipefail

[ "$(uname -s)" = Darwin ] || { echo "surrealist: macOS only"; exit 0; }
[ -d /Applications/Surrealist.app ] && exit 0

case "$(uname -m)" in arm64) arch=aarch64 ;; *) arch=x64 ;; esac

# Grep the .dmg asset URLs straight out of the JSON (jq trips over control
# characters in the release-notes body).
url="$(curl -fsSL https://api.github.com/repos/surrealdb/surrealist/releases/latest \
  | grep -oE 'https://[^"]+\.dmg' | grep -i "$arch" | head -1)"
[ -n "$url" ] || { echo "surrealist: no $arch .dmg in the latest release" >&2; exit 1; }

tmp="$(mktemp -d)"
curl -fsSL -o "$tmp/Surrealist.dmg" "$url"
vol="$(hdiutil attach "$tmp/Surrealist.dmg" -nobrowse -noverify | grep -o '/Volumes/.*' | tail -1)"
cp -R "$vol/Surrealist.app" /Applications/
hdiutil detach "$vol" -quiet
rm -rf "$tmp"
