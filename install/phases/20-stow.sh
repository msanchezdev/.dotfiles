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

# Remove stale stow links for a package: symlinks in $HOME that resolve INTO the
# package but that stow no longer recognises as its own. This happens after the
# repo moves and ~/.dotfiles becomes a symlink — stow realpath's its dir to
# ~/git/... while the old links still point via .dotfiles/..., so stow reports
# "existing target not owned by stow". Only links resolving into the package are
# removed (never real user files), so stow can re-link them cleanly.
_clean_stale() { # <stow-dir> <package>
  local dir="$1" pkg="$2" real rel t
  real="$(cd "$dir/$pkg" 2>/dev/null && pwd -P)" || return 0
  while IFS= read -r rel; do
    t="$HOME/$rel"
    while [ "$t" != "$HOME" ] && [ "$t" != "/" ]; do
      if [ -L "$t" ]; then
        case "$(readlink -f "$t" 2>/dev/null)/" in "$real"/*) rm -f "$t" ;; esac
        break
      fi
      t="$(dirname "$t")"
    done
  done < <(cd "$dir/$pkg" && find . -mindepth 1 \( -type f -o -type l \) 2>/dev/null | sed 's#^\./##')
}

stow_pkg() { # <stow-dir> <package>
  local dir="$1" pkg="$2"
  if stow --restow --target="$HOME" --dir="$dir" "$pkg" 2>/dev/null; then
    ok "stow $pkg"; return
  fi
  # Conflict — most often stale links from a moved repo. Clean ours and retry.
  _clean_stale "$dir" "$pkg"
  if stow --restow --target="$HOME" --dir="$dir" "$pkg" 2>/dev/null; then
    ok "stow $pkg (re-linked after move)"
  else
    warn "stow conflict for '$pkg' — resolve files in \$HOME, then re-run"
  fi
}

# Shared packages.
for d in "$DOTFILES"/*/; do
  pkg="$(basename "$d")"
  _is_stow_package "$d" || continue   # skip repo infra (install/, manifest/, env/, test/, ...)
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
