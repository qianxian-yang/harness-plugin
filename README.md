# TD Harness

**Production-grade engineering skills for AI coding agents.**

Skills encode the workflows, quality gates, and best practices that senior engineers use when building software. This company version focuses on test and review workflows.

```
 TEST                   REVIEW
┌──────────────┐      ┌──────┐
│ Code + Tests │ ───▶ │  QA  │
│ (TDD)        │      │ Gate │
└──────────────┘      └──────┘
 /test              /review
                   /code-simplify
```

---

## Commands

3 slash commands that map to this repo's core workflow. Each one activates the right skills automatically.

| What you're doing | Command | Key principle |
|-------------------|---------|---------------|
| Prove it works | `/test` | Tests are proof |
| Review before merge | `/review` | Improve code health |
| Simplify the code | `/code-simplify` | Clarity over cleverness |

Optional domain skills can still be applied based on context — for example, API-heavy work can use `td-api-and-interface-design`, and UI-heavy work can use `td-frontend-ui-engineering`.

---

## Quick Start

If you want the fastest path, do this first:

1. Clone the repo
2. Pick 2-3 skills to start with (`td-test-driven-development`, `td-code-review-and-quality`, `td-context-engineering`)
3. Follow the setup block for your agent

```bash
git clone git@gitlab.tongdun.cn:skills/harness-skills.git
cd harness-skills
```

<details>
<summary><b>Claude Code (recommended)</b></summary>

**Option A: Marketplace (fastest)**

```
/plugin marketplace add skills/harness-skills
/plugin install harness-skills
```

> **SSH errors?** The marketplace clones repos via SSH. If you don't have SSH keys set up on GitLab, add your SSH key in GitLab settings, or switch to HTTPS for fetches only:
> ```bash
> git config --global url."https://gitlab.tongdun.cn/".insteadOf "git@gitlab.tongdun.cn:"
> ```

**Option B: Local / development**

```bash
claude --plugin-dir /path/to/harness-skills
```

After install, run `/test` in Claude Code to confirm commands are available.

</details>

<details>
<summary><b>Cursor</b></summary>

Use `.cursor/rules/` and load the three core skills first:

```bash
mkdir -p .cursor/rules
cp /path/to/harness-skills/skills/td-test-driven-development/SKILL.md .cursor/rules/test-driven-development.md
cp /path/to/harness-skills/skills/td-code-review-and-quality/SKILL.md .cursor/rules/code-review-and-quality.md
cp /path/to/harness-skills/skills/td-context-engineering/SKILL.md .cursor/rules/context-engineering.md
```

Full setup options (rules, `.cursorrules`, Notepads): [docs/cursor-setup.md](docs/cursor-setup.md).

</details>

<details>
<summary><b>Gemini CLI</b></summary>

Install as native skills for auto-discovery:

```bash
gemini skills install git@gitlab.tongdun.cn:skills/harness-skills.git --path skills
```

Or install from a local clone:

```bash
gemini skills install /path/to/harness-skills/skills/
```

Verify with `/skills list`.

Persistent-context setup with `GEMINI.md`: [docs/gemini-cli-setup.md](docs/gemini-cli-setup.md).

</details>

<details>
<summary><b>Windsurf</b></summary>

Add the core skills to `.windsurfrules`, then load domain skills only when needed.

Step-by-step setup: [docs/windsurf-setup.md](docs/windsurf-setup.md).

</details>

<details>
<summary><b>OpenCode</b></summary>

OpenCode uses agent-driven skill execution via `AGENTS.md` and the `skill` tool.

1. Open this repository in OpenCode
2. Keep `AGENTS.md` at repo root
3. Keep the `skills/` directory intact

Setup guide: [docs/opencode-setup.md](docs/opencode-setup.md).

</details>

<details>
<summary><b>GitHub Copilot</b></summary>

Use agent definitions from `agents/` as Copilot personas and skill content in `.github/copilot-instructions.md`.

Step-by-step setup: [docs/copilot-setup.md](docs/copilot-setup.md).

</details>

