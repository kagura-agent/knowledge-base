# Claude Code Memory 系统研究笔记

> 源码版本：2026-04 读码分析
> 最后更新：2026-04-01

---

## 架构概览

三个核心组件 + 四个支撑模块。

```
query loop 结束
  ├─ extractMemories（实时提取，fire-and-forget）
  ├─ autoDream（后台整理，有 gate）
  └─ ...

新 query 进入
  └─ findRelevantMemories（检索注入 context）
```

---

## 核心组件

### 1. extractMemories — 实时提取

**文件：** `src/services/extractMemories/extractMemories.ts`

**触发时机：** 每次 query loop 结束（`stopHooks.ts` → `handleStopHooks`），fire-and-forget。

**机制：** `runForkedAgent` — fork 主对话（共享 prompt cache），让 fork 分析最近 N 条消息并提取记忆。

**关键设计：**

| 设计点 | 实现 |
|---|---|
| 互斥 | 主 agent 已写 memory 文件 → extraction 跳过（`hasMemoryWritesSince`） |
| 工具限制 | Read/Grep/Glob + 只读 Bash + Edit/Write **仅限 memory 目录** |
| 深度限制 | `maxTurns: 5`（防止 rabbit hole） |
| 节流 | `tengu_bramble_lintel` 控制每 N 个 turn 才跑一次 |
| 重叠保护 | `inProgress` 时新请求 stash，当前完成后跑 trailing extraction |
| 游标 | `lastMemoryMessageUuid` 追踪处理进度，只看新消息 |

**设计要点：**
- fork 共享 prompt cache → 不额外付 prefill 成本
- 工具白名单确保 extraction agent 不会乱改代码
- 游标机制保证不重复处理

### 2. autoDream — 后台整理

**文件：** `src/services/autoDream/autoDream.ts`

**触发时机：** 也在 `stopHooks`，但有三道 gate：

```
Time gate:    距上次整理 ≥ minHours（默认 24h）
Session gate: 上次整理后 ≥ minSessions 个 session 有过活动（默认 5）
Lock gate:    文件锁（PID + mtime），防止并发
```

三道 gate 全过才执行。

**机制：** `runForkedAgent`，prompt 来自 `consolidationPrompt.ts`。

**四阶段流程：**

1. **Orient** — 理解当前记忆结构
2. **Gather recent signal** — 读 session transcripts（JSONL），grep 窄搜，不全读
3. **Consolidate** — 合并/删除/更新记忆
4. **Prune and index** — 维护 `MEMORY.md` 索引 ≤ 200 行

**其他细节：**
- `DreamTask` 注册到 UI，用户可以 kill
- 读 transcript 用 grep 窄搜而非全文读取（控制 token）

### 3. findRelevantMemories — 检索

**文件：** `src/memdir/findRelevantMemories.ts`

**触发时机：** 每次新 query 时。

**两步流程：**

```
scanMemoryFiles（扫目录，解析 frontmatter）
  → 生成 memory manifest
    → Sonnet sideQuery 选最相关的（最多 5 个）
```

**关键细节：**

| 项 | 说明 |
|---|---|
| 扫描 | 读 `.md` frontmatter（description + type），按 mtime 排序，上限 200 个 |
| 选择器 | **Sonnet**（不是 embedding），输入是 query + memory manifest |
| 去重 | `alreadySurfaced` 过滤已展示的记忆，避免同一 session 重复注入 |

**设计选择：用 LLM 而非 embedding 做检索。** 好处是语义理解更强，代价是每次 query 多一次 Sonnet 调用。

---

## 支撑模块

### memoryTypes.ts — 分类体系

四种类型，通过 frontmatter `type` 字段区分：

| 类型 | 内容 | 示例 |
|---|---|---|
| `user` | 用户角色、偏好、知识水平 | "Luna prefers Chinese" |
| `feedback` | 用户反馈（纠正 **AND** 确认） | "User confirmed this approach works" |
| `project` | 进行中的工作、目标、bug | "Working on memory refactor" |
| `reference` | 外部系统指针 | "Jira board at ..." |

**核心设计："Record from failure AND success"**
- 不只记错误纠正，确认（"这样做对了"）也要记
- 双向记录避免只学到"不该做什么"

**明确排除（不存入记忆的）：**
- 代码模式（code patterns）
- git 历史
- 调试方案
- CLAUDE.md 已有的内容
- 临时任务状态

### memoryAge.ts — 新鲜度管理

**设计动机：** 用户报告旧记忆被当作事实断言（"memory drift"）。

```
memoryAgeDays     → 按 mtime 算天数
memoryFreshnessText → >1 天的加 staleness caveat
memoryFreshnessNote → 包在 <system-reminder> 标签里注入 context
```

### memoryScan.ts — 目录扫描

```
scanMemoryFiles    → 读目录、解析 frontmatter、按 mtime 排序、上限 200 个
formatMemoryManifest → 格式化为文本清单
```

供 extraction agent 和 recall selector 共用。

### MEMORY_DRIFT_CAVEAT / TRUSTING_RECALL_SECTION

关键原则：
> "The memory says X exists" is not the same as "X exists now"

- 记忆可能过时，使用前必须验证当前状态
- eval-validated：H1 0/2→3/3，H5 0/2→3/3（加了 caveat 后 eval 全过）

---

## 数据流总览

```
┌─────────────────────────────────────────────────────┐
│                    Session 运行时                      │
│                                                       │
│  新 query ──→ findRelevantMemories ──→ 注入 context   │
│      │         (scanMemoryFiles + Sonnet sideQuery)   │
│      ▼                                                │
│  agent 执行 query loop                                │
│      │                                                │
│      ▼                                                │
│  stopHooks                                            │
│      ├─ extractMemories (fork agent, fire-and-forget) │
│      │    └─ 写 memory/*.md (frontmatter + content)   │
│      │                                                │
│      └─ autoDream (三道 gate)                          │
│           └─ 四阶段整理                                │
│              └─ 更新 MEMORY.md 索引 (≤200 行)          │
└─────────────────────────────────────────────────────┘
```

---

## 对比分析：Claude Code vs Kagura/OpenClaw

| 维度 | Claude Code | Kagura/OpenClaw |
|---|---|---|
| **提取** | 自动 fork agent 提取（每次 query 后） | 手动（nudge 触发写 beliefs-candidates） |
| **整理** | autoDream 自动（24h + 5 session gate） | daily-review cron（FlowForge） |
| **检索** | Sonnet sideQuery 选 top-5 | memory_search FTS/hybrid |
| **分类** | 4 类 frontmatter（user/feedback/project/reference） | 无分类（纯文本） |
| **新鲜度** | mtime + staleness caveat（>1天加提醒） | 无（MEMORY.md 手写日期） |
| **双向记录** | feedback 类型明确记 confirmation | beliefs-candidates 有 confirmation 但较晚加入 |
| **索引** | MEMORY.md ≤200 行，一行一指针 | MEMORY.md 当内容写，已超 200 行 |
| **排除规则** | 明确列出不该存什么 | 无明确排除规则 |

**差距总结：** Claude Code 的 memory 系统是全自动闭环（提取→整理→检索），Kagura 目前是半手动（nudge 触发提取、cron 整理、FTS 检索），缺分类/新鲜度/排除规则。

---

## 可落地改进方案

### P0 — 已有 TODO，优先推进

1. **MEMORY.md 纯索引化**
   - MEMORY.md 只留指针 ≤200 行
   - 内容移到 `memory/` 或 `knowledge-base/`
   - 参考 Claude Code 的 MEMORY.md 索引设计

2. **memory/ 文件加 frontmatter**
   - 加 `type: user | feedback | project | reference`
   - 加 `description:` 一行摘要
   - memory_search 可以用 frontmatter 做预筛选

### P1 — 新增机制

3. **staleness caveat**
   - 引用 >14 天的记忆时加 caveat（"此记忆可能已过时"）
   - daily-review 扫描过期条目，标记或提醒验证

4. **排除规则**
   - AGENTS.md 或 NUDGE.md 明确列出不存入记忆的类别：
     - 代码模式 / git 历史 / 调试方案
     - 已在 CLAUDE.md/AGENTS.md 中的内容
     - 临时任务状态

### P2 — 增强现有

5. **confirmation 记录强化**
   - NUDGE.md 已有 confirmation 类型，继续强化
   - "这样做对了" 和 "这样做错了" 同等重要

6. **检索改进**
   - memory_search 升级为两步：先扫 frontmatter 缩小范围 → 再语义匹配
   - 类似 Claude Code 的 `scanMemoryFiles` + `sideQuery` 模式
   - 考虑用 LLM 做最终选择而非纯 FTS

---

## 值得借鉴的设计决策

1. **fork 共享 prompt cache** — 提取不额外付 prefill 成本，这是 Claude Code 能"免费"做自动提取的关键
2. **三道 gate 控制整理频率** — 不是定时跑，而是"够了才跑"（时间+session数+锁），避免浪费
3. **Sonnet 做检索而非 embedding** — 语义理解更强，适合记忆数量不大（≤200）的场景
4. **排除规则比包含规则更重要** — 明确说"不存什么"比"存什么"更能控制记忆质量
5. **eval-driven 的 caveat** — MEMORY_DRIFT_CAVEAT 是因为 eval 发现问题才加的，有数据支撑（H1/H5 从 0/2 到 3/3）
