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

# surrealql-nvim is a local dogfood checkout with no git remote, so it can't be
# auto-cloned. Just flag its absence.
surql="$HOME/.local/src/surrealql-nvim"
[ -d "$surql" ] || warn "missing local checkout: $surql (surrealql-nvim plugin will error)"
