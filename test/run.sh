#!/usr/bin/env bash
# Test the dotfiles bootstrap on a clean Ubuntu container.
#
#   test/run.sh              # full install, then verify + idempotency re-run
#   PHASES="bootstrap" test/run.sh   # run only specific phases
#
# The working tree (minus .git and *.local.env, i.e. exactly what a fresh
# `git clone` would have) is copied into the container's HOME and installed
# there, so nothing on the host is touched.
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
IMAGE=dotfiles-test

docker build -t "$IMAGE" "$REPO/test"

docker run --rm -v "$REPO":/repo:ro -e PHASES="${PHASES:-}" "$IMAGE" bash -c '
  set -e
  mkdir -p ~/.dotfiles
  # Simulate a fresh clone: tracked-ish files only, no .git, no local secrets.
  tar -C /repo --exclude=./.git --exclude="*.local.env" -cf - . | tar -C ~/.dotfiles -xf -
  cd ~/.dotfiles

  echo "######## FRESH MACHINE: hostname=$(hostname) user=$(whoami) ########"
  ./install.sh ${PHASES}

  echo
  echo "######## VERIFICATION ########"
  # Bring brew + bun onto PATH the way a new login shell would.
  [ -x /home/linuxbrew/.linuxbrew/bin/brew ] && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
  export PATH="$HOME/.bun/bin:$PATH"

  echo "-- ~/.zshrc (want symlink into .dotfiles/zsh):"
  ls -l ~/.zshrc
  echo "-- profile seeded:"; cat ~/.config/dotfiles/profile
  echo "-- managed env block count (want 1):"; grep -c ">>> dotfiles env >>>" ~/.zshrc
  echo "-- tools on PATH:"
  for b in brew nvim tmux stow rg fd yazi jq yq stylua biome prettier yaml-language-server tsgo; do
    printf "   %-22s" "$b"; command -v "$b" >/dev/null && echo "$(command -v "$b")" || echo "MISSING"
  done

  echo
  echo "######## IDEMPOTENCY (second full run; want all skips, no conflicts) ########"
  ./install.sh ${PHASES} 2>&1 | grep -iE "stow|conflict|already sources|install " | head -30 || true
'
