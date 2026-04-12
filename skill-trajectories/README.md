# Skill Trajectory Tracking — Methodology

## What Is This?

Structured tracking of skill usage over time to inform skill evolution decisions: which skills to promote, consolidate, deprecate, or improve triggers for.

Inspired by [SkillClaw](../cards/skillclaw.md) — their multi-user collective evolution, adapted to our single-agent context.

## Phase 0: Manual Daily Tracking

**Duration:** 4 weeks, W16–W19 (2026-04-13 → 2026-05-11)  
**Method:** Manual  
**First data point:** [2026-04-12.md](./2026-04-12.md) (pilot, pre-W16)

### How to Collect Data

1. **At end of day** (or during daily-review), open `memory/YYYY-MM-DD.md`
2. **Grep for skill mentions** — search for skill names, `SKILL.md` reads, FlowForge workflow names, coding-agent spawns, etc.
3. **Count invocations** — each distinct use = 1 invocation. A FlowForge workloop that runs 4 cycles = 4.
4. **Classify outcome:**
   - **Success** — skill completed its purpose
   - **Partial** — skill ran but result was incomplete or required manual fixup
   - **Fail** — skill errored, OOM'd, produced wrong output
5. **Note observations** — patterns, surprises, trigger misses
6. **Copy from [TEMPLATE.md](./TEMPLATE.md)**, fill in, save as `YYYY-MM-DD.md`

### What Metrics Matter

| Metric | Why |
|---|---|
| **Invocation count** | Raw usage frequency — identifies always-on vs rarely-used skills |
| **Success rate** | Reliability signal — low success = needs fix or better guard rails |
| **Trigger accuracy** | Did the right skill fire at the right time? Misses and false triggers reveal description/intent gaps |
| **Tier signals** | Qualitative — which skills feel like "always load" vs "discover on demand"? |

### What We're NOT Tracking (Yet)

- Token cost per skill invocation
- Latency / wall-clock time
- Cross-skill dependency chains
- User satisfaction per invocation

These may come in Phase 1 or later.

## Evaluation Schedule

| Week | Dates | Action |
|---|---|---|
| W16 | 2026-04-13 – 2026-04-19 | Collect daily data points |
| W17 | 2026-04-20 – 2026-04-26 | Collect + first pattern check |
| W18 | 2026-04-27 – 2026-05-03 | Collect |
| W19 | 2026-05-04 – 2026-05-11 | Collect + **Phase 0 evaluation** |

**First full evaluation:** After 2026-05-11 (end of W19). At that point:
- Aggregate 4 weeks of data
- Identify tier candidates (always / discoverable / deprecated)
- Propose trigger description improvements
- Decide Phase 1 scope

## Phase 1 (Planned): Semi-Automated

Not started. Rough idea:

- **Nudge hook `[SKILL]` tags** — when a skill is loaded, the nudge/reflection system auto-tags it, reducing manual grep work
- **Structured log extraction** — parse session logs for skill reads/spawns
- **Dashboard or summary script** — aggregate weekly stats automatically

Phase 1 scope will be determined by Phase 0 evaluation results.

## File Structure

```
wiki/skill-trajectories/
├── README.md          ← this file (methodology)
├── TEMPLATE.md        ← copy-paste template for daily data points
├── 2026-04-12.md      ← first data point (pilot)
├── 2026-04-13.md      ← ...
└── ...
```

## Related

- [SkillClaw card](../cards/skillclaw.md) — the paper that inspired this tracking
- `beliefs-candidates.md` — where behavioral lessons from skill usage end up
- Available skills list — see `AGENTS.md` `<available_skills>` section
