---
layout: default
title: "SwiftBar WARP Control - Professional macOS VPN Menu Bar Tool"
description: "Secure and efficient SwiftBar plugin for password-free Cloudflare WARP VPN management on macOS. One-click installation, menu bar integration, and enterprise security."
keywords: "macOS, SwiftBar, Cloudflare WARP, VPN, menu bar, plugin, password-free, automation, security"
---

# SwiftBar WARP Control

**Professional macOS menu bar tool for password-free Cloudflare WARP VPN control**

A secure and efficient SwiftBar plugin that provides seamless Cloudflare WARP VPN management directly from your macOS menu bar. Eliminate repetitive password prompts while maintaining security and ease of use.

![License](https://img.shields.io/badge/license-MIT-blue.svg)
![macOS](https://img.shields.io/badge/macOS-10.15+-brightgreen.svg)
![SwiftBar](https://img.shields.io/badge/SwiftBar-2.0+-orange.svg)
![GitHub release](https://img.shields.io/github/v/release/leeguooooo/swiftbar-warp-control)
![GitHub stars](https://img.shields.io/github/stars/leeguooooo/swiftbar-warp-control)

## Why Choose SwiftBar WARP Control?

### 🚀 **Zero-Friction VPN Management**
Toggle Cloudflare WARP on/off instantly from your menu bar without entering your password every time. Perfect for developers, remote workers, and privacy-conscious users.

### 🔒 **Enterprise-Grade Security**
Minimal privilege escalation with isolated sudo permissions. Only the specific WARP control script can be executed without a password - no system-wide vulnerabilities.

### ⚡ **One-Click Installation**
Automated installer handles everything: Homebrew, SwiftBar, security configuration, and plugin setup. Get running in under 2 minutes.

### 🎯 **Native macOS Experience**
Built specifically for macOS with seamless menu bar integration, smart status detection, and clean visual indicators.

## Quick Start

```bash
curl -fsSL https://raw.githubusercontent.com/leeguooooo/swiftbar-warp-control/main/install.sh | bash
```

## Key Features

- **Password-Free Control**: Toggle WARP without repetitive authentication
- **One-Click Installation**: Automated setup for all dependencies
- **Secure Design**: Minimal privilege escalation for safety
- **Clean Interface**: Professional menu bar integration
- **Smart Detection**: Automatic WARP status monitoring
- **Rich Menu Options**: Start, stop, restart, and status checking
- **Easy Uninstall**: Complete removal with included script

## Perfect For

- **Developers** who frequently switch VPN status during development
- **Remote Workers** needing quick, secure internet access
- **Privacy Users** wanting streamlined WARP management
- **System Administrators** deploying VPN tools across teams
- **Power Users** seeking efficient macOS automation tools

## Technical Specifications

- **Compatibility**: macOS 10.15 (Catalina) and later
- **Architecture**: Universal (Intel and Apple Silicon)
- **Dependencies**: SwiftBar 2.0+, Cloudflare WARP
- **Security**: Isolated sudo permissions, minimal attack surface
- **License**: MIT (Open Source)

## Installation Methods

### Automated Installation (Recommended)
```bash
curl -fsSL https://raw.githubusercontent.com/leeguooooo/swiftbar-warp-control/main/install.sh | bash
```

### Manual Installation
```bash
git clone https://github.com/leeguooooo/swiftbar-warp-control.git
cd swiftbar-warp-control
bash install.sh
```

## What Gets Installed

1. **Homebrew** (if not already installed)
2. **SwiftBar** (if not already installed)
3. **WARP Control Script** (`/usr/local/bin/warp-control.sh`)
4. **Sudo Configuration** (`/etc/sudoers.d/warp-toggle`)
5. **SwiftBar Plugin** (`~/swiftbar/warp.5s.sh`)

## Support & Community

- **Documentation**: [GitHub Wiki](https://github.com/leeguooooo/swiftbar-warp-control/wiki)
- **Bug Reports**: [GitHub Issues](https://github.com/leeguooooo/swiftbar-warp-control/issues)
- **Feature Requests**: [GitHub Discussions](https://github.com/leeguooooo/swiftbar-warp-control/discussions)
- **Security**: [Security Policy](https://github.com/leeguooooo/swiftbar-warp-control/security)

## Open Source & Sponsorship

This project is **100% open source** under the MIT license. If it's been helpful to you, please consider:

- ⭐ **Starring** the repository
- 💝 **Sponsoring** development via [GitHub Sponsors](https://github.com/sponsors/leeguooooo)
- ☕ **Buying me a coffee** via [Buy Me A Coffee](https://buymeacoffee.com/leeguooooo)
- 🗣️ **Sharing** with others who might benefit

## Related Projects

- [SwiftBar](https://github.com/swiftbar/SwiftBar) - The powerful menu bar customization tool
- [Cloudflare WARP](https://1.1.1.1/) - Fast, secure, private internet connection
- [BitBar](https://github.com/matryer/bitbar) - Original inspiration for menu bar plugins

---

**Made with care for the macOS community** • [GitHub](https://github.com/leeguooooo/swiftbar-warp-control) • [Documentation](docs/) • [License](LICENSE)