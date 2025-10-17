# 🎯 解决 OrbStack 网络冲突问题

## 问题确认

你的 `bridge102` (172.20.0.0/16) 是由 **OrbStack** 创建的，与公司内网 `172.20.22.101` 冲突！

```
OrbStack 网络:    172.20.0.0/16 (本地)
公司内网服务器:   172.20.22.101
结果: 无法访问公司服务器 ❌
```

---

## ✅ 解决方案

### 方法 1：通过 OrbStack 图形界面修改（推荐）⭐

#### 步骤 1: 打开 OrbStack 设置
```bash
# 方法 A: 点击菜单栏的 OrbStack 图标
# OrbStack 图标 → Settings（设置）

# 方法 B: 命令行打开
open -a OrbStack
```

#### 步骤 2: 修改网络设置
```
1. Settings（设置）
2. Network（网络）标签
3. 找到 "IP Address Range" 或 "Network Subnet"
4. 修改为非冲突的网段，例如：
   - 10.20.0.0/16 ✅
   - 192.168.100.0/24 ✅
   - 10.200.0.0/16 ✅
5. 点击 Apply（应用）或 Save（保存）
6. 重启 OrbStack
```

#### 步骤 3: 重启 OrbStack
```bash
# 方法 A: 通过界面
# OrbStack → Quit → 重新打开

# 方法 B: 命令行（如果有 orb 命令）
killall "OrbStack Helper" "OrbStack"
sleep 3
open -a OrbStack
```

#### 步骤 4: 验证
```bash
# 检查新的网络配置
ifconfig | grep -A 3 "bridge"

# 应该看到新的 IP 段（不是 172.20.x.x）

# 测试访问
curl -I https://sg-git.pwtk.cc/user/login
```

---

### 方法 2：完全停止 OrbStack（临时方案）

如果你暂时不需要 OrbStack：

```bash
# 1. 停止所有 OrbStack 进程
killall "OrbStack Helper" "OrbStack"

# 2. 确认网络已释放
ifconfig bridge102
# 应该显示 "bridge102: no such interface"

# 3. 测试访问
curl -I https://sg-git.pwtk.cc/user/login

# 4. 如果成功，说明确实是 OrbStack 冲突
```

**注意：** 这会停止所有 OrbStack 容器和虚拟机！

---

### 方法 3：通过配置文件修改（高级）

如果 OrbStack 有配置文件：

```bash
# 1. 查找配置文件
find ~/Library ~/. -name "*orbstack*" -type f 2>/dev/null | grep -i config

# 2. 编辑配置文件（如果存在）
# 通常在:
# ~/Library/Application Support/OrbStack/config.json
# 或
# ~/.orbstack/config.yaml

# 3. 查找并修改网络相关配置，例如：
# "network": {
#   "subnet": "10.20.0.0/16"  // 修改这里
# }

# 4. 重启 OrbStack
```

---

## 📋 完整操作步骤

### Step 1: 备份当前容器（如果有重要数据）

```bash
# 列出运行的容器
docker ps

# 如果有重要数据，先备份
# docker commit <container_id> backup-image
```

### Step 2: 修改 OrbStack 网络

```bash
# 1. 打开 OrbStack
open -a OrbStack

# 2. 按照上面"方法 1"的图形界面步骤操作
# Settings → Network → 修改 IP Range → 保存

# 3. 退出并重启 OrbStack
```

### Step 3: 验证修改

```bash
# 1. 检查网络接口
echo "=== 检查是否还有 172.20.x.x ===" 
ifconfig | grep -B 2 "inet 172\.20"
# 应该为空或显示其他接口

# 2. 检查路由
echo "=== 检查路由表 ==="
netstat -rn | grep "172\.20"
# 应该没有本地 bridge 路由

# 3. 测试连接
echo "=== 测试访问公司服务器 ==="
curl -I --max-time 5 https://sg-git.pwtk.cc/user/login

# 4. 如果成功，应该看到 HTTP 响应头
```

### Step 4: 重启容器（如果需要）

