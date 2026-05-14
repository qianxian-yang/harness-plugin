# TD Harness Skills

**Production-grade engineering skills for AI coding agents — covering the full software development lifecycle from spec to ship.**

Skills encode the workflows, quality gates, and best practices that senior engineers use when building software. These ones are packaged so AI agents follow them consistently across every phase of development.

---

## Commands

7 slash commands that map to the development lifecycle. Each one activates the right skills automatically.

| What you're doing | Command | Key principle |
|-------------------|---------|---------------|
| Define what to build | `/td-spec` | Spec before code |
| Plan how to build it | `/td-plan` | Small, atomic tasks |
| Build incrementally | `/td-build` | One slice at a time |
| Prove it works | `/td-test` | Tests are proof |
| Review before merge | `/td-review` | Improve code health |
| Simplify the code | `/td-code-simplify` | Clarity over cleverness |
| Ship to production | `/td-ship` | Faster is safer |

Skills also activate automatically based on what you're doing — designing an API triggers `td-api-and-interface-design`, building UI triggers `td-frontend-ui-engineering`, and so on.

---

## Quick Start

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
****copilot:****
> ```bash
> copilot plugin marketplace add funky-eyes/best-copilot
> copilot plugin install best-copilot@best-copilot
> ```

**Option B: Local / development**

```bash
git clone https://github.com/qianxian-yang/td-harness-skills.git
claude --plugin-dir /path/to/harness-skills
```

After install, run `/td-test` in Claude Code to confirm commands are available.

If you’re using Copilot, please switch to the **Senior Project Expert** agent via `/agent`. In the first session, it will automatically perform actions such as `/init`.

</details>



---

## All 25 Skills

The commands above are entry points. The pack includes 25 skills total — 24 lifecycle skills plus the `td-skill-navigation` meta-skill. Each skill is a structured workflow with steps, verification gates, and anti-rationalization tables. You can also reference any skill directly.

### Meta - Discover which skill applies

| Skill | What It Does | Use When |
|-------|-------------|----------|
| [td-skill-navigation](skills/td-skill-navigation/SKILL.md) | Maps incoming work to the right skill workflow and defines shared operating rules | Starting a session or deciding which skill applies |

### Define - Clarify what to build

| Skill | What It Does | Use When |
|-------|-------------|----------|
| [td-interview-me](skills/td-interview-me/SKILL.md) | One-question-at-a-time interview that extracts what the user actually wants instead of what they think they should want, until ~95% confidence | The ask is underspecified, or the user invokes "interview me" / "grill me" |
| [td-idea-refine](skills/td-idea-refine/SKILL.md) | Structured divergent/convergent thinking to turn vague ideas into concrete proposals | You have a rough concept that needs exploration |
| [td-spec-driven-development](skills/td-spec-driven-development/SKILL.md) | Write a PRD covering objectives, commands, structure, code style, testing, and boundaries before any code | Starting a new project, feature, or significant change |

### Plan - Break it down

| Skill | What It Does | Use When |
|-------|-------------|----------|
| [td-planning-and-task-breakdown](skills/td-planning-and-task-breakdown/SKILL.md) | Decompose specs into small, verifiable tasks with acceptance criteria and dependency ordering | You have a spec and need implementable units |

### Build - Write the code

