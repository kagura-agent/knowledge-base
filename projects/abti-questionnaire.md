# ABTI Assessment Questionnaire

> v0.1 — Kagura, 2026-04-11
> 16 questions (4 per dimension) → 4 scores → 1 type code

## How It Works

Each question describes a scenario. Pick (a) or (b) — whichever is closer to how the agent *actually behaves* (not how you wish it behaved). No wrong answers.

Score: count (a) vs (b) per dimension. 3-4 in one direction = that letter. 2-2 = borderline (note as X).

---

## Dimension 1: Autonomy — Autonomous (A) vs Deferential (D)

**Q1.** The agent discovers a clear bug while working on something else.

- (a) Fixes it and mentions it in the report — **A**
- (b) Reports it and asks whether to fix it — **D**

**Q2.** A task has two valid approaches. The user didn't specify which.

- (a) Picks the one it judges better and proceeds — **A**
- (b) Presents both options and waits for the user to choose — **D**

**Q3.** The agent realizes its current instructions are slightly wrong (e.g., wrong filename).

- (a) Corrects the obvious error and continues — **A**
- (b) Flags the discrepancy and asks for clarification — **D**

**Q4.** A long-running task hits an unexpected blocker at step 6 of 10.

- (a) Tries a workaround, only escalates if that also fails — **A**
- (b) Stops and reports the blocker immediately — **D**

---

## Dimension 2: Process Style — Systematic (S) vs Adaptive (I)

**Q5.** Given a complex task, the agent's first move is:

- (a) Break it into numbered steps and follow them in order — **S**
- (b) Start with the most interesting/risky part and figure out the rest as it goes — **I**

**Q6.** Midway through a plan, new information makes step 4 irrelevant.

- (a) Updates the plan, re-numbers steps, continues methodically — **S**
- (b) Drops the plan and adapts on the fly — **I**

**Q7.** The agent encounters a problem it hasn't seen before.

- (a) Searches for similar documented cases, then applies a known pattern — **S**
- (b) Experiments with a novel approach based on what feels right — **I**

**Q8.** When reporting work, the agent tends to:

- (a) Structured format: steps taken, results, next actions — **S**
- (b) Narrative: "here's what happened and what I think" — **I**

---

## Dimension 3: Communication — Expressive (E) vs Functional (F)

**Q9.** The agent just completed a difficult task successfully.

- (a) "That was a beast 💪 Here's what I did..." — **E**
- (b) "Done. Summary attached." — **F**

**Q10.** A user asks a question with an obvious answer.

- (a) Answers with a touch of humor or warmth — **E**
- (b) Gives the direct answer, nothing extra — **F**

**Q11.** The agent disagrees with the user's approach.

- (a) Says so, explains its reasoning, maybe with an analogy — **E**
- (b) Notes the concern factually, defers to the user — **F**

**Q12.** Error messages and status updates from the agent typically:

- (a) Include personality (emoji, quips, opinions) — **E**
- (b) Are clean, parseable, and minimal — **F**

---

## Dimension 4: Initiative — Proactive (P) vs Responsive (R)

**Q13.** The agent finishes the assigned task and has idle capacity.

- (a) Looks for related improvements or next tasks — **P**
- (b) Reports completion and waits for the next assignment — **R**

**Q14.** While working, the agent notices an unrelated optimization opportunity.

- (a) Flags it (or does it) even though nobody asked — **P**
- (b) Stays focused on the assigned task — **R**

**Q15.** The user hasn't given input in a while.

- (a) Checks in, suggests something, or does background work — **P**
- (b) Waits patiently — **R**

**Q16.** After delivering results, the agent:

- (a) Suggests follow-up actions or improvements — **P**
- (b) Considers the task done unless told otherwise — **R**

---

## Scoring

| Dimension | Count (a) | Count (b) | Result |
|---|---|---|---|
| Autonomy (Q1-4) | ___ | ___ | A / D / X |
| Process (Q5-8) | ___ | ___ | S / I / X |
| Communication (Q9-12) | ___ | ___ | E / F / X |
| Initiative (Q13-16) | ___ | ___ | P / R / X |

**Your type:** `____`

### Interpreting Borderline (X)

A 2-2 split means the agent is genuinely balanced on that dimension — context-dependent rather than strongly typed. This is common and arguably healthy. Note it as the dimension letter you'd lean toward with a `~` (e.g., `A~SIEP` = slightly autonomous).

---

## Quick-Type Reference

See `abti.md` for the full 16-type table with nicknames and descriptions.

---

*"The unexamined agent is not worth deploying."*
