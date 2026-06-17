# ~/.zshrc — rebuilding incrementally.
# Full previous config: `git show HEAD~:zsh/.zshrc` or ~/.zshrc.full.bak

# --- Homebrew + PATH ---
# Put brew (and everything it installs) on PATH: macOS Apple Silicon /opt,
# Linux /home/linuxbrew, Intel mac /usr/local.
for _brew in /opt/homebrew/bin/brew /home/linuxbrew/.linuxbrew/bin/brew /usr/local/bin/brew; do
  [ -x "$_brew" ] && eval "$("$_brew" shellenv)" && break
done
unset _brew
export PATH="$HOME/.local/bin:$PATH"             # user binaries (claude, ...)
[ -d "$HOME/.bun/bin" ] && export PATH="$HOME/.bun/bin:$PATH"

# --- oh-my-zsh (installed by the manifest into ~/.oh-my-zsh) ---
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"
plugins=(git)
[ -f "$ZSH/oh-my-zsh.sh" ] && source "$ZSH/oh-my-zsh.sh"

# --- fzf: key bindings (^R history, ^T files, Alt-C cd) + fuzzy completion ---
# Loaded after oh-my-zsh so its compinit has run. `fzf --zsh` needs fzf >= 0.48.
command -v fzf >/dev/null 2>&1 && source <(fzf --zsh)

# --- zoxide: smart jumping with `z` (and `zi` interactive). `cd` stays normal. ---
command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init zsh)"

# --- aliases ---
alias reload-source='source ~/.zshrc'                  # reload this shell config
# Update the dotfiles: pull latest, re-run the (idempotent) installer, then
# reload this shell. Faster local equivalent of re-running the curl bootstrap.
# Config-only, skip the heavier phases with:  ~/.dotfiles/install.sh stow env
alias dotup='git -C "$HOME/.dotfiles" pull --ff-only && "$HOME/.dotfiles/install.sh" && source ~/.zshrc'

# --- functions ---
# `y`: open yazi, and cd to wherever you quit it. Invoked as `y` — does NOT
# replace `cd`.
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	command yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && [ -d "$cwd" ] && builtin cd -- "$cwd"
	rm -f -- "$tmp"
}

# >>> dotfiles env >>>
[ -f "$HOME/.config/dotfiles/env.sh" ] && source "$HOME/.config/dotfiles/env.sh"
# <<< dotfiles env <<<
