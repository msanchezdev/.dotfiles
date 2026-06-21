# shellcheck shell=bash
# Phase 40 — post-install bootstrap that depends on configs being in place.

step "Post-install"

# tmux plugin manager: install configured plugins headlessly.
tpm_dir="$HOME/.tmux/plugins/tpm"
if [ -x "$tpm_dir/bin/install_plugins" ]; then
  info "installing tmux plugins"
  _run "tmux plugins (tpm)" "$tpm_dir/bin/install_plugins" && ok "tmux plugins" || warn "tpm install failed (see log)"
else
  skip "tpm not present (added by manifest git package)"
fi

# Neovim: sync lazy.nvim plugins (also triggers treesitter/LSP builds on first run).
if has nvim; then
  info "syncing neovim plugins (headless, may take a minute)"
  _run "neovim plugins (Lazy sync)" nvim --headless "+Lazy! sync" +qa && ok "neovim plugins" \
    || warn "nvim plugin sync had issues (see log) — open nvim and run :Lazy"
else
  skip "nvim not installed"
fi

# Make zsh the default login shell. The git-cloned oh-my-zsh (unlike the
# official installer) doesn't run chsh, so a fresh Linux box would stay on bash.
# Idempotent: a no-op once the login shell is already zsh.
if [ -L "$HOME/.zshrc" ] || [ -e "$HOME/.zshrc" ]; then
  zsh_path="$(command -v zsh || true)"
  # Login shell: getent on Linux. macOS has no getent, and calling it under
  # `set -e`/pipefail aborts the whole run — so gate it and fall back to $SHELL.
  if has getent; then
    current_shell="$(getent passwd "$USER" 2>/dev/null | cut -d: -f7 || true)"
  else
    current_shell="${SHELL:-}"
  fi
  [ -n "$current_shell" ] || current_shell="${SHELL:-}"
  if [ -z "$zsh_path" ]; then
    skip "zsh not found — leaving default shell"
  elif [ "$current_shell" = "$zsh_path" ] || [ "${current_shell##*/}" = zsh ]; then
    skip "default shell already zsh"   # any zsh (path may differ from command -v zsh)
  elif ! has chsh; then
    warn "chsh unavailable — set zsh as your login shell manually"
  else
    # chsh requires the target shell to be listed in /etc/shells.
    if ! grep -qx "$zsh_path" /etc/shells 2>/dev/null; then
      info "adding $zsh_path to /etc/shells (sudo)"
      echo "$zsh_path" | sudo tee -a /etc/shells >/dev/null 2>&1 || warn "couldn't update /etc/shells"
    fi
    info "setting default shell to zsh (chsh may prompt for your password)"
    chsh -s "$zsh_path" && ok "default shell -> zsh (re-login to take effect)" \
      || warn "chsh failed — run manually: chsh -s $zsh_path"
  fi
fi

# GitHub SSH: the .gitconfig routes GitHub pushes over SSH, which needs a key
# registered on this machine. Nudge to set it up with gh if it isn't already.
if has gh && ! gh auth status >/dev/null 2>&1; then
  warn "GitHub not set up on this machine. Run: gh auth login  (choose SSH) to"
  warn "register an SSH key — needed for 'git push' (and 'dotup' if pulling over SSH)."
fi

# (Rosetta 2 is installed by the manifest — `rosetta` script entry — so it's in
# place before this seeds the rosetta: true Colima config.)

# Seed Colima's default config (resources + Apple Silicon vz/virtiofs/rosetta)
# if the user hasn't created one yet. Colima manages the file after first start,
# so only seed when absent (never clobber).
if [ "$(os_id)" = macos ] && has colima && [ ! -f "$HOME/.colima/default/colima.yaml" ]; then
  info "seeding Colima default config"
  mkdir -p "$HOME/.colima/default"
  cp "$DOTFILES/colima/colima.yaml" "$HOME/.colima/default/colima.yaml" \
    && ok "colima config (edit ~/.colima/default/colima.yaml to tune)" \
    || warn "couldn't seed colima config"
fi

