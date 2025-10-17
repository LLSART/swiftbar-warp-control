# 🧪 v1.1.1 验证指南

## ⚡ 快速验证（5 分钟）

### 步骤 1: 应用更新
```bash
cd /Users/leo/github.com/swiftbar-warp-control
sudo cp scripts/warp-control.sh /usr/local/bin/warp-control.sh
sudo chmod 755 /usr/local/bin/warp-control.sh
```

### 步骤 2: 运行自动化测试
```bash
bash test-fix.sh
```

**预期结果：**
```
✅ All tests passed!
```

### 步骤 3: 重启 SwiftBar
```bash
pkill -f SwiftBar && sleep 1 && open -a SwiftBar
```

---

## 🔍 详细验证

### 验证 1: 脚本语法检查
```bash
bash -n /usr/local/bin/warp-control.sh
echo $?  # 应该输出 0
```

### 验证 2: PATH 修复
```bash
# 检查脚本中的 PATH 设置
head -15 scripts/warp-control.sh | grep -A2 "export PATH"
```

**应该看到：**
```bash
export PATH="/usr/local/bin:/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin"
```

### 验证 3: find_warp_cli 函数
```bash
# 检查函数是否存在
grep -n "find_warp_cli" scripts/warp-control.sh
```

**应该看到：**
```
21:find_warp_cli() {
88:    warp_cli=$(find_warp_cli)
159:    warp_cli=$(find_warp_cli)
210:    warp_cli=$(find_warp_cli)
```

### 验证 4: warp-cli 可访问性

#### 4a. 正常环境
```bash
which warp-cli
# 应该输出: /usr/local/bin/warp-cli
```

#### 4b. sudo 环境（关键测试！）
```bash
sudo bash -c 'which warp-cli'
# v1.1.1 应该能找到
# 如果找不到，脚本的 PATH 导出应该能处理
```

#### 4c. 完全干净的 sudo PATH
```bash
sudo env -i PATH=/usr/bin:/bin:/usr/sbin:/sbin \
  bash -c 'source /usr/local/bin/warp-control.sh && find_warp_cli'
# 应该输出 warp-cli 的路径
```

### 验证 5: 停止功能
```bash
sudo /usr/local/bin/warp-control.sh stop
```

**应该看到：**
```
🛑 停止 WARP...
🔌 断开 WARP 连接...        ← 新增
✅ WARP 连接已断开          ← 新增
✅ WARP 已停止
```

**验证结果：**
```bash
warp-cli status
# 应该显示: Disconnected 或 Unable to connect
```

### 验证 6: 启动功能（核心测试）
```bash
sudo /usr/local/bin/warp-control.sh start
```

**应该看到：**
```
🚀 启动 WARP...
🔗 建立 WARP 连接...        ← 关键：这行必须出现！
✅ WARP 已启动并连接         ← 关键：确认连接成功！
```

**如果失败应该看到：**
```
🚀 启动 WARP...
🔗 建立 WARP 连接...
❌ WARP daemon 已启动，但连接失败    ← 明确的错误
错误详情: [具体错误信息]
⚠️  请检查设备是否已注册或许可证是否有效
```

**验证结果：**
```bash
warp-cli status
# 必须显示: Connected 或 Status update: Connected
```

### 验证 7: DNS 配置
```bash
# 方法 1
scutil --dns | grep 'nameserver\[0\]'
# 应该看到: nameserver[0] : 162.159.36.1 或类似

# 方法 2
scutil --dns | grep -A4 'resolver #1'
# 应该看到 Cloudflare 的 DNS 服务器

# 方法 3
networksetup -getdnsservers "Wi-Fi"
# 应该看到 Cloudflare DNS 地址
```

### 验证 8: 状态命令
```bash
sudo /usr/local/bin/warp-control.sh status
```

**应该看到：**
```
=== WARP Daemon Status ===
✅ Daemon: Running

=== WARP Connection Status ===
warp-cli path: /usr/local/bin/warp-cli    ← 显示实际路径
Status update: Connected                  ← 连接状态

=== WARP Settings ===
[WARP 配置详情]
```

### 验证 9: SwiftBar 集成（最重要！）
```bash
# 1. 重启 SwiftBar
pkill -f SwiftBar
open -a SwiftBar

# 2. 在菜单栏找到 WARP 图标（🟢 或 🔴）
# 3. 点击图标
# 4. 点击 "停止 WARP"
# 5. 等待 2 秒
# 6. 点击 "启动 WARP"
# 7. 验证连接
warp-cli status
```

### 验证 10: WARP 官方诊断
```bash
# 打开 WARP 应用
open -a "Cloudflare WARP"

# 然后：
# 1. 点击设置图标 ⚙️
# 2. 点击 "诊断"
# 3. 点击 "运行诊断"
# 4. 等待诊断完成
```

**预期结果：**
- ✅ "macOS WARP DNS servers are not being set" → **NO DETECTION** (绿色)
- ✅ "Frequent Disconnections" → **计数为 0**
- ⚠️ "macOS Application Firewall" → 可能仍需手动配置

---

## ✅ 成功标志清单

