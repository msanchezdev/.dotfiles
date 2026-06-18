#!/usr/bin/env bash
# Install Pencil desktop from pencil.dev. Idempotent.
#   Linux: AppImage -> ~/.local/bin/pencil-desktop (matches the pencil-desktop alias)
#   macOS: .dmg      -> /Applications/Pencil.app
set -euo pipefail

base="https://pencil.dev/download"
arch="$(uname -m)"

case "$(uname -s)" in
  Linux)
    dest="$HOME/.local/bin/pencil-desktop"
    [ -x "$dest" ] && exit 0
    case "$arch" in aarch64 | arm64) a=arm64 ;; *) a=x86_64 ;; esac
    mkdir -p "$HOME/.local/bin"
    curl -fsSL -o "$dest" "$base/Pencil-linux-$a.AppImage"
    chmod +x "$dest"
    ;;
  Darwin)
    [ -d /Applications/Pencil.app ] && exit 0
    case "$arch" in arm64) a=arm64 ;; *) a=x64 ;; esac
    tmp="$(mktemp -d)"
    curl -fsSL -o "$tmp/Pencil.dmg" "$base/Pencil-mac-$a.dmg"
    vol="$(hdiutil attach "$tmp/Pencil.dmg" -nobrowse -noverify | grep -o '/Volumes/.*' | tail -1)"
    cp -R "$vol/Pencil.app" /Applications/
    hdiutil detach "$vol" -quiet
    rm -rf "$tmp"
    ;;
  *)
    echo "pencil: unsupported OS $(uname -s)" >&2
    exit 1
    ;;
esac
