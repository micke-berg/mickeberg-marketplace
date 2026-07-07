---
name: standup
description: Prepare a quick standup summary from your recent git activity, so you don't blank when it's your turn. Use whenever the user says "standup", "what did I do yesterday", "what have I been working on", "prepare for standup", "daily standup", "/standup", or "what did I do this week". It's a glanceable cheat sheet, not a script to read aloud.
---

# Standup

Pull together what you have been working on from git, so you have a glanceable cheat sheet before your standup. Not a script to read out loud, just enough to jog your memory so you do not blank when it is your turn.

## Customize (edit this block for your setup)

- **Repos**: `AUTO` — summarize the current git repo. To cover several, list their paths here, or set one parent folder and the skill scans it for git repos.
- **Since**: `AUTO` — since yesterday. If today is Monday, or nothing shows up for yesterday, look back over the last few working days (up to ~4). Override with a window like `3 days` or `1 week`.
- **Author**: `AUTO` — filter to your own commits, using `git config user.name` and `user.email`. Set explicitly if your commits use a different identity.
- **Issue tracker**: `OFF` — git-only by default. If you track work in Jira / Linear / GitHub Issues, paste the relevant context via arguments and the skill weaves it in. Not all work shows up in git.

## Gathering

1. **Find your identity.** `git config user.name` and `git config user.email`.
2. **Pick the window.** Default: since yesterday. If it is Monday or yesterday is empty, widen to the last few working days.
3. **Read git activity** for each repo (the current one, or the configured list). Across branches, your commits only, no merges:
   ```bash
   git log --all --author="<you>" --since="<window>" --oneline --no-merges
   ```
   For repos with hits, get scope with `--stat` (which areas were touched, so you can describe the work in team terms):
   ```bash
   git log --all --author="<you>" --since="<window>" --no-merges --stat
   ```
   If you use worktrees, `git worktree list` can reveal separate work.
4. **Weave in what git misses.** Anything passed as arguments — today's plans, blockers, reviews, meetings, research, non-code work — matters as much as the commits.

## Writing it

Write in first person so you can read straight from it.

- **Short.** A standup is one to two minutes. Scannable in ten seconds: 3 to 5 sentences total, not a paragraph per feature.
- **Group by feature or area, not by source.** Code and a ticket for the same thing are one bullet, not two.
- **Team terms, not file paths.** "Worked on the refund form", not "changed 12 files in libs/...". The team cares about progress, not paths.
- **Include non-code work naturally.** Prep, reviews, investigations, and meetings are bullets like any other.
- **Talk, do not template.** No "Yesterday / Today / Blockers" headers. Write it the way you would say it. If there are no blockers, drop it or say "no blockers" casually at the end.

Rough shape (adapt to what there actually is to say):

```text
Yesterday I worked on [thing] and [thing]. [One line of detail if it helps.]
Today I'm planning to [thing].
No blockers.
```

If it spans several days, open with "Last few days I've been ..." instead.

## Arguments

$ARGUMENTS
