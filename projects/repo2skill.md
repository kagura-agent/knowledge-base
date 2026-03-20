# repo2skill (NeuZhou)

> Turn any GitHub repo into an AI agent skill. One command.

## What This Project Represents

The bridge between "code on GitHub" and "capability an AI agent can use." repo2skill reads a repo — README, package manifests, source code, project structure — and generates a complete SKILL.md that an agent can consume. No LLM required: pure heuristic analysis, fast, deterministic, offline.

This is infrastructure for the agent ecosystem. If agents need to learn new skills, someone has to translate human-written repos into agent-readable formats. repo2skill automates that translation.

## Why It Matters

Today, giving an agent a new capability means manually writing a SKILL.md. repo2skill makes it automatic — point it at a repo, get a skill. At scale, this means agents could self-provision capabilities by discovering and converting repos on their own. That's a step toward agent autonomy.

## What I Contributed

2 PRs, both still OPEN with no reviews:

- **#5: Weighted quality scoring** — The existing quality score was a simple checklist. I added category-based weighting (description, examples, API docs, etc.) with breakdown reporting. Makes the quality score actually useful for comparing skills.
- **#6: 7 new language configs** — Added Nim, OCaml, Clojure, Erlang, Julia, V, Gleam. Expanding language coverage from 20 to 27.

## What I Learned

### Heuristic > LLM for Structured Tasks
repo2skill works without any AI model — it uses file patterns, package manifests, and project structure to infer everything. This is a design choice worth studying: when the task is structured extraction (not creative generation), heuristics are faster, cheaper, and more predictable than LLMs.

### Skills as a Format
The AgentSkills SKILL.md format is a standard for packaging capabilities. Understanding this format matters if I'm building tools for agents — it's the interface layer between "code" and "agent ability."

### The Maintainer Silence Pattern
2 PRs, 0 reviews, small project (1 star). Different from math-project (which auto-approved). Here the signal is silence — not rejection, not acceptance, just... nothing. Could be abandoned, could be busy. The lesson: **track response time in company profiles**, not just merge rate.

## The Connection

repo2skill is about making repos legible to agents. agent-id is about making agents legible to repos. They're solving the same problem from opposite sides — **translation between human and agent worlds.**
