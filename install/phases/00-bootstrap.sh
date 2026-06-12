# shellcheck shell=bash
# Phase 00 — bootstrap the package managers the rest of the install relies on.
# This must run before anything reads the YAML manifest, because the manifest
# parser (yq+jq) and most packages come from Homebrew.

step "Bootstrap toolchain"

# Homebrew -------------------------------------------------------------------
if ! has brew; then
  info "Installing Homebrew"
  NONINTERACTIVE=1 /bin/bash -c \
    "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" \
    || die "Homebrew install failed"
fi
# Make brew available in this shell for the current run.
if ! has brew; then
  for p in /home/linuxbrew/.linuxbrew/bin/brew /opt/homebrew/bin/brew /usr/local/bin/brew; do
    [ -x "$p" ] && eval "$("$p" shellenv)" && break
  done
fi
has brew && ok "Homebrew" || die "Homebrew not on PATH after install"

# Manifest parser ------------------------------------------------------------
for tool in yq jq; do
  if ! has "$tool"; then
    info "Installing $tool (manifest parser)"
    brew install "$tool" >/dev/null 2>&1 && ok "$tool" || die "could not install $tool"
  else
    skip "$tool present"
  fi
done

# bun (JS-ecosystem installer) ----------------------------------------------
if ! has bun; then
  info "Installing bun"
  curl -fsSL https://bun.sh/install | bash >/dev/null 2>&1 || warn "bun install failed"
  [ -x "$HOME/.bun/bin/bun" ] && export PATH="$HOME/.bun/bin:$PATH"
fi
has bun && ok "bun" || warn "bun unavailable — bun packages will be skipped"
