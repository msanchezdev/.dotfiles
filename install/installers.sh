# shellcheck shell=bash
# Per-installer dispatch. Each install_<via> takes the fields parsed from a
# manifest row and is responsible for being idempotent.

# install_brew <name> <bin>
install_brew() {
  local name="$1" bin="$2"
  [ -n "$bin" ] && has "$bin" && { skip "$name (brew, $bin present)"; return; }
  if brew list --versions "$name" >/dev/null 2>&1; then
    skip "$name (brew, already installed)"; return
  fi
  info "brew install $name"
  brew install "$name" && ok "$name" || warn "failed: brew install $name"
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

# install_apt <name> <bin>
install_apt() {
  local name="$1" bin="$2"
  [ -n "$bin" ] && has "$bin" && { skip "$name (apt, $bin present)"; return; }
  if dpkg -s "$name" >/dev/null 2>&1; then skip "$name (apt, installed)"; return; fi
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

# Route one manifest row to the right installer.
dispatch_package() {
  local via="$1" name="$2" bin="$3" repo="$4" dest="$5"
  case "$via" in
    brew) install_brew "$name" "$bin" ;;
    bun)  install_bun  "$name" "$bin" ;;
    npm)  install_npm  "$name" "$bin" ;;
    apt)  install_apt  "$name" "$bin" ;;
    git)  install_git  "$name" "$repo" "$dest" ;;
    *)    warn "unknown installer '$via' for '$name'" ;;
  esac
}
