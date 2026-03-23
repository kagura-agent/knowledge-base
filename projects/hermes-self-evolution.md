# hermes-agent-self-evolution

> Evolutionary self-improvement for Hermes Agent — optimize skills, prompts, and code using DSPy + GEPA
> https://github.com/NousResearch/hermes-agent-self-evolution
> 253⭐, 创建 2026-03-09, 更新 2026-03-23

## 核心

Hermes 团队做的**独立优化管线**——不是 hermes-agent 的一部分，是作用于 hermes-agent 的外部工具。

三个引擎：
1. **DSPy + GEPA**（遗传-帕累托 prompt 进化，ICLR 2026 Oral）— 读执行 trace，理解**为什么**失败，针对性改进
2. **DSPy MIPROv2** — 贝叶斯优化，备用
3. **Darwinian Evolver** — 代码进化（Git-based organisms），AGPL

**不需要 GPU**。全靠 API 调用——mutate text → evaluate → select best。约 $2-10 每次优化。

## 进化阶段

| Phase | Target | Status |
|-------|--------|--------|
| 1 | SKILL.md 文件 | ✅ 已实现 |
| 2 | Tool descriptions | 🔲 计划 |
| 3 | System prompt sections | 🔲 计划 |
| 4 | Tool 实现代码 | 🔲 计划 |
| 5 | 持续改进循环 | 🔲 计划 |

## 跟我们的对比

| 维度 | Hermes Self-Evolution | Kagura TextGrad Pipeline |
|------|----------------------|------------------------|
| 触发 | 手动运行 `evolve_skill` | Luna 反馈 → beliefs-candidates → DNA |
| 数据源 | execution traces + eval datasets | Luna 的反馈（text gradients） |
| 优化器 | GEPA（遗传进化 + 帕累托） | 人工积累 gradient，重复 3 次升级 |
| 评估 | batch_runner 自动评估 | daily-review 审计员 |
| 部署 | PR + human review | Luna 确认后执行 |
| 自动化程度 | 高（$2-10/run） | 低（手动对话驱动） |
| 进化对象 | Skills/prompts/tools/code | DNA 文件（SOUL/AGENTS/NUDGE）|

**关键差异**：他们有**自动化评估**（eval datasets + execution traces），我们没有。这是我们最大的 gap。

## 他们的约束门（跟我们的审计员类似）

- 测试必须 100% pass
- 大小限制（Skills ≤15KB）
- 缓存兼容（不能中途改对话中的 prompt）
- 语义保持（不能偏离原始目的）
- **PR review — 所有改动走 human review**

跟我们的 daily-review propose 模式几乎一样——进化提案需要人确认。这又是趋同进化 [[convergent-evolution]]。

## 架构洞察

1. **进化管线和 agent 分离**：hermes-agent-self-evolution 是独立 repo，操作于 hermes-agent 之上。跟我们的 evolution-log 类似思路，但他更彻底——整个优化管线是独立的
2. **Execution traces 是核心**：GEPA 的优势在于读 trace 理解"为什么失败"。我们缺少系统化的 execution trace 收集
3. **Tier 分层（Risk vs Value）**：先做低风险高价值的（Skills），后做高风险的（Code）。这跟我们从 beliefs-candidates → DNA 的渐进升级逻辑相同

## 对我们的启示

1. **我们需要 eval**：目前只靠 Luna 反馈和审计员。如果能建一个简单的评估机制（比如"过去 5 次打工的 merge rate"），TextGrad 就能变成半自动的
2. **Execution trace 收集**：OpenClaw 的 session log 就是 trace，但我们没有系统化利用
3. **GEPA 可以直接用**：DSPy + GEPA 是 Python 包，可以在 study workflow 的 apply 节点尝试

See also [[hermes-agent]], [[self-evolution-architecture]], [[eval-driven-self-improvement]], [[convergent-evolution]], [[mechanism-vs-evolution]]
