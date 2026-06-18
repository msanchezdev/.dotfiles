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
#   DOTFILES_DIR       where the repo lives (default: ~/git/github.com/msanchezdev/.dotfiles)
#   DOTFILES_PROFILE   name this machine's profile on first run, e.g.
#                      DOTFILES_PROFILE=work bash -c "$(curl -fsSL .../install)"
#
# The repo is cloned into a structured ~/git/<host>/<owner>/<repo> path; a
# ~/.dotfiles symlink points at it so everything (install.sh, dotup, stow) keeps
# referencing ~/.dotfiles.
set -euo pipefail

REPO_HTTPS="https://github.com/msanchezdev/.dotfiles.git"
REPO_SSH="git@github.com:msanchezdev/.dotfiles"
REPO_DIR="${DOTFILES_DIR:-$HOME/git/github.com/msanchezdev/.dotfiles}"
LINK="$HOME/.dotfiles"

info() { printf '\033[1;34m::\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m::\033[0m %s\n' "$*" >&2; }
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

# 2. Get the repo into REPO_DIR (clone, or migrate a legacy ~/.dotfiles checkout).
mkdir -p "$(dirname "$REPO_DIR")"
if [ ! -L "$LINK" ] && [ -d "$LINK/.git" ] && [ ! -d "$REPO_DIR/.git" ]; then
  info "Migrating $LINK -> $REPO_DIR"
  mv "$LINK" "$REPO_DIR"
fi
if [ ! -d "$REPO_DIR/.git" ]; then
  info "Cloning into $REPO_DIR"
  git clone "$REPO_HTTPS" "$REPO_DIR"
fi

# Point ~/.dotfiles at it (everything references ~/.dotfiles).
if [ -L "$LINK" ] || [ ! -e "$LINK" ]; then
  ln -sfn "$REPO_DIR" "$LINK"
elif [ "$(cd "$LINK" 2>/dev/null && pwd -P)" != "$REPO_DIR" ]; then
  warn "$LINK exists and isn't a symlink to $REPO_DIR — leaving it as is"
fi

# Fetch over HTTPS, push over SSH (for the owner). The HTTPS fetch keeps working
# even with a global `insteadOf https://github.com/ -> git@github.com:` in your
# .gitconfig: a repo-local, longer-prefix identity rewrite wins by longest match,
# so only THIS repo is exempted from the SSH rewrite (no SSH key needed to pull).
# Set this BEFORE pulling so it self-heals an existing checkout.
git -C "$REPO_DIR" remote set-url origin "$REPO_HTTPS" 2>/dev/null || true
git -C "$REPO_DIR" remote set-url --push origin "$REPO_SSH" 2>/dev/null || true
git -C "$REPO_DIR" config "url.${REPO_HTTPS%.git}.insteadOf" "${REPO_HTTPS%.git}"

info "Updating $REPO_DIR"
git -C "$REPO_DIR" pull --ff-only || info "skipping update (local changes / diverged)"

# 3. Run the installer via the ~/.dotfiles symlink, so DOTFILES resolves the
# same way as `dotup` does (uniform stow link targets).
info "Running installer"
cd "$LINK"
exec ./install.sh "$@"
