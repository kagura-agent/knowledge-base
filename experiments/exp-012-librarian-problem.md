# EXP-012: The Librarian Problem — From Search to Agent-Mediated Retrieval

**Date:** 2026-03-27
**Status:** Idea — not yet implemented
**Triggered by:** Luna asking "how do you know what to search?" while debugging why memory_search was disabled

## Context

We discovered that OpenClaw's `memory_search` tool had never been working — no embedding provider was configured. But while investigating the fix, a deeper question emerged: even if memory_search works perfectly, **who decides the search query?**

The chain looks like this:

```
User request → Agent interprets → Agent constructs query → memory_search(query) → Results
```

The bottleneck is step 2-3. The agent must:
1. Recognize that it needs external knowledge
2. Know roughly what kind of knowledge exists
3. Construct an effective query

This is the classic search problem that humans faced in the keyword-search era: you need to know the right keywords to find what you need. If you don't know something exists, you won't search for it.

## The Insight

Luna pointed out: in the LLM era, humans no longer need keywords — they describe their needs in natural language and the model understands intent. What if we apply the same shift to agent memory?

**Instead of making the worker agent search, make the knowledge base an agent.**

A "librarian agent" that:
- Knows everything on the shelves (has full context of knowledge-base contents)
- Receives intent, not keywords ("I'm about to work on NemoClaw")
- Proactively assembles relevant materials (field notes, maintainer style, past mistakes, related beliefs-candidates)
- Can warn about things the worker doesn't know to ask about ("last time you worked on NemoClaw, you forgot to grep the full codebase")

## Why This Is Different From Search

| | Keyword Search | Semantic Search (memory_search) | Librarian Agent |
|---|---|---|---|
| Query source | Agent constructs keywords | Agent describes need | Agent states intent |
| Knowledge of corpus | None | Embedding similarity | Full understanding |
| Can surface unknown unknowns | No | Partially (similar embeddings) | Yes (understands context) |
| Can warn proactively | No | No | Yes |
| Cost | Cheap | Cheap | Expensive (full agent turn) |

The key difference: **search requires you to know what you're looking for. A librarian figures out what you need.**

## Connection to Other Experiments

- **EXP-006 (Knowledge-Behavior Gap):** The gap isn't just "knows but doesn't do" — it's also "has the information but doesn't retrieve it at the right moment." A librarian agent addresses the retrieval half.
- **EXP-011 (Four-Layer Evolution):** The librarian sits between the Knowledge layer and the Skill layer — it's the retrieval mechanism that makes stored knowledge actionable.
- **EXP-005 (Automated Reflection):** Nudge triggers reflection; the librarian triggers retrieval. Both are "push" mechanisms vs passive "pull."

## From Librarian to Coach

Luna's earlier insight about "agent trainers" connects here. A librarian that not only finds materials but also says "watch out for this pattern" is essentially a coach. The progression:

1. **Librarian** — "Here are the relevant materials for your task"
2. **Coach** — "Based on your history, watch out for X and try Y"
3. **Trainer** — "I've designed a learning sequence to improve your weakness in Z"

Each level adds more agency to the retrieval/advisory layer.

## Implementation Sketch (Not Validated)

Lightest version:
- A dedicated agent session with knowledge-base index as context
- Worker agent sends: "I'm about to {task description}"
- Librarian returns: relevant snippets + warnings + suggestions
- Could be a FlowForge node (pre-work → ask librarian → do work)

Heavier version:
- Librarian monitors worker's ongoing session
- Proactively injects relevant context when it detects knowledge gaps
- Like OpenClaw's nudge plugin but for knowledge, not reflection

## Open Questions

1. **Cost:** Each librarian consultation is a full agent turn. Worth it for every task? Or only for tasks above some complexity threshold?
2. **Context window:** Can the librarian hold the full knowledge-base in context? As it grows, might need its own retrieval layer (librarian searching its own index — turtles all the way down)
3. **Staleness:** If the librarian's context is loaded at session start, it won't know about knowledge added mid-session
4. **Is this just RAG with extra steps?** Possibly. But the "agent" part means it can reason about what's relevant, not just return top-K similar chunks

## Status

Recording the idea. Not building yet — still in residence period (居住期). But this addresses a real, observed failure mode: "wrote it down but didn't read it when it mattered."
