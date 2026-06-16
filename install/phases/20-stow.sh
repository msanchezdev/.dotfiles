# shellcheck shell=bash
# Phase 20 — symlink config into $HOME with GNU stow (idempotent via --restow).
# Shared stow packages are the top-level dirs (nvim, tmux, ...); device-specific
# overlays live under devices/<profile>/ and are stowed on top.

step "Stow config ($PROFILE)"

has stow || { warn "stow missing — skipping symlinks"; return; }

# A stow package is a top-level dir holding at least one dotfile/.config entry
# to link into $HOME. Dirs with no hidden entries (install/, manifest/, env/,
# test/, ...) are repo infrastructure, not packages — skip them. This is
# self-maintaining: new infra dirs don't need to be added to a blocklist.
_is_stow_package() {
  [ -n "$(find "$1" -maxdepth 1 -mindepth 1 -name '.*' -print -quit 2>/dev/null)" ]
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
  _is_stow_package "$d" || { skip "$pkg (not a stow package)"; continue; }
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
