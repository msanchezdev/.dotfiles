# ~/.zshrc — rebuilding incrementally.
# Full previous config: `git show HEAD~:zsh/.zshrc` or ~/.zshrc.full.bak

# --- oh-my-zsh (installed by the manifest into ~/.oh-my-zsh) ---
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"
plugins=(git)
[ -f "$ZSH/oh-my-zsh.sh" ] && source "$ZSH/oh-my-zsh.sh"

# >>> dotfiles env >>>
[ -f "$HOME/.config/dotfiles/env.sh" ] && source "$HOME/.config/dotfiles/env.sh"
# <<< dotfiles env <<<
