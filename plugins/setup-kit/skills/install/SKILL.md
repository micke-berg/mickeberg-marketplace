---
name: install
description: Guided, idempotent installer that takes a machine from bare to a professional Claude Code setup (prerequisites, the CLI, a settings baseline, the kit's plugins, hooks, and status line), checking each step and verifying at the end by re-running the setup audit. Safe to run twice. Use when the user says "install the kit", "set up Claude Code", "install setup-kit", "set up this machine", or right after a setup audit shows gaps.
---

# Install

Bring a machine up to the kit's target state, one verified step at a time, and prove it at the end. The install is **idempotent**: every step checks before it acts, so running it a second time changes nothing and simply confirms the machine is ready. The last step re-runs `setup-audit`, the same audit you would run first, so the proof that install worked is a clean audit, not this skill's own say-so.

This skill guides and executes, but it stops for the human at exactly the two points that must be human: authentication, and any change to the operating system (installing a system package, granting a permission). It never handles credentials.

## Customize (edit this block for the engagement)

- **Target state**: `AUTO`, read `references/target-state.md` in this plugin (`${CLAUDE_PLUGIN_ROOT}/references/target-state.md`). Same file `setup-audit` uses.
- **Steps**: `ALL`, run every step below. Narrow to a list (e.g. `config,plugins,hooks`) to install only part.
- **Plugins**: `AUTO`, the recommended set from the target state (git-tools, guardrails, recap, setup-kit). Override with an explicit list.
- **Hooks**: `ASK`, offer git-guardrails and notify, install on yes. Set `ON` to install without asking, `OFF` to skip hooks.
- **Settings mode**: `MERGE`, on a machine that already has `~/.claude/settings.json`, merge the baseline in without clobbering existing keys. `WRITE` only on a confirmed-fresh machine.
- **Platform**: `AUTO`, detect macOS / Linux / Windows and use the matching commands and notify snippet.

## Workflow

Run `setup-audit` first (or read its recent report) so you act only on real gaps. Then, for each step: **check → act only if needed → re-check.** Announce each step and its result.

1. **Prerequisites (A).** Check `git`, `node` (active LTS), a package manager, `bash`. If any REQUIRED one is missing, **stop and hand the client the official installer for their platform**. Do not silently install a foundational tool. These are theirs to own.
2. **Claude Code (B).** If `claude` is absent, install per the current docs (`npm install -g @anthropic-ai/claude-code` or the platform installer). Then **pause for authentication**: ask the client to run `claude`, sign in, and confirm. Do not proceed until they confirm. Never touch credentials.
3. **Companions (C).** Offer `gh`, `jq`, `ripgrep` using the client's package manager (Homebrew / winget / apt / choco). Install `jq` if hooks are wanted (step 6 needs it). Ask before each system install unless Hooks/Settings mode says otherwise.
4. **Global config (D).** Ensure `~/.claude/settings.json` exists and carries the baseline from `templates/settings/settings.baseline.json`:
   - Fresh machine (`WRITE`): copy the baseline.
   - Existing machine (`MERGE`): read the current file, add only missing baseline keys (`permissions.defaultMode`, `attribution`, `statusLine`, `hooks.Notification`, `enabledPlugins` entries), and **preserve everything already there**. Never drop the client's existing keys, and never write secrets or personal paths.
5. **Marketplace and plugins (E).** Register the kit marketplace if absent (`/plugin marketplace add <kit repo>`), then update the cache so it is current (`/plugin marketplace update <name>`), then enable each plugin in the set, both the `enabledPlugins: true` entry and, where run interactively, `/plugin install <name>@<marketplace>`. A reload or restart applies it.
6. **Hooks (F), per the Hooks setting.**
   - **git-guardrails**: copy `assets/hooks/git-guardrails.sh` from this plugin to `~/.claude/hooks/git-guardrails.sh`, make it executable, and merge the `PreToolUse` entry into settings (matcher `Bash|PowerShell`). It needs `jq` to arm (step 3). It fails open, so a machine without `jq` is safe but unprotected. Say so.
   - **notify**: write the `Notification` hook using the snippet matching the detected OS (macOS `osascript`, Linux `notify-send`, Windows PowerShell). One line, no personal content.
7. **Status line (G).** On macOS/Linux, copy `assets/statusline/statusline-command.sh` to `~/.claude/statusline-command.sh` and point `settings.json` `statusLine` at it (needs `jq` and `bc`). On Windows, skip it and note the gap. The script is POSIX/zsh.
8. **Verify.** Run `setup-audit` again and show its report as the closing checklist. Anything still MISS is called out with the reason and the one command to close it.

## The closing checklist

End with the audit's own grade and table, framed as done-vs-not:

```text
Install complete, verification via setup-audit
Grade: READY

  [x] git, node, npm, bash        present
  [x] claude                      installed, you confirmed sign-in
  [x] jq                          installed (git-guardrails armed)
  [x] settings baseline           merged (existing keys preserved)
  [x] mickeberg marketplace       registered + updated
  [x] git-tools, guardrails,      enabled
      recap, setup-kit
  [x] git-guardrails hook         wired (PreToolUse)
  [x] notify hook                 macOS osascript
  [x] status line                 configured
  [ ] ripgrep                     skipped (optional, you declined)

Reload plugins or restart Claude Code to apply. You're ready.
```

Only tick a box the audit actually confirmed. A step the client declined is an empty box with "(declined)", not a tick and not a failure.

## Rules

- **Idempotent.** Check before every action. Re-running install must be a no-op that ends in a clean audit, never a duplicate hook or a clobbered setting.
- **Merge, do not overwrite.** On a machine with existing config, add what is missing and keep what is there. Losing a client's settings is the worst outcome this skill can produce.
- **Stop for the two human steps.** Authentication and OS-level installs pause for the client. Never enter credentials, never `sudo` silently.
- **Never write secrets or personal data** into any shipped file. The baseline is generic. The client's accounts stay the client's.
- **The verification is setup-audit, not this skill.** Do not declare success from install's own steps. Run the audit and let its honest grade be the proof.

## Extra context from the user

$ARGUMENTS
