---
name: pr
description: Open a GitHub pull request with a generated title and description. Use whenever the user says "open a PR", "create a pull request", "PR this", "/pr", "put this up for review", or has pushed a branch and wants it reviewed. Builds the title and body from the branch's commits, pushes if needed, then opens the PR with gh.
---

# PR (GitHub)

Open a pull request on GitHub with a title and description built from the branch's commits, using the `gh` CLI. Cross-platform: works anywhere `git` and `gh` are installed.

## Customize (edit this block for your team)

- **Base branch**: `AUTO` — the repo's default branch (from `gh repo view`). Override with a fixed base like `develop`.
- **Ticket prefix**: `AUTO` — detect an issue key like `ABC-123` from the branch name and put it in the title. `NONE` to disable.
- **Description**: `SUMMARY` — a short what/why plus a bullet list of the notable commits. Set `LINK-ONLY` if your team prefers just an issue link, or `TEMPLATE` to fill the repo's PR template when one exists.
- **Draft**: `ASK` — open as draft or ready for review. `ON` = always draft, `OFF` = always ready.

## Workflow

1. **Preflight.** `git branch --show-current`. If it is the base branch, stop and tell the user to branch first. Check the branch is pushed (`git status -sb`); if it has no upstream, offer to `git push -u origin <branch>`.
2. **Check for an existing PR.** `gh pr view --json url,state 2>/dev/null`. If one already exists for this branch, show it instead of creating a duplicate.
3. **Gather.** `git log <base>..HEAD --no-merges --oneline` for the commits that will be in the PR, and the diffstat for scope.
4. **Draft title + body.**
   - Title: `[<ticket> ]<summary>` — concise, from the branch and commits. Same human voice as a good commit message: say what it does, avoid "enhance / leverage / comprehensive".
   - Body: per the Description setting. If the repo has `.github/PULL_REQUEST_TEMPLATE.md`, fill that.
5. **Humanizer pass (if available).** A PR body is read by reviewers, so it is public-facing. If the body has prose (a summary or bullets, not just an issue link) and the `humanizer` skill is available in this session, run the body through it via the Skill tool before showing it, so it reads naturally. If the skill is not installed, skip this step silently. Nothing to humanize in a `LINK-ONLY` body.
6. **Show it and wait for approval.** Never open the PR before the user approves the title and body.
7. **Open it** with gh:
   ```bash
   gh pr create --base <base> --head <branch> --title "<title>" --body "<body>"
   ```
   Add `--draft` per the Draft setting.
8. Report the PR URL.

## Rules

- Never open the PR without showing the title and body first.
- Do not force-push, amend, or rebase unless the user asks.
- If `gh` is not authenticated, tell the user to run `gh auth login` rather than guessing.

## Extra context from the user

$ARGUMENTS