# SSH server (key-only, reached over Tailscale). Linux: openssh-server (manifest)
# + systemd/service; macOS: built-in sshd via Remote Login.
_sshd_conf="$DOTFILES/etc/ssh/sshd_config.d/10-dotfiles-hardening.conf"
_sshd_dest="/etc/ssh/sshd_config.d/$(basename "$_sshd_conf")"
if { [ "$(os_id)" = linux ] && [ -x /usr/sbin/sshd ]; } || [ "$(os_id)" = macos ]; then
  # authorized_keys: key-only SSH locks you out with none — seed from GitHub.
  if [ ! -s "$HOME/.ssh/authorized_keys" ]; then
    mkdir -p "$HOME/.ssh" && chmod 700 "$HOME/.ssh"
    if _run "authorized_keys (github)" curl -fsSL -o "$HOME/.ssh/authorized_keys" https://github.com/msanchezdev.keys \
       && [ -s "$HOME/.ssh/authorized_keys" ]; then
      chmod 600 "$HOME/.ssh/authorized_keys"; ok "authorized_keys from github.com/msanchezdev.keys"
    else
      warn "couldn't fetch authorized_keys — add your public key manually"
    fi
  fi
  # Config + enable need sudo. Skip (no password prompt) once the hardening
  # config is already in place, so re-runs don't re-prompt every time.
  if [ -f "$_sshd_dest" ] && cmp -s "$_sshd_conf" "$_sshd_dest" 2>/dev/null; then
    skip "ssh server (key-only) already configured"
  elif sudo_keep; then
    info "configuring ssh server (key-only)"
    sudo mkdir -p /etc/ssh/sshd_config.d
    sudo install -m 0644 "$_sshd_conf" /etc/ssh/sshd_config.d/ \
      && ok "sshd key-only config" || warn "couldn't write /etc/ssh/sshd_config.d/"
    if [ "$(os_id)" = macos ]; then
      if _run "ssh: enable Remote Login" sudo systemsetup -setremotelogin on; then
        ok "Remote Login on"
        sudo launchctl kickstart -k system/com.openssh.sshd >/dev/null 2>&1 || true
      else
        warn "enable Remote Login: System Settings > General > Sharing (systemsetup needs Full Disk Access)"
      fi
    else
      if   sudo systemctl enable --now ssh 2>/dev/null; then ok "sshd enabled (systemd)"
      elif sudo service ssh restart       2>/dev/null; then ok "sshd running (service)"
      else warn "start sshd manually: sudo service ssh start"; fi
    fi
  else
    warn "ssh server: needs sudo — skipped"
  fi
fi

# Xcode + iOS Simulator (macOS). Installing Xcode needs your Apple ID, so we
# only nudge for that; once full Xcode is selected we accept the license and
# fetch the iOS simulator runtime (a few GB, one-time).
if [ "$(os_id)" = macos ] && has xcodes; then
  # 1. Install Xcode if none is present. The Apple ID sign-in is unavoidable —
  #    xcodes prompts for it interactively (download is ~15GB).
  if ! ls -d /Applications/Xcode*.app >/dev/null 2>&1; then
    info "installing Xcode via xcodes (prompts for your Apple ID, ~15GB)"
    xcodes install --latest && ok "Xcode installed" \
      || warn "xcodes install failed/cancelled — re-run: xcodes install --latest"
  fi
  # 2. Make the newest installed Xcode the active toolchain (its command-line
  #    tools come with it) if the active dir isn't already an Xcode.
  if ! xcode-select -p 2>/dev/null | grep -q '/Xcode[^/]*\.app/'; then
    _xc="$(ls -d /Applications/Xcode*.app 2>/dev/null | sort -V | tail -1 || true)"
    [ -n "$_xc" ] && sudo_keep && sudo xcode-select -s "$_xc" && ok "selected $(basename "$_xc")" || true
  fi
  # 3. With a full Xcode active: accept the license + fetch the iOS simulator.
  if xcode-select -p 2>/dev/null | grep -q '/Xcode[^/]*\.app/'; then
    # `xcodebuild -version` succeeds only once the license is accepted — use it
    # to gate the sudo accept so it doesn't prompt every run.
    if xcodebuild -version >/dev/null 2>&1; then
      skip "Xcode license accepted"
    elif sudo_keep; then
      _run "Xcode license" sudo xcodebuild -license accept && ok "Xcode license accepted" \
        || warn "Xcode license accept failed (see log)"
    fi
    if xcrun simctl list runtimes 2>/dev/null | grep -qi 'iOS'; then
      skip "iOS simulator runtime present"
    else
      info "downloading iOS simulator runtime (several GB)…"
      _run "iOS simulator runtime" xcodebuild -downloadPlatform iOS \
        && ok "iOS simulator runtime" || warn "iOS simulator download failed (see log) — xcodebuild -downloadPlatform iOS"
    fi
  fi
fi

# Surrealist on WSL: it's the Windows app (no Linux install) — install the latest
# from GitHub and launch it via the `surrealist` shell alias.
if is_wsl && has cmd.exe; then
  _sl_exe="$(wslpath "$(cmd.exe /c 'echo %LOCALAPPDATA%' 2>/dev/null | tr -d '\r')" 2>/dev/null)/Surrealist/surrealist.exe"
  if [ -x "$_sl_exe" ]; then
    skip "Surrealist (Windows) present"
  else
    info "installing Surrealist on Windows (latest)"
    _run "surrealist (windows)" bash "$DOTFILES/scripts/install-surrealist-windows.sh" \
      && ok "Surrealist (Windows)" || warn "Surrealist (Windows) install failed (see log)"
  fi
fi
