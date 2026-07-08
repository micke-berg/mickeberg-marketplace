# The baseline

A professional minimum for a software project, written to be graded against. It is stack-agnostic: each item states a **principle** that holds for any codebase, then how to **check** it per stack where the mechanism differs. The bar is "should never have shipped without this," not "nice to have."

`team-baseline` walks these categories against a repo and reports findings honestly, including which categories it could not check and which do not apply. A category that does not apply to this kind of project (SEO for a CLI, HTTP headers for a library) is **N/A**, not a failure.

## How to grade

Each failing check is a finding with a severity:

- **HIGH**. A security hole, data-loss risk, or a gap that will bite in production. Blocks "production-baseline".
- **MEDIUM**. A real gap that should be fixed soon, not immediately dangerous.
- **LOW**. Hygiene and polish. Worth doing, safe to defer.

The overall grade:

- **PASS**. No HIGH, few or no MEDIUM.
- **AT RISK**. No HIGH, several MEDIUM.
- **NOT BASELINE**. One or more HIGH. List them first, each with the one concrete fix.

Applicability first: decide which categories fit this project (web app, API, library, CLI, mobile) before checking. Grade only what applies, and say what you skipped and why.

---

## 1. Repository hygiene

**Principle:** the repo leaks nothing and its history is clean.

- `.gitignore` covers env files (`.env*` except examples), dependency dirs, build output, editor/OS cruft, local/private notes, coverage. **HIGH** if env files are not ignored.
- No secrets committed now. Grep the tree for key shapes (`sk-`, `AKIA`, `Bearer `, `-----BEGIN`, long hex/base64, provider prefixes), excluding lockfiles. **HIGH** on any hit.
- No secrets in history. `git log --all -p -- <suspect paths>` or a scanning tool. A secret ever committed must be rotated and the history rewritten. **HIGH**.
- Commit messages and branch names carry no throwaway origin context that shouldn't be public. **LOW**, flag rather than erase.

## 2. Task tracking and PR descriptions

**Principle:** the task is recorded where tasks belong. The PR describes what actually shipped.

- Non-trivial work has an issue/ticket for its description and requirements. The PR body is not the only record of the task. **MEDIUM** if the tracker is the PR.
- PR descriptions are written **after** the diff and say what the change does and why, referencing the issue for what was asked. Not a pre-written task list left stale. **MEDIUM**.
- PR bodies are checked for content that shouldn't be public (unpatched-vuln detail, pasted credentials, internal context). **HIGH** if a secret is in a PR body.

## 3. Source-control platform settings

**Principle:** the repo's platform settings match its risk.

- Private unless public is intended. **HIGH** if a private-intended repo is public.
- Branch protection on the main branch: require PR, require review, require status checks once CI exists, block force-push and deletion. **MEDIUM** (**HIGH** for a team repo with direct pushes to main).
- Dependency alerts and automated security updates enabled. **MEDIUM**.
- Secret scanning + push protection enabled where the platform offers it. **MEDIUM**.
- No access token committed or over-scoped in CI secrets. **HIGH** if found.

## 4. CI

**Principle:** the checks that gate quality run automatically, not just on someone's laptop.

- A CI pipeline runs lint, typecheck, test, and build on push and PR. **MEDIUM** if absent, **HIGH** if "tests exist but nothing runs them".
- CI is required to pass before merge (ties to branch protection). **MEDIUM**.

## 5. Secrets and configuration

**Principle:** configuration is validated, and secrets are never hardcoded.

- Every environment variable is validated at startup and the app fails fast if a required one is missing (zod/valibot in JS, a typed config/options object in .NET, pydantic/settings in Python). **MEDIUM**, **HIGH** if missing config fails silently in prod.
- No `env || "hardcoded-fallback"` for secrets or per-environment URLs. **HIGH** for a secret fallback.
- An up-to-date example env file is committed. The real one never is. **MEDIUM**.
- Public/exposed config is deliberately separated from secret config (e.g. a `PUBLIC_`/`NEXT_PUBLIC_` prefix is never on a secret). **HIGH** if a secret is exposed to the client.

