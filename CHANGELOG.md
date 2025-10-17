# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.1.1] - 2025-10-17

### Fixed
- **CRITICAL PATH Issue**: Fixed warp-cli not being found when script runs via sudo (SwiftBar context)
  - sudo resets PATH to `/usr/bin:/bin:/usr/sbin:/sbin`, excluding `/usr/local/bin` where warp-cli typically resides
  - Added explicit PATH export at script startup to include common installation locations
  - Implemented multi-layer warp-cli lookup: PATH → known absolute paths → app bundle
  - Without this fix, `warp-cli connect/disconnect` would NEVER execute in SwiftBar, making v1.1.0 ineffective
  
- **Error Handling**: Properly capture and report warp-cli command failures
  - Now captures exit codes from `warp-cli connect/disconnect` commands
  - Displays detailed error messages instead of always showing "success"
  - Returns appropriate exit codes to indicate actual operation status
  - Helps diagnose issues like unregistered devices or invalid licenses

### Added
- `find_warp_cli()` function to reliably locate warp-cli in any environment
- Support for multiple warp-cli installation paths:
  - `/usr/local/bin/warp-cli` (Homebrew Intel)
  - `/opt/homebrew/bin/warp-cli` (Homebrew Apple Silicon)
  - `/Applications/Cloudflare WARP.app/Contents/Resources/warp-cli` (App bundle)
- Enhanced status command now shows actual warp-cli path being used
- Comprehensive error messages with troubleshooting hints

### Changed
- All warp-cli invocations now use absolute paths or validated command names
- Error output is captured and displayed to users for better diagnostics
- Status messages are now accurate (no false positives)

### Technical Details
**Critical Issue:**
When SwiftBar invokes scripts via sudo, the PATH is reset to system directories only:
```bash
# Normal: /usr/local/bin:/usr/bin:/bin (warp-cli found ✓)
# Sudo:   /usr/bin:/bin:/usr/sbin:/sbin (warp-cli NOT found ✗)
```

This meant v1.1.0's `warp-cli connect` calls were being skipped entirely, and the script fell back to only starting the daemon without establishing a connection.

**Solution:**
1. Export full PATH at script start: `export PATH="/usr/local/bin:/opt/homebrew/bin:$PATH"`
2. Implement fallback search through known installation locations
3. Use absolute paths for all warp-cli invocations

This ensures reliable operation in both direct execution and sudo contexts.

### Credits
- Issue discovered and reported by: Leo (Code Review)
- Severity: HIGH (v1.1.0 was non-functional in SwiftBar context)

## [1.1.0] - 2025-10-17

### Fixed
- **Critical DNS Issue**: Fixed "macOS WARP DNS servers are not being set" error by properly establishing WARP connection
- **Frequent Disconnections**: Resolved frequent disconnection issues by using `warp-cli connect/disconnect` commands
- **Connection Management**: Now properly handles WARP network connection establishment, not just daemon process control

### Changed
- **Enhanced Start Flow**: `start` command now calls `warp-cli connect` after launching daemon to establish proper VPN connection
- **Enhanced Stop Flow**: `stop` command now calls `warp-cli disconnect` before unloading daemon for graceful disconnection
- **Improved Status**: `status` command now shows detailed connection information including WARP settings and connection state

### Technical Details
Previous version only used `launchctl load/unload` which started the daemon process but didn't establish the network connection. This caused:
- DNS servers not being configured
- Network routes not being set up
- Firewall rules not being applied
- VPN tunnel not being established

New version properly integrates with WARP by:
1. Starting daemon process (`launchctl load`)
2. Establishing connection (`warp-cli connect`)
3. Verifying connection status (`warp-cli status`)

This ensures DNS configuration, routing, and all network features work correctly.

### Migration
Users experiencing DNS or connection issues should update by running:
```bash
cd /path/to/swiftbar-warp-control
sudo cp scripts/warp-control.sh /usr/local/bin/warp-control.sh
sudo chmod 755 /usr/local/bin/warp-control.sh
```

Then verify with:
```bash
sudo /usr/local/bin/warp-control.sh stop
sudo /usr/local/bin/warp-control.sh start
warp-cli status  # Should show "Connected"
```

See [WARP_FIX.md](./WARP_FIX.md) for detailed technical explanation and [QUICK_UPDATE.md](./QUICK_UPDATE.md) for update instructions.

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