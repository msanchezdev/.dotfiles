#!/usr/bin/env bash
input=$(cat)

cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // ""')
model=$(echo "$input" | jq -r '.model.display_name // ""')
project_dir=$(echo "$input" | jq -r '.workspace.project_dir // ""')

# Current directory basename
dir_name=$(basename "$cwd")

# Git branch + dirty marker (skip hooks/optional locks; head -1 stops at first change for speed)
git_branch=""
git_dirty=""
if [ -n "$cwd" ] && git -C "$cwd" rev-parse --git-dir >/dev/null 2>&1; then
  git_branch=$(git -C "$cwd" -c core.hooksPath=/dev/null symbolic-ref --short HEAD 2>/dev/null \
               || git -C "$cwd" rev-parse --short HEAD 2>/dev/null)
  [ -n "$(git -C "$cwd" status --porcelain 2>/dev/null | head -1)" ] && git_dirty="*"
fi

# Schemic version: read packages/core/package.json from the workspace project root
schemic_ver=""
pkg_json="${project_dir}/packages/core/package.json"
if [ -f "$pkg_json" ]; then
  _ver=$(jq -r '.version // empty' "$pkg_json" 2>/dev/null)
  [ -n "$_ver" ] && schemic_ver="v${_ver}"
fi

# Linked-worktree indicator: a worktree's git-dir lives under <main>/.git/worktrees/<name>.
# Empty in the main checkout. Name = the worktree's working-dir basename.
git_wt=""
if [ -n "$git_branch" ]; then
  _gitdir=$(git -C "$cwd" rev-parse --absolute-git-dir 2>/dev/null)
  case "$_gitdir" in
    */worktrees/*) git_wt=$(basename "$(git -C "$cwd" rev-parse --show-toplevel 2>/dev/null)") ;;
  esac
fi

# Context usage %: sum the latest transcript usage entry (input + cache read + cache creation)
# against the model's window (1M for the [1m] variant, else 200k).
ctx_pct=""
tp=$(echo "$input" | jq -r '.transcript_path // ""')
if [ -f "$tp" ]; then
  _usage=$(tac "$tp" 2>/dev/null | grep -m1 'cache_read_input_tokens')
  if [ -n "$_usage" ]; then
    _used=$(printf '%s' "$_usage" | jq -r '(.message.usage // .usage) as $u | ($u.input_tokens + ($u.cache_read_input_tokens // 0) + ($u.cache_creation_input_tokens // 0)) // empty' 2>/dev/null)
    _mid=$(echo "$input" | jq -r '(.model.id // "") + " " + (.model.display_name // "")' | tr '[:upper:]' '[:lower:]')
    case "$_mid" in *1m*) _limit=1000000 ;; *) _limit=200000 ;; esac
    [ -n "$_used" ] && [ "$_used" -gt 0 ] 2>/dev/null && ctx_pct=$(( _used * 100 / _limit ))
  fi
fi

# ANSI helpers
DIM="\033[2m"
RST="\033[0m"
CYAN="\033[0;36m"
YELLOW="\033[0;33m"
RED="\033[0;31m"
GREEN="\033[0;32m"
MAGENTA="\033[0;35m"
SEP="${DIM} · ${RST}"

# Assemble left-to-right: model · dir · branch[*] · version
out=""
add() { [ -z "$out" ] && out="$1" || out="${out}${SEP}$1"; }

[ -n "$model" ]     && add "${DIM}${model}${RST}"
[ -n "$dir_name" ]  && add "${CYAN}${dir_name}${RST}"
[ -n "$git_wt" ]    && add "${MAGENTA}⑂ ${git_wt}${RST}"

if [ -n "$git_branch" ]; then
  branch_seg="${YELLOW}${git_branch}${RST}"
  [ -n "$git_dirty" ] && branch_seg="${branch_seg}${RED}*${RST}"
  add "$branch_seg"
fi

if [ -n "$ctx_pct" ]; then
  ctx_color="$GREEN"
  [ "$ctx_pct" -ge 50 ] && ctx_color="$YELLOW"
  [ "$ctx_pct" -ge 80 ] && ctx_color="$RED"
  add "${ctx_color}ctx ${ctx_pct}%${RST}"
fi

[ -n "$schemic_ver" ] && add "${GREEN}${schemic_ver}${RST}"

printf "%b\n" "$out"
