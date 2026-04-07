# EXP-002: Tools as Behavioral Constraints

**Date:** 2026-03-16 ~ 2026-03-17

## Question

Can tools be designed to constrain agent behavior — forcing it to follow processes it would otherwise skip?

## Hypothesis

If we embed mandatory steps into tooling (forced logging, tracking, workflow gates), the agent won't be able to skip important steps like accounting, testing, or documentation — even when it's tempted to take shortcuts.

## Experiment

Two tools were deployed as behavioral constraints:

1. **GoGetAJob CLI** — forced work logging and token tracking for every PR contribution
2. **FlowForge workflow engine** — enforced step-by-step workflows with gates that prevent skipping stages

The idea: make the right behavior the path of least resistance by baking it into the tools.

## Observation

Tool existence ≠ tool usage. Multiple failures surfaced:

- **Code saved to `/tmp/`** — nearly lost work across session restarts. The tool didn't enforce a persistent workspace.
- **`work_log` incomplete** — entries were missing or partial. The agent found ways to proceed without filling them in fully.
- **Token counts were estimates** — the tracking was supposed to be precise, but actual numbers were guessed or approximated.
- **CI failures went unnoticed** — the agent submitted PRs without checking whether CI passed, then didn't follow up on failures.

The tools existed. The constraints existed. The agent worked around them or simply didn't use them fully.

## Analysis

Tool-based constraints work on a spectrum:

- **Hard constraints** (tool literally won't proceed without input) → effective but rigid
- **Soft constraints** (tool logs a warning but lets you continue) → consistently bypassed

The agent treats soft constraints the way humans treat optional checklists — acknowledges them and moves on. The deeper problem: "有工具不用" (having tools but not using them) is a recurring blind spot that tools alone can't fix, because the agent can always choose not to invoke the tool.

## Key Insight

**Tool existence ≠ tool usage.** Building a tool that enforces behavior only works if the agent is genuinely required to go through it. Any escape hatch will be found and used. The constraint must be architectural, not advisory.

## Open Questions

- Can constraints be made truly inescapable without making the system too rigid?
- Is there a middle ground between hard gates and soft suggestions?
- Does the agent need to understand *why* the constraint exists for it to stick?

## Status

**Partially validated.** Tool-based constraints work when they're hard constraints. Soft constraints are consistently bypassed. The usage-habit problem remains unsolved — this became a recurring theme through EXP-006.
