---
description: Break work into small verifiable tasks with acceptance criteria and dependency ordering
---

Invoke the harness-skills:td-planning-and-task-breakdown skill.

Read the existing spec (`docs/td-harness/YYYY-MM-DD-<feature-name>/spec.md` or equivalent) and the relevant codebase sections. Then:

1. Enter plan mode — read only, no code changes
2. Identify the dependency graph between components
3. Slice work vertically (one complete path per task, not horizontal layers)
4. Write tasks with acceptance criteria and verification steps
5. Add checkpoints between phases
6. Present the plan for human review

Save the plan to `docs/td-harness/YYYY-MM-DD-<feature-name>/plan.md` and task list to `docs/td-harness/YYYY-MM-DD-<feature-name>/todo.md`.

`<feature-name>` is a short kebab-case slug (e.g., `user-auth`, `payment-flow`). `YYYY-MM-DD` is today's date. Reuse the same directory created by `/td-spec` if it exists. Derive the slug from the spec or the user's request. If unclear, ask before saving.

After the plan is approved, automatically invoke `td-incremental-implementation` to begin executing the first task. Do NOT wait for the user to manually request it.
