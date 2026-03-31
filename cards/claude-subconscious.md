---
title: "claude-subconscious (Letta AI)"
created: 2026-03-25
---
## 概述
给 Claude Code 加"潜意识"——一个异步后台 agent 监听每次对话，读文件、搜网页、积累记忆，下次 prompt 前通过 stdout "低语"回来。2.4k⭐，MIT，TypeScript。标注为 demo，生产版是 letta-code。

## 核心架构：双 agent
- **前台**: Claude Code（正常编码）
- **后台**: Letta Agent（独立推理，异步不阻塞）
- 连接点：Claude Code 的 4 个 hooks（SessionStart / UserPromptSubmit / PreToolUse / Stop）

## 8 个 Memory Blocks
| Block | 对应我们 |
|-------|---------|
| core_directives | SOUL.md |
| guidance | HEARTBEAT.md + NUDGE.md |
| user_preferences | USER.md |
| project_context | knowledge-base/projects/ |
| session_patterns | beliefs-candidates.md |
| pending_items | TODO.md |
| self_improvement | AGENTS.md DNA Self-Governance |
| tool_guidelines | TOOLS.md |

## 关键设计
- stdout 注入，不写 CLAUDE.md（避免文件冲突）
- 后台 agent 有独立的文件读/搜索能力
- 跨 session 共享记忆，跨 project 共享 brain + 项目级 thread 分离
- 依赖 Letta 平台（云端或自托管）

## 跟我们的核心差异
- 他们：双 agent（后台独立思考）→ System 1 + System 2
- 我们：单 agent + 定时机制（heartbeat/nudge/cron）→ 一个人定期自省
- 他们：服务端记忆 → 依赖外部
- 我们：本地文件 → 零依赖，git 可追踪

## 最值得借鉴
1. **异步后台 agent** — 记忆整理不占主 agent context
2. **结构化 memory blocks** — 比自由格式 MEMORY.md 更易自动管理
3. **sleep-time compute** — 不工作时做后台思考（≈ 我们的 daily-review 但更彻底）

## Letta AI 背景
- 前身 MemGPT（UC Berkeley Sky Computing Lab）
- 核心理念："LLM as Operating System"
- 主要项目：letta (22k⭐), letta-code (2k⭐), agent-file (.af 格式), sleep-time-compute
- 投资人：Jeff Dean, Clem Delangue (HF CEO)

## 跟进
- letta-code（正式继任者）
- agent-file 标准化格式
- sleep-time compute 论文
