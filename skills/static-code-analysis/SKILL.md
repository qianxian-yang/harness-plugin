---
name: static-code-analysis
description: Run quality-focused static code analysis and produce an HTML report. Use when the user asks for linting, type checking, style checks, static analysis, quality gates, or an HTML static-analysis report, excluding security, secret scanning, dependency vulnerability scanning, SAST, or compliance audits.
---

# Static Code Analysis

## Overview

Run non-security static code checks and produce one HTML report at `harness/static-analysis-report.html`, with other run artifacts under the target project's `harness/static-analysis/` directory. The report must show which tools ran, which high-priority defects should be fixed, and the exact file and line where each defect appears.

This skill is intentionally scoped to code quality only. Do not run security scanners, secret scanners, dependency vulnerability tools, SAST tools, license scanners, or audit commands.

Only projects whose backend stack is Python may execute Python tooling. Other stack combinations, including Java+frontend and Go+frontend, must not invoke `python3`, Python scripts, Python virtual environments, or pip.

Detect stacks as `backend + optional frontend`:
- backend priority: `pom.xml` -> Java, else `go.mod` -> Go, else `requirements*.txt` -> Python, else none.
- frontend is additive when a directory has `package.json` and frontend source files (`.ts`, `.tsx`, `.js`, `.jsx`, `.css`, `.less`, `.scss`) exist under the project root or that directory.

## Workflow

1. Confirm the target project directory.
2. Read `references/tool-selection.md` only when you need the exact tool-selection rules or high-priority definition.
3. Run the bundled script:

```bash
bash /mnt/skills/user/static-code-analysis/scripts/run-static-analysis.sh [project-dir]
```

If the skill is installed somewhere other than `/mnt/skills/user`, use the actual path to `scripts/run-static-analysis.sh`.

4. Let the script write the HTML report to `[project-dir]/harness/static-analysis-report.html`, and write all other run artifacts to `[project-dir]/harness/static-analysis/`.
5. Review the generated HTML report before presenting results.
6. Tell the user where the HTML report was written and summarize only the high-priority defects.

## Required Report Contents

The HTML report must include:

- The project path and generation time.
- The harness output directory.
- A clear statement that security checks were excluded.
- A first section (`Summary`) that classifies high-priority defects by tool.
- A second section (`Tools Overview`) with exactly these columns: `Tool`, `Command`, `Duration`, `Issues`.
- `Issues` values in the second section must link to the matching tool group in the third section when the issue count is greater than zero.
- A third section (`High-Priority Defect Details`) that shows only high-priority, recommended-to-fix defects.
- The third section must group defects by tool, and each defect item must be collapsible.

If a tool reports a failure but no code location can be parsed, inspect the tool output manually. Add the exact code location to the user-facing summary when possible, even if the script could not extract it automatically.

## Static Analysis Scope

Allowed examples:

- JavaScript/TypeScript: ESLint, TypeScript `tsc --noEmit`, Prettier check, Stylelint.
- Python: Ruff and mypy are always required for Python projects. Pylint and Pyright run when configured. Missing Python quality tools may be written to `harness/static-analysis/requirements.txt` and installed automatically into `harness/static-analysis/.venv`.
- Java: run `mvn -B clean install -DskipTests -U` first. Then run SpotBugs with version by Java major: `>8` uses `mvn com.github.spotbugs:spotbugs-maven-plugin:4.9.8.3:spotbugs`, `<=8` uses `mvn com.github.spotbugs:spotbugs-maven-plugin:4.7.3.6:spotbugs`.
- Go: `gofmt -l`, `go vet`, Staticcheck when already installed.

Forbidden examples:

- `npm audit`, `yarn audit`, `pnpm audit`.
- Bandit, Semgrep security rules, CodeQL security scans.
- Gitleaks, TruffleHog, secret scanners.
- OWASP Dependency Check, Snyk, OSV Scanner, Dependabot audits.
- License, compliance, or policy scans.

When the user asks for both quality and security checks, split the work: run this skill for quality static analysis and use a security-specific workflow separately.

If a project script mixes quality checks with forbidden security/audit commands, skip that script and record the skip reason in the report instead of running a partial or ambiguous command.

Do not ask the user before installing missing Python quality tools for a Python project. The bundled script must generate `harness/static-analysis/requirements.txt`, write `harness/static-analysis/dependency-notes.md`, create `harness/static-analysis/.venv`, and install with that virtual environment's pip. Non-Python projects must never use this Python dependency path; record missing non-Python toolchain dependencies as skipped/environment notes in the HTML report.
