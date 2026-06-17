# shellcheck shell=bash
# Per-installer dispatch. Each install_<via> takes the fields parsed from a
# manifest row and is responsible for being idempotent.

# Run a (writing) brew command as whoever owns the prefix. On a shared Mac
# where another account owns /opt/homebrew, a plain `brew install` fails the
# ownership check; route it through `sudo -H -u <owner>`. No-op when you own
# the prefix (the common case) — then it's just `brew`. Read-only brew calls
# (list/--prefix) work as any user, so callers use plain `brew` for those.
_brew() {
  local prefix owner
  prefix="$(brew --prefix 2>/dev/null)"; : "${prefix:=/opt/homebrew}"
  if [ "$(uname)" = Darwin ]; then       # macOS and Linux `stat` differ
    owner="$(stat -f '%Su' "$prefix" 2>/dev/null)"
  else
    owner="$(stat -c '%U' "$prefix" 2>/dev/null)"
  fi
  if [ -z "$owner" ] || [ "$owner" = "$(whoami)" ]; then
    brew "$@"
  else
    sudo_keep || { warn "need sudo to run brew as $owner"; return 1; }
    sudo -H -u "$owner" "$prefix/bin/brew" "$@"
  fi
}

# install_brew <name> <bin>
install_brew() {
  local name="$1" bin="$2"
  [ -n "$bin" ] && has "$bin" && { skip "$name (brew, $bin present)"; return; }
  if brew list --versions "$name" >/dev/null 2>&1; then
    skip "$name (brew, already installed)"; return
  fi
  info "brew install $name"
  _brew install "$name" && ok "$name" || warn "failed: brew install $name"
}

# install_bun <name> <bin>
install_bun() {
  local name="$1" bin="$2"
  [ -n "$bin" ] && has "$bin" && { skip "$name (bun, $bin present)"; return; }
  info "bun add -g $name"
  bun add -g "$name" >/dev/null 2>&1 && ok "$name" || warn "failed: bun add -g $name"
}

# install_npm <name> <bin>
install_npm() {
  local name="$1" bin="$2"
  [ -n "$bin" ] && has "$bin" && { skip "$name (npm, $bin present)"; return; }
  info "npm install -g $name"
  npm install -g "$name" >/dev/null 2>&1 && ok "$name" || warn "failed: npm install -g $name"
}

# Refresh apt's package lists at most once per run — a fresh machine (or a
# container with cleared lists) can't install anything until this runs.
_APT_UPDATED=
_apt_update_once() {
  [ -n "$_APT_UPDATED" ] && return
  sudo_keep || true
  info "apt-get update"
  sudo apt-get update -qq >/dev/null 2>&1 || warn "apt-get update failed"
  _APT_UPDATED=1
}

# install_apt <name> <bin>
install_apt() {
  local name="$1" bin="$2"
  [ -n "$bin" ] && has "$bin" && { skip "$name (apt, $bin present)"; return; }
  if dpkg -s "$name" >/dev/null 2>&1; then skip "$name (apt, installed)"; return; fi
  _apt_update_once
  info "apt-get install $name"
  sudo apt-get install -y "$name" >/dev/null 2>&1 && ok "$name" || warn "failed: apt-get install $name"
}

# install_git <name> <repo> <dest>
install_git() {
  local name="$1" repo="$2" dest="$3"
  dest="${dest/#\~/$HOME}"
  if [ -z "$repo" ] || [ -z "$dest" ]; then
    warn "git package '$name' needs repo+dest in the manifest"; return
  fi
  if [ -d "$dest/.git" ]; then skip "$name (git, cloned at $dest)"; return; fi
  info "git clone $repo -> $dest"
  git clone --depth 1 "$repo" "$dest" >/dev/null 2>&1 && ok "$name" || warn "failed: git clone $repo"
}

# install_script <name> <bin> <cmd>
# For tools with their own curl|bash installer (e.g. claude). `cmd` runs only
# when `bin` is absent, so it never reinstalls/updates on re-runs.
install_script() {
  local name="$1" bin="$2" cmd="$3"
  [ -n "$bin" ] && has "$bin" && { skip "$name (script, $bin present)"; return; }
  if [ -z "$cmd" ]; then warn "script package '$name' needs a cmd in the manifest"; return; fi
  info "installing $name via its script"
  bash -c "$cmd" >/dev/null 2>&1 && ok "$name" || warn "failed: install script for $name"
}

# install_cask <name>
# macOS GUI apps via Homebrew casks (gate these with only: [macos] — casks
# don't exist on linuxbrew). Detect via `brew list --cask`, not a CLI bin.
install_cask() {
  local name="$1"
  has brew || { warn "brew missing — can't install cask $name"; return; }
  if brew list --cask "$name" >/dev/null 2>&1; then skip "$name (cask, installed)"; return; fi
  info "brew install --cask $name"
  _brew install --cask "$name" >/dev/null 2>&1 && ok "$name" || warn "failed: brew install --cask $name"
}

# Route one manifest row to the right installer.
dispatch_package() {
  local via="$1" name="$2" bin="$3" repo="$4" dest="$5" cmd="$6"
  case "$via" in
    brew)   install_brew   "$name" "$bin" ;;
    cask)   install_cask   "$name" ;;
    bun)    install_bun    "$name" "$bin" ;;
    npm)    install_npm    "$name" "$bin" ;;
    apt)    install_apt    "$name" "$bin" ;;
    git)    install_git    "$name" "$repo" "$dest" ;;
    script) install_script "$name" "$bin" "$cmd" ;;
    *)      warn "unknown installer '$via' for '$name'" ;;
  esac
}
