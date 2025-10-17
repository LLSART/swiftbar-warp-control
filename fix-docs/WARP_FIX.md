# WARP Connection Fix - 解决 DNS 和频繁断开问题

## 问题诊断

根据 Cloudflare WARP 诊断结果，发现以下关键问题：

1. ❌ **Frequent Disconnections** (CRITICAL) - 频繁断开连接
2. ❌ **macOS WARP DNS servers are not being set** (CRITICAL) - DNS 服务器未配置
3. ⚠️ **macOS Application Firewall** (WARNING) - 防火墙规则问题

## 根本原因

之前的脚本**只启停了 WARP daemon 进程**，但**没有真正建立 WARP 网络连接**。

### 技术细节

```bash
# ❌ 旧版本（问题版本）
launchctl load /Library/LaunchDaemons/com.cloudflare.1dot1dot1dot1.macos.warp.daemon.plist
# 只启动了后台进程，但没有建立网络连接

# ✅ 新版本（修复版本）
launchctl load /Library/LaunchDaemons/com.cloudflare.1dot1dot1dot1.macos.warp.daemon.plist
warp-cli connect
# 启动进程 + 建立连接并配置 DNS/路由
```

**关键区别：**
- `launchctl load` → 启动 daemon 进程（CloudflareWARP 进程运行）
- `warp-cli connect` → 建立 VPN 连接，配置 DNS、路由、防火墙规则

## 解决方案

### 1. 更新了 `warp-control.sh` 脚本

#### 启动流程改进
```bash
start_warp() {
    # 1. 启动 daemon 进程
    launchctl load "$DAEMON_PATH"
    
    # 2. ✨ 新增：建立 WARP 连接
    warp-cli connect
    
    # 这样才能正确配置 DNS 和网络路由
}
```

#### 停止流程改进
```bash
stop_warp() {
    # 1. ✨ 新增：优雅断开连接
    warp-cli disconnect
    
    # 2. 停止 daemon 进程
    launchctl unload "$DAEMON_PATH"
}
```

#### 状态检查增强
```bash
get_status() {
    # 显示 daemon 状态
    # 显示连接状态（Connected/Disconnected）
    # 显示 WARP 设置详情
    warp-cli status
    warp-cli settings
}
```

### 2. 如何应用此修复

#### 方法 1：重新安装（推荐）
```bash
cd /Users/leo/github.com/swiftbar-warp-control
bash install.sh
```

安装脚本会：
- 自动复制更新后的脚本到 `/usr/local/bin/warp-control.sh`
- 设置正确的执行权限
- 重启 SwiftBar

#### 方法 2：手动更新
```bash
# 复制更新后的脚本
sudo cp scripts/warp-control.sh /usr/local/bin/warp-control.sh
sudo chmod 755 /usr/local/bin/warp-control.sh

# 重启 SwiftBar
pkill -f SwiftBar
open -a SwiftBar
```

### 3. 验证修复

更新后，测试启动 WARP：

```bash
# 测试启动
sudo /usr/local/bin/warp-control.sh start

# 应该看到：
# 🚀 启动 WARP...
# 🔗 建立 WARP 连接...
# ✅ WARP 已启动并连接

# 检查详细状态
sudo /usr/local/bin/warp-control.sh status

# 应该看到：
# === WARP Daemon Status ===
# ✅ Daemon: Running
#
# === WARP Connection Status ===
# Status update: Connected
# ...
```

### 4. 检查 DNS 配置

验证 DNS 是否正确配置：

```bash
# 方法 1：查看 DNS 服务器
scutil --dns | grep 'nameserver\[0\]'
# 应该看到类似：nameserver[0] : 162.159.36.1 (Cloudflare DNS)

# 方法 2：查看网络接口 DNS
networksetup -getdnsservers "Wi-Fi"
# 应该看到 Cloudflare 的 DNS 地址

# 方法 3：使用 WARP CLI
warp-cli status
# 应该显示 "Connected"
```

## 解决其他诊断问题

### 问题 1：防火墙警告
```bash
# 在系统设置中添加防火墙规则
# 路径：系统设置 → 网络 → 防火墙 → 选项
# 手动允许以下应用：
# - Cloudflare WARP.app
# - CloudflareWARP (daemon)
```

### 问题 2：DNS 冲突检查
如果仍有 DNS 问题，检查是否有其他软件冲突：

```bash
# 常见冲突软件：
# - AdGuard
# - Surge
# - Clash
# - ClashX
# - Little Snitch
# - 企业 VPN/MDM 配置

# 检查活跃的网络扩展
systemextensionsctl list

# 检查所有 DNS 解析器
scutil --dns
```

### 问题 3：验证没有频繁断开
更新后：
1. 停止 WARP
2. 启动 WARP
3. 保持运行 10 分钟
4. 打开 WARP 应用 → 设置 → 诊断
5. 确认 "Frequent Disconnections" 计数为 0

## 技术说明

### 为什么之前的方式不工作？

WARP 的完整启动需要两个步骤：

1. **系统层面**：启动 daemon 进程（`launchctl load`）
   - 这只是让后台服务运行
   - 进程会出现在 Activity Monitor
   - 但**不会建立网络连接**

2. **网络层面**：建立 VPN 连接（`warp-cli connect`）
   - 配置虚拟网络接口
   - 设置 DNS 服务器（162.159.36.1 等）
   - 配置路由表
   - 应用防火墙规则
   - 建立到 Cloudflare 的加密隧道

### 脚本行为对比

| 操作 | 旧版本 | 新版本 |
|------|--------|--------|
| 启动 daemon | ✅ | ✅ |
| 建立连接 | ❌ | ✅ |
| 配置 DNS | ❌ | ✅ |
| 设置路由 | ❌ | ✅ |
| 防火墙规则 | ❌ | ✅ |
| 加密隧道 | ❌ | ✅ |

### 为什么需要 warp-cli？

`warp-cli` 是 Cloudflare 官方的命令行工具，负责：
- 与 daemon 通信
- 触发连接/断开操作
- 管理网络配置
- 处理 DNS 设置
- 报告连接状态

它通常安装在：
- `/Applications/Cloudflare WARP.app/Contents/Resources/warp-cli`
- `/opt/homebrew/bin/warp-cli` (如果通过 Homebrew 安装)

## 测试清单

更新后请完成以下测试：

- [ ] 通过 SwiftBar 菜单启动 WARP
- [ ] 检查状态显示 "Connected"
- [ ] 访问 https://1.1.1.1/help 验证连接
- [ ] 停止 WARP，验证断开
- [ ] 重启 WARP，验证重连
- [ ] 运行诊断，确认没有 CRITICAL 错误
- [ ] 检查 DNS 设置正确
- [ ] 保持连接 10 分钟，确认稳定

## 回滚（如果需要）

如果新版本有问题，可以回滚到旧版本：

```bash
# 查看 git 历史
cd /Users/leo/github.com/swiftbar-warp-control
git log --oneline scripts/warp-control.sh

# 回滚到特定版本
git checkout <commit-hash> scripts/warp-control.sh

# 重新安装
bash install.sh
```

## 参考资源

- [Cloudflare WARP 官方文档](https://developers.cloudflare.com/warp-client/)
- [warp-cli 命令参考](https://developers.cloudflare.com/warp-client/warp-cli/)
- [macOS Network Extensions](https://developer.apple.com/documentation/networkextension)

## 更新历史

- **2025-10-17**: 修复 DNS 未配置和频繁断开问题，添加 `warp-cli connect/disconnect` 调用
- **之前版本**: 仅使用 `launchctl` 控制 daemon

