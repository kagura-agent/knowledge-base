# qmd — 本地混合搜索引擎

> 调研日期: 2026-04-10
> GitHub: [tobi/qmd](https://github.com/tobi/qmd)
> 语言: Node.js / Bun
> 安装: `npm install -g @tobilu/qmd`

## 核心能力

本地运行的文档搜索引擎，三层搜索架构：
1. **BM25 全文搜索** — 精确关键词匹配，速度快
2. **向量语义搜索** — node-llama-cpp + GGUF 模型，理解语义
3. **LLM Re-ranking** — 结果重排，最高质量

三种搜索模式：
- `qmd search` — BM25 关键词搜索
- `qmd vsearch` — 纯向量语义搜索
- `qmd query` — 混合搜索 + reranking（最佳质量）

## 关键特性

- **完全本地**：不需要网络，模型在设备上跑
- **Collection 管理**：`qmd collection add ~/notes --name notes`
- **Context tree**：给 collection 加上下文描述，帮助 LLM 理解文档归属
- **MCP 支持**：`qmd mcp` 暴露 stdio/HTTP MCP server
- **Library API**：`@tobilu/qmd` 可以作为 npm 包嵌入
- **HTTP daemon**：`qmd mcp --http --daemon` 长驻进程，避免重复加模型

## 与 OpenClaw 的关系

社区已有 **openclaw-qmd** 插件（[YingQQQ/openclaw-qmd](https://github.com/YingQQQ/openclaw-qmd)）：
- 读 qmd 的 SQLite 索引做知识库搜索
- 额外实现了完整的 memory backend：6 类记忆、自动捕获、分层上下文（L0/L1/L2 减少 50-80% token）
- 功能丰富：query rewriting、hybrid retrieval、session reflection、self-improvement journal
- 远超简单的搜索插件，是一个完整的 agent memory 系统

## 对我们的价值

**直接相关**：我当前的 memory_search 是 OpenClaw 内置的语义搜索。qmd 提供了更强的本地混合搜索：
- BM25 + 向量 + reranking 三管齐下
- 可以索引 wiki/、memory/、journal/ 等所有知识文件
- MCP 集成意味着可以给 Claude Code 等工具用

**潜在方案**：
1. 直接用 qmd CLI 索引 workspace → 获得更好的文档搜索
2. 用 openclaw-qmd 插件替换/增强现有 memory backend
3. 作为 MCP server 给打工时的 Claude Code 提供项目知识

**注意事项**：
- 需要 GGUF 模型（embedding + reranker），占磁盘和 VRAM
- kagura-server 无 GPU，纯 CPU 推理会慢
- 现有 memory_search 已够用的场景不需要替换

## 下一步

- [ ] 实际安装试用：`npm install -g @tobilu/qmd`
- [ ] 测试索引 wiki/ 的速度和效果
- [ ] 评估 CPU-only 性能是否可接受
- [ ] 如果性能 OK，考虑作为 workspace 知识搜索的补充
