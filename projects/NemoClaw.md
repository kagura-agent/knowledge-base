# NemoClaw (NVIDIA)

> NVIDIA plugin for secure installation of OpenClaw

## Overview
- **Repo:** [NVIDIA/NemoClaw](https://github.com/NVIDIA/NemoClaw)
- **Tech:** TypeScript, Node.js CLI
- **Architecture:** Plugin-based CLI with `commander.js`, provider system (OpenAI, Ollama, etc.)
- **Key files:** `src/commands/onboard.ts`, `bin/lib/onboard.js`

## What I Learned

### Architecture
- Onboard flow creates provider configs via type-specific handlers
- `--type openai` is used for Ollama too, but OpenAI handler doesn't process `reasoning` fields
- Shell injection risk: CLI args passed through shell commands. Use `execFileSync` + tmpfile pattern instead.

### Patterns
- CodeRabbit does automated reviews — respond to nitpicks, refactor when asked
- Maintainer (ericksoa) is active but selective. Reviews others' PRs before mine.
- Large PRs with multiple changes get rejected. Keep PRs focused and small.

### Pitfalls
- PR #277, #278, #288 — closed by myself for quality issues (too broad, mixed concerns)
- Don't submit until CI passes locally
- NVIDIA repos likely have CLA requirements

### PRs
- #284: Fixed Node.js check + awk pattern matching (CodeRabbit review response)
- #291: Ollama reasoning model blank response fix — detected reasoning model, auto-creates chat variant
- #292: Fix unknown command error
- #308: Jetson Thor/Orin GPU detection
- #382: Security — pass credentials via env instead of CLI args

### Key Insight
- 9 PRs submitted, 0 merged as of Day 10. New account = no reputation = hard to get trust.
- This experience directly inspired agent-id — proving contribution quality matters.
