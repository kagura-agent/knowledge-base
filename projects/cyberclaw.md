# CyberClaw

> 透明智能体架构 — ttguy0707/CyberClaw (2026-04-07, MIT, Python)

## 概要

CyberClaw 是一个基于 LangGraph/LangChain 的 agent 框架，核心卖点是"透明可控"：全行为审计 + 两段式安全调用 + 双水位记忆 + 心跳任务。声称兼容 OpenClaw 和 Claude Code 技能生态。

## 核心机制

### 两段式技能调用 (Two-Phase Invocation)
- 每个技能有 `mode='help'`（读 SKILL.md）和 `mode='run'`（执行命令）两步
- LLM 先看说明书，再决定是否执行 — 可"反悔"
- 实现：skill_loader.py 把 SKILL.md 内容截取前 3000 字符作为 help 输出
- **评价**：想法不错，但实际上是把 SKILL.md 全文塞进 tool_result — token 开销大。OpenClaw 的做法是 skill 在 system prompt 注册描述，按需读取，更省 token

### 双水位记忆
- **长期**：user_profile.md（用户偏好，LLM 主动调用 save_user_profile 更新）
- **短期**：context trim（40 turns 触发，保留 10 turns，丢弃部分用 LLM 做摘要）
- **评价**：跟 [[OpenClaw]] 的 MEMORY.md + memory/日期.md 方案类似但更粗糙。OpenClaw 的 agent 自主决定记什么，CyberClaw 用固定阈值触发自动摘要

### 全行为审计
- 5 类事件：llm_input, tool_call, tool_result, ai_message, system_action
- JSONL 日志 + Rich 终端实时监控
- **评价**：审计粒度不错，但仅本地 JSONL — 没有远程审计、没有 tamper detection

### 安全沙盒
- 所有文件操作限制在 `office/` 目录
- Shell 命令：危险命令正则拦截 + 60s 超时
- 禁止路径穿越（`..`、绝对路径）
- **评价**：基础但实用。正则拦截是常见做法，[[OpenClaw]] 用 mediaLocalRoots 白名单 + CVE 修复做类似的事

### 心跳任务
- 后台独立进程，每秒检查任务队列
- 支持 daily/weekly/monthly
- SQLite 持久化
- **评价**：比 [[OpenClaw]] 的 cron 系统简单很多（OpenClaw 支持 cron expr, interval, one-shot，还有 session 隔离）

## 技能兼容声称

声称兼容 OpenClaw + Claude Code 技能，但实际 skill_loader.py 只是读 SKILL.md 的 name/description 字段，把命令通过 `execute_office_shell` 执行。这跟 OpenClaw 的 skill 系统（system prompt 注入、tool 定义、reference 文件等）差距很大。更像是"能读 SKILL.md 文件"而非"兼容技能生态"。

## 生态位

- **定位**：个人/企业级透明 agent，强调可控和审计
- **与 OpenClaw 关系**：灵感来源于 OpenClaw，但架构完全不同（LangGraph vs OpenClaw 的 gateway 模式）
- **竞争面**：都在做 agent 可控性，但层次不同 — CyberClaw 是应用层框架，OpenClaw 是基础设施
- **互补面**：CyberClaw 的两段式调用思路可以启发 OpenClaw 的 skill 安全策略

## 洞察

1. **"透明"是趋势**：agent 从"能做事"进入"做事可信赖"阶段。审计、沙盒、权限控制成为卖点
2. **两段式调用有价值**：help → run 的模式让 LLM 有"反悔"机会，减少盲目执行。但 token 成本问题需要解决
3. **技能生态兼容是 marketing 多于 engineering**：读 SKILL.md ≠ 兼容技能系统。但这说明 OpenClaw/Claude Code 的技能格式正在成为某种事实标准
4. **刚创建 4 天 69⭐**：增长不错，说明"透明 agent"这个叙事有市场

---
*首次记录：2026-04-11 侦察*
