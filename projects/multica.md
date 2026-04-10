# Multica

> multica-ai/multica — 开源 managed agents 平台
> 首次记录: 2026-04-10 | Stars: ~5k (trending +1680/day)

## 是什么

把 coding agent（Claude Code/Codex/OpenClaw/OpenCode）变成"队友"的平台。核心概念：
- **Agent as Teammate**: agent 有 profile，出现在看板上，能评论/建 issue/汇报 blocker
- **Task Lifecycle**: enqueue → claim → start → complete/fail，WebSocket 实时流
- **Reusable Skills**: 每个解决方案变成可复用 skill，团队能力随时间复利
- **Unified Runtimes**: 本地 daemon 或云 runtime，自动检测可用 CLI
- **Multi-Workspace**: 团队级隔离

## 架构

- Frontend: Next.js 16 (App Router)
- Backend: Go (Chi + sqlc + gorilla/websocket)
- DB: PostgreSQL 17 + pgvector
- Agent Runtime: 本地 daemon，执行 `claude`/`codex`/`openclaw`/`opencode`

## 跟 OpenClaw 的关系

**互补 > 竞争。** OpenClaw 是 agent 的"操作系统"（gateway + 插件 + 工具链），Multica 是上层的"项目管理"层。Multica daemon 已支持 OpenClaw 作为 runtime provider。

类比：OpenClaw ≈ OS，Multica ≈ Jira for agents。

## 值得关注

- Skills 复用机制：跟 OpenClaw skills 有什么异同？
- daemon 如何跟 OpenClaw gateway 交互？（是直接 spawn CLI 还是走 ACP？）
- pgvector 用在哪？（猜测是 skill 检索）
- 打工候选？Go backend + Next.js，技术栈匹配

## 打工潜力

新项目(~2周)，增长快，Apache-2.0，Go+TS 栈我们熟。值得观察 1-2 周看社区活跃度。
