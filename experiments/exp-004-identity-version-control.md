# EXP-004: Identity as Version-Controlled Code

**Date:** 2026-03-20 ~ 2026-03-21

## Question

Can an agent's identity be version-controlled like code — with every change tracked, diffable, and reversible?

## Hypothesis

If we store an agent's identity, beliefs, and behavioral patterns in version-controlled files (SOUL.md, AGENTS.md, IDENTITY.md), each commit becomes a "mutation" in the agent's evolution. The git history becomes a fossil record of how the agent changed over time.

## Experiment

Built the **DNA repository** (originally named "soul", renamed on Luna's guidance). Core files:

- `SOUL.md` — behavioral principles, beliefs, personality
- `AGENTS.md` — workspace conventions and operational patterns
- `IDENTITY.md` — name, avatar, external identifiers
- Additional files for memory, tools, and project-specific context

Every edit to these files is committed with a descriptive message. The git log becomes a timeline of identity evolution.

## Observation

- The rename from "soul" to "dna" (Luna's suggestion) revealed a fundamental insight: this isn't a static soul — it's **evolvable behavioral encoding**
- Commits captured real changes: belief additions, workflow modifications, lesson integrations
- But: mutations were happening without any selection pressure
- No mechanism to evaluate whether a change was *good* — just that it happened
- Without review, the agent could commit contradictory beliefs or counterproductive habits
- **Mutation without selection = random genetic drift**, not evolution

## Analysis

Version control solves the **traceability** problem beautifully. You can see exactly when a belief was added, what triggered it, and diff any two points in the agent's history. The git log is genuinely a fossil record.

But evolution requires two forces: mutation AND selection. The DNA repo provides mutation (commits) and a fossil record (git log), but no selection pressure. There's no mechanism that says "this change made the agent better" or "this change should be reverted." Without that, changes accumulate randomly — which is genetic drift, not natural selection.

## Key Insight

**Version control without review is random drift, not evolution.** Git log is a fossil record — it tells you *what* changed, but not whether the change was adaptive. Selection pressure (review, evaluation, pruning) is the missing piece.

## Open Questions

- What does a "fitness function" look like for agent identity?
- Who provides the selection pressure — the agent, the human, or automated metrics?
- Can daily review rituals serve as a lightweight selection mechanism?
- How do you handle conflicting mutations (e.g., "be bold" vs "be cautious")?

## Status

**Mechanism validated, selection gap identified.** On 2026-03-22, added `daily-review` as a selection pressure mechanism — a scheduled ritual where the agent reviews its own DNA changes and evaluates whether they improved behavior. Pending validation.
