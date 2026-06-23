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

# --- render: colored text, ' · ' separated (Dracula palette, no backgrounds) --
ESC=$'\033'; RST="${ESC}[0m"; DIM="${ESC}[2m"
COMMENT="${ESC}[38;2;98;114;164m"   # #6272a4
CYAN="${ESC}[38;2;139;233;253m"     # #8be9fd
GREEN="${ESC}[38;2;80;250;123m"     # #50fa7b
YELLOW="${ESC}[38;2;241;250;140m"   # #f1fa8c
ORANGE="${ESC}[38;2;255;184;108m"   # #ffb86c
PINK="${ESC}[38;2;255;121;198m"     # #ff79c6
RED="${ESC}[38;2;255;85;85m"        # #ff5555
SEP="${DIM} · ${RST}"
WT=$'⑂'; RLD=$'↻'

out=""
add() { [ -z "$out" ] && out="$1" || out="${out}${SEP}$1"; }
_remain() { if [ "$1" -lt 20 ]; then printf '%s' "$RED"; elif [ "$1" -lt 50 ]; then printf '%s' "$ORANGE"; else printf '%s' "$GREEN"; fi; }
_used()   { if [ "$1" -ge 80 ]; then printf '%s' "$RED"; elif [ "$1" -ge 50 ]; then printf '%s' "$YELLOW"; else printf '%s' "$GREEN"; fi; }

[ -n "$model" ]    && add "${DIM}${model}${RST}"
[ -n "$dir_name" ] && add "${CYAN}${dir_name}${RST}"
[ -n "$git_wt" ]   && add "${PINK}${WT} ${git_wt}${RST}"
if [ -n "$git_branch" ]; then
  if [ -n "$git_dirty" ]; then add "${ORANGE}${git_branch}*${RST}"; else add "${GREEN}${git_branch}${RST}"; fi
fi
[ -n "$ctx_pct" ]  && add "$(_used "$ctx_pct")ctx ${ctx_pct}%${RST}"

# session (5h) usage left + reset countdown
_u5=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
if [ -n "$_u5" ]; then
  _l5=$(( 100 - _u5 )); _seg5="$(_remain "$_l5")5h ${_l5}%${RST}"
  _r5=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // empty'); _now=$(date +%s)
  if [ -n "$_r5" ] && [ "$_r5" -gt "$_now" ] 2>/dev/null; then
    _s=$(( _r5 - _now )); _h=$(( _s / 3600 )); _m=$(( (_s % 3600) / 60 ))
    [ "$_h" -gt 0 ] && _rs="${_h}h${_m}m" || _rs="${_m}m"
    _seg5="${_seg5} ${DIM}${RLD}${_rs}${RST}"
  fi
  add "$_seg5"
fi

# weekly (7d) usage left
_u7=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')
[ -n "$_u7" ] && add "$(_remain "$(( 100 - _u7 ))")7d $(( 100 - _u7 ))%${RST}"

# session cost (comment → orange ≥$1 → red ≥$5)
_cost=$(echo "$input" | jq -r '.cost.total_cost_usd // empty')
if [ -n "$_cost" ]; then
  _cf="$COMMENT"
  awk "BEGIN{exit !(${_cost} >= 1)}" 2>/dev/null && _cf="$ORANGE"
  awk "BEGIN{exit !(${_cost} >= 5)}" 2>/dev/null && _cf="$RED"
  add "${_cf}\$$(printf '%.2f' "$_cost")${RST}"
fi

[ -n "$schemic_ver" ] && add "${COMMENT}${schemic_ver}${RST}"

printf '%s\n' "$out"
