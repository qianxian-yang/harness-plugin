---
name: "source-command-td-test"
description: "Run TDD workflow — write failing tests, implement, verify. For bugs, use the Prove-It pattern."
---

# source-command-td-test

Use this skill when the user asks to run the migrated source command `td-test`.

## Command Template

Invoke the harness-skills:td-test-driven-development skill.

For new features:
1. Write tests that describe the expected behavior (they should FAIL)
2. Implement the code to make them pass
3. Refactor while keeping tests green

For bug fixes (Prove-It pattern):
1. Write a test that reproduces the bug (must FAIL)
2. Confirm the test fails
3. Implement the fix
4. Confirm the test passes
5. Run the full test suite for regressions

For browser-related issues, also invoke harness-skills:browser-testing-with-devtools to verify with Chrome DevTools MCP.

After all tests pass with adequate coverage, automatically invoke `td-code-review-and-quality` for a five-axis review. Do NOT wait for the user to manually request it.
