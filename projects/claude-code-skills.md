# Claude Code Skill 系统研究笔记

> 源码版本：2026-04 读码分析（Claude Code CLI 输出）
> 最后更新：2026-04-01

---

## 架构概览

Skill 本质上是一个 `PromptCommand` 对象（type: `'prompt'`）。一个 SKILL.md 文件 = 一个 skill。

```
加载顺序（loadAllCommands 合并）：
  1. bundledSkills        ← 内置在二进制中
  2. builtinPluginSkills  ← 内置插件 skills
  3. skillDirCommands     ← 从磁盘 .claude/skills/ 加载
  4. workflowCommands     ← WORKFLOW_SCRIPTS 功能
  5. pluginCommands       ← 插件命令
  6. pluginSkills         ← 插件 skills
  7. COMMANDS()           ← 内置命令（/help, /clear 等）
  运行时动态：
  8. dynamicSkills        ← 文件操作时动态发现
  9. MCP skills           ← 通过 AppState.mcp.commands 注入
```

---

## Skill 定义格式

### 文件结构
```
.claude/skills/my-skill/
  └── SKILL.md          ← 唯一入口文件，必须是这个名字
```

### SKILL.md 格式：YAML frontmatter + Markdown 正文

```markdown
---
name: 显示名称                    # 可选，覆盖目录名
description: 描述                 # 缺省则从正文第一行提取
when-to-use: 使用场景             # 触发条件说明
allowed-tools:                   # 限制可用工具列表
  - Read
  - Edit
argument-hint: "[filename]"      # 参数提示
arguments:                       # 命名参数
  - filename
model: opus                      # 模型覆盖（或 'inherit'）
effort: high                     # 努力程度: low/medium/high/整数
disable-model-invocation: false  # 禁止模型主动调用
user-invocable: true             # 用户是否可以 /name 调用
context: fork                    # 执行模式: inline（默认）| fork
agent: haiku                     # fork 模式的 agent 类型
paths:                           # 条件激活路径（gitignore 格式）
  - "**/*.ts"
hooks:                           # 生命周期钩子
  post_compact:
    - ref: my_hook
shell:                           # shell 命令配置
  cmd_name:
    path: /custom/bin/cmd
version: "1.0"                   # 版本号
---

Skill 主体内容...
可以使用 ${CLAUDE_SKILL_DIR} 引用同目录文件
可以使用 ${CLAUDE_SESSION_ID} 获取会话 ID
可以使用 $ARGUMENTS 获取用户参数
可以用 !`shell_command` 嵌入 shell 输出
```

### 运行时类型（PromptCommand，`src/types/command.ts:25-57`）

| 字段 | 类型 | 说明 |
|---|---|---|
| type | `'prompt'` | 固定标识 |
| name | string | 唯一标识符 |
| description | string | 描述 |
| source | SettingSource \| 'builtin' \| 'mcp' \| 'plugin' \| 'bundled' | 来源 |
| loadedFrom | LoadedFrom | 加载方式 |
| allowedTools | string[] | 执行时可用工具 |
| model | string | 模型覆盖 |
| context | 'inline' \| 'fork' | 执行模式 |
| paths | string[] | 条件激活路径 |
| hooks | HooksSettings | 钩子 |
| getPromptForCommand | (args, ctx) => Promise<ContentBlockParam[]> | 内容生成函数 |

---

## 加载流程

### 磁盘 Skill 发现路径（`src/skills/loadSkillsDir.ts:638-804`）

```
getSkillDirCommands(cwd) 并行加载：
  ├── managed:  {managedFilePath}/.claude/skills/   ← 企业策略管控
  ├── user:     ~/.claude/skills/                   ← 用户级
  ├── project:  遍历 cwd → home 的所有 .claude/skills/ ← 项目级
  ├── addDir:   --add-dir 指定的额外目录             ← CLI 参数
  └── legacy:   .claude/commands/                    ← 已弃用格式
```

### 去重机制
通过 `realpath()` 解析符号链接获得规范路径，避免同一 skill 通过不同路径被加载两次（`src/skills/loadSkillsDir.ts:118-124`）。

### 动态发现（`src/skills/loadSkillsDir.ts:861-975`）
当文件操作（Read/Write/Edit）触发时：
1. `discoverSkillDirsForPaths()` —— 从文件路径向上遍历到 cwd，查找 `.claude/skills/`
2. `addSkillDirectories()` —— 加载发现的目录，深路径优先
3. 跳过 gitignore 下的目录（安全检查）

### 条件激活（`src/skills/loadSkillsDir.ts:997-1058`）
带 `paths:` frontmatter 的 skill 不会立即注册：
1. 存入 `conditionalSkills` Map
2. 当文件操作匹配路径模式时，`activateConditionalSkillsForPaths()` 将其激活
3. 使用 `ignore` 库做 gitignore 风格匹配
4. 激活后永久加入 `dynamicSkills`，不再回退

---

## 类型体系

### 1. Bundled Skills（内置）
**位置**: `src/skills/bundled/`

通过 `initBundledSkills()` → `registerBundledSkill()` 注册。

**当前内置 Skills**:
- `simplify` — 代码审查和清理
- `remember` — 记忆管理
- `verify` — 验证
- `debug` — 调试
- `keybindings` — 键绑定
- `loop` — 循环执行（需 AGENT_TRIGGERS flag）
- `claude-api` — Claude API 辅助

### 2. 用户/项目 Skills（磁盘加载）
从 `.claude/skills/` 目录发现，三级优先：managed > user > project。
支持动态发现和条件激活。

### 3. MCP Skills
通过 MCP (Model Context Protocol) server 注入。
`AppState.mcp.commands` 管理，运行时动态注册。

---

## 执行机制

### 两种执行模式

| 模式 | context 值 | 行为 |
|---|---|---|
| inline（默认） | `'inline'` | 直接注入当前对话上下文 |
| fork | `'fork'` | fork 出子 agent 执行，结果返回父对话 |

### fork 模式
- 可指定 `agent: haiku` 使用更便宜的模型
- 共享 prompt cache
- 适合独立的、不需要完整上下文的任务

### 变量替换
- `${CLAUDE_SKILL_DIR}` — skill 目录路径
- `${CLAUDE_SESSION_ID}` — 当前会话 ID
- `$ARGUMENTS` — 用户传入的参数
- `` !`shell_command` `` — 嵌入 shell 命令输出（动态内容）

### allowed-tools 限制
skill 可以声明只允许特定工具，执行时其他工具被禁用。安全隔离。

---

## 与 CLAUDE.md 的关系

CLAUDE.md 是全局配置（类似 AGENTS.md），Skills 是可组合的能力单元：
- CLAUDE.md 定义 persona、规则、上下文
- Skills 定义具体的"怎么做某件事"
- Skills 可以在 CLAUDE.md 中被引用和组合
- 条件激活让 skills 按项目路径自动启用

---

## 对比分析：Claude Code vs OpenClaw Skills

| 维度 | Claude Code | OpenClaw / ClawHub |
|---|---|---|
| **定义格式** | YAML frontmatter + Markdown | SKILL.md（类似但字段不同） |
| **加载路径** | managed > user > project（3 级） | workspace/skills/ + ~/.openclaw/skills/（2 级） |
| **动态发现** | 文件操作触发，向上遍历查找 | 无（启动时扫描） |
| **条件激活** | paths: gitignore 模式匹配 | description 匹配（人工判断） |
| **执行模式** | inline / fork（共享 cache） | 直接注入（无 fork 选项） |
| **工具限制** | allowed-tools per skill | 无 per-skill 工具限制 |
| **变量替换** | ${CLAUDE_SKILL_DIR}、$ARGUMENTS 等 | 无内置变量 |
| **Shell 嵌入** | !`command` 语法 | 靠 scripts/ 目录 |
| **分发** | 无官方 marketplace（但有 plugin 系统） | ClawHub（npm 风格） |
| **MCP 集成** | 原生支持 MCP skills | 无 |
| **版本管理** | version 字段但无自动更新 | ClawHub install/update |

### OpenClaw 的优势
- ClawHub 生态（搜索、安装、发布）
- 更简单的心智模型
- 跨 agent 共享 skills

### Claude Code 的优势
- 动态发现（不需要预装，文件操作触发）
- 条件激活（按路径模式自动启用）
- fork 模式（省 token，隔离执行）
- 工具限制（per-skill 安全隔离）
- 变量替换和 shell 嵌入（动态内容）
- 三级加载优先级（企业管控）

---

## 可借鉴的设计

1. **条件激活（paths）**：skill 根据当前工作文件自动启用/隐藏。OpenClaw 可以加 `activateWhen:` 字段
2. **fork 模式**：skill 执行在 fork 中，不污染主对话上下文。省 token + 安全隔离
3. **allowed-tools**：per-skill 工具白名单。防止 skill 越权
4. **动态发现**：文件操作时向上遍历查找 skills。不需要预装——代码自带 skill
5. **变量替换**：`${SKILL_DIR}` 让 skill 引用自己目录的文件。OpenClaw 的 `references/` 做了类似的事但更手动
6. **Shell 嵌入**：`` !`command` `` 在 skill prompt 中嵌入动态内容（git status、env 等）
