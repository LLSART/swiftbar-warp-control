# 安全说明 | Security Guide

SwiftBar WARP Control 的安全设计和最佳实践。

Security design and best practices for SwiftBar WARP Control.

---

## 🔒 安全原则 | Security Principles

### 最小权限原则 | Principle of Least Privilege
本工具遵循最小权限原则，仅请求完成功能所需的最低权限：

This tool follows the principle of least privilege, only requesting the minimum permissions needed:

- ✅ **仅允许**: 执行 `/usr/local/bin/warp-control.sh`
- ✅ **Only allows**: Execution of `/usr/local/bin/warp-control.sh`
- ❌ **不允许**: 其他任何 sudo 命令
- ❌ **Does not allow**: Any other sudo commands

### 用户隔离 | User Isolation
权限配置是用户特定的：

Permission configuration is user-specific:

```bash
# sudoers 配置只影响安装用户
username ALL=(ALL) NOPASSWD: /usr/local/bin/warp-control.sh
```

---

## 🛡️ 安全机制 | Security Mechanisms

### 1. Sudo 配置安全 | Sudo Configuration Security

#### 配置文件位置 | Configuration File Location
```
/etc/sudoers.d/warp-toggle
```

#### 权限设置 | Permission Settings
```bash
# 文件权限: 440 (只读，仅 root 和 wheel 组)
sudo chmod 440 /etc/sudoers.d/warp-toggle

# 文件所有者: root:wheel
sudo chown root:wheel /etc/sudoers.d/warp-toggle
```

#### 语法验证 | Syntax Validation
```bash
# 安装时自动验证语法
sudo visudo -c -f /etc/sudoers.d/warp-toggle
```

### 2. 脚本安全 | Script Security

#### 控制脚本保护 | Control Script Protection
```bash
# 位置: /usr/local/bin/warp-control.sh
# 权限: 755 (所有人可读可执行，仅 root 可写)
# 所有者: root:wheel
```

#### 输入验证 | Input Validation
控制脚本包含严格的输入验证：

The control script includes strict input validation:

```bash
# 只接受预定义的命令
case "$1" in
    start|stop|status|toggle)
        # 执行相应操作
        ;;
    *)
        # 拒绝未知命令
        show_usage
        exit 1
        ;;
esac
```

### 3. 文件完整性 | File Integrity

#### 安装时检查 | Installation Checks
- 验证所有脚本的完整性
- 确认 WARP 应用程序的存在
- 检查系统要求

#### 运行时检查 | Runtime Checks
- 验证目标文件存在
- 检查 WARP daemon 状态
- 确认权限配置正确

---

## ⚠️ 安全注意事项 | Security Considerations

### 1. 权限范围 | Permission Scope

**允许的操作 | Allowed Operations:**
- 启动/停止 Cloudflare WARP
- 查看 WARP 状态
- 控制 WARP daemon

**不允许的操作 | NOT Allowed Operations:**
- 修改系统文件
- 访问其他用户数据
- 执行任意系统命令
- 修改网络配置（除 WARP 外）

### 2. 潜在风险 | Potential Risks

#### 低风险 | Low Risk
- ✅ 脚本只能控制 WARP
- ✅ 权限限制在单个用户
- ✅ 无网络配置修改权限

#### 需要注意 | Requires Attention
- ⚠️ 管理员权限用于系统 daemon 控制
- ⚠️ sudoers 配置文件的修改

### 3. 缓解措施 | Mitigation Measures

- **代码审查**: 所有代码开源可审查
- **最小化安装**: 只安装必要组件
- **清理卸载**: 提供完整的卸载机制
- **权限检查**: 安装时验证所有权限

---

## 🔍 安全审计 | Security Audit

### 检查当前配置 | Check Current Configuration

```bash
# 1. 检查 sudoers 配置
sudo cat /etc/sudoers.d/warp-toggle

# 2. 验证配置语法
sudo visudo -c -f /etc/sudoers.d/warp-toggle

# 3. 检查控制脚本权限
ls -la /usr/local/bin/warp-control.sh

# 4. 测试权限范围
sudo -n /usr/local/bin/warp-control.sh status

# 5. 尝试未授权操作（应该失败）
sudo -n ls /etc/sudoers.d/
```

### 验证文件完整性 | Verify File Integrity

```bash
# 检查所有相关文件
echo "=== Security Audit ===" > security-audit.log

echo -e "\n1. Sudoers Configuration:" >> security-audit.log
ls -la /etc/sudoers.d/warp-toggle >> security-audit.log

echo -e "\n2. Control Script:" >> security-audit.log
ls -la /usr/local/bin/warp-control.sh >> security-audit.log

echo -e "\n3. SwiftBar Plugin:" >> security-audit.log
ls -la ~/swiftbar/warp.5s.sh >> security-audit.log

echo -e "\n4. Test Permissions:" >> security-audit.log
sudo -n /usr/local/bin/warp-control.sh status >> security-audit.log 2>&1
```

---

## 🚨 安全事件响应 | Security Incident Response

### 发现安全问题时 | When Security Issues Are Found

1. **立即停止使用 | Stop Using Immediately**
   ```bash
   bash uninstall.sh
   ```

2. **报告问题 | Report Issue**
   - 发送邮件到安全团队（如果有）
   - 在 GitHub 创建私密报告
   - 提供详细的问题描述

3. **临时缓解 | Temporary Mitigation**
   ```bash
   # 删除 sudo 配置
   sudo rm -f /etc/sudoers.d/warp-toggle
   
   # 删除控制脚本
   sudo rm -f /usr/local/bin/warp-control.sh
   ```

### 安全更新流程 | Security Update Process

1. **检查更新**: 定期检查项目更新
2. **验证来源**: 确认更新来自官方源
3. **备份配置**: 更新前备份重要配置
4. **测试验证**: 更新后验证功能正常

---

## 📋 安全检查清单 | Security Checklist

### 安装前检查 | Pre-installation Checks
- [ ] 确认从官方源下载
- [ ] 检查文件完整性
- [ ] 阅读所有脚本内容
- [ ] 了解将被修改的系统文件

### 安装后验证 | Post-installation Verification
- [ ] 验证 sudoers 配置正确
- [ ] 确认脚本权限适当
- [ ] 测试功能正常工作
- [ ] 验证无意外权限授予

### 定期审计 | Regular Audits
- [ ] 检查 sudoers 配置未被篡改
- [ ] 验证控制脚本完整性
- [ ] 监控系统日志异常
- [ ] 检查是否有安全更新

---

## 🔗 安全资源 | Security Resources

### 相关文档 | Related Documentation
- [macOS 安全指南](https://support.apple.com/guide/security/)
- [sudo 手册](https://www.sudo.ws/man.html)
- [SwiftBar 安全文档](https://github.com/swiftbar/SwiftBar/blob/main/SECURITY.md)

### 报告安全问题 | Report Security Issues
- **GitHub Issues**: [安全问题模板](https://github.com/yourusername/swiftbar-warp-control/issues/new?template=security.md)
- **邮件**: security@yourproject.com
- **加密通信**: 使用 GPG 公钥加密敏感信息

---

## ✅ 最佳实践 | Best Practices

1. **定期更新**: 保持工具为最新版本
2. **最小安装**: 只在需要时安装
3. **权限审查**: 定期检查授予的权限
4. **安全意识**: 了解工具的安全影响
5. **备份重要配置**: 在修改前创建备份

---

**记住：安全是一个持续的过程，不是一次性的设置**
**Remember: Security is an ongoing process, not a one-time setup**