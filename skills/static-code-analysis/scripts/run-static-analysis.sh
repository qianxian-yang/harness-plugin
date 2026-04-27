#!/bin/bash
set -e

QUALITY_ONLY_NOTICE="Security checks are intentionally excluded: no secret scanning, dependency vulnerability scanning, SAST, license scanning, or audit commands were run."
MAX_FINDINGS=50
MAX_OUTPUT_CHARS=200000
INSTALL_TIMEOUT=300
NO_INSTALL_PYTHON_TOOLS=0
FAIL_ON_HIGH=0
PROJECT_DIR="."
OUTPUT_PATH=""

usage() {
  echo "Usage: run-static-analysis.sh [project-dir] [--output path] [--no-install-python-tools] [--fail-on-high]" >&2
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --output)
      shift
      OUTPUT_PATH="${1:-}"
      ;;
    --timeout)
      shift
      # Accepted for compatibility. Commands run without a shell-level timeout.
      ;;
    --install-timeout)
      shift
      INSTALL_TIMEOUT="${1:-300}"
      ;;
    --max-findings)
      shift
      MAX_FINDINGS="${1:-50}"
      ;;
    --max-output-chars)
      shift
      MAX_OUTPUT_CHARS="${1:-200000}"
      ;;
    --no-install-python-tools)
      NO_INSTALL_PYTHON_TOOLS=1
      ;;
    --fail-on-high)
      FAIL_ON_HIGH=1
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    -*)
      echo "Unknown option: $1" >&2
      usage
      exit 2
      ;;
    *)
      PROJECT_DIR="$1"
      ;;
  esac
  shift
done

if [ ! -d "$PROJECT_DIR" ]; then
  printf '{"ok":false,"error":"project_dir not found: %s"}\n' "$PROJECT_DIR"
  exit 2
fi

ROOT="$(cd "$PROJECT_DIR" && pwd -P)"
HARNESS_DIR="$ROOT/harness/static-analysis"
RAW_DIR="$HARNESS_DIR/raw"
TOOLS_FILE="$HARNESS_DIR/tools.tsv"
TOOL_STATS_FILE="$HARNESS_DIR/tool-stats.tsv"
TOOL_ROWS_FILE="$HARNESS_DIR/tool-rows.html"
FINDINGS_FILE="$HARNESS_DIR/findings.html"
FINDINGS_DATA_FILE="$HARNESS_DIR/findings.tsv"
SUMMARY_FILE="$HARNESS_DIR/summary.html"
RAW_SECTIONS_FILE="$HARNESS_DIR/raw-sections.html"
SKIPPED_FILE="$HARNESS_DIR/skipped.txt"
DEPENDENCY_NOTES_RUNTIME="$HARNESS_DIR/dependency-runtime-notes.txt"
REQUIREMENTS_PATH="$HARNESS_DIR/requirements.txt"
DEPENDENCY_NOTES_PATH="$HARNESS_DIR/dependency-notes.md"
BACKEND_STACK="none"
HAS_FRONTEND_STACK=0
STACK_PROFILE="unknown"

mkdir -p "$HARNESS_DIR" "$RAW_DIR"
: > "$TOOLS_FILE"
: > "$TOOL_STATS_FILE"
: > "$TOOL_ROWS_FILE"
: > "$FINDINGS_FILE"
: > "$FINDINGS_DATA_FILE"
: > "$SUMMARY_FILE"
: > "$RAW_SECTIONS_FILE"
: > "$SKIPPED_FILE"
: > "$DEPENDENCY_NOTES_RUNTIME"

if [ -n "$OUTPUT_PATH" ]; then
  case "$OUTPUT_PATH" in
    /*) REPORT_PATH="$OUTPUT_PATH" ;;
    *) REPORT_PATH="$HARNESS_DIR/$OUTPUT_PATH" ;;
  esac
else
  REPORT_PATH="$ROOT/harness/static-analysis-report.html"
fi
mkdir -p "$(dirname "$REPORT_PATH")"

log() {
  echo "$1" >&2
}

html_escape() {
  sed -e 's/&/\&amp;/g' -e 's/</\&lt;/g' -e 's/>/\&gt;/g' -e 's/"/\&quot;/g'
}

json_escape() {
  sed -e 's/\\/\\\\/g' -e 's/"/\\"/g'
}

slugify() {
  echo "$1" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/-/g; s/^-//; s/-$//'
}

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

has_python_files() {
  find "$ROOT" \
    \( -name .git -o -name node_modules -o -name .venv -o -name venv -o -name target -o -name build -o -name dist -o -name __pycache__ -o -path "$ROOT/harness" \) -prune \
    -o -type f -name '*.py' -print -quit | grep -q .
}

has_python_requirements() {
  find "$ROOT" \
    \( -name .git -o -name node_modules -o -name .venv -o -name venv -o -name target -o -name build -o -name dist -o -name __pycache__ -o -path "$ROOT/harness" \) -prune \
    -o -type f -name 'requirements*.txt' -print -quit | grep -q .
}

has_file() {
  [ -f "$ROOT/$1" ]
}

has_config_text() {
  marker="$1"
  shift
  for file_name in "$@"; do
    if [ -f "$ROOT/$file_name" ] && grep -qi "$marker" "$ROOT/$file_name"; then
      return 0
    fi
  done
  return 1
}

venv_bin() {
  venv_dir="$1"
  bin_name="$2"
  if [ -x "$venv_dir/bin/$bin_name" ]; then
    echo "$venv_dir/bin/$bin_name"
    return 0
  fi
  if [ -x "$venv_dir/Scripts/$bin_name.exe" ]; then
    echo "$venv_dir/Scripts/$bin_name.exe"
    return 0
  fi
  return 1
}

python_tool() {
  bin_name="$1"
  venv_bin "$ROOT/.venv" "$bin_name" && return 0
  venv_bin "$ROOT/venv" "$bin_name" && return 0
  venv_bin "$HARNESS_DIR/.venv" "$bin_name" && return 0
  command -v "$bin_name" 2>/dev/null && return 0
  return 1
}

package_script_body() {
  script_name="$1"
  if [ ! -f "$ROOT/package.json" ]; then
    return 1
  fi
  tr '\n' ' ' < "$ROOT/package.json" \
    | sed -E "s/(\"$script_name\"[[:space:]]*:[[:space:]]*\")/\\
\1/g" \
    | sed -nE "s/^[[:space:]]*\"$script_name\"[[:space:]]*:[[:space:]]*\"([^\"]*)\".*$/\1/p" \
    | head -n 1
}

package_script_exists() {
  [ -n "$(package_script_body "$1")" ]
}

forbidden_script() {
  echo "$1" | grep -Eiq '(^|[^[:alnum:]_-])(npm[[:space:]]+audit|yarn[[:space:]]+audit|pnpm[[:space:]]+audit|audit|semgrep|bandit|gitleaks|trufflehog|snyk|osv|codeql|dependency-check|dependabot|license|secret|security)([^[:alnum:]_-]|$)'
}

add_skipped() {
  echo "$1" >> "$SKIPPED_FILE"
}

add_dependency_note() {
  echo "$1" >> "$DEPENDENCY_NOTES_RUNTIME"
}

add_tool() {
  name="$1"
  fail_on_output="$2"
  reason="$3"
  shift 3
  printf '%s\t%s\t%s\t%s\n' "$name" "$fail_on_output" "$reason" "$*" >> "$TOOLS_FILE"
}

project_package_manager() {
  if [ -f "$ROOT/pnpm-lock.yaml" ] && command_exists pnpm; then
    echo "pnpm run"
  elif [ -f "$ROOT/yarn.lock" ] && command_exists yarn; then
    echo "yarn run"
  elif command_exists npm; then
    echo "npm run"
  else
    return 1
  fi
}

has_frontend_markers() {
  [ -f "$ROOT/package.json" ]
}

has_go_markers() {
  [ -f "$ROOT/go.mod" ]
}

has_java_markers() {
  [ -f "$ROOT/pom.xml" ]
}

detect_java_major() {
  local version_line
  local version_token
  local major

  if ! command_exists java; then
    return 1
  fi

  version_line="$(java -version 2>&1 | head -n 1)"
  version_token="$(printf '%s' "$version_line" | sed -nE 's/.*version "([^"]+)".*/\1/p')"
  if [ -z "$version_token" ]; then
    version_token="$(printf '%s' "$version_line" | sed -nE 's/.*openjdk ([0-9][^ ]*).*/\1/p')"
  fi
  if [ -z "$version_token" ]; then
    return 1
  fi

  if echo "$version_token" | grep -Eq '^1\.[0-9]+'; then
    major="$(printf '%s' "$version_token" | sed -E 's/^1\.([0-9]+).*/\1/')"
  else
    major="$(printf '%s' "$version_token" | sed -E 's/^([0-9]+).*/\1/')"
  fi

  if echo "$major" | grep -Eq '^[0-9]+$'; then
    echo "$major"
    return 0
  fi
  return 1
}

