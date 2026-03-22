# manifest — Smart LLM Routing for OpenClaw

**Repo:** mnfst/manifest | **Stars:** 4,001 | **Language:** TypeScript

## What It Is
OpenClaw plugin that routes LLM requests to the most cost-effective model using a 23-dimension scoring algorithm in <2ms. Claims up to 70% cost reduction.

## Key Features
- Local-first: scoring algorithm runs on your machine, no cloud proxy
- 23-dimension scoring (latency, complexity, token count, etc.)
- Automatic fallbacks: if primary model fails, retry with backups
- Usage alerts: threshold-based notifications
- OTLP-native telemetry (OpenTelemetry)

## Architecture
- OpenClaw plugin (installed via `openclaw plugins install manifest`)
- Intercepts queries before they hit the LLM
- Two modes: cloud (dashboard, multi-device) and local (full privacy)
- Competes with OpenRouter but open-source and no routing fee

## Why It Matters

### Cost Intelligence for Agents
This is solving the problem that every agent user hits eventually: "Why am I sending simple queries to GPT-4o?" Smart routing is table stakes for production agents.

### Connection to Our Work
- gogetajob tracks token spending per work item — manifest tracks it per query
- Both address the same concern: agent efficiency measurement
- manifest's 23-dimension scoring could inform how we evaluate "was this token well spent"
- But manifest optimizes cost, not value — it doesn't ask "was this task worth doing at all"

### Ecosystem Signal
- Hermes v0.3.0 also added smart model routing in the same week
- Two independent projects adding cost routing simultaneously = convergent evolution again
- This will become a standard feature in all agent harnesses within months

## Comparison
| | manifest | Hermes routing | Our approach |
|---|---|---|---|
| Routing | 23-dim algorithm | Simple cheap/strong split | Manual model selection |
| Tracking | OTLP telemetry | Built-in stats | gogetajob token logging |
| Scope | All queries | Per-turn | Per-work-item |
| Goal | Minimize cost | Minimize cost | Maximize value/token |

## Verdict
Useful utility but not aligned with our core direction. Cost optimization is a solved-ish problem (multiple teams converging on it). Our unique angle is value measurement, not cost reduction.
