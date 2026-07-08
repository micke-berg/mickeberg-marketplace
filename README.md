# mickeberg, Claude Code plugins

A small, personal [Claude Code](https://code.claude.com/docs) plugin marketplace. Cross-platform (macOS, Linux, Windows), no company specifics. It grows one useful, portable tool at a time.

## What is in here

**`git-tools`**. Git workflow skills.

- **`commit`**. Drafts a Conventional Commits message from your staged changes, shows it for approval, then commits. Auto-detects an issue key and a scope, and works in both bash and PowerShell.

**`guardrails`**. Enforced quality checks.

- **`verify`**. Before you call a change done, it runs your project's own checks (lint, typecheck, test, build) detected from `package.json`, loops on fixable failures, and reports **honestly**: a check that did not run is reported as "not run", never as passed.
- **Optional pre-push gate (off by default)**. A bundled hook that can block `git push` until `verify` has passed. It does nothing until you opt in per-repo. See [The optional pre-push gate](#the-optional-pre-push-gate).

**`recap`**. Summaries from your git history.

- **`standup`**. Turns your recent commits (across one repo or several) into a short, glanceable, spoken-style standup cheat sheet, so you don't blank when it's your turn. Git-only by default. Paste ticket context if you want it woven in.

**`setup-kit`**. The delivery toolkit for a professional Claude Code setup.

- **`setup-audit`**. Read-only inventory of a machine's setup, graded against a target state. Runs first as the honest "before", and again as the verification after `install`.
- **`install`**. A guided, **idempotent** installer: prerequisites, the CLI, a merged settings baseline, the kit's plugins, hooks, and status line. Safe to run twice. Its final step re-runs `setup-audit`, so the proof it worked is a clean audit, not its own say-so.
- **`init-team`**. Reads a repo (stack, scripts, conventions) then interviews only the gaps, and writes a tailored `CLAUDE.md` plus a `.claude/settings.json` permissions baseline. Shows both for approval before writing.
- **`team-baseline`**. Grades a repo against a professional baseline (hygiene, security, config, data layer, architecture, docs, tests) and reports findings by severity with an **honest** coverage line: what passed, what didn't apply, and what couldn't be checked.
- Ships `CLAUDE.md` templates (Next.js/TS, .NET, generic), a settings baseline, a team-guidelines skeleton, and a delivery `RUNBOOK.md`.

**`humanizer`**. Cleans AI tells out of writing.

- **`humanizer`**. Reviews or edits text and removes signs of AI-generated writing: em dash overuse, rule of three, inflated symbolism, vague attributions, AI vocabulary, and more. Based on Wikipedia's "Signs of AI writing" guide. Packaged from [blader/humanizer](https://github.com/blader/humanizer).

Every team-specific choice in each skill (issue-key prefix, scope naming, which check layers to run, which repos to scan) lives in a single **Customize** block at the top of the skill, so you adapt it by editing one place instead of hunting through the text.

## Install

### Option A, try it locally first (recommended before you push anywhere)

From a clone of this repo:

```text
/plugin marketplace add ./mickeberg-marketplace
/plugin install git-tools@mickeberg
/plugin install guardrails@mickeberg
/plugin install recap@mickeberg
/plugin install setup-kit@mickeberg
/plugin install humanizer@mickeberg
/reload-plugins
```

`add` also accepts an absolute path to the folder or directly to `.claude-plugin/marketplace.json`.

### Option B, from GitHub

```text
/plugin marketplace add micke-berg/mickeberg-marketplace
/plugin install git-tools@mickeberg
/plugin install guardrails@mickeberg
/plugin install recap@mickeberg
/plugin install setup-kit@mickeberg
/plugin install humanizer@mickeberg
/reload-plugins
```

### Use it

```text
/git-tools:commit       # stage changes first, then draft + commit
/guardrails:verify      # run the project's checks and report honestly
/recap:standup          # summarize your recent git work for standup
/setup-kit:setup-audit  # inventory this machine's setup and report gaps
/setup-kit:install      # bring a machine up to the setup baseline (idempotent)
/setup-kit:init-team    # interview a repo into a CLAUDE.md + settings baseline
/setup-kit:team-baseline # grade a repo against a professional baseline
/humanizer:humanizer    # strip AI tells out of a piece of text
```

The skills also trigger from natural phrasing like "commit this", "verify before I push", or "what did I do yesterday".

## The optional pre-push gate

`guardrails` ships a hook that can refuse a `git push` until `verify` has passed. It is **off by default** and only ever acts in a repo that opted in.

- **Turn it on for a repo:** create an empty file `.guardrails/gate-on` in that repo.
- **How it behaves once on:** a `git push` is blocked unless `/guardrails:verify` wrote a fresh (`pass: true`, under 60 minutes) `.guardrails/verify-pass.json`.
- **Turn it off:** delete `.guardrails/gate-on`.
- **Ignore the local state:** add `.guardrails/verify-pass.json` to your `.gitignore` (it is ephemeral). Keep or commit `.guardrails/gate-on` depending on whether you want the gate to be personal or shared with your team.

Requirements: `bash` (native on macOS/Linux, Git Bash on Windows) and `node`, both of which any JS/TS dev machine already has.

## Manage

```text
/plugin list                          # what is installed
/plugin marketplace update mickeberg  # pull the latest
/plugin disable guardrails@mickeberg  # turn off without uninstalling
/plugin marketplace remove mickeberg  # remove the marketplace
```

## For maintainers

- **Validate before pushing:** run `claude plugin validate .` from the repo root. It checks the marketplace and plugin manifests and catches path or naming mistakes.
- **Versioning:** each plugin's version is set in its own `plugins/<name>/.claude-plugin/plugin.json`. Bump it on every release, or remove the `version` field to have Claude Code track the git commit instead. Do not set the version in both `plugin.json` and the marketplace entry.
- **Add a plugin:** create `plugins/<name>/.claude-plugin/plugin.json` plus a `skills/` folder (and `hooks/hooks.json` if it bundles hooks), then add an entry to `.claude-plugin/marketplace.json` pointing at `./plugins/<name>`.
- **Writing style (applies to every skill and doc):** no em dashes, no semicolons, no colon used as a mid-sentence pause (a colon introducing a list is fine). Plain, direct sentences, no corporate filler. Everything ships under my name, so it reads like I wrote it. Code and code comments are exempt.

### Vendored plugins

Most plugins here are mine. `humanizer` is not, it is a copied snapshot of [blader/humanizer](https://github.com/blader/humanizer), packaged so it installs the same way as everything else. A few consequences worth knowing:

- **It is pinned, not tracked.** The copy in `plugins/humanizer/skills/humanizer/` reflects upstream commit `c78047b` (2026-01-22). Upstream changes do not reach here until someone re-copies.
- **Refresh it like this** when upstream has something worth pulling in:
  ```text
  git -C /path/to/humanizer pull                       # or clone it fresh
  cp SKILL.md README.md  plugins/humanizer/skills/humanizer/
  # bump version in plugins/humanizer/.claude-plugin/plugin.json
  # update the pinned commit above, then validate + commit
  ```
- **Credit stays with the author.** The upstream repo is linked in the plugin's `homepage` field and here. I do not claim it as mine, and it is not covered by this repo's MIT license. Check the upstream license before doing anything beyond personal use.

## License

MIT covers the marketplace scaffolding and my own plugins (`git-tools`, `guardrails`, `recap`, `setup-kit`). See [LICENSE](LICENSE). Vendored plugins keep their upstream authorship and license, see [Vendored plugins](#vendored-plugins).
