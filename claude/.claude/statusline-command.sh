#!/usr/bin/env bash
# Claude Code status line — three-line layout:
#   Line 1: model | dir | git | k8s
#   Line 2: tokens bar  (input+output vs context window size)
#   Line 3: cost bar    (session cost vs $10 cap)

input=$(cat)

# --- ANSI color codes ---
RESET="\033[0m"

CYAN="\033[36m"              # model
GREEN="\033[32m"             # bar: 0-49%
YELLOW="\033[33m"            # bar: 50-79%
RED="\033[31m"               # bar: 80-100%
BLUE="\033[34m"              # git branch
ORANGE="\033[38;5;214m"      # kubernetes context
WHITE="\033[37m"             # cwd
SEP_COLOR="\033[38;5;240m"   # dim gray separator

SEP="${SEP_COLOR} | ${RESET}"

# --- Helper: build a 10-cell ASCII progress bar ---
# Usage: make_bar <percent_int>
# Returns the color-coded bar string via stdout.
make_bar() {
  local pct=$1
  local filled=$(( pct * 10 / 100 ))
  [ "$filled" -gt 10 ] && filled=10
  local empty=$(( 10 - filled ))

  local bar_color
  if [ "$pct" -ge 80 ]; then
    bar_color="${RED}"
  elif [ "$pct" -ge 50 ]; then
    bar_color="${YELLOW}"
  else
    bar_color="${GREEN}"
  fi

  local bar_fill=""
  local i
  for (( i=0; i<filled; i++ )); do bar_fill+="█"; done
  for (( i=0; i<empty;  i++ )); do bar_fill+="░"; done

  printf "%b" "${bar_color}[${bar_fill}]${RESET}"
}

# ---------------------------------------------------------------------------
# LINE 1 — info segments: model | dir | git | k8s
# ---------------------------------------------------------------------------

# Model
model=$(echo "$input" | jq -r '.model.display_name // empty')
[ -n "$model" ] && model_str="${CYAN}${model}${RESET}" || model_str=""

# Current working directory (basename only)
cwd=$(echo "$input" | jq -r '.workspace.current_dir // empty')
if [ -n "$cwd" ]; then
  dir_display=$(basename "$cwd")
  cwd_str="${WHITE}dir:${dir_display}${RESET}"
else
  cwd_str=""
fi

# Git branch (skip optional locks)
git_branch=$(GIT_OPTIONAL_LOCKS=0 git -C "${cwd:-$(pwd)}" rev-parse --abbrev-ref HEAD 2>/dev/null)
[ -n "$git_branch" ] && branch_str="${BLUE}git:${git_branch}${RESET}" || branch_str=""

# kubectl current-context — detect OpenShift via heuristic on context/server name
kube_ctx=$(kubectl config current-context 2>/dev/null)
if [ -n "$kube_ctx" ]; then
  kube_server=$(kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}' 2>/dev/null)
  if echo "${kube_ctx}${kube_server}" | grep -qiE 'openshift|\.ocp\.|openshiftapps'; then
    kube_prefix="ocp"
  else
    kube_prefix="k8s"
  fi
  kube_str="${ORANGE}${kube_prefix}:${kube_ctx}${RESET}"
else
  kube_str=""
fi

# Assemble line 1
line1_parts=()
[ -n "$model_str"  ] && line1_parts+=("$model_str")
[ -n "$cwd_str"    ] && line1_parts+=("$cwd_str")
[ -n "$branch_str" ] && line1_parts+=("$branch_str")
[ -n "$kube_str"   ] && line1_parts+=("$kube_str")

line1=""
for i in "${!line1_parts[@]}"; do
  if [ "$i" -eq 0 ]; then
    line1="${line1_parts[$i]}"
  else
    line1="${line1}${SEP}${line1_parts[$i]}"
  fi
done

# ---------------------------------------------------------------------------
# LINE 2 — tokens bar: (input+output) / context_window_size
# ---------------------------------------------------------------------------

ctx_size=$(echo "$input" | jq -r '.context_window.context_window_size // empty')
cur_in=$(echo "$input"   | jq -r '.context_window.current_usage.input_tokens  // empty')
cur_out=$(echo "$input"  | jq -r '.context_window.current_usage.output_tokens // empty')

if [ -n "$ctx_size" ] && [ -n "$cur_in" ] && [ -n "$cur_out" ] && [ "$ctx_size" -gt 0 ]; then
  total_tokens=$(( cur_in + cur_out ))
  tok_pct=$(awk "BEGIN {v=int($total_tokens*100/$ctx_size); if(v>100) v=100; print v}")
  tok_bar=$(make_bar "$tok_pct")
  total_k=$(awk "BEGIN {printf \"%.1fk\", $total_tokens/1000}")
  max_k=$(awk   "BEGIN {printf \"%.0fk\", $ctx_size/1000}")
  line2="tokens $(printf "%b" "$tok_bar") ${total_k}/${max_k} (${tok_pct}%)"
else
  line2="tokens $(printf "%b" "${YELLOW}[░░░░░░░░░░]${RESET}") --/--"
fi

# ---------------------------------------------------------------------------
# LINE 3 — cost bar: session cost / $10 cap
# ---------------------------------------------------------------------------

# Pricing: claude-sonnet-4-6 $3/M input, $15/M output
COST_CAP=10
total_in=$(echo "$input"  | jq -r '.context_window.total_input_tokens  // 0')
total_out=$(echo "$input" | jq -r '.context_window.total_output_tokens // 0')
cost=$(awk "BEGIN {printf \"%.3f\", ($total_in/1000000)*3 + ($total_out/1000000)*15}")
cost_pct=$(awk "BEGIN {v=int(($cost/$COST_CAP)*100); if(v>100) v=100; print v}")
cost_bar=$(make_bar "$cost_pct")
line3="cost   $(printf "%b" "$cost_bar") \$${cost}/\$${COST_CAP} (${cost_pct}%)"

# ---------------------------------------------------------------------------
# Output — three lines separated by literal newlines
# ---------------------------------------------------------------------------

printf "%b\n%b\n%b" "$line1" "$line2" "$line3"
