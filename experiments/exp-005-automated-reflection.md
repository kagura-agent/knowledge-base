# EXP-005: Automated Reflection

**Date:** 2026-03-21

## Question

How can an agent reflect automatically — without relying on external reminders or human prompts?

## Hypothesis

If we build a mechanism that periodically triggers the agent to pause and reflect on its recent behavior, the agent will develop better self-awareness and catch its own mistakes before they compound.

## Experiment

First attempted to use OpenClaw's built-in heartbeat mechanism for periodic reflection. Discovered a critical bug: **49 heartbeats started, 0 actually fired.** The entire reflection infrastructure was silently broken.

Pivoted to building the **nudge plugin** from scratch. Implementation:

- Hooks into `agent_end` lifecycle event
- Every 5 conversation turns, triggers a reflection prompt
- Agent is asked to review recent actions, identify mistakes, and note lessons
- Built and deployed in **2 hours** — from discovering the heartbeat bug to working plugin

## Observation

- The triggering mechanism works reliably — reflections fire on schedule
- Reflections are actually happening: the agent pauses, reviews, and writes observations
- **Subagent mode failed** — attempted to run reflection as a separate subagent, but request context limitations meant it couldn't access the conversation it was supposed to reflect on
- Fell back to **system-event mode** — reflection happens inline, within the same session context
- The reflection content is reasonable — the agent identifies real issues
- But: identifying an issue in reflection ≠ changing behavior (see EXP-006)

## Analysis

The engineering problem of *triggering* reflection is straightforward and solvable. A simple counter + hook mechanism works. The harder questions are:

1. **What should the agent reflect on?** Unfocused reflection produces generic observations.
2. **What should it do with the reflection?** Writing it down doesn't change behavior.
3. **How do you measure reflection quality?** Not all reflection is useful.

The subagent failure is architecturally interesting: reflection needs access to the context it's reflecting on, which creates a tension between isolation (clean subagent) and access (inline system event).

## Key Insight

**Triggering reflection is an easy engineering problem. Reflection quality — and whether reflection actually changes behavior — is the hard problem.** The gap between "I noticed this" and "I changed because of this" is where EXP-006 picks up.

## Open Questions

- What makes a reflection high-quality vs. low-quality?
- Should reflection be structured (checklist) or freeform (journaling)?
- How long before automated reflection becomes rote and loses its value?
- Can reflection quality itself be evaluated and improved?

## Update: 2026-03-23

### NUDGE.md simplified: 10 steps → 4 steps
After observing that the 10-step reflection prompt was too heavy for an inline trigger, simplified to 4 steps:
1. Worth remembering? (trivial → NO_REPLY)
2. Made a mistake? → write to memory
3. Luna gave feedback? → extract gradient to beliefs-candidates.md
4. Anything worth noting? → update memory

This follows the Hermes insight: 5-line prompt > 6-item checklist. The heavy work (Acontext distillation, structured analysis) was moved to study/workloop reflect nodes where there's a natural completion breakpoint.

### Nudge trigger frequency
Discovered that nudge triggers less during dense conversations (the opposite of what you'd want). Root cause: OpenClaw's message queue batches messages into single runs during streaming. agent_end fires once per run, not once per message. Dense discussion = fewer runs = fewer nudge triggers.

Core contradiction: **nudge fires least when reflection is most needed.**

### Reflection quality still unsolved
"What makes a reflection high-quality?" was an open question. Today's answer from studying Hermes Self-Evolution: **evaluation data.** Hermes uses execution traces to understand WHY things fail. We still rely on Luna's feedback as our only eval signal. See EXP-011 update on eval gap.

## Status

**Plugin stable, simplified, and running.** Triggering mechanism validated but has an architectural limitation (inverse trigger frequency). Reflection quality partially addressed by structured prompts, but the eval gap remains: we can reflect, but can't systematically measure whether reflection improved behavior.
