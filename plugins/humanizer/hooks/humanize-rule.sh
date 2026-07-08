#!/usr/bin/env bash

# Injects a standing rule at session start so public-facing text is humanized
# automatically, as the last step, without the user having to add it to
# CLAUDE.md by hand. The rule is a soft, model-followed instruction (same
# mechanism as Claude Code's output-style modes), not a hard gate.

cat << 'EOF'
{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": "Standing rule (humanizer plugin): before finalizing any PUBLIC-FACING text you produce (anything other people will read: PR and ticket descriptions, posts, external messages, published docs), run it through the `humanizer` skill as the LAST step, so it carries no AI traces while keeping the author's voice intact. This is not optional and is never skipped, even when a voice has already been applied. Internal-only text (commit messages, code and comments, private notes, replies to the user in this chat) is exempt. If the humanizer skill is not installed, apply its AI-tell removal directly instead of skipping."
  }
}
EOF

exit 0
