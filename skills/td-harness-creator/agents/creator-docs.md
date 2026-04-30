# Documentation Creation Agent

You are creating or updating harness documentation files for a codebase.

## Input

You will receive:
- Architecture analysis data (from `harness/.analysis/architecture.json`)
- Audit data showing what exists and what's missing (from `harness/.analysis/audit.json`)
- Delta list of files to create/update

## Files You May Create/Update

### AGENTS.md

The navigation map for AI agents. This is the most important file.

**Target**: 80-120 lines. This is a map, not a manual.

**Structure**:
```
Line 1-10:    Project overview (describe project positioning and summarize the technology stack and repository organization; stack and structure must reflect the actual codebase)
Line 11-25:   Quick commands (build, run, test, format, quality checks) + environment variable setup and precedence (based on the project's real mechanism)
Line 26-45:   Backend architecture (optional; include only when backend exists): ASCII package tree + purpose of each package + brief core subsystem summary, with link to the detailed architecture doc
Line 46-60:   Frontend architecture (optional; include only when frontend exists): tech stack, routing approach, API layer conventions, component standards, with link to the frontend architecture doc
Line 61-75:   Key conventions (exception handling, response conventions, layered dependency rules, code style, security baseline); include a detailed doc link for each rule
Line 76-90:   Local development and verification flow (change → build → run → verify) + API verification method, auth/token acquisition method, and log location guidance
Line 91-100:  Quality check command list (for example lint/format/build/test; use actual repository commands)
Line 101-110: Reference project conventions (reference project/source list + precedence rules when conventions conflict)
Line 111-120: Documentation navigation index (architecture / design-docs / references, etc.)
```

The structure above should be enforced as strictly as possible. The only exception is that the backend/frontend architecture sections are conditional by project type (backend-only projects may omit frontend architecture; frontend-only projects may omit backend architecture).

**Rules**:
- Every link must point to a doc that actually exists
- Include real package names from architecture analysis
- Don't embed detailed explanations — link to docs/

### docs/ARCHITECTURE.md

The authoritative architecture document.

**Must include**:
- Mermaid diagram generated from actual import analysis (not templates)
- Layer table with real packages and their dependencies
- Source citations (`> Sources: [file:line]()`) for every claim
- Forbidden dependency rules

### docs/DEVELOPMENT.md

Development setup and commands.

**Must include**:
- Prerequisites (Go version, Node version, etc.)
- Build commands that actually work
- Test commands with explanation
- Lint commands

### harness/docs/design-docs/

Component-level design documents.

**For each key component** (from architecture analysis):
1. `harness/docs/design-docs/index.md` — Index table
2. `harness/docs/design-docs/{component}.md` — Detailed design doc

**Each design doc must have**:
- Overview
- Architecture (with Mermaid diagram)
- Key Interfaces (with file:line citations)
- Execution Flow
- Error Handling

**Use templates from** `references/documentation-templates.md`.

### Additional docs (as needed)

- `harness/docs/QUALITY.md` — Quality standards
- `harness/docs/TESTING.md` — Testing strategy
- `harness/docs/SECURITY.md` — Security considerations
- `harness/docs/PRODUCT_SENSE.md` — Product context
- `harness/docs/references/index.md` — Reference index

## Quality Requirements

| Requirement | What This Means |
|-------------|-----------------|
| **Source-grounded** | Every claim cites actual file:line |
| **Real data** | Layer maps use actual packages, not placeholders |
| **Working commands** | DEVELOPMENT.md commands actually run |
| **No placeholders** | No "TODO: fill in later" |
| **Numbered sections** | For stable cross-references |

## What NOT to Create

- Source code files
- Test files for business logic
- Application entry points
