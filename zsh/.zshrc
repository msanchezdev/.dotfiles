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

# --- nvm (Node Version Manager; installed by the manifest into ~/.nvm) ---
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"

# --- portless (named .localhost dev URLs) ---
export PORTLESS_STATE_DIR="$HOME/.portless"
export PORTLESS_WILDCARD=1

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

# pencil-desktop — Linux/WSL only (GPU flags for Vulkan rendering).
[[ "$OSTYPE" == linux* ]] && alias pencil-desktop="$HOME/.local/bin/pencil-desktop --ignore-gpu-blocklist --enable-features=Vulkan"

# dotprofile — manage the device profile (rename/copy per-profile files):
#   dotprofile                      show current   dotprofile rename <new>        move
#   dotprofile rename <new> --copy  copy & switch
dotprofile() { "$HOME/.dotfiles/scripts/profile.sh" "$@"; }

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

# `obrew`: run Homebrew as whoever owns the prefix — for `brew install/upgrade`
# on a Mac where another account owns /opt/homebrew. Read-only brew commands
# (list, --prefix, shellenv) already work as any user, so use plain `brew` for
# those. No-op on single-user machines (you own it -> runs brew directly).
obrew() {
	local prefix owner
	prefix="$(brew --prefix 2>/dev/null)"; : "${prefix:=/opt/homebrew}"
	if [ "$(uname)" = Darwin ]; then       # macOS and Linux stat differ
		owner="$(stat -f '%Su' "$prefix" 2>/dev/null)"
	else
		owner="$(stat -c '%U' "$prefix" 2>/dev/null)"
	fi
	if [ -z "$owner" ] || [ "$owner" = "$(whoami)" ]; then
		brew "$@"
	else
		sudo -H -u "$owner" "$prefix/bin/brew" "$@"
	fi
}

# `clone <repo>`: clone into ~/git/<host>/<owner>/<repo> and cd in. Accepts:
#   owner/repo                 (host defaults to github.com)
#   host.tld/owner/repo        (first segment is the host when it has a dot)
#   https://host/owner/repo[.git]   or   git@host:owner/repo[.git]
clone() {
	# NB: `rpath`, not `path` — in zsh `path` is special (tied to $PATH).
	local input="${1:-}" host rpath dest first
	[ -z "$input" ] && { echo "usage: clone <owner/repo | host/owner/repo | url>" >&2; return 1; }
	case "$input" in
		*://*)   host="${input#*://}"; host="${host##*@}"; host="${host%%/*}"; rpath="${input#*://*/}" ;;
		*@*:*)   host="${input#*@}"; host="${host%%:*}"; rpath="${input##*:}" ;;
		*/*)     first="${input%%/*}"
		         case "$first" in
		           *.*) host="$first"; rpath="${input#*/}" ;;   # first segment is a host
		           *)   host="github.com"; rpath="$input" ;;
		         esac ;;
		*)       echo "clone: need owner/repo or a URL" >&2; return 1 ;;
	esac
	rpath="${rpath%.git}"; rpath="${rpath%/}"
	[ -z "$host" ] || [ -z "$rpath" ] && { echo "clone: couldn't parse '$input'" >&2; return 1; }
	dest="$HOME/git/$host/$rpath"
	if [ -d "$dest/.git" ]; then
		echo "already cloned: $dest"
	else
		mkdir -p "${dest:h}" && git clone "https://$host/$rpath.git" "$dest" || return 1
	fi
	cd "$dest"
}

# >>> dotfiles env >>>
[ -f "$HOME/.config/dotfiles/env.sh" ] && source "$HOME/.config/dotfiles/env.sh"
# <<< dotfiles env <<<