- [ ] 脚本语法检查通过
- [ ] PATH 包含 `/usr/local/bin`
- [ ] `find_warp_cli` 函数存在
- [ ] warp-cli 在正常环境可找到
- [ ] warp-cli 在 sudo 环境可找到
- [ ] 停止时显示 "断开连接" 消息
- [ ] 启动时显示 "建立连接" 消息
- [ ] `warp-cli status` 显示 Connected
- [ ] DNS 配置为 Cloudflare 地址
- [ ] status 命令显示 warp-cli 路径
- [ ] SwiftBar 菜单控制正常工作
- [ ] WARP 诊断无 CRITICAL 错误

---

## 🔴 失败场景处理

### 场景 1: warp-cli 找不到
```bash
# 检查 warp-cli 是否存在
ls -la /usr/local/bin/warp-cli
ls -la /opt/homebrew/bin/warp-cli
ls -la "/Applications/Cloudflare WARP.app/Contents/Resources/warp-cli"

# 如果找到但不在标准位置，创建符号链接
sudo ln -sf /Applications/Cloudflare\ WARP.app/Contents/Resources/warp-cli \
  /usr/local/bin/warp-cli
```

### 场景 2: 启动成功但没有 "建立连接" 消息
```bash
# 这意味着 find_warp_cli 失败了
# 检查脚本版本
head -20 /usr/local/bin/warp-control.sh | grep "export PATH"

# 如果没有看到 PATH 导出，说明旧脚本还在
# 重新复制
sudo cp scripts/warp-control.sh /usr/local/bin/warp-control.sh
```

### 场景 3: 连接失败但显示详细错误
```bash
# 这是预期行为（v1.1.1 的改进）
# 根据错误信息采取行动：

# 如果是 "device not registered"
open -a "Cloudflare WARP"
# 在应用中注册设备

# 如果是 "license invalid"
# 检查 WARP 订阅状态

# 如果是其他网络错误
# 检查网络连接和防火墙
```

### 场景 4: SwiftBar 菜单不工作
```bash
# 1. 检查 sudoers 配置
sudo cat /etc/sudoers.d/warp-toggle

# 应该包含类似：
# your_username ALL=(ALL) NOPASSWD: /usr/local/bin/warp-control.sh

# 2. 测试 sudo 免密
sudo -n /usr/local/bin/warp-control.sh status

# 如果要求密码，重新配置 sudoers
# （参考 install.sh）
```

---

## 🧪 自动化测试

### 运行完整测试套件
```bash
bash test-fix.sh
```

**测试包括：**
1. PATH 检查（sudo 环境）
2. warp-cli 可用性
3. 控制脚本存在性
4. 停止功能
5. 断开验证
6. 启动功能（关键）
7. 连接验证
8. DNS 配置

### 预期输出
```
╔══════════════════════════════════════════════════════════════╗
║        WARP Connection Fix - Verification Test               ║
╚══════════════════════════════════════════════════════════════╝

[1/8] Checking PATH in sudo context...
✅ /usr/local/bin is in sudo PATH

[2/8] Checking warp-cli availability...
✅ warp-cli found at: /usr/local/bin/warp-cli

[3/8] Checking control script...
✅ Control script found

[4/8] Testing WARP stop...
✅ Stop command completed

[5/8] Verifying disconnection...
✅ WARP is disconnected

[6/8] Testing WARP start with connection...
✅ Start command completed

[7/8] Verifying connection establishment...
Status update: Connected
✅ WARP is properly connected

[8/8] Checking DNS configuration...
nameserver[0] : 162.159.36.1
✅ Cloudflare DNS is configured

╔══════════════════════════════════════════════════════════════╗
║                  ✅ All tests passed!                         ║
╚══════════════════════════════════════════════════════════════╝
```

---

## 📋 验证报告模板

完成验证后，填写此清单：

```
验证日期: [填写日期]
系统版本: [macOS 版本]
芯片类型: [Intel / Apple Silicon]

✅ / ❌  脚本语法检查
✅ / ❌  PATH 修复验证
✅ / ❌  find_warp_cli 函数
✅ / ❌  sudo 环境 warp-cli 可用
✅ / ❌  停止功能（含断开连接消息）
✅ / ❌  启动功能（含建立连接消息）
✅ / ❌  warp-cli status = Connected
✅ / ❌  DNS 配置正确
✅ / ❌  SwiftBar 菜单工作
✅ / ❌  WARP 诊断通过
✅ / ❌  自动化测试通过

问题记录:
[如有问题，记录在此]

最终结论:
[ ] ✅ 验证通过，可以使用
[ ] ⚠️ 部分问题，需要修复
[ ] ❌ 验证失败，需要回滚
```

---

## 🚀 快速命令参考

```bash
# 一键更新 + 测试
cd /Users/leo/github.com/swiftbar-warp-control && \
sudo cp scripts/warp-control.sh /usr/local/bin/warp-control.sh && \
bash test-fix.sh && \
pkill -f SwiftBar && open -a SwiftBar

# 检查版本
grep -n "export PATH" /usr/local/bin/warp-control.sh
grep -n "find_warp_cli" /usr/local/bin/warp-control.sh

# 测试功能
sudo /usr/local/bin/warp-control.sh stop
sudo /usr/local/bin/warp-control.sh start
sudo /usr/local/bin/warp-control.sh status

# 验证连接
warp-cli status
scutil --dns | grep nameserver
```

