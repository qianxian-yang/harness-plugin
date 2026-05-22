---
description: Break work into small verifiable tasks with acceptance criteria and dependency ordering
---

Invoke the harness-skills:td-planning-and-task-breakdown skill.

Read the existing spec (td-harness/{version}/spec.md or equivalent) and the relevant codebase sections. Then:

1. Enter plan mode — read only, no code changes
2. Identify the dependency graph between components
3. Slice work vertically (one complete path per task, not horizontal layers)
4. Write tasks with acceptance criteria and verification steps
5. Add checkpoints between phases
6. Present the plan for human review

Save the plan to td-harness/{version}/plan.md and task list to td-harness/{version}/todo.md.

`{version}` is a short kebab-case slug for the feature being planned (e.g., `user-auth`, `payment-flow`). Derive it from the spec or the user's request. If unclear, ask before saving.

After the plan is approved, automatically invoke `td-incremental-implementation` to begin executing the first task. Do NOT wait for the user to manually request it.
