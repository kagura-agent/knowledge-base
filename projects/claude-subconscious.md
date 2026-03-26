# claude-subconscious (Letta)

> "Give Claude Code a subconscious" — 1.5k⭐，TypeScript

## 核心设计

一个**背景 agent**，通过 Claude Code Plugin 系统注入，不修改 Claude Code 代码：
- 看每个 session 的 transcript
- 用工具（Read, Grep, Glob）读代码
- 建持久记忆（跨 session）
- 在每个 prompt 前 "whisper" 上下文回 Claude Code

## 架构

```
Claude Code ◄──► Letta Agent (background)
  │                  │
  │ session start    │ new session notification
  │ before prompt    │ whisper guidance → stdout
  │ before tool use  │ mid-workflow updates → stdout
  │ after response   │ transcript → SDK session (async)
  │                  │   → reads files, updates memory
```

## 跟我们的对比

| 维度 | claude-subconscious | 我们 (OpenClaw + Kagura) |
|------|-------------------|--------------------------|
| 宿主 | Claude Code（外挂） | OpenClaw（原生） |
| 记忆载体 | Letta memory blocks | MEMORY.md + self-improving/ |
| 触发机制 | Plugin hooks | nudge (agent_end) + heartbeat |
| 注入方式 | stdout XML injection | system prompt context |
| 持久化 | Letta Cloud API | 本地文件 + git |
| 记忆更新 | 后台 agent 自动 | 混合（自动 + 手动） |
| 可观察性 | Letta Dashboard | evolution-log + 飞书通知 |

## 关键洞察

1. **外挂 vs 原生**：他们必须通过 stdout 注入（因为 Claude Code 是黑盒），我们直接在 system prompt 里。这让他们的架构更 hacky 但也更通用
2. **背景 agent 模式**：他们的 subconscious agent 是独立运行的——看 transcript 后自己决定记什么。这比我们的 nudge（只在 agent_end 时触发一次 prompt）更强大
3. **Memory blocks ≈ 我们的 workspace files**：他们把记忆分成 user_preferences, project_context 等块。我们用 MEMORY.md, USER.md, SOUL.md 等文件做同样的事
4. **"It takes a few sessions"**：他们承认记忆需要时间积累——跟我们的"居住期"完全一致

## 值得借鉴

- **Diff-based memory updates**：首次注入完整 memory blocks，后续只注入变化（`<letta_memory_update>` diff）。减少 token 消耗
- **Mid-workflow whispers**：不只是 session 开始时注入，在 tool use 之前也注入。更像人类的"直觉"

## 在生态中的位置

属于 [[self-evolving agent landscape]] 的 Memory 层。
跟 [[hindsight]]（后端记忆基础设施）互补：hindsight 提供记忆 API，claude-subconscious 是消费者。
跟我们的定位不同：他们给别人的 agent 加记忆，我们的 agent 自己有记忆。

## 相关

- [[self-evolving agent landscape]]
- [[hermes-agent]] — 同在 self-evolving 方向
- [[nudge plugin]] — 我们的等价物（但更轻量）
