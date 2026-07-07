# mickeberg — Claude Code plugins

A small, personal [Claude Code](https://code.claude.com/docs) plugin marketplace. Cross-platform (macOS, Linux, Windows), no company specifics. It grows one useful, portable tool at a time.

## What is in here

**`git-tools`** — git workflow skills.

- **`commit`** — drafts a Conventional Commits message from your staged changes, shows it for approval, then commits. Auto-detects an issue key and a scope, and works in both bash and PowerShell.

**`guardrails`** — enforced quality checks.

- **`verify`** — before you call a change done, it runs your project's own checks (lint, typecheck, test, build) detected from `package.json`, loops on fixable failures, and reports **honestly**: a check that did not run is reported as "not run", never as passed.
- **Optional pre-push gate (off by default)** — a bundled hook that can block `git push` until `verify` has passed. It does nothing until you opt in per-repo. See [The optional pre-push gate](#the-optional-pre-push-gate).

**`recap`** — summaries from your git history.

- **`standup`** — turns your recent commits (across one repo or several) into a short, glanceable, spoken-style standup cheat sheet, so you don't blank when it's your turn. Git-only by default; paste ticket context if you want it woven in.

Every team-specific choice in each skill (issue-key prefix, scope naming, which check layers to run, which repos to scan) lives in a single **Customize** block at the top of the skill, so you adapt it by editing one place instead of hunting through the text.

## Install

### Option A — try it locally first (recommended before you push anywhere)

From a clone of this repo:

```text
/plugin marketplace add ./mickeberg-marketplace
/plugin install git-tools@mickeberg
/plugin install guardrails@mickeberg
/plugin install recap@mickeberg
/reload-plugins
```

`add` also accepts an absolute path to the folder or directly to `.claude-plugin/marketplace.json`.

### Option B — from GitHub

```text
/plugin marketplace add micke-berg/mickeberg-marketplace
/plugin install git-tools@mickeberg
/plugin install guardrails@mickeberg
/plugin install recap@mickeberg
/reload-plugins
```

### Use it

```text
/git-tools:commit     # stage changes first, then draft + commit
/guardrails:verify    # run the project's checks and report honestly
/recap:standup        # summarize your recent git work for standup
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

## License

MIT. See [LICENSE](LICENSE).
