# Claude Code Coordinator / Multi-Agent 编排研究笔记

> 源码版本：2026-04 读码分析
> 最后更新：2026-04-01

---

## 架构概览

Claude Code 有两种 multi-agent 模式：**Coordinator 模式**（显式编排）和 **Fork 模式**（隐式分叉）。两者互斥。

```
Coordinator 模式（CLAUDE_CODE_COORDINATOR_MODE=1）:
  coordinator ──AgentTool──→ worker（异步）
       ↑                         │
       └── <task-notification> ──┘
       
Fork 模式（默认，feature gate: FORK_SUBAGENT）:
  parent agent ──AgentTool(无subagent_type)──→ fork child
       ↑                                          │
       └──── <task-notification> ─────────────────┘
```

---

## Agent 类型体系

### 1. Coordinator + Worker
- **coordinator**：不直接执行工具（除了 AgentTool / SendMessage / TaskStop），专注任务分解和结果综合
- **worker**：通过 `AgentTool({ subagent_type: "worker" })` 创建，有完整工具访问权
- worker 结果通过 `<task-notification>` XML 返回给 coordinator（作为 user message 注入）
- coordinator 可以用 `SendMessageTool` 继续已有 worker（保留上下文），或 spawn 新 worker

### 2. Fork Child
- 通过 `AgentTool` 省略 `subagent_type` 触发
- 继承父对话的完整上下文（消息历史 + system prompt）
- 共享 prompt cache（关键优化——fork child 和父对话用相同的 cache key prefix）
- 不允许递归 fork（`isInForkChild` 检测 `FORK_BOILERPLATE_TAG`）
- 强制规则：不对话、不 spawn 子 agent、500 字以内报告、以 "Scope:" 开头

### 3. Teammate（Swarm 模式）
- 通过 CLI args（`--agent-id`, `--team-name`）或 in-process AsyncLocalStorage 设置身份
- 两种运行方式：tmux（独立进程）或 in-process（AsyncLocalStorage 隔离）
- 有 TeammateIdle 和 TaskCompleted hooks
- 用于更大规模的 agent 协作

---

## 通信机制

### task-notification XML
worker/fork 完成后返回结构化 XML：
```xml
<task-notification>
  <task-id>{agentId}</task-id>
  <status>completed|failed|killed</status>
  <summary>{human-readable}</summary>
  <result>{agent's final text}</result>
  <usage><total_tokens>N</total_tokens>...</usage>
</task-notification>
```
作为 user message 注入 coordinator 的对话流。

### SendMessageTool
coordinator 用 `SendMessage({ to: agentId, message: "..." })` 向已有 worker 发后续指令。worker 保留完整上下文——适合纠错和继续工作。

### TaskStopTool
coordinator 可以停止正在运行的 worker（方向错了或需求变了）。停止后仍可通过 SendMessage 继续。

### Scratchpad（跨 worker 共享目录）
- 路径：`/tmp/claude-{uid}/{sanitized-cwd}/{sessionId}/scratchpad/`
- 在 scratchpad 内读写不需要 permission prompt
- coordinator system prompt 告知所有 worker 这个路径
- 用途：跨 worker 持久化中间结果（结构自定义）

---

## Memory 策略

### 三种 Scope

| Scope | 路径 | 用途 | VCS |
|---|---|---|---|
| user | `~/.claude/agent-memory/<agentType>/` | 跨项目通用经验 | 否 |
| project | `<cwd>/.claude/agent-memory/<agentType>/` | 项目特定知识 | 是 |
| local | `<cwd>/.claude/agent-memory-local/<agentType>/` | 项目+机器特定 | 否 |

- 每个 agent type 独立目录
- 入口文件是 `MEMORY.md`
- `loadAgentMemoryPrompt` 在 agent spawn 时注入 system prompt

### Snapshot 同步
- `agent-memory-snapshots/<agentType>/` 存储快照
- 通过 `snapshot.json` 和 `.snapshot-synced.json` 追踪版本
- 支持把快照同步到 local scope

### 隔离原则
- 每个 agent type 有自己的 memory 目录
- worker 不共享 coordinator 的 auto-memory（`extractMemories` 跳过 subagent）
- scratchpad 是唯一的跨 worker 共享通道

---

## 进度监控

### AgentSummary（`agentSummary.ts`）
- 每 30s fork 一次 worker 对话，生成 3-5 词进度摘要
- 用 `runForkedAgent` 共享 prompt cache
- 工具全 deny（只需要文本输出）
- 摘要更新到 UI（`updateAgentSummary`）
- 避免重复：传 previousSummary，要求 "say something NEW"

---

## Coordinator System Prompt 关键设计

### 任务四阶段
```
Research（并行）→ Synthesis（coordinator）→ Implementation（worker）→ Verification（worker）
```

### "必须综合，不能转发"
- coordinator 读完 research 结果后**必须自己理解**
- 禁止 "based on your findings, fix it"（lazy delegation）
- 好的 prompt 包含具体文件路径、行号、改什么

### Continue vs Spawn 决策
| 场景 | 选择 | 原因 |
|---|---|---|
| research 探索的文件就是要改的 | Continue | 上下文重叠高 |
| research 广泛但实现很窄 | Spawn fresh | 避免噪声 |
| 纠错/继续之前的工作 | Continue | 有错误上下文 |
| 验证别人写的代码 | Spawn fresh | 新鲜视角 |
| 之前方向完全错误 | Spawn fresh | 避免锚定效应 |

---

## 对比分析：Claude Code vs OpenClaw

| 维度 | Claude Code | OpenClaw |
|---|---|---|
| **编排模式** | Coordinator（显式）+ Fork（隐式），互斥 | subagent（通用）+ ACP（harness） |
| **通信** | task-notification XML + SendMessage | push-based completion event |
| **共享状态** | Scratchpad 目录 | 无（靠文件系统） |
| **Agent 记忆** | 三 scope（user/project/local）+ snapshot 同步 | 无独立 agent 记忆 |
| **进度监控** | 每 30s fork 摘要 | 无（只有完成通知） |
| **prompt cache** | fork 共享 parent cache | 不共享 |
| **任务控制** | Stop + Continue（保留上下文） | kill（丢上下文） |
| **递归防护** | isInForkChild 检测 | 无 |

### OpenClaw 的优势
- subagent 更通用（不限于 worker 角色）
- ACP 支持多种 harness（Claude Code、Codex 等）
- 更简单的心智模型

### Claude Code 的优势
- prompt cache 共享（fork 零额外 prefill 成本）
- Continue 机制（不丢上下文）
- Scratchpad（跨 worker 结构化共享）
- Agent-level memory（持久化跨 session）
- 进度监控（用户实时看到 worker 在做什么）
- 递归防护

---

## 可借鉴的设计

1. **Scratchpad**：给 subagent 一个共享临时目录，不需要靠文件系统约定。OpenClaw 可以在 spawn 时传 scratchpad 路径
2. **Continue 机制**：subagent 完成后能继续（保留上下文），而不是只能 kill + 重 spawn
3. **Agent-level memory**：每个 agent type 有独立持久记忆，跨 session 积累。比全局 MEMORY.md 更细粒度
4. **进度摘要**：长任务时每 30s 生成摘要，用户不用盲等。可以用 heartbeat 或 polling 模拟
5. **"必须综合不能转发"**：coordinator 读完结果必须自己理解再写 spec——这是我做研究时的教训（把任务整块丢给子 agent ≠ 理解）
6. **Continue vs Spawn 决策框架**：按上下文重叠度选择，不是默认总 spawn 新的
