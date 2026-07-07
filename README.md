# mickeberg — Claude Code plugins

A small, personal [Claude Code](https://code.claude.com/docs) plugin marketplace. Cross-platform (macOS, Linux, Windows), no company specifics. It starts with one plugin and will grow.

## What is in here

**`git-tools`** — a growing set of git workflow skills. Currently one:

- **`commit`** — drafts a Conventional Commits message from your staged changes, shows it for approval, then commits. Auto-detects an issue key and a scope, and works in both bash and PowerShell.

Every team-specific choice in the `commit` skill (issue-key prefix, scope naming, whether to add attribution trailers) lives in a single **Customize** block at the top of the skill, so you adapt it by editing one place instead of hunting through the text.

## Install

### Option A — try it locally first (recommended before you push anywhere)

From a clone of this repo:

```text
/plugin marketplace add ./mickeberg-marketplace
/plugin install git-tools@mickeberg
/reload-plugins
```

`add` also accepts an absolute path to the folder or directly to `.claude-plugin/marketplace.json`.

### Option B — from GitHub

```text
/plugin marketplace add micke-berg/mickeberg-marketplace
/plugin install git-tools@mickeberg
/reload-plugins
```

### Use it

Stage some changes, then:

```text
/git-tools:commit
```

The skill also triggers when you say things like "commit this" or "looks good, commit it".

## Manage

```text
/plugin list                          # what is installed
/plugin marketplace update mickeberg  # pull the latest
/plugin disable git-tools@mickeberg   # turn off without uninstalling
/plugin marketplace remove mickeberg  # remove the marketplace
```

## For maintainers

- **Validate before pushing:** run `claude plugin validate .` from the repo root. It checks the marketplace and plugin manifests and catches path or naming mistakes.
- **Versioning:** each plugin's version is set in its own `plugins/<name>/.claude-plugin/plugin.json`. Bump it on every release, or remove the `version` field to have Claude Code track the git commit instead. Do not set the version in both `plugin.json` and the marketplace entry.
- **Add a plugin:** create `plugins/<name>/.claude-plugin/plugin.json` plus a `skills/` folder, then add an entry to `.claude-plugin/marketplace.json` pointing at `./plugins/<name>`.

## License

MIT. See [LICENSE](LICENSE).
