# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.0.0] - 2024-09-30

### Added
- Initial release of SwiftBar WARP Control
- One-click password-free Cloudflare WARP control for macOS
- Automated installation script with dependency management
- SwiftBar plugin for menu bar integration
- Secure sudo configuration for WARP control
- Professional documentation with SEO optimization
- GitHub Pages website and documentation
- Sponsorship support via GitHub Sponsors and Buy Me a Coffee
- Comprehensive uninstall script
- Security-focused design with minimal privilege escalation

### Features
- **Password-Free Control**: Toggle WARP without repeated authentication
- **One-Click Installation**: Automated setup for all dependencies including SwiftBar
- **Secure Design**: Minimal privilege escalation with isolated permissions
- **Clean Interface**: Professional menu bar integration with status indicators
- **Smart Detection**: Automatic WARP status monitoring and system requirements check
- **Rich Menu Options**: Start, stop, restart, and status checking capabilities
- **Easy Uninstall**: Complete removal with included uninstall script

### Technical Details
- **Compatibility**: macOS 10.15 (Catalina) and later
- **Architecture**: Universal support (Intel and Apple Silicon)
- **Dependencies**: SwiftBar 2.0+, Cloudflare WARP
- **Security**: Isolated sudo permissions, minimal attack surface
- **License**: MIT (Open Source)

### Documentation
- Comprehensive README with installation and usage instructions
- Bilingual documentation (English and Chinese)
- Troubleshooting guide with common issues and solutions
- Security documentation with best practices
- SEO-optimized GitHub Pages website
- Contributing guidelines for developers

### Installation
```bash
curl -fsSL https://raw.githubusercontent.com/leeguooooo/swiftbar-warp-control/main/install.sh | bash
```

### What's Included
- WARP control script (`/usr/local/bin/warp-control.sh`)
- Sudo configuration (`/etc/sudoers.d/warp-toggle`)
- SwiftBar plugin (`~/swiftbar/warp.5s.sh`)
- Automated Homebrew and SwiftBar installation
- Complete uninstallation support

[Unreleased]: https://github.com/leeguooooo/swiftbar-warp-control/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/leeguooooo/swiftbar-warp-control/releases/tag/v1.0.0