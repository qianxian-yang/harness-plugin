# Tool Selection

Use this reference when deciding whether a command belongs in the quality static-analysis report.

## Scope Rule

Only run tools that inspect source code quality without looking for security vulnerabilities, leaked secrets, license risk, or vulnerable dependencies.

If a tool can run both quality and security checks, use only the quality mode. If the mode is ambiguous, do not run it.

## Stack Profile Rule

Treat the project as `backend + optional frontend`.

- Backend priority: if `pom.xml` exists, backend is Java; otherwise `go.mod`; otherwise `requirements*.txt`; otherwise no backend.
- Frontend is additive when `package.json` exists.
- Valid profiles include `java+frontend`, `python+frontend`, `go+frontend`, `nodejs+frontend`, and backend-only variants.
- When backend priority chooses Java, ignore Python/Go backend markers and note that in skipped/context notes.

## Default Tool Map

| Stack | Run when available | Notes |
|---|---|---|
| JavaScript / TypeScript | `lint`, `typecheck`, `format:check`, `prettier:check` package scripts; local `tsc --noEmit`; local `eslint`; local `stylelint` | Prefer project scripts because they encode local conventions. |
| Python | Ruff, mypy, optionally Pylint and Pyright | Always run Ruff and mypy for Python projects. Run Pylint and Pyright when config is present. If missing, generate `harness/static-analysis/requirements.txt` and install quality-only Python tools into `harness/static-analysis/.venv`. |
| Java / Maven | `mvn -B clean install -DskipTests -U`, then SpotBugs | When `pom.xml` is present, run build first, then SpotBugs by Java major: `>8` use `com.github.spotbugs:spotbugs-maven-plugin:4.9.8.3:spotbugs`, `<=8` use `com.github.spotbugs:spotbugs-maven-plugin:4.7.3.6:spotbugs`. |
| Go | `gofmt -l`, `go vet`, Staticcheck | Treat unformatted files from `gofmt -l` as high-priority quality failures. |

## Python Execution Boundary

Only projects whose selected backend is Python may execute Python tooling. Python backend selection requires `requirements*.txt`, not just `*.py` files. For non-Python backend profiles, including Java+frontend, Go+frontend, and nodejs+frontend, do not invoke `python3`, Python scripts, Python virtual environments, or pip. Report generation must still succeed without Python.

## High-Priority Defects

Treat a finding as high priority when it blocks a clean static-analysis run or points to likely broken code:

- Type errors from TypeScript, mypy, Pyright, Java SpotBugs, or Go vet.
- Linter findings reported as `error`, `fatal`, or equivalent.
- Formatter check failures in code that must pass repository formatting gates.
- Java SpotBugs findings from `mvn com.github.spotbugs:spotbugs-maven-plugin:spotbugs` that make the quality gate fail.

Do not promote ordinary warnings to high priority unless the project config fails the command for that warning.

## Harness Location Expectations

Write all run artifacts under the target project's `harness/static-analysis/` directory, except the top-level report at `harness/static-analysis-report.html`:

- `harness/static-analysis-report.html` for the self-contained HTML report.
- `requirements.txt` when Python quality tools need installation.
- `dependency-notes.md` explaining generated requirements and installation results.
- `.venv/` for Python quality tool installation.

The report should be self-contained HTML with inline CSS so it can be opened directly in a browser.