## 6. Authentication

*(Applies to anything with auth. N/A for a library or a public static site.)*

**Principle:** credentials are compared safely, stored safely, and rate-limited.

- Passwords/tokens compared in constant time (`timingSafeEqual` / framework equivalent), never `==`. **HIGH**.
- No plaintext passwords held in client state and resent per request. Use signed, HttpOnly session cookies or the framework's session. **HIGH**.
- The login path is rate-limited / has lockout or slowdown after N failures. **MEDIUM**.
- A single shared secret (guest-style auth) is scoped narrowly and rotated, or replaced with one-time tokens. **MEDIUM**.

## 7. LLM / AI routes

*(Applies to any endpoint calling an LLM provider. N/A otherwise.)*

**Principle:** an AI route is a spend-and-injection surface and is guarded like one.

- Requires auth, rate-limited per user and per IP. **HIGH** if an open, unauthenticated LLM route exists.
- Input lengths capped, `max_tokens` capped, a provider-side monthly spend cap set. **MEDIUM** (**HIGH** if an open route has no caps).
- User-supplied text is treated as untrusted data: wrapped in delimiters, with the model instructed not to follow instructions inside it. **MEDIUM**.
- Model output is validated server-side (parse, schema-check) before use or echo. **MEDIUM**.
- URL inputs that get fetched apply the SSRF guard (category 9). **HIGH**.

## 8. HTTP security headers

*(Applies to web apps/sites. N/A for a CLI or library.)*

**Principle:** the browser is told the safe defaults.

- Sets, at minimum: HSTS, `X-Content-Type-Options: nosniff`, a frame policy (`X-Frame-Options: DENY` or CSP `frame-ancestors`), a sane `Referrer-Policy`, a `Permissions-Policy`, and a `Content-Security-Policy`. **MEDIUM** (**HIGH** if a form/auth app has none).
- Server banner / `x-powered-by` disabled. **LOW**.

## 9. Server-side URL fetching (SSRF)

*(Applies to any server code that fetches a URL it was given. N/A otherwise.)*

**Principle:** a server that fetches a user-supplied URL must not be tricked into hitting internal targets.

- Scheme allowlisted to `https:`. `file:`/`ftp:`/`gopher:`/`data:` rejected. **HIGH**.
- Hostname resolved and private/loopback/link-local ranges rejected (RFC1918, 127/8, 169.254/16, `::1`, `fc00::/7`). **HIGH**.
- Response size capped in bytes, a timeout via an abort mechanism, redirects blocked or re-checked. **MEDIUM**.

## 10. Rendering untrusted content

*(Applies where content comes from users or third parties and is rendered as HTML/markdown/MDX. N/A for repo-only content.)*

**Principle:** never render untrusted markup unsanitized.

- HTML/markdown/MDX from any non-trusted source is sanitized with an allowlist schema. **HIGH** if raw untrusted HTML is rendered.
- JSON embedded in a script tag is serialized and `<` escaped to prevent tag-breakout. **MEDIUM**.

## 11. Input validation

**Principle:** shape is never trusted. The boundary validates.

- Every API/request body is schema-validated (zod/valibot, model validation/FluentValidation, pydantic/DRF serializers). **HIGH** if unvalidated input reaches logic.
- Enumerable values (author, tag, category, role) are allowlisted, not free-text into a fixed set. **MEDIUM**.
- String lengths capped server-side. **LOW/MEDIUM**.
- Validation failures return a safe error that does not leak the schema. **MEDIUM**.

## 12. Error handling

**Principle:** clients get a safe message. Details live in logs.

- A generic message plus a request id to the client. Full detail logged server-side. **MEDIUM**.
- Third-party/SDK error messages are not echoed to clients (they leak IDs, versions, internals). **MEDIUM/HIGH**.
- A last-resort error surface exists (framework error boundary / handler) so a failure degrades, not 500s blank. **MEDIUM**.

