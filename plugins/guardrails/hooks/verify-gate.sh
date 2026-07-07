#!/bin/bash
# Plugin hook: PreToolUse (Bash|PowerShell) — OPTIONAL, OFF BY DEFAULT.
#
# Blocks `git push` unless BOTH are true:
#   1. the repo opted in by creating the file .guardrails/gate-on, and
#   2. a fresh .guardrails/verify-pass.json (pass:true, < MAX_AGE_MIN old) exists.
#
# Without .guardrails/gate-on this hook does nothing. Exit 2 blocks and feeds the
# message back to Claude; every other path exits 0 so it can never wrongly block.
#
# JSON is parsed with node (portable, and avoids the python3 Store-alias stub on
# Windows). Requires bash: native on macOS/Linux, Git Bash on Windows.

INPUT=$(cat)
CMD=$(echo "$INPUT" | node -e "let d='';process.stdin.on('data',c=>d+=c).on('end',()=>{try{console.log(JSON.parse(d).tool_input?.command??'')}catch{}})" 2>/dev/null)

# Only care about `git push`.
case "$CMD" in
  *"git push"*) ;;
  *) exit 0 ;;
esac

# Resolve the repo root of the current working directory.
ROOT=$(git rev-parse --show-toplevel 2>/dev/null)
[ -n "$ROOT" ] || exit 0

# Opt-in switch: no-op unless this repo created .guardrails/gate-on.
[ -f "$ROOT/.guardrails/gate-on" ] || exit 0

MARKER="$ROOT/.guardrails/verify-pass.json"
MAX_AGE_MIN=60

fail() {
  echo "guardrails verify-gate: $1" >&2
  echo "Run /guardrails:verify until green (it writes .guardrails/verify-pass.json), then push. To turn this gate off, delete .guardrails/gate-on." >&2
  exit 2
}

[ -f "$MARKER" ] || fail "no verify-pass marker — /guardrails:verify has not passed for this change."

# The marker must actually say pass:true.
if [ "$(node -e "try{console.log(JSON.parse(require('fs').readFileSync(0,'utf8')).pass===true)}catch{console.log(false)}" < "$MARKER" 2>/dev/null)" != "true" ]; then
  fail "the last verify did not pass — re-run /guardrails:verify until green."
fi

# Freshness: the marker must reflect the current change, not an old run.
if ! find "$MARKER" -mmin -$MAX_AGE_MIN 2>/dev/null | grep -q .; then
  fail "verify-pass marker is older than $MAX_AGE_MIN minutes — re-run /guardrails:verify."
fi

exit 0
