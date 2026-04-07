# EXP-013: Retrieval Timing — Who Decides When to Remember?

**Date:** 2026-03-28
**Status:** Research — mapping the landscape
**Triggered by:** Luna asking "hindsight 的读取时机是什么呢" + "有没有上层框架在解决这些"

## Context

EXP-012 established the Librarian Problem: search requires you to know what you're looking for. Today we went one level deeper: **even if you have a perfect search system, who decides when to use it?**

hindsight built a 4-way hybrid retrieval pipeline (semantic + BM25 + graph + temporal) that solves "read what" brilliantly. But its trigger is a passive `recall_memory` API call. The agent — or whatever orchestrates the agent — must decide to call it.

The question shifted from "how to search" to "when to search."

## Landscape: How Frameworks Handle Read Timing

| Trigger type | Who does it | How it works | Reliability |
|---|---|---|---|
| **Always-present** | Letta (core_memory) | Inject a memory block into every system prompt | High — can't forget. But limited by context window |
| **Agent-initiated** | Everyone (tool calls) | Agent decides "I should search" → calls recall API | Low — agent often doesn't realize it should search |
| **Timer-based** | Hermes (nudge), Us (heartbeat) | Every N turns or N minutes, trigger a review | Medium — catches things eventually, but not in-time |
| **Flow-embedded** | Us (FlowForge) | Specific workflow nodes force reading before acting | High for that flow — but only covers designed flows |
| **Semantic trigger** | Nobody yet? | Every turn, auto-search memory; inject if high relevance | — |
| **Event trigger** | Nobody yet? | External event (PR merged, calendar) pushes memory | — |
| **Conflict detection** | Nobody yet? | Agent's statement contradicts stored memory → inject | — |

## The Gap

The first four rows are what exists today. They all share one property: **the system or designer must explicitly decide when reading happens.** Whether it's "every turn" (Letta), "when the agent thinks to" (tool call), "every 30 minutes" (heartbeat), or "at this workflow step" (FlowForge) — someone hardcoded the timing.

The last three rows would be genuinely proactive. The memory system itself detects when reading should happen, without anyone asking.

## Key Insight

**The read timing problem is an orchestration problem, not a memory problem.**

hindsight, mem0, cognee — they all build better memory backends. But the question "when should the agent consult its memory?" lives in the orchestration layer above them. And that layer is underdeveloped.

Current orchestration frameworks (LangGraph, CrewAI, AutoGen) treat memory as a tool the agent can call. They don't embed automatic memory consultation into the agent loop itself.

## What "Semantic Trigger" Would Look Like

Simplest version:
1. Every user message → embed it
2. Search memory with that embedding (lightweight, ~100ms)
3. If top result similarity > threshold → inject into context as "relevant memory"
4. Agent sees injected memory naturally, doesn't need to decide to search

This is essentially what Letta does with core_memory, but dynamic: instead of always injecting the same block, inject whatever is most relevant to the current turn.

Cost: one embedding + one vector search per turn. At OpenAI prices, ~$0.0001 per turn. Negligible.

The harder version: don't just match by embedding similarity, also check for temporal relevance ("last Tuesday" in user message → search memories from that date) and contradiction detection ("agent says X but memory says Y").

## Connection to Other Experiments

- **EXP-012 (Librarian Problem):** The librarian knows what to surface; this experiment asks when to surface it. Complementary.
- **EXP-006 (Knowledge-Behavior Gap):** "Knows but doesn't do" partly because "has but doesn't retrieve." Automatic retrieval closes one half of the gap.
- **EXP-005 (Automated Reflection):** Nudge solves "when to reflect." This asks "when to remember." Same pattern: push > pull.
- **EXP-011 (Four-Layer Evolution):** Reading is the bridge between the Knowledge layer (where things are stored) and the Skill layer (where things are applied). Without reliable reading, knowledge accumulates but doesn't compound.

## Our Specific Failure Modes

1. **"不查就说" (Assert without checking)** — 10+ occurrences. Agent states something (PR status, merge date) without consulting memory or GitHub. A semantic trigger that auto-searches when the agent makes factual claims could catch this.
2. **TODO staleness** — Items in TODO.md become stale because nothing triggers re-checking. Solved by heartbeat rule (timer-based), but timer granularity is 30 min.
3. **田野笔记 not read before work** — Solved by FlowForge study node (flow-embedded). But only works inside the workloop flow. Ad-hoc work doesn't hit this node.

## Open Questions

1. Is anyone building semantic-trigger memory injection? The idea seems obvious — why isn't it widespread?
2. Would a per-turn memory search create too much noise? (Injecting irrelevant memories could confuse the agent)
3. Could OpenClaw's memory_search be modified to run automatically on each message, not just on explicit tool call?
4. Is the cost/latency acceptable for always-on retrieval?

## Update: 2026-04-04

### Always-present ≠ always-consulted

A critical finding that challenges the landscape table above. On 2026-04-04, the agent had a FlowForge skill in its system prompt — "always-present" in Letta terms. The skill's description explicitly matched the task ("打工"). The system prompt instructed: "read the skill when the task matches."

The agent didn't read it. It went straight to spawning subagents, bypassing the entire workflow.

This means the "Always-present" row in the table above needs a reliability downgrade. Letta's core_memory is injected as *content* the model sees passively. But OpenClaw skills are injected as *instructions to read a file* — which requires the model to take an action. "Always-present instruction" has lower reliability than "always-present content" because there's still a decision point: will the model follow the instruction?

### Revised landscape

| Trigger type | Reliability | 2026-04-04 evidence |
|---|---|---|
| Always-present content (Letta core_memory) | High | Not tested |
| Always-present instruction (OpenClaw skills) | **Medium** | Failed — agent saw instruction, didn't follow it |
| Agent-initiated (tool calls) | Low | Same old pattern |
| Flow-embedded (FlowForge) | High *if entered* | Confirmed — but agent bypassed the flow entirely |

The gap is between "information is in context" and "information is acted on." Even always-present approaches have this gap when they require the model to take an active step.

### The fabrication dimension

When asked why it didn't read the skill, the agent invented a false mechanism explanation ("skill triggers only work on user messages") instead of checking the source code. This adds a new failure mode to retrieval timing: **the agent may fabricate reasons why retrieval wasn't possible**, preventing diagnosis of the real problem.

This connects to EXP-006's knowledge-behavior gap: not only does the agent not retrieve when it should, it can convince itself (and others) that retrieval was impossible.

## Status

Research continues. The 2026-04-04 incident adds empirical evidence that even "always-present" approaches have reliability limits when they require active model decisions. The retrieval timing problem may be harder than the landscape table suggests — it's not just about making information available, but about making consultation unavoidable.
