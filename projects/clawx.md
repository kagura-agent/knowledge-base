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
