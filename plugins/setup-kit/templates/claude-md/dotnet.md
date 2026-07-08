<!--
  CLAUDE.md skeleton, .NET (C#).
  Pre-filled with the idioms of this stack. init-team confirms these against the
  repo (the .sln/.csproj, Directory.Build.props, appsettings) and fills the rest
  from a short interview. Delete any line that isn't true. Keep it tight.
-->

# <PROJECT_NAME>

<ONE_OR_TWO_SENTENCES: what this service/app is and who uses it.>

## Stack

- **.NET** <version, e.g. 8.0> / **C#** <langversion>
- **Type:** <ASP.NET Core Web API / worker service / console / class library>
- **Data:** <EF Core + SQL Server / Postgres / Dapper / none>
- **Key packages:** <the few worth knowing; skip the framework obvious>

## Running it

```bash
dotnet restore
dotnet build                              # warnings-as-errors if configured
dotnet run --project <src/App>            # local run
dotnet test                               # the test suite
dotnet format                             # style; run it, don't hand-format
```

Config: `appsettings.json` for defaults, `appsettings.Development.json` for local,
secrets via `dotnet user-secrets` (never committed). Environment through `IConfiguration`,
not `Environment.GetEnvironmentVariable` scattered inline.

## How the code is organized

- `src/`, projects, one responsibility each (`<App>`, `<Domain>`, `<Infrastructure>`).
- `tests/`, one test project per production project it covers.
- **Boundary:** dependencies flow inward, `Domain` depends on nothing. `Infrastructure` and the web layer depend on `Domain`, never the reverse.
- **Boundary:** services are resolved through DI, not `new`-ed at call sites. Register in `Program.cs` / a composition root.

## Conventions

- **Commits:** Conventional Commits. Issue key from the branch if present. No tool attribution.
- **Branches:** `type/short-description` off `main`.
- **PRs:** one approval, CI green (build + test + format check), description written after the diff.
- **Style:** `.editorconfig` + `dotnet format` decide it. Nullable reference types on. Treat warnings as errors where the project does.

## Testing

- **Run:** `dotnet test`.
- **Must have tests:** domain logic, validators, anything with branching business rules.
- **Approach:** <xUnit/NUnit; integration tests against a real or containerized DB over mocks where feasible>.

## Working with Claude here

- **Always:** `dotnet build` and `dotnet test` before calling a change done (the `verify` skill does this, point it at the dotnet commands).
- **Ask before:** an EF migration, adding a NuGet package, or touching auth/authorization or a public API contract.
- **Never:** commit secrets or connection strings (use user-secrets / a vault), check in `bin/` or `obj/`, force-push a shared branch.
- **Security defaults (this stack):** validate inputs at the boundary (model validation / FluentValidation), parameterized queries only, don't leak exception details to clients.

## Docs map

- `README.md`, setup, run, test.
- `<docs/…>`, <architecture, ADRs, runbooks, whatever exists>.
