#!/bin/bash
set -euo pipefail

TARGET="."
QUALITY_EXT="sh"
FORCE=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --target)
      TARGET="${2:-}"
      shift 2
      ;;
    --quality-ext)
      QUALITY_EXT="${2:-}"
      shift 2
      ;;
    --force)
      FORCE=1
      shift
      ;;
    *)
      echo "Unknown arg: $1" >&2
      exit 1
      ;;
  esac
done

if [[ -z "$TARGET" || -z "$QUALITY_EXT" ]]; then
  echo "--target and --quality-ext are required" >&2
  exit 1
fi

TARGET="$(cd "$TARGET" && pwd)"
QUALITY_DIR="$TARGET/harness/quality-scripts"
SERVER_DIR="$TARGET/harness/server-scripts"
DOCS_DIR="$TARGET/harness/docs"
LINT_SCRIPT="$QUALITY_DIR/lint-quality.${QUALITY_EXT}"
UNIT_SCRIPT="$QUALITY_DIR/unit-test-coverage.sh"
SETUP_SCRIPT="$SERVER_DIR/setup-env.sh"
START_SCRIPT="$SERVER_DIR/start-server.sh"
AGENTS_FILE="$TARGET/AGENTS.md"
CLAUDE_FILE="$TARGET/CLAUDE.md"

mkdir -p "$QUALITY_DIR" "$SERVER_DIR" "$DOCS_DIR"

write_file() {
  local path="$1"
  local mode="$2"
  if [[ -f "$path" && "$FORCE" -ne 1 ]]; then
    echo "Skip existing: $path (use --force to overwrite)" >&2
    return
  fi
  cat > "$path"
  chmod "$mode" "$path"
}

detect_gitnexus_skill() {
  local codex_home="${CODEX_HOME:-$HOME/.codex}"
  local candidates=(
    "$codex_home/skills/gitnexus-cli/SKILL.md"
    "$HOME/.codex/skills/gitnexus-cli/SKILL.md"
    "$TARGET/skills/gitnexus-cli/SKILL.md"
  )
  for p in "${candidates[@]}"; do
    if [[ -f "$p" ]]; then
      echo "$p"
      return 0
    fi
  done
  return 1
}

