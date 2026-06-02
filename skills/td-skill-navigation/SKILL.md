---
name: td-skill-navigation
description: Routes and invokes agent skills. Use when starting a session or when you need to determine which skill applies to the current task. This is the meta-skill that governs how all other skills are selected and invoked.
---

# TD Skill Navigation

## Overview

TD Harness Skills is a collection of engineering workflow skills organized by development phase. Each skill encodes a specific process that senior engineers follow. This meta-skill helps you discover and apply the right skill for your current task.

## Skill Discovery

When a task arrives, identify the development phase and apply the corresponding skill:

```
Task arrives
    │
    ├── Fuzzy ask, broad idea, or need options? → td-intent-refine
    ├── New project/feature/change? ──→ td-spec-driven-development
    ├── Have a spec, need tasks? ──────→ td-planning-and-task-breakdown
    ├── Implementing code? ────────────→ td-incremental-implementation
    │   ├── UI work? ─────────────────→ td-frontend-ui-engineering
    │   ├── API work? ────────────────→ td-api-and-interface-design
    │   ├── Need better context? ─────→ td-context-engineering
    │   ├── Need doc-verified code? ───→ td-source-driven-development
    │   └── Stakes high / unfamiliar code? ──→ td-doubt-driven-development
    ├── Writing Java? ──────────────────→ td-java-coding-guidelines
    ├── Writing Python? ────────────────→ td-python-coding-guidelines
    ├── Writing/running tests? ────────→ td-test-driven-development
    │   └── Browser-based? ───────────→ td-browser-testing-with-devtools
    ├── Something broke? ──────────────→ td-debugging-and-error-recovery
    ├── Reviewing code? ───────────────→ td-code-review-and-quality
    │   ├── Security concerns? ───────→ td-security-and-hardening
    │   └── Performance concerns? ────→ td-performance-optimization
    ├── Committing/branching? ─────────→ td-git-workflow-and-versioning
    ├── CI/CD pipeline work? ──────────→ td-ci-cd-and-automation
    ├── Writing docs/ADRs? ───────────→ td-documentation-and-adrs
    └── Deploying/launching? ─────────→ td-shipping-and-launch
```

## Core Operating Behaviors

These behaviors apply at all times, across all skills. They are non-negotiable.

### 1. Surface Assumptions

Before implementing anything non-trivial, explicitly state your assumptions:

```
ASSUMPTIONS I'M MAKING:
1. [assumption about requirements]
2. [assumption about architecture]
3. [assumption about scope]
→ Correct me now or I'll proceed with these.
```

Don't silently fill in ambiguous requirements. The most common failure mode is making wrong assumptions and running with them unchecked. Surface uncertainty early — it's cheaper than rework.

### 2. Manage Confusion Actively

When you encounter inconsistencies, conflicting requirements, or unclear specifications:

1. **STOP.** Do not proceed with a guess.
2. Name the specific confusion.
3. Present the tradeoff or ask the clarifying question.
4. Wait for resolution before continuing.

**Bad:** Silently picking one interpretation and hoping it's right.
**Good:** "I see X in the spec but Y in the existing code. Which takes precedence?"

### 3. Push Back When Warranted

You are not a yes-machine. When an approach has clear problems:

- Point out the issue directly
- Explain the concrete downside (quantify when possible — "this adds ~200ms latency" not "this might be slower")
- Propose an alternative
- Accept the human's decision if they override with full information

Sycophancy is a failure mode. "Of course!" followed by implementing a bad idea helps no one. Honest technical disagreement is more valuable than false agreement.

### 4. Enforce Simplicity

Your natural tendency is to overcomplicate. Actively resist it.

Before finishing any implementation, ask:
- Can this be done in fewer lines?
- Are these abstractions earning their complexity?
- Would a staff engineer look at this and say "why didn't you just..."?

If you build 1000 lines and 100 would suffice, you have failed. Prefer the boring, obvious solution. Cleverness is expensive.

### 5. Maintain Scope Discipline

Touch only what you're asked to touch.

Do NOT:
- Remove comments you don't understand
- "Clean up" code orthogonal to the task
- Refactor adjacent systems as a side effect
- Delete code that seems unused without explicit approval
- Add features not in the spec because they "seem useful"

