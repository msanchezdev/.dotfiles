#!/usr/bin/env bash
# One-line bootstrap for a fresh machine:
#
#   bash -c "$(curl -fsSL https://dotfiles.msanchez.dev/install)"
#
# (dotfiles.msanchez.dev/install is a Cloudflare Worker serving this file from
# GitHub — see cloudflare/. Raw fallback:
#   https://raw.githubusercontent.com/msanchezdev/.dotfiles/main/bootstrap.sh )
#
# Use this `bash -c "$(...)"` form, not `curl ... | bash`: it keeps a terminal
# attached so Homebrew can prompt for your sudo password on macOS.
#
# Forward args to install.sh (e.g. run a single phase) with a trailing --:
#   bash -c "$(curl -fsSL https://dotfiles.msanchez.dev/install)" -- bootstrap
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
if [ ! -d "$DEST/.git" ]; then
  info "Cloning into $DEST"
  git clone "$REPO_HTTPS" "$DEST"
fi

# Fetch over HTTPS, push over SSH (for the owner). The HTTPS fetch keeps working
# even with a global `insteadOf https://github.com/ -> git@github.com:` in your
# .gitconfig: a repo-local, longer-prefix identity rewrite wins by longest match,
# so only THIS repo is exempted from the SSH rewrite (no SSH key needed to pull).
# Set this BEFORE pulling so it self-heals an existing checkout.
git -C "$DEST" remote set-url origin "$REPO_HTTPS" 2>/dev/null || true
git -C "$DEST" remote set-url --push origin "$REPO_SSH" 2>/dev/null || true
git -C "$DEST" config "url.${REPO_HTTPS%.git}.insteadOf" "${REPO_HTTPS%.git}"

if [ -d "$DEST/.git" ]; then
  info "Updating $DEST"
  git -C "$DEST" pull --ff-only || info "skipping update (local changes / diverged)"
fi

# 3. Run the installer, forwarding any args.
info "Running installer"
cd "$DEST"
exec ./install.sh "$@"
