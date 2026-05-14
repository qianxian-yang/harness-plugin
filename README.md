# Harness Skills

**Production-grade engineering skills for AI coding agents — covering the full software development lifecycle from spec to ship.**

Skills encode the workflows, quality gates, and best practices that senior engineers use when building software.

```
 TEST                   REVIEW
┌──────────────┐      ┌──────┐
│ Code + Tests │ ───▶ │  QA  │
│ (TDD)        │      │ Gate │
└──────────────┘      └──────┘
 /td-test            /td-review
                     /td-code-simplify
```

---

## Commands

3 slash commands that map to this repo's core workflow. Each one activates the right skills automatically.

| What you're doing | Command | Key principle |
|-------------------|---------|---------------|
| Prove it works | `/td-test` | Tests are proof |
| Review before merge | `/td-review` | Improve code health |
| Simplify the code | `/td-code-simplify` | Clarity over cleverness |

---

## Quick Start

1. Clone the repo
2. Pick 2-3 skills to start with (`td-test-driven-development`, `td-code-review-and-quality`, `td-code-simplification`)
3. Follow the setup block for your agent

```bash
git clone https://github.com/qianxian-yang/td-harness-skills.git
cd td-harness-skills
```

<details>
<summary><b>Claude Code (recommended)</b></summary>

**Option A: Marketplace (fastest)**

```bash
claude plugin marketplace add qianxian-yang/td-harness-skills
claude plugin install harness-plugin@td-quality
```

> **SSH errors?** The marketplace clones repos via SSH. If you don't have SSH keys set up on GitHub, use the full HTTPS URL:
> ```bash
> claude plugin marketplace add https://github.com/qianxian-yang/td-harness-skills.git
> claude plugin install harness-plugin@td-quality
> ```

**Option B: Local / development**

```bash
claude --plugin-dir /path/to/harness-skills
```

After install, run `/td-test` in Claude Code to confirm commands are available.


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
| [td-source-driven-development](skills/td-source-driven-development/SKILL.md) | Ground every framework decision in official documentation - verify, cite sources, flag what's unverified | You want authoritative, source-cited code for any framework or library |
| [td-frontend-ui-engineering](skills/td-frontend-ui-engineering/SKILL.md) | Component architecture, design systems, state management, responsive design, WCAG 2.1 AA accessibility | Building or modifying user-facing interfaces |
| [td-api-and-interface-design](skills/td-api-and-interface-design/SKILL.md) | Contract-first design, Hyrum's Law, One-Version Rule, error semantics, boundary validation | Designing APIs, module boundaries, or public interfaces |
| [td-security-and-hardening](skills/td-security-and-hardening/SKILL.md) | OWASP Top 10 prevention, auth patterns, secrets management, dependency auditing, three-tier boundary system | Handling user input, auth, data storage, or external integrations |
| [td-performance-optimization](skills/td-performance-optimization/SKILL.md) | Measure-first approach - Core Web Vitals targets, profiling workflows, bundle analysis, anti-pattern detection | Performance requirements exist or you suspect regressions |

### Language-Specific Coding Guidelines

| Skill | What It Does | Use When |
|-------|-------------|----------|
| [td-java-coding-guidelines](skills/td-java-coding-guidelines/SKILL.md) | Java coding standards based on Alibaba Java Coding Guidelines — naming, OOP, collections, concurrency, exceptions, logging, MySQL, project layering | Writing or reviewing Java code |
| [td-python-coding-guidelines](skills/td-python-coding-guidelines/SKILL.md) | Python coding standards based on Google Python Style Guide — imports, naming, docstrings, type annotations, exceptions | Writing or reviewing Python code |

### Meta

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
│  │              Use when...                  │  │
│  └───────────────────────────────────────────┘  │
│  Overview         -> What this skill does       │
│  When to Use      -> Triggering conditions      │
│  Process          -> Step-by-step workflow       │
│  Rationalizations -> Excuses + rebuttals        │
│  Red Flags        -> Signs something's wrong    │
│  Verification     -> Evidence requirements      │
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
harness-skills/
├── .claude-plugin/                       # Plugin metadata
│   ├── plugin.json                       #   Plugin definition
│   └── marketplace.json                  #   Marketplace listing
├── skills/                               # 11 skills (SKILL.md per directory)
│   ├── td-test-driven-development/       #   Core workflow
│   ├── td-code-review-and-quality/       #   Core workflow
│   ├── td-code-simplification/           #   Core workflow
│   ├── td-source-driven-development/     #   Optional domain
│   ├── td-frontend-ui-engineering/       #   Optional domain
│   ├── td-api-and-interface-design/      #   Optional domain
│   ├── td-security-and-hardening/        #   Optional domain
│   ├── td-performance-optimization/      #   Optional domain
│   ├── td-java-coding-guidelines/        #   Language: Java
│   ├── td-python-coding-guidelines/      #   Language: Python
│   └── td-skill-navigation/              #   Meta: how to use this pack
├── agents/                               # 3 specialist personas
├── references/                           # 4 supplementary checklists
├── hooks/                                # Session lifecycle hooks
└── .claude/commands/                     # 3 slash commands
```

---

## Why Harness Skills?

AI coding agents default to the shortest path - which often means skipping tests, security reviews, and the practices that make software reliable. Harness Skills gives agents structured workflows that enforce the same discipline senior engineers bring to production code.

Each skill encodes hard-won engineering judgment: *how* to implement safely, *what* to test, and *how* to review. These aren't generic prompts - they're opinionated, process-driven workflows that separate production-quality work from prototype-quality work.

Skills bake in best practices from Google's engineering culture — including concepts from [Software Engineering at Google](https://abseil.io/resources/swe-book) and Google's [engineering practices guide](https://google.github.io/eng-practices/). You'll find Hyrum's Law in API design, the Beyonce Rule and test pyramid in testing, change sizing and review speed norms in code review, and Chesterton's Fence in simplification.

---

## Contributing

Skills should be **specific** (actionable steps, not vague advice), **verifiable** (clear exit criteria with evidence requirements), **battle-tested** (based on real workflows), and **minimal** (only what's needed to guide the agent).

---

## License

MIT - use these skills in your projects, teams, and tools.
