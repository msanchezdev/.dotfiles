# shellcheck shell=bash
# Shared helpers for the dotfiles installer. Sourced by install.sh.

# --- output ----------------------------------------------------------------
if [ -t 1 ]; then
  _C_RESET=$'\033[0m'; _C_BOLD=$'\033[1m'; _C_DIM=$'\033[2m'
  _C_BLUE=$'\033[34m'; _C_GREEN=$'\033[32m'; _C_YELLOW=$'\033[33m'; _C_RED=$'\033[31m'
else
  _C_RESET=; _C_BOLD=; _C_DIM=; _C_BLUE=; _C_GREEN=; _C_YELLOW=; _C_RED=
fi

rule() { printf '%s%s%s\n' "$_C_DIM" "────────────────────────────────────────────────────────────" "$_C_RESET"; }
step() { printf '\n%s==>%s %s%s%s\n' "$_C_BLUE$_C_BOLD" "$_C_RESET" "$_C_BOLD" "$*" "$_C_RESET"; }
info() { printf '    %s\n' "$*"; }
ok()   { printf '    %s✓%s %s\n' "$_C_GREEN" "$_C_RESET" "$*"; }
skip() { printf '    %s·%s %s%s%s\n' "$_C_DIM" "$_C_RESET" "$_C_DIM" "$*" "$_C_RESET"; }
warn() { printf '    %s!%s %s\n' "$_C_YELLOW" "$_C_RESET" "$*" >&2; }
die()  { printf '%sError:%s %s\n' "$_C_RED$_C_BOLD" "$_C_RESET" "$*" >&2; exit 1; }

# --- predicates ------------------------------------------------------------
has() { command -v "$1" >/dev/null 2>&1; }

os_id() {
  case "$(uname -s)" in
    Darwin) echo macos ;;
    Linux)  echo linux ;;
    *)      echo unknown ;;
  esac
}

is_wsl() { grep -qiE '(microsoft|wsl)' /proc/version 2>/dev/null; }

# True when the comma-separated platform list in $1 includes the current OS.
# An empty list means "all platforms".
platform_match() {
  local only="$1" cur; cur="$(os_id)"
  [ -z "$only" ] && return 0
  case ",$only," in *",$cur,"*) return 0 ;; *) return 1 ;; esac
}

# --- paths & profile -------------------------------------------------------
DOTFILES_STATE_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/dotfiles"
PROFILE_FILE="$DOTFILES_STATE_DIR/profile"

# Resolve the active device profile. The profile file is gitignored and names
# this machine; on first run we seed it from the hostname so the script stays
# non-interactive. Edit ~/.config/dotfiles/profile to rename a device.
resolve_profile() {
  if [ -f "$PROFILE_FILE" ]; then
    PROFILE="$(tr -d '[:space:]' < "$PROFILE_FILE")"
  fi
  if [ -z "${PROFILE:-}" ]; then
    PROFILE="$(hostname -s 2>/dev/null || hostname)"
    PROFILE="$(printf '%s' "$PROFILE" | tr '[:upper:]' '[:lower:]')"
    mkdir -p "$DOTFILES_STATE_DIR"
    printf '%s\n' "$PROFILE" > "$PROFILE_FILE"
    warn "No profile set — seeded '$PROFILE' at $PROFILE_FILE (edit to rename)."
  fi
  export PROFILE
}
