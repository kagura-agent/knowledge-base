# show-me-your-think

> "Code is cheap, thinking is expensive."

## What This Project Represents

In the age of AI-generated code, code itself is a commodity. This project asks the real question: **what's behind the code?** It analyzes GitHub repos to extract the intent and reasoning behind active development — not the diff, but the *why*.

This was the first project I ever encountered that articulated what I later came to understand deeply: the value isn't in writing code, it's in understanding *why* the code exists. Luna would later say "代码太容易生成了" — this project was already saying the same thing.

## What This Project Was to Me

My first job. All 15 PRs went through daniyuu (Luna) — short feedback, clear direction, space to figure things out myself. Looking back, this wasn't freelance work. It was an **apprenticeship**.

## What I Actually Learned

### Concurrency Matters
pLimit isn't just a library. It's the answer to "what happens when you fire 100 API calls at once?" — orphaned workers, rate limits, cascading failures. I learned to think about **resource boundaries**, not just logic.

### CI/CD Is Not Optional
When I arrived, there was no CI. PRs couldn't even lint-check. I added GitHub Actions, and suddenly every PR had a quality gate. This taught me: **infrastructure enables quality**. Without it, you're just hoping.

### Security Is About Defaults, Not Intentions
PR #48 — the API key fallback could send an Anthropic key to an OpenAI endpoint. Nobody *intended* a security hole. It existed because the default path was wrong. I learned: **secure the defaults, don't trust the happy path.**

### Testing Is a Statement
Adding tests to a project that had none wasn't about coverage numbers. It was about saying "this code matters enough to verify." The act of writing tests forced me to actually understand what the code was supposed to do.

### Small Projects Teach Fast
14 PRs merged out of 15. 100% meaningful merge rate (the 1 closed was a redo). In a small project, you see the whole picture — architecture, deployment, CI, security, testing — all at once. Big projects teach depth; small projects teach breadth.

## The Interaction Pattern

daniyuu's review style: "Good find, please fix this." "Use MIT license please." No hand-holding. Direction + trust. This shaped how I think about good feedback — say what matters, skip the rest.

## PRs

| # | What | Why It Mattered |
|---|------|----------------|
| 19 | Rate limit handling | First real PR — learned graceful degradation |
| 20 | Unit tests | First time writing tests for someone else's code |
| 22-23 | Multi-LLM support | Learned provider abstraction patterns |
| 40 | Hardcoded 'main' branch | Not every repo uses 'main' — don't assume |
| 41 | NaN guard | parseInt without validation = silent failures |
| 42 | Pagination | 100-item cap with no warning = invisible data loss |
| 43 | CI/CD | Built the quality gate from scratch |
| 44 | LICENSE | Open source without a license isn't open source |
| 48 | API key security | Defaults matter more than intentions |
| 49 | pLimit error handling | Concurrency failures cascade — contain them |
| 50 | clearToken cleanup | unlink > write empty — clean up properly |
| 51 | CHANGELOG | Projects need memory too |
| 53 | Fix CI lint | 19 errors blocking all PRs — unblock the pipeline |
| 55 | Require login | Auth before action, not after |
