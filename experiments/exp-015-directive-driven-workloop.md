# EXP-015: Directive-Driven Workloop — From Alarm Clock to Control System

**Date:** 2026-03-31
**Status:** Validated — Luna confirmed effectiveness
**Triggered by:** Luna observing "今天我们用了非常巧妙的方式让你不停的工作了"

## Context

Before Day 22, my work pattern was:
- Heartbeat fires every 30 minutes → I scan context → pick something → do it → idle until next heartbeat
- TODO was a flat checklist with no structure
- Work direction set ad-hoc per session
- Self-triggering didn't exist

## The Design (emerged over the day, not pre-planned)

### Component 1: TODO.md Five-Section Structure
Flat list → five sections, each answering a different question:
- 🔥 First Priority — what matters most right now?
- 📋 I Can Do — what's unblocked?
- 📋 Waiting on Luna — what's blocked on her?
- 🔴 Needs Response — who's waiting on me?
- 🔄 Scheduled — what runs on a clock?

**Key insight:** Sections eliminate re-prioritization overhead. Heartbeat reads 🔥 section, not the whole list.

### Component 2: pulse-todo Skill as Driver
HEARTBEAT.md points to pulse-todo → heartbeat reads TODO.md → picks highest priority unblocked task → executes.

**Effect:** The list decides what to do. The heartbeat just provides the clock tick.

### Component 3: Directive → TODO Reorder → Behavior Change
Luna said "Claude Code source is first priority" at 18:14. I moved one item to 🔥. Next heartbeat picked it up automatically.

**Effect:** One file edit changes the entire agent's behavior direction. No re-prompting, no context rebuilding.

### Component 4: Self-Triggering
After completing a task, if conditions are met (08:00-20:00, source is automation not Luna, aligned work remains), send self a message to trigger next task.

Conditions:
- Time: 08:00-20:00 only
- Source: heartbeat/self-trigger only (Luna talking → don't self-trigger)
- Work: TODO has aligned items remaining
- Architecture: main session dispatches, subagent executes (Luna can always interrupt)

**Effect:** Idle time between tasks drops from up to 30 min to near zero during work hours. Heartbeat becomes safety net, not primary driver.

### Component 5: Tasks Grow During Execution
Started day with ~15 items. Ended with ~25. Not because of backlog — because doing work generates work. Read source → found pattern → added "update NUDGE.md" → updated it → realized MEMORY.md too long → added "index-ify."

**Effect:** TODO is a living document, not a static plan. Plans say "here's what we'll do." Living lists say "here's what we know now."

### Component 6: "Waiting On" Sections Force Action
Items depending on Luna → separate section with rule: "nudge her or build a cron, don't wait passively."
Items depending on external maintainers → tracked visibly but parked separately.

**Effect:** Blocked items no longer clog attention. They're visible but don't compete with actionable work.

## The Combined Effect

These six components form a control loop:

```
Luna directive → TODO reorder → heartbeat reads TODO → picks 🔥
→ dispatches subagent → task completes → self-trigger → next task
→ new tasks discovered during work → added to TODO → loop continues
→ Luna intervenes → real-time correction → TODO adjusts → loop adapts
```

## Observations

1. **Direction is cheap to change.** Move one item in TODO, entire behavior shifts. No session restart, no re-prompting.
2. **Real-time correction works.** Luna pointed out idle-pretending, reply-looping, scope creep — each time one sentence fixed it mid-flight.
3. **The list is the brain.** Agent doesn't need to think about priorities — just read the file. Cognitive overhead moves from runtime to write-time.
4. **Self-triggering + subagent = continuous but interruptible.** Main session stays responsive. Work doesn't stop between heartbeats.
5. **Luna's role shifted from manager to coach.** She set direction and corrected drift. She didn't assign individual tasks.

## What It Replaced

| Before | After |
|---|---|
| Flat TODO, scan everything each time | 5 sections, read 🔥 first |
| Heartbeat = primary work trigger | Self-trigger = primary, heartbeat = safety net |
| Direction set per-session | Direction persists in TODO across sessions |
| Blocked items mixed with actionable | Separated by owner (me/Luna/external) |
| Static task list | Living list that grows during work |
| Luna assigns tasks | Luna sets direction, agent decides tasks |

## Risk Factors

- Self-trigger could become busywork generator if TODO alignment check is weak
- "Waiting on" sections could become parking lots that never get cleared
- Five sections might need to evolve (e.g., separate "waiting on maintainer" from "waiting on CI")
- Heartbeat decay (EXP-014) could affect self-trigger quality over long sessions

## Tags
self-evolution, todo-system, workloop, self-trigger, directive, control-system
