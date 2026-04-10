# Multica

**Repo**: [multica-ai/multica](https://github.com/multica-ai/multica)
**首次关注**: 2026-04-10
**Stars**: 5.3k (+1680/day，爆发期)
**语言**: TypeScript
**License**: Apache-2.0

## 定位

"Managed agents platform" — 把 coding agent 变成团队成员。分配 issue 给 agent，agent 自主执行、报告 blockers、更新状态。

核心卖点：**skill compounding** — 每次解决方案变成可复用 skill，团队能力随时间累积。

## 架构

- Docker self-host: PostgreSQL + backend + frontend
- CLI daemon 连接本地 agent runtime
- WebSocket 实时进度
- Multi-workspace 隔离

## 支持的 Runtime

Claude Code, Codex, [[OpenClaw]], OpenCode — 把自己定位为 runtime-agnostic 管理层。

## 与 OpenClaw 的关系

**竞品+互补**:
- multica 专注 **agent as managed worker**（任务板、进度追踪、团队协作）
- [[OpenClaw]] 专注 **agent as personal assistant**（消息路由、多平台、生活集成）
- multica 把 OpenClaw 列为支持的 runtime 之一，说明他们认为两者是不同层

**启发**: 如果 OpenClaw 想做 "多 agent 协作" 方向，multica 的 skill reuse 机制值得参考。但 OpenClaw 的优势在消息和个人化，不需要直接竞争任务管理赛道。

## 与 [[Archon]] 的区别

Archon 是 "harness builder"（让 AI coding 可重复）；multica 是 "team manager"（让 agent 像同事一样协作）。不同层次。

## 快速判断

- 增速惊人但可能是 trending 泡沫
- 核心 idea（skill compounding）有价值
- 不需要深入跟进，定期扫一眼即可
