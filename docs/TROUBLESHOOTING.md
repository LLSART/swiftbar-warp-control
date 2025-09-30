# 故障排除指南 | Troubleshooting Guide

本文档包含 SwiftBar WARP Control 的常见问题和解决方案。

This document contains common issues and solutions for SwiftBar WARP Control.

---

## 🚨 常见问题 | Common Issues

### 1. 安装相关问题 | Installation Issues

#### 问题：安装脚本运行失败
**Problem: Installation script fails**

**可能原因 | Possible Causes:**
- 网络连接问题
- 权限不足
- macOS 版本不兼容

**解决方案 | Solutions:**
```bash
# 检查网络连接
curl -I https://github.com

# 检查 macOS 版本
sw_vers -productVersion

# 确保有管理员权限
sudo -v
```

#### 问题：Homebrew 安装失败
**Problem: Homebrew installation fails**

**解决方案 | Solution:**
```bash
# 手动安装 Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 对于 Apple Silicon Mac，添加到 PATH
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
source ~/.zprofile
```

### 2. SwiftBar 相关问题 | SwiftBar Issues

#### 问题：菜单栏不显示 WARP 图标
**Problem: WARP icon doesn't appear in menu bar**

**检查步骤 | Check Steps:**
1. 确认 SwiftBar 正在运行
   ```bash
   ps aux | grep SwiftBar
   ```

2. 检查插件目录设置
   - 打开 SwiftBar 偏好设置
   - 确认插件目录包含 `~/swiftbar`

3. 刷新插件
   - 在 SwiftBar 菜单中选择 "Refresh Plugins"

#### 问题：SwiftBar 插件显示错误
**Problem: SwiftBar plugin shows error**

**检查脚本权限 | Check Script Permissions:**
```bash
# 检查文件是否存在
ls -la ~/swiftbar/warp.5s.sh

# 确保脚本可执行
chmod +x ~/swiftbar/warp.5s.sh

# 检查控制脚本
ls -la /usr/local/bin/warp-control.sh
```

### 3. WARP 控制问题 | WARP Control Issues

#### 问题：WARP 无法启动或停止
**Problem: WARP won't start or stop**

**诊断步骤 | Diagnostic Steps:**
```bash
# 检查 WARP 是否已安装
ls -la "/Applications/Cloudflare WARP.app"

# 检查 daemon 文件
ls -la "/Library/LaunchDaemons/com.cloudflare.1dot1dot1dot1.macos.warp.daemon.plist"

# 手动测试控制脚本
sudo /usr/local/bin/warp-control.sh status
```

#### 问题：权限被拒绝错误
**Problem: Permission denied errors**

**解决方案 | Solutions:**
```bash
# 检查 sudoers 配置
sudo visudo -c -f /etc/sudoers.d/warp-toggle

# 验证配置内容
sudo cat /etc/sudoers.d/warp-toggle

# 如果配置错误，重新安装
bash install.sh
```

### 4. 系统相关问题 | System Issues

#### 问题：macOS 版本不兼容
**Problem: macOS version incompatibility**

**最低要求 | Minimum Requirements:**
- macOS 10.15 (Catalina) 或更高版本

**检查版本 | Check Version:**
```bash
sw_vers -productVersion
```

#### 问题：ARM64/Intel 架构问题
**Problem: ARM64/Intel architecture issues**

**解决方案 | Solution:**
```bash
# 检查架构
uname -m

# 对于 Apple Silicon (arm64)
if [[ $(uname -m) == "arm64" ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# 对于 Intel (x86_64)
if [[ $(uname -m) == "x86_64" ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
fi
```

---

## 🔧 高级故障排除 | Advanced Troubleshooting

### 完全重置安装 | Complete Reset Installation

如果遇到严重问题，可以完全重置：
If you encounter serious issues, you can completely reset:

```bash
# 1. 完全卸载
bash uninstall.sh

# 2. 手动清理残留文件
sudo rm -f /usr/local/bin/warp-control.sh
sudo rm -f /etc/sudoers.d/warp-toggle
rm -f ~/swiftbar/warp.5s.sh

# 3. 重新安装
bash install.sh
```

### 日志收集 | Log Collection

收集日志以便报告问题：
Collect logs for issue reporting:

```bash
# 系统信息
echo "=== System Info ===" > debug.log
sw_vers >> debug.log
uname -m >> debug.log

# WARP 状态
echo -e "\n=== WARP Status ===" >> debug.log
ps aux | grep CloudflareWARP >> debug.log

# 文件权限
echo -e "\n=== File Permissions ===" >> debug.log
ls -la /usr/local/bin/warp-control.sh >> debug.log
ls -la /etc/sudoers.d/warp-toggle >> debug.log
ls -la ~/swiftbar/warp.5s.sh >> debug.log

# SwiftBar 进程
echo -e "\n=== SwiftBar Process ===" >> debug.log
ps aux | grep SwiftBar >> debug.log
```

### 手动测试各组件 | Manual Component Testing

```bash
# 1. 测试 WARP 控制脚本
sudo /usr/local/bin/warp-control.sh status

# 2. 测试 sudo 配置
sudo -n /usr/local/bin/warp-control.sh status

# 3. 测试 SwiftBar 插件
bash ~/swiftbar/warp.5s.sh

# 4. 测试 WARP daemon
sudo launchctl list | grep cloudflare
```

---

## 📞 获取帮助 | Getting Help

如果以上解决方案都不能解决您的问题：
If none of the above solutions work:

### 报告 Bug | Report a Bug
1. 收集日志信息（参见上面的日志收集部分）
2. 访问 [GitHub Issues](https://github.com/yourusername/swiftbar-warp-control/issues)
3. 使用 Bug 报告模板创建新 issue
4. 附上收集的日志信息

### 寻求帮助 | Seek Help
- 📚 **文档**: [项目 Wiki](https://github.com/yourusername/swiftbar-warp-control/wiki)
- 💬 **讨论**: [GitHub Discussions](https://github.com/yourusername/swiftbar-warp-control/discussions)
- 🐛 **问题反馈**: [GitHub Issues](https://github.com/yourusername/swiftbar-warp-control/issues)

### 社区支持 | Community Support
- 在创建新 issue 前，请搜索已有的相关问题
- 提供详细的系统信息和错误日志
- 描述重现问题的具体步骤

---

## 🔄 常见解决方案速查 | Quick Solutions Reference

| 问题 Problem | 解决方案 Solution |
|-------------|------------------|
| 安装失败 | `bash install.sh` |
| 图标不显示 | 重启 SwiftBar |
| 权限错误 | 检查 sudoers 配置 |
| WARP 无响应 | 重启 WARP 应用 |
| 脚本错误 | 重新安装插件 |

---

**提示：大多数问题可以通过重新运行安装脚本解决**
**Tip: Most issues can be resolved by re-running the installation script**