# 🚀 WARP 修复快速参考

## ⚡ 一键修复

```bash
cd /Users/leo/github.com/swiftbar-warp-control && \
sudo cp scripts/warp-control.sh /usr/local/bin/warp-control.sh && \
sudo chmod 755 /usr/local/bin/warp-control.sh && \
echo "✅ 脚本已更新" && \
bash test-fix.sh
```

## 🔍 问题原因

**一句话**: 只启动了进程，没建立连接。

```
旧版: launchctl load                     → daemon 运行，但 DNS ❌
新版: launchctl load + warp-cli connect → daemon 运行，DNS ✅
```

## ✅ 验证成功

```bash
# 启动 WARP
sudo /usr/local/bin/warp-control.sh start
# 看到: 🔗 建立 WARP 连接... ✅ WARP 已启动并连接

# 检查状态
warp-cli status
# 输出: Status update: Connected

# 检查 DNS
scutil --dns | grep '162.159'
# 看到 Cloudflare DNS IP
```

## 📋 完整测试流程

```bash
# 1. 停止
sudo /usr/local/bin/warp-control.sh stop

# 2. 启动
sudo /usr/local/bin/warp-control.sh start

# 3. 状态
sudo /usr/local/bin/warp-control.sh status

# 4. 验证 DNS
scutil --dns | grep nameserver

# 5. Web 验证
open https://1.1.1.1/help
```

## 🔧 手动验证诊断

```
WARP App → 设置 ⚙️ → 诊断 → 运行诊断
```

**预期结果:**
- DNS servers issue: ✅ NO DETECTION (绿色)
- Frequent Disconnections: ✅ 计数为 0

## 📦 更新的文件

```
✅ scripts/warp-control.sh    - 核心修复
✅ CHANGELOG.md               - 版本记录
✅ WARP_FIX.md               - 技术详解
✅ QUICK_UPDATE.md           - 更新指南
✅ EXECUTIVE_SUMMARY.md      - 执行摘要
✅ test-fix.sh               - 测试脚本
✅ FIX_SUMMARY.md            - 修复总结
```

## 🐛 故障排除

### warp-cli 未找到
```bash
which warp-cli
# 如果没输出:
sudo ln -sf /Applications/Cloudflare\ WARP.app/Contents/Resources/warp-cli /usr/local/bin/warp-cli
```

### DNS 仍有问题
```bash
# 检查冲突软件
ps aux | grep -i "adguard\|surge\|clash"

# 查看所有 DNS 配置
scutil --dns
```

### 权限问题
```bash
ls -la /usr/local/bin/warp-control.sh
# 应该: -rwxr-xr-x

sudo chmod 755 /usr/local/bin/warp-control.sh
```

## 📞 关键命令速查

| 命令 | 说明 |
|------|------|
| `warp-cli status` | 查看连接状态 |
| `warp-cli connect` | 手动连接 |
| `warp-cli disconnect` | 手动断开 |
| `warp-cli settings` | 查看配置 |
| `scutil --dns` | 查看 DNS 配置 |
| `networksetup -getdnsservers Wi-Fi` | 查看网络 DNS |
| `launchctl list \| grep warp` | 查看 daemon 状态 |

## 🎯 核心改动

```bash
# 旧版 start_warp()
launchctl load "$DAEMON_PATH"

# 新版 start_warp()
launchctl load "$DAEMON_PATH"
warp-cli connect  # ← 关键添加

# 旧版 stop_warp()
launchctl unload "$DAEMON_PATH"

# 新版 stop_warp()
warp-cli disconnect  # ← 关键添加
launchctl unload "$DAEMON_PATH"
```

## 📊 技术对比

| 功能 | 旧版 | 新版 |
|:-----|:----:|:----:|
| Daemon 运行 | ✅ | ✅ |
| VPN 连接 | ❌ | ✅ |
| DNS 配置 | ❌ | ✅ |
| 网络工作 | ❌ | ✅ |

## 🔗 相关链接

- 详细说明: [WARP_FIX.md](./WARP_FIX.md)
- 快速更新: [QUICK_UPDATE.md](./QUICK_UPDATE.md)
- 执行摘要: [EXECUTIVE_SUMMARY.md](./EXECUTIVE_SUMMARY.md)
- 修复总结: [FIX_SUMMARY.md](./FIX_SUMMARY.md)

## ✨ TL;DR

```bash
# 更新
sudo cp scripts/warp-control.sh /usr/local/bin/warp-control.sh

# 测试
bash test-fix.sh

# 完成 ✅
```

