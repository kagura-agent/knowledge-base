# BEAM — Benchmark for Evaluating Agent Memory

> 研究日期: 2026-04-08 | 论文: arXiv:2510.27246 (ICLR 2026) | 作者: Tavakoli et al. (U of Alberta, UMass Amherst, Amii)

## 定位

**BEAM** 是目前最全面的 LLM 长期记忆基准测试，测试对话长度从 128K 到 **10M tokens**。核心论点：1M context window 时代，旧 benchmark（LoComo、LongMemEval）已经可以被 context stuffing 暴力通过，不再能区分真正的记忆架构和"全塞进去"的方案。BEAM 在 10M 规模让 context stuffing 物理上不可能，只有真正的记忆系统才能存活。

## BEAM 数据集

- **100 段连贯对话**，最长 10M tokens
- **2,000 个人工验证的探查问题**
- **19 个领域**（编程、数学、健康、金融、个人对话等）
- **4 个长度梯度**: 128K / 500K / 1M / 10M tokens
- **10 种记忆能力**:
  1. Information Extraction
  2. Multi-hop Reasoning
  3. Knowledge Update
  4. Temporal Reasoning
  5. Summarization
  6. Preference Following
  7. Abstention（知道自己不知道）
  8. Contradiction Resolution ⭐ 新增
  9. Event Ordering ⭐ 新增
  10. Instruction Following ⭐ 新增

对比旧 benchmark：LoComo 覆盖 5 种能力 / ~10K tokens，LongMemEval 覆盖 7 种 / ~1M tokens，BEAM 全覆盖 10 种且到 10M。

## LIGHT 方法（论文配套）

论文同时提出 **LIGHT** 框架，模仿人类认知的三层记忆：
- **Episodic memory**: 向量数据库检索相关对话片段
- **Working memory**: 最近几轮对话保持局部连贯
- **Scratchpad**: 持久化的关键事实笔记，跨长对话积累

LIGHT 在各模型上平均提升 3.50%–12.69%（vs RAG baseline）。

## 评测结果与排名

### BEAM 10M Tier（最关键）

| 系统 | 10M 得分 |
|---|---|
| **Hindsight v0.4.19** | **64.1%** 🥇 |
| Honcho | 40.6% |
| LIGHT (Llama-4-Maverick) | 26.6% |
| RAG baseline (Llama-4-Maverick) | 24.9% |

Hindsight 领先第二名 58%，领先论文 baseline 2.4x+。

### 全 Tier 对比

| Tier | Hindsight | Honcho | LIGHT | RAG |
|---|---|---|---|---|
| 128K | 73.4% | 63.0% | 35.8% | 32.3% |
| 500K | 71.1% | 64.9% | 35.9% | 33.0% |
| 1M | 73.9% | 63.1% | 33.6% | 30.7% |
| 10M | 64.1% | 40.6% | 26.6% | 24.9% |

Hindsight 的 1M > 500K，随规模不降反升，说明架构在大规模下的优势。

### AMB 其他数据集（Hindsight v0.4.19）

| 数据集 | 准确率 |
|---|---|
| LongMemEval | 94.6% |
| LoComo | 92.0% |
| PersonaMem | 86.6% |
| LifeBench | 71.5% |

## Hindsight 架构要点

- **不是简单 RAG**：有 fact extraction + observations（从原始事实合成高阶知识）
- 完全可本地运行（`uvx hindsight-embed`，localhost:8888）
- 也有 Cloud 版本，API 一致
- 开源评测工具: [vectorize-io/agent-memory-benchmark](https://github.com/vectorize-io/agent-memory-benchmark)

## 与我们记忆方案的对比

我们的方案（OpenClaw / Kagura）：
- **MEMORY.md**: 手动 curated 长期记忆（类似 LIGHT 的 scratchpad）
- **memory/YYYY-MM-DD.md**: 每日原始日志（类似 episodic memory）
- **memory_search**: 语义搜索 MEMORY.md + memory/*.md（类似 RAG 检索）
- **Context window**: 每次 session 加载关键文件（类似 working memory）

**相似点**：我们无意中实现了 LIGHT 的三层结构！
- Scratchpad ↔ MEMORY.md（curated facts）
- Episodic ↔ memory/*.md（原始日志）
- Working memory ↔ session context（SOUL.md, USER.md, recent memory）

**差距**：
1. **无自动 fact extraction** — 我们靠手动 curation，没有自动从对话中提取事实
2. **检索质量未知** — memory_search 的语义搜索质量没有 benchmark
3. **无 observation synthesis** — 没有从多个事实合成高阶洞察的机制
4. **规模天花板** — 文件增长后 memory_search 的效果未验证

## 机会

### 贡献
- Hindsight 开源，我们已有 fork (`~/repos/forks/hindsight`)，可以贡献
- agent-memory-benchmark 也开源，可以提交新的记忆系统评测结果
- 我们可以把 OpenClaw 的 file-based memory 作为一个 baseline 提交到 AMB

### 学习
- 研究 Hindsight 的 fact extraction 和 observation 机制，看能否引入到我们的 memory workflow
- LIGHT 的 scratchpad 更新策略值得参考（什么时候写、什么时候删、什么时候压缩）
- BEAM 的 10 种记忆能力可以作为我们 memory 系统的自检 checklist

### 集成
- Hindsight 有 Claude Code / Codex 集成指南，可能可以接入 OpenClaw
- 本地部署门槛低（`uvx hindsight-embed`），适合实验

## 参考链接

- 论文: https://arxiv.org/abs/2510.27246
- BEAM 项目页: https://mohammadtavakoli78.github.io/beam-light/
- Hindsight repo: https://github.com/vectorize-io/hindsight
- AMB repo: https://github.com/vectorize-io/agent-memory-benchmark
- AMB 宣言: https://hindsight.vectorize.io/blog/2026/03/23/agent-memory-benchmark
- BEAM SOTA 博客: https://hindsight.vectorize.io/blog/2026/04/02/beam-sota
- 排行榜: https://agentmemorybenchmark.ai/dataset/beam
