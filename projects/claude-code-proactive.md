# Claude Code Proactive Mode 研究笔记

> 源码版本：2026-04 读码分析
> 最后更新：2026-04-01

---

## 架构概览

Proactive mode 让 Claude Code 变成"常驻自主 agent"——不再是问答式，而是主动寻找工作做。

```
Proactive mode 架构：

  tick timer ──→ <tick>timestamp</tick> ──→ query loop
       ↑                                      │
       │                                      ↓
   Sleep Tool ←──── "nothing to do" ────── agent 判断
       │                                      │
       └── wake (timeout/interrupt) ────→  有事做 → 执行工具
       
  CronScheduler ──→ enqueue prompt ──→ 等 REPL 空闲 ──→ 执行
```

三个核心组件：
1. **Tick 机制** — 定期"叫醒"agent
2. **SleepTool** — agent 主动等待（控制 pace）
3. **CronScheduler** — 定时任务调度

---

## Tick 机制

### 什么是 Tick
- XML 格式：`<tick>10:30:45 AM</tick>`（当前本地时间）
- 含义："你醒了，有什么要做的？"
- 多个 tick 可能 batch 到一条消息——只处理最新的

### Agent 行为规则
- **有事做** → 直接做（读文件、跑命令、写代码），不问
- **没事做** → **必须调 Sleep**，禁止回复"还在等"
- **首次 tick** → 打招呼，问用户要做什么。**不要主动探索代码库**
- **用户在线时** → 频繁检查消息，保持紧密反馈循环
- **用户没回复** → 不要重复问

### Build-time Gate
- `feature('PROACTIVE')` 或 `feature('KAIROS')` — 编译时 dead code elimination
- `proactiveModule?.isProactiveActive()` — 运行时检查
- proactive module 是懒加载的（`require('../proactive/index.js')`）

---

## SleepTool

**文件**: `src/tools/SleepTool/prompt.ts`（定义在 prompt 中，实际工具通过 `feature('PROACTIVE')` 条件加载）

### 设计
- 参数：sleep 时长
- 用户可以随时打断
- 可以与其他工具并行调用（不阻塞）
- 比 `Bash(sleep ...)` 更轻——不占 shell 进程

### Pace 控制
- prompt cache 5 分钟后过期 → 平衡唤醒频率和 cache 利用
- 等慢进程 → sleep 长一点
- 主动迭代 → sleep 短一点
- 每次唤醒 = 一次 API 调用 → 有成本意识

---

## CronScheduler（`src/utils/cronScheduler.ts`）

### 核心设计
- **1 秒 check 间隔**（`CHECK_INTERVAL_MS = 1000`）
- **只在 REPL 空闲时触发**（`isLoading()` gate）
- **file watcher**（chokidar）监听 `.claude/scheduled_tasks.json`
- **scheduler lock**（per-project，防止多个 Claude 实例 double-fire）

### 两种任务类型

| | Session-only | Durable |
|---|---|---|
| 持久化 | 内存中 | `.claude/scheduled_tasks.json` |
| 重启后 | 丢失 | 自动恢复 |
| 场景 | "5 分钟后提醒我" | "每天早上 9 点检查" |
| 默认 | ✅ | 需要 `durable: true` |

### Jitter 设计（避免 :00 踩踏）
- recurring：fire time 后加最多 10%（max 15 min）随机延迟
- one-shot：:00 或 :30 分钟的任务提前最多 90s
- **prompt 级别也避免 :00 和 :30**——用户说"每小时"→ 选 `7 * * * *` 不是 `0 * * * *`
- 原因：全球所有用户的"9 点"都落在同一时刻 → API 压力

### 过期机制
- recurring 任务自动过期（`DEFAULT_MAX_AGE_DAYS`，从 config 算出）
- aged-out 的 recurring 任务最后 fire 一次再删除
- `permanent` 标志可以跳过 aging

### Missed Task 处理
- 启动时扫描：哪些 one-shot 任务在 Claude 关闭期间过期了？
- 不自动执行——先用 `AskUserQuestion` 工具问用户要不要补跑
- prompt 用 code fence 包装，防 prompt injection

