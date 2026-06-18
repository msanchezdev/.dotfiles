#!/usr/bin/env bash
# Manage the dotfiles device profile (the per-machine name that selects
# manifest/devices/<p>.yaml, env/devices/<p>.{env,local.env}, and devices/<p>/).
#
#   profile.sh                      print the current profile
#   profile.sh rename <new>         rename current profile -> <new>  (moves files)
#   profile.sh rename <new> --copy  copy current profile -> <new>    (keeps old)
set -euo pipefail

DOTFILES="${DOTFILES:-$HOME/.dotfiles}"
PROFILE_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/dotfiles/profile"

current() {
  if [ -f "$PROFILE_FILE" ]; then tr -d '[:space:]' < "$PROFILE_FILE"
  else hostname -s 2>/dev/null || hostname; fi
}

case "${1:-current}" in
  current) current ;;
  rename)
    new="${2:?usage: profile.sh rename <new> [--copy]}"
    mode="${3:-}"
    [ "$mode" = --copy ] || [ -z "$mode" ] || { echo "unknown flag '$mode' (only --copy)" >&2; exit 1; }
    old="$(current)"
    [ "$old" = "$new" ] && { echo "already '$new'"; exit 0; }

    # Move (git mv if tracked, else mv) or copy each per-profile path.
    transfer() {
      local src="$1" dst="$2" rel
      [ -e "$src" ] || return 0
      if [ "$mode" = --copy ]; then
        cp -r "$src" "$dst"
      elif rel="${src#"$DOTFILES"/}"; git -C "$DOTFILES" ls-files --error-unmatch "$rel" >/dev/null 2>&1; then
        git -C "$DOTFILES" mv "$rel" "${dst#"$DOTFILES"/}"
      else
        mv "$src" "$dst"
      fi
    }
    transfer "$DOTFILES/manifest/devices/$old.yaml"   "$DOTFILES/manifest/devices/$new.yaml"
    transfer "$DOTFILES/env/devices/$old.env"         "$DOTFILES/env/devices/$new.env"
    transfer "$DOTFILES/env/devices/$old.local.env"   "$DOTFILES/env/devices/$new.local.env"
    transfer "$DOTFILES/devices/$old"                 "$DOTFILES/devices/$new"

    mkdir -p "$(dirname "$PROFILE_FILE")"
    printf '%s\n' "$new" > "$PROFILE_FILE"
    if [ "$mode" = --copy ]; then echo "profile: copied '$old' -> '$new' (now active)"
    else echo "profile: renamed '$old' -> '$new'"; fi
    echo "review & commit the moved files in $DOTFILES (the .local.env stays gitignored)."
    ;;
  *) echo "usage: profile.sh [current | rename <new> [--copy]]" >&2; exit 1 ;;
esac
