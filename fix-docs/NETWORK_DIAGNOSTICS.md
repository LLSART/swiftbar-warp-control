# 🔍 网络冲突自动诊断功能

## 新增功能

为了避免以后遇到类似的网络冲突问题，我们添加了自动诊断功能！

### ✨ 功能特性

1. **自动检测本地网络冲突**
   - 检测使用企业网段 (172.16-31.x.x) 的本地接口
   - 检测 Docker 网络配置
   - 检测路由表冲突

2. **智能提示**
   - 发现冲突时显示详细警告
   - 提供具体的修复建议
   - 指向相关文档

3. **两种使用方式**
   - 集成在 `warp-control.sh status` 命令中
   - 独立的诊断脚本 `diagnose-network.sh`

---

## 使用方法

### 方法 1：通过 warp-control.sh（推荐）

```bash
# 查看 WARP 状态时自动检查网络冲突
sudo /usr/local/bin/warp-control.sh status
```

**输出示例（有冲突时）：**
```
=== WARP Daemon Status ===
✅ Daemon: Running

=== WARP Connection Status ===
warp-cli path: /usr/local/bin/warp-cli
Status update: Connected

=== WARP Settings ===
...

=== Network Conflict Check ===
⚠️  发现 Docker 网络使用企业网段：
172.20.0.0/16

💡 建议修改 Docker 网络配置：
   - 编辑 docker-compose.yml
   - 将 subnet 改为 10.x.x.x 网段
   - 然后执行: docker-compose down && docker-compose up -d
```

**输出示例（无冲突时）：**
```
=== Network Conflict Check ===
✅ 未发现网络冲突
```

### 方法 2：独立诊断脚本

```bash
# 运行完整的网络诊断
cd /Users/leo/github.com/swiftbar-warp-control
bash diagnose-network.sh
```

**诊断内容包括：**
1. 本地网络接口检查
2. Docker 网络配置检查
3. 路由表分析
4. WARP 状态检查
5. DNS 配置验证
6. 常见冲突场景检测

---

## 诊断脚本功能详解

### [1/6] 检查本地网络接口
```
检查所有使用 172.16-31.x.x 和 10.x.x.x 的网络接口
显示接口名称和 IP 地址
```

### [2/6] 检查 Docker 网络配置
```
列出所有 Docker 网络
检测使用企业网段的网络
提供修复建议
```

### [3/6] 检查路由表
```
查找可能冲突的路由条目
识别指向本地接口的企业网段路由
```

### [4/6] 检查 WARP 状态
```
验证 WARP 连接状态
显示 Split Tunnel 配置
检查 WARP 设置
```

### [5/6] 检查 DNS 配置
```
验证是否使用 Cloudflare DNS
显示当前 DNS 服务器
```

### [6/6] 检查常见冲突场景
```
检测虚拟化软件（OrbStack/Docker）
检测其他 VPN
检测多网络接口冲突
```

---

## 实际案例

### 案例 1：Docker 网络冲突

**诊断输出：**
```bash
$ bash diagnose-network.sh

[2/6] 检查 Docker 网络配置
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Docker 网络列表：
NAME                       DRIVER    SCOPE
bridge                     bridge    local
larkcheckin_lark-network   bridge    local

⚠️  网络 'larkcheckin_lark-network' 使用企业网段: 172.20.0.0/16

ℹ️  建议修改 docker-compose.yml 中的网络配置：
  networks:
    your-network:
      driver: bridge
      ipam:
        config:
          - subnet: 10.20.0.0/16  # 修改为此
```

**解决步骤：**
```bash
# 1. 编辑 docker-compose.yml
vim docker-compose.yml

# 2. 修改网络配置
# 将 subnet: 172.20.0.0/16 改为 subnet: 10.20.0.0/16

# 3. 重建网络
docker-compose down
docker-compose up -d

# 4. 验证修复
bash diagnose-network.sh
```

### 案例 2：OrbStack 网络冲突

**诊断输出：**
```bash
[1/6] 检查本地网络接口
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⚠️  发现使用企业常用网段 (172.16-31.x.x)：
  • 172.20.0.0 (bridge102)

ℹ️  这些网段常被企业内网使用，可能导致访问冲突

[6/6] 检查常见冲突场景
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✓ 检测到虚拟化软件运行
⚠️  虚拟机网络可能使用冲突网段
```

