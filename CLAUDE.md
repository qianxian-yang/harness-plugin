# td-harness

This is the td-harness project — a collection of production-grade engineering skills for AI coding agents.

## Project Structure

```
skills/       → Core skills (SKILL.md per directory)
agents/       → Reusable agent personas (code-reviewer, test-engineer, security-auditor)
hooks/        → Session lifecycle hooks
.claude/commands/ → Slash commands (/test, /review, /code-simplify)
references/   → Supplementary checklists (testing, performance, security, accessibility)
docs/         → Setup guides for different tools
```

## Skills

**Core workflow:** (td-harness)test-driven-development, (td-harness)code-review-and-quality, (td-harness)code-simplification
**Optional domain:** (td-harness)context-engineering, (td-harness)source-driven-development, (td-harness)frontend-ui-engineering, (td-harness)api-and-interface-design, (td-harness)security-and-hardening, (td-harness)performance-optimization
**Meta:** (td-harness)skill-navigation

## Conventions

- Every skill lives in `skills/<name>/SKILL.md`
- YAML frontmatter with `name` and `description` fields
- Description starts with what the skill does (third person), followed by trigger conditions ("Use when...")
- Every skill has: Overview, When to Use, Process, Common Rationalizations, Red Flags, Verification
- References are in `references/`, not inside skill directories
- Supporting files only created when content exceeds 100 lines

## Commands

- `npm test` — Not applicable (this is a documentation project)
- Validate: Check that all SKILL.md files have valid YAML frontmatter with name and description

## Boundaries

- Always: Follow the skill-anatomy.md format for new skills
- Never: Add skills that are vague advice instead of actionable processes
- Never: Duplicate content between skills — reference other skills instead
