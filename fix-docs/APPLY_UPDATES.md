# 🔄 应用 v1.1.2 更新

## 更新内容

添加了**网络冲突自动检测功能**，现在脚本可以：
- ✅ 自动检测本地网络冲突
- ✅ 检测 Docker 网络配置问题
- ✅ 提供详细的修复建议
- ✅ 独立诊断工具

---

## 快速应用更新

### 一键命令

```bash
cd /Users/leo/github.com/swiftbar-warp-control
sudo cp scripts/warp-control.sh /usr/local/bin/warp-control.sh
sudo chmod 755 /usr/local/bin/warp-control.sh
```

### 验证更新

```bash
# 测试网络冲突检测功能
sudo /usr/local/bin/warp-control.sh status

# 应该看到新增的 "=== Network Conflict Check ===" 部分
```

---

## 使用新功能

### 方法 1: 集成检测（推荐）

```bash
# 查看状态时自动检查网络冲突
sudo /usr/local/bin/warp-control.sh status
```

**输出示例：**
```
=== WARP Connection Status ===
...

=== Network Conflict Check ===
✅ 未发现网络冲突
```

### 方法 2: 独立诊断工具

```bash
# 运行完整诊断
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

## 对比测试

### 修改前
```bash
$ sudo /usr/local/bin/warp-control.sh status

=== WARP Daemon Status ===
✅ Daemon: Running

=== WARP Connection Status ===
warp-cli path: /usr/local/bin/warp-cli
Status update: Connected

=== WARP Settings ===
...
```

### 修改后（新增部分）
```bash
$ sudo /usr/local/bin/warp-control.sh status

=== WARP Daemon Status ===
✅ Daemon: Running

=== WARP Connection Status ===
warp-cli path: /usr/local/bin/warp-cli
Status update: Connected

=== WARP Settings ===
...

=== Network Conflict Check ===           ← 🆕 新增
✅ 未发现网络冲突                         ← 🆕 新增
```

### 如果有冲突时
```bash
=== Network Conflict Check ===
⚠️  发现 Docker 网络使用企业网段：
172.20.0.0/16

💡 建议修改 Docker 网络配置：
   - 编辑 docker-compose.yml
   - 将 subnet 改为 10.x.x.x 网段
   - 然后执行: docker-compose down && docker-compose up -d
```

---

## 新文件说明

### diagnose-network.sh
```bash
# 完整的网络诊断工具
bash diagnose-network.sh
```

**功能特性：**
- 6 个诊断步骤
- 彩色输出
- 智能报告生成
- 详细的修复建议

### NETWORK_DIAGNOSTICS.md
```
诊断功能的完整说明文档
- 使用方法
- 输出说明
- 案例分析
- 常见问题
```

---

## 完整更新步骤

### 步骤 1: 应用脚本更新
```bash
cd /Users/leo/github.com/swiftbar-warp-control
sudo cp scripts/warp-control.sh /usr/local/bin/warp-control.sh
sudo chmod 755 /usr/local/bin/warp-control.sh
```

### 步骤 2: 验证语法
```bash
bash -n /usr/local/bin/warp-control.sh
echo $?  # 应该输出 0
```

### 步骤 3: 测试功能
```bash
# 测试 status 命令
sudo /usr/local/bin/warp-control.sh status | grep "Network Conflict"

# 测试独立诊断
bash diagnose-network.sh
```

### 步骤 4: 重启 SwiftBar（可选）
```bash
pkill -f SwiftBar && sleep 1 && open -a SwiftBar
```

---

## 预期效果

### ✅ 正常情况（无冲突）
```
=== Network Conflict Check ===
✅ 未发现网络冲突
```

### ⚠️ 发现冲突时
```
=== Network Conflict Check ===
⚠️  发现本地使用企业网段 (172.16-31.x.x)：
172.20.0.0

💡 如果无法访问公司内网服务，可能是网络地址冲突
   建议：
   1. 检查是否有 Docker/VM 使用相同网段
   2. 修改本地网络配置避免冲突
   3. 参考: NETWORK_CONFLICT_FIX.md
```

---

## 常见问题

### Q: 更新会影响现有功能吗？
A: 不会。只是在 `status` 命令末尾添加了冲突检测，不影响其他功能。

### Q: 如果不想看到冲突检测怎么办？
A: 可以用 `grep` 过滤：
```bash
sudo /usr/local/bin/warp-control.sh status | grep -v "Network Conflict" -A 0
```

### Q: 诊断脚本会修改配置吗？
A: 不会。所有诊断工具都是只读的，只检查不修改。

### Q: 更新失败怎么办？
A: 检查语法：
```bash
bash -n scripts/warp-control.sh
# 如果有错误会显示具体行号
```

---

## 版本信息

| 版本 | 功能 | 文件 |
|------|------|------|
| v1.0.0 | 基础功能 | 只启动 daemon |
| v1.1.0 | 添加连接管理 | 添加 warp-cli connect/disconnect |
| v1.1.1 | PATH + 错误处理 | 修复 sudo 环境问题 |
| v1.1.2 | 网络冲突检测 | 添加自动诊断功能 ⭐ |

---

## 文件清单

### 更新的文件
- ✅ `scripts/warp-control.sh` - 添加 check_network_conflicts()

### 新增的文件
- 🆕 `diagnose-network.sh` - 独立诊断工具
- 🆕 `NETWORK_DIAGNOSTICS.md` - 诊断功能说明
- 🆕 `FINAL_SUMMARY.md` - 最终总结
- 🆕 `APPLY_UPDATES.md` - 本文件

---

## 快速命令参考

```bash
# 应用更新
sudo cp scripts/warp-control.sh /usr/local/bin/warp-control.sh

# 测试集成检测
sudo /usr/local/bin/warp-control.sh status

# 运行独立诊断
bash diagnose-network.sh

# 查看文档
cat NETWORK_DIAGNOSTICS.md
```

---

**现在就应用更新，让脚本能自动检测网络冲突！** 🚀

