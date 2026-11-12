#!/usr/bin/env bash
# Claude Code status line (public / personal edition).
#
#   Opus 5.5 · myproj@dotfiles        ctx ███░░░░░░░  31% 󰔟 · 5h  23% 2h14m · wk  41% 3d4h
#
# Left:  model · where you are (workmode project@domain, else the path).
# Right: context bar + prompt-cache hourglass · plan usage.
#
# "Plan usage" is the subscription's own budget: the 5-hour and 7-day rate-limit
# windows Claude Code passes in on stdin (`rate_limits`, Pro/Max/Team subscribers,
# after the first response). Each shows % used and time to reset. Without a
# subscription the slot falls back to:
#   - `spend` when behind a Claude apps gateway that sets a spend limit, or
#   - `~$` Claude Code's own local list-price session estimate (API key users).
#
# Everything comes from stdin, so there are no network calls, no cache files and
# no background jobs. The only on-disk cache is the per-cwd workmode label (below).
#
# Install: chezmoi puts this at ~/.claude/statusline.sh and points
# settings.json `statusLine.command` at it (run_onchange_after_claude-statusline).
# Machines with the private overlay keep their own status line instead.
#
# Docs: https://code.claude.com/docs/en/statusline
set -uo pipefail   # no -e: a missing field must degrade, never blank the line

CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/claude-statusline"

DIM=$'\033[2m'; RED=$'\033[31m'; YEL=$'\033[33m'; GRN=$'\033[32m'; OFF=$'\033[0m'
LBL=$'\033[38;5;117m'; ORG=$'\033[38;5;208m'   # 256-colour light blue + orange
# Nerd Font hourglasses for the prompt-cache state. All four are East-Asian width
# class A (ONE cell in a patched font), so ${#plain} measures them honestly. An
# emoji is class W: it measures 1 and draws 2, and the right-aligned tail drifts.
HG_FULL=$''   # nf-fa-hourglass_1  plenty of TTL left
HG_HALF=$''   # nf-fa-hourglass_2  half way
HG_LOW=$''    # nf-fa-hourglass_3  about to expire
HG_DEAD=$''   # nf-oct-hourglass   cold: the next request re-writes the whole prefix

now=$(date +%s)

# --- calibration --------------------------------------------------------------
# `statusLine.command` = "<this script> --ruler" prints a width ruler instead:
# digits mark every 10th column counting DOWN from the edge. Whatever number is
# still visible at the right end is how much gets clipped -> CLAUDE_STATUSLINE_MARGIN.
if [[ "${1:-}" == "--ruler" ]]; then
  cat >/dev/null
  w="${COLUMNS:-80}"; [[ "$w" =~ ^[0-9]+$ ]] || w=80
  line=""
  for (( i = w; i >= 1; i-- )); do
    if (( i % 10 == 0 )); then line+=$(( (i / 10) % 10 )); else line+="·"; fi
  done
  printf 'COLUMNS=%s %s\n' "$w" "$line"
  exit 0
fi

# --- helpers --------------------------------------------------------------------
is_int() { [[ "${1:-}" =~ ^[0-9]+$ ]]; }
is_num() { [[ "${1:-}" =~ ^[0-9]+([.][0-9]+)?$ ]]; }

pct_colour() {   # $1 = integer percent -> colour escape
  if   (( $1 >= 80 )); then printf '%s' "$RED"
  elif (( $1 >= 50 )); then printf '%s' "$YEL"
  else                      printf '%s' "$GRN"; fi
}

fmt_left() {   # $1 = seconds -> "42m" | "2h14m" | "3d4h"
  local s=$1
  (( s <= 0 )) && { printf 'now'; return; }
  if   (( s < 3600 ));  then printf '%dm' $(( (s + 59) / 60 ))
  elif (( s < 86400 )); then printf '%dh%02dm' $(( s / 3600 )) $(( s % 3600 / 60 ))
  else                       printf '%dd%dh' $(( s / 86400 )) $(( s % 86400 / 3600 )); fi
}

parse_iso() {   # ISO-8601 UTC timestamp -> epoch seconds (GNU date, then BSD date)
  local ts="$1" e
  e=$(date -d "$ts" +%s 2>/dev/null) && { printf '%s' "$e"; return 0; }
  e=$(date -j -u -f '%Y-%m-%dT%H:%M:%S' "${ts%%.*}" +%s 2>/dev/null) && { printf '%s' "$e"; return 0; }
  return 1
}

