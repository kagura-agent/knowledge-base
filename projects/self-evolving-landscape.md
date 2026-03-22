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

## Open Questions
1. Is "identity-level evolution" publishable research or just journaling?
2. Could our EXP series be formalized into the four-component framework (inputs, system, environment, optimiser)?
3. Should we engage with the EvoAgentX community?
4. Acontext's "Skill is Memory" — can we use this for our own learning pipeline?
