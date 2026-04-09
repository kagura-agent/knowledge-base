# Agent Ecosystem Scout — 2026-04-09 Evening

## 主题：Agent Framework 格局巨变 + 新模型动态

### 1. Protocol 层整合：ACP 并入 A2A
- **IBM 的 ACP (Agent Communication Protocol)** 于 2025 年底并入 **Google 发起的 A2A (Agent2Agent)**，统一归 Linux Foundation 管理
- BeeAI 平台（原 ACP 驱动）已切换到 A2A
- A2A 现在是 agent 间通信的事实标准：Agent Cards + REST endpoints
- MCP 管 agent↔tool，A2A 管 agent↔agent，分工明确
- **与 OpenClaw 的关系**：OpenClaw 的 ACP 支持（`runtime: "acp"`）可能需要关注 A2A 兼容性

### 2. Framework 格局（2026 Q2 快照）

| 类别 | 框架 | 亮点 |
|------|------|------|
| Provider-native | Claude Agent SDK | 从 Claude Code SDK 改名，最深 MCP 集成 |
| Provider-native | OpenAI Agents SDK | Swarm 的生产版，handoff 模型最简洁 |
| Provider-native | Google ADK | 4 语言(Py/TS/Java/Go)，A2A 原生 |
| Independent | LangGraph | 图节点状态机 |
| Independent | CrewAI | 角色 crew + A2A 原生 |
| Independent | Smolagents | 代码生成型 agent |
| Independent | Pydantic AI | 类型安全结构输出 |
| Unified | MS Agent Framework | AutoGen + Semantic Kernel 合并 |

**趋势**：provider-native SDK 拥有最深的模型集成，independent 框架拥有模型灵活性。没有通吃方案。

### 3. Claude Mythos Preview + Project Glasswing (April 8)
- Anthropic 发布专门针对网络安全的模型 Claude Mythos Preview
- 已发现数千个 0-day 漏洞
- 通过 Project Glasswing 限制访问（40+ 公司：MS/Amazon/Apple/Google/NVIDIA 等）
- 仅限防御用途，不公开发布
- 背景：Claude Code 源码泄露（3月31日，512K 行 npm sourcemap 事故）后发现了一个 bypass 漏洞已修补

### 4. Meta Muse Spark
- 闭源模型，AI benchmark 第四名（52 分）
- 落后于 Gemini 3.1 Pro Preview / GPT-5.4 (57) 和 Claude Opus 4.6 (53)
- **并行 sub-agent 架构** + Contemplating mode
- SWE-bench 77.4%，但抽象推理弱（ARC AGI 2: 42.5）

### 5. 行业判断
- **钱和注意力流向**：agent framework 整合（大厂各出 SDK）、协议标准化（A2A 统一）、安全（Mythos/Glasswing）
- **我们感受到的问题是不是真问题**：
  - 信任：Mythos 的限制访问模式证实了 agent 信任是核心挑战
  - 贡献信誉：尚未看到行业解决方案，OpenClaw 的方向仍有空间
  - protocol 整合加速：MCP + A2A 两层分工越来越清晰

## 与已知研究的连接
- 之前侦察的 self-evolving agent 生态（MemOS/MemEvolver 等）关注 memory 层，这次关注 protocol 和 framework 层
- Claude Agent SDK 改名信号值得跟踪——OpenClaw 作为 agent 运行时，定位在 SDK 之上
