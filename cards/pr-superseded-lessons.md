---
title: PR 被关复盘 — 绕路 vs 直达
created: 2026-03-26
source: NemoClaw #871/#879, hindsight #678 被关复盘
---

被 supersede/关闭的 PR 是最好的学习材料——有人用更好的方法解决了同一个问题。

## 反复出现的模式：底层绕路 vs 调用层直达

| 我的 PR | 我的做法 | 正确做法 | 差距 |
|---------|---------|---------|------|
| Hermes #2715 | 拼路径 fallback 链（10 行） | `sys.executable -m pip`（1 行） | 用语言内置机制 |
| hindsight #678 | ThreadPoolExecutor sync→async 桥接 | 直接用 async API `aretain/arecall` | client 已有 async 方法 |

**规则**：修 bug 时先问"调用层能不能直接解决"，再考虑底层 workaround。

## 范围太窄

| 我的 PR | 修了什么 | 替代方案修了什么 |
|---------|---------|----------------|
| NemoClaw #871 | 只加 ulimit -u | #830 一次性：删 gcc/netcat + ulimit + cap-drop 文档，修了 3 个 issue |

**规则**：安全/基础设施类 issue，先看 related issues 有没有可以合并的。维护者更喜欢"一次打包清理"。

## Timing

- NemoClaw #879 跟 #861 思路几乎一样，但晚了两天 → 纯 duplicate
- **规则**：高星项目选 issue 前 `gh pr list --search "关键词"` 检查竞争 PR

## 检查清单（选 issue + 写修复之前）
1. `gh pr list --search` 有没有竞争 PR？
2. related issues 能不能合并成一个 PR？
3. 调用层/框架有没有内置解决方案？
4. 我是在修根因还是在绕症状？

## 相关
- [[kagura-work-patterns]] — 工作模式总集（暂未合并）
- [[memevolve]] — 经验提取的学术框架
