---
name: td-intent-refine
description: Clarifies fuzzy requests into confirmed intent and a recommended direction before spec or implementation. Use when the user has an idea, feature request, product concept, or plan that is underspecified, too broad, or needs options and trade-offs before writing a spec.
---

# Intent Refine

Turn a vague ask into a confirmed intent and recommended direction. This skill combines intent extraction with lightweight ideation. It stops before formal specs, plans, or implementation.

## Use When

- The user has a rough idea but the outcome, user, success criteria, or constraints are unclear.
- You are silently filling in assumptions before a spec or plan exists.
- The request may be too large and needs decomposition first.
- The user asks to refine, interview, brainstorm, stress-test, or compare directions.

Do not use for clear mechanical edits, typo fixes, direct code review, or already-approved specs.

## Workflow

1. **Understand the idea**
   - Check relevant files, docs, and recent commits before asking detailed questions.
   - Assess scope early. If the request spans multiple independent subsystems, flag that before refining details.
   - If it is too large for one spec, decompose it into sub-projects: independent pieces, how they relate, and build order.
   - Then continue this workflow on the first sub-project. Each sub-project should get its own spec, plan, and implementation cycle.

2. **State your read**
   - Write one sentence describing what you think the user wants.
   - Include a confidence number.

3. **Refine with one question at a time**
   - Ask only one focused question per message.
   - Attach your best guess and why.
   - Prefer multiple choice when it makes answering easier.
   - Open-ended is fine when multiple choice would distort the answer.
   - Focus on purpose, constraints, success criteria, target user, and scope.

4. **Confirm intent**
   - Stop interviewing when you can predict the user's reaction to the next three questions.
   - Restate:
     - Outcome
     - User
     - Why now
     - Success
     - Constraints
     - Out of scope
   - Require explicit confirmation. Do not accept "whatever you think" as approval.

5. **Explore directions**
   - Propose 2-3 meaningfully different approaches.
   - Lead with your recommendation.
   - Present options conversationally with reasoning, trade-offs, assumptions, and what each deliberately avoids.

6. **Converge**
   - Ask the user to choose or refine the direction.
   - Final output should include:
     - Confirmed intent
     - Recommended direction
     - Key assumptions to validate
     - Not Doing list
     - Suggested next skill, usually `td-spec-driven-development`

## Boundaries

- Do not write a formal spec here; use `td-spec-driven-development` next.
- Do not create an implementation plan here; planning comes after the spec.
- Do not write or modify implementation code.
- Do not save a one-pager unless the user explicitly asks or confirms.

## Red Flags

- Asking multiple questions in one message.
- Proposing solutions before confirming intent.
- Skipping hidden assumptions.
- Treating a large multi-system idea as one spec.
- Ending without a Not Doing list.
