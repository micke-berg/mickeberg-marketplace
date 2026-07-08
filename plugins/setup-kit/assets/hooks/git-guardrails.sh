#!/usr/bin/env bash
set -euo pipefail

# git-guardrails: block the git commands that lose work, before they run.
# Wired as a PreToolUse hook on the Bash tool. The install skill copies this to
# ~/.claude/hooks/git-guardrails.sh and merges the settings entry.
# Idea credit: Matt Pocock's git-guardrails-claude-code. Implementation is my own.
#
# Claude Code feeds the tool call as JSON on stdin. Exit 2 blocks the call and
# sends stderr back to the model as the reason. Exit 0 lets it through.

input=$(cat)

# Parsed with jq. Without jq the hook cannot read the command, so it fails open:
# it never blocks real work, but the guardrail is inactive until you install jq.
if ! command -v jq >/dev/null 2>&1; then
  exit 0
fi

# Only inspect Bash calls. Everything else passes straight through.
if [ "$(jq -r '.tool_name // ""' <<<"$input")" != "Bash" ]; then
  exit 0
fi

cmd=$(jq -r '.tool_input.command // ""' <<<"$input")

deny() {
  echo "git-guardrails blocked: $1" >&2
  echo "Run it yourself in a terminal if you really mean to." >&2
  exit 2
}

# Force push to a shared branch is the big one. --force-with-lease is allowed,
# since it refuses to clobber work it has not seen.
if grep -Eq 'git +push' <<<"$cmd" \
   && grep -Eq '(--force($|[^-])|-f($| ))' <<<"$cmd" \
   && grep -Eqw '(main|master|develop|release|prod|production)' <<<"$cmd"; then
  deny "force push that names a protected branch"
fi

# reason|extended-regex, first match wins
while IFS='|' read -r reason pattern; do
  if [ -z "$pattern" ]; then continue; fi
  if grep -Eq "$pattern" <<<"$cmd"; then deny "$reason"; fi
done <<'RULES'
reset --hard discards uncommitted work|git +reset +--hard\b
clean deletes untracked files|git +clean\b.*-[a-zA-Z]*[df]
force-delete of a branch|git +branch +-D\b
checkout . discards all local changes|git +checkout +(--[[:space:]]+)?\.[[:space:]]*$
repo-wide history rewrite|git +(filter-branch|filter-repo)\b
RULES

exit 0
