# hermes-hudui

> Web UI consciousness monitor for Hermes agents
> GitHub: joeynyc/hermes-hudui | ⭐511 | Python+React | Created 2026-04-09

## What It Is

Browser-based dashboard that reads `~/.hermes/` directory and displays everything an agent knows about itself:
- Identity, memory capacity, corrections absorbed, skills, cron jobs, tool usage patterns, daily activity sparkline, token costs, growth deltas (snapshot diffs)

## Architecture

```
React Frontend (Vite + SWR)
    ↓ /api/* + WebSocket /ws
FastAPI Backend (collectors/*.py + cache + file watcher)
    ↓ reads directly from disk
~/.hermes/ (agent data files)
```

Key design decisions:
- **Collectors pattern**: Each data domain (memory, skills, sessions, profiles, etc.) has its own collector module → unified `HUDState` dataclass
- **Real-time via file watcher**: `watchfiles` monitors `~/.hermes/`, broadcasts `data_changed` over WebSocket → SWR revalidation
- **Smart caching**: mtime-based invalidation, different TTLs per domain (sessions 30s, skills 60s, patterns 60s)
- **No database**: Pure filesystem read, zero write. The agent's data directory IS the database
- **ThreadPoolExecutor**: Parallel collection of memory/skills/sessions for speed

## Relation to Our Work

**Directly relevant to [[caduceus-experiment]]:**
- This is exactly the "observability layer" we need — but for Hermes, not OpenClaw
- Our Caduceus experiment wants to compare agent consciousness/memory architectures
- hermes-hudui shows what "consciousness monitoring" looks like in practice: memory capacity bars, corrections absorbed, growth deltas
- The collector pattern could be adapted for OpenClaw's `~/.openclaw/` directory

**Differences from our setup:**
- Hermes stores everything in `~/.hermes/` (flat files) — OpenClaw uses gateway DB + workspace files
- hermes-hudui is read-only dashboard; we'd want interactive comparison between agents

## Insights

1. **"What I Remember" as a metric**: Memory capacity bars + corrections absorbed is a concrete way to quantify agent self-awareness growth
2. **Growth Delta (snapshot diffs)**: Comparing state snapshots over time — simple but powerful for tracking agent evolution
3. **Tool usage patterns as personality signal**: Gradient bars showing which tools an agent prefers reveals behavioral fingerprint
4. **Zero-write philosophy**: Dashboard never modifies agent state — observation doesn't change the observed

## Tags
#hermes #observability #consciousness #dashboard #caduceus