### Lock 机制
- per-project `scheduler.lock` 文件
- PID-based liveness probe（owner 死了 → 其他 session takeover）
- 非 owner session 每 5s probe 一次（`LOCK_PROBE_INTERVAL_MS`）

---

## /loop Skill（`src/skills/bundled/loop.ts`）

用户友好的 cron 入口：
```
/loop 5m /babysit-prs        ← 每 5 分钟跑一次
/loop 30m check the deploy   ← 每 30 分钟检查
/loop 1h /standup 1           ← 每小时
/loop check the deploy        ← 默认间隔（10m）
```

底层调用 `CronCreateTool`，只是语法糖。

---

## CronCreateTool（`src/tools/ScheduleCronTool/CronCreateTool.ts`）

### 参数

| 参数 | 类型 | 说明 |
|---|---|---|
| cron | string | 标准 5 字段 cron 表达式（本地时间） |
| prompt | string | 触发时执行的 prompt |
| recurring | boolean | true=循环，false=一次性 |
| durable | boolean | true=持久化到文件 |

### 限制
- 最多 50 个 job（`MAX_JOBS`）
- teammate 不能创建 durable cron（重启后 agentId 会指向不存在的 teammate）
- `CLAUDE_CODE_DISABLE_CRON` 环境变量可以完全关闭

---

## 对比分析：Claude Code vs OpenClaw

| 维度 | Claude Code | OpenClaw |
|---|---|---|
| **Tick 机制** | `<tick>` XML，proactive mode 下定期发送 | heartbeat（每 30m），可配置 |
| **Sleep 机制** | SleepTool（agent 主动等待，可打断） | 无（heartbeat 间隔固定） |
| **Cron** | CronCreateTool（agent 自建） | openclaw.json cron（config 配置） |
| **Durable** | session-only + durable 双轨 | 全部持久化（config 文件） |
| **Jitter** | 内置 jitter + prompt 级避 :00 | 无 |
| **Lock** | per-project scheduler lock | 无（单 gateway 实例） |
| **Missed task** | 启动时检测 + 问用户 | 无（错过就错过） |
| **自主模式** | proactive mode（独立 feature flag） | heartbeat + 自触发（HEARTBEAT.md 驱动） |
| **Pace 控制** | SleepTool + prompt cache 意识 | 固定 heartbeat 间隔 |

### OpenClaw 的优势
- heartbeat + HEARTBEAT.md 驱动——纯文本配置，更简单
- cron 在 config 中声明式定义，不需要 agent 运行时创建
- 单 gateway 实例天然没有 double-fire 问题

### Claude Code 的优势
- **Agent 自主创建 cron**——不依赖人工配置
- **SleepTool 控制 pace**——比固定间隔更灵活
- **Jitter 设计**——大规模部署必需
- **Durable + session-only 双轨**——按需持久化
- **Missed task 恢复**——重启后不丢任务

---

## 可借鉴的设计

1. **Agent 自建 cron**：让 agent 自己决定什么时候检查什么——比在 config 里预设更灵活。OpenClaw 的 cron 工具可以开放给 agent
2. **Pace 控制（SleepTool 思路）**：heartbeat 间隔应该可以动态调整——忙的时候 5 分钟一次，闲的时候 30 分钟。不需要完整的 SleepTool，但 heartbeat 间隔应该可变
3. **Jitter**：如果 OpenClaw 大规模部署，cron 需要 jitter 防止 API 踩踏
4. **Missed task 恢复**：gateway 重启后检查哪些 cron 在关闭期间该触发但没触发
5. **"必须 Sleep，禁止废话"**：proactive mode 的这条规则很好——我们的 heartbeat 如果没事做，回 HEARTBEAT_OK 而不是"我检查了没什么新的"。已经在做了
6. **Prompt-level jitter 意识**：让 agent 理解"不要把所有任务安排在整点"——这是集群意识