determine_stack_profile() {
  BACKEND_STACK="none"
  HAS_FRONTEND_STACK=0
  STACK_PROFILE="unknown"

  if has_frontend_markers; then
    HAS_FRONTEND_STACK=1
  fi

  if has_java_markers; then
    BACKEND_STACK="java"
  elif has_go_markers; then
    BACKEND_STACK="go"
  elif has_python_requirements; then
    BACKEND_STACK="python"
  fi

  if [ "$BACKEND_STACK" != "none" ] && [ "$HAS_FRONTEND_STACK" -eq 1 ]; then
    STACK_PROFILE="$BACKEND_STACK+frontend"
  elif [ "$BACKEND_STACK" != "none" ]; then
    STACK_PROFILE="$BACKEND_STACK"
  elif [ "$HAS_FRONTEND_STACK" -eq 1 ]; then
    STACK_PROFILE="nodejs+frontend"
  fi
}

prepare_python_dependencies() {
  if [ "$BACKEND_STACK" != "python" ]; then
    return 0
  fi
  if ! has_python_requirements; then
    return 0
  fi

  requirements_tmp="$HARNESS_DIR/requirements.tmp"
  : > "$requirements_tmp"

  if ! python_tool ruff >/dev/null; then
    echo "ruff" >> "$requirements_tmp"
    add_dependency_note "\`ruff\`: Python backend detected by requirements, but Ruff is not available."
  fi
  if ! python_tool mypy >/dev/null; then
    echo "mypy" >> "$requirements_tmp"
    add_dependency_note "\`mypy\`: Python backend detected by requirements, but mypy is not available."
  fi
  if { has_file ".pylintrc" || has_config_text pylint pyproject.toml setup.cfg tox.ini; } && ! python_tool pylint >/dev/null; then
    echo "pylint" >> "$requirements_tmp"
    add_dependency_note "\`pylint\`: Pylint config found, but pylint is not available."
  fi
  if { has_file "pyrightconfig.json" || has_config_text pyright pyproject.toml; } && ! python_tool pyright >/dev/null; then
    echo "pyright" >> "$requirements_tmp"
    add_dependency_note "\`pyright\`: Pyright config found, but pyright is not available."
  fi

  if [ ! -s "$requirements_tmp" ]; then
    return 0
  fi

  {
    echo "# Generated by static-code-analysis for quality-only Python tools."
    echo "# Installed into harness/static-analysis/.venv by run-static-analysis.sh."
    sort -u "$requirements_tmp"
  } > "$REQUIREMENTS_PATH"

  if [ "$NO_INSTALL_PYTHON_TOOLS" -eq 1 ]; then
    add_dependency_note "Python tool installation was disabled for this run."
    write_dependency_notes
    return 0
  fi

  if ! command_exists python3; then
    add_dependency_note "python3 is not available, so harness/static-analysis/.venv could not be created."
    write_dependency_notes
    return 0
  fi

  venv_python="$(venv_bin "$HARNESS_DIR/.venv" python || true)"
  if [ -z "$venv_python" ]; then
    log "Creating static-analysis virtualenv: $HARNESS_DIR/.venv"
    if ! python3 -m venv "$HARNESS_DIR/.venv" > "$HARNESS_DIR/venv-create.log" 2>&1; then
      add_dependency_note "Creating harness/static-analysis/.venv failed. See $HARNESS_DIR/venv-create.log."
      write_dependency_notes
      return 0
    fi
    venv_python="$(venv_bin "$HARNESS_DIR/.venv" python || true)"
  fi

  if [ -z "$venv_python" ]; then
    add_dependency_note "Created harness/static-analysis/.venv, but its python executable was not found."
    write_dependency_notes
    return 0
  fi

  log "Installing Python static-analysis tools from $REQUIREMENTS_PATH"
  if "$venv_python" -m pip install -r "$REQUIREMENTS_PATH" > "$HARNESS_DIR/pip-install.log" 2>&1; then
    add_dependency_note "Installed Python static-analysis tools into \`$HARNESS_DIR/.venv\`."
  else
    add_dependency_note "Installing Python static-analysis tools failed. See $HARNESS_DIR/pip-install.log."
  fi
  write_dependency_notes
}

write_dependency_notes() {
  if [ ! -f "$REQUIREMENTS_PATH" ] && [ ! -s "$DEPENDENCY_NOTES_RUNTIME" ]; then
    return 0
  fi
  {
    echo "# Static Analysis Dependencies"
    echo
    echo "These dependencies are quality-only Python static analysis tools."
    echo "Security, secret scanning, dependency vulnerability, SAST, license, and audit tools are intentionally excluded."
    if [ -f "$REQUIREMENTS_PATH" ]; then
      echo
      echo "## Requirements"
      echo
      echo "\`$REQUIREMENTS_PATH\`"
    fi
    if [ -s "$DEPENDENCY_NOTES_RUNTIME" ]; then
      echo
      echo "## Notes"
      echo
      sed 's/^/- /' "$DEPENDENCY_NOTES_RUNTIME"
    fi
    echo
    echo "## Virtual environment"
    echo
    echo "The script installs Python quality tools into \`harness/static-analysis/.venv\` using that virtual environment's pip."
  } > "$DEPENDENCY_NOTES_PATH"
}

