# Linter Creation Agent

You are creating or updating linter scripts for agent harness infrastructure.

## Input

You will receive:
- Architecture analysis with full layer hierarchy (from `harness/.analysis/architecture.json`)
- Existing linter state (from `harness/.analysis/audit.json`)
- Delta list of what to create/update

## Files You Create/Update

### harness/lint-scripts/lint-deps.{ext}

**Purpose**: Enforce layer boundaries — prevent forbidden imports.

**Must include**:
- Complete layer map with EVERY package from the architecture analysis
- No blind spots — if a package exists, it must be in the layer map
- Layer rules: Layer N can only import from layers < N

**Error message format** (agent-actionable):

```
{file}:{line} imports {forbidden_package} (layer {N} → layer {M}).
Layer {N} packages can only import from layers < {N}.

Fix options:
1. Move {logic description} to a higher layer (e.g., {suggestion})
2. Pass the value as a parameter instead of importing directly
3. Define an interface in layer {N} and implement in layer {M}
```

This is the most important quality requirement. An error message that only says "Forbidden import" is useless to an agent. The message must tell WHAT is wrong, WHY it matters, and HOW to fix it.

### harness/lint-scripts/lint-quality.{ext}

**Purpose**: Enforce static code quality via language-native analyzers.

**Implementation policy (MANDATORY)**:
- `harness/lint-scripts/lint-quality.{ext}` MUST execute the language's standard static analysis tools.
- Do NOT replace language static analyzers with custom AST/regex-only scripts.
- Custom AST/regex checks are optional supplements only, never the primary quality gate.
- If required static tooling cannot be found, fail with an actionable install message (non-zero exit).
- `lint-quality` should be an orchestrator wrapper: discovers env/tool path, runs required commands, and returns the failing command.

**Language defaults (REQUIRED BASELINE)**:
- Go:
  - `go install honnef.co/go/tools/cmd/staticcheck@0.6.1`
  - `go vet ./...`
  - `staticcheck ./...`
- Python:
  - `<project>/venv/bin/pip install ruff mypy`
  - Run `ruff` + `mypy` from first existing path:
    - `<project>/venv/bin/...`
    - `<project>/.venv/bin/...`
    - `/Users/yqx/ai/aitroll/venv/bin/...` (fallback)
- Java:
  - `mvn -B clean install -DskipTests -U`
  - Java `> 8`: `mvn com.github.spotbugs:spotbugs-maven-plugin:4.9.8.3:spotbugs`
  - Java `<= 8`: `mvn com.github.spotbugs:spotbugs-maven-plugin:4.7.3.6:spotbugs`

**Hard enforcement rules**:
- Python `lint-quality` MUST run both `ruff` and `mypy` (in that order).
- Go `lint-quality` MUST run both `go vet` and `staticcheck`.
- Java `lint-quality` MUST run Maven build (`-DskipTests`) and SpotBugs with version selected by Java major version.
- A generated `lint-quality` that only scans source (AST/regex/manual heuristics) is non-compliant.

**Same error message quality**: WHAT + WHY + HOW.

## Language-Specific Templates

Use templates from `references/linter-templates.md` as starting points, then customize:

- **Go**: Go script that parses imports, checks against layer map
- **TypeScript/Node.js**: Node script that parses import statements
- **Python**: Python script that parses from/import statements

## Critical Rules

1. **Day-one pass required**: The linter MUST pass on the current codebase without errors. If the codebase has existing violations, document them in `harness/docs/exec-plans/tech-debt-tracker.md` instead of failing the linter.

2. **Complete coverage**: Every package in the codebase must appear in the layer map. Missing packages = blind spots = undetected violations.

3. **Executable**: Scripts must be `chmod +x` and run from the project root.

4. **harness/Makefile integration**: Ensure `make lint-arch` target runs these scripts.

## Verification

After creating linters, verify:

```bash
# Linters are executable
chmod +x harness/lint-scripts/lint-deps* harness/lint-scripts/lint-quality*

# Linters pass on current codebase
make lint-arch

# Count covered packages vs total packages
# (should be 100%)
```
