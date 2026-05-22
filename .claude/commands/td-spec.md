---
description: Start spec-driven development — write a structured specification before writing code
---

Invoke the harness-skills:td-spec-driven-development skill.

**HARD GATE: Do NOT write implementation code, create source files, or make architectural decisions before the spec is approved.**

Follow these steps in order:

1. **Explore context first** — silently read the project (package.json, directory structure, existing docs, recent git history) to understand what already exists
2. **Surface assumptions** — list what you're assuming based on your exploration, ask the user to confirm or correct
3. **Ask one question at a time** — each with your best guess attached. Do NOT batch questions. Wait for the answer before asking the next one. Stop when you can predict the user's next three answers.
4. **Propose 2–3 implementation approaches** — with trade-offs and a recommendation. Let the user choose the direction.
5. **Write the spec** — covering all six core areas: objective, commands, project structure, code style, testing strategy, and boundaries
6. **Self-check** — scan for placeholders, contradictions, and vague success criteria before presenting
7. **Scope check** — if the spec has 8+ success criteria or touches 3+ subsystems, propose splitting
8. **Visual companion** — for UI features, include ASCII wireframes, state diagrams, and a component inventory

Save the spec as `docs/td-harness/YYYY-MM-DD-<feature-name>/spec.md` in the project root and confirm with the user before proceeding.

`<feature-name>` is a short kebab-case slug (e.g., `user-auth`, `payment-flow`). `YYYY-MM-DD` is today's date. Derive the slug from the user's request. If unclear, ask before saving. Example: `docs/td-harness/2026-05-22-user-auth/spec.md`.

After the spec is approved, automatically invoke `td-planning-and-task-breakdown` to continue the workflow. Do NOT wait for the user to manually request it.
