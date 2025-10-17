# 🚨 网络冲突问题解决方案

## 问题诊断

### 症状
- WARP 连接成功 ✅
- DNS 解析正常：`sg-git.pwtk.cc` → `172.20.22.101` ✅
- 无法访问网站 ❌
- 同事可以访问 ✅

### 根本原因：IP 地址段冲突

**你的本地网络：**
```
bridge102: 172.20.0.0/16 (本地虚拟机/Docker网络)
路由: 172.20.22.101 → bridge102 (本地)
```

**公司内网：**
```
sg-git.pwtk.cc: 172.20.22.101 (公司内网服务器)
需要路由: 172.20.22.101 → 公司网络
```

**冲突结果：**
- 系统认为 172.20.22.101 在本地 bridge102 网络
- 不会通过 WARP 或其他方式去公司网络查找
- 导致 "Destination Host Unreachable"

---

## 解决方案

### 方案 1：修改本地 Docker/虚拟机网络 ⭐ 推荐

#### 步骤 1: 识别使用 172.20.x.x 的服务

```bash
# 检查虚拟化软件
ps aux | grep -iE "vmware|parallels|virtualbox|colima|orbstack"

# 检查 Docker
docker network ls
docker network inspect bridge102 2>/dev/null || echo "不是 Docker 网络"
```

#### 步骤 2: 修改网络配置

**如果是 Docker Desktop：**
```bash
# 方法 A: 通过 GUI
# 1. 打开 Docker Desktop
# 2. Settings → Resources → Network
# 3. 修改 Default address pools 为:
#    Base: 10.20.0.0/16
#    Size: 24

# 方法 B: 修改配置文件
# ~/.docker/daemon.json
{
  "default-address-pools": [
    {
      "base": "10.20.0.0/16",
      "size": 24
    }
  ]
}

# 重启 Docker
# Docker Desktop → Restart
```

**如果是 OrbStack：**
```bash
# OrbStack 使用独立的网络配置
# 通常不会冲突，检查 OrbStack 设置
```

**如果是 Parallels/VMware：**
```bash
# 在虚拟机设置中修改网络
# Network → Configure → 修改网段
```

#### 步骤 3: 验证修改

```bash
# 1. 检查新的网络配置
ifconfig | grep -A 3 "172\."

# 2. 应该不再看到 172.20.x.x
# 3. 测试访问
curl -I https://sg-git.pwtk.cc/user/login
```

---

### 方案 2：连接公司 VPN

如果公司提供 VPN，连接后应该能正确路由到内网。

```bash
# 1. 连接公司 VPN
# 2. 检查路由
netstat -rn | grep 172.20

# 应该看到通过 VPN 接口的路由
# 3. 测试访问
curl -I https://sg-git.pwtk.cc/user/login
```

---

### 方案 3：临时方案 - 通过 WARP 管理员配置

联系你们的 WARP 管理员（`pw007` 组织），请求：

**选项 A: 排除整个 172.16.0.0/12**
```
请管理员在 Cloudflare Zero Trust 后台：
Settings → WARP Client → Split Tunnels
添加排除：172.16.0.0/12
```

**选项 B: 只包含公司内网段**
```
改为 Include Only 模式
只包含公司需要的 IP 段
```

---

### 方案 4：临时禁用 WARP（不推荐）

仅用于测试：

```bash
# 停止 WARP
sudo /usr/local/bin/warp-control.sh stop

# 测试访问
curl -I https://sg-git.pwtk.cc/user/login

# 如果能访问，确认是 WARP 导致的
# 但这会失去 WARP 的安全保护
```

---

## 验证和诊断

### 检查本地网络冲突

```bash
# 1. 查看所有 172.x.x.x 网络接口
ifconfig | grep -B 2 "inet 172\."

# 2. 查看路由表
netstat -rn | grep "172\."

# 3. 尝试 ping
ping -c 3 172.20.22.101

# 4. 检查 DNS
nslookup sg-git.pwtk.cc
```

### 检查 WARP 配置

```bash
# 查看 Split Tunnel 配置
warp-cli tunnel ip list

# 查看详细设置
warp-cli settings | grep -A 20 "Exclude"
```

### 对比同事的配置

问同事执行以下命令并对比：

```bash
# 1. 网络接口
ifconfig | grep -B 2 "inet 172\."

# 2. WARP 排除列表
warp-cli tunnel ip list

# 3. 路由表
netstat -rn | grep "172\.20"
```

---

## 推荐执行顺序

### 短期（立即）
1. ✅ 停止 WARP，测试是否能访问
2. ✅ 如果能访问，确认是网络冲突问题

### 中期（1小时内）
3. ✅ 识别使用 172.20.x.x 的服务（Docker/VM）
4. ✅ 修改网络配置为其他网段（10.20.x.x）
5. ✅ 重启相关服务
6. ✅ 测试访问

### 长期（如果上述方案不可行）
7. ✅ 联系 IT 部门/WARP 管理员
8. ✅ 请求修改组织的 Split Tunnel 配置
9. ✅ 或提供公司 VPN 访问

---

## 常见问题

### Q: 为什么同事能访问？
A: 可能原因：
- 同事的 Docker 网络不是 172.20.x.x
- 同事连接了公司 VPN
- 同事的 WARP 配置不同（管理员单独配置）
- 同事在公司网络内

### Q: 修改 Docker 网络会影响现有容器吗？
A: 会，需要重建网络和容器。建议：
```bash
# 备份容器数据
docker-compose down
# 修改网络配置
# 重启 Docker
docker-compose up -d
```

### Q: 能否只针对这个 IP 添加路由？
A: 不行，因为本地 bridge102 已经占用了这个网段，系统会优先匹配本地路由。

### Q: WARP 组织策略能覆盖本地配置吗？
A: 能。你看到的配置是 `(network policy)` 管理的，需要管理员修改。

---

## 测试脚本

```bash
#!/bin/bash

echo "=== 网络冲突诊断 ==="
echo ""

echo "1. 检查本地 172.20.x.x 网络"
ifconfig | grep -B 2 "inet 172\.20"
echo ""

echo "2. 检查路由冲突"
netstat -rn | grep "172\.20"
echo ""

echo "3. 测试 DNS 解析"
nslookup sg-git.pwtk.cc
echo ""

echo "4. 测试连通性（禁用 WARP）"
sudo /usr/local/bin/warp-control.sh stop
sleep 2
curl -I --max-time 5 https://sg-git.pwtk.cc/user/login
echo ""

echo "5. 恢复 WARP"
sudo /usr/local/bin/warp-control.sh start
echo ""

echo "诊断完成！"
```

---

## 联系管理员模板

如果需要联系 WARP 管理员：

```
主题：请求修改 WARP Split Tunnel 配置

您好，

我在使用 WARP 时遇到网络冲突问题：

问题：
- 无法访问 sg-git.pwtk.cc (172.20.22.101)
- 本地虚拟机网络使用 172.20.0.0/16
- 与公司内网地址冲突

请求：
请在 Split Tunnel 配置中排除 172.16.0.0/12 网段
或者指导如何解决此冲突

感谢！
```

---

**总结：最佳解决方案是修改本地 Docker/VM 网络，避免使用公司内网的 IP 段。**

