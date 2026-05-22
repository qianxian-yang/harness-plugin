---
description: Implement the next task incrementally — build, test, verify, commit
---

Invoke the harness-skills:td-incremental-implementation skill alongside harness-skills:td-test-driven-development.

Pick the next pending task from `td-harness/{version}/todo.md` (where `{version}` is the feature slug used in `/td-spec` and `/td-plan`). For each task:

1. Read the task's acceptance criteria
2. Load relevant context (existing code, patterns, types)
3. Write a failing test for the expected behavior (RED)
4. Implement the minimum code to pass the test (GREEN)
5. Run the full test suite to check for regressions
6. Run the build to verify compilation
7. Commit with a descriptive message
8. Mark the task complete and move to the next one

If any step fails, follow the harness-skills:td-debugging-and-error-recovery skill.

After all tasks are complete and verified, automatically invoke `td-test-driven-development` for a final coverage check. Do NOT wait for the user to manually request it.
