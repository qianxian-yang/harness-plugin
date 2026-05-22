---
name: td-spec-driven-development
description: Creates specs before coding. Use when starting a new project, feature, or significant change and no specification exists yet. Use when requirements are unclear, ambiguous, or only exist as a vague idea.
---

# Spec-Driven Development

## Overview

Write a structured specification before writing any code. The spec is the shared source of truth between you and the human engineer — it defines what we're building, why, and how we'll know it's done. Code without a spec is guessing.

## When to Use

- Starting a new project or feature
- Requirements are ambiguous or incomplete
- The change touches multiple files or modules
- You're about to make an architectural decision
- The task would take more than 30 minutes to implement

**When NOT to use:** Single-line fixes, typo corrections, or changes where requirements are unambiguous and self-contained.

## HARD GATE — No Code Without a Spec

**You MUST NOT write implementation code, create source files, or make architectural decisions before a spec exists and is approved.** This is non-negotiable.

If the user says "just start building" or "skip the spec," respond:

> I can't write good code without knowing what "good" means for this project. A spec takes 10 minutes; debugging wrong assumptions takes hours. Let me ask a few quick questions first.

The only exceptions are single-line fixes, typo corrections, or changes where requirements are unambiguous and self-contained (see "When NOT to use" above).

## The Gated Workflow

Spec-driven development has four phases. Do not advance to the next phase until the current one is validated.

```
SPECIFY ──→ PLAN ──→ TASKS ──→ IMPLEMENT
   │          │        │          │
   ▼          ▼        ▼          ▼
 Human      Human    Human      Human
 reviews    reviews  reviews    reviews
```

### Phase 1: Specify

#### Step 1a: Explore the project context

Before asking a single question, silently read the codebase to understand what already exists:

1. Read `package.json`, `tsconfig.json`, `pyproject.toml`, or equivalent to identify tech stack and dependencies
2. Scan the directory structure (`src/`, `lib/`, `tests/`, etc.) to understand project layout
3. Read existing CLAUDE.md, README, or docs for conventions already in place
4. Check for existing specs in `docs/td-harness/` to avoid contradictions
5. Look at recent git history (`git log --oneline -20`) to understand what the team has been working on

**Why:** A spec that contradicts the existing codebase is worse than no spec. You need to know what's already there before proposing what's next.

#### Step 1b: Surface assumptions

Before writing any spec content, list what you're assuming based on what you found:

```
ASSUMPTIONS I'M MAKING (based on codebase exploration):
1. This is a web application (not native mobile) — found React in package.json
2. Authentication uses session-based cookies — found express-session in dependencies
3. The database is PostgreSQL — found Prisma schema pointing to postgres
4. We're targeting modern browsers only — found browserslist config excludes IE
→ Correct me now or I'll proceed with these.
```

Don't silently fill in ambiguous requirements. The spec's entire purpose is to surface misunderstandings *before* code gets written — assumptions are the most dangerous form of misunderstanding.

#### Step 1c: Ask one question at a time

**Do NOT batch questions.** Ask one focused question per message, with your best guess attached:

```
Q: Who is the primary user of this feature — internal engineers or end users?
GUESS: Internal engineers, because the existing dashboard at /admin suggests this is an ops tool.
```

Wait for the answer before asking the next question. The next question often depends on the previous answer — batching locks you into the wrong framing.

**Why one at a time:**
- The user reacts faster to a wrong guess than they generate an answer from scratch
- Batches encourage skim-reading and surface answers
- Your guess surfaces *your* assumptions, which is what the spec process is meant to expose

**Stop when** you can predict the user's answers to the next three questions you'd ask. That means you have shared understanding.

#### Step 1d: Propose 2–3 implementation approaches

Before writing the spec, present 2–3 distinct approaches with trade-offs:

```
APPROACH A: Server-side rendering with Next.js API routes
  + Simpler deployment, SEO-friendly
  − Heavier server load, harder to scale horizontally

APPROACH B: SPA with separate API service
  + Independent scaling, team can split frontend/backend
  − More infra complexity, CORS handling

APPROACH C: Hybrid — SSR for public pages, SPA for authenticated dashboard
  + Best of both, matches existing pattern in /marketing vs /app
  − More build complexity, two rendering modes to maintain

RECOMMENDATION: Approach C — it matches what you already have and avoids a rewrite.
→ Which direction?
```

**Why:** The most valuable design decisions happen here. Jumping straight to a spec locks in one approach without showing alternatives. The user deserves to see the trade-off space.

#### Step 1e: Write the spec

With the approach confirmed, **write a spec document covering these six core areas:**

1. **Objective** — What are we building and why? Who is the user? What does success look like?

2. **Commands** — Full executable commands with flags, not just tool names.
   ```
   Build: npm run build
   Test: npm test -- --coverage
   Lint: npm run lint --fix
   Dev: npm run dev
   ```