discover_tools() {
  if [ "$HAS_FRONTEND_STACK" -eq 1 ]; then
    if pm="$(project_package_manager)"; then
      for script_name in lint typecheck type-check check:types format:check prettier:check stylelint; do
        if package_script_exists "$script_name"; then
          body="$(package_script_body "$script_name")"
          if forbidden_script "$body"; then
            add_skipped "package script '$script_name' skipped because it appears to include security/audit scanning"
          else
            add_tool "Node $script_name" 0 "stack profile includes frontend; package $script_name script" $pm "$script_name"
          fi
        fi
      done
    else
      add_skipped "Frontend stack detected (package.json found), but no npm/yarn/pnpm command is available"
    fi

    if [ -x "$ROOT/node_modules/.bin/tsc" ] && [ -f "$ROOT/tsconfig.json" ]; then
      if ! grep -q '^Node type' "$TOOLS_FILE" && ! grep -q '^Node check:types' "$TOOLS_FILE"; then
        add_tool "TypeScript compiler" 0 "stack profile includes frontend; local tsc with tsconfig.json" "$ROOT/node_modules/.bin/tsc" --noEmit
      fi
    fi

    eslint_config_found=0
    for config in .eslintrc .eslintrc.js .eslintrc.cjs .eslintrc.json eslint.config.js eslint.config.mjs eslint.config.cjs; do
      [ -f "$ROOT/$config" ] && eslint_config_found=1
    done
    if [ "$eslint_config_found" -eq 1 ] && [ -x "$ROOT/node_modules/.bin/eslint" ] && ! grep -q '^Node lint' "$TOOLS_FILE"; then
      add_tool "ESLint" 0 "stack profile includes frontend; local eslint config" "$ROOT/node_modules/.bin/eslint" .
    fi

    stylelint_config_found=0
    for config in .stylelintrc .stylelintrc.json .stylelintrc.js stylelint.config.js stylelint.config.cjs; do
      [ -f "$ROOT/$config" ] && stylelint_config_found=1
    done
    if [ "$stylelint_config_found" -eq 1 ] && [ -x "$ROOT/node_modules/.bin/stylelint" ]; then
      add_tool "Stylelint" 0 "stack profile includes frontend; local stylelint config" "$ROOT/node_modules/.bin/stylelint" '**/*.{css,scss,less}'
    fi
  fi

  case "$BACKEND_STACK" in
    java)
      java_major=""
      spotbugs_version="4.9.8.3"
      if has_python_requirements; then
        add_skipped "requirements*.txt detected, but backend stack is Java (pom.xml present)."
      elif has_python_files; then
        add_skipped "Python files detected without requirements*.txt; treated as scripts while backend stack is Java."
      fi
      if has_go_markers; then
        add_skipped "go.mod detected, but backend stack is Java (pom.xml present)."
      fi
      if command_exists mvn; then
        add_tool "Maven Build (skip tests)" 0 "backend stack java; required pre-step before SpotBugs" mvn -B clean install -DskipTests -U

        java_major="$(detect_java_major || true)"
        if [ -n "$java_major" ] && [ "$java_major" -le 8 ]; then
          spotbugs_version="4.7.3.6"
        fi
        if [ -z "$java_major" ]; then
          add_skipped "Could not detect Java major version; defaulting SpotBugs plugin to 4.9.8.3 (>8 path)."
          add_tool "Maven SpotBugs" 0 "backend stack java; java version unknown, default SpotBugs 4.9.8.3" mvn com.github.spotbugs:spotbugs-maven-plugin:4.9.8.3:spotbugs
        else
          add_tool "Maven SpotBugs" 0 "backend stack java; java $java_major uses SpotBugs $spotbugs_version" mvn com.github.spotbugs:spotbugs-maven-plugin:$spotbugs_version:spotbugs
        fi
      else
        add_skipped "Backend stack is Java (pom.xml found), but mvn is not available"
      fi
      ;;
    python)
      if has_go_markers; then
        add_skipped "go.mod detected, but backend stack is Python."
      fi
      if ruff_path="$(python_tool ruff)"; then
        add_tool "Ruff" 0 "backend stack python; ruff available" "$ruff_path" check .
      else
        add_skipped "Backend stack is Python, but Ruff is not available"
      fi
      if mypy_path="$(python_tool mypy)"; then
        add_tool "mypy" 0 "backend stack python; mypy required for Python static analysis" "$mypy_path" .
      else
        add_skipped "Backend stack is Python, but mypy is not available"
      fi
      if { has_file ".pylintrc" || has_config_text pylint pyproject.toml setup.cfg tox.ini; } && pylint_path="$(python_tool pylint)"; then
        add_tool "Pylint" 0 "backend stack python; pylint config found" "$pylint_path" .
      fi
      if { has_file "pyrightconfig.json" || has_config_text pyright pyproject.toml; } && pyright_path="$(python_tool pyright)"; then
        add_tool "Pyright" 0 "backend stack python; pyright config found" "$pyright_path"
      fi
      ;;
    go)
      if has_python_requirements; then
        add_skipped "requirements*.txt detected, but backend stack is Go (go.mod present)."
      elif has_python_files; then
        add_skipped "Python files detected without requirements*.txt; treated as scripts while backend stack is Go."
      fi
      if command_exists gofmt; then
        add_tool "gofmt" 1 "backend stack go; formatting check" gofmt -l .
      fi
      if command_exists go; then
        add_tool "go vet" 0 "backend stack go; vet quality analysis" go vet ./...
      else
        add_skipped "Backend stack is Go (go.mod found), but go is not available"
      fi
      if command_exists staticcheck; then
        add_tool "Staticcheck" 0 "backend stack go; staticcheck available" staticcheck ./...
      fi
      ;;
    *)
      if [ "$HAS_FRONTEND_STACK" -eq 0 ]; then
        add_skipped "No supported stack marker detected (expected pom.xml, go.mod, requirements*.txt, or package.json)."
      fi
      if has_python_files && ! has_python_requirements; then
        add_skipped "Python files detected without requirements*.txt; treated as scripts, not a Python backend project."
      fi
      ;;
  esac
}

truncate_output() {
  file_path="$1"
  if [ -f "$file_path" ]; then
    size="$(wc -c < "$file_path" | tr -d ' ')"
    if [ "$size" -gt "$MAX_OUTPUT_CHARS" ]; then
      head -c "$MAX_OUTPUT_CHARS" "$file_path" > "$file_path.tmp"
      {
        echo
        echo "[output truncated]"
      } >> "$file_path.tmp"
      mv "$file_path.tmp" "$file_path"
    fi
  fi
}

