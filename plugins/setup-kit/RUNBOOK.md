# RUNBOOK, delivering a setup engagement

The step-by-step for taking a client from "we installed Claude Code and aren't sure we're using it well" to a professional, verified setup. This is the **procedure**. The talk track (how to explain each piece, the demo scripts, and the troubleshooting cheat sheet) lives in the operator's manual, which is a separate deliverable. This runbook says *what to do and in what order*. The manual says *what to say*.

## The kit at a glance

Four skills in this plugin, plus three companion plugins in the same marketplace:

| Skill / plugin | Job | When in the flow |
|---|---|---|
| `setup-audit` (this plugin) | Read-only inventory + gap report vs the target state | First (the "before"), and last (the verify) |
| `install` (this plugin) | Idempotent installer, verified by re-running the audit | After the audit |
| `init-team` (this plugin) | Interview → repo `CLAUDE.md` + `.claude/settings.json` | Per repo, after the machine is set up |
| `team-baseline` (this plugin) | Grade a repo against a professional baseline | Per repo, as the "where you stand" report |
| `git-tools` | Conventional commits + PRs | Left running, part of the setup |
| `guardrails` | `verify` before done + optional pre-push gate | Left running, the quality gate |
| `recap` | `standup` from git history | Left running, a daily win that demos well |

Two more building blocks ship alongside and are worth wiring on request: the **git-guardrails** hook (blocks destructive git, this plugin bundles and installs it) and the **notify** hook (desktop ping when Claude needs input, installed per-platform).

## Before the engagement

- Confirm the client's platform(s): macOS, Linux, Windows. Windows means Git Bash or WSL for the bash pieces, and the status line is skipped (POSIX-only), know that going in.
- Confirm they can install software on the machine (admin rights) and can complete the Claude Code sign-in themselves. The kit never handles their credentials.
- Have the marketplace reachable: the client will register it during install.
- Agree the plugin set and the permissions posture (cautious `default`, `acceptEdits`, or broad `auto`) so `install` and `init-team` set the right mode.

## The delivery flow (team or solo machine)

1. **Audit first, the honest before.** Run `setup-audit`. It changes nothing. The report is the baseline you're starting from and the "before" evidence for the engagement write-up. Read it together.
2. **Install.** Run `install`. It walks the gaps: prerequisites, Claude Code (client signs in), companions (`gh`, `jq`, `rg`), the settings baseline (merged, never clobbering), the marketplace and plugins, the hooks, the status line. It stops for the two human steps, sign-in and any OS-level install. It is idempotent: safe to re-run.
3. **Verify by re-audit.** `install` ends by running `setup-audit` again and showing the checklist. A clean audit is the proof. If anything is still MISS, it's named with the fix. Don't declare done off install's own steps. The audit is the gate.

## Per repo

4. **Onboard the repo with `init-team`.** Run it inside the repo. It reads the stack, scripts, and conventions first, then asks only the gaps (boundaries, pain points, hard nevers, autonomy). It shows the drafted `CLAUDE.md` and `.claude/settings.json` for approval before writing. One per repo the client wants Claude to work in well.
5. **Grade with `team-baseline`.** Run it on the same repo. It produces a severity-ranked findings report and an honest coverage line (what passed, what didn't apply, what wasn't checked). This is the "where you stand" artifact and the natural upsell surface. HIGH findings are concrete follow-on work.
6. **Drop in the team guidelines** (optional). Fill `templates/team-guidelines.md` for the team and commit it, so the norms live in the repo.

## Solo variant

Same flow, shorter. `init-team` in solo mode collapses to confirm-detection, hard-nevers, and autonomy, no team ceremony. Skip the team-guidelines step unless they want it. The audit → install → verify spine is unchanged.

## Leave it demonstrably working

The client should, unattended after you leave, be able to:

- Re-run `setup-audit` and see READY.
- Run `/guardrails:verify` in a repo and watch it run their own checks.
- Run `/recap:standup` and get a real summary.
- Open their repo's `CLAUDE.md` and have it be accurate.

That set is the "it works without me in the room" bar. If any of it doesn't hold, it's a fix, not a footnote.

## After

- Write the engagement report from the two audits (before → after) and the baseline findings. What was missing, what's now in place, what the HIGH findings are.
- Record what you learned into the ledger, the friction points, the client-specific tweaks, anything that should change the kit. The kit compounds only if each engagement feeds back.

## Notes for the operator

- **Idempotency is the safety net.** If a run is interrupted, just run `install` again. It re-checks everything and only does what's missing.
- **The audit is read-only.** You can run it on a client machine any time without risk. Reach for it whenever you're unsure of state.
- **Cross-platform caveats live in the target state** (`references/target-state.md`): the status line is POSIX-only, the notify hook is per-OS, and hooks need `jq`. Check there before promising a Windows client the full set.
- **The deeper "how it works / how I explain this / what to do when it breaks on stage" material is the operator's manual, not this file.** Keep them separate: procedure here, explanation there.
