---
name: td-harness-setup
description: Create and bootstrap a repository harness skeleton with AGENTS.md/CLAUDE.md navigation docs, startup scripts, and quality scripts. Use when asked to initialize harness/, generate project navigation files, add static checks, or add unit-test+coverage commands; first detect whether gitnexus-cli skill exists and use it for repository analysis when available.
---

# TD Harness Setup

Create a standard harness scaffold and project navigation files for an existing repository.

## Workflow

1. Detect whether `gitnexus-cli` skill exists before any generation.
2. If `gitnexus-cli` exists, use it to analyze/index repository context first, then generate files.
3. Create harness structure and executable scripts.
4. Generate `AGENTS.md` and `CLAUDE.md` with the same content, following the strict section layout.
5. Validate generated files and script executability.

## Detect and Use `gitnexus-cli`

Check these paths in order:

- `$CODEX_HOME/skills/gitnexus-cli/SKILL.md`
- `~/.codex/skills/gitnexus-cli/SKILL.md`
- `./skills/gitnexus-cli/SKILL.md`

If found:

- Invoke `$gitnexus-cli` to inspect repo status and index readiness before generating docs.
- Prefer using discovered stack/structure/commands to fill AGENTS/CLAUDE sections.

If not found:

- Continue with local file-based detection (`package.json`, `pom.xml`, `go.mod`, `pyproject.toml`, `requirements.txt`, etc.).

## Generate Files

Run:

```bash
bash skills/td-harness-setup/scripts/setup-harness.sh --target . --quality-ext sh
```

Optional:

```bash
bash skills/td-harness-setup/scripts/setup-harness.sh --target /path/to/repo --quality-ext sh --force
```

Arguments:

- `--target`: target repository root (default `.`)
- `--quality-ext`: extension for `lint-quality.{ext}` (default `sh`)
- `--force`: overwrite existing generated files

## Output Contract

The script creates:

- `harness/docs/`
- `harness/quality-scripts/lint-quality.{ext}`
- `harness/quality-scripts/unit-test-coverage.sh`
- `harness/server-scripts/setup-env.sh`
- `harness/server-scripts/start-server.sh`
- `AGENTS.md`
- `CLAUDE.md` (same content as `AGENTS.md`)

`AGENTS.md` and `CLAUDE.md` must follow the requested 80-120 line map structure, with backend/frontend architecture sections treated as conditional by project type.

## Quality Script Rules

Include static quality and unit-test coverage behavior:

- Go: `go vet ./...`, `staticcheck ./...`
- Python: `ruff check .`, `mypy .` with `venv`/`.venv` probing
- Java (Maven): `mvn -B clean install -DskipTests -U` + SpotBugs version by Java major
- TypeScript/JavaScript: `npm run lint`, `npm run typecheck`

Unit test coverage script must run project-native tests and emit coverage artifacts where available.

## Present Results

When finished, report:

1. Whether `gitnexus-cli` skill was found and used.
2. Created file list.
3. Detected stack and selected commands.
4. Any placeholders that need manual completion.
