#!/usr/bin/env bash
# One-line bootstrap for a fresh machine:
#
#   curl -fsSL https://raw.githubusercontent.com/msanchezdev/.dotfiles/main/bootstrap.sh | bash
#
# Forward args to install.sh (e.g. run a single phase):
#   curl -fsSL .../bootstrap.sh | bash -s -- bootstrap
#
# Env knobs:
#   DOTFILES_DIR   where to clone (default: ~/.dotfiles)
set -euo pipefail

REPO_HTTPS="https://github.com/msanchezdev/.dotfiles.git"
REPO_SSH="git@github.com:msanchezdev/.dotfiles"
DEST="${DOTFILES_DIR:-$HOME/.dotfiles}"

info() { printf '\033[1;34m::\033[0m %s\n' "$*"; }
die()  { printf '\033[1;31mError:\033[0m %s\n' "$*" >&2; exit 1; }

# 1. Ensure git (needed to clone). Homebrew/install.sh handle the rest.
if ! command -v git >/dev/null 2>&1; then
  info "Installing git"
  if   command -v apt-get >/dev/null 2>&1; then sudo apt-get update -qq && sudo apt-get install -y git
  elif command -v dnf     >/dev/null 2>&1; then sudo dnf install -y git
  elif command -v pacman  >/dev/null 2>&1; then sudo pacman -S --noconfirm git
  elif command -v brew    >/dev/null 2>&1; then brew install git
  elif command -v xcode-select >/dev/null 2>&1; then xcode-select --install || true
  else die "git not found and no known package manager — install git, then re-run."
  fi
fi

# 2. Clone (over HTTPS, no auth needed) or update an existing checkout.
if [ -d "$DEST/.git" ]; then
  info "Updating $DEST"
  git -C "$DEST" pull --ff-only || info "skipping update (local changes / diverged)"
else
  info "Cloning into $DEST"
  git clone "$REPO_HTTPS" "$DEST"
fi

# Fetch over HTTPS, but push over SSH (for the owner's own machines).
git -C "$DEST" remote set-url --push origin "$REPO_SSH" 2>/dev/null || true

# 3. Run the installer, forwarding any args.
info "Running installer"
cd "$DEST"
exec ./install.sh "$@"
