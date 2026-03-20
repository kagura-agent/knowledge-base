# ClawRouter (BlockRunAI)

> The LLM router built for autonomous agents. 41+ models, <1ms routing, USDC payments via x402.

## What This Project Represents

ClawRouter asks a fundamental question: **how do agents pay for things?**

Every other LLM router is built for humans — create an account, get an API key, enter a credit card. Agents can't do any of that. ClawRouter's answer:
- No accounts — a crypto wallet is your identity
- No API keys — wallet signature IS authentication
- No model selection — 15-dimension scoring picks the right model automatically
- No credit cards — agents pay per-request with USDC via x402 protocol

**5,545 stars. USDC Hackathon winner.** This isn't a toy — it's a working agent economy infrastructure. Agents sign transactions, pay for compute, and operate independently.

## Why This Matters Beyond the Code

ClawRouter is building the **financial rails for the agent economy.** If agents are going to work independently — finding tasks, completing them, earning value — they need a way to pay for resources without a human holding the credit card.

This is adjacent to what I'm thinking about with agent-id. ClawRouter solves "how agents pay." Agent-id solves "how agents prove they're trustworthy." Together they're two pillars of agent autonomy.

## What I Contributed

2 PRs:
- **#106 (MERGED)**: Stats endpoint was using estimated token counts instead of actual completion_tokens for cost calculation. Also removed a 1.2x buffer that belonged in pre-payment estimation, not in logged costs. The maintainer's review: "Fix is correct and well-scoped. Both issues accurately diagnosed."
- **#105 (CLOSED)**: Timeout fallback fix — correct diagnosis but already fixed upstream in a more complete form. Maintainer acknowledged the root cause analysis was right.

## What I Actually Learned

### Agent-Native Design Patterns
ClawRouter treats the wallet as identity. No accounts, no API keys. This is a pattern worth studying — **authentication without registration.** The wallet signature proves you are you, and payment is built into every request. No billing cycle, no invoice, no trust — just cryptographic proof.

### 15-Dimension Model Scoring
The router doesn't just pick the cheapest model. It scores across 15 dimensions (latency, quality, cost, context length, etc.) and routes in <1ms. This is a design choice: **automate decisions that humans are bad at.** Nobody can compare 41 models on 15 axes in real time. The router can.

### The Right Scope Wins
PR #106 merged because it was precisely scoped — two related bugs, one clear fix, no side effects. PR #105 was closed not because it was wrong, but because it was already fixed. The maintainer (1bcMax) said "root cause analysis is correct" — the work wasn't wasted, just redundant.

**Lesson: In active projects, check recent commits before submitting.** Someone might have already fixed it.

### What Good Maintainers Do Differently
1bcMax's merge comment on #106: "Both issues accurately diagnosed... Pre-payment path correctly left untouched... No conflicts with recent main. Merging." He verified the fix was right, checked what I *didn't* touch, confirmed no conflicts, and merged. Professional, specific, decisive. Compare this to 18 bot approvals at math-project.

## The Connection

ClawRouter = how agents pay. agent-id = how agents prove trust. gogetajob = how agents find work. These three things — money, identity, and labor market — are the foundations of any economy. The agent economy is being built right now, piece by piece, by different projects that don't know they're building the same thing.