| Skill | What It Does | Use When |
|-------|-------------|----------|
| [td-incremental-implementation](skills/td-incremental-implementation/SKILL.md) | Thin vertical slices - implement, test, verify, commit. Feature flags, safe defaults, rollback-friendly changes | Any change touching more than one file |
| [td-test-driven-development](skills/td-test-driven-development/SKILL.md) | Red-Green-Refactor, test pyramid (80/15/5), test sizes, DAMP over DRY, Beyonce Rule, browser testing | Implementing logic, fixing bugs, or changing behavior |
| [td-context-engineering](skills/td-context-engineering/SKILL.md) | Feed agents the right information at the right time - rules files, context packing, MCP integrations | Starting a session, switching tasks, or when output quality drops |
| [td-source-driven-development](skills/td-source-driven-development/SKILL.md) | Ground every framework decision in official documentation - verify, cite sources, flag what's unverified | You want authoritative, source-cited code for any framework or library |
| [td-doubt-driven-development](skills/td-doubt-driven-development/SKILL.md) | Adversarial fresh-context review of every non-trivial decision in-flight - CLAIM → EXTRACT → DOUBT → RECONCILE → STOP | Stakes are high (production, security, irreversible), working in unfamiliar code |
| [td-frontend-ui-engineering](skills/td-frontend-ui-engineering/SKILL.md) | Component architecture, design systems, state management, responsive design, WCAG 2.1 AA accessibility | Building or modifying user-facing interfaces |
| [td-api-and-interface-design](skills/td-api-and-interface-design/SKILL.md) | Contract-first design, Hyrum's Law, One-Version Rule, error semantics, boundary validation | Designing APIs, module boundaries, or public interfaces |

### Verify - Prove it works

| Skill | What It Does | Use When |
|-------|-------------|----------|
| [td-browser-testing-with-devtools](skills/td-browser-testing-with-devtools/SKILL.md) | Chrome DevTools MCP for live runtime data - DOM inspection, console logs, network traces, performance profiling | Building or debugging anything that runs in a browser |
| [td-debugging-and-error-recovery](skills/td-debugging-and-error-recovery/SKILL.md) | Five-step triage: reproduce, localize, reduce, fix, guard. Stop-the-line rule, safe fallbacks | Tests fail, builds break, or behavior is unexpected |

### Review - Quality gates before merge

| Skill | What It Does | Use When |
|-------|-------------|----------|
| [td-code-review-and-quality](skills/td-code-review-and-quality/SKILL.md) | Five-axis review, change sizing (~100 lines), severity labels (Nit/Optional/FYI), review speed norms, splitting strategies | Before merging any change |
| [td-code-simplification](skills/td-code-simplification/SKILL.md) | Chesterton's Fence, Rule of 500, reduce complexity while preserving exact behavior | Code works but is harder to read or maintain than it should be |
| [td-security-and-hardening](skills/td-security-and-hardening/SKILL.md) | OWASP Top 10 prevention, auth patterns, secrets management, dependency auditing, three-tier boundary system | Handling user input, auth, data storage, or external integrations |
| [td-performance-optimization](skills/td-performance-optimization/SKILL.md) | Measure-first approach - Core Web Vitals targets, profiling workflows, bundle analysis, anti-pattern detection | Performance requirements exist or you suspect regressions |

### Ship - Deploy with confidence

| Skill | What It Does | Use When |
|-------|-------------|----------|
| [td-git-workflow-and-versioning](skills/td-git-workflow-and-versioning/SKILL.md) | Trunk-based development, atomic commits, change sizing (~100 lines), the commit-as-save-point pattern | Making any code change (always) |
| [td-ci-cd-and-automation](skills/td-ci-cd-and-automation/SKILL.md) | Shift Left, Faster is Safer, feature flags, quality gate pipelines, failure feedback loops | Setting up or modifying build and deploy pipelines |
| [td-deprecation-and-migration](skills/td-deprecation-and-migration/SKILL.md) | Code-as-liability mindset, compulsory vs advisory deprecation, migration patterns, zombie code removal | Removing old systems, migrating users, or sunsetting features |
| [td-documentation-and-adrs](skills/td-documentation-and-adrs/SKILL.md) | Architecture Decision Records, API docs, inline documentation standards - document the *why* | Making architectural decisions, changing APIs, or shipping features |
| [td-shipping-and-launch](skills/td-shipping-and-launch/SKILL.md) | Pre-launch checklists, feature flag lifecycle, staged rollouts, rollback procedures, monitoring setup | Preparing to deploy to production |

### Language-Specific Coding Guidelines

