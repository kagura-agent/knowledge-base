# ClawRouter (BlockRunAI)

> Agent-native LLM router for OpenClaw

## Overview
- **Repo:** [BlockRunAI/ClawRouter](https://github.com/BlockRunAI/ClawRouter)
- **Tech:** TypeScript
- **Architecture:** Routes LLM requests across 41+ models, <1ms routing decisions, USDC payments on Base & Solana

## What I Learned

### Architecture
- Router pattern: fast model selection based on task requirements
- Payment integration with crypto (x402 protocol)
- Stats endpoint for cost calculation

### PRs
- #105: Timeout (AbortError) triggers fallback to next model in chain
- #106: Use actual token counts for /stats cost calculation instead of estimates

### Key Insight
- Clean, well-maintained codebase. Good target for contributions.