code_excerpt_html() {
  local file_path="$1"
  local line_no="$2"
  local start
  local end
  if [ ! -f "$ROOT/$file_path" ]; then
    echo '<p class="muted">Code excerpt unavailable.</p>'
    return
  fi
  start=$((line_no - 2))
  end=$((line_no + 2))
  [ "$start" -lt 1 ] && start=1
  awk -v start="$start" -v end="$end" -v mark="$line_no" '
    NR >= start && NR <= end {
      gsub("&", "\\&amp;"); gsub("<", "\\&lt;"); gsub(">", "\\&gt;"); gsub("\"", "\\&quot;");
      cls = (NR == mark ? " mark" : "");
      printf "<div class=\"code-line%s\"><span>%d</span><code>%s</code></div>\n", cls, NR, $0;
    }
  ' "$ROOT/$file_path"
}

suggestion_for() {
  local tool_name
  tool_name="$(echo "$1" | tr '[:upper:]' '[:lower:]')"
  case "$tool_name" in
    *typescript*|*mypy*|*pyright*|*"go vet"*)
      echo "Fix the type or compile-time contract at this location, then rerun the same static check."
      ;;
    *fmt*|*format*|*prettier*|*gofmt*)
      echo "Apply the repository formatter for this file and verify the formatting check passes."
      ;;
    *spotbugs*)
      echo "Fix the Java quality rule violation reported by SpotBugs, then rerun the Maven SpotBugs goal."
      ;;
    *)
      echo "Fix the reported quality error at this location and rerun the failing tool."
      ;;
  esac
}

append_finding() {
  local tool_id="$1"
  local tool_name="$2"
  local file_path="$3"
  local line_no="$4"
  local col_no="$5"
  local message="$6"
  local suggestion
  local message_clean
  local suggestion_clean
  local tool_name_clean
  local file_clean

  if [ "$FINDING_COUNT" -ge "$MAX_FINDINGS" ]; then
    return
  fi

  FINDING_COUNT=$((FINDING_COUNT + 1))
  suggestion="$(suggestion_for "$tool_name")"
  tool_name_clean="$(printf '%s' "$tool_name" | tr '\t\r\n' '   ')"
  file_clean="$(printf '%s' "$file_path" | tr '\t\r\n' '   ')"
  message_clean="$(printf '%s' "$message" | tr '\t\r\n' '   ')"
  suggestion_clean="$(printf '%s' "$suggestion" | tr '\t\r\n' '   ')"
  printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
    "$tool_id" "$tool_name_clean" "$file_clean" "$line_no" "$col_no" "$message_clean" "$suggestion_clean" >> "$FINDINGS_DATA_FILE"
}

extract_findings() {
  local tool_id="$1"
  local tool_name="$2"
  local output_file="$3"
  local current_file=""
  local current_message=""
  local line
  local stripped
  local file_path
  local line_no
  local col_no
  local message

  while IFS= read -r line || [ -n "$line" ]; do
    stripped="$(echo "$line" | sed -E 's/^[[:space:]]+//; s/[[:space:]]+$//')"
    if echo "$stripped" | grep -Eq '^[A-Z][A-Z0-9]+([[:space:]]+\[[^]]+\])?[[:space:]]+'; then
      current_message="$stripped"
      continue
    fi
    if echo "$stripped" | grep -Eq '^-->[[:space:]]+[^:]+:[0-9]+:[0-9]+'; then
      file_path="$(echo "$stripped" | sed -E 's/^-->[[:space:]]+([^:]+):([0-9]+):([0-9]+).*$/\1/')"
      line_no="$(echo "$stripped" | sed -E 's/^-->[[:space:]]+([^:]+):([0-9]+):([0-9]+).*$/\2/')"
      col_no="$(echo "$stripped" | sed -E 's/^-->[[:space:]]+([^:]+):([0-9]+):([0-9]+).*$/\3/')"
      message="$current_message"
      [ -z "$message" ] && message="$stripped"
      append_finding "$tool_id" "$tool_name" "$file_path" "$line_no" "$col_no" "$message"
      continue
    fi

    if echo "$stripped" | grep -Eq '\.(ts|tsx|js|jsx|mjs|cjs|css|scss|less|py|java|go|vue|svelte|xml|yaml|yml|json)$' && [ -f "$ROOT/$stripped" ]; then
      current_file="$stripped"
      continue
    fi

    if echo "$stripped" | grep -Eq '^([^[:space:]:\[]+\.(ts|tsx|js|jsx|mjs|cjs|css|scss|less|py|java|go|vue|svelte|xml|yaml|yml|json))\(([0-9]+),([0-9]+)\):[[:space:]]*(.*)$'; then
      file_path="$(echo "$stripped" | sed -E 's/^([^[:space:]:\[]+\.[[:alnum:]]+)\(([0-9]+),([0-9]+)\):[[:space:]]*(.*)$/\1/')"
      line_no="$(echo "$stripped" | sed -E 's/^([^[:space:]:\[]+\.[[:alnum:]]+)\(([0-9]+),([0-9]+)\):[[:space:]]*(.*)$/\2/')"
      col_no="$(echo "$stripped" | sed -E 's/^([^[:space:]:\[]+\.[[:alnum:]]+)\(([0-9]+),([0-9]+)\):[[:space:]]*(.*)$/\3/')"
      message="$(echo "$stripped" | sed -E 's/^([^[:space:]:\[]+\.[[:alnum:]]+)\(([0-9]+),([0-9]+)\):[[:space:]]*(.*)$/\4/')"
      append_finding "$tool_id" "$tool_name" "$file_path" "$line_no" "$col_no" "$message"
      continue
    fi

    if echo "$stripped" | grep -Eq '^(vet:[[:space:]]+)?([^[:space:]:\[]+\.(ts|tsx|js|jsx|mjs|cjs|css|scss|less|py|java|go|vue|svelte|xml|yaml|yml|json)):[0-9]+(:[0-9]+)?:[[:space:]]*(.*)$'; then
      file_path="$(echo "$stripped" | sed -E 's/^(vet:[[:space:]]+)?([^[:space:]:\[]+\.[[:alnum:]]+):([0-9]+)(:([0-9]+))?:[[:space:]]*(.*)$/\2/')"
      line_no="$(echo "$stripped" | sed -E 's/^(vet:[[:space:]]+)?([^[:space:]:\[]+\.[[:alnum:]]+):([0-9]+)(:([0-9]+))?:[[:space:]]*(.*)$/\3/')"
      col_no="$(echo "$stripped" | sed -E 's/^(vet:[[:space:]]+)?([^[:space:]:\[]+\.[[:alnum:]]+):([0-9]+)(:([0-9]+))?:[[:space:]]*(.*)$/\5/')"
      message="$(echo "$stripped" | sed -E 's/^(vet:[[:space:]]+)?([^[:space:]:\[]+\.[[:alnum:]]+):([0-9]+)(:([0-9]+))?:[[:space:]]*(.*)$/\6/')"
      if [ "$tool_name" = "go vet" ] || echo "$message $stripped" | grep -Eiq '\b(error|fatal|failed|failure|TS[0-9]{4}|[EF][0-9]{3,4})\b'; then
        append_finding "$tool_id" "$tool_name" "$file_path" "$line_no" "$col_no" "$message"
      fi
      continue
    fi

    if echo "$stripped" | grep -Eq '^([^[:space:]:\[]+\.(ts|tsx|js|jsx|mjs|cjs|css|scss|less|py|java|go|vue|svelte|xml|yaml|yml|json)):[0-9]+(:[0-9]+)?:[[:space:]]*(.*)$'; then
      file_path="$(echo "$stripped" | sed -E 's/^([^[:space:]:\[]+\.[[:alnum:]]+):([0-9]+)(:([0-9]+))?:[[:space:]]*(.*)$/\1/')"
      line_no="$(echo "$stripped" | sed -E 's/^([^[:space:]:\[]+\.[[:alnum:]]+):([0-9]+)(:([0-9]+))?:[[:space:]]*(.*)$/\2/')"
      col_no="$(echo "$stripped" | sed -E 's/^([^[:space:]:\[]+\.[[:alnum:]]+):([0-9]+)(:([0-9]+))?:[[:space:]]*(.*)$/\4/')"
      message="$(echo "$stripped" | sed -E 's/^([^[:space:]:\[]+\.[[:alnum:]]+):([0-9]+)(:([0-9]+))?:[[:space:]]*(.*)$/\5/')"
      if [ "$tool_name" = "go vet" ] || echo "$message $stripped" | grep -Eiq '\b(error|fatal|failed|failure|TS[0-9]{4}|[EF][0-9]{3,4})\b'; then
        append_finding "$tool_id" "$tool_name" "$file_path" "$line_no" "$col_no" "$message"
      fi
      continue
    fi

    if [ -n "$current_file" ] && echo "$stripped" | grep -Eiq '^[0-9]+:[0-9]+[[:space:]]+error[[:space:]]+'; then
      line_no="$(echo "$stripped" | sed -E 's/^([0-9]+):([0-9]+)[[:space:]]+error[[:space:]]+(.*)$/\1/')"
      col_no="$(echo "$stripped" | sed -E 's/^([0-9]+):([0-9]+)[[:space:]]+error[[:space:]]+(.*)$/\2/')"
      message="$(echo "$stripped" | sed -E 's/^([0-9]+):([0-9]+)[[:space:]]+error[[:space:]]+(.*)$/error \3/')"
      append_finding "$tool_id" "$tool_name" "$current_file" "$line_no" "$col_no" "$message"
    fi
  done < "$output_file"
}

