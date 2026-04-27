---
name: static-code-analysis
description: Run quality-focused static code analysis and produce an HTML report. Use when the user asks for linting, type checking, style checks, static analysis, quality gates, or an HTML static-analysis report, excluding security, secret scanning, dependency vulnerability scanning, SAST, or compliance audits.
---

# Static Code Analysis

## Overview

Run non-security static code checks and produce one HTML report under the target project's `harness/report/static-analysis/` directory. The report must show which tools ran, which high-priority defects should be fixed, and the exact file and line where each defect appears.

This skill is intentionally scoped to code quality only. Do not run security scanners, secret scanners, dependency vulnerability tools, SAST tools, license scanners, or audit commands.

Only Python projects may execute Python tooling. Non-Python projects, including Java, frontend, and Go projects, must not invoke `python3`, Python scripts, Python virtual environments, or pip.

## Workflow

1. Confirm the target project directory.
2. Read `references/tool-selection.md` only when you need the exact tool-selection rules or high-priority definition.
3. Run the bundled script:

```bash
bash /mnt/skills/user/static-code-analysis/scripts/run-static-analysis.sh [project-dir]
```

If the skill is installed somewhere other than `/mnt/skills/user`, use the actual path to `scripts/run-static-analysis.sh`.

4. Let the script create and use `[project-dir]/harness/report/static-analysis/` for all run artifacts.
5. Review the generated HTML report before presenting results.
6. Tell the user where the HTML report was written and summarize only the high-priority defects.

## Required Report Contents

The HTML report must include:

- The project path and generation time.
- The harness output directory.
- A clear statement that security checks were excluded.
- Dependency preparation notes, including generated requirements when Python quality tools had to be installed.
- A table of every static analysis tool that ran, including command, status, duration, and exit code.
- A high-priority defects section with file, line, column when available, tool name, message, suggested fix, and a nearby code excerpt.
- A readable output section for each failed tool. Show parsed issue cards before raw output, with different visual styles for location, rule/message, and code excerpt. Ruff output must not be shown only as an undifferentiated preformatted blob.

If a tool reports a failure but no code location can be parsed, inspect the tool output manually. Add the exact code location to the user-facing summary when possible, even if the script could not extract it automatically.

## Static Analysis Scope

Allowed examples:

- JavaScript/TypeScript: ESLint, TypeScript `tsc --noEmit`, Prettier check, Stylelint.
- Python: Ruff and mypy are always required for Python projects. Pylint and Pyright run when configured. Missing Python quality tools may be written to `harness/report/static-analysis/requirements.txt` and installed automatically into `harness/report/static-analysis/.venv`.
- Java: only `mvn com.github.spotbugs:spotbugs-maven-plugin:spotbugs` when `pom.xml` is present.
- Go: `gofmt -l`, `go vet`, Staticcheck when already installed.

Forbidden examples:

- `npm audit`, `yarn audit`, `pnpm audit`.
- Bandit, Semgrep security rules, CodeQL security scans.
- Gitleaks, TruffleHog, secret scanners.
- OWASP Dependency Check, Snyk, OSV Scanner, Dependabot audits.
- License, compliance, or policy scans.

When the user asks for both quality and security checks, split the work: run this skill for quality static analysis and use a security-specific workflow separately.

If a project script mixes quality checks with forbidden security/audit commands, skip that script and record the skip reason in the report instead of running a partial or ambiguous command.

Do not ask the user before installing missing Python quality tools for a Python project. The bundled script must generate `harness/report/static-analysis/requirements.txt`, write `harness/report/static-analysis/dependency-notes.md`, create `harness/report/static-analysis/.venv`, and install with that virtual environment's pip. Non-Python projects must never use this Python dependency path; record missing non-Python toolchain dependencies as skipped/environment notes in the HTML report.