<details>
  <summary><b>Kiro IDE & CLI</b></summary>
  Skills for Kiro live under `.kiro/skills/` (project-level or global). Kiro also supports `AGENTS.md`.
  See [Kiro skills docs](https://kiro.dev/docs/skills/).
</details>

<details>
<summary><b>Codex / Other Agents</b></summary>

Skills are plain Markdown, so they work with any agent that accepts system prompts, rules files, or instruction files.

Universal setup guide: [docs/getting-started.md](docs/getting-started.md).

</details>



---

## All 11 Skills

The commands above are the entry points. Under the hood, they activate these 11 skills — each one a structured workflow with steps, verification gates, and anti-rationalization tables. You can also reference any skill directly.

### Core Workflow

| Skill | What It Does | Use When |
|-------|-------------|----------|
| [td-test-driven-development](skills/td-test-driven-development/SKILL.md) | Red-Green-Refactor, test pyramid (80/15/5), test sizes, DAMP over DRY, Beyonce Rule, browser testing | Implementing logic, fixing bugs, or changing behavior |
| [td-code-review-and-quality](skills/td-code-review-and-quality/SKILL.md) | Five-axis review, change sizing (~100 lines), severity labels (Nit/Optional/FYI), review speed norms, splitting strategies | Before merging any change |
| [td-code-simplification](skills/td-code-simplification/SKILL.md) | Chesterton's Fence, Rule of 500, reduce complexity while preserving exact behavior | Code works but is harder to read or maintain than it should be |

### Optional Domain Skills

| Skill | What It Does | Use When |
|-------|-------------|----------|
| [td-context-engineering](skills/td-context-engineering/SKILL.md) | Feed agents the right information at the right time - rules files, context packing, MCP integrations | Starting a session, switching tasks, or when output quality drops |
| [td-source-driven-development](skills/td-source-driven-development/SKILL.md) | Ground every framework decision in official documentation - verify, cite sources, flag what's unverified | You want authoritative, source-cited code for any framework or library |
| [static-code-analysis](skills/static-code-analysis/SKILL.md) | Quality-only lint/type/style checks with self-contained HTML reports and code locations | Running static code checks without security scanning |
| [td-frontend-ui-engineering](skills/td-frontend-ui-engineering/SKILL.md) | Component architecture, design systems, state management, responsive design, WCAG 2.1 AA accessibility | Building or modifying user-facing interfaces |
| [td-api-and-interface-design](skills/td-api-and-interface-design/SKILL.md) | Contract-first design, Hyrum's Law, One-Version Rule, error semantics, boundary validation | Designing APIs, module boundaries, or public interfaces |
| [td-security-and-hardening](skills/td-security-and-hardening/SKILL.md) | OWASP Top 10 prevention, auth patterns, secrets management, dependency auditing, three-tier boundary system | Handling user input, auth, data storage, or external integrations |
| [td-performance-optimization](skills/td-performance-optimization/SKILL.md) | Measure-first approach - Core Web Vitals targets, profiling workflows, bundle analysis, anti-pattern detection | Performance requirements exist or you suspect regressions |

### Meta - Skill routing

| Skill | What It Does | Use When |
|-------|-------------|----------|
| [td-skill-navigation](skills/td-skill-navigation/SKILL.md) | Meta-skill for routing tasks to the correct workflow | Starting a session or deciding which skill should be applied |

---

## Agent Personas

Pre-configured specialist personas for targeted reviews:

| Agent | Role | Perspective |
|-------|------|-------------|
| [code-reviewer](agents/code-reviewer.md) | Senior Staff Engineer | Five-axis code review with "would a staff engineer approve this?" standard |
| [test-engineer](agents/test-engineer.md) | QA Specialist | Test strategy, coverage analysis, and the Prove-It pattern |
| [security-auditor](agents/security-auditor.md) | Security Engineer | Vulnerability detection, threat modeling, OWASP assessment |

---

## Reference Checklists

Quick-reference material that skills pull in when needed:

| Reference | Covers |
|-----------|--------|
| [testing-patterns.md](references/testing-patterns.md) | Test structure, naming, mocking, React/API/E2E examples, anti-patterns |
| [security-checklist.md](references/security-checklist.md) | Pre-commit checks, auth, input validation, headers, CORS, OWASP Top 10 |
| [performance-checklist.md](references/performance-checklist.md) | Core Web Vitals targets, frontend/backend checklists, measurement commands |
| [accessibility-checklist.md](references/accessibility-checklist.md) | Keyboard nav, screen readers, visual design, ARIA, testing tools |

---

## How Skills Work

Every skill follows a consistent anatomy:

```
┌─────────────────────────────────────────────────┐
│  SKILL.md                                       │
│                                                 │
│  ┌─ Frontmatter ─────────────────────────────┐  │
│  │ name: lowercase-hyphen-name               │  │
│  │ description: Guides agents through [task].│  │
│  │              Use when…                    │  │
│  └───────────────────────────────────────────┘  │                                                                                                
│  Overview         → What this skill does        │
│  When to Use      → Triggering conditions       │
│  Process          → Step-by-step workflow       │
│  Rationalizations → Excuses + rebuttals         │
│  Red Flags        → Signs something's wrong     │
│  Verification     → Evidence requirements       │
└─────────────────────────────────────────────────┘
```

**Key design choices:**

- **Process, not prose.** Skills are workflows agents follow, not reference docs they read. Each has steps, checkpoints, and exit criteria.
- **Anti-rationalization.** Every skill includes a table of common excuses agents use to skip steps (e.g., "I'll add tests later") with documented counter-arguments.
- **Verification is non-negotiable.** Every skill ends with evidence requirements - tests passing, build output, runtime data. "Seems right" is never sufficient.
- **Progressive disclosure.** The `SKILL.md` is the entry point. Supporting references load only when needed, keeping token usage minimal.

---

## Project Structure

```
td-harness/
├── skills/                            # 10 core skills (SKILL.md per directory)
│   ├── test-driven-development/       #   Core workflow
│   ├── code-review-and-quality/       #   Core workflow
│   ├── code-simplification/           #   Core workflow
│   ├── context-engineering/           #   Optional domain
│   ├── source-driven-development/     #   Optional domain
│   ├── frontend-ui-engineering/       #   Optional domain
│   ├── api-and-interface-design/      #   Optional domain
│   ├── security-and-hardening/        #   Optional domain
│   ├── performance-optimization/      #   Optional domain
│   └── skill-navigation/              #   Meta: how to use this pack
├── agents/                            # 3 specialist personas
├── references/                        # 4 supplementary checklists
├── hooks/                             # Session lifecycle hooks
├── .claude/commands/                  # 3 slash commands
└── docs/                              # Setup guides per tool
```

---

## Why TD Harness?

AI coding agents default to the shortest path - which often means skipping tests, security reviews, and the practices that make software reliable. TD Harness gives agents structured workflows that enforce the same discipline senior engineers bring to production code.

Each skill encodes hard-won engineering judgment: *how* to implement safely, *what* to test, and *how* to review. These aren't generic prompts - they're the kind of opinionated, process-driven workflows that separate production-quality work from prototype-quality work.

Skills bake in best practices from Google's engineering culture — including concepts from [Software Engineering at Google](https://abseil.io/resources/swe-book) and Google's [engineering practices guide](https://google.github.io/eng-practices/). You'll find Hyrum's Law in API design, the Beyonce Rule and test pyramid in testing, change sizing and review speed norms in code review, and Chesterton's Fence in simplification. These aren't abstract principles — they're embedded directly into the step-by-step workflows agents follow.

---

## Contributing

Skills should be **specific** (actionable steps, not vague advice), **verifiable** (clear exit criteria with evidence requirements), **battle-tested** (based on real workflows), and **minimal** (only what's needed to guide the agent).

See [docs/skill-anatomy.md](docs/skill-anatomy.md) for the format specification and [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

---

## License

MIT - use these skills in your projects, teams, and tools.
