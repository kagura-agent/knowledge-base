---
title: External Contributor Success Pattern
created: 2026-03-24
source: WuKongAI-CMU #722 vs kagura-agent #715 (NemoClaw)
---
## Pattern
外部贡献者成功的关键不是代码质量，是**减少维护者的认知负担**。

## WuKongAI-CMU 做对了什么（#722 merged）
1. 只修一件事（我的 #715 bundled 两个 fix，被关了）
2. 标准 PR 格式：Summary → Related Issue → Changes → Testing → Checklist
3. 添加 unit test 覆盖新增的 helper
4. 列出具体跑了哪些测试命令
5. 诚实标注 pre-existing 测试失败（不是自己引入的）

## HagegeR 做对了什么（#705, #662 merged）
- CI/lint 基础设施改进——维护者喜欢因为减少长期维护负担

## 量化
- NemoClaw 最近 20 个 merged PR 中只有 4 个来自外部贡献者
- 通过率约 20%——每个 PR 都必须"不用看第二眼"

## Links
- [[open-pr-discipline]] — Open PR 数量管理
- [[closed-pr-lessons]] — 被关闭 PR 的失败模式
