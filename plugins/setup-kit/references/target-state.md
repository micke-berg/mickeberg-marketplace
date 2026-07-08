# Target state

The machine state the kit installs and audits against. `setup-audit` reads this file and reports what is present, missing, or out of date. `install` reads the same file and brings the machine up to it, one step at a time. Because they share this one definition, `install`'s final verification is simply `setup-audit` run again: a clean audit is proof the install worked.

Nothing here is specific to one person, company, or project. Every account and every repo is the client's own. The kit only decides *what good looks like*, never *whose*.

## How to read the tables

Each row is one item with a level:

- **REQUIRED**. The kit does not function without it. A missing REQUIRED item fails the audit.
- **RECOMMENDED**. Strongly wanted, and the default install sets it up. A client can decline per item.
- **OPTIONAL**. Offered, not assumed. Skipped unless the client asks.

`Check` and `Install` give a POSIX command (macOS, Linux, Git Bash / WSL on Windows) and, where it differs, a PowerShell equivalent. Detect the platform once and use the matching column. Prefer the client's existing package manager (Homebrew, apt, winget, choco, scoop) over curl-to-shell where one exists.

---

## A. Prerequisites

| Item | Level | Why | Check (POSIX) | Check (PowerShell) |
|---|---|---|---|---|
| `git` | REQUIRED | Every skill in the kit reads or writes git state. | `command -v git` | `Get-Command git` |
| Node.js (active LTS) | REQUIRED | Claude Code runs on Node, and the guardrails gate and status line call `node`. Accept the current or previous LTS major. | `node --version` | `node --version` |
| A Node package manager | REQUIRED | `npm` ships with Node and is enough. `pnpm` / `yarn` are fine if the client already uses them. | `command -v npm` | `Get-Command npm` |
| A POSIX shell | REQUIRED | Hooks and the status line are bash. Native on macOS/Linux. On Windows this is Git Bash (bundled with Git for Windows) or WSL. | `command -v bash` | `Get-Command bash` |

If a REQUIRED prerequisite is missing, `install` stops and points the client at the official installer for their platform rather than guessing a package manager. These are the client's foundational tools, not something the kit should force.

## B. Claude Code

| Item | Level | Why | Check |
|---|---|---|---|
| Claude Code CLI installed | REQUIRED | It is the thing being set up. | `command -v claude` and `claude --version` |
| Authenticated | REQUIRED | Nothing runs unauthenticated. | `claude` starts without prompting for login (auth is interactive, see note) |

Install (per the current docs at https://code.claude.com/docs): `npm install -g @anthropic-ai/claude-code`, or the platform installer the docs recommend. **Authentication is interactive and only the client can complete it**. `install` guides them to run `claude`, sign in, and confirm, then continues. The kit never handles credentials.

## C. CLI companions

| Item | Level | Why | Check | Install (examples) |
|---|---|---|---|---|
| `gh` (GitHub CLI) | RECOMMENDED | The `pr` skill (git-tools) opens PRs with it. Skip if the client is not on GitHub. | `command -v gh` | `brew install gh` / `winget install GitHub.cli` / `apt install gh` |
| `jq` | RECOMMENDED | The git-guardrails hook and the status line parse JSON with it. Without `jq` the hook fails open (does nothing), so it is required *if* hooks are wanted. | `command -v jq` | `brew install jq` / `winget install jqlang.jq` / `apt install jq` |
| `ripgrep` (`rg`) | OPTIONAL | Fast search. Claude Code uses it when present. | `command -v rg` | `brew install ripgrep` / `winget install BurntSushi.ripgrep.MSVC` |

## D. Global Claude config (`~/.claude/settings.json`)

Present, valid JSON, carrying a professional baseline. The kit ships this as a template (`templates/settings/settings.baseline.json`). `install` writes it on a fresh machine and **merges** rather than overwrites on a machine that already has one.

| Key | Level | Target | Why |
|---|---|---|---|
| `permissions.defaultMode` | RECOMMENDED | a deliberate value, not absent | The client chooses their comfort level. The kit makes it explicit instead of implicit. |
| `attribution.commit` / `attribution.pr` | RECOMMENDED | `""` (off) | No tool-credit trailers in git history unless the client wants them. |
| `statusLine` | RECOMMENDED | points at the kit status line | At-a-glance context (branch, model, dir). See G. |
| `hooks.Notification` | RECOMMENDED | platform-correct notify | A long run should not sit silently waiting. See F. |
| `enabledPlugins` | RECOMMENDED | the kit plugins on | See E. |

Never write secrets, tokens, or personal paths into a shipped settings file. `additionalDirectories`, project history, and account tokens are the client's and stay on the client's machine only.

## E. Marketplace and plugins

| Item | Level | Target |
|---|---|---|
| Kit marketplace registered | REQUIRED | the kit's marketplace in `extraKnownMarketplaces` (or added via `/plugin marketplace add`) |
| `git-tools` | RECOMMENDED | enabled, conventional commits + PRs |
| `guardrails` | RECOMMENDED | enabled, verify-before-done, optional pre-push gate |
| `recap` | RECOMMENDED | enabled, standup from git history |
| `setup-kit` | RECOMMENDED | enabled, this kit's own skills, so `setup-audit` stays available on the client machine |
| Official plugins (playwright, etc.) | OPTIONAL | only what the client's stack needs |

Enabling a plugin is two parts: the marketplace must be present in the plugin cache (add or update it) **and** the plugin set to `true` in `enabledPlugins`. A reload (or restart) applies the change.

## F. Hooks

| Hook | Level | What | Cross-platform note |
|---|---|---|---|
| git-guardrails (`PreToolUse` on Bash) | RECOMMENDED | Blocks the git commands that destroy work (force-push to a protected branch, `reset --hard`, `clean -fd`, branch force-delete, `checkout .`, history rewrites). | bash + `jq`. Fails open without `jq`, so install `jq` (C) to arm it. |
| notify (`Notification`) | RECOMMENDED | Desktop ping when Claude needs input. | Platform-specific command. Pick the matching snippet below. |

**notify snippets** (`install` writes the one matching the detected OS):

- macOS: `osascript -e 'display notification "Claude needs your attention" with title "Claude Code" sound name "Glass"'`
- Linux: `notify-send "Claude Code" "Claude needs your attention"` (needs `libnotify` / `notify-send`)
- Windows (PowerShell): `powershell -NoProfile -Command "[void][System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms'); [System.Windows.Forms.MessageBox]::Show('Claude needs your attention','Claude Code')"`, or a BurntToast toast if the client has that module.

## G. Status line

| Item | Level | What |
|---|---|---|
| Status line configured | RECOMMENDED | `settings.json` `statusLine` runs the kit's `statusline-command.sh`, showing branch, model, and directory at a glance. bash + `jq`. |

---

## The audit grade

`setup-audit` summarizes to one line the client understands:

- **READY**. Every REQUIRED item present, RECOMMENDED items either present or explicitly declined.
- **USABLE**. All REQUIRED present, some RECOMMENDED still missing (listed).
- **BLOCKED**. A REQUIRED item is missing (listed first, with the one command to fix it).

The grade is honest above all. An item that could not be checked is reported as "unknown", never assumed present. This mirrors the guardrails rule: a check that did not run is not a pass.
