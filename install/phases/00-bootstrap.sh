# shellcheck shell=bash
# Phase 00 — bootstrap the toolchain the rest of the install relies on. This
# runs before the manifest is read, and installs the tools the *installer
# itself* needs (brew, yq/jq to parse the manifest, stow to link configs, bun
# to install JS packages) — independent of what the manifest lists, so a bare
# or minimal manifest still produces a working setup.

step "Bootstrap toolchain"

# Homebrew -------------------------------------------------------------------
# Load brew into this shell from its standard locations. A minimal/bare shell
# rc may not put brew on PATH, so `has brew` alone would wrongly conclude it's
# missing and reinstall it — check the install dirs directly first.
_load_brew() {
  has brew && return 0
  for p in /opt/homebrew/bin/brew /home/linuxbrew/.linuxbrew/bin/brew /usr/local/bin/brew; do
    [ -x "$p" ] && { eval "$("$p" shellenv)"; return 0; }
  done
  return 1
}

_load_brew || true
if ! has brew; then
  info "Installing Homebrew"
  # Homebrew installs NONINTERACTIVE (so it never stops to prompt), which means
  # it won't ask for a sudo password either — it needs one already cached. On
  # macOS sudo requires a password, so prime it up front. This needs a real
  # terminal: run via `bash -c "$(curl ...)"`, NOT `curl ... | bash` (a pipe
  # has no TTY, so sudo can't read the password). Passwordless sudo (CI/Linux)
  # makes `sudo -v` a no-op.
  if command -v sudo >/dev/null 2>&1 && [ "$(id -u)" -ne 0 ]; then
    sudo -v || die "sudo access is required to install Homebrew (your user must be an Administrator, and you must run via 'bash -c \"\$(curl ...)\"' so the password can be entered)"
    # Keep the sudo timestamp warm during the (possibly long) install so it
    # doesn't expire between Homebrew's sudo calls. disown so the shell doesn't
    # print a "Terminated" job notice when we stop it below.
    ( while kill -0 "$$" 2>/dev/null; do sudo -n true 2>/dev/null; sleep 50; done ) &
    _sudo_keepalive=$!
    disown "$_sudo_keepalive" 2>/dev/null || true
  fi
  NONINTERACTIVE=1 /bin/bash -c \
    "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" \
    || die "Homebrew install failed"
  [ -n "${_sudo_keepalive:-}" ] && kill "$_sudo_keepalive" 2>/dev/null
  _load_brew || true   # put the freshly installed brew on PATH for this run
  # Visually separate Homebrew's large output from the rest of the install.
  rule
  ok "Homebrew installed"
else
  skip "Homebrew present"
fi
has brew || die "Homebrew not on PATH after install"

# Installer infrastructure (manifest parser + config linker) -----------------
# These are required by later phases regardless of the manifest, so they are
# bootstrapped here rather than declared as packages.
#   yq, jq  -> parse the YAML manifest        stow -> symlink configs (phase 20)
for tool in yq jq stow; do
  if ! has "$tool"; then
    info "Installing $tool"
    brew install "$tool" >/dev/null 2>&1 && ok "$tool" || die "could not install $tool"
  else
    skip "$tool present"
  fi
done

# bun (JS-ecosystem installer) ----------------------------------------------
# Like brew, bun installs to a dir (~/.bun/bin) a bare shell rc may not have on
# PATH — probe it first so we don't reinstall. Loading it onto PATH also lets
# the packages phase find bun-installed bins (biome, tsgo, ...) on re-runs.
_load_bun() {
  has bun && return 0
  [ -x "$HOME/.bun/bin/bun" ] && { export PATH="$HOME/.bun/bin:$PATH"; return 0; }
  return 1
}

_load_bun || true
if ! has bun; then
  # bun's installer unzips its release, so ensure unzip first (absent on
  # minimal Linux). brew is already available for a portable dependency.
  has unzip || { info "Installing unzip (bun prerequisite)"; brew install unzip >/dev/null 2>&1 || warn "unzip install failed"; }
  info "Installing bun"
  curl -fsSL https://bun.sh/install | bash >/dev/null 2>&1 || warn "bun install failed"
  _load_bun || true
  has bun && ok "bun installed" || warn "bun unavailable — bun packages will be skipped"
else
  skip "bun present"
fi
