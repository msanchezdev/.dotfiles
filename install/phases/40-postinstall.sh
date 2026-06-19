# shellcheck shell=bash
# Phase 40 — post-install bootstrap that depends on configs being in place.

step "Post-install"

# tmux plugin manager: install configured plugins headlessly.
tpm_dir="$HOME/.tmux/plugins/tpm"
if [ -x "$tpm_dir/bin/install_plugins" ]; then
  info "installing tmux plugins"
  "$tpm_dir/bin/install_plugins" >/dev/null 2>&1 && ok "tmux plugins" || warn "tpm install failed"
else
  skip "tpm not present (added by manifest git package)"
fi

# Neovim: sync lazy.nvim plugins (also triggers treesitter/LSP builds on first run).
if has nvim; then
  info "syncing neovim plugins (headless, may take a minute)"
  nvim --headless "+Lazy! sync" +qa >/dev/null 2>&1 && ok "neovim plugins" \
    || warn "nvim plugin sync had issues — open nvim and run :Lazy"
else
  skip "nvim not installed"
fi

# Make zsh the default login shell. The git-cloned oh-my-zsh (unlike the
# official installer) doesn't run chsh, so a fresh Linux box would stay on bash.
# Idempotent: a no-op once the login shell is already zsh.
if [ -L "$HOME/.zshrc" ] || [ -e "$HOME/.zshrc" ]; then
  zsh_path="$(command -v zsh || true)"
  current_shell="$(getent passwd "$USER" 2>/dev/null | cut -d: -f7)"
  [ -z "$current_shell" ] && current_shell="${SHELL:-}"   # macOS has no getent
  if [ -z "$zsh_path" ]; then
    skip "zsh not found — leaving default shell"
  elif [ "$current_shell" = "$zsh_path" ]; then
    skip "default shell already zsh"
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

# SSH server (key-only, reached over Tailscale). Drop the hardening config into
# /etc/ssh/sshd_config.d/ and enable sshd. Linux: openssh-server (manifest) +
# systemd/service; macOS: built-in sshd via Remote Login. Needs sudo.
_sshd_conf="$DOTFILES/etc/ssh/sshd_config.d/10-dotfiles-hardening.conf"
if { [ "$(os_id)" = linux ] && [ -x /usr/sbin/sshd ]; } || [ "$(os_id)" = macos ]; then
  if sudo_keep; then
    info "configuring ssh server (key-only)"
    sudo mkdir -p /etc/ssh/sshd_config.d
    sudo install -m 0644 "$_sshd_conf" /etc/ssh/sshd_config.d/ \
      && ok "sshd key-only config" || warn "couldn't write /etc/ssh/sshd_config.d/"
    [ -s "$HOME/.ssh/authorized_keys" ] \
      || warn "no ~/.ssh/authorized_keys — add your public key or key-only SSH will lock you out"
    if [ "$(os_id)" = macos ]; then
      if sudo systemsetup -setremotelogin on >/dev/null 2>&1; then
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
