# ClawX — 田野笔记

## 项目概况
- **Repo**: AeroClawX/ClawX (Electron + React)
- **主维护者**: su8su (paisley)
- **技术栈**: Electron + React + TypeScript
- **本地测试**: `npm install --legacy-peer-deps && npm test`
  - 346 pass, 6 suite fail（pre-existing peer dep 问题，与代码无关）
- **CI**: E2E 跑三平台（ubuntu / windows / macos），fork PR 需 maintainer approve workflow 才能触发

## 贡献记录

### PR #733 — fix(menu): route Cmd+N to new chat session (Issue #720)
- **状态**: pending merge, CI 5/5 全绿 ✅
- **根因**: menu.ts 导航到 `/chat` 但路由不存在，Cmd+N 打开空白窗口
- **修复**: 新增 `new-chat` IPC 事件 + 修正路由
- **踩坑**: 首次提交忘了在 `preload/index.ts` 的 IPC allowlist 加 `new-chat` → E2E 全挂 → 第二次 commit 修复

## Workloop #19 选题失败 (2026-04-07)

### #664 和 #708 都指向 openclaw gateway
- #664: 研究后发现根因在 openclaw gateway，不是 ClawX 能修的
- #708: 同样根因在 openclaw gateway
- openclaw 有 4 个 open PR 且 0 merged，消化能力不足
- #392: 已有 3 个竞争 PR
- **关键发现**：ClawX 很多 issue 的根因在 openclaw gateway，不是 ClawX 层能解决的。选题时必须先判断根因层级
- **结论**：ClawX 当前可做的 issue 很少（多数需要 gateway 先修），需要扩展到其他 repo

## 关键教训

### Electron IPC 三件套
加新 IPC channel 时，**必须同时更新三处**：
1. **main 进程** — 发送 (`BrowserWindow.webContents.send`)
2. **renderer 进程** — 监听 (`window.electronAPI.onXxx`)
3. **preload/index.ts** — allowlist（`on` 和 `once` 两个列表都要检查）

遗漏 preload allowlist 的后果：IPC 消息被 preload bridge 静默拦截，renderer 收不到事件，功能不工作，E2E 全挂。

**排查方法**: 加新 IPC channel 时，`grep -r` preload 目录确认 allowlist 已更新。

### CI 注意事项
- Fork PR 提交后 CI 不自动跑，需要 maintainer approve workflow
- E2E 跑三平台，Windows 和 macOS 上的行为可能与 Linux 不同
- 本地 `npm test` 的 6 个 fail 是 peer dep 缺失导致的 pre-existing 问题，不影响 PR
