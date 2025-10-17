# 快速更新指南

## 问题
WARP 诊断显示：
- ❌ DNS servers are not being set
- ❌ Frequent Disconnections
- ⚠️ Application Firewall warning

## 原因
脚本只启动了 daemon，但没有调用 `warp-cli connect` 建立真正的网络连接。

## 修复内容
已更新 `scripts/warp-control.sh`：
- ✅ 启动时自动调用 `warp-cli connect`
- ✅ 停止时自动调用 `warp-cli disconnect`
- ✅ 增强 status 命令显示详细连接状态

## 安装更新

### 一键更新（需要 sudo 密码）
```bash
cd /Users/leo/github.com/swiftbar-warp-control
sudo cp scripts/warp-control.sh /usr/local/bin/warp-control.sh
sudo chmod 755 /usr/local/bin/warp-control.sh
```

### 验证安装
```bash
# 测试停止
sudo /usr/local/bin/warp-control.sh stop

# 测试启动（应该看到 "🔗 建立 WARP 连接..." 消息）
sudo /usr/local/bin/warp-control.sh start

# 检查详细状态
sudo /usr/local/bin/warp-control.sh status
```

### 重启 SwiftBar
```bash
pkill -f SwiftBar && sleep 1 && open -a SwiftBar
```

## 测试连接

### 1. 检查连接状态
```bash
warp-cli status
# 应该显示：Status update: Connected
```

### 2. 检查 DNS 配置
```bash
scutil --dns | grep 'nameserver\[0\]'
# 应该看到 Cloudflare DNS (162.159.36.x)
```

### 3. 验证网络
访问：https://1.1.1.1/help
应该显示：
- ✅ 使用 WARP
- ✅ DNS 查询已加密

### 4. 重新运行诊断
在 WARP 应用中：
设置 → 诊断 → 运行诊断

应该看到 DNS 问题已解决。

## 防火墙警告
如果仍有防火墙警告，手动添加规则：
1. 系统设置 → 网络 → 防火墙 → 选项
2. 点击 "+" 添加应用
3. 选择 `/Applications/Cloudflare WARP.app`
4. 选择 "允许传入连接"

## 如有问题

### 检查 warp-cli
```bash
which warp-cli
# 应该输出：/usr/local/bin/warp-cli
```

### 查看详细日志
```bash
# 启动并查看输出
sudo /usr/local/bin/warp-control.sh start

# 如果有错误，请截图反馈
```

### 回滚（如果需要）
```bash
git checkout HEAD~1 scripts/warp-control.sh
sudo cp scripts/warp-control.sh /usr/local/bin/warp-control.sh
```

## 技术细节
详见 [WARP_FIX.md](./WARP_FIX.md)