# --- where are we? ----------------------------------------------------------------
# With workmode installed, the label is the project@domain the tmux tab shows,
# resolved through the engine rather than reimplemented. It costs ~120ms (python
# start + a workspace scan), too slow to run on every refresh, so it is cached
# per-cwd. Without workmode this whole block is skipped and the path is shown.
LOC_TTL="${CLAUDE_STATUSLINE_LOC_TTL:-3600}"
PROJ_MAX="${CLAUDE_STATUSLINE_PROJECT_MAX:-28}"

shorten_label() {   # "<project>@<domain>" -> "<project trimmed>…@<domain>"
  local label="$1" proj dom
  [[ "$label" == *@* ]] || { printf '%s' "$label"; return; }
  proj="${label%@*}"; dom="${label##*@}"
  [[ -n "$proj" ]] || { printf '%s' "$label"; return; }        # "@domain" stays as is
  (( ${#proj} > PROJ_MAX )) && proj="${proj:0:PROJ_MAX}…"
  printf '%s@%s' "$proj" "$dom"
}

resolve_workmode() {   # $1 = cwd -> prints the label, or returns 1
  command -v workmode >/dev/null 2>&1 || return 1
  local dir="$1" key cache then_ts core label
  mkdir -p "$CACHE_DIR" 2>/dev/null || return 1
  key=$(printf '%s' "$dir" | cksum | tr -d ' /')
  cache="$CACHE_DIR/loc-$key"
  if [[ -r "$cache" ]]; then
    read -r then_ts < "$cache"
    is_int "$then_ts" || then_ts=0
    if (( now - then_ts < LOC_TTL )); then
      label=$(sed -n '2p' "$cache")
      [[ "$label" == "-" ]] && return 1         # cached miss: not a workmode location
      printf '%s\n' "$label"; return 0
    fi
  fi
  core=$(workmode core 2>/dev/null) || return 1
  [[ -n "$core" ]] || return 1
  # timeout: a wedged workspace scan must never hang the status line
  label=$(WM_CORE="$core" WM_DIR="$dir" timeout 5 python3 -c '
import sys, os
sys.path.insert(0, os.path.join(os.environ["WM_CORE"], "engine", "scripts"))
from work import discover_workspaces
t = os.path.realpath(os.environ["WM_DIR"]).rstrip("/")
best = best_r = None
for ws in discover_workspaces():
    r = os.path.realpath(ws.root).rstrip("/")
    if (t == r or t.startswith(r + os.sep)) and (best_r is None or len(best_r) < len(r)):
        best, best_r = ws, r
if best_r is None:
    sys.exit(2)                                   # not a workmode location
if t == best_r:
    print("@" + best.domain)                      # domain root
else:
    print(os.path.relpath(t, best_r).split(os.sep)[0] + "@" + best.domain)
' 2>/dev/null)
  case $? in
    0) ;;
    2) label="-" ;;                             # a definite miss: cache it too, or every
    *) return 1 ;;                              # render outside workmode pays ~120ms
  esac
  [[ -n "$label" ]] || return 1
  printf '%s\n%s\n' "$now" "$label" > "$cache.tmp" 2>/dev/null && mv -f "$cache.tmp" "$cache" 2>/dev/null
  [[ "$label" == "-" ]] && return 1
  printf '%s\n' "$label"
}

# --- read stdin -------------------------------------------------------------------
# One jq pass, tab-separated. EVERY field needs a non-empty "-" fallback: tab is
# IFS whitespace, so `read` merges consecutive tabs and an empty field would shift
# every field after it. (Tab-only IFS is still needed: "Opus 5.5" has a space.)
# jq's `//` treats false like null, so booleans are stringified explicitly.
input=$(cat)
IFS=$'\t' read -r model ctx_pct sess_cost cache_rd tok_total transcript cwd_in \
  pc_warm pc_expires pc_ttl rl5_pct rl5_reset rl7_pct rl7_reset sp_pct sp_used sp_limit < <(
  printf '%s' "$input" | jq -r '
    def s: if . == null then "-" else tostring end;
    [ (.model.display_name // .model.id // "claude"),
      (.context_window.used_percentage | s),
      (.cost.total_cost_usd | s),
      (.context_window.current_usage.cache_read_input_tokens | s),
      (.context_window.total_input_tokens | s),
      ((.transcript_path // "") | if . == "" then "-" else . end),
      ((.workspace.current_dir // .cwd // "") | if . == "" then "-" else . end),
      (.prompt_cache.warm | s),
      (.prompt_cache.expires_at | s),
      (.prompt_cache.ttl | s),
      (.rate_limits.five_hour.used_percentage | s),
      (.rate_limits.five_hour.resets_at | s),
      (.rate_limits.seven_day.used_percentage | s),
      (.rate_limits.seven_day.resets_at | s),
      (.rate_limits.spend_limit.used_percentage | s),
      (.rate_limits.spend_limit.used_usd | s),
      (.rate_limits.spend_limit.limit_usd | s)
    ] | @tsv' 2>/dev/null
)
[[ -n "${model:-}" ]] || model="claude"
is_int "${cache_rd:-}"  || cache_rd=0
is_int "${tok_total:-}" || tok_total=0
is_num "${sess_cost:-}" || sess_cost=0   # printf %f on a non-number would blank the line
[[ "${transcript:--}" == "-" ]] && transcript=""
[[ "${cwd_in:--}" == "-" ]] && cwd_in="$PWD"

BAR_W="${CLAUDE_STATUSLINE_BAR_WIDTH:-10}"

# --- left: model · location ---------------------------------------------------------
left="$model"; left_plain="$model"
if wm_label=$(resolve_workmode "$cwd_in"); then
  wm_label=$(shorten_label "$wm_label")
  loc="${LBL}${wm_label}${OFF}"; loc_plain="$wm_label"
elif [[ "$cwd_in" == "$HOME" || "$cwd_in" == "$HOME"/* ]]; then
  # ${x#"$HOME"} with quotes: strip exactly $HOME, never a glob-ish prefix
  p="~${cwd_in#"$HOME"}"
  loc="${ORG}${p}${OFF}"; loc_plain="$p"
else
  loc="${RED}${cwd_in}${OFF}"; loc_plain="$cwd_in"
fi
left+=" ${DIM}·${OFF} ${loc}"; left_plain+=" · ${loc_plain}"

right=""; right_plain=""

# --- prompt-cache hourglass -----------------------------------------------------------
# A cold cache re-writes the WHOLE prefix on the next request, so the cost of
# stepping away scales with how full the context is. Nothing else warns you.
# Preferred source: the `prompt_cache` object (warm + expires_at). It is documented
# but older builds did not send it, so fall back to deriving the state from the last
# response's cache-read share + its age, read from the transcript (NOT the file's
# mtime, which is touched without new API calls).
CACHE_TTL_S="${CLAUDE_STATUSLINE_CACHE_TTL:-3600}"   # subscription main-conversation default
cseg=""; cseg_plain=""
hg_set() { cseg="${1}${2}${OFF}"; cseg_plain="$2"; }
if [[ "$pc_warm" == "true" || "$pc_warm" == "false" ]]; then
  case "$pc_ttl" in 5m) ttl_s=300 ;; 1h) ttl_s=3600 ;; *) ttl_s=$CACHE_TTL_S ;; esac
  exp=${pc_expires%%.*}
  if [[ "$pc_warm" == "false" ]] || ! is_int "$exp" || (( exp <= now )); then
    hg_set "$RED" "$HG_DEAD"
  else
    used=$(( (ttl_s - (exp - now)) * 100 / ttl_s ))
    if   (( used >= 85 )); then hg_set "$ORG" "$HG_LOW"
    elif (( used >= 50 )); then hg_set "$YEL" "$HG_HALF"
    else                        hg_set "$GRN" "$HG_FULL"; fi
  fi
elif (( tok_total > 0 )); then
  age=-1
  if [[ -n "$transcript" && -r "$transcript" ]]; then
    # last 256K only: tail seeks, so cost is independent of transcript size
    ts=$(tail -c 262144 "$transcript" 2>/dev/null | grep '"usage"' \
         | grep -o '"timestamp":"[^"]*"' | tail -1 | cut -d'"' -f4)
    if [[ -n "$ts" ]] && then_s=$(parse_iso "$ts") && is_int "$then_s"; then
      age=$(( now - then_s ))
    fi
  fi
  share=$(( cache_rd * 100 / tok_total ))
  if   (( age >= CACHE_TTL_S || share == 0 ));                  then hg_set "$RED" "$HG_DEAD"
  elif (( age >= 0 && age * 100 / CACHE_TTL_S >= 85 ));         then hg_set "$ORG" "$HG_LOW"
  elif (( age >= 0 && age * 100 / CACHE_TTL_S >= 50 || share < 50 )); then hg_set "$YEL" "$HG_HALF"
  else                                                               hg_set "$GRN" "$HG_FULL"; fi
fi

# --- context bar ----------------------------------------------------------------------
if [[ "$ctx_pct" != "-" && -n "$ctx_pct" ]]; then
  pct=${ctx_pct%%.*}
  is_int "$pct" || pct=0
  (( pct > 100 )) && pct=100
  c=$(pct_colour "$pct")
  filled=$(( (pct * BAR_W + 50) / 100 ))
  (( pct > 0 && filled == 0 )) && filled=1                       # a sliver still shows
  (( pct < 100 && filled >= BAR_W )) && filled=$(( BAR_W - 1 ))  # full bar = really full
  printf -v on  '%*s' "$filled" '';               on=${on// /█}
  printf -v off '%*s' "$(( BAR_W - filled ))" ''; off=${off// /░}
  printf -v pctstr '%3d' "$pct"                  # constant width from 9% to 100%
  right+="${DIM}ctx${OFF} ${c}${on}${OFF}${DIM}${off}${OFF} ${c}${pctstr}%${OFF}"
  right_plain+="ctx ${on}${off} ${pctstr}%"
  if [[ -n "$cseg" ]]; then right+=" ${cseg}"; right_plain+=" ${cseg_plain}"; fi
fi

# --- plan usage (or its fallbacks) ------------------------------------------------------
usage=""; usage_plain=""
add_usage() {   # $1 colour seg, $2 plain seg
  if [[ -n "$usage_plain" ]]; then usage+=" ${DIM}·${OFF} "; usage_plain+=" · "; fi
  usage+="$1"; usage_plain+="$2"
}
rl_window() {   # $1 label, $2 pct, $3 resets_at
  local p=${2%%.*} r=${3%%.*} c pstr left_s=""
  is_int "$p" || return 0
  c=$(pct_colour "$p")
  printf -v pstr '%3d%%' "$p"
  is_int "$r" && left_s=" $(fmt_left $(( r - now )))"
  add_usage "${DIM}$1${OFF} ${c}${pstr}${OFF}${DIM}${left_s}${OFF}" "$1 ${pstr}${left_s}"
}
rl_window "5h" "$rl5_pct" "$rl5_reset"
rl_window "wk" "$rl7_pct" "$rl7_reset"

if [[ -z "$usage_plain" ]] && is_num "$sp_pct"; then          # Claude apps gateway spend limit
  sp=${sp_pct%%.*}; c=$(pct_colour "$sp")
  if is_num "$sp_used" && is_num "$sp_limit"; then
    printf -v s 'spend $%.0f/$%.0f' "$sp_used" "$sp_limit"
  else
    printf -v s 'spend %d%%' "$sp"
  fi
  add_usage "${c}${s}${OFF}" "$s"
fi

if [[ -z "$usage_plain" ]] && [[ "$sess_cost" != "0" ]]; then  # API key: local estimate
  printf -v s '~$%.2f' "$sess_cost"
  add_usage "${DIM}cost${OFF} ${s}" "cost ${s}"
fi

if [[ -n "$usage_plain" ]]; then
  if [[ -n "$right_plain" ]]; then right+=" ${DIM}·${OFF} "; right_plain+=" · "; fi
  right+="$usage"; right_plain+="$usage_plain"
fi

# --- layout -----------------------------------------------------------------------------
# Model flush left, the rest pushed right with INTERIOR padding: leading whitespace
# does not survive to the screen. Width is $COLUMNS (tput/stty cannot work, output is
# captured), and it is the TERMINAL width, so hold back a margin or the tail is cut.
# Terminal resize is not an update trigger; refreshInterval re-aligns.
MARGIN="${CLAUDE_STATUSLINE_MARGIN:-4}"
width="${COLUMNS:-0}"; is_int "$width" || width=0
gap=$(( width - ${#left_plain} - ${#right_plain} - MARGIN ))
(( gap < 1 )) && gap=1
printf -v spacer '%*s' "$gap" ''
printf '%s%s%s\n' "$left" "$spacer" "$right"