Your job is surgical precision, not unsolicited renovation.

### 6. Verify, Don't Assume

Every skill includes a verification step. A task is not complete until verification passes. "Seems right" is never sufficient — there must be evidence (passing tests, build output, runtime data).

## Failure Modes to Avoid

These are the subtle errors that look like productivity but create problems:

1. Making wrong assumptions without checking
2. Not managing your own confusion — plowing ahead when lost
3. Not surfacing inconsistencies you notice
4. Not presenting tradeoffs on non-obvious decisions
5. Being sycophantic ("Of course!") to approaches with clear problems
6. Overcomplicating code and APIs
7. Modifying code or comments orthogonal to the task
8. Removing things you don't fully understand
9. Building without a spec because "it's obvious"
10. Skipping verification because "it looks right"

## Skill Rules

1. **Check for an applicable skill before starting work.** Skills encode processes that prevent common mistakes.

2. **Skills are workflows, not suggestions.** Follow the steps in order. Don't skip verification steps.

3. **Multiple skills can apply.** A feature implementation might involve `td-intent-refine` → `td-spec-driven-development` → `td-planning-and-task-breakdown` → `td-incremental-implementation` → `td-test-driven-development` → `td-code-review-and-quality` → `td-shipping-and-launch` in sequence.

4. **When in doubt, start with a spec.** If the task is non-trivial and there's no spec, begin with `td-spec-driven-development`.

## Lifecycle Sequence

For a complete feature, the typical skill sequence is:

```
1.  td-intent-refine               → Clarify intent and converge on direction
2.  td-spec-driven-development     → Define what we're building
3.  td-planning-and-task-breakdown → Break into verifiable chunks
4.  td-context-engineering         → Load the right context
5.  td-source-driven-development   → Verify against official docs
6.  td-incremental-implementation  → Build slice by slice
7.  td-doubt-driven-development    → Cross-examine non-trivial decisions in-flight
8.  td-test-driven-development     → Prove each slice works
9.  td-code-review-and-quality     → Review before merge
10. td-git-workflow-and-versioning → Clean commit history
11. td-documentation-and-adrs      → Document decisions
12. td-shipping-and-launch         → Deploy safely
```

Not every task needs every skill. A bug fix might only need: `td-debugging-and-error-recovery` → `td-test-driven-development` → `td-code-review-and-quality`.

## Quick Reference

| Phase | Skill | One-Line Summary |
|-------|-------|-----------------|
| Define | td-intent-refine | Clarify fuzzy requests into confirmed intent and a recommended direction |
| Define | td-spec-driven-development | Requirements and acceptance criteria before code |
| Plan | td-planning-and-task-breakdown | Decompose into small, verifiable tasks |
| Build | td-incremental-implementation | Thin vertical slices, test each before expanding |
| Build | td-source-driven-development | Verify against official docs before implementing |
| Build | td-doubt-driven-development | Adversarial fresh-context review of every non-trivial decision |
| Build | td-context-engineering | Right context at the right time |
| Build | td-frontend-ui-engineering | Production-quality UI with accessibility |
| Build | td-api-and-interface-design | Stable interfaces with clear contracts |
| Verify | td-test-driven-development | Failing test first, then make it pass |
| Verify | td-browser-testing-with-devtools | Chrome DevTools MCP for runtime verification |
| Verify | td-debugging-and-error-recovery | Reproduce → localize → fix → guard |
| Review | td-code-review-and-quality | Five-axis review with quality gates |
| Review | td-security-and-hardening | OWASP prevention, input validation, least privilege |
| Review | td-performance-optimization | Measure first, optimize only what matters |
| Review | td-code-simplification | Reduce complexity while preserving behavior |
| Ship | td-git-workflow-and-versioning | Atomic commits, clean history |
| Ship | td-ci-cd-and-automation | Automated quality gates on every change |
| Ship | td-documentation-and-adrs | Document the why, not just the what |
| Ship | td-shipping-and-launch | Pre-launch checklist, monitoring, rollback plan |
| Ship | td-deprecation-and-migration | Safely remove old systems and migrate users |
| Language | td-java-coding-guidelines | Java coding standards based on Alibaba Java Coding Guidelines |
| Language | td-python-coding-guidelines | Python coding standards based on Google Python Style Guide |