3. **Project Structure** — Where source code lives, where tests go, where docs belong.
   ```
   src/           → Application source code
   src/components → React components
   src/lib        → Shared utilities
   tests/         → Unit and integration tests
   e2e/           → End-to-end tests
   docs/          → Documentation
   ```

4. **Code Style** — One real code snippet showing your style beats three paragraphs describing it. Include naming conventions, formatting rules, and examples of good output.

5. **Testing Strategy** — What framework, where tests live, coverage expectations, which test levels for which concerns.

6. **Boundaries** — Three-tier system:
   - **Always do:** Run tests before commits, follow naming conventions, validate inputs
   - **Ask first:** Database schema changes, adding dependencies, changing CI config
   - **Never do:** Commit secrets, edit vendor directories, remove failing tests without approval

**Spec template:**

```markdown
# Spec: [Project/Feature Name]

## Objective
[What we're building and why. User stories or acceptance criteria.]

## Tech Stack
[Framework, language, key dependencies with versions]

## Commands
[Build, test, lint, dev — full commands]

## Project Structure
[Directory layout with descriptions]

## Code Style
[Example snippet + key conventions]

## Testing Strategy
[Framework, test locations, coverage requirements, test levels]

## Boundaries
- Always: [...]
- Ask first: [...]
- Never: [...]

## Success Criteria
[How we'll know this is done — specific, testable conditions]

## Open Questions
[Anything unresolved that needs human input]
```

**Reframe instructions as success criteria.** When receiving vague requirements, translate them into concrete conditions:

```
REQUIREMENT: "Make the dashboard faster"

REFRAMED SUCCESS CRITERIA:
- Dashboard LCP < 2.5s on 4G connection
- Initial data load completes in < 500ms
- No layout shift during load (CLS < 0.1)
→ Are these the right targets?
```

This lets you loop, retry, and problem-solve toward a clear goal rather than guessing what "faster" means.

### Phase 2: Plan

With the validated spec, generate a technical implementation plan:

1. Identify the major components and their dependencies
2. Determine the implementation order (what must be built first)
3. Note risks and mitigation strategies
4. Identify what can be built in parallel vs. what must be sequential
5. Define verification checkpoints between phases

The plan should be reviewable: the human should be able to read it and say "yes, that's the right approach" or "no, change X."

### Phase 3: Tasks

Break the plan into discrete, implementable tasks:

- Each task should be completable in a single focused session
- Each task has explicit acceptance criteria
- Each task includes a verification step (test, build, manual check)
- Tasks are ordered by dependency, not by perceived importance
- No task should require changing more than ~5 files

**Task template:**
```markdown
- [ ] Task: [Description]
  - Acceptance: [What must be true when done]
  - Verify: [How to confirm — test command, build, manual check]
  - Files: [Which files will be touched]
```

### Phase 4: Implement

Execute tasks one at a time following `skills/incremental-implementation/SKILL.md` (`incremental-implementation`) and `skills/test-driven-development/SKILL.md` (`test-driven-development`). Use `skills/context-engineering/SKILL.md` (`context-engineering`) to load the right spec sections and source files at each step rather than flooding the agent with the entire spec.

## Artifact Directory Structure

All td-harness artifacts are stored under `docs/td-harness/` in the project root, organized by date and feature:

```
docs/td-harness/
├── 2026-05-20-user-auth/
│   ├── spec.md        ← Created by /td-spec
│   ├── plan.md        ← Created by /td-plan
│   └── todo.md        ← Created by /td-plan
├── 2026-05-22-payment-flow/
│   ├── spec.md
│   ├── plan.md
│   └── todo.md
└── ...
```

**Naming convention:** `YYYY-MM-DD-<feature-name>/` where:
- `YYYY-MM-DD` is the date the spec was created
- `<feature-name>` is a short kebab-case slug derived from the user's request (e.g., `user-auth`, `payment-flow`, `email-notifications`)

**Rules:**
- Commit these files to version control — they are project history, not throwaway notes
- When running `/td-plan` or `/td-build`, reuse the directory created by `/td-spec`
- If multiple specs exist, the most recent by date takes precedence unless the user specifies otherwise

## Keeping the Spec Alive

The spec is a living document, not a one-time artifact:

- **Update when decisions change** — If you discover the data model needs to change, update the spec first, then implement.
- **Update when scope changes** — Features added or cut should be reflected in the spec.
- **Commit the spec** — The spec belongs in version control alongside the code.
- **Reference the spec in PRs** — Link back to the spec section that each PR implements.

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "This is simple, I don't need a spec" | Simple tasks don't need *long* specs, but they still need acceptance criteria. A two-line spec is fine. |
| "I'll write the spec after I code it" | That's documentation, not specification. The spec's value is in forcing clarity *before* code. |
| "The spec will slow us down" | A 15-minute spec prevents hours of rework. Waterfall in 15 minutes beats debugging in 15 hours. |
| "Requirements will change anyway" | That's why the spec is a living document. An outdated spec is still better than no spec. |
| "The user knows what they want" | Even clear requests have implicit assumptions. The spec surfaces those assumptions. |

