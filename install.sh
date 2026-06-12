#!/usr/bin/env bash
# Idempotent dotfiles installer.
#
#   ./install.sh            run every phase
#   ./install.sh packages   run a single phase (bootstrap|env|packages|stow|postinstall)
#
# Configuration:
#   manifest/packages.yaml          shared packages (committed)
#   manifest/devices/<profile>.yaml per-device packages (committed)
#   env/shared.env                  shared env (committed)
#   env/devices/<profile>.env       per-device env (committed, non-secret)
#   env/devices/<profile>.local.env per-device secrets (gitignored)
#   ~/.config/dotfiles/profile      this machine's profile name (gitignored)
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export DOTFILES

# shellcheck source=install/lib.sh
source "$DOTFILES/install/lib.sh"
# shellcheck source=install/installers.sh
source "$DOTFILES/install/installers.sh"

resolve_profile
printf '%sdotfiles%s · profile %s%s%s · %s\n' \
  "$_C_BOLD" "$_C_RESET" "$_C_BOLD" "$PROFILE" "$_C_RESET" "$(os_id)$(is_wsl && echo '/wsl')"

run_phase() {
  case "$1" in
    bootstrap)   source "$DOTFILES/install/phases/00-bootstrap.sh" ;;
    env)         source "$DOTFILES/install/phases/10-env.sh" ;;
    packages)    source "$DOTFILES/install/phases/20-packages.sh" ;;
    stow)        source "$DOTFILES/install/phases/30-stow.sh" ;;
    postinstall) source "$DOTFILES/install/phases/40-postinstall.sh" ;;
    *) die "unknown phase '$1' (bootstrap|env|packages|stow|postinstall)" ;;
  esac
}

if [ "$#" -gt 0 ]; then
  for phase in "$@"; do run_phase "$phase"; done
else
  for phase in bootstrap env packages stow postinstall; do run_phase "$phase"; done
fi

step "Done"
info "Restart your shell or: source ~/.config/dotfiles/env.sh"
