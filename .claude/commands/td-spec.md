---
description: Start spec-driven development — write a structured specification before writing code
---

Invoke the harness-skills:td-spec-driven-development skill.

Begin by understanding what the user wants to build. Ask clarifying questions about:
1. The objective and target users
2. Core features and acceptance criteria
3. Tech stack preferences and constraints
4. Known boundaries (what to always do, ask first about, and never do)

Then generate a structured spec covering all six core areas: objective, commands, project structure, code style, testing strategy, and boundaries.

Save the spec as td-harness/{version}/spec.md in the project root and confirm with the user before proceeding.

`{version}` is a short kebab-case slug for the feature being specced (e.g., `user-auth`, `payment-flow`). Derive it from the user's request. If unclear, ask before saving.
