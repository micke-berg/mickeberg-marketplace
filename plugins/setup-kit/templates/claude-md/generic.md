<!--
  CLAUDE.md skeleton, generic / any stack.
  This is the shape of a good project brief for Claude Code. The structure is
  generic. The content is yours. init-team fills these sections from what it can
  read in the repo plus a short interview, and shows you the result before writing.
  Fill or delete every <PLACEHOLDER>. A section you leave empty is worse than one
  you remove. Keep it short: a brief that is read beats an exhaustive one that isn't.
-->

# <PROJECT_NAME>

<ONE_OR_TWO_SENTENCES: what this project is and who it is for.>

## Stack

- **Language / runtime:** <e.g. Go 1.22, Node 20, Python 3.12>
- **Framework:** <e.g. Gin, Express, none>
- **Data:** <database, cache, queue, or "none">
- **Key libraries:** <the few worth knowing; skip the obvious ones>

## Running it

<!-- The commands a new contributor runs. Real commands, copy-pasteable. -->

```bash
<install deps>        # e.g. make setup
<run dev>             # e.g. make dev
<run tests>          # e.g. make test
<build>              # e.g. make build
```

Environment: <how env/config is provided, an example file, a secrets manager, nothing needed>.

## How the code is organized

<!-- The map that stops Claude guessing. Where things live, and the boundaries
     that must not be crossed. Two to five bullets, not a file tree. -->

- <e.g. `cmd/` entrypoints, `internal/` business logic, `pkg/` shared>
- **Boundary:** <e.g. handlers never touch the DB directly, they call the service layer>
- **Boundary:** <e.g. config is read only through `config/`, never `os.Getenv` inline>

## Conventions

- **Commits:** <e.g. Conventional Commits; issue key from the branch; no tool attribution>
- **Branches:** <e.g. `type/short-description`, off `main`>
- **Pull requests:** <e.g. one approval, CI green, description written after the diff>
- **Code style:** <formatter/linter that decides style, e.g. gofmt + golangci-lint, run it, don't hand-format>

## Testing

- **How to run:** <command>
- **What must have tests:** <e.g. business logic and parsers; not glue code>
- **Approach:** <e.g. table tests against a real test DB, mocks discouraged>

## Working with Claude here

<!-- The most valuable section. Be specific about the local rules. -->

- **Always:** <e.g. run the linter and tests before saying a change is done>
- **Ask before:** <e.g. changing the schema, adding a dependency, touching auth>
- **Never:** <e.g. commit secrets, edit generated files, force-push a shared branch, invent an API that isn't there>
- **When unsure:** <e.g. stop and ask rather than guess at business rules>

## Docs map

<!-- Which document owns what, so Claude updates the right one. -->

- `README.md`, <what it covers>
- `<other docs>`, <what they cover>
