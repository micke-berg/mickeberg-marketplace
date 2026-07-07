---
name: verify
description: Before calling a change done, actually verify it. Detects and runs the project's own checks (lint, typecheck, test, build), loops on fixable failures, and reports honestly — a check that did not run is reported as "not run", never as passed. Use whenever the user says "verify", "verify this", "is it ready", "is it done", "check before I commit", "check before I push", "ship it", or has finished an implementation and the next step is committing, pushing, or opening a PR.
---

# Verify

Actually check a change before anyone calls it done. The one rule that matters: **never report something as passing unless it truly ran and passed.** A check that does not exist or did not run is "not run", not "pass". A green result is a promise that the work was really checked.

## Customize (edit this block for your project)

- **Layers**: `lint, typecheck, test, build` — the checks to run, in order. Drop any your project does not have.
- **Commands**: `AUTO` — detect from `package.json` scripts and the lockfile (pnpm / npm / yarn). Replace with explicit commands if detection is wrong, e.g. `test: "pnpm vitest run"`.
- **Auto-fix**: `ASK` — for fixable layers (lint / format), offer to run the fix and re-check once. Set `ON` to fix without asking, `OFF` to never fix.
- **Gate marker**: `ON` — on all-green, write `.guardrails/verify-pass.json` so this plugin's optional pre-push gate can confirm a real pass. Set `OFF` if you do not use the gate.

## Workflow

1. **See what changed.** Run `git status --short` and `git diff` (staged and unstaged) so the report is about this change and you can judge which layers matter.
2. **Detect the toolchain.** Read `package.json`. Pick the package manager from the lockfile (`pnpm-lock.yaml` → pnpm, `yarn.lock` → yarn, otherwise npm). Map each layer to the project's own script:
   - lint → a `lint` script (or `eslint` if present)
   - typecheck → a `typecheck` / `type-check` script (or `tsc --noEmit` when the repo is TypeScript)
   - test → a `test` script
   - build → a `build` script
   If a layer has no matching script, it is **not run** (report it as such), not failed. This skill assumes a JS/TS project; for other stacks, set the commands explicitly in the Customize block.
3. **Run the layers in order** with the detected package manager, e.g. `pnpm run lint`. Capture pass/fail and, on failure, the key output.
4. **Handle fixable failures** per the Auto-fix setting. If lint fails and a fix exists (`lint --fix` or a `format` script), offer or run it per ASK / ON, then re-run that one layer once.
5. **Report honestly** (format below).
6. **On all-green**, if Gate marker is ON, write `.guardrails/verify-pass.json`:
   ```json
   {
     "pass": true,
     "branch": "<current branch>",
     "ranAt": "<ISO timestamp>",
     "layers": { "lint": "pass", "typecheck": "pass", "test": "pass", "build": "not-run" }
   }
   ```

## The report

Always a truthful per-layer summary. For example:

```text
Verify — branch feature/cart-totals
  lint       PASS
  typecheck  PASS
  test       FAIL   3 failing in cart.test.ts (see below)
  build      NOT RUN (blocked by failing tests)

Result: NOT verified. Fix the failing tests, then re-run.
```

- Every layer is PASS, FAIL, or NOT RUN. Never blank, never an optimistic PASS.
- If a layer did not run because an earlier one failed, say so.
- Only say "verified" when every layer that exists passed. If any were skipped, name them.

## Rules

- A check that did not run is **not run**, never **passed**. This is the whole point of the skill.
- Do not edit code to force a check green unless the user asked you to fix it (auto-fix covers only lint / format).
- Do not write the pass marker unless the run was genuinely all-green.

## Extra context from the user

$ARGUMENTS
