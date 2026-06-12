# shellcheck shell=bash
# Phase 30 — symlink config into $HOME with GNU stow (idempotent via --restow).
# Shared stow packages are the top-level dirs (nvim, tmux, ...); device-specific
# overlays live under devices/<profile>/ and are stowed on top.

step "Stow config ($PROFILE)"

has stow || { warn "stow missing — skipping symlinks"; return; }

# Directories at the repo root that are infrastructure, not stow packages.
_is_infra() {
  case "$1" in install|manifest|env|devices|.git) return 0 ;; *) return 1 ;; esac
}

stow_pkg() { # <stow-dir> <package>
  local dir="$1" pkg="$2"
  if stow --restow --target="$HOME" --dir="$dir" "$pkg" 2>/dev/null; then
    ok "stow $pkg"
  else
    warn "stow conflict for '$pkg' — resolve files in \$HOME, then re-run"
  fi
}

# Shared packages.
for d in "$DOTFILES"/*/; do
  pkg="$(basename "$d")"
  _is_infra "$pkg" && continue
  stow_pkg "$DOTFILES" "$pkg"
done

# Device overlay packages.
overlay="$DOTFILES/devices/$PROFILE"
if [ -d "$overlay" ]; then
  for d in "$overlay"/*/; do
    [ -d "$d" ] || continue
    stow_pkg "$overlay" "$(basename "$d")"
  done
fi
