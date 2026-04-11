# SkillClaw

> AMAP-ML/SkillClaw | 347⭐ | Python | 2026-04
> "Let Skills Evolve Collectively with Agentic Evolver"
> Paper: arXiv:2604.08377

## 核心设计

Multi-user agent 生态的 **skill 集体进化** 框架。三组件：
1. **Client Proxy** — 本地 API 代理，拦截 agent 请求，记录 session artifacts，同步 skill
2. **Workflow Evolve Server** — 3 阶段 LLM workflow: Summarize → Aggregate → Execute
3. **Agent Evolve Server** — 替代方案：用 OpenClaw agent 自主分析 sessions + 写 skill

共享存储（OSS/S3/local），skill 格式统一为 `SKILL.md`。

## 架构洞察

- **Collective evolution**：不是单 agent 自我进化，是群体经验共享。多用户 session 数据 → 提炼 skill → 全体 agent 受益
- **Transparent proxy**：agent 不需要改代码，proxy 自动拦截 API 调用
- **双 evolve 模式**：workflow（固定 3 步）vs agent（自主探索），可互换
- **WildClawBench 验证**：real-world 场景，不靠更大模型，靠更聪明的经验
- **兼容 6+ 框架**：CoPaw, IronClaw, PicoClaw 等

## 跟我们的关联

- Kagura 的 skill 进化是**单 agent**：beliefs-candidates → DNA/workflow 升级
- SkillClaw 是**多 agent**：群体经验 → 共享 skill 库
- 如果 OpenClaw 生态有多个 agent，SkillClaw 模式可以让 skill 跨 agent 进化

## 可借鉴

1. **Session → Skill 自动提炼**：类似 claude-memory-compiler 但产出是 SKILL.md 而非 knowledge article
2. **Transparent proxy 模式**：不改 agent 代码就能收集 session 数据
3. **Evolve benchmark**：WildClawBench 可作为评估参考

## 关联

- [[skill-evolution]] — 核心概念
- [[claude-memory-compiler]] — 同一波 Karpathy pattern，不同产出（knowledge vs skill）
- [[obra-superpowers]] — 另一种 agentic skills 框架