## 13. Data layer

**Principle:** external data access is paginated, retried, atomic, and degrades gracefully.

- Every list call against an external/store API has a pagination ceiling and loops the cursor. Silent truncation is the classic bug. **MEDIUM** (**HIGH** if truncation causes data loss/wrong results).
- External clients retry on 429 (respecting `Retry-After`) with capped exponential backoff on 5xx. **MEDIUM**.
- Writes are atomic, no "delete all then re-append". Append-then-remove, or a transaction. Assume any request can fail mid-way. **HIGH** if a non-atomic write can lose data.
- Data fetches degrade gracefully (try/catch, sensible empty/null, an error surface) rather than crashing the page. **MEDIUM**.

## 14. Performance

*(Applies to user-facing apps. Grade lightly for internal tools.)*

**Principle:** the obvious performance defaults are in place.

- Images go through the framework's image handling with explicit dimensions. The LCP image is prioritized. **LOW/MEDIUM**.
- Fonts are self-hosted/bundled, not fetched from a third-party CDN at runtime. **LOW**.
- Hot data fetches are deduplicated/cached per request where the framework supports it. **LOW**.

## 15. SEO

*(Applies to public marketing/content sites. N/A for apps, APIs, internal tools.)*

**Principle:** a public site is discoverable and shares correctly.

- Base metadata (title, description, canonical), Open Graph + Twitter card with a default share image, sitemap and robots using the real site URL, structured data for articles. **LOW/MEDIUM**.
- Internal/admin routes are `noindex`. **MEDIUM**.

## 16. Language and config strictness

**Principle:** the compiler/linter catches what it can.

- Strict type settings on: TypeScript `strict` (+ `noUncheckedIndexedAccess`, `noImplicitOverride`), C# nullable reference types + warnings-as-errors, Python type checking in CI (mypy/pyright) where used. **MEDIUM**.
- Lint rules beyond defaults where they matter (no stray `console`/print in prod code, no server-only imports in client files, discouraged `any`/`dynamic`). **LOW/MEDIUM**.
- Config files are covered by the type/lint setup, not excluded. **LOW**.
- Runtime major version pinned to what deploy runs. **LOW**.

## 17. Architecture boundaries

**Principle:** responsibilities are separated and not duplicated.

- Presentation stays thin. Oversized components/handlers are split (a soft ceiling, enforced in the same change that crosses it). **LOW/MEDIUM**.
- Shared UI, business logic, and types each have one home, not five copies. **MEDIUM**.
- API routes follow a consistent resource shape. Sprawling verb-routes signal accretion. **LOW**.
- Cross-cutting concerns (auth, config, response envelope) each have one idiomatic implementation. A second copy is the signal to extract the first. **MEDIUM**.

## 18. Documentation

**Principle:** a new contributor can start from the docs, and the docs match the code.

- README gets a clean clone to a running dev server by following it alone, in a reasonable time. **MEDIUM**.
- A project brief (README/CLAUDE.md/CONTRIBUTING) conveys the data model and route/module map. **LOW/MEDIUM**.
- Every env var is documented in the example env file **and** the README. **LOW**.
- Docs match the code. More routes/commands in code than in docs means the docs are wrong. Updated in the same change that alters the surface. **MEDIUM**.

## 19. Testing

**Principle:** the important logic is tested, and tests reflect reality.

- A test runner is set up from day one, even with one smoke test. **MEDIUM**.
- Pure business logic (validators, parsers, state machines, money math) has unit tests. **MEDIUM**.
- Integration tests run against a real/seeded test database where feasible. Mocks are the fallback, not the default (a mocked test can pass while prod breaks). **MEDIUM**.

---

## Reporting

Produce a findings report, most severe first, each finding naming: the category, the severity, what's wrong (concrete, with the file/location where you found it), and the one fix. End with the honest coverage line: which categories PASSED, which had findings, which were N/A for this project, and which you could **not** check and why. A category you skipped is never silently a pass.
