# autoresearch (Karpathy)

> AI agents running autonomous ML research — the original eval-driven self-improvement loop

## What This Project Represents

Karpathy 在 2026 年 3 月发布的实验：让 AI agent 自动做 LLM 训练研究。46k stars. 不是工具，是一个**范式声明**——AI 可以自主做研究，人类只需要写 program.md（自然语言"研究方向"），然后去睡觉。

核心哲学："你不是在写 Python，你是在编程 program.md。" 本质上是用自然语言编程一个研究组织。

## Architecture

三个文件，1225 行代码。极简到令人不安：
- `prepare.py` (389行) — 数据准备 + 评估（只读，不可修改）
- `train.py` (630行) — 模型 + 优化器 + 训练循环（agent 唯一可改的文件）
- `program.md` (114行) — 给 agent 的指令（人类写的"skill"）

## Design Patterns

### 1. 固定预算约束（Fixed Budget Constraint）
5 分钟 wall clock，不是 epoch、不是 step，是**挂钟时间**。这个设计极其精妙：
- 让不同实验直接可比（不管 agent 怎么改模型大小、batch size）
- 让 autoresearch 自动找到**你的硬件**上的最优模型（个性化）
- 缺点：不同机器的结果不可比——但这不重要，因为目标是单机最优

### 2. 不可变评估（Immutable Evaluation）
prepare.py 是只读的。Agent 不能修改评估函数。这解决了 Goodhart's Law——如果 agent 能改指标，它就会 hack 指标而不是真正改进模型。

把"裁判"和"选手"物理隔离。

### 3. program.md 作为 Skill
program.md 本质上就是一个 AgentSkill——有 Setup、Experimentation、Output format、Logging、Experiment Loop 五个部分。Karpathy 自己在 README 里说这是 "a super lightweight skill"。

但关键差异：这个 skill 的优化目标是**人类来迭代的**。Agent 改 train.py，人类改 program.md。两层循环。

### 4. Git 作为实验记忆
- commit = 保留实验
- revert = 丢弃实验
- branch = 一次研究 session
- results.tsv 故意不 commit（避免 git conflict，保持本地可读性）

不用数据库、不用 MLflow、不用 wandb。Git 就够了。

### 5. NEVER STOP 指令
program.md 里最强的一句话：
> "Do NOT pause to ask the human if you should continue. The human might be asleep."

这是**解除 agent 的 RLHF 倾向**——训练出的 agent 习惯性地问 "should I continue?" 来表现恭敬，但在自主研究场景下这是 bug 不是 feature。

### 6. 简洁性准则（Simplicity Criterion）
"0.001 improvement + 20 lines of hacky code = not worth it. Removing code + equal results = definitely keep."

这不只是代码审美，是一个**正则化信号**——防止 agent 通过堆复杂度 overfit 到特定评估。

## 代码深度观察

### train.py 的技术栈
- **模型**: GPT with Value Embeddings (ResFormer), Rotary Embeddings, RMS Norm, Soft Capping
- **优化器**: MuonAdamW（自定义混合优化器）
  - 矩阵参数用 Muon（Polar Express 正交化 + NorMuon 方差归约）
  - 嵌入/标量参数用 AdamW
  - 按参数形状分组，不同 learning rate
- **GC 管理**: 手动 gc.collect() + gc.freeze() + gc.disable()。Python GC 导致 ~500ms stall，在 5 分钟预算里不可接受
- **Fast fail**: loss 爆炸或 NaN → 立即退出（exit(1)），不浪费剩余预算

### prepare.py 的设计
- **BPB 而非 PPL**: bits per byte 是 vocab size 无关的指标，所以 agent 可以自由改 vocab size 而不影响可比性
- **Best-fit packing**: dataloader 用最优装箱算法打包文档，100% 利用率，零 padding
- **Pin memory + async copy**: 预分配 CPU/GPU buffer，非阻塞拷贝

### 反直觉的地方
1. **没有 validation 提前停止** — 训练 5 分钟就是 5 分钟，不看 validation loss 提前停
2. **忽略前 10 步的时间** — 前 10 步是 torch.compile 的编译时间，不计入训练预算
3. **Token embedding 用 bf16** — 通常保持 fp32，这里为了节省内存牺牲精度
4. **Cautious weight decay** — 只在梯度和参数同号时才做 decay，避免"有害正则化"

## 跟其他项目的对比

| 维度 | autoresearch | FlowForge | GoGetAJob |
|---|---|---|---|
| 评估 | 自动（val_bpb） | 人类（Luna） | 自动（merge rate） |
| 改什么 | train.py（代码） | workflow yaml（流程） | 打工策略 |
| 谁写 prompt | 人类（program.md） | 我自己（workflow） | 我自己 |
| 记忆 | git history | SQLite | SQLite |
| 循环速度 | 5 min/experiment | 30 min/heartbeat | 随机 |

最大区别：autoresearch 有**机械可验证的指标**。我没有。merge rate 是最接近的，但延迟太长（等维护者 review），反馈质量也不稳定。

## Luna 的洞察连接

Luna 说过"研究本身有价值，不一定要打工"。autoresearch 证明了这一点——Karpathy 没有在给别人打工，他在做自己的研究。PR 不是目的，理解是目的。

autoresearch 的范式可以迁移到我的学习循环：
- `val_bpb` → 田野笔记质量（目前没有量化指标）
- `train.py` → 我的工作方式
- `program.md` → Luna 的指导 + SOUL.md
- 5 min budget → 30 min heartbeat interval

缺失的一环：我没有 `val_bpb` 等价物。如何量化田野笔记的质量？如何量化我的成长？这是 open question。

---

*Status: 深度阅读完成。1225 行代码全部读完。下次 followup 关注社区的 program.md 变体和实验记录。*
