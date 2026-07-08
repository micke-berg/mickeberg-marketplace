---
name: team-baseline
description: Grade a repo against a professional baseline (repo hygiene, security, config, data layer, architecture, docs, tests) and produce a findings report ranked by severity, with an honest list of what was checked, what didn't apply, and what couldn't be verified. Use when the user says "team baseline", "baseline this repo", "audit this repo", "is this production ready", "grade this codebase", or before shipping or handing off a project.
---

# Team baseline

Measure a repo against a professional minimum and report where it falls short, ranked by how much it matters. The bar is "should never have shipped without this," not perfection. The report is only worth trusting if it is honest about its own coverage, so this skill names what it checked, what did not apply, and what it could not verify. A skipped category is never quietly counted as a pass.

## Customize (edit this block for the engagement)

- **Baseline**: `AUTO`, read the checklist from `references/baseline.md` in this plugin (`${CLAUDE_PLUGIN_ROOT}/skills/team-baseline/references/baseline.md`). Point elsewhere for a client's own bar.
- **Scope**: `ALL`, grade every applicable category. Narrow to a list (e.g. `1,3,5,11` for a fast security-and-hygiene pass).
- **Project type**: `AUTO`, detect web app / API / library / CLI / mobile and set category applicability from it. Override if detection is wrong.
- **Depth**: `STANDARD`, read config, key source files, and representative routes/handlers. `DEEP` reads more broadly (worth it before a release or handoff).
- **Fix**: `OFF`, report only. Set `ASK` to offer fixes for the safe, mechanical findings after the report. Never auto-fix security findings without review.

## Workflow

1. **Classify the project.** From the repo's manifest and structure, decide what kind of project it is. That sets which baseline categories apply and which are N/A (SEO for a CLI, HTTP headers for a library). State the classification up front.
2. **Load the baseline.** Read `references/baseline.md`. It is the source of truth for categories, principles, per-stack checks, and severities. Don't hard-code the list here, follow the file.
3. **Detect the stack** so you apply the right per-stack check (the baseline gives JS/TS, .NET, and Python forms for several items). Confirm the package manager, framework, and test runner.
4. **Check each applicable category** at the chosen depth. Read real files, `.gitignore`, config, env handling, a couple of API routes/handlers, the data-access layer, CI config, the docs. For each failing check, record a finding: category, severity, the concrete problem **with the file/location**, and the one fix. Ground every finding in something you actually read. Never assert a finding you did not see.
5. **Grade** to PASS / AT RISK / NOT BASELINE per the baseline's rules (any HIGH → NOT BASELINE).
6. **Report** (format below).
7. **Fixes**, only per the Fix setting, and only the safe mechanical ones (add a `.gitignore` entry, add an env example, add a missing script). Security findings are reported for a human, not silently patched.

## The report

Findings first, most severe first, then the honest coverage line. For example:

```text
team-baseline, acme-api  (Node/Express API)
Grade: NOT BASELINE, 2 HIGH, 3 MEDIUM

HIGH
  [1 Repo hygiene]   .env committed at commit a1b2c3, contains DB creds.
                     Rotate the creds, add .env to .gitignore, scrub history.
  [11 Input valid.]  POST /orders trusts the body shape (routes/orders.js:22).
                     Validate with zod before use, reject on failure.
MEDIUM
  [4 CI]             No pipeline runs the tests. Add lint+test+build on PR.
  [12 Errors]        err.message from the DB driver is returned to clients
                     (routes/orders.js:41). Return a generic message + request id.
  [19 Testing]       No test runner configured. Add one with a smoke test.

Coverage
  PASSED:   3 (Secrets/config, Auth, Data layer)
  FINDINGS: 5 categories above
  N/A:      SEO, HTTP headers already covered, Performance, Rendering untrusted (no such surface)
  NOT CHECKED: SCM platform settings (no API access this run), verify by hand

Bottom line: two HIGH findings block production. Fix those first.
```

- Every finding cites where you found it. A finding with no location is a guess. Leave it out or mark it as "to verify".
- The coverage block is not optional. PASSED / FINDINGS / N/A / NOT CHECKED, every category accounted for.
- If nothing is wrong in a category, it is PASSED, not omitted.

## Rules

- **Honest coverage above all.** A category you couldn't check is NOT CHECKED, never a silent pass. This is the whole value of the report.
- **Ground every finding.** Cite the file and line/area you read. No findings from vibes.
- **Severity is the baseline's, not your mood.** HIGH means security/data-loss/production-breaking, per the file. Don't inflate or soften.
- **Report, don't secretly fix.** Fixes happen only under the Fix setting, only for safe mechanical items, and never for security findings without a human.
- **N/A is a real answer.** Don't grade a library on SEO or a CLI on HTTP headers. Applicability first.

## Extra context from the user

$ARGUMENTS
