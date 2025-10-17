# SwiftBar WARP Control

一键无密码控制 Cloudflare WARP - macOS 菜单栏集成

<div align="center">

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![macOS](https://img.shields.io/badge/macOS-10.15+-blue.svg)](https://www.apple.com/macos)
[![Version](https://img.shields.io/badge/version-1.1.2-green.svg)](https://github.com/leeguooooo/swiftbar-warp-control)

</div>

## ✨ 特性

- 🎯 **无密码控制** - 通过 SwiftBar 菜单一键启停 WARP，无需重复输入密码
- 🚀 **一键安装** - 自动安装所有依赖，包括 SwiftBar 和 sudo 配置
- 🔒 **安全设计** - 最小权限原则，只对特定脚本免密
- 🎨 **优雅界面** - 菜单栏图标显示实时状态（🟢/🔴）
- 🔍 **网络诊断** - v1.1.2 新增自动网络冲突检测
- 📱 **智能提示** - 发现问题立即给出修复建议

## 🆕 v1.1.2 新功能

### 自动网络冲突检测
- ✅ 检测本地网络是否与企业内网冲突
- ✅ 检测 Docker 网络配置问题
- ✅ 提供详细的修复建议
- ✅ 独立诊断工具

**使用方法：**
```bash
# 集成检测
sudo /usr/local/bin/warp-control.sh status

# 完整诊断
bash diagnose-network.sh
```

详见：[新功能快速开始](./fix-docs/QUICK_START_NEW_FEATURES.md)

## 📦 安装

### 方法 1：一键安装（推荐）

```bash
curl -fsSL https://raw.githubusercontent.com/leeguooooo/swiftbar-warp-control/main/install.sh | bash
```

### 方法 2：Git 克隆安装

```bash
git clone https://github.com/leeguooooo/swiftbar-warp-control.git
cd swiftbar-warp-control
bash install.sh
```

安装脚本会自动：
1. ✅ 检查系统要求
2. ✅ 安装 Homebrew（如果需要）
3. ✅ 安装 SwiftBar
4. ✅ 配置 sudo 免密
5. ✅ 安装控制脚本
6. ✅ 启动 SwiftBar

## 🎯 使用

### SwiftBar 菜单控制

点击菜单栏的 WARP 图标：
- 🟢 **已连接** - 显示绿色，点击可停止或重启
- 🔴 **已断开** - 显示红色，点击可启动

### 命令行控制

```bash
# 启动 WARP
sudo /usr/local/bin/warp-control.sh start

# 停止 WARP
sudo /usr/local/bin/warp-control.sh stop

# 查看状态（含网络冲突检测）
sudo /usr/local/bin/warp-control.sh status

# 切换状态
sudo /usr/local/bin/warp-control.sh toggle
```

### 网络诊断

```bash
# 完整网络诊断
bash diagnose-network.sh

# 快速测试
bash test-fix.sh
```

## 📚 文档

### 核心文档
- **[CHANGELOG.md](./CHANGELOG.md)** - 版本更新历史
- **[QUICK_REFERENCE.md](./QUICK_REFERENCE.md)** - 快速命令参考
- **[QUICK_UPDATE.md](./QUICK_UPDATE.md)** - 快速更新指南
- **[VERIFY.md](./VERIFY.md)** - 功能验证指南

### 修复文档
详细的问题修复和功能说明文档已整理到 [fix-docs/](./fix-docs/) 目录：

- [新功能快速开始](./fix-docs/QUICK_START_NEW_FEATURES.md) ⭐
- [完整修复总结](./fix-docs/FINAL_SUMMARY.md)
- [网络冲突修复](./fix-docs/NETWORK_CONFLICT_FIX.md)
- [更多文档...](./fix-docs/)

## 🔧 工具脚本

| 脚本 | 用途 |
|------|------|
| `install.sh` | 一键安装 |
| `uninstall.sh` | 完全卸载 |
| `update.sh` | 更新到最新版本 |
| `diagnose-network.sh` | 网络诊断工具 |
| `test-fix.sh` | 自动化测试 |

## 🔄 更新

### 更新到 v1.1.2

```bash
cd swiftbar-warp-control
git pull
bash update.sh
```

或手动更新：
```bash
sudo cp scripts/warp-control.sh /usr/local/bin/warp-control.sh
```

## 🗑️ 卸载

```bash
cd swiftbar-warp-control
bash uninstall.sh
```

卸载脚本会移除：
- ✅ 控制脚本
- ✅ sudo 配置
- ✅ SwiftBar 插件
- ⚠️ 不会卸载 SwiftBar 本身

## 💡 常见问题

### Q: 无法访问公司内网服务？
A: 运行网络诊断工具：
```bash
bash diagnose-network.sh
```
如果检测到网络冲突，按提示修复。

### Q: SwiftBar 菜单没有反应？
A: 检查 sudo 配置：
```bash
sudo -n /usr/local/bin/warp-control.sh status
```
如果要求密码，重新运行 `bash install.sh`。

### Q: DNS 没有配置？
A: 确认 WARP 真正连接：
```bash
warp-cli status
# 应该显示: Connected
```

更多问题请查看 [fix-docs/](./fix-docs/) 目录中的详细文档。

## 🤝 贡献

欢迎贡献！请查看 [CONTRIBUTING.md](./CONTRIBUTING.md)。

## 📄 许可证

MIT License - 详见 [LICENSE](./LICENSE)

## 🙏 致谢

- [SwiftBar](https://github.com/swiftbar/SwiftBar) - macOS 菜单栏工具
- [Cloudflare WARP](https://1.1.1.1/) - 网络安全服务

## 📞 支持

- 🐛 [报告问题](https://github.com/leeguooooo/swiftbar-warp-control/issues)
- 💬 [讨论区](https://github.com/leeguooooo/swiftbar-warp-control/discussions)
- 📖 [完整文档](./fix-docs/)

---

<div align="center">
<b>让 WARP 控制更简单 🚀</b>
</div>
