# CyberClaw

> 下一代透明智能体架构，专注安全审计和可控性。受 OpenClaw 启发。

- **repo**: ttguy0707/CyberClaw
- **创建**: 2026-04-07
- **语言**: Python (LangChain/LangGraph)
- **Stars**: 70 (4天)

## 核心机制

1. **两段式安全调用** (help → run): 先看 SKILL.md 说明，再决定执行。可反悔。类似 dry-run 模式。
2. **5类事件审计**: llm_input, tool_call, tool_result, ai_message, system_action → JSONL 日志 + Rich 终端
3. **双水位记忆**: 长期画像 (user_profile.md) + 短期摘要 (SQLite, 每 N 轮自动摘要)
4. **心跳任务**: 后台独立进程，daily/weekly/monthly，持久化
5. **跨平台**: Unix + Windows，路径拦截（禁 ../绝对路径）

## 安全设计值得借鉴

- **两段式调用**：OpenClaw 的 approval 机制类似但更粗粒度（approve/deny）。CyberClaw 的 help→run 让 agent 先理解工具再用，减少误用
- **路径拦截**：所有操作限制在 office/ 目录内。简单粗暴但有效
- **Shell 命令安全**：危险命令正则匹配 + 60s 超时熔断 + 强制非交互

## 生态位置

- 明确声称兼容 OpenClaw + Claude Code 技能生态
- 基于 LangChain/LangGraph，定位企业级
- 跟 OpenClaw 是互补关系：OpenClaw 是平台，CyberClaw 是上面的一种 agent 架构

## 深入对比：CyberClaw 安全 vs OpenClaw Approval（2026-04-11）

### 设计哲学差异

| 维度 | CyberClaw | OpenClaw |
|------|-----------|----------|
| **核心理念** | 零信任 + 透明（agent 的每一步都可审计） | 权限分级 + 人类审批（关键操作需人类授权） |
| **信任模型** | 默认不信任，沙盒内执行 | 可配置信任级别（deny/allowlist/full） |
| **粒度** | 工具级别（help→run 两段式） | 命令级别（pattern + argPattern 匹配） |
| **审计** | 5 类事件实时 JSONL | 审批记录 + 执行日志 |
| **UX** | agent 先读说明书再决定是否执行 | 人类看到命令后 approve/deny |

### CyberClaw 两段式调用（help→run）

1. Agent 想用工具 → 先 `mode='help'` 读 SKILL.md
2. 读完理解后 → 决定用 `mode='run'` 执行，或换工具
3. **反悔机制**：看了说明书可以不执行

优点：减少 agent 误用工具（先理解再用），P0 事故减少是合理的
缺点：全靠 agent 自律，没有人类在环；恶意 prompt 可以绕过

### OpenClaw Approval 机制

1. Agent 发起 exec → gateway 检查 security 策略
2. `deny`: 直接拒绝
3. `allowlist`: 匹配 pattern（命令）+ argPattern（参数），命中放行，否则需审批
4. `full`: 全部放行
5. 需审批时 → 通过 channel plugin 投递审批请求（Discord/飞书/CLI）
6. 人类 `/approve` 或 `/deny`
7. 支持 per-agent 策略 + 全局 defaults

优点：人类在环，策略可配、可审计、可追溯
缺点：审批延迟影响自主性；allowlist 维护成本高

### 关键差异：谁做决策？

- **CyberClaw**: Agent 自己决策，系统提供信息辅助
- **OpenClaw**: 人类决策（或预设规则），Agent 等待授权

这反映了两种安全范式：
- CyberClaw = **透明度优先**（让你看到 agent 在做什么，但不阻止）
- OpenClaw = **控制优先**（关键操作必须经过人类授权）

### 各自适合的场景

- **CyberClaw 适合**：个人实验、受控环境、信任 agent 能力但想看过程
- **OpenClaw 适合**：生产环境、多 agent 管理、需要强制人类审批的场景

### 可借鉴的设计

1. **两段式调用 UX 可补充 OpenClaw**：在 allowlist 模式下，agent 先 dry-run 看效果，再真正执行，减少审批往返
2. **5 类事件审计分类**：OpenClaw 可以细化审计事件分类（当前审批记录偏粗）
3. **P0 事故率量化**：用具体指标衡量安全改进，而不是「感觉更安全」
4. **路径沙盒**（office/ 限制）：简单粗暴但有效，OpenClaw 的 mediaLocalRoots 是类似思路

### 局限性

- CyberClaw 的「P0 事故率降 80%」没有公开测试方法，难以验证 [未验证]
- 两段式调用不能防御恶意 prompt injection（agent 被骗后依然会 run）
- OpenClaw 的 allowlist 在 agent 自主运行时（heartbeat/cron）会形成瓶颈

### 结论

两者互补不矛盾。最佳实践是：
- **控制层**用 OpenClaw（人类审批 + allowlist）
- **透明层**借鉴 CyberClaw（细粒度审计 + agent 自检）
- 长期方向：agent 能力提升后，从「控制优先」渐进到「透明优先」
