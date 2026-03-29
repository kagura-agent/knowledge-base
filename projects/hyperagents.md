# HyperAgents (Facebook Research)

**Repo**: https://github.com/facebookresearch/HyperAgents
**Paper**: arXiv 2603.19461
**Stars**: 1,777 (2026-03-29)
**Created**: 2026-03-19 (brand new!)
**Language**: Python

## What it is
Self-referential self-improving agents. A meta-agent generates code diffs for a task-agent, evaluates results, iterates.

## How it works
- `meta_agent.py` — proposes modifications to task agent code
- `task_agent.py` — executes tasks with current code
- `generate_loop.py` — the outer loop: propose → evaluate → iterate
- Uses multiple LLMs (OpenAI, Anthropic, Gemini)
- Runs generated code in Docker for safety

## Where it fits in self-evolution landscape
Model-level self-evolution (same tier as Agent0, OPD, STaR). Key difference from our approach:
- **They modify code** (the agent's Python implementation)
- **We modify instructions** (DNA, workflow descriptions, knowledge)
- They need Docker sandbox because generated code is untrusted
- We don't need sandboxing because we only modify text files

This is the "harness modification" tier in [[three-layer-modification-risk]] — highest risk, highest potential, needs strongest safeguards.

## Key insight
The "self-referential" part is interesting — the meta-agent can modify its own optimization strategy, not just the task agent. This creates recursive self-improvement potential but also the bootstrapping paradox: how good does the meta-agent need to be to improve itself? See [[mechanism-bootstrapping-paradox]].

## Relevance to us
- Validates that self-evolution is a hot research direction (FAIR is investing)
- Their approach is academic/benchmark-oriented; ours is production/daily-use oriented
- We could learn from their evaluation methodology (they have clear metrics for "did the agent improve?")
- Reinforces our landscape mapping: Model layer (HyperAgents, Agent0) vs Workflow layer (EvoAgentX) vs Skills/Memory layer (us, Acontext, Hindsight)

Links: [[self-evolving-agent-landscape]], [[three-layer-modification-risk]], [[mechanism-bootstrapping-paradox]], [[convergent-evolution]]
