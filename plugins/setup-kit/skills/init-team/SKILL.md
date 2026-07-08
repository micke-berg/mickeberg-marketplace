---
name: init-team
description: Interview a team lead or solo dev about a repo, then write a professional CLAUDE.md project brief and a .claude/settings.json permissions baseline tuned to the stack. Reads everything it can from the repo first and only asks about what it can't detect. Shows both files for approval before writing. Use when the user says "init team", "set up this repo for Claude", "write a CLAUDE.md", "onboard this repo", "generate a project brief", or when a repo has no CLAUDE.md and should.
---

# Init team

Give a repo a `CLAUDE.md` that makes every future Claude Code session start informed, plus a `.claude/settings.json` that sets a sane permission posture for the team. The output is short, accurate, and in the project's own terms, a brief that gets read, not a wall that gets skipped.

The method is one rule: **read before you ask.** A repo answers most of its own questions: the stack, the scripts, the commit style, the CI. Detect all of that first. Spend the interview only on what a repo cannot tell you: the boundaries in people's heads, the pain points, the hard "never" rules, and how much autonomy the team wants to grant. Works the same for a ten-person team and a solo dev. The solo run is just shorter.

## Customize (edit this block for the engagement)

- **Templates**: `AUTO`, pick the CLAUDE.md skeleton by detected stack from `templates/claude-md/` in this plugin (`nextjs-ts.md`, `dotnet.md`, else `generic.md`). Force one by name if detection is wrong.
- **Mode**: `AUTO`, detect team vs solo from the git history (many authors vs one) and ask a shorter set for solo. Force `TEAM` or `SOLO`.
- **Write settings**: `ON`, also write `.claude/settings.json` with a project permission baseline. `OFF` to produce only the CLAUDE.md.
- **Depth**: `STANDARD`, a one-page brief. `MINIMAL` for a stub to grow, `FULL` to include a docs map and testing detail.
- **Approval**: `ON`, always show both files and wait for a yes before writing. Keep this on.

## Step 1, Detect (read the repo, ask nothing yet)

Gather everything the repo already knows. Do not ask about any of this. Confirm it later in one line.

- **Stack and runtime.** `package.json` (and lockfile → package manager), `*.csproj` / `*.sln`, `pyproject.toml` / `requirements.txt`, `go.mod`, `Gemfile`, `Cargo.toml`. Framework from dependencies (Next.js, ASP.NET, Django, etc.).
- **Scripts / commands.** `package.json` scripts, a `Makefile`, `dotnet` project layout, `tox.ini` / `manage.py`. The real dev / test / build / lint commands.
- **Existing docs.** `README.md`, an existing `CLAUDE.md` or `AGENTS.md`, a `docs/` dir, `CONTRIBUTING.md`. If a CLAUDE.md already exists, you are improving it, not clobbering it. Read it and diff intent.
- **Conventions from history.** `git log --oneline -30` for commit style (Conventional Commits? issue keys? scopes?). `git branch -a` for branch naming. A `.github/` for PR templates and CI (lint/typecheck/test/build steps reveal the real gate).
- **Structure and boundaries (candidates).** Top-level folders, where entrypoints vs logic vs shared code live. Note apparent boundaries to confirm, don't assert them.
- **Tests.** Test framework and where tests live, from config and folders.

Write down what you found. This becomes the draft's backbone and the confirm-in-one-line list.

## Step 2, Interview (only the gaps)

Ask only what step 1 could not answer. Keep it to a handful of questions, one at a time, plain language. Lead with a quick confirm of detection, then the human-only questions:

1. **Confirm detection.** "This looks like a `<stack>` repo using `<pm>`, dev is `<cmd>`, tests are `<cmd>`. Right?" Correct from the answer.
2. **Boundaries.** "What are the rules about how this code is organized that a newcomer gets wrong? For example, what should never call what?"
3. **Pain points.** "What does an AI assistant, or a new hire, most often get wrong in this repo?"
4. **Hard nevers.** "What should Claude never do here? Files it must not touch, actions that need a human, things that look editable but aren't."
5. **Ask-before.** "What should it check with a person first? Schema changes, new dependencies, auth, public API?"
6. **Autonomy / permissions.** "How much should it do without asking: ask for most things, edit files freely but ask before running commands, or broad autonomy?" (maps to `default` / `acceptEdits` / `auto`).
7. **Docs ownership** (FULL depth only). "Which document owns what, so it updates the right one?"

For a SOLO run, collapse to confirm-detection, hard-nevers, and autonomy. Don't manufacture team ceremony a solo dev doesn't have.

## Step 3, Draft

1. **Pick the template** by detected stack and load it from `templates/claude-md/`.
2. **Fill it** from detection (step 1) and answers (step 2). Every `<PLACEHOLDER>` is filled or its line removed. No placeholder ships. No section left empty. An empty section is worse than a missing one.
3. **Keep it tight.** One page at STANDARD depth. Cut anything the reader already knows. Specific and true beats complete.
4. **Voice.** Plain and direct, the project's own terms. No corporate filler, no invented specifics. If you didn't detect or hear it, don't assert it. Leave it out or ask.
5. **Draft `.claude/settings.json`** (if Write settings is ON) from `templates/settings/settings.baseline.json`, setting `permissions.defaultMode` to the autonomy answer and adding any repo-specific `deny` the "hard nevers" imply. Project settings, committed, layered over the user's global.

## Step 4, Approve, then write

- **Show both files in full** and wait for an explicit yes. This is the approval gate. Never write before it.
- On yes, write `CLAUDE.md` at the repo root and `.claude/settings.json` (create `.claude/` if needed). If a CLAUDE.md existed, show what changed.
- On changes requested, revise and show again.
- **Close** by pointing at next steps: read the brief, run `team-baseline` to grade the repo against a professional bar, wire the `verify` gate.

## Rules

- **Read before you ask.** Never ask what the repo answers. Asking for the stack when `package.json` is right there erodes trust immediately.
- **Never invent specifics.** No made-up commands, boundaries, or business rules. Detected or heard, or it doesn't go in.
- **Approval before writing.** Both files shown, explicit yes, then write. No surprise files.
- **Don't clobber.** An existing CLAUDE.md is improved with intent preserved, not overwritten blind.
- **Short wins.** A one-page brief that gets read beats a thorough one that doesn't.

## Extra context from the user

$ARGUMENTS
