# MemPalace

- **repo**: milla-jovovich/mempalace
- **stars**: 40k+ (created 2026-04-05, 一周爆火)
- **语言**: Python
- **license**: MIT
- **关键词**: AI memory, ChromaDB, MCP, local-first

## 核心思路

"Store everything, then make it findable" — 跟大多数 memory 系统（让 AI 决定什么值得记）反过来。

**Palace 架构**：受记忆宫殿启发，把对话组织为 wings（人/项目）→ halls（记忆类型）→ rooms（具体想法）。本质是 ChromaDB metadata filtering，但隐喻好用。

**Raw verbatim storage**：不做摘要/提取，原文存 ChromaDB，语义搜索找回。LongMemEval 96.6% R@5（500 题，零 API 调用）。

**AAAK 压缩**（实验）：有损缩写方言，用实体代码+截断压缩 token。当前回退到 84.2% vs raw 的 96.6%。

## 诚实度加分

创始人在 README 里主动纠正了社区发现的问题：
- AAAK token 例子用了错误的 heuristic 估算
- "30x 无损压缩"夸大了（实际有损）
- "+34% palace boost"只是标准 ChromaDB metadata filtering
- "矛盾检测"代码存在但没接入主流程

这种透明度在爆火项目中罕见，值得尊重。

## 跟我们的关联

| 维度 | MemPalace | 我们（wiki + memory/） |
|---|---|---|
| 存储 | 原文 → ChromaDB | markdown 文件 + memex |
| 检索 | semantic search + metadata filter | memex search + grep |
| 结构 | palace 隐喻（wings/halls/rooms） | 手动分类（projects/cards/beliefs） |
| 记忆选择 | 不选，全存 | 人工策展（MEMORY.md） |

**启发**：
1. "全存 + 好搜索" vs "策展 + 少量" — 两种哲学，mempalace 在 benchmark 上赢了
2. 我们的 memory/ 日志已经接近 "raw verbatim"，但没有 semantic index
3. Palace 的 wing/room 隐喻可借鉴到我们的 wiki 分类
4. MCP 集成方式值得参考 — 19 个工具让 AI 直接调用

## 值得关注

- AAAK 压缩迭代（能否缩小跟 raw 的差距）
- 社区活跃度（已有 fake website 警告）
- 是否会加 incremental mining（当前似乎是批量）

---
*2026-04-11 快速扫描发现，深读 README + 架构*
