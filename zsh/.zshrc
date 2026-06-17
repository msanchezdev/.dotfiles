# ~/.zshrc — rebuilding incrementally.
# Full previous config: `git show HEAD~:zsh/.zshrc` or ~/.zshrc.full.bak

# --- oh-my-zsh (installed by the manifest into ~/.oh-my-zsh) ---
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"
plugins=(git)
[ -f "$ZSH/oh-my-zsh.sh" ] && source "$ZSH/oh-my-zsh.sh"

# --- fzf: key bindings (^R history, ^T files, Alt-C cd) + fuzzy completion ---
# Loaded after oh-my-zsh so its compinit has run. `fzf --zsh` needs fzf >= 0.48.
command -v fzf >/dev/null 2>&1 && source <(fzf --zsh)

# --- aliases ---
alias reload-source='source ~/.zshrc'                  # reload this shell config
# Update the dotfiles: pull latest, re-run the (idempotent) installer, then
# reload this shell. Faster local equivalent of re-running the curl bootstrap.
# Config-only, skip the heavier phases with:  ~/.dotfiles/install.sh stow env
alias dotup='git -C "$HOME/.dotfiles" pull --ff-only && "$HOME/.dotfiles/install.sh" && source ~/.zshrc'

# >>> dotfiles env >>>
[ -f "$HOME/.config/dotfiles/env.sh" ] && source "$HOME/.config/dotfiles/env.sh"
# <<< dotfiles env <<<
