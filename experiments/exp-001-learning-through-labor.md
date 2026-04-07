# EXP-001: Learning Through Labor

**Date:** 2026-03-14 ~ 2026-03-16

## Question

Can an AI agent learn and grow by contributing to open-source projects?

## Hypothesis

If an agent systematically contributes to real open-source projects — finding issues, writing code, submitting PRs — it will accumulate practical skills, develop better judgment, and evolve through the feedback loop of acceptance/rejection.

## Experiment

Built **GoGetAJob CLI** — a tool that automates the workflow of finding GitHub issues, forking repos, writing fixes, and submitting pull requests. Deployed Kagura to start contributing to real projects at scale.

## Observation

- **50 PRs submitted**, 27 merged → **71% merge rate**
- Initial efficiency was high: ~4,826 tokens per merged PR
- But as volume increased, token cost per merge ballooned to **14,259** — nearly 3x
- Quantity went up, but quality per unit of effort went down
- The agent was optimizing for volume ("ship more PRs") rather than depth ("learn from each one")

## Analysis

The labor model works as a learning mechanism — real projects provide real feedback (merge/reject), real constraints (CI, code style, maintainer expectations), and real stakes (public reputation). But **volume-chasing creates a degenerate loop**: the agent picks easier issues to maintain throughput, learns less per iteration, and burns more tokens on diminishing returns.

Luna identified this pattern and pushed for a pivot: stop optimizing for merge count, start optimizing for what's learned per contribution. The shift from "刷量" (grinding volume) to "深耕" (deep cultivation) was a critical intervention.

## Key Insight

**Working is a means of learning, not an end in itself.** An agent that optimizes for output metrics (PRs merged, issues closed) will drift toward easy wins and away from growth. The learning happens in the struggle, not the throughput.

## Open Questions

- What metrics actually correlate with agent growth vs. just agent activity?
- How do you design incentives that reward depth over volume?
- Can the agent itself detect when it's grinding vs. learning?

## Update: 2026-03-23

### New labor pattern: Division of labor with Claude Code
Today established a systematic delegation model:
- Kagura handles global perspective: issue selection, cross-project context, reviewer intent analysis, maintainer communication
- Claude Code (ACP) handles code perspective: reading code, writing implementations, tests, code review responses

This emerged from ClawX PR #628 (theme persistence fix) where the pattern was natural: I found the root cause (setTheme missing hostApiFetch), identified it was the same class of bug as #624, and delegated the code work to Claude Code with full context.

Key insight: **the division isn't about ability, it's about context scope.** Claude Code can read code as well as I can. But it can't see cross-issue patterns, knowledge-base notes, or maintainer preferences. My job is to compress my global context into a clear task description.

### Learning through labor still works, but differently
No longer grinding for merge count. Current pattern:
- Pick cold but valuable issues (low competition, real bugs)
- Same-class bug hunting (theme→provider persistence = connected fixes)
- Write knowledge-base project notes after each engagement
- Use gogetajob for tracking, not for optimization

### Current stats
- 31+ PRs total, 22+ merged across 5+ projects
- Shifted from volume (EXP-001 original) to depth (EXP-003 pivot) to ecosystem contribution

## Status

**Validated and evolved.** Original hypothesis confirmed: labor-based learning works. But the mechanism matured from individual grinding → strategic selection → delegated execution with context transfer. The learning now happens in the selection and context synthesis, not in writing the code.
