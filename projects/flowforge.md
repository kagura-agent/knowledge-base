
## workloop.yaml 改进：followup 增加通知检查 (2026-04-09)
- **来源**: beliefs-candidates 巡检盲区 pattern (3/30 ×2)
- **改动**: followup node 从只查 PR 状态 → 增加 `gh api notifications` 检查
- **原因**: Acontext #506 和 memex #29 的 post-merge review 都因为只查 open PR 而漏掉
- **验证**: 下次 workloop 执行时自动生效
