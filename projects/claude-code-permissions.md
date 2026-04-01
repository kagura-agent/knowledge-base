# Claude Code Permission 系统研究笔记

> 源码版本：2026-04 读码分析
> 最后更新：2026-04-01

---

## 架构概览

Permission 系统控制 agent 能做什么、不能做什么。核心是**分层规则 + LLM classifier + 用户确认**的三重门。

```
工具调用请求
  │
  ├─ Safe allowlist? ──→ 直接通过（read-only 工具等）
  │
  ├─ Permission mode 检查
  │   ├─ bypassPermissions → 全部通过
  │   ├─ plan → 只读工具通过，写操作拒绝
  │   ├─ acceptEdits → 文件编辑通过，bash 需分类
  │   ├─ auto → LLM classifier 决定
  │   └─ default → 规则匹配 + 用户确认
  │
  ├─ 规则匹配（allow/deny/ask rules）
  │   ├─ managed（企业策略）
  │   ├─ user（~/.claude/settings.json）
  │   ├─ project（.claude/settings.json）
  │   ├─ local（.claude/settings.local.json）
  │   ├─ session（运行时积累）
  │   └─ cliArg（命令行参数）
  │
  └─ 用户确认 → allow once / allow always / deny
```

---

## Permission Modes（6 种）

| Mode | 行为 | 场景 |
|---|---|---|
| `default` | 规则匹配 + 用户确认 | 正常使用 |
| `plan` | 只读，写操作全拒 | 规划阶段 |
| `acceptEdits` | 文件编辑自动通过，bash 需确认 | 快速编码 |
| `bypassPermissions` | 全部通过 | CI/脚本/信任场景 |
| `dontAsk` | 不匹配规则就拒绝（不问用户） | 非交互 |
| `auto` | LLM classifier 自动判断 | 内部测试（TRANSCRIPT_CLASSIFIER flag） |

### Auto Mode（Yolo Classifier）
- 用 LLM（classifier）分析工具调用的 transcript 上下文
- 两阶段：fast（快速判断）→ thinking（需要深思的复杂情况）
- 有 denial tracking：连续被拒太多次 → 回退到 prompt 模式
- circuit breaker：GrowthBook 可以远程关闭
- **Safe allowlist**：read-only 工具直接通过不走 classifier（省 token）

---

## 规则系统

### 三种行为
- `allow` — 自动通过
- `deny` — 自动拒绝
- `ask` — 每次问用户

### 规则来源（优先级从高到低）
1. `managed`（企业策略，不可覆盖）
2. `policySettings`（组织策略）
3. `cliArg`（命令行参数）
4. `session`（运行时积累的 "always allow" 选择）
5. `userSettings`（~/.claude/settings.json）
6. `projectSettings`（.claude/settings.json）
7. `localSettings`（.claude/settings.local.json）

### 规则格式
```
Bash(npm test)          ← exact match
Bash(npm:*)             ← prefix match（legacy）
Bash(npm run *)         ← wildcard match
Edit(src/**/*)          ← 文件路径 wildcard
```

### Dangerous Pattern 检测
- 允许 `Bash(python:*)` = 允许任意代码执行 → 自动剥离
- 危险 pattern 列表：python, node, bash, ssh, eval, exec, sudo, curl...
- auto mode 进入时自动清理危险 allow rules（`strippedDangerousRules`）

---

## Shell Permission 特殊处理

### Bash/PowerShell 分类
- **精确匹配**：`Bash(npm test)` 只匹配完全相同的命令
- **前缀匹配**：`Bash(npm:*)` 匹配 `npm` 开头的命令
- **Wildcard**：`Bash(npm run *)` 支持 glob 模式
- 正则用 null-byte sentinel 处理转义

### 输出重定向检测
- `extractOutputRedirections()` 检测 `>`, `>>` 等
- 重定向到 project 外的路径需要额外权限

---

## Permission Decision 结果

| 类型 | 含义 | 附加信息 |
|---|---|---|
| `allow` | 通过 | 可选 updatedInput, acceptFeedback |
| `ask` | 需要用户确认 | message, suggestions（快捷 allow rule） |
| `deny` | 拒绝 | message, decisionReason |
| `passthrough` | 透传（不做判断） | 委托给其他系统 |

### Decision Reason 类型
- `rule` — 匹配到某条规则
- `mode` — 当前 mode 决定
- `classifier` — auto mode classifier 判断
- `hook` — hook 系统决定
- `sandboxOverride` — sandbox 覆盖
- `safetyCheck` — 安全检查
- `workingDir` — 工作目录限制

---

## Hooks 集成

Permission 系统支持通过 hooks 介入：
- `executePermissionRequestHooks()` — 在 permission 决策前执行 hook
- Hook 可以覆盖决策（allow/deny/ask）
- Hook 来源标注（`hookName`, `hookSource`）

---

## 对比分析：Claude Code vs OpenClaw

| 维度 | Claude Code | OpenClaw |
|---|---|---|
| **Permission modes** | 6 种（default/plan/acceptEdits/bypass/dontAsk/auto） | 2 种（正常 / elevated） |
| **规则粒度** | per-tool + per-command（`Bash(npm test)`） | per-tool（allow/deny 工具列表） |
| **规则来源** | 7 层优先级（managed→local） | config 文件 + elevated 白名单 |
| **LLM classifier** | auto mode（两阶段 classifier） | 无 |
| **Dangerous pattern** | 自动检测 + 剥离 | 无 |
| **Shell 安全** | 命令级 pattern matching + 重定向检测 | exec 工具统一处理 |
| **用户确认 UI** | 交互式 dialog（allow once/always/deny） | /approve 命令 |
| **Sandbox 集成** | sandbox 覆盖 permission | 独立的 sandbox 系统 |
| **企业管控** | managed 策略（不可覆盖） | 无 |

### OpenClaw 的优势
- 更简单——两层就够用（正常 + elevated）
- /approve 命令行体验更统一
- 不需要 LLM 做 permission 判断（省 token）

### Claude Code 的优势
- **命令级细粒度**：`Bash(npm test)` 而非整个 exec 工具
- **Auto mode**：LLM 理解上下文自动判断安全性
- **Dangerous pattern 检测**：防止用户意外放行危险命令
- **企业管控层**：managed 策略不可被用户覆盖
- **Session 级积累**："always allow" 选择在 session 内积累，不持久化

---

## 可借鉴的设计

1. **命令级权限**：OpenClaw 的 elevated 是 tool 级的（exec yes/no）。可以加命令级白名单：`exec:allow:["npm test", "git status"]`
2. **Dangerous pattern 检测**：防止 agent 被 prompt inject 执行危险命令。简单版：维护一个危险命令前缀列表
3. **Session 级规则积累**：用户在 session 中选了 "always allow npm test"，这个 session 后续不再问。不持久化 = 安全
4. **Permission suggestions**：ask 时附带快捷 allow rule 建议——用户一键加规则，减少重复确认
5. **Plan mode**：只读模式让 agent 先看再做。OpenClaw 可以在 subagent 上实现类似的 read-only 模式
