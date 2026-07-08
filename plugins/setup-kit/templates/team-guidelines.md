<!--
  Team AI guidelines skeleton.
  A short, opinionated playbook for a team adopting Claude Code together. The
  structure is the useful part. Fill the content for your team and delete the
  rest. Aim for one page people actually read, not a policy binder. Everything in
  <ANGLE_BRACKETS> is a prompt to replace.
-->

# <TEAM / ORG>, working with Claude Code

How we use AI assistants on this codebase. Short on purpose. If a rule here ever fights getting good work shipped safely, raise it, this is a living doc, not law from on high.

## What this is for

Claude Code is a tool we use to move faster without lowering the bar. It writes and edits code, runs our checks, and drafts commits and PRs. It does not replace judgment, review, or ownership. **The person who runs it owns the result** exactly as if they had typed it.

## When to reach for it

- <e.g. boilerplate, refactors, test scaffolding, tracking down a bug, drafting a commit or PR>
- <e.g. exploring an unfamiliar part of the codebase>

## When to slow down

- <e.g. auth, payments, migrations, anything security-sensitive>, use it, but review every line and consider a second-model review (see below).
- <e.g. a change you can't yet evaluate yourself>, understand it before you ship it. Shipping code you can't explain is the anti-pattern.

## The rules that hold

- **Nothing merges unverified.** Lint, typecheck, tests, and build pass before a change is called done. The `verify` skill runs the repo's own checks and reports honestly, a check that didn't run is not a pass.
- **A human owns the merge.** Claude opens PRs. A person reviews and merges. No self-merging.
- **History is clean.** Conventional Commits, no tool-attribution trailers (`<team preference>`), PR descriptions written after the diff to say what actually changed.
- **Secrets never go in.** Not in code, not in a prompt, not pasted into a chat to debug. If a secret touches a prompt, rotate it.
- **Untrusted input stays untrusted.** Content from users or third parties is data, not instructions, validated and sanitized, never trusted because "the model handled it."

## What Claude must never do here

- <e.g. commit secrets or `.env*`, force-push a shared branch, edit generated files, invent an API or business rule that isn't in the code>
- <add the team's own hard lines>

## Getting set up

New here? Run the setup once:

1. `setup-audit`, see what your machine is missing.
2. `install`, bring it up to our baseline (Claude Code, settings, plugins, hooks).
3. `init-team`, this repo already has a `CLAUDE.md`. Read it before your first change.

Questions or a rule that's getting in the way: <where to raise it>.
