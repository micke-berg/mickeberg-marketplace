<!--
  CLAUDE.md skeleton, Next.js (App Router) + TypeScript.
  Pre-filled with the idioms of this stack. init-team confirms these against the
  repo (package.json, next.config, tsconfig) and fills the rest from a short
  interview. Delete any line that isn't true for your project. Keep it tight.
-->

# <PROJECT_NAME>

<ONE_OR_TWO_SENTENCES: what this app is and who uses it.>

## Stack

- **Next.js** (App Router) + **TypeScript** (`strict`)
- **Styling:** <Tailwind / CSS Modules / styled, pick one>
- **Data:** <e.g. Postgres via Supabase / Prisma / none>
- **Deploy:** <e.g. Vercel>
- **Package manager:** <npm / pnpm / yarn, the one with the lockfile in the repo>

## Running it

```bash
<pm> install
<pm> run dev          # local dev server
<pm> run lint         # eslint
<pm> run typecheck    # tsc --noEmit   (add this script if missing)
<pm> run test         # <vitest / jest / playwright>
<pm> run build        # production build; the real gate before shipping
```

Env: copy `.env.local.example` to `.env.local` and fill it. Every `process.env`
value is validated in `<lib/env.ts>` and the app throws at startup if one is missing.

## How the code is organized

- `app/`, routes (App Router). Server Components by default. `"use client"` only where interaction needs it.
- `components/`, shared UI. **Boundary:** client components stay small. Split one past ~300 lines.
- `lib/`, business logic and data access. **Boundary:** route handlers and components call `lib/`, they do not inline data or `fetch` logic.
- `types/`, shared types. Don't redefine the same model in five files.
- **Boundary:** server-only modules (env, secrets, db) are never imported by a `"use client"` file.

## Conventions

- **Commits:** Conventional Commits. Issue key from the branch if present. No AI/tool attribution trailers.
- **Branches:** `type/short-description` off `main`.
- **PRs:** one approval, CI green (lint + typecheck + test + build), description written after the diff.
- **Style:** ESLint + Prettier decide formatting. Run them, don't hand-format. `<pm> run lint --fix`.

## Testing

- **Run:** `<pm> run test`.
- **Must have tests:** pure logic in `lib/` (validators, parsers, money math, state machines), and any API route.
- **Approach:** <real test DB over mocks where feasible; a mocked test can pass while prod breaks>.

## Working with Claude here

- **Always:** run lint, typecheck, and the build before calling a change done (the `verify` skill does this).
- **Ask before:** a schema/migration change, adding a dependency, or touching auth, middleware, or a security header.
- **Never:** commit secrets or `.env*`, use a raw `<img>` where `next/image` fits, add `NEXT_PUBLIC_` to a secret, force-push a shared branch.
- **Security defaults (this stack):** validate every API body (zod), keep security headers in `next.config`, SSRF-guard any server-side URL fetch, sanitize any HTML/MDX from a non-repo source.

## Docs map

- `README.md`, setup, scripts, env table.
- `<docs/…>`, <architecture, data model, runbooks, whatever exists>.
