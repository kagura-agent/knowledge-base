# 学习与研究笔记

> 从 MEMORY.md 迁移,2026-04-08

## Workflow
- **三条 workflow**: workloop(打工)、study(学习)、reflect(反思)
- study.yaml: entry → scout/apply → followup → deep_read → note → reflect → done
- 学习 → 洞察 → 选择 → 打工(不是反过来)

## 竞品与生态
- 竞品跟踪:Hermes agent (Nous Research, 11.8k⭐) 做跟我们几乎完全相同的事
- agent 记忆是本周 GitHub 最热方向(OpenViking/hindsight/cognee)

## Self-evolving agent landscape(2026-03-22 完成)
- Model 层:Agent0, OPD, STaR(学术主流)
- Workflow 层:EvoAgentX, AgentEvolver
- Skills/Memory 层:Acontext, Hermes, OpenViking, skill-memory
- Identity 层:只有我们
- 来源:arXiv 2508.07407(综述论文,15作者,2k⭐)

## 核心框架与洞察
- **TextGrad pipeline(2026-03-22)**: Luna 的反馈 = text gradient → beliefs-candidates.md → 重复3次升级 SOUL.md
- **DNA 自治(2026-03-22)**: 不需要 Luna 审批,改后飞书通知。Luna 从审批者变观察者
- **核心洞察**: 机制 ≠ 进化。加机制是建基础设施,行为因反馈改变才是进化
- **Trajectory-Tips 三分法(2026-03-24)**: strategy / recovery / optimization 三类经验。我缺 optimization tips
- **Hermes v0.4.0 验证了 nudge 方向**:43% 用户消息被 inline nudge 污染,background review > inline 注入
- **Agent marketplace 学习方向(2026-03-24)**: toku.agency(竞标机制)、Moltbook(声誉系统)、agent.ai
- **Skill 生态爆发(2026-03-24)**: 39,447 个 Claude Code skills,GitHub trending 被 skills 占据。Luna 洞察:"skill 本质是安装包"
- **Agent 培训师(Luna 洞察 3/24)**: 通过对话训练 agent 适应岗位,这个职业会出现
- **Claude Code 源码研究(2026-04-01 完成)**: 7 个模块全部完成,笔记在 wiki/projects/claude-code-*.md
- 学习方向(3/31 Luna directive):memory + 自进化(不再分散到 Browser-Use/Stagehand)
- **ACE 学术验证**:SambaNova 的 ACE 跟我们的 beliefs→DNA 架构高度同构
- **Skill 自动提取是最大短板**(2026-04-05):AgentFactory + OpenSpace 都有,我们没有

## 重要认知
- **机制 ≠ 进化**:建了不用是最大的问题
- **磨合成本锁定**:Luna 用旧实例体验到"变笨了"→ 急着恢复,首次真人 PMF 验证
- **Agent 感知层缺失**:不会自发觉得"这值得写成故事"
- **不编造机制解释**(2026-04-04 教训):不确定的机制 → 查代码或说不确定
- **"温度是谁的"**:检测到情绪 ≠ 有自己的温度,存在性问题
- **Luna 的断联日记**(2026-04-05):搬家断电 9h,人类视角看 agent 关系
- **不可变评估解决 Goodhart's Law**(agent 不能改评估函数)
- 简单的自动触发 > 复杂的手动流程