## Spec Self-Check

Before presenting the spec to the user, run these checks yourself:

**Placeholder scan:** Search the spec for `[TODO]`, `[TBD]`, `[placeholder]`, `???`, or any bracket-enclosed text that isn't filled in. Every field must have real content or be explicitly marked as "Open Question."

**Contradiction scan:** Check that the spec doesn't contradict:
- Itself (e.g., "use REST" in one section but "GraphQL endpoint" in another)
- The existing codebase (e.g., specifying Jest when the project uses Vitest)
- Constraints the user stated during questioning

**Vagueness scan:** Flag any success criteria that aren't testable. "Improve performance" is not testable. "LCP < 2.5s" is testable. Every success criterion must have a concrete verification method.

If any check fails, fix the issue before presenting the spec. Do NOT present a spec with known problems and hope the user catches them.

## Scope Split Detection

Before finalizing, assess whether the spec is too large:

- **More than 8 success criteria** → likely needs splitting
- **Touches more than 3 independent subsystems** → likely needs splitting
- **Estimated implementation > 2 days** → likely needs splitting

If the spec is too large, propose splitting into 2–3 smaller specs with explicit dependencies:

```
This spec covers auth + permissions + audit logging. I recommend splitting:
1. Spec A: Authentication (login/logout/session) — no dependencies
2. Spec B: Role-based permissions — depends on Spec A
3. Spec C: Audit logging — depends on Spec A, independent of Spec B
→ Ship Spec A first?
```

## Visual Companion

For features with a user-facing UI, generate a visual reference alongside the spec:

1. **ASCII wireframe** for layout and component placement:
   ```
   ┌─────────────────────────────────────┐
   │ [Logo]  Dashboard   Settings  [👤]  │
   ├─────────┬───────────────────────────┤
   │ Sidebar │  ┌─────────┐ ┌─────────┐ │
   │ • Home  │  │ Metric  │ │ Metric  │ │
   │ • Users │  │  Card 1 │ │  Card 2 │ │
   │ • Data  │  └─────────┘ └─────────┘ │
   │         │  ┌─────────────────────┐  │
   │         │  │   Chart Area        │  │
   │         │  └─────────────────────┘  │
   └─────────┴───────────────────────────┘
   ```

2. **State diagram** for interactive flows:
   ```
   [Login Page] ──credentials──→ [Validating...]
        │                            │
        │                       ┌────┴────┐
        │                    success    failure
        │                       │         │
        │                  [Dashboard]  [Error Toast]
        │                                 │
        └─────────────────────────────────┘
   ```

3. **Component inventory** listing each UI element with its purpose and states:
   ```
   MetricCard: displays one KPI
     - loading: skeleton shimmer
     - loaded: value + trend arrow
     - error: "Failed to load" with retry button
   ```

**When to include:** Any spec where the user will see a UI. Skip for pure backend, CLI, or infrastructure work.

**Why:** Words describe intent; visuals reveal layout conflicts, missing states, and UX gaps that text alone misses. A 5-minute wireframe prevents a 2-hour "that's not what I meant" after implementation.

## Red Flags

- Starting to write code without any written requirements
- Asking "should I just start building?" before clarifying what "done" means
- Implementing features not mentioned in any spec or task list
- Making architectural decisions without documenting them
- Skipping the spec because "it's obvious what to build"
- Batching multiple questions in one message instead of asking one at a time
- Writing a spec without exploring the existing codebase first
- Presenting only one approach without showing alternatives
- Spec contains `[TODO]`, `[TBD]`, or unfilled placeholders
- Success criteria that aren't concretely testable
- Spec touches 3+ independent subsystems without a split proposal
- UI feature spec with no visual reference (wireframe, state diagram, or component inventory)

## Verification

Before proceeding to implementation, confirm:

- [ ] The existing codebase was explored before writing the spec
- [ ] Questions were asked one at a time, each with a guess attached
- [ ] 2–3 implementation approaches were presented with trade-offs
- [ ] The spec covers all six core areas
- [ ] The spec self-check passed (no placeholders, no contradictions, no vague criteria)
- [ ] Scope was assessed — spec split proposed if too large
- [ ] Visual companion included for UI features (wireframe, state diagram, component inventory)
- [ ] The human has reviewed and approved the spec
- [ ] Success criteria are specific and testable
- [ ] Boundaries (Always/Ask First/Never) are defined
- [ ] The spec is saved to a file in the repository

## Handoff

Spec approved and saved. **Now invoke `td-planning-and-task-breakdown` to break this into implementable tasks.**

Do NOT skip to implementation. Do NOT write code until a plan exists and is approved.
