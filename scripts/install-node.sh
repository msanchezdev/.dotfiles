#!/usr/bin/env bash
# Install nvm + the latest LTS Node.js. Idempotent. Works on Linux and macOS.
# nvm itself is loaded from zsh/.zshrc; this only installs it + a Node version.
set -euo pipefail

export NVM_DIR="$HOME/.nvm"
NVM_VERSION="v0.40.5"

# Install nvm if missing. PROFILE=/dev/null stops nvm's installer from appending
# to our managed shell rc — we source nvm ourselves in zsh/.zshrc.
if [ ! -s "$NVM_DIR/nvm.sh" ]; then
  PROFILE=/dev/null bash -c \
    "$(curl -fsSL "https://raw.githubusercontent.com/nvm-sh/nvm/$NVM_VERSION/install.sh")"
fi

# Load nvm. Only install + set a default Node when there isn't one already, so
# this never clobbers an existing setup or re-downloads on every install run
# (nvm-managed node isn't on the installer's PATH, so the bin check can't skip).
# shellcheck disable=SC1091
. "$NVM_DIR/nvm.sh"
if ! nvm which default >/dev/null 2>&1; then
  nvm install --lts
  nvm alias default 'lts/*'
fi