**解决步骤：**
参考 [FIX_ORBSTACK_NETWORK.md](./FIX_ORBSTACK_NETWORK.md)

---

## 集成到工作流

### 定期检查

建议在以下情况运行诊断：

1. **首次安装 WARP 后**
   ```bash
   bash diagnose-network.sh
   ```

2. **无法访问公司内网时**
   ```bash
   sudo /usr/local/bin/warp-control.sh status
   ```

3. **修改 Docker/VM 配置后**
   ```bash
   bash diagnose-network.sh
   ```

4. **遇到网络问题时**
   ```bash
   # 完整诊断
   bash diagnose-network.sh > network-report.txt
   # 发送报告给 IT 部门
   ```

### 添加到 crontab（可选）

```bash
# 每周一早上 9 点检查
0 9 * * 1 /Users/leo/github.com/swiftbar-warp-control/diagnose-network.sh >> /tmp/warp-diagnostics.log 2>&1
```

---

## 技术实现

### check_network_conflicts() 函数

```bash
# 在 warp-control.sh 中
check_network_conflicts() {
    # 检查 172.16-31.x.x 接口
    local local_172_networks=$(ifconfig | grep "inet 172\.[1-3][0-9]\.")
    
    # 检查 Docker 网络
    if command -v docker; then
        local docker_172_networks=$(docker network inspect ...)
    fi
    
    # 显示警告和建议
    if [[ 发现冲突 ]]; then
        print_warning "..."
        echo "建议: ..."
    fi
}
```

### diagnose-network.sh 脚本

```bash
# 6 个检查步骤
check_local_networks()      # 本地接口
check_docker_networks()     # Docker 配置
check_routes()              # 路由表
check_warp_status()         # WARP 状态
check_dns()                 # DNS 配置
check_common_scenarios()    # 常见场景

# 生成诊断报告
generate_report()
```

---

## 常见问题

### Q: 诊断脚本会修改配置吗？
A: 不会。诊断脚本是只读的，只会检查和报告，不会修改任何配置。

### Q: 诊断需要 sudo 权限吗？
A: 大部分功能不需要。但如果要通过 `warp-control.sh status` 使用，需要 sudo。

### Q: 误报怎么办？
A: 诊断工具会检测所有 172.16-31.x.x 网段。如果你确定某个网络不冲突，可以忽略该警告。

### Q: 可以自动修复吗？
A: 目前不支持自动修复，需要手动修改配置文件。这样更安全，避免意外修改重要配置。

### Q: 检测到冲突但网络正常？
A: 如果你的本地网络和公司内网使用不同的子网（虽然在同一大范围内），可能不会冲突。诊断只是提醒潜在风险。

---

## 输出示例

### 完整诊断报告示例

```bash
$ bash diagnose-network.sh

╔══════════════════════════════════════════════════════════════╗
║          WARP 网络冲突诊断工具                              ║
╚══════════════════════════════════════════════════════════════╝

[1/6] 检查本地网络接口
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
发现 10.x.x.x 网段：
  • 10.20.0.1 (bridge100)

[2/6] 检查 Docker 网络配置
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Docker 网络列表：
NAME              DRIVER    SCOPE
bridge            bridge    local
larkcheckin_lark  bridge    local

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
  nameserver[0] : 162.159.36.1

[6/6] 检查常见冲突场景
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✓ 检测到虚拟化软件运行
✅ 未发现常见冲突场景

╔══════════════════════════════════════════════════════════════╗
║                        诊断总结                              ║
╚══════════════════════════════════════════════════════════════╝

✅ 网络配置良好，未发现冲突

如果仍有连接问题，请：
  1. 运行 'sudo /usr/local/bin/warp-control.sh status'
  2. 检查 WARP 应用的诊断功能
  3. 查看 SOLUTION_SUMMARY.md
```

---

## 相关文档

- [SOLUTION_SUMMARY.md](./SOLUTION_SUMMARY.md) - 完整解决方案
- [NETWORK_CONFLICT_FIX.md](./NETWORK_CONFLICT_FIX.md) - 网络冲突修复
- [FIX_ORBSTACK_NETWORK.md](./FIX_ORBSTACK_NETWORK.md) - OrbStack 配置
- [VERIFY.md](./VERIFY.md) - 验证指南

---

**总结：现在脚本可以自动检测并提示网络冲突，避免以后遇到类似问题！** 🎉