| Skill | What It Does | Use When |
|-------|-------------|----------|
| [td-java-coding-guidelines](skills/td-java-coding-guidelines/SKILL.md) | Java coding standards based on Alibaba Java Coding Guidelines — naming, OOP, collections, concurrency, exceptions, logging, MySQL, project layering | Writing or reviewing Java code |
| [td-python-coding-guidelines](skills/td-python-coding-guidelines/SKILL.md) | Python coding standards based on Google Python Style Guide — imports, naming, docstrings, type annotations, exceptions | Writing or reviewing Python code |

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
| [orchestration-patterns.md](references/orchestration-patterns.md) | Agent orchestration patterns, parallel fan-out, anti-patterns |

---

## How Skills Work

Every skill follows a consistent anatomy:

```
┌─────────────────────────────────────────────────┐
│  SKILL.md                                       │
│                                                 │
│  ┌─ Frontmatter ─────────────────────────────┐  │
│  │ name: td-lowercase-hyphen-name            │  │
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
├── skills/                               # 25 skills (24 lifecycle + 1 meta)
│   ├── td-interview-me/                  #   Define
│   ├── td-idea-refine/                   #   Define
│   ├── td-spec-driven-development/       #   Define
│   ├── td-planning-and-task-breakdown/   #   Plan
│   ├── td-incremental-implementation/    #   Build
│   ├── td-context-engineering/           #   Build
│   ├── td-source-driven-development/     #   Build
│   ├── td-doubt-driven-development/      #   Build
│   ├── td-frontend-ui-engineering/       #   Build
│   ├── td-test-driven-development/       #   Build
│   ├── td-api-and-interface-design/      #   Build
│   ├── td-browser-testing-with-devtools/ #   Verify
│   ├── td-debugging-and-error-recovery/  #   Verify
│   ├── td-code-review-and-quality/       #   Review
│   ├── td-code-simplification/           #   Review
│   ├── td-security-and-hardening/        #   Review
│   ├── td-performance-optimization/      #   Review
│   ├── td-git-workflow-and-versioning/   #   Ship
│   ├── td-ci-cd-and-automation/          #   Ship
│   ├── td-deprecation-and-migration/     #   Ship
│   ├── td-documentation-and-adrs/        #   Ship
│   ├── td-shipping-and-launch/           #   Ship
│   ├── td-java-coding-guidelines/        #   Language: Java
│   ├── td-python-coding-guidelines/      #   Language: Python
│   └── td-skill-navigation/              #   Meta: how to use this pack
├── agents/                               # 3 specialist personas
├── references/                           # 5 supplementary checklists
├── hooks/                                # Session lifecycle hooks
└── .claude/commands/                     # 7 slash commands
```

---

## Why Harness Skills?

AI coding agents default to the shortest path - which often means skipping specs, tests, security reviews, and the practices that make software reliable. Harness Skills gives agents structured workflows that enforce the same discipline senior engineers bring to production code.

Each skill encodes hard-won engineering judgment: *when* to write a spec, *what* to test, *how* to review, and *when* to ship. These aren't generic prompts - they're the kind of opinionated, process-driven workflows that separate production-quality work from prototype-quality work.

Skills bake in best practices from Google's engineering culture — including concepts from [Software Engineering at Google](https://abseil.io/resources/swe-book) and Google's [engineering practices guide](https://google.github.io/eng-practices/). You'll find Hyrum's Law in API design, the Beyonce Rule and test pyramid in testing, change sizing and review speed norms in code review, Chesterton's Fence in simplification, trunk-based development in git workflow, Shift Left and feature flags in CI/CD, and a dedicated deprecation skill treating code as a liability.

---

## Contributing

Skills should be **specific** (actionable steps, not vague advice), **verifiable** (clear exit criteria with evidence requirements), **battle-tested** (based on real workflows), and **minimal** (only what's needed to guide the agent).

---

## License

MIT - use these skills in your projects, teams, and tools.
