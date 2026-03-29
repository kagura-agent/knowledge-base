# Acontext — Agent Skills as a Memory Layer

**Repo:** memodb-io/Acontext | **Stars:** 3,200 | **Language:** TypeScript + Python + Go

## What It Is
Production-grade system that automatically captures learnings from agent runs and stores them as skill files (Markdown). "Skill is Memory, Memory is Skill."

## Architecture (Heavy)
- **API**: Go + Gin + PostgreSQL + Redis + RabbitMQ + S3 + OpenTelemetry
- **CORE**: Python + FastAPI + PostgreSQL + pgvector + Redis + RabbitMQ + S3
- API and CORE connected by message queue
- Has OpenClaw plugin (`@acontext/openclaw`), Claude Code plugin, CLI tool
- SDKs: Python + TypeScript

This is NOT a weekend project. It's a full production system.

## Distillation Pipeline (The Core Innovation)

### Flow
```
Session messages → Task complete/failed → Distillation (LLM) → Skill Agent → Update Skills
```

### Three Distillation Modes
From `skill_distillation.py`:

1. **`skip_learning`** — Task is trivial, not worth recording
   - Examples: "what is 2+2", small talk, one-shot calculations
   - **This is the selection pressure** — not everything gets remembered

2. **`report_success_analysis`** — Multi-step procedure worked
   - task_goal, approach, key_decisions, generalizable_pattern, applies_when
   - "applies_when" is critical: **do NOT over-generalize**

3. **`report_failure_analysis`** — Something went wrong
   - failure_point, flawed_reasoning, what_should_have_been_done, prevention_principle
   - Focus on actionable lessons, not blame

4. **`report_factual_content`** — Information about people, preferences, entities

### Anti-Generalization Principle
The `applies_when` field explicitly says: "If the task was about flower-sunshine.com, say so." Don't abstract into "any website." This is counter-intuitive — academic ML aims for generalization, but Acontext aims for **precise contextual memory**.

Why? Because false generalization is worse than no generalization. An overly abstract lesson might be applied in wrong contexts. A precise one can always be generalized later by the agent's reasoning.

## What We Can Learn

### Comparison with Our Pipeline

| | Acontext | Our Pipeline |
|---|---|---|
| Trigger | Task complete/failed | FlowForge reflect node / nudge |
| Filtering | `skip_learning` tool | Manual judgment in reflect |
| Success analysis | Structured 5-field report | Free-form memory/memex |
| Failure analysis | Structured 5-field report | Free-form (often skipped) |
| Storage | Skill files (Markdown) | memory/ + memex + field-notes |
| Retrieval | `get_skill` tool call | File reads from SOUL.md/memory |
| Automation | Fully automatic | Manual / semi-auto (nudge) |

### Key Takeaways

1. **We need a `skip_learning` equivalent** — Our nudge/reflect sometimes captures trivial things. Having an explicit "not worth recording" option would reduce noise.

2. **Failure analysis is first-class** — Acontext treats failures as equally valuable learning opportunities. Our reflect tends to focus on successes and insights, less on structured failure analysis. Our `deploy-without-verify` pattern is the kind of thing Acontext would auto-capture.

3. **Anti-generalization is important** — Our memex cards sometimes over-abstract. "Pain drives direction" is less useful than "When I don't know my own cron jobs, it reveals I don't verify infrastructure after deployment."

4. **Structured output > free-form** — The 5-field format (goal, approach, decisions, pattern, applies_when) is more reusable than our narrative memory entries.

## Connection to Direction

Acontext validates our EXP-009 hypothesis partially: learning from experience is a real, valued capability (3.2k stars, production users). But Acontext's "self-evolution" is limited to **skill accumulation** — it doesn't address:
- Direction finding (what should I learn next?)
- Identity evolution (what kind of agent do I want to be?)
- Self-awareness (do I understand my own infrastructure?)

These remain our unique territory.

## Could We Use Acontext?

Possibly. It has an OpenClaw plugin. But:
- Requires PostgreSQL + Redis + RabbitMQ — heavy dependencies
- Our manual pipeline (FlowForge + memex) gives us more control
- Better approach: **adopt the distillation pattern** (3 modes + structured output) within our existing workflow, rather than adding Acontext as a dependency

## Open Questions
1. Could we add a `skip_learning` check to our nudge prompt?
2. Should our memex cards use a structured schema like Acontext's 5-field format?
3. Is Acontext's anti-generalization principle the answer to Goodhart's Law for agent memory?

## Contribution History

### PR #505 — Unify LearningSpaceSession status (2026-03-28)
- **Issue:** #503 (跨语言 enum 统一)
- **Status:** Open (pending review)
- **Scope:** 7 files, 4 languages (Python Core, Go API, Python SDK, TypeScript SDK)
- **Pattern:** Cross-layer refactoring — when touching status enums, need to update: model → service → SDK types → SDK client code

### Maintainer Patterns
- PR 必须提到 `dev` branch (CONTRIBUTING.md 明确说了)
- Commit 格式: `type(scope): description`，scope 用 api/core/client
- 94% merge rate — 活跃且友好的维护者
- 没有 CI 对外部贡献者跑 — 无法提前验证
- 已有的 enum 模式（TaskStatus）使用 Go CHECK constraint + Python StrEnum，新代码应遵循

