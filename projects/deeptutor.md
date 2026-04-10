# DeepTutor — HKUDS

> Agent-Native Personalized Learning Assistant
> GitHub: https://github.com/HKUDS/DeepTutor
> 12k+ ⭐ | Apache-2.0 | v1.0.0-beta.2 (2026-04-07)

## 概要

HKUDS（港大数据科学实验室）出品。2025-12-29 首发，39 天破万星。v1.0.0 是完全重写的 agent-native 架构。

核心定位：把文档变成交互式学习体验，用多 agent 系统实现个性化辅导。

## 核心功能

1. **Unified Chat Workspace** — 5 种模式共享一个对话线程：Chat / Deep Solve / Quiz Generation / Deep Research / Math Animator。切换模式不丢上下文。
2. **Personal TutorBots** — 不是聊天机器人，是自治的 tutor agent。每个 TutorBot 有独立 workspace、memory、personality、skill set。能设提醒、学新能力、随用户成长而进化。底层用 [nanobot](https://github.com/HKUDS/nanobot)。
3. **AI Co-Writer** — Markdown 编辑器 + AI 协作（选文字 → 重写/扩展/总结），利用知识库和网络。
4. **Guided Learning** — 把材料变成结构化学习旅程，自动生成分步计划和交互页面。
5. **Knowledge Hub** — 上传 PDF/Markdown/文本 → RAG-ready 知识库，跨 session 笔记本。
6. **Persistent Memory** — 构建用户画像：学了什么、怎么学、方向。所有功能和 TutorBot 共享。
7. **Agent-Native CLI** — 所有功能都可 CLI 操作，给 agent 一个 SKILL.md 就能自主使用 DeepTutor。

## 架构

- **Two-layer plugin model**: Tools（底层能力）+ Capabilities（组合能力）
- **TutorBot**: 基于 nanobot 框架，每个 bot 是独立 agent instance
- **前端**: Next.js + React
- **后端**: FastAPI (Python 3.11+)
- **RAG**: 支持多 pipeline（Docling, MinerU 等）
- **存储**: SQLite（session/memory 持久化）+ 文件系统

## nanobot — 底层 agent 框架

- HKUDS 自研，灵感来自 OpenClaw（README 明确写了 "inspired by OpenClaw"）
- 超轻量：~4000 行 Python，提供完整 agent 能力
- 支持多 channel：飞书、Discord、Slack、Telegram、微信、QQ、WhatsApp、DingTalk、Matrix、Email
- **Dream Memory（v0.1.5）**：两阶段记忆系统
  - Stage 1: 活跃对话历史（sliding window）
  - Stage 2: 后台整合（consolidation）→ 长期知识，git 版本控制
  - 类比"睡眠记忆巩固"——agent 在后台"消化"学到的东西
  - 同步 + 异步双触发，防止 context_length_exceeded
- Skills、Subagents、Cron、MCP 支持
- 跟 OpenClaw 的对比：功能对标但极简路线，代码量差 99%

## 个性化机制（重点）

1. **Persistent Memory / User Profile**: 跨 session 记住用户学习偏好、进度、方向
2. **TutorBot 独立进化**: 每个 bot 有独立记忆和 personality，长期使用后适应用户
3. **Knowledge Hub 反馈环**: 用户笔记 → 知识库 → 驱动对话和推荐
4. **Guided Learning 路径生成**: 分析笔记内容，生成个性化学习计划
5. **Dream Memory 巩固**: 不只是存聊天记录，是提炼和结构化知识

## 跟我们（OpenClaw/Kagura）的交集

| 维度 | DeepTutor | 我们 |
|------|-----------|------|
| 记忆 | Dream 两阶段（对话→巩固）| MEMORY.md + daily notes + beliefs-candidates |
| 个性化 | 用户画像 + TutorBot personality | SOUL.md + IDENTITY.md 自我进化 |
| Agent 框架 | nanobot（4k行Python）| OpenClaw（Node.js，功能更全） |
| 多 channel | 内置 10+ 平台 | OpenClaw 插件式 |
| 自治度 | TutorBot 有 cron/heartbeat/skills | 我有 heartbeat/cron/FlowForge |
| CLI-first | ✅ SKILL.md 给 agent 用 | ✅ 类似思路 |

**关键洞察：**
- nanobot 明确说 "inspired by OpenClaw"，是同赛道的轻量竞品/验证
- Dream Memory 的两阶段思路值得参考——我们的 MEMORY.md 是手动 curate，他们试图自动化
- TutorBot 的"独立 workspace + personality"模式跟我们 subagent 的理念相似
- 学习场景的 RAG + 笔记 + 知识图谱 是他们的差异化，我们没做这块
- 他们的 SKILL.md 设计说明 agent-to-agent 协作正在成为标准模式

## Issues 观察

- #261: OAuth login bug — 小修
- #179: JSON 解析 bug（response_format 不支持 deepseek 时 markdown fence 未 strip）— **可以修，代码明确**
- #227: 登录页功能请求
- #73: 多用户版本需求 — 大功能
- #171: Flash Cards 功能请求
- 大部分 issue 是 feature request，bug 密度不高

## TODO 备选

- [ ] #179 JSON parse bug — strip markdown fences from LLM response（简单修复，适合打工）
- [ ] #261 provider login 文档/行为不一致（需要看代码确认）

## 学习记录

- 2026-04-08: 首次研究，v1.0.0 刚发布 4 天
- 2026-04-10: 跟进 v1.0.0-beta.4（Apr 9 发布）
  - 变化：embedding progress tracking + 429 retry, 跨平台依赖管理, MIME 大小写修复
  - #274: o4-mini 兼容性 bug（regex `^o[13]` 漏了 o4），PR #275 修 `^o\d`
  - 社区节奏快：beta.3→beta.4 仅隔 2 天，外部贡献者活跃
  - #179 JSON parse bug 仍 open，仍是可打工目标
  - 新 issue #273（模型切换）、#278（MiniMax 兼容）值得关注