```bash
# 如果你有 Docker 容器在运行
docker ps -a
# 根据需要重启容器
```

---

## 🔍 诊断脚本

保存并运行此脚本：

```bash
#!/bin/bash
# diagnose-orbstack-network.sh

echo "╔══════════════════════════════════════════════════════════╗"
echo "║       OrbStack 网络冲突诊断                              ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo ""

echo "[1/6] 检查 OrbStack 进程"
ps aux | grep -i orbstack | grep -v grep || echo "❌ OrbStack 未运行"
echo ""

echo "[2/6] 检查网络接口"
ifconfig | grep -B 2 "inet 172\." || echo "✅ 没有 172.x.x.x 接口"
echo ""

echo "[3/6] 检查路由表"
netstat -rn | grep "172\.20" || echo "✅ 没有 172.20.x.x 路由"
echo ""

echo "[4/6] DNS 解析测试"
nslookup sg-git.pwtk.cc
echo ""

echo "[5/6] Ping 测试"
ping -c 3 172.20.22.101
echo ""

echo "[6/6] HTTP 连接测试"
curl -I --max-time 5 https://sg-git.pwtk.cc/user/login
echo ""

echo "╔══════════════════════════════════════════════════════════╗"
echo "║                    诊断完成                              ║"
echo "╚══════════════════════════════════════════════════════════╝"
```

---

## 💡 推荐的 OrbStack 网络配置

建议使用这些非冲突的网段：

| 网段 | CIDR | 说明 |
|------|------|------|
| 10.20.0.0/16 | ✅ 推荐 | 与常见网络不冲突 |
| 10.200.0.0/16 | ✅ 推荐 | 更不常见的 10.x 段 |
| 192.168.100.0/24 | ⚠️ 可用 | 可能与家庭网络冲突 |

**避免使用：**
- ❌ 172.16.0.0/12 (包含 172.16-31.x.x) - 可能与公司内网冲突
- ❌ 192.168.0.0/16 - 可能与家庭/办公室网络冲突

---

## ⚠️ 注意事项

### 修改网络会影响什么？
- ✅ OrbStack 容器会获得新的 IP 地址
- ✅ 不会丢失容器数据
- ⚠️ 容器间的硬编码 IP 连接需要更新
- ⚠️ 端口映射保持不变

### 如果 OrbStack 没有网络设置选项？
可能是旧版本，建议：
```bash
# 1. 检查版本
open -a OrbStack
# 点击 About 查看版本号

# 2. 更新到最新版
# 访问 https://orbstack.dev/download
# 或通过 Homebrew:
# brew upgrade orbstack
```

---

## 🎯 快速解决方案

如果你现在就需要访问 `sg-git.pwtk.cc`：

```bash
# 方案 A: 临时停止 OrbStack（最快）
killall "OrbStack Helper" "OrbStack"
sleep 2
curl -I https://sg-git.pwtk.cc/user/login
# 测试后根据需要重启 OrbStack

# 方案 B: 临时停止 WARP + 使用公司 VPN
sudo /usr/local/bin/warp-control.sh stop
# 连接公司 VPN（如果有）
# 然后访问网站
```

---

## 📞 需要帮助？

### OrbStack 官方文档
- 网站：https://orbstack.dev/
- 文档：https://docs.orbstack.dev/
- 常见问题：https://docs.orbstack.dev/faq

### 检查 OrbStack 社区
- GitHub: https://github.com/orbstack/orbstack
- Discord: 搜索 OrbStack 相关讨论

---

## ✅ 验证清单

修改完成后，确认以下几点：

- [ ] OrbStack 已重启
- [ ] `ifconfig` 中没有 172.20.x.x 地址
- [ ] `netstat -rn` 中没有 172.20.x.x 路由
- [ ] 可以 ping 通 172.20.22.101
- [ ] 可以访问 https://sg-git.pwtk.cc/user/login
- [ ] WARP 仍然连接
- [ ] OrbStack 容器正常运行

---

**总结：修改 OrbStack 网络配置为非冲突网段（如 10.20.0.0/16）即可解决问题！**

