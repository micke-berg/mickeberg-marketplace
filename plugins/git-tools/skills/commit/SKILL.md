---
name: commit
description: Write and execute a git commit using Conventional Commits format, with an approval gate. Use this skill whenever the user says "commit", "commit this", "write a commit message", "/commit", "save my changes", or has finished a task and says something like "looks good, commit it" or "done, let's commit".
---

# Commit

Draft a Conventional Commits message for the staged changes, show it for approval, and commit only after the user approves.

## Customize (edit this block for your team)

Everything team-specific lives here so the rest of the skill stays generic. This one block is the whole configuration surface.

- **Ticket prefix**: `AUTO` — detect an issue id like `ABC-123` from the branch name and put it at the front of the summary. Set a fixed string, or `NONE` to disable. The pattern AUTO looks for is `[A-Z][A-Z0-9]+-\d+` (matches Jira-style keys such as `PROJ-42`, `TIP-17837`).
- **Scope**: `AUTO` — derive the scope from the top-level folder or package of the changed files. Replace with your own path-to-scope map if you prefer fixed names.
- **Attribution**: `OFF` — do not add `Co-Authored-By` or any tool-credit trailer. Set to `ON` if your team wants them.
- **Allowed types**: `feat, fix, chore, refactor, test, docs, perf, build, ci, style`.

## Workflow

1. Run `git diff --cached` to see staged changes. If nothing is staged, run `git diff`, tell the user nothing is staged, and offer to stage specific files. Do not stage everything blindly.
2. Run `git branch --show-current` to get the branch name.
3. Draft the message from the diff, using the format below.
4. Show the message to the user and wait for approval. Never commit before the user approves.
5. Once approved, commit with a newline-preserving method for the current shell (see below).

The review-before-commit step matters: history is permanent and visible to the whole team.

## Message format

```
[<ticket> ]<type>(<scope>): <short summary>

[optional body]
```

- **ticket** — per the Customize block. `AUTO` extracts a key like `ABC-123` from a branch such as `ABC-123-fix-button`. If none is found, omit the prefix entirely.
- **type** — one of the allowed types.
- **scope** — per the Customize block. `AUTO` uses the top-level folder or package of the changed files (for example, changes under `src/api/` give `api`). If the changes span scopes, use the primary one and mention the rest in a body line. Omit the scope and its parentheses when there is no meaningful one.
- **short summary** — lowercase, no trailing period, under ~60 characters. Keep the whole first line under ~80.

### Body

Most commits do not need a body. Add one or two short lines only when the what or why is not obvious from the first line alone.

### Writing style

Write like a human talking to a colleague, not a press release. Say "fix amount rounding on partial payments", not "implement comprehensive rounding solution for enhanced accuracy".

Avoid these words: enhance, leverage, utilize, robust, comprehensive, streamline, facilitate, optimize (unless you mean a measured performance win).

**Good**
- `ABC-123 feat(api): add CSV export to transactions endpoint`
- `fix(ui): correct amount rounding on partial payments`
- `chore: bump eslint to 9.14`
- `refactor(auth): extract token refresh into its own module`

**Bad (and why)**
- `feat(api): Enhance transactions with robust CSV export functionality` — fancy, says nothing useful
- `feat: Add CSV export feature to the transactions endpoint for better UX` — filler, too long

## Committing (cross-platform)

Show the message first. After approval, commit with a method that preserves newlines in the shell you are actually in.

**bash / zsh (macOS, Linux, Git Bash):**
```bash
git commit -m "$(cat <<'EOF'
ABC-123 feat(api): add CSV export

Adds a download endpoint that streams filtered rows as CSV.
EOF
)"
```

**PowerShell (Windows):**
```powershell
git commit -m @'
ABC-123 feat(api): add CSV export

Adds a download endpoint that streams filtered rows as CSV.
'@
```

A single-line message can just use `git commit -m "type(scope): summary"` in any shell.

## Rules

- Never commit without showing the message and getting approval first.
- Follow the Attribution setting. Default is `OFF`: no `Co-Authored-By` and no tool-credit trailers.
- Do not amend, rebase, or force unless the user explicitly asks.

## Extra context from the user

$ARGUMENTS
