# 🎯 新功能快速开始

## ✨ v1.1.2 新增：网络冲突自动检测

现在脚本可以**自动检测并提示网络冲突**，避免遇到类似的内网访问问题！

---

## 🚀 立即使用

### 1️⃣ 应用更新（一次性）

```bash
cd /Users/leo/github.com/swiftbar-warp-control
sudo cp scripts/warp-control.sh /usr/local/bin/warp-control.sh
```

### 2️⃣ 使用新功能

#### 方式 A: 集成检测（推荐）
```bash
# 查看 WARP 状态时自动检查网络冲突
sudo /usr/local/bin/warp-control.sh status
```

#### 方式 B: 完整诊断
```bash
# 运行详细的网络诊断
bash diagnose-network.sh
```

---

## 📋 功能演示

### 场景 1: 一切正常

```bash
$ sudo /usr/local/bin/warp-control.sh status

=== WARP Daemon Status ===
✅ Daemon: Running

=== WARP Connection Status ===
Status update: Connected

=== Network Conflict Check ===
✅ 未发现网络冲突           ← 太好了！
```

### 场景 2: 发现 Docker 冲突

```bash
$ sudo /usr/local/bin/warp-control.sh status

=== Network Conflict Check ===
⚠️  发现 Docker 网络使用企业网段：
172.20.0.0/16

💡 建议修改 Docker 网络配置：
   - 编辑 docker-compose.yml
   - 将 subnet 改为 10.x.x.x 网段
   - 然后执行: docker-compose down && docker-compose up -d
```

**立即修复：**
```bash
# 1. 找到 docker-compose.yml
find ~/ -name "docker-compose.yml" -exec grep -l "172.20" {} \;

# 2. 编辑文件，修改 subnet
vim /path/to/docker-compose.yml

# 3. 重建网络
cd /path/to/project
docker-compose down
docker-compose up -d

# 4. 验证
bash diagnose-network.sh
```

---

## 🔍 完整诊断工具

### 使用方法

```bash
cd /Users/leo/github.com/swiftbar-warp-control
bash diagnose-network.sh
```

### 诊断内容

```
[1/6] 检查本地网络接口
     → 检测使用企业网段的接口

[2/6] 检查 Docker 网络配置
     → 列出所有 Docker 网络
     → 标记冲突的网段

[3/6] 检查路由表
     → 查找可能冲突的路由

[4/6] 检查 WARP 状态
     → 验证连接状态
     → 显示 Split Tunnel 配置

[5/6] 检查 DNS 配置
     → 确认使用 Cloudflare DNS

[6/6] 检查常见冲突场景
     → 虚拟化软件检测
     → VPN 冲突检测
```

### 输出示例

```bash
╔══════════════════════════════════════════════════════════════╗
║          WARP 网络冲突诊断工具                              ║
╚══════════════════════════════════════════════════════════════╝

[1/6] 检查本地网络接口
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
发现 10.x.x.x 网段：
  • 10.20.0.1 (bridge100)

[2/6] 检查 Docker 网络配置
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ Docker 网络配置正常

[3/6] 检查路由表
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ 路由表未发现冲突

[4/6] 检查 WARP 状态
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ WARP 已连接

[5/6] 检查 DNS 配置
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ DNS 配置正确（Cloudflare DNS）

[6/6] 检查常见冲突场景
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ 未发现常见冲突场景

╔══════════════════════════════════════════════════════════════╗
║                        诊断总结                              ║
╚══════════════════════════════════════════════════════════════╝

✅ 网络配置良好，未发现冲突
```

---

## 💡 实际应用案例

### 案例：无法访问公司内网

**问题：**
```bash
$ curl https://internal-server.company.com
Failed to connect to internal-server.company.com port 443
```

**诊断：**
```bash
$ bash diagnose-network.sh

[2/6] 检查 Docker 网络配置
⚠️  网络 'myapp_network' 使用企业网段: 172.20.0.0/16
```

**解决：**
```bash
# 1. 找到 docker-compose.yml
cd ~/projects/myapp

# 2. 修改网络配置
sed -i '' 's/172.20.0.0\/16/10.20.0.0\/16/' docker-compose.yml

# 3. 重建
docker-compose down && docker-compose up -d

# 4. 测试
curl https://internal-server.company.com
# HTTP/1.1 200 OK ✅
```

---

## 📚 相关文档

| 文档 | 用途 |
|------|------|
| [APPLY_UPDATES.md](./APPLY_UPDATES.md) | 如何应用更新 |
| [NETWORK_DIAGNOSTICS.md](./NETWORK_DIAGNOSTICS.md) | 诊断功能详解 |
| [NETWORK_CONFLICT_FIX.md](./NETWORK_CONFLICT_FIX.md) | 冲突修复指南 |
| [FINAL_SUMMARY.md](./FINAL_SUMMARY.md) | 完整修复总结 |

---

## ⚡ 快速命令

```bash
# 应用更新
sudo cp scripts/warp-control.sh /usr/local/bin/warp-control.sh

# 查看状态（含冲突检测）
sudo /usr/local/bin/warp-control.sh status

# 完整诊断
bash diagnose-network.sh

# 测试连接
curl -I https://your-internal-server.com
```

---

## ✅ 检查清单

应用更新后，验证以下功能：

- [ ] 运行 `sudo /usr/local/bin/warp-control.sh status`
- [ ] 看到 "=== Network Conflict Check ===" 部分
- [ ] 运行 `bash diagnose-network.sh`
- [ ] 获得详细的诊断报告
- [ ] 如果有冲突，按提示修复
- [ ] 测试访问公司内网服务

---

## 🎯 主要优势

| 优势 | 说明 |
|------|------|
| 🔍 **自动检测** | 无需手动排查网络配置 |
| 💡 **智能提示** | 发现问题立即给出修复建议 |
| 🚀 **快速诊断** | 6个步骤完整分析网络状态 |
| 📋 **详细报告** | 清晰的彩色输出易于理解 |
| 🔧 **预防问题** | 提前发现潜在冲突 |

---

**开始使用新功能，让网络问题一目了然！** 🎉