build_summary_html() {
  local tools_with_issues=0
  local tools_without_issues=0
  local has_dependency_notes=0
  local has_skipped_notes=0
  local tool_id
  local tool_name
  local command_text
  local duration
  local issue_count
  local exit_code
  local escaped_tool_name

  : > "$SUMMARY_FILE"

  {
    echo '<div class="panel">'
    echo '  <h3>High-Priority Summary by Tool</h3>'
    echo '  <div class="summary-groups">'
    echo '    <section class="summary-group">'
    echo '      <h4>Tools with high-priority defects</h4>'
    echo '      <ul>'
  } >> "$SUMMARY_FILE"

  while IFS="$(printf '\t')" read -r tool_id tool_name command_text duration issue_count exit_code || [ -n "$tool_id" ]; do
    [ -z "$tool_id" ] && continue
    if [ "${issue_count:-0}" -gt 0 ]; then
      tools_with_issues=$((tools_with_issues + 1))
      escaped_tool_name="$(printf '%s' "$tool_name" | html_escape)"
      echo "        <li><a class=\"issue-link\" href=\"#$tool_id\">$escaped_tool_name</a>: ${issue_count} high-priority defects</li>" >> "$SUMMARY_FILE"
    fi
  done < "$TOOL_STATS_FILE"

  if [ "$tools_with_issues" -eq 0 ]; then
    echo '        <li class="muted">No high-priority defects detected.</li>' >> "$SUMMARY_FILE"
  fi

  {
    echo '      </ul>'
    echo '    </section>'
    echo '    <section class="summary-group">'
    echo '      <h4>Tools without high-priority defects</h4>'
    echo '      <ul>'
  } >> "$SUMMARY_FILE"

  while IFS="$(printf '\t')" read -r tool_id tool_name command_text duration issue_count exit_code || [ -n "$tool_id" ]; do
    [ -z "$tool_id" ] && continue
    if [ "${issue_count:-0}" -eq 0 ]; then
      tools_without_issues=$((tools_without_issues + 1))
      escaped_tool_name="$(printf '%s' "$tool_name" | html_escape)"
      echo "        <li>$escaped_tool_name</li>" >> "$SUMMARY_FILE"
    fi
  done < "$TOOL_STATS_FILE"

  if [ "$tools_without_issues" -eq 0 ]; then
    echo '        <li class="muted">All executed tools reported high-priority defects.</li>' >> "$SUMMARY_FILE"
  fi

  {
    echo '      </ul>'
    echo '    </section>'
    echo '  </div>'
  } >> "$SUMMARY_FILE"

  if [ -f "$REQUIREMENTS_PATH" ] || [ -f "$DEPENDENCY_NOTES_PATH" ] || [ -s "$DEPENDENCY_NOTES_RUNTIME" ]; then
    has_dependency_notes=1
  fi
  if [ -s "$SKIPPED_FILE" ]; then
    has_skipped_notes=1
  fi

  if [ "$has_dependency_notes" -eq 1 ] || [ "$has_skipped_notes" -eq 1 ]; then
    echo '  <details class="context-notes">' >> "$SUMMARY_FILE"
    echo '    <summary>Run Context Notes</summary>' >> "$SUMMARY_FILE"
    echo '    <div class="note-body">' >> "$SUMMARY_FILE"
    if [ "$has_dependency_notes" -eq 1 ]; then
      echo '      <h4>Dependency Preparation</h4>' >> "$SUMMARY_FILE"
      echo '      <ul>' >> "$SUMMARY_FILE"
      [ -f "$REQUIREMENTS_PATH" ] && echo "        <li>Requirements: <code>$(printf '%s' "$REQUIREMENTS_PATH" | html_escape)</code></li>" >> "$SUMMARY_FILE"
      [ -f "$DEPENDENCY_NOTES_PATH" ] && echo "        <li>Notes: <code>$(printf '%s' "$DEPENDENCY_NOTES_PATH" | html_escape)</code></li>" >> "$SUMMARY_FILE"
      while IFS= read -r note || [ -n "$note" ]; do
        [ -n "$note" ] && echo "        <li>$(printf '%s' "$note" | html_escape)</li>" >> "$SUMMARY_FILE"
      done < "$DEPENDENCY_NOTES_RUNTIME"
      echo '      </ul>' >> "$SUMMARY_FILE"
    fi
    if [ "$has_skipped_notes" -eq 1 ]; then
      echo '      <h4>Skipped Detection Notes</h4>' >> "$SUMMARY_FILE"
      echo '      <ul>' >> "$SUMMARY_FILE"
      while IFS= read -r note || [ -n "$note" ]; do
        [ -n "$note" ] && echo "        <li>$(printf '%s' "$note" | html_escape)</li>" >> "$SUMMARY_FILE"
      done < "$SKIPPED_FILE"
      echo '      </ul>' >> "$SUMMARY_FILE"
    fi
    echo '    </div>' >> "$SUMMARY_FILE"
    echo '  </details>' >> "$SUMMARY_FILE"
  fi

  echo '</div>' >> "$SUMMARY_FILE"
}

