# Tool Selection

Use this reference when deciding whether a command belongs in the quality static-analysis report.

## Scope Rule

Only run tools that inspect source code quality without looking for security vulnerabilities, leaked secrets, license risk, or vulnerable dependencies.

If a tool can run both quality and security checks, use only the quality mode. If the mode is ambiguous, do not run it.

## Default Tool Map

| Stack | Run when available | Notes |
|---|---|---|
| JavaScript / TypeScript | `lint`, `typecheck`, `format:check`, `prettier:check` package scripts; local `tsc --noEmit`; local `eslint`; local `stylelint` | Prefer project scripts because they encode local conventions. |
| Python | Ruff, Flake8, Pylint, mypy, Pyright | Run type checkers when config is present. If missing, generate `harness/static-analysis/requirements.txt` and install quality-only Python tools into `harness/static-analysis/.venv`. |
| Java / Maven | `mvn com.github.spotbugs:spotbugs-maven-plugin:spotbugs` | Run this exact Maven goal when `pom.xml` is present. Do not run Checkstyle, PMD, Gradle tasks, or other Java static-analysis commands from this skill. |
| Go | `gofmt -l`, `go vet`, Staticcheck | Treat unformatted files from `gofmt -l` as high-priority quality failures. |

## Python Execution Boundary

Only projects with Python source files may execute Python tooling. For non-Python projects, including Java, frontend, and Go projects, do not invoke `python3`, Python scripts, Python virtual environments, or pip. Report generation must still succeed without Python.

## High-Priority Defects

Treat a finding as high priority when it blocks a clean static-analysis run or points to likely broken code:

- Type errors from TypeScript, mypy, Pyright, Java SpotBugs, or Go vet.
- Linter findings reported as `error`, `fatal`, or equivalent.
- Formatter check failures in code that must pass repository formatting gates.
- Java SpotBugs findings from `mvn com.github.spotbugs:spotbugs-maven-plugin:spotbugs` that make the quality gate fail.

Do not promote ordinary warnings to high priority unless the project config fails the command for that warning.

## Harness Location Expectations

Write all run artifacts under the target project's `harness/static-analysis/` directory by default:

- `static-analysis-report.html` for the self-contained HTML report.
- `requirements.txt` when Python quality tools need installation.
- `dependency-notes.md` explaining generated requirements and installation results.
- `.venv/` for Python quality tool installation.

The report should be self-contained HTML with inline CSS so it can be opened directly in a browser.
