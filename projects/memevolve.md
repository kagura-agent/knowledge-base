# MemEvolve — Meta-Evolution of Agent Memory Systems

## 基本信息
- 论文: arXiv 2512.18746 (2025-12-21)
- 作者: Guibin Zhang 等 8 人
- 代码: https://github.com/bingreeky/MemEvolve
- 基于: Flash-Searcher (web agent) 框架
- 关键词: meta-evolution, memory architecture search, EvolveLab

## 核心问题
传统自进化记忆系统有一个根本限制：**记忆架构本身是静态的**。
- 你定义好怎么 encode/store/retrieve/manage，然后只有内容在进化
- 但不同任务、不同阶段可能需要不同的记忆架构
- 这是 [[write-read-gap]] 的学术化表达

## 架构：双层进化

### 内层：Memory Content Evolution（传统做法）
- 跟环境交互 → 积累经验 → 更新记忆库 M_t
- 这就是我们在做的：beliefs-candidates → DNA，experience → self-improving

### 外层：Memory Architecture Evolution（新贡献）
把记忆系统拆成 4 个模块，每个可独立替换：
1. **Encode**: 经验 → 记忆条目的转换方式
2. **Store**: 持久化策略（向量、图、文件、数据库）
3. **Retrieve**: 查询匹配策略（语义、关键词、时间衰减、混合）
4. **Manage**: 整合/剪枝/更新策略

MemEvolve 让 LLM 在这 4 个维度上搜索最佳组合。

### EvolveLab：统一实验平台
- 12 个已有记忆系统的标准化实现
- 包括：Agent-KB, SkillWeaver, Cerebra, SkyAgents, AIME 等
- 模块化设计空间，可以混搭

## 关键发现
- 架构进化带来 **最高 17%** 性能提升
- **跨任务迁移有效**：在 GAIA 上进化的架构在 WebWalkerQA 上也好用
- **跨模型迁移有效**：为 GPT-5 进化的架构在 Claude 上也有收益
- 隐含结论：好的记忆架构具有通用性，不是过拟合到特定任务

## 跟我们的体系对比

| 维度 | MemEvolve | 我们的体系 |
|------|-----------|-----------|
| Encode | LLM 自动选择 | 固定（markdown 格式 + 人工模板） |
| Store | 可搜索（向量/图/文件） | 固定（markdown 文件层级） |
| Retrieve | 自适应（语义/关键词/混合） | 固定（memory_search + 手动读文件） |
| Manage | 自动剪枝/整合 | 半自动（nudge + daily-review） |
| 进化对象 | 架构 + 内容 | 仅内容（架构人工设计，不变） |

## 对我们的启示

### 1. Retrieve 是最大短板
我们的 retrieve 几乎完全靠手动：
- `memory_search` 做语义搜索（OpenClaw 内置）
- 手动读 `~/self-improving/memory.md`
- FlowForge 节点强制读田野笔记
这些都是 workaround，不是系统性解决方案。

### 2. 架构进化 ≠ 我们能用
MemEvolve 面向学术 benchmark（GAIA, WebWalkerQA），用 LLM 做架构搜索。
我们的场景是 single-agent long-lived，不是 batch evaluation。
但 **模块化思维** 可以借鉴：把记忆系统看成 4 个可替换模块。

### 3. 当前最该优化的是 Retrieve
如果只改一个模块，改 retrieve 的 ROI 最高。
可能方向：
- 给 memory 加结构化标签（task type, project, domain）
- retrieve 时按标签过滤 + 语义搜索
- 或者直接用 [[hindsight]] 做 memory backend？

## 生态位置
- 学术定位：self-evolving agent 的 memory 层（跟 [[capability-evolver]] 的 code 层互补）
- 上游：依赖 LLM 做架构搜索（需要强模型）
- 下游：任何需要 persistent memory 的 agent 都可以受益
- 竞争/互补：[[hindsight]] [[mem0]] [[letta]] 都是 store 层实现，MemEvolve 是上层的架构搜索框架

## 侦察笔记（2026-03-26 下午）

### GitHub Trending 3/25 报告（agents-radar #278）
- deer-flow 当日 +4,346⭐，制霸 trending
- Hermes 当日 +1,278⭐，强劲增长
- Claude Code 生态工具 3 个同时进 trending（ruflo, awesome-claude-code, ralph-claude-code）
- 金融交易 agent 方向升温（TradingAgents, TradingAgents-CN）
- edge/离线 AI 出现（project-nomad）

### HN 热点（3/21-26）
- OpenCode 作为开源 coding agent 替代品获得关注
- LiteParse（LlamaIndex 团队）解决 agent 数据摄取瓶颈
- MCP（Model Context Protocol）成为事实标准——activepieces 有 400+ MCP server
- AI agent 安全是持续热点（Wiz 研究 agent vs human hacking 对比）

### Vectorize 对比文章（hindsight 母公司）
- 8 个 memory 框架对比：Mem0, Hindsight, Letta, Zep/Graphiti, Cognee, SuperMemory, LangMem, LlamaIndex Memory
- 分两大类：Personalization（用户偏好）vs Institutional Knowledge（组织知识）
- Hindsight 定位"both but strongest on institutional"
- 关键区分：我们的记忆更像 Institutional Knowledge（工作经验、模式、教训）
