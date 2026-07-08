# Settings baseline, notes

`settings.baseline.json` is a starting point for a client's `~/.claude/settings.json` (global) or a repo's `.claude/settings.json` (project). It ships **conservative on purpose**: a professional baseline should start cautious and be loosened deliberately, never the other way round. Tune it, don't inherit someone else's power-user config.

The template deliberately leaves out anything machine- or platform-specific, the status line path and the notify hook are written by the `install` skill once it knows the client's home directory and OS. That keeps this JSON valid on every platform.

## What's in it, and why

- **`attribution.commit` / `attribution.pr` = `""`**. No tool-credit trailers in git history. A clean, professional default. Flip to a value if a team wants attribution.
- **`permissions.defaultMode` = `"default"`**. Claude asks before most actions. This is the cautious end of the dial (see below). It trades a few prompts for the client seeing what the tool wants to do while they build trust.
- **`permissions.deny`**. One high-value catch (`rm -rf`). Destructive **git** commands are covered separately and more robustly by the git-guardrails hook the kit installs, so this list stays short rather than duplicating it as security theater. Extend it with anything a team never wants run.
- **`enabledPlugins`**. The kit's own plugins on. Adjust the marketplace suffix (`@mickeberg`) to match wherever the kit is published for this client.

## The permissions dial

`defaultMode` sets how much Claude asks:

- `"default"`, asks before most edits and commands. **Shipped default.** Safest, most prompts.
- `"acceptEdits"`, file edits flow without asking, commands still gated. A good move once a team trusts the file-editing but wants command execution reviewed.
- `"auto"`, broad autonomy. For an experienced solo dev who wants low friction. Pair it with a solid `deny` list and the git-guardrails hook.
- `"plan"`, Claude plans but does not act until approved. Useful for high-stakes repos.

Move along this dial deliberately, per machine or per repo, as trust grows.

## Cutting prompt fatigue without going permissive

Rather than jumping to `"auto"`, keep `"default"` and add an `allow` list for the safe, read-only things a team runs constantly, so those stop prompting while everything else still asks. For example:

```json
"permissions": {
  "defaultMode": "default",
  "allow": [
    "Bash(git status:*)",
    "Bash(git diff:*)",
    "Bash(git log:*)"
  ],
  "deny": [
    "Bash(rm -rf:*)"
  ]
}
```

Add the client's own common safe commands. This is usually a better path than loosening `defaultMode` wholesale.

## Project vs global

- **Global** (`~/.claude/settings.json`), applies everywhere for this user. The install baseline lands here.
- **Project** (`.claude/settings.json`, committed), team-shared rules for one repo. `init-team` writes a small project settings file with the repo's permission posture. Project settings layer on top of global.