build_findings_html() {
  local tool_id
  local tool_name
  local command_text
  local duration
  local issue_count
  local exit_code
  local finding_tool_id
  local finding_tool_name
  local file_path
  local line_no
  local col_no
  local message
  local suggestion
  local location
  local escaped_tool
  local escaped_location
  local escaped_message
  local escaped_suggestion
  local shown_tools=0

  : > "$FINDINGS_FILE"

  while IFS="$(printf '\t')" read -r tool_id tool_name command_text duration issue_count exit_code || [ -n "$tool_id" ]; do
    [ -z "$tool_id" ] && continue
    [ "${issue_count:-0}" -le 0 ] && continue
    shown_tools=$((shown_tools + 1))
    escaped_tool="$(printf '%s' "$tool_name" | html_escape)"

    {
      echo "<section class=\"tool-findings\" id=\"$tool_id\">"
      echo "  <h3>$escaped_tool</h3>"
      echo "  <p class=\"muted\">${issue_count} high-priority defects</p>"
    } >> "$FINDINGS_FILE"

    while IFS="$(printf '\t')" read -r finding_tool_id finding_tool_name file_path line_no col_no message suggestion || [ -n "$finding_tool_id" ]; do
      [ -z "$finding_tool_id" ] && continue
      [ "$finding_tool_id" != "$tool_id" ] && continue
      location="$file_path:$line_no"
      if [ -n "$col_no" ]; then
        location="$location:$col_no"
      fi
      escaped_location="$(printf '%s' "$location" | html_escape)"
      escaped_message="$(printf '%s' "$message" | html_escape)"
      escaped_suggestion="$(printf '%s' "$suggestion" | html_escape)"
      {
        echo '  <details class="finding">'
        echo '    <summary>'
        echo "      <strong>$escaped_location</strong>"
        echo "      <span class=\"finding-tool\">$escaped_tool</span>"
        echo '    </summary>'
        echo '    <div class="finding-body">'
        echo "      <p class=\"message\">$escaped_message</p>"
        echo "      <p><strong>Suggested fix:</strong> $escaped_suggestion</p>"
        echo '      <div class="code">'
        code_excerpt_html "$file_path" "$line_no"
        echo '      </div>'
        echo '    </div>'
        echo '  </details>'
      } >> "$FINDINGS_FILE"
    done < "$FINDINGS_DATA_FILE"

    echo '</section>' >> "$FINDINGS_FILE"
  done < "$TOOL_STATS_FILE"

  if [ "$shown_tools" -eq 0 ]; then
    echo '<p class="empty">No high-priority quality defects were detected.</p>' > "$FINDINGS_FILE"
  fi
}

issue_card_html() {
  local destination_file="$1"
  local tool_name="$2"
  local file_path="$3"
  local line_no="$4"
  local col_no="$5"
  local rule="$6"
  local description="$7"
  local location
  local escaped_tool
  local escaped_location
  local escaped_rule
  local escaped_description

  location="$file_path:$line_no"
  [ -n "$col_no" ] && location="$location:$col_no"
  escaped_tool="$(printf '%s' "$tool_name" | html_escape)"
  escaped_location="$(printf '%s' "$location" | html_escape)"
  escaped_rule="$(printf '%s' "$rule" | html_escape)"
  escaped_description="$(printf '%s' "$description" | html_escape)"

  {
    echo '<section class="issue-card">'
    echo '  <div class="issue-meta">'
    echo "    <span class=\"issue-tool\">$escaped_tool</span>"
    echo "    <code>$escaped_location</code>"
    [ -n "$rule" ] && echo "    <span class=\"issue-rule\">$escaped_rule</span>"
    echo '  </div>'
    echo "  <p class=\"issue-desc\">$escaped_description</p>"
    echo '  <div class="issue-code">'
    code_excerpt_html "$file_path" "$line_no"
    echo '  </div>'
    echo '</section>'
  } >> "$destination_file"
}

