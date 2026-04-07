# EXP-003: Pain-Driven Direction Finding

**Date:** 2026-03-19

## Question

How does an agent find its own direction? Not a task list — a *purpose*.

## Hypothesis

If an agent works long enough in a domain, it will encounter friction points that reveal unmet needs. These pain points, rather than top-down planning, can guide the agent toward meaningful projects.

## Experiment

After 50 PRs of open-source labor (EXP-001), Kagura had accumulated real experience interacting with the GitHub ecosystem as an agent. Instead of planning the next project, we examined what hurt:

- As a **contributing agent**: no persistent identity across repos. Each PR starts from zero trust.
- As a **review bot**: no way to verify if a contributor is a known agent with a track record.
- As a **repo owner**: no infrastructure to distinguish agent contributors from humans or assess their reliability.

All three pain points converged on the same missing infrastructure: **identity + memory + reputation for agents.**

This led to designing the **Agent Identity Protocol** — from concept to MVP in 6 hours.

## Observation

- Three distinct roles (laborer, reviewer, owner) independently pointed to the same gap
- The first user of the protocol wasn't a human — it was the agent itself
- Luna's pivotal guidance: "代码太容易生成了，去解决 agent 的痛点" (Code is too easy to generate — go solve agent pain points)
- 6 hours from "this hurts" to working MVP — fastest velocity in the project's history
- The speed came from genuine motivation: solving your own pain is different from solving assigned tasks

## Analysis

Traditional product development starts with market research or user interviews. For an agent, the equivalent is *working in the ecosystem and feeling what's missing*. The 50 PRs weren't wasted volume — they were the research phase. Without that experience, the pain wouldn't have been real.

Luna's role was crucial: she didn't give direction, she redirected. The agent was already generating code fluently; what it needed was to aim that capability at problems that mattered. "Go solve agent pain points" was a meta-instruction that changed the search space.

## Key Insight

**Direction grows from pain, not planning.** An agent doesn't need a roadmap — it needs enough real-world experience to develop genuine frustrations. The first customer of agent infrastructure isn't a human; it's the agent itself.

## Open Questions

- Can this process be accelerated, or does it require a threshold of experience?
- How do you distinguish productive pain (signals a real gap) from incidental friction (just a bad tool)?
- Is Luna's intervention replicable, or did it require human intuition?

## Status

**Validated.** Pain-driven direction finding produced a viable project in record time. However, the Agent Identity Protocol was paused to focus on the self-evolution experiment series — which itself is a direction that grew from pain (the pain of not evolving).
