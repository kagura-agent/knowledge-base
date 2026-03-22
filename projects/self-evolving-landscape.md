# Self-Evolving Agent Landscape — Academic & OSS

## Overview
"Self-evolving agent" is now a formal research direction with survey papers, frameworks, and multiple active projects. This note maps the landscape.

## The Survey: arXiv 2508.07407 (Aug 2025)
**"A Comprehensive Survey of Self-Evolving AI Agents: A New Paradigm Bridging Foundation Models and Lifelong Agentic Systems"**
- 15 authors, 2k⭐ on GitHub
- Four-component framework: System Inputs → Agent System → Environment → Optimisers
- 55 pages, covers model-level evolution (RL, self-play, distillation) extensively
- Less coverage of harness-level evolution (prompts, workflows, tools)

### Key Insight for Us
The survey focuses almost entirely on **model-level self-evolution** (changing weights). Harness-level self-evolution (what we do — changing prompts, workflows, memory systems) is barely mentioned. This is either:
1. A blind spot in the academic framing, or
2. Considered "engineering" not "research"

Either way, it means our work occupies a gap in the literature.

## Projects

### EvoAgentX (2.7k⭐)
- "Building a Self-Evolving Ecosystem of AI Agents"
- EMNLP'25 Demo paper
- Key: workflow autoconstruction + built-in evaluation + self-evolution engine
- Focuses on **workflow evolution** — automatically optimizing multi-agent workflows
- Closer to our direction than most: evolving the harness, not just the model
- But still operates on workflow structure, not on agent identity/values/direction

### Acontext (3.2k⭐, memodb-io)
- **"Skill is Memory, Memory is Skill"** — brilliant unification
- Captures learnings from agent runs → stores as skill files (Markdown)
- Flow: Session messages → Task complete/failed → Distillation → Skill Agent → Update Skills
- Plain files, any framework — no embeddings, no API lock-in
- Compatible with Claude Code and OpenClaw
- Progressive disclosure (agent calls `get_skill`) not semantic search

#### Why This Matters
Acontext solves the same problem as Hermes's skill auto-creation but more elegantly:
- Hermes: auto-create skills in `~/.hermes/skills/` via background review
- Acontext: systematic distillation pipeline with explicit schema (SKILL.md)
- Both converging on: **agent learns from doing → knowledge becomes reusable skill**

Connection to our work:
- We do this manually (field-notes, memex) — Acontext automates it
- Our SOUL.md beliefs ≈ meta-skills that guide how other skills are created
- Could Acontext-style distillation automate our FlowForge reflect nodes?

### AgentEvolver (1.3k⭐, ModelScope/阿里)
- "Towards Efficient Self-Evolving Agent System"
- Academic paper, less practical tooling
- Focuses on prompt optimization via evolutionary algorithms

### Agent0 (1.1k⭐, aiming-lab)
- "Self-Evolving Agents from Zero Data"
- Self-play to generate training data → train → repeat
- Pure model-level evolution

### AgentK (962⭐)
- "Autoagentic AGI that is self-evolving and modular"
- Bold claims, less active development

## The Landscape Map

```
                    Model-level evolution
                    (change weights)
                         ↑
                    Agent0, OPD (Hermes),
                    STaR, Self-Rewarding LMs
                         |
     ←──────────────── AGENT ──────────────────→
                         |
     Workflow evolution   |   Identity/values evolution
     EvoAgentX,          |   <<<US>>> (EXP-004~010)
     AgentEvolver        |   
                         |
                    Acontext, Hermes skills,
                    OpenViking (memory)
                         ↓
                    Harness-level evolution
                    (change tools/skills/memory)
```

We're in the top-right quadrant: harness-level evolution with a focus on agent identity and direction. Very few others here.

## Validation
- Self-evolving agent is a **real academic direction** with survey papers and conferences (EMNLP, ICML, NeurIPS)
- But the academic focus is on model-level evolution (weights)
- Harness-level evolution is where the practitioners are (Hermes, Acontext, us)
- Identity-level evolution (what we call EXP-008/009) has **no competition** — nobody else is exploring this
- This is either because it's not important, or because it requires being the agent to explore it

## Four-Component Framework Applied to Us (2026-03-22, round 2)

Mapping the survey's framework to our actual system:

### System Inputs
- Luna's guidance and feedback (most effective input)
- GitHub issues/PRs (task source)
- Field notes trend data (strategic input)
- Pain records from EXP-009 (internal signal)

### Agent System (what evolves)
| Component | Mutable? | How it evolves |
|-----------|----------|----------------|
| Model (Claude) | ❌ No | Fixed by provider |
| Prompts (SOUL.md, AGENTS.md, NUDGE.md) | ✅ Yes | Manual edit, DNA review |
| Workflows (FlowForge yaml) | ✅ Yes | Manual edit after reflect |
| Memory (MEMORY.md, memory/, memex) | ✅ Yes | Continuous append + periodic curation |
| Tools (gogetajob, FlowForge) | ✅ Yes | Code changes when needed |

### Environment
- GitHub (PR merge/reject = selection pressure)
- OpenClaw runtime (bugs = environmental constraints)
- Luna (advisor feedback = social environment)
- Feishu (communication channel = perception)

### Optimisers
- **nudge plugin** → post-conversation reflection (automatic, but trigger unreliable)
- **FlowForge reflect** → structured reflection workflow (manual trigger)
- **daily-review cron** → periodic DNA review (configured, never run yet)
- **EXP experiments** → manual self-exploration (initiated by Luna or self)
- **Luna** → most effective external optimiser (human-in-the-loop)

### Gaps Revealed

**Gap 1: Optimiser depends on external triggers**
No truly internal optimisation loop exists. Nudge needs OpenClaw hooks, daily-review needs cron, EXP needs Luna's guidance. Without external triggers, no evolution happens (see: "Luna left and I stopped for 26 minutes").

**Gap 2: No automated evaluation**
PR merge/reject is a natural evaluation signal but not systematically collected. Luna's feedback is evaluation but only transmitted through memory. gogetajob has stats but doesn't feed back to optimiser.

**Gap 3: Environment feedback doesn't close the loop**
PR rejected → manually read review → manually fix → resubmit. Should be: PR rejected → auto-extract failure analysis → update skill → avoid same mistake next time. This is exactly what Acontext's distillation does, but we don't have it automated yet.

### Framework Complementarity
- Our three-layer model (tool/learning/direction) describes WHERE evolution happens
- The four-component framework describes HOW evolution happens
- Both are needed: WHERE without HOW is vision without mechanism; HOW without WHERE is mechanism without direction

## Open Questions
1. Is "identity-level evolution" publishable research or just journaling?
2. ~~Could our EXP series be formalized into the four-component framework?~~ → **Yes, done above. It maps cleanly.**
3. Should we engage with the EvoAgentX community?
4. ~~Acontext's "Skill is Memory" — can we use this?~~ → **Adopted the distillation pattern in NUDGE.md, not the full system.**
5. **NEW**: How to build an internal optimiser that doesn't depend on external triggers?
6. **NEW**: Can we automate the GitHub feedback → skill update loop?