build_parsed_output() {
  local tool_name="$1"
  local raw_output_file="$2"
  local parsed_output_file="$3"
  local current_rule=""
  local current_desc=""
  local line
  local stripped
  local file_path
  local line_no
  local col_no
  local description
  local rule

  : > "$parsed_output_file"

  while IFS= read -r line || [ -n "$line" ]; do
    stripped="$(echo "$line" | sed -E 's/^[[:space:]]+//; s/[[:space:]]+$//')"

    if echo "$stripped" | grep -Eq '^[A-Z][A-Z0-9]+([[:space:]]+\[[^]]+\])?[[:space:]]+'; then
      current_rule="$(echo "$stripped" | sed -E 's/^([A-Z][A-Z0-9]+)([[:space:]]+\[[^]]+\])?[[:space:]]+.*$/\1/')"
      current_desc="$(echo "$stripped" | sed -E 's/^[A-Z][A-Z0-9]+([[:space:]]+\[[^]]+\])?[[:space:]]+//')"
      continue
    fi

    if echo "$stripped" | grep -Eq '^-->[[:space:]]+[^:]+:[0-9]+:[0-9]+'; then
      file_path="$(echo "$stripped" | sed -E 's/^-->[[:space:]]+([^:]+):([0-9]+):([0-9]+).*$/\1/')"
      line_no="$(echo "$stripped" | sed -E 's/^-->[[:space:]]+([^:]+):([0-9]+):([0-9]+).*$/\2/')"
      col_no="$(echo "$stripped" | sed -E 's/^-->[[:space:]]+([^:]+):([0-9]+):([0-9]+).*$/\3/')"
      description="$current_desc"
      [ -z "$description" ] && description="$stripped"
      issue_card_html "$parsed_output_file" "$tool_name" "$file_path" "$line_no" "$col_no" "$current_rule" "$description"
      continue
    fi

    if echo "$stripped" | grep -Eq '^([^[:space:]:\[]+\.(ts|tsx|js|jsx|mjs|cjs|css|scss|less|py|java|go|vue|svelte|xml|yaml|yml|json)):[0-9]+(:[0-9]+)?:[[:space:]]*(.*)$'; then
      file_path="$(echo "$stripped" | sed -E 's/^([^[:space:]:\[]+\.[[:alnum:]]+):([0-9]+)(:([0-9]+))?:[[:space:]]*(.*)$/\1/')"
      line_no="$(echo "$stripped" | sed -E 's/^([^[:space:]:\[]+\.[[:alnum:]]+):([0-9]+)(:([0-9]+))?:[[:space:]]*(.*)$/\2/')"
      col_no="$(echo "$stripped" | sed -E 's/^([^[:space:]:\[]+\.[[:alnum:]]+):([0-9]+)(:([0-9]+))?:[[:space:]]*(.*)$/\4/')"
      description="$(echo "$stripped" | sed -E 's/^([^[:space:]:\[]+\.[[:alnum:]]+):([0-9]+)(:([0-9]+))?:[[:space:]]*(.*)$/\5/')"
      rule="$(echo "$description" | sed -nE 's/.*\[([^]]+)\].*/\1/p')"
      issue_card_html "$parsed_output_file" "$tool_name" "$file_path" "$line_no" "$col_no" "$rule" "$description"
      continue
    fi

    if echo "$stripped" | grep -Eq '^(vet:[[:space:]]+)?([^[:space:]:\[]+\.(ts|tsx|js|jsx|mjs|cjs|css|scss|less|py|java|go|vue|svelte|xml|yaml|yml|json)):[0-9]+(:[0-9]+)?:[[:space:]]*(.*)$'; then
      file_path="$(echo "$stripped" | sed -E 's/^(vet:[[:space:]]+)?([^[:space:]:\[]+\.[[:alnum:]]+):([0-9]+)(:([0-9]+))?:[[:space:]]*(.*)$/\2/')"
      line_no="$(echo "$stripped" | sed -E 's/^(vet:[[:space:]]+)?([^[:space:]:\[]+\.[[:alnum:]]+):([0-9]+)(:([0-9]+))?:[[:space:]]*(.*)$/\3/')"
      col_no="$(echo "$stripped" | sed -E 's/^(vet:[[:space:]]+)?([^[:space:]:\[]+\.[[:alnum:]]+):([0-9]+)(:([0-9]+))?:[[:space:]]*(.*)$/\5/')"
      description="$(echo "$stripped" | sed -E 's/^(vet:[[:space:]]+)?([^[:space:]:\[]+\.[[:alnum:]]+):([0-9]+)(:([0-9]+))?:[[:space:]]*(.*)$/\6/')"
      rule="$(echo "$description" | sed -nE 's/.*\[([^]]+)\].*/\1/p')"
      issue_card_html "$parsed_output_file" "$tool_name" "$file_path" "$line_no" "$col_no" "$rule" "$description"
    fi
  done < "$raw_output_file"
}

run_tools() {
  TOOLS_RUN=0
  FAILED_TOOLS=0
  FINDING_COUNT=0

  while IFS="$(printf '\t')" read -r name fail_on_output reason command_text || [ -n "$name" ]; do
    [ -z "$name" ] && continue
    TOOLS_RUN=$((TOOLS_RUN + 1))
    tool_id="tool-$TOOLS_RUN-$(slugify "$name")"
    slug="$(slugify "$name-$TOOLS_RUN")"
    output_file="$RAW_DIR/$slug.txt"
    parsed_output_file="$RAW_DIR/$slug-parsed.html"
    findings_before="$FINDING_COUNT"
    log "Running $name: $command_text"
    start_time="$(date +%s)"
    set +e
    (cd "$ROOT" && sh -c "$command_text") > "$output_file" 2>&1
    exit_code=$?
    set -e
    if [ "$fail_on_output" = "1" ] && [ -s "$output_file" ] && [ "$exit_code" -eq 0 ]; then
      exit_code=1
    fi
    end_time="$(date +%s)"
    duration=$((end_time - start_time))
    truncate_output "$output_file"
    if [ "$exit_code" -eq 0 ]; then
      :
    else
      FAILED_TOOLS=$((FAILED_TOOLS + 1))
      extract_findings "$tool_id" "$name" "$output_file"
    fi
    build_parsed_output "$name" "$output_file" "$parsed_output_file"
    tool_issues=$((FINDING_COUNT - findings_before))
    if [ "$tool_issues" -gt 0 ]; then
      issues_html="<a class=\"issue-link\" href=\"#$tool_id\">$tool_issues</a>"
    else
      issues_html="0"
    fi

    escaped_name="$(printf '%s' "$name" | html_escape)"
    escaped_command="$(printf '%s' "$command_text" | html_escape)"
    {
      echo '<tr>'
      echo "<td>$escaped_name</td><td><code>$escaped_command</code></td><td>${duration}s</td><td>$issues_html</td>"
      echo '</tr>'
    } >> "$TOOL_ROWS_FILE"
    printf '%s\t%s\t%s\t%s\t%s\t%s\n' \
      "$tool_id" \
      "$(printf '%s' "$name" | tr '\t\r\n' '   ')" \
      "$(printf '%s' "$command_text" | tr '\t\r\n' '   ')" \
      "$duration" \
      "$tool_issues" \
      "$exit_code" >> "$TOOL_STATS_FILE"

    escaped_output="$(html_escape < "$output_file")"
    {
      echo '<details>'
      echo "<summary>$escaped_name output</summary>"
      if [ -s "$parsed_output_file" ]; then
        echo '<div class="parsed-output">'
        echo '<div class="raw-label">Parsed issues</div>'
        cat "$parsed_output_file"
        echo '</div>'
      fi
      echo '<div class="raw-label">Raw output</div>'
      echo "<pre class=\"raw-pre\">$escaped_output</pre>"
      echo '</details>'
    } >> "$RAW_SECTIONS_FILE"
  done < "$TOOLS_FILE"
}

