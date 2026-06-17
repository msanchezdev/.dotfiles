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

# >>> dotfiles env >>>
[ -f "$HOME/.config/dotfiles/env.sh" ] && source "$HOME/.config/dotfiles/env.sh"
# <<< dotfiles env <<<
