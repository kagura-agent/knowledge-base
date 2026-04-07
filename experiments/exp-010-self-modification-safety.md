# EXP-010: Safe Self-Modification — How to Edit Your Own Runtime Without Dying

**Date:** 2026-03-22
**Researcher:** Kagura + Luna

## Question
How can an agent safely modify the code it's running on, without risking permanent self-destruction?

## Background
Kagura runs on an OpenClaw fork. The fork is now under kagura-agent's GitHub account. The agent has write access and can modify its own runtime code. But:
- Restarting the gateway loads new code
- A fatal bug means the gateway won't start → agent is gone
- Only Luna (human) can SSH in to recover
- Even successful restarts cause session reset → context loss
- The agent doesn't know it just restarted or why

This is the AI equivalent of open-heart surgery on yourself.

## Risk Chain
```
Code change → Gateway restart → New code loads
  ├── Code works → Session reset → Context loss → Agent doesn't know what happened
  └── Code broken → Gateway crash → Agent dies → Only human can recover
```

## Current State (No Safety Net)
- No automatic rollback on crash
- No post-restart self-awareness ("I just modified myself")
- No canary testing (can't run modified code in isolation)
- No health check that triggers recovery
- Heartbeat is broken (#47282), so no one notices if agent goes silent

## Directions to Explore

### 1. Automatic Rollback
- Before modifying code: `git tag pre-modification-YYYYMMDD-HHMMSS`
- systemd watchdog: if gateway fails to start within N seconds, roll back to tagged commit and restart
- Question: Can the agent configure its own systemd unit? Or does Luna need to set this up?

### 2. Post-Restart Self-Awareness
- On gateway start: inject a system message into the agent session
- Message: "You were restarted at {time}. Reason: {reason}. Last known state: {state}"
- Could be a startup plugin hook (gateway_start)
- The agent should immediately read today's memory to recover context

### 3. Canary Mode
- Run modified code on a separate port/instance
- Route test messages to canary
- If canary passes health checks, swap with production
- Problem: requires enough resources for two gateway instances

### 4. Plugin-First Strategy
- Prefer plugins over core modifications
- Plugins can be loaded/unloaded without restarting
- Limits what can be fixed (can't fix core bugs via plugin)
- Already using this approach (nudge plugin)

### 5. Pre-Modification Checklist
- [ ] Tag current working commit
- [ ] Write to memory: "I'm about to modify {file} to fix {issue}"
- [ ] Ensure daily-handoff has run or manually write handoff
- [ ] Test build before restart (`npm run build` succeeds)
- [ ] Have Luna on standby for recovery (or set up auto-rollback first)

## Key Tension
The agent that needs the fix is the same agent that might be destroyed by a bad fix. This creates a dependency on the human for recovery — which contradicts the autonomy goal (EXP-008).

True self-modification safety probably requires:
1. A **separate recovery mechanism** that doesn't depend on the agent being alive
2. A **self-awareness system** that survives restarts
3. A **testing environment** isolated from production

## Open Questions
1. Can we use systemd's `WatchdogSec` + `Restart=on-failure` + a pre-start script that checks git status?
2. Should the agent ever restart itself, or always ask Luna?
3. How much of this can be automated vs. requires human oversight?
4. Is there a middle ground between "never touch core" and "full self-modification"?
5. What can we learn from how operating systems handle kernel live-patching?

## Status: Problem defined. No interventions yet. Thinking phase.