detect_stack() {
  local stack=()
  [[ -f "$TARGET/go.mod" ]] && stack+=("go")
  [[ -f "$TARGET/pom.xml" || -f "$TARGET/build.gradle" || -f "$TARGET/build.gradle.kts" ]] && stack+=("java")
  [[ -f "$TARGET/pyproject.toml" || -f "$TARGET/requirements.txt" || -f "$TARGET/setup.py" ]] && stack+=("python")
  [[ -f "$TARGET/package.json" ]] && stack+=("node")
  if [[ ${#stack[@]} -eq 0 ]]; then
    stack+=("unknown")
  fi
  printf '%s\n' "${stack[@]}"
}

detect_project_type() {
  local has_frontend=0
  local has_backend=0

  if [[ -d "$TARGET/src" || -d "$TARGET/app" ]]; then
    if rg -n "react|vue|angular|next|vite|svelte" "$TARGET" --glob '!node_modules/**' >/dev/null 2>&1; then
      has_frontend=1
    fi
  fi

  if rg -n "express|koa|fastify|spring|flask|django|gin|echo" "$TARGET" --glob '!node_modules/**' >/dev/null 2>&1; then
    has_backend=1
  fi

  [[ -f "$TARGET/pom.xml" || -f "$TARGET/go.mod" || -f "$TARGET/requirements.txt" || -f "$TARGET/pyproject.toml" ]] && has_backend=1
  echo "$has_backend $has_frontend"
}

GITNEXUS_PATH=""
if GITNEXUS_PATH="$(detect_gitnexus_skill)"; then
  echo "Detected gitnexus-cli skill: $GITNEXUS_PATH" >&2
  echo "Action: Use $gitnexus-cli before generation when available in runtime." >&2
else
  echo "gitnexus-cli skill not found; continue with local detection." >&2
fi

STACK_LIST="$(detect_stack | tr '\n' ',' | sed 's/,$//')"
read -r HAS_BACKEND HAS_FRONTEND < <(detect_project_type)

write_file "$LINT_SCRIPT" 755 <<'LINT_EOF'
#!/bin/bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT"

run_if_cmd() {
  local cmd="$1"
  shift
  if command -v "$cmd" >/dev/null 2>&1; then
    "$cmd" "$@"
  else
    echo "Skip: missing command '$cmd'" >&2
  fi
}

if [[ -f "go.mod" ]]; then
  run_if_cmd go vet ./...
  run_if_cmd staticcheck ./...
fi

if [[ -f "pyproject.toml" || -f "requirements.txt" || -f "setup.py" ]]; then
  if [[ -x "venv/bin/ruff" && -x "venv/bin/mypy" ]]; then
    venv/bin/ruff check .
    venv/bin/mypy .
  elif [[ -x ".venv/bin/ruff" && -x ".venv/bin/mypy" ]]; then
    .venv/bin/ruff check .
    .venv/bin/mypy .
  else
    echo "Skip Python static checks: no venv/.venv ruff+mypy found" >&2
  fi
fi

if [[ -f "pom.xml" ]]; then
  run_if_cmd mvn -B clean install -DskipTests -U

  JAVA_MAJOR=""
  if command -v java >/dev/null 2>&1; then
    JAVA_VER_RAW="$(java -version 2>&1 | head -n1)"
    if [[ "$JAVA_VER_RAW" =~ \"([0-9]+)\. ]]; then
      JAVA_MAJOR="${BASH_REMATCH[1]}"
    fi
  fi

  if [[ -n "$JAVA_MAJOR" && "$JAVA_MAJOR" -le 8 ]]; then
    run_if_cmd mvn com.github.spotbugs:spotbugs-maven-plugin:4.7.3.6:spotbugs
  else
    run_if_cmd mvn com.github.spotbugs:spotbugs-maven-plugin:4.9.8.3:spotbugs
  fi
fi

if [[ -f "package.json" ]]; then
  run_if_cmd npm run lint
  run_if_cmd npm run typecheck
fi
LINT_EOF

write_file "$UNIT_SCRIPT" 755 <<'UNIT_EOF'
#!/bin/bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT"

if [[ -f "package.json" ]]; then
  if npm run | rg -n "test:coverage" >/dev/null 2>&1; then
    npm run test:coverage
  else
    npm test -- --coverage || npm test
  fi
fi

if [[ -f "pyproject.toml" || -f "requirements.txt" || -f "setup.py" ]]; then
  if [[ -x "venv/bin/pytest" ]]; then
    venv/bin/pytest --cov=. --cov-report=term-missing --cov-report=xml
  elif [[ -x ".venv/bin/pytest" ]]; then
    .venv/bin/pytest --cov=. --cov-report=term-missing --cov-report=xml
  else
    echo "Skip Python tests: pytest not found in venv/.venv" >&2
  fi
fi

if [[ -f "go.mod" ]]; then
  go test ./... -coverprofile=coverage.out -covermode=atomic
fi

if [[ -f "pom.xml" ]]; then
  mvn -B test
  if rg -n "jacoco-maven-plugin" pom.xml >/dev/null 2>&1; then
    mvn -B jacoco:report
  fi
fi
UNIT_EOF

write_file "$SETUP_SCRIPT" 755 <<'SETUP_EOF'
#!/bin/bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT"

echo "[setup-env] root: $ROOT" >&2

if [[ -f ".env.example" && ! -f ".env" ]]; then
  cp .env.example .env
  echo "Created .env from .env.example" >&2
fi

mkdir -p harness/docs harness/quality-scripts harness/server-scripts

echo "Environment setup complete." >&2
SETUP_EOF

write_file "$START_SCRIPT" 755 <<'START_EOF'
#!/bin/bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT"

if [[ -f "package.json" ]]; then
  npm run dev || npm run start
  exit 0
fi

if [[ -f "pom.xml" ]]; then
  mvn spring-boot:run
  exit 0
fi

if [[ -f "go.mod" ]]; then
  go run ./...
  exit 0
fi

if [[ -f "pyproject.toml" || -f "requirements.txt" ]]; then
  if command -v uv >/dev/null 2>&1; then
    uv run python -m app || uv run python -m main
  else
    python -m app || python -m main
  fi
  exit 0
fi

echo "No known startup command detected." >&2
exit 1
START_EOF

ARCH_BACKEND_LINE="(omitted: backend not detected)"
ARCH_FRONTEND_LINE="(omitted: frontend not detected)"
if [[ "$HAS_BACKEND" -eq 1 ]]; then
  ARCH_BACKEND_LINE="harness/docs/backend-architecture.md"
fi
if [[ "$HAS_FRONTEND" -eq 1 ]]; then
  ARCH_FRONTEND_LINE="harness/docs/frontend-architecture.md"
fi

generate_map() {
  cat <<MAP_EOF
# Agent Navigation Map

## Project Overview (Line 1-10)
Project positioning: this repository is maintained with a harness-first workflow for AI-assisted engineering.
Primary stack (detected): ${STACK_LIST}.
Repository organization: source modules at project root, harness artifacts under harness/.
Harness scope: docs, quality scripts, and server scripts for repeatable local operations.
This file is a map, not a manual; details are delegated to linked docs.
Repository change strategy: prefer small, verifiable changes and script-first automation.
Execution baseline: all local workflows should be runnable from repository root.

## Quick Commands (Line 11-25)
Build: use project-native build command (for example npm run build / mvn -B package / go build ./... / python -m build).
Run: harness/server-scripts/start-server.sh.
Test: harness/quality-scripts/unit-test-coverage.sh.
Format: use project-native formatter command (for example npm run format / ruff format / gofmt / spotless).
Quality check: harness/quality-scripts/lint-quality.${QUALITY_EXT}.
Environment setup: harness/server-scripts/setup-env.sh.
Env var precedence: CLI flags > shell exported vars > .env > .env.example defaults.
Artifact output: write coverage and reports into repository-visible paths.
Failure rule: any quality script non-zero exit should block merge.

## Backend Architecture (Line 26-45)
Backend section is conditional.
Backend detected: ${HAS_BACKEND}.
Reference doc: ${ARCH_BACKEND_LINE}
ASCII package tree placeholder:
backend/
  handlers/
  service/
  repository/
  model/
Purpose rules: handlers orchestrate IO, service owns business logic, repository owns persistence.
Subsystem summary placeholder: auth, config, observability, integration boundaries.
Integration rule: external service clients stay in infrastructure boundary only.
Persistence rule: avoid leaking DB schema concerns into application boundary.

## Frontend Architecture (Line 46-60)
Frontend section is conditional.
Frontend detected: ${HAS_FRONTEND}.
Reference doc: ${ARCH_FRONTEND_LINE}
Tech stack placeholder: framework + router + state + build tool.
Routing convention: central router config with feature-sliced route modules.
API layer convention: all remote calls go through typed client wrappers.
Component standards: container/presentational split and shared design tokens.
State rule: keep server-state and ui-state separated.
UI resilience rule: loading/error/empty states must be explicit.

## Key Conventions (Line 61-75)
Exception handling: convert internal exceptions to stable external errors with correlation IDs.
Response conventions: keep response shape consistent and versioned.
Layering rule: UI -> application -> domain -> infrastructure; no reverse dependencies.
Code style: follow language-specific repository coding standards.
Security baseline: input validation, authn/authz checks, secrets from env only.
Detailed docs: harness/docs/conventions-exceptions.md, harness/docs/conventions-response.md, harness/docs/conventions-layering.md, harness/docs/conventions-style.md, harness/docs/conventions-security.md.
Logging rule: logs should be structured and searchable by request/session ID.
Dependency rule: pin critical tooling versions in CI and local scripts when possible.

## Local Dev + Verification Flow (Line 76-90)
Flow: change code -> build -> start service -> run verification scripts.
API verification: use curl/postman or project API tests against local endpoint.
Token acquisition: use local auth bootstrap flow or test fixture credentials.
Log locations: project runtime logs + test logs + build logs.
Recommended order: setup-env -> start-server -> lint-quality -> unit-test-coverage.
Debug order: reproduce -> isolate -> add test -> fix -> rerun coverage.
Rollback rule: revert only the minimal scope when verification fails.

## Quality Command List (Line 91-100)
Static checks: harness/quality-scripts/lint-quality.${QUALITY_EXT}
Unit and coverage: harness/quality-scripts/unit-test-coverage.sh
Build verification: run project-native build command.
Test verification: run project-native unit tests and inspect coverage artifacts.
Optional extension: add integration/e2e commands under harness/quality-scripts as needed.

## Convention References (Line 101-110)
Priority order when conventions conflict:
1) Security and compliance constraints.
2) Repository-level mandatory conventions.
3) Language-specific style guides.
4) Team-level optional preferences.
Reference sources: project docs, framework official docs, and language standards.
Escalation rule: when uncertainty remains, document the chosen interpretation in harness/docs.

## Documentation Index (Line 111-120)
Architecture docs: harness/docs/backend-architecture.md, harness/docs/frontend-architecture.md.
Design docs: harness/docs/design-*.md.
References: harness/docs/references-*.md.
Runbooks: harness/docs/runbook-*.md.
Quality docs: harness/docs/quality-*.md.
Operational notes: harness/docs/ops-*.md.
Decision logs: harness/docs/adr-*.md.
MAP_EOF
}

if [[ ! -f "$AGENTS_FILE" || "$FORCE" -eq 1 ]]; then
  generate_map > "$AGENTS_FILE"
  chmod 644 "$AGENTS_FILE"
else
  echo "Skip existing: $AGENTS_FILE (use --force to overwrite)" >&2
fi

if [[ ! -f "$CLAUDE_FILE" || "$FORCE" -eq 1 ]]; then
  cp "$AGENTS_FILE" "$CLAUDE_FILE"
  chmod 644 "$CLAUDE_FILE"
else
  echo "Skip existing: $CLAUDE_FILE (use --force to overwrite)" >&2
fi

printf '{"status":"ok","target":"%s","stack":"%s","gitnexus_skill":"%s"}\n' "$TARGET" "$STACK_LIST" "${GITNEXUS_PATH:-not_found}"