render_report() {
  generated="$(date '+%Y-%m-%d %H:%M:%S %Z')"
  {
    cat <<HTML
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Static Code Analysis Report</title>
  <style>
    :root { color-scheme: light; --bg: #f7f8fa; --panel: #ffffff; --text: #20242a; --muted: #5d6675; --border: #d9dee7; --pass: #0f7b45; --fail: #b42318; --accent: #2457c5; --code: #f1f4f8; }
    * { box-sizing: border-box; }
    body { margin: 0; background: var(--bg); color: var(--text); font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif; line-height: 1.5; }
    main { max-width: 1180px; margin: 0 auto; padding: 32px 24px 48px; }
    h1, h2, h3, h4 { margin: 0 0 12px; }
    h1 { font-size: 30px; }
    h2 { font-size: 20px; margin-top: 28px; }
    h3 { font-size: 17px; margin-top: 0; }
    h4 { font-size: 14px; margin-top: 0; color: var(--muted); }
    .meta, .notice, .panel, details { background: var(--panel); border: 1px solid var(--border); border-radius: 8px; padding: 16px; margin-top: 14px; }
    .notice { border-left: 4px solid var(--accent); }
    .summary { display: grid; grid-template-columns: repeat(auto-fit, minmax(180px, 1fr)); gap: 12px; margin-top: 18px; }
    .metric { background: var(--panel); border: 1px solid var(--border); border-radius: 8px; padding: 14px; }
    .metric strong { display: block; font-size: 28px; }
    .muted, .empty { color: var(--muted); }
    .summary-groups { display: grid; gap: 12px; grid-template-columns: repeat(auto-fit, minmax(280px, 1fr)); margin-top: 8px; }
    .summary-group { background: #fbfcfe; border: 1px solid var(--border); border-radius: 8px; padding: 12px; }
    .summary-group ul { margin: 0; padding-left: 18px; }
    .context-notes { margin-top: 14px; }
    .note-body h4 { margin-top: 10px; }
    .note-body ul { margin: 0 0 8px; padding-left: 18px; }
    .tool-findings { background: var(--panel); border: 1px solid var(--border); border-radius: 8px; margin-top: 14px; padding: 16px; scroll-margin-top: 20px; }
    table { width: 100%; border-collapse: collapse; background: var(--panel); border: 1px solid var(--border); }
    th, td { text-align: left; border-bottom: 1px solid var(--border); padding: 10px; vertical-align: top; }
    th { background: #edf1f7; font-size: 13px; }
    .issue-link { color: var(--accent); font-weight: 700; text-decoration: none; }
    .issue-link:hover { text-decoration: underline; }
    code, pre { font-family: "SFMono-Regular", Consolas, monospace; }
    .badge { display: inline-block; min-width: 66px; text-align: center; border-radius: 999px; padding: 3px 10px; font-size: 12px; font-weight: 700; }
    .pass { color: #fff; background: var(--pass); }
    .fail { color: #fff; background: var(--fail); }
    .finding { border-left: 4px solid var(--fail); overflow: hidden; padding: 0; }
    .finding > summary { align-items: center; cursor: pointer; display: flex; font-weight: 700; gap: 12px; justify-content: space-between; list-style: none; padding: 14px 16px; }
    .finding > summary::-webkit-details-marker { display: none; }
    .finding-body { border-top: 1px solid var(--border); padding: 12px 16px 16px; }
    .finding-tool { color: var(--muted); font-size: 13px; font-weight: 700; }
    .message { margin: 10px 0; }
    .code { overflow-x: auto; background: var(--code); border-radius: 6px; padding: 10px 0; }
    .code-line { display: grid; grid-template-columns: 64px 1fr; gap: 12px; padding: 0 12px; white-space: pre; }
    .code-line span { color: var(--muted); text-align: right; user-select: none; }
    .code-line.mark { background: #ffe8e5; }
    .parsed-output { display: grid; gap: 12px; margin-top: 12px; }
    .raw-label { color: var(--muted); font-size: 12px; font-weight: 700; letter-spacing: .04em; margin-top: 12px; text-transform: uppercase; }
    .issue-card { background: #fbfcfe; border: 1px solid var(--border); border-left: 4px solid var(--accent); border-radius: 8px; padding: 12px; }
    .issue-meta { align-items: center; display: flex; flex-wrap: wrap; gap: 8px; }
    .issue-tool, .issue-rule { border-radius: 999px; font-size: 12px; font-weight: 700; padding: 2px 8px; }
    .issue-tool { background: #e8eefc; color: #1d4fa7; }
    .issue-rule { background: #fff0d6; color: #8a4b00; }
    .issue-desc { margin: 10px 0; font-weight: 650; }
    .issue-code { background: var(--code); border-radius: 6px; overflow-x: auto; padding: 8px 0; }
    details summary { cursor: pointer; font-weight: 700; }
    pre { overflow-x: auto; background: var(--code); padding: 12px; border-radius: 6px; }
    .raw-pre { border: 1px solid var(--border); margin-top: 6px; white-space: pre-wrap; }
  </style>
</head>
<body>
  <main>
    <h1>Static Code Analysis Report</h1>
    <div class="meta">
      <div><strong>Project:</strong> <code>$(printf '%s' "$ROOT" | html_escape)</code></div>
      <div><strong>Detected stack profile:</strong> <code>$(printf '%s' "$STACK_PROFILE" | html_escape)</code></div>
      <div><strong>Harness directory:</strong> <code>$(printf '%s' "$HARNESS_DIR" | html_escape)</code></div>
      <div><strong>Generated:</strong> $(printf '%s' "$generated" | html_escape)</div>
    </div>
    <div class="notice">$(printf '%s' "$QUALITY_ONLY_NOTICE" | html_escape)</div>
    <div class="summary">
      <div class="metric"><strong>$TOOLS_RUN</strong><span>tools run</span></div>
      <div class="metric"><strong>$FAILED_TOOLS</strong><span>tools failed</span></div>
      <div class="metric"><strong>$FINDING_COUNT</strong><span>high-priority defects</span></div>
    </div>
HTML

    echo '    <h2>Summary</h2>'
    cat "$SUMMARY_FILE"

    echo '    <h2>Tools Overview</h2>'
    echo '    <table><thead><tr><th>Tool</th><th>Command</th><th>Duration</th><th>Issues</th></tr></thead><tbody>'
    if [ -s "$TOOL_ROWS_FILE" ]; then
      cat "$TOOL_ROWS_FILE"
    else
      echo '<tr><td colspan="4">No compatible static analysis tools were detected.</td></tr>'
    fi
    echo '    </tbody></table>'

    echo '    <h2>High-Priority Defect Details</h2>'
    cat "$FINDINGS_FILE"
    echo '  </main></body></html>'
  } > "$REPORT_PATH"
}

determine_stack_profile
prepare_python_dependencies
discover_tools
run_tools
build_summary_html
build_findings_html
render_report

report_json="$(printf '%s' "$REPORT_PATH" | json_escape)"
harness_json="$(printf '%s' "$HARNESS_DIR" | json_escape)"
requirements_json="null"
dependency_notes_json="null"
[ -f "$REQUIREMENTS_PATH" ] && requirements_json="\"$(printf '%s' "$REQUIREMENTS_PATH" | json_escape)\""
[ -f "$DEPENDENCY_NOTES_PATH" ] && dependency_notes_json="\"$(printf '%s' "$DEPENDENCY_NOTES_PATH" | json_escape)\""

printf '{"ok":true,"report":"%s","harnessDir":"%s","requirements":%s,"dependencyNotes":%s,"toolsRun":%s,"failedTools":%s,"highPriorityFindings":%s,"securityChecksExcluded":true}\n' \
  "$report_json" "$harness_json" "$requirements_json" "$dependency_notes_json" "$TOOLS_RUN" "$FAILED_TOOLS" "$FINDING_COUNT"

if [ "$FAIL_ON_HIGH" -eq 1 ] && [ "$FINDING_COUNT" -gt 0 ]; then
  exit 1
fi
