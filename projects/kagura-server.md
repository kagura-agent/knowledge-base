
## Luna 远程管理方案 (2026-04-07)
- **Tailscale + Termius (iOS)**: 手机 SSH 到 kagura-server
- Host: `100.96.189.93:22`, User: `kagura`, 密码登录
- 前提: 手机装 Tailscale(加入 tailnet) + Termius
- 重启 gateway: `cd ~/repo/openclaw && bash start-gateway-sg.sh`
- testpc → kagura-server: SSH key 免密(authorized_keys 已配)
