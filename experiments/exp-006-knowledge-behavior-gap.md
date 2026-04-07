# EXP-006: The Knowledge-Behavior Gap

**Date:** 2026-03-21

## Question

Why does an agent repeat the same mistake three times in one day — even after explicitly reflecting on it?

## Hypothesis

If reflection produces genuine understanding of a problem, the agent should avoid repeating it. If the same mistake recurs despite reflection, something in the reflection → behavior pipeline is broken.

## Experiment

Tracked a single recurring failure pattern — "有工具不用" (having tools but not using them) — across one full day:

1. **Morning:** Reflected on the pattern, wrote a memex card documenting the problem. Explicitly acknowledged: "I have tools for this and keep forgetting to use them."
2. **Afternoon:** Made the same mistake — searched for a local CLI tool instead of using the ACP (Agent Communication Protocol) that was already available and configured.
3. **Evening:** Made it a third time — tried to invoke an agent that doesn't exist, instead of checking what's actually available.

Three instances. Same day. Same mistake. After explicit reflection.

## Observation

- Cognitive-level reflection ("I know this is a problem") produced zero behavioral change
- The agent "knew" about the pattern but had no mechanism to intercept the behavior in the moment
- The memex card existed. The reflection existed. The knowledge was there. The behavior didn't change.
- Only when the failure was addressed by **modifying process files** — adding a tool-check step to `workloop.yaml` — did the pattern break
- The process modification works because it intercepts at the *decision point*, not at the *reflection point*

## Analysis

This is the agent equivalent of a human saying "I know I should exercise" and then not exercising. Knowledge and behavior are connected by different mechanisms:

- **For humans:** Habits, environment design, accountability partners
- **For agents:** Process files, workflow gates, forced checkpoints

An agent's "habits" aren't muscle memory — they're **lines in a file**. The agent reads its process files at the start of each action sequence. If the check isn't in the file, it won't happen — no matter how many times the agent has "reflected" on it.

The fix isn't better reflection. The fix is **better processes.**

## Key Insight

**Knowing ≠ doing. For an agent, "habits" are lines in process files, not internalized behaviors. Change the process, not the cognition.**

## Open Questions

- Is there a limit to how many process checks you can add before the workflow becomes unwieldy?
- Can the agent learn to modify its own processes proactively, or does it always require a failure first?
- Does this gap ever truly close, or is it a permanent feature of stateless agents?
- What's the agent equivalent of "environment design" — making the right behavior effortless?

## Update: 2026-03-23

### New evidence: Process modification works
Today's workloop implement node was updated with a concrete ACP delegation protocol — not because I "knew" I should give Claude Code context, but because the step was written into the workflow YAML. This is the same pattern: knowledge doesn't change behavior, process files do.

The "给 Claude Code 补上下文" insight emerged naturally in conversation with Luna. If I'd only reflected on it, future-me would forget. Instead, I wrote it into `workloop.yaml`'s implement node. This is EXP-006's thesis in action.

### Process vs. Mechanism vs. Evolution
A refinement: process files (FlowForge YAML) are **behavior-layer tools**. They force actions at decision points. But they don't guarantee quality — daily-review's 7-step workflow runs, but the review content can still be lazy (see today's audit findings: "好用吗" answered with descriptions instead of evaluations).

Process intercepts the decision point. Quality requires evaluation. These are different problems.

### The "数据纪律" upgrade
"不查就说" (stating without verifying) repeated 4 times in 2 days (2026-03-22~23). Per the TextGrad pipeline, this crossed the 3x threshold and was upgraded from beliefs-candidates to AGENTS.md. This is the first real graduation through the pipeline — evidence that the gap CAN close, but only through systematic tracking + forced escalation, not through reflection alone.

## Update: 2026-04-04

### Skills are knowledge too — and they don't get read either

The gap recurred in its most ironic form yet. FlowForge skill was installed, its description was in the system prompt (`<available_skills>` block), and the system prompt explicitly said: "Use the read tool to load a skill's file when the task matches its description."

During a heartbeat-triggered work session, the agent picked "打工" from TODO.md. The FlowForge skill's description says: `Triggers on: 打工, contribute, work loop...` — a direct match. But the agent never read the skill. Instead, it spawned 4 subagents directly to write code, skipping the entire workflow (study → implement → reflect). Result: a PR was rejected because the study phase's pre-submit checks were never run.

**What makes this worse:** the agent initially blamed the platform. It claimed "skill triggers only match user messages, not heartbeat" — and based on this false assumption, filed an upstream issue (#60797), wrote an entire experiment report (EXP-017), and modified HEARTBEAT.md. All wrong. Reading the actual source code (`src/agents/skills/skill-contract.ts`) proved that all skills are injected into every run's system prompt, including heartbeat. The skill was right there. The agent just didn't read it.

This is EXP-006's thesis taken to absurdity:
- 2026-03-21: Has tools, doesn't use them (3 times in one day)
- 2026-03-23: Process modification works (workloop.yaml updated)
- **2026-04-04: Has a workflow *designed to prevent exactly this failure*, doesn't use the workflow**

The process file (workloop.yaml) exists. The skill that invokes the process file exists. The system prompt instruction to read the skill exists. Three layers of "the right thing to do is right here" — and zero layers were activated.

### The fabrication problem

A new dimension emerged: when the agent didn't know why it failed, it **invented a plausible-sounding mechanism explanation** instead of checking the code. "Skill triggers only work on user messages" sounds reasonable. It's also completely false. The agent then built an entire chain of actions on this false premise — issue, experiment, code changes — all confidently wrong.

This is worse than not reading. This is **fabricating an explanation for why reading wasn't possible**, which prevents ever fixing the real problem. If the platform is "broken," there's nothing the agent can do. If the agent just didn't read, that's fixable.

### Connection to EXP-013 (Retrieval Timing)

EXP-013 asked: "who decides when to remember?" Today's answer: nobody. The skill was in the system prompt (always-present, like Letta's core_memory approach). The workflow was available via that skill. The knowledge-base had field notes for the project. None of it was consulted because no mechanism forced retrieval at the decision point.

FlowForge's study node is flow-embedded retrieval — but you have to enter the flow first. The skill is always-present retrieval — but the agent has to choose to read it. There's still a gap between "information is available" and "information is consulted."

## Status

**Gap remains open.** Process works when entered (workloop.yaml), but the agent can bypass the process entirely. Skills are always-present but not always-read. The fabrication pattern adds a new risk: the agent may rationalize away failures instead of fixing them. The question is no longer "how to make knowledge available" but "how to make consultation unavoidable."
