#!/usr/bin/env zsh
# Claude Code statusLine command
# Receives Claude Code session JSON on stdin.
# Outputs a single-line status string with segments separated by " | ".
# Segments are omitted when their value is unavailable.
# POSIX/zsh; needs jq and bc. The install skill places this on macOS/Linux.

input=$(cat)

# 1. Git branch — derived from the cwd in the JSON, not the shell cwd
cwd=$(echo "$input" | jq -r '.workspace.current_dir // empty')
branch=""
if [ -n "$cwd" ]; then
  branch=$(git -C "$cwd" --no-optional-locks rev-parse --abbrev-ref HEAD 2>/dev/null)
fi

# 2. Model id
model=$(echo "$input" | jq -r '.model.id // empty')

# 3. Context usage — rendered as a 10-char filled bar, e.g. [████░░░░░░]
used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
if [ -n "$used" ]; then
  filled=$(printf '%.0f' "$(echo "$used * 10 / 100" | bc -l)")
  empty=$((10 - filled))
  bar="["
  for i in $(seq 1 $filled); do bar="${bar}█"; done
  for i in $(seq 1 $empty);  do bar="${bar}░"; done
  bar="${bar}]"
  ctx_seg="$bar"
fi

# 4. Session cost — not exposed by Claude Code; segment is always omitted

# 5. Current directory, shortened to ~/...
short_dir=""
if [ -n "$cwd" ]; then
  home="$HOME"
  if [[ "$cwd" == "$home"* ]]; then
    short_dir="~${cwd#$home}"
  else
    short_dir="$cwd"
  fi
fi

# Build output — only include non-empty segments
parts=()
[ -n "$branch" ]   && parts+=("$branch")
[ -n "$model" ]    && parts+=("$model")
[ -n "$ctx_seg" ]  && parts+=("$ctx_seg")
[ -n "$short_dir" ] && parts+=("$short_dir")

# Join with " | "
out=""
for part in "${parts[@]}"; do
  if [ -z "$out" ]; then
    out="$part"
  else
    out="$out | $part"
  fi
done

echo "$out"
