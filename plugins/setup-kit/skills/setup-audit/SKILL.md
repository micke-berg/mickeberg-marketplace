---
name: setup-audit
description: Inventory a machine's Claude Code setup and report gaps against the kit's target state, without changing anything. Runs first on any client machine as the "before" evidence, and again after install as the verification pass. Use when the user says "setup audit", "audit this machine", "what's my Claude Code setup", "am I set up", "check my setup", or before and after running the install skill.
---

# Setup audit

Take stock of a machine's Claude Code setup and say plainly what is there, what is missing, and what is out of date, measured against the kit's target state. **This skill reads only. It never installs, writes, or changes anything**. That is the `install` skill's job. Running it is always safe, which is why it goes first on a client machine (the honest "before" picture) and again at the end of an install (the verification).

## Customize (edit this block for the engagement)

- **Target state**: `AUTO`, read the kit's target from `references/target-state.md` in this plugin (`${CLAUDE_PLUGIN_ROOT}/references/target-state.md`). Point elsewhere to audit against a client-specific target.
- **Scope**: `FULL`, check every section (A prerequisites through G status line). Set to `PREREQS` for a fast go/no-go, or list sections like `A,B,E` to narrow it.
- **Plugins baseline**: `AUTO`, take the recommended plugin list from the target state. Override with an explicit list if the client agreed a different set.
- **Platform**: `AUTO`, detect macOS / Linux / Windows and use the matching checks. Override only if auditing a machine you are not on.

## Workflow

1. **Detect the platform.** `uname -s` on POSIX. On Windows you are in PowerShell or Git Bash. This decides which check column from the target state to use, and which notify snippet counts as correct.
2. **Load the target state.** Read the target-state file. It is the source of truth for what to check and at what level (REQUIRED / RECOMMENDED / OPTIONAL). Do not hard-code a checklist here. If the target changes, this skill follows it.
3. **Check each item, read-only.** Walk the sections in scope:
   - **Tools** (A, C): `command -v <tool>` then its `--version`. Record the version string, not just presence. An ancient Node is a finding.
   - **Claude Code** (B): `claude --version`. Authentication cannot be read directly and must not be forced. Report it as "assumed authenticated if the CLI runs" and leave a line for the client to confirm.
   - **Global config** (D): read `~/.claude/settings.json` if it exists. Report which baseline keys are set (`permissions.defaultMode`, `attribution`, `statusLine`, `hooks.Notification`, `enabledPlugins`). **Do not print secrets, tokens, or personal paths**. Report presence and shape only.
   - **Marketplace and plugins** (E): read `enabledPlugins` and `extraKnownMarketplaces` from settings, and the plugin cache under `~/.claude/plugins/marketplaces/`. Note the cache can lag the source repo. If the kit marketplace is registered but a plugin is missing from the cache, that is a "needs update", not "missing". Where the CLI is available, `claude plugin list` gives the authoritative installed and enabled state and `claude plugin details <name>@<marketplace>` lists a plugin's skills, so a report can confirm the kit's own skills are actually loaded rather than only present in the cache.
   - **Hooks** (F): read the `hooks` block in settings. Is git-guardrails wired on `PreToolUse`? Is a notify hook present and correct for this platform?
   - **Status line** (G): is `statusLine` set and does its script exist?
4. **Grade** to READY / USABLE / BLOCKED per the target state's rules.
5. **Report** (format below). If run right after `install`, note that this is the verification pass and call out anything install left undone.

## The report

A per-section table the client can read at a glance, most important first. For example:

```text
Setup audit, MacBook Pro (macOS 14), 2026-07-08
Grade: USABLE, all required present, 2 recommended missing

A. Prerequisites
   git         PASS   2.44.0
   node        PASS   v20.11.1 (active LTS)
   npm         PASS   10.2.4
   bash        PASS   3.2.57
B. Claude Code
   claude      PASS   1.x installed, confirm you are signed in
C. Companions
   gh          PASS   2.62.0
   jq          MISS   needed to arm the git-guardrails hook -> brew install jq
   rg          n/a    optional, not installed
D. Global config (~/.claude/settings.json)
   present     PASS   permissions.defaultMode set, attribution off
   statusLine  MISS   not configured (see G)
E. Marketplace + plugins
   mickeberg   PASS   registered, git-tools enabled
   guardrails  MISS   not enabled
   recap       MISS   not enabled
F. Hooks
   guardrails  n/a    depends on jq (C)
   notify      PASS   macOS osascript notify present
G. Status line
   statusline  MISS   not configured

Next: install jq, enable guardrails+recap, add the status line.
Run the install skill to close these, or fix by hand from the notes above.
```

- Every item is PASS, MISS, n/a (optional/not-applicable), or UNKNOWN (could not be checked). Never an optimistic PASS.
- A MISS on a RECOMMENDED item lowers the grade to USABLE, not BLOCKED. A MISS on a REQUIRED item is BLOCKED and goes first.
- Print the one command that fixes each gap, taken from the target state, in the client's platform.

## Rules

- **Read-only, always.** If you catch yourself about to write a file, install a tool, or edit settings, stop. That is `install`, not `setup-audit`.
- **Never print secrets or personal data.** Report that `settings.json` exists and which baseline keys are set, not its contents. Never echo tokens, `additionalDirectories`, or account identifiers.
- **Do not force authentication.** Report auth as unconfirmed and let the client confirm. Never trigger a login flow to "test" it.
- **Unknown is not pass.** If a check cannot run (permission, platform quirk), say UNKNOWN and why.

## Extra context from the user

$ARGUMENTS