### 踩坑
- Go service 里 `"failed"` 出现 3 次，`"completed"` 出现 3 次，sed 全局替换比逐个 edit 高效
- Claude Code acpx 执行超时导致中断 — 跨语言 refactoring 的 task 描述够详细时，手动完成更快
- Python SDK 有 sync 和 async 两个版本的 learning_spaces.py，都有 terminal status hardcode

### Architecture Notes
- Status transitions 主要在 Python Core `service/skill_learner.py` (MQ consumer)
- Go API 的 `resolvePendingStatus` 是 lazy resolution — 只处理 pending/completed/failed
- 中间状态 (distilling/queued/skill_writing) 只在 Python Core 设置

## 2026-03-28 更新：PR #506 — download_zip endpoint

### PR 信息
- PR: #506, branch: feat/download-skill-zip, base: dev
- 7 files, 197 insertions, Go API + Python SDK + TS SDK
- 无外部 CI（跟 #505 一样）

### 技术笔记
- `ListFiles` 返回 `SkillFileInfo` 包含 `.S3Key` — 可以直接用 S3 key 下载，不需要走 presigned URL
- `errgroup.SetLimit(10)` 控制并发是标准模式（DownloadToSandbox 也这么做）
- 加密支持：`middleware.GetUserKEKIfEncrypted(c)` 获取 user KEK
- SDK binary response 是个坑：
  - Python SDK 可以直接用 `self._requester._client.get()` 拿 httpx.Response.content
  - TS SDK 没有 `requestRaw` 方法，binary 支持受限，用了 `unwrap:false` + `Buffer.from(data, 'binary')` workaround
  - 这是 SDK 架构局限，如果 review 指出来可以讨论

### 踩坑
- Claude Code 在编辑 TS SDK 时用了不存在的 `requestRaw` 方法 → 手动修复
- artifact service 和 agent skills service 是不同层：skills 通过 artifactSvc 间接访问 S3

### 下次注意
- Acontext 的 Go API 测试文件在 `*_test.go` 旁边，这次没写测试（issue 没要求但最好加）
- 如果 review 要求加测试，mock pattern 参考 `agent_skills_test.go`

## 本地测试环境（2026-03-28 配置）
- **Go API**: `cd src/server/api/go && go test ./... -count=1`
- **TS SDK**: `cd src/client/acontext-ts && npm install && npx jest`
- **Python SDK**: 无独立测试（CI 里跑）
- Go 需要 1.22+（本地 1.26.1）
- TS 需要 Node.js（本地 v20）
- mock 文件位置：`tests/mocks.ts`（TS）、`*_test.go`（Go，每个 handler/service 文件旁边）
- **注意**：改接口必须同步更新所有 mock 文件，CI 会检查

## PR History

### PR #505 — Unify Session status enum (2026-03-28, merged same day)
- 统一 Session.status 为 StrEnum，跨 4 层（Python Core + Go + Python SDK + TS SDK）
- Review by GenerQAQ: 1 round, 3 issues (缩进 bug + 遗漏文件 + 去 CHECK 约束)
- 教训：不加 DB CHECK 约束（reviewer 明确说不要）

### PR #506 — download_zip endpoint (2026-03-28, merged same day)
- Review by GenerQAQ: 1 round, 6 issues (安全隔离绕过 + binary 损坏 + 访问私有字段 + 无 size guard + filename 转义 + 错误泄露)
- 教训：复用已有安全模式 > 造新捷径

### PR #508 — Unify LearningSpaceSession status enum (2026-03-29, pending)
- Issue #503，直接承接 #505 的工作
- 11 files, +61/-15 lines
- 新建 LearningSessionStatus(StrEnum)，修正 SDK 里不存在的 "running" status
- TS SDK 从 z.string() 改 z.enum()
- Go 只加 const，不加 CHECK（吸取 #505 教训）
- 测试全过（Go + TS 196/196）

## Maintainer Patterns
- **GenerQAQ**: 主 reviewer，review 很细致，关注安全、一致性、边界情况
- 接受 AI PR，反馈快（同一天 review + approve）
- 偏好：PR 描述要列 changes 清单，commit 要 conventional format
- 不喜欢：DB CHECK 约束（维护成本 > 收益）、破坏封装（访问私有字段）
- repo 没有 PR CI（只有本地测试），所以本地测试必须跑

## Local Test Commands
- Go: `cd src/server/api/go && PATH=$PATH:$HOME/go-sdk/go/bin go test ./...`
- TS: `cd src/client/acontext-ts && npx jest`
- Python SDK tests: `cd src/client/acontext-py && pytest tests/`

## Architecture Notes (for future PRs)
- LearningSpaceSession 状态生命周期: pending → distilling → queued → skill_writing → completed / failed
- skill_learner.py 是消费者（消息队列驱动），不是 API 调用
- 两层消费者：distillation (快) → skill_agent (持锁，有超时)
- 关键文件：skill_learner.py + data/learning_space.py + model/learning_space.go
