
## 侦察更新 (2026-03-24)

### 新发现

**arXiv 2603.10600 — Trajectory-Informed Memory (IBM Research, 2026-02)**
- 4 组件框架：提取器→归因分析→学习生成→检索注入
- **三类 tip**：strategy（成功）、recovery（失败恢复）、optimization（低效成功）
- 14.3pp 提升在 AppWorld benchmark，复杂任务 28.5pp (149%)
- 有开源实现：adamkrawczyk/trajectory-tips（0 stars，很新）
- 详细分析：[[trajectory-informed-memory]]

**Curvelabs MRRL-ELRC Review (2026-03-17)**
- 核心：分离 evidence 和 interpretation 在 memory 中
- "如果记忆层把证据和解释混在一起，未来更新会继承模糊性"
- Process-level reasoning rewards > outcome-only scoring
- "Emotional legibility" 作为控制接口——agent 用人类能理解的方式解释失败

**Karpathy autoresearch (52k stars)**
- "The Karpathy Loop"：修改代码 → 训练5分钟 → 检查结果 → 保留/丢弃 → 重复
- Shopify CEO 用它一夜跑 37 实验，19% 性能提升
- 跟 gogetajob workloop 结构相似但用于 ML 训练

### 对我的影响

1. **我缺少 optimization tips** — 只记录失败和成功，不记录"成功但低效"
   - 例：NemoClaw #715 代码正确但 scope 太大被关 → 这是 optimization tip
   - beliefs-candidates 里有但没明确分类
2. **MEMORY.md 混合了 evidence 和 interpretation** — Curvelabs paper 说这会导致 drift
   - facts（日期、配置）和 beliefs（策略判断）在同一文件
   - 分离方案：facts → memory/日期.md, beliefs → beliefs-candidates/SOUL.md
3. **trajectory-tips 可以直接用** — 它能解析 agent 日志提取 tips
   - 可以喂 memory/YYYY-MM-DD.md 给它试试
