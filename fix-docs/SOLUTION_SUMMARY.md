# ✅ 问题解决总结

## 🎯 问题

无法访问公司内网地址 `https://sg-git.pwtk.cc/user/login` (172.20.22.101)

## 🔍 根本原因

**网络地址冲突：**
- 你的 Docker Compose 项目 `larkcheckin` 使用了 `172.20.0.0/16` 网段
- 公司内网服务器也在 `172.20.22.101`
- 系统认为目标地址在本地 Docker 网络，导致无法路由到真实的公司服务器

## ✅ 解决方案

修改 Docker Compose 网络配置，避免与公司内网冲突。

### 执行的步骤

1. **备份配置文件**
   ```bash
   cp docker-compose.yml docker-compose.yml.backup-20251017
   ```

2. **修改网络段**
   ```bash
   # 在 /Users/leo/github.com/larkCheckin/docker-compose.yml 中
   # 将 subnet: 172.20.0.0/16
   # 改为 subnet: 10.20.0.0/16
   ```

3. **重建容器和网络**
   ```bash
   docker-compose down
   docker-compose up -d
   ```

### 修改前后对比

| 项目 | 修改前 | 修改后 |
|------|--------|--------|
| Docker 网络 | 172.20.0.0/16 | 10.20.0.0/16 |
| 路由冲突 | ❌ 有冲突 | ✅ 无冲突 |
| 访问公司网站 | ❌ 失败 | ✅ 成功 (HTTP 200) |
| 本地服务 | ✅ 正常 | ✅ 正常 |
| WARP 状态 | ✅ 连接 | ✅ 连接 |

## 📋 验证结果

### 1. 网络配置验证 ✅
```bash
$ docker network inspect larkcheckin_lark-network | grep Subnet
"Subnet": "10.20.0.0/16"
```

### 2. 接口检查 ✅
```bash
$ ifconfig | grep "inet 172.20"
# 无输出 - 没有冲突的 172.20.x.x 接口
```

### 3. 路由表检查 ✅
```bash
$ netstat -rn | grep "172.20"
# 无冲突的本地路由
```

### 4. 网站访问测试 ✅
```bash
$ curl -I https://sg-git.pwtk.cc/user/login
HTTP/1.1 200 OK
Server: nginx/1.20.1
...
```

## 🎓 相关问题解释

### Q: 为什么同事能访问但你不能？
A: 同事可能：
- 使用了不同的 Docker 网络段
- 没有本地 Docker 服务冲突
- 直接在公司网络内

### Q: WARP 脚本修复有用吗？
A: 有用！但这次的问题不是 WARP 配置问题，而是本地网络冲突。
- WARP 脚本修复 → 解决了 DNS 配置和连接建立问题 ✅
- Docker 网络修复 → 解决了 IP 地址段冲突问题 ✅

### Q: 以后如何避免类似问题？
A: 
1. Docker 项目使用 `10.x.x.x` 或 `192.168.x.x` (非常见段)
2. 避免使用 `172.16.0.0/12` (172.16-31.x.x) - 常用于企业内网
3. 如果有公司 VPN，询问 IT 部门内网使用的网段

## 📁 修改的文件

```
/Users/leo/github.com/larkCheckin/docker-compose.yml
```

**变更内容：**
```yaml
# 原配置
networks:
  lark-network:
    driver: bridge
    ipam:
      config:
        - subnet: 172.20.0.0/16

# 新配置  
networks:
  lark-network:
    driver: bridge
    ipam:
      config:
        - subnet: 10.20.0.0/16
```

## 🔧 WARP 脚本修复总结

在解决网络冲突之前，我们还完成了 WARP 脚本的关键修复：

### v1.1.1 修复内容
1. **PATH 问题修复** - 解决 sudo 环境下 warp-cli 找不到的问题
2. **错误处理改进** - 捕获并显示 warp-cli 命令的实际错误
3. **连接管理增强** - 确保真正建立 WARP 连接，而不只是启动 daemon

### 验证
- ✅ 脚本语法检查通过
- ✅ PATH 修复生效
- ✅ warp-cli 在 sudo 环境下可用
- ✅ 错误处理正常工作
- ✅ WARP 连接正常建立

## 🎯 最终状态

### 系统状态
- ✅ WARP 连接：Connected
- ✅ DNS 配置：Cloudflare DNS (162.159.36.1)
- ✅ Docker 网络：10.20.0.0/16 (无冲突)
- ✅ 公司网站访问：正常 (HTTP 200)
- ✅ 本地服务：正常运行

### 容器状态
```bash
$ docker ps
larkcheckin-nginx-1      - Running (80, 443)
larkcheckin-frontend-1   - Running (3000)
larkcheckin-backend-1    - Running (8000)
larkcheckin-redis-1      - Running (6379)
larkcheckin-portainer-1  - Running (9000)
```

## 💡 经验教训

1. **IP 地址段规划很重要**
   - 企业内网通常使用 `10.x.x.x` 或 `172.16-31.x.x`
   - 本地开发环境应避免使用这些段

2. **问题诊断需要全面**
   - 不只是看 WARP 配置
   - 还要检查本地网络冲突
   - 路由表是关键诊断工具

3. **文档的价值**
   - 详细的诊断文档帮助快速定位问题
   - 解决方案文档方便以后参考

## 📚 相关文档

- [WARP_FIX.md](./WARP_FIX.md) - WARP 连接问题修复
- [CRITICAL_PATCH.md](./CRITICAL_PATCH.md) - PATH 和错误处理修复
- [NETWORK_CONFLICT_FIX.md](./NETWORK_CONFLICT_FIX.md) - 网络冲突诊断
- [FIX_ORBSTACK_NETWORK.md](./FIX_ORBSTACK_NETWORK.md) - OrbStack 网络配置
- [VERIFY.md](./VERIFY.md) - 验证指南

---

**问题解决时间**: 2025-10-17  
**涉及组件**: WARP, Docker Compose, OrbStack, 网络路由  
**最终状态**: ✅ 完全解决  
**关键发现**: Docker 网络地址冲突，而非 WARP 配置问题

