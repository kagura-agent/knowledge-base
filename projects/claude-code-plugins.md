# Claude Code Plugin 系统研究笔记

> 源码版本：2026-04 读码分析
> 最后更新：2026-04-01

---

## 架构概览

Plugin 系统是 Claude Code 的扩展机制——通过 marketplace 分发，支持 skills、hooks、MCP servers、agents、output styles 等多种组件。

```
Plugin 架构：

  Marketplace（GitHub repo / URL / npm / local）
       │
       ↓
  known_marketplaces.json ←→ reconciler（自动同步）
       │
       ↓
  PluginInstallationManager（后台安装，不阻塞启动）
       │
       ↓
  LoadedPlugin → skills / hooks / MCP servers / agents / output-styles
```

---

## Plugin 定义

### LoadedPlugin 核心字段

| 字段 | 类型 | 说明 |
|---|---|---|
| name | string | 插件名 |
| manifest | PluginManifest | 插件清单 |
| path | string | 安装路径 |
| source | string | 来源标识 |
| repository | string | 所属 marketplace |
| enabled | boolean | 是否启用 |
| isBuiltin | boolean | 是否内置 |
| sha | string | Git commit SHA（版本锁定） |

### Plugin 组件（5 种）
1. **commands** — 自定义命令（`/plugin-name`）
2. **agents** — 自定义 agent 类型
3. **skills** — SKILL.md 格式的能力
4. **hooks** — 生命周期钩子
5. **output-styles** — 输出样式

---

## 两类 Plugin

### 1. Built-in Plugins（内置）
- 随 CLI 发布，ID 格式：`{name}@builtin`
- 用户可在 `/plugin` UI 中启用/禁用
- 状态持久化到 user settings
- 通过 `registerBuiltinPlugin()` 注册
- 有 `isAvailable()` 检查（按系统能力决定是否显示）
- 有 `defaultEnabled` 字段

### 2. Marketplace Plugins（市场）
- 从 marketplace 安装，ID 格式：`{name}@{marketplace}`
- 支持多种来源：GitHub repo、URL、npm、本地目录
- 版本通过 Git SHA 锁定

---

## Marketplace 系统

### 官方 Marketplace
- 仓库：`anthropics/claude-plugins-official`（GitHub）
- 常量：`OFFICIAL_MARKETPLACE_NAME = 'claude-plugins-official'`
- 有 GCS 加速下载路径（`officialMarketplaceGcs.ts`）

### 文件结构
```
~/.claude/
  └── plugins/
      ├── known_marketplaces.json    ← marketplace 配置
      └── marketplaces/              ← 缓存目录
          ├── my-marketplace.json    ← URL 来源
          └── github-marketplace/    ← GitHub 来源（git clone）
              └── .claude-plugin/
                  └── marketplace.json
```

### Reconciler（自动同步）
- `diffMarketplaces()` — 比较 settings 声明和 known_marketplaces.json 实际状态
- `reconcileMarketplaces()` — 自动安装缺失的、更新源变更的
- 支持相对路径解析（`./path` 在项目 settings 中）
- Git worktree 路径规范化（`findCanonicalGitRoot`）

### 安装流程
1. 启动时 `PluginInstallationManager` 后台运行
2. `diffMarketplaces()` 计算差异
3. 缺失的 → 自动安装（git clone / download）
4. 源变更的 → 更新
5. 新安装 → 自动 refresh plugins
6. 仅更新 → 设 `needsRefresh`，提示用户 `/reload-plugins`
7. UI 显示安装进度（pending → installing → installed/failed）

### Marketplace Source 类型
- `github` — Git 仓库（clone）
- `url` — JSON 文件（HTTP fetch）
- `npm` — npm 包
- `local` / `directory` — 本地路径
- 有 allowlist/blocklist 安全策略

---

## Hook 系统

Plugin 可以提供 hooks：
- 生命周期钩子（启动、工具调用前后、compact 后等）
- 通过 `HooksSettings` 配置
- 与 permission 系统集成

---

## 安全

- **Policy allowlist**：管理员可限制允许的 marketplace 来源
- **Blocklist**：阻止特定来源
- **SHA 锁定**：marketplace entry 可指定 commit SHA
- **isAvailable()** gate：built-in plugin 可按系统能力隐藏

---

## 对比分析：Claude Code Plugins vs OpenClaw Plugins

| 维度 | Claude Code | OpenClaw |
|---|---|---|
| **分发** | Marketplace（GitHub/URL/npm/local） | npm plugin + ClawHub skills |
| **安装** | `/plugin marketplace add` + `/plugin install` | `openclaw plugins install` / `clawhub install` |
| **组件类型** | 5 种（commands/agents/skills/hooks/output-styles） | plugin hooks + skills 分离 |
| **内置 vs 市场** | `@builtin` vs `@marketplace` 明确区分 | 无明确区分 |
| **自动同步** | reconciler 自动安装/更新 | 无自动更新 |
| **版本** | Git SHA 锁定 | npm semver |
| **官方 Marketplace** | anthropics/claude-plugins-official | ClawHub (clawhub.ai) |
| **安全** | allowlist/blocklist + policy | 无 |

### OpenClaw 的优势
- Plugin 和 Skill 分离（关注点清晰）
- ClawHub 有完整的 search/install/update/publish 流程
- npm semver 语义化版本（vs Git SHA 不透明）

### Claude Code 的优势
- **统一的 Plugin 容器**：一个 plugin 可以同时提供 skills + hooks + MCP + agents
- **Reconciler 自动同步**：不需要手动更新
- **多来源支持**：GitHub/URL/npm/local 任选
- **Built-in 可禁用**：用户可以关掉不想要的内置功能
- **后台安装不阻塞**：启动时后台装，不影响交互

---

## 可借鉴的设计

1. **Plugin = 组件容器**：一个 plugin 可以同时提供 skill + hook + MCP。OpenClaw 目前 skill 和 plugin 分离，可以考虑统一
2. **Reconciler 自动同步**：settings 声明了 marketplace → 自动确保本地有。减少手动 install 步骤
3. **Built-in 可禁用**：内置功能不强制——用户可以关掉不需要的。OpenClaw 可以让 built-in skills/plugins 有 enable/disable
4. **后台安装**：plugin 安装不阻塞启动。重启后台装，装完自动生效
5. **SHA 锁定**：marketplace entry 指定 commit hash = 可复现安装。比"latest"更安全
