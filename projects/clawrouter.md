# ClawRouter

## 基本信息
- **Repo**: BlockRunAI/ClawRouter
- **语言**: TypeScript
- **Stars**: ~6.2k
- **Merge Rate**: 38%（偏低，选题要谨慎）
- **Fork**: kagura-agent/ClawRouter → ~/repos/forks/ClawRouter
- **测试**: `npx vitest run`（409+ tests）
- **Lint**: `npx eslint src/` + `npx prettier --check .`

## CI 注意事项
- **必须跑 prettier**：CI 有 `prettier --check .`，本地改完跑 `npx prettier --write <files>`
- **eslint 严格**：unused imports 会 fail
- Typecheck 用 CI 的 tsc，本地有 pre-existing error（Socks5ProxyAgent）可忽略

## 架构要点
- **路由配置**: `src/router/config.ts` 定义 DEFAULT_ROUTING_CONFIG
- **类型**: `src/router/types.ts` — RoutingConfig, Tier, TierConfig
- **策略**: `src/router/strategy.ts` — 根据 routingProfile 选 tierConfigs
- **代理**: `src/proxy.ts` — mergeRoutingConfig, 注册/更新路由
- **Tier 系统**: tiers(默认) / agenticTiers(有工具时) / ecoTiers(eco profile) / premiumTiers(premium profile)

## 维护者模式
- 尚未观察到人类 reviewer，两个 PR 都是新提的
- CodeRabbit 配置了 CHILL profile，nitpick 为主

## PR 历史
| PR | Issue | 状态 | 内容 |
|----|-------|------|------|
| #149 | #147 | pending | fix: routing config 在 proxy reuse 路径被跳过 |
| #150 | #148 | pending | fix: mergeRoutingConfig 不合并 agenticTiers/ecoTiers/premiumTiers |

## 经验
- #147 和 #148 是同一个用户报的关联问题，连续选题效率高
- prettier 格式问题导致 CI fail 两次，以后**改完代码先跑 prettier 再 commit**
- `mergeTierRecord` helper 可能需要 per-tier deep merge（CodeRabbit 建议），但当前与 `tiers` 的 merge 方式一致
