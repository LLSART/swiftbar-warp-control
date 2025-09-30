# 贡献指南 | Contributing Guide

感谢您对 SwiftBar WARP Control 项目的兴趣！我们欢迎各种形式的贡献。

Thank you for your interest in contributing to SwiftBar WARP Control! We welcome all forms of contributions.

---

## 🤝 如何贡献 | How to Contribute

### 报告问题 | Reporting Issues
- 使用 [GitHub Issues](https://github.com/yourusername/swiftbar-warp-control/issues) 报告 bug
- 搜索现有 issues 避免重复报告
- 提供详细的系统信息和重现步骤

### 建议功能 | Suggesting Features
- 使用 [GitHub Discussions](https://github.com/yourusername/swiftbar-warp-control/discussions) 讨论新功能
- 解释功能的用途和价值
- 考虑安全性和兼容性影响

### 提交代码 | Submitting Code
1. **Fork** 项目仓库
2. 创建 **feature branch**: `git checkout -b feature/amazing-feature`
3. **提交** 您的更改: `git commit -m 'Add amazing feature'`
4. **推送** 到分支: `git push origin feature/amazing-feature`
5. 创建 **Pull Request**

---

## 🛠️ 开发环境设置 | Development Setup

### 系统要求 | System Requirements
- macOS 10.15+ 
- Git
- Bash 4.0+
- 可选：Homebrew, SwiftBar (用于测试)

### 设置步骤 | Setup Steps
```bash
# 1. 克隆项目
git clone https://github.com/yourusername/swiftbar-warp-control.git
cd swiftbar-warp-control

# 2. 检查脚本语法
find . -name "*.sh" -exec bash -n {} \;

# 3. 在测试环境中安装
bash install.sh

# 4. 测试功能
sudo /usr/local/bin/warp-control.sh status
```

---

## 📝 代码标准 | Code Standards

### Shell 脚本规范 | Shell Script Guidelines
- 使用 `#!/bin/bash` shebang
- 启用严格模式：`set -e`
- 使用有意义的变量名
- 添加注释解释复杂逻辑
- 使用函数组织代码

### 示例代码风格 | Example Code Style
```bash
#!/bin/bash

# Script description
# Usage: script.sh [options]

set -e

# Constants
readonly SCRIPT_NAME="$(basename "$0")"
readonly LOG_FILE="/tmp/${SCRIPT_NAME}.log"

# Functions
print_info() {
    echo -e "${BLUE}ℹ️ ${1}${NC}"
}

main() {
    # Main logic here
    print_info "Starting process..."
}

# Entry point
main "$@"
```

### 文档规范 | Documentation Standards
- 中英文双语文档
- 使用 Markdown 格式
- 包含代码示例
- 添加适当的表情符号增强可读性

---

## 🧪 测试 | Testing

### 本地测试 | Local Testing
```bash
# 语法检查
bash -n install.sh
bash -n uninstall.sh
bash -n scripts/*.sh

# 功能测试
bash install.sh
# 测试各项功能...
bash uninstall.sh
```

### 安全测试 | Security Testing
```bash
# 检查权限配置
sudo visudo -c -f config/warp-toggle-sudoers

# 验证脚本权限
ls -la /usr/local/bin/warp-control.sh

# 测试权限范围
sudo -n /usr/local/bin/warp-control.sh status
```

### CI/CD 测试 | CI/CD Testing
项目使用 GitHub Actions 进行自动化测试：
- 脚本语法检查
- 安全性验证
- 兼容性测试
- 文档完整性检查

---

## 📋 Pull Request 清单 | Pull Request Checklist

在提交 PR 前，请确保：

Before submitting a PR, please ensure:

- [ ] 代码遵循项目风格指南
- [ ] 添加了适当的注释
- [ ] 更新了相关文档
- [ ] 通过了所有测试
- [ ] 添加了必要的测试用例
- [ ] 更新了 CHANGELOG（如果适用）
- [ ] 考虑了安全性影响
- [ ] 保持向后兼容性

### PR 描述模板 | PR Description Template
```markdown
## 更改描述 | Description of Changes
简要描述您的更改内容。

## 更改类型 | Type of Change
- [ ] Bug 修复
- [ ] 新功能
- [ ] 文档更新
- [ ] 性能改进
- [ ] 代码重构

## 测试 | Testing
描述您如何测试这些更改。

## 安全考虑 | Security Considerations
如果涉及安全相关更改，请说明。

## 检查清单 | Checklist
- [ ] 代码已测试
- [ ] 文档已更新
- [ ] 通过了所有检查
```

---

## 🏷️ 版本管理 | Version Management

### 语义化版本 | Semantic Versioning
项目遵循 [语义化版本规范](https://semver.org/)：
- **主版本号**: 不兼容的 API 更改
- **次版本号**: 向后兼容的功能性新增
- **修订号**: 向后兼容的问题修正

### 发布流程 | Release Process
1. 更新版本号
2. 更新 CHANGELOG
3. 创建 Git tag
4. 发布 GitHub Release
5. 更新文档

---

## 🔒 安全贡献 | Security Contributions

### 安全问题报告 | Security Issue Reporting
- 私下报告安全漏洞
- 使用 GitHub Security Advisories
- 不在公开 issues 中讨论安全问题

### 安全代码审查 | Security Code Review
所有涉及权限或系统修改的代码都需要额外的安全审查：
- 检查权限最小化
- 验证输入验证
- 确认错误处理
- 评估攻击面

---

## 📚 资源 | Resources

### 项目资源 | Project Resources
- [GitHub Repository](https://github.com/yourusername/swiftbar-warp-control)
- [Issues](https://github.com/yourusername/swiftbar-warp-control/issues)
- [Discussions](https://github.com/yourusername/swiftbar-warp-control/discussions)
- [Wiki](https://github.com/yourusername/swiftbar-warp-control/wiki)

### 相关文档 | Related Documentation
- [SwiftBar Documentation](https://github.com/swiftbar/SwiftBar)
- [Cloudflare WARP](https://developers.cloudflare.com/warp-client/)
- [macOS Security](https://support.apple.com/guide/security/)
- [Bash Style Guide](https://google.github.io/styleguide/shellguide.html)

---

## 🎯 贡献想法 | Contribution Ideas

### 简单任务 | Easy Tasks
- 修复文档中的拼写错误
- 改进错误消息
- 添加更多语言支持
- 优化安装脚本输出

### 中等任务 | Medium Tasks
- 添加配置选项
- 改进错误处理
- 增强兼容性检查
- 优化性能

### 高级任务 | Advanced Tasks
- 重构核心架构
- 添加新的控制功能
- 实现插件系统
- 集成其他工具

---

## 🙏 致谢 | Acknowledgments

感谢所有贡献者的努力！您的贡献让这个项目变得更好。

Thank you to all contributors for your efforts! Your contributions make this project better.

### 贡献者列表 | Contributors List
贡献者将在此处列出，感谢您的参与！

Contributors will be listed here, thank you for your participation!

---

**记住：每个贡献都很重要，无论大小！**
**Remember: Every contribution matters, no matter how small!**