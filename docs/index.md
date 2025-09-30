---
layout: default
title: "Documentation - SwiftBar WARP Control"
description: "Complete documentation for SwiftBar WARP Control - installation, configuration, troubleshooting, and advanced usage."
---

# Documentation

Welcome to the SwiftBar WARP Control documentation. Here you'll find everything you need to install, configure, and use this powerful macOS VPN management tool.

## Quick Navigation

- [Installation Guide](#installation)
- [Configuration](#configuration)
- [Usage Examples](#usage)
- [Troubleshooting](TROUBLESHOOTING.md)
- [Security Guide](SECURITY.md)
- [Contributing](../CONTRIBUTING.md)

## Installation

### Prerequisites

- macOS 10.15 (Catalina) or later
- Administrator access for initial setup
- Cloudflare WARP app installed

### One-Line Installation

```bash
curl -fsSL https://raw.githubusercontent.com/leeguooooo/swiftbar-warp-control/main/install.sh | bash
```

### Manual Installation

```bash
git clone https://github.com/leeguooooo/swiftbar-warp-control.git
cd swiftbar-warp-control
bash install.sh
```

## Configuration

### Default Settings

The tool works out-of-the-box with sensible defaults:

- **Plugin Location**: `~/swiftbar/warp.5s.sh`
- **Update Interval**: 5 seconds
- **Control Script**: `/usr/local/bin/warp-control.sh`

### Customization

You can customize the plugin behavior by editing the SwiftBar plugin file:

```bash
nano ~/swiftbar/warp.5s.sh
```

## Usage

### Menu Bar Controls

After installation, you'll see the WARP status in your menu bar:

- **🟢 WARP**: Connected and active
- **🔴 WARP**: Disconnected or inactive

### Command Line Interface

Direct terminal control:

```bash
# Check status
sudo /usr/local/bin/warp-control.sh status

# Start WARP
sudo /usr/local/bin/warp-control.sh start

# Stop WARP
sudo /usr/local/bin/warp-control.sh stop

# Toggle state
sudo /usr/local/bin/warp-control.sh toggle
```

### Advanced Usage

#### Automated Scripts

Integrate WARP control into your workflows:

```bash
#!/bin/bash
# Enable WARP for secure operations
sudo /usr/local/bin/warp-control.sh start

# Your secure operations here
# ...

# Disable WARP when done
sudo /usr/local/bin/warp-control.sh stop
```

#### Status Monitoring

Check WARP status in scripts:

```bash
if sudo /usr/local/bin/warp-control.sh status | grep -q "running"; then
    echo "WARP is active"
else
    echo "WARP is inactive"
fi
```

## Security Considerations

### Sudo Configuration

The tool uses a minimal sudo configuration:

```bash
username ALL=(ALL) NOPASSWD: /usr/local/bin/warp-control.sh
```

This allows password-free execution of **only** the WARP control script.

### Best Practices

1. **Regular Updates**: Keep the tool updated for security patches
2. **Access Control**: Only install on trusted systems
3. **Monitoring**: Regularly check sudo logs if needed
4. **Backup**: Backup your configuration before major changes

## Uninstallation

### Complete Removal

```bash
bash uninstall.sh
```

### Manual Cleanup

If the automated uninstaller fails:

```bash
# Remove control script
sudo rm -f /usr/local/bin/warp-control.sh

# Remove sudo configuration
sudo rm -f /etc/sudoers.d/warp-toggle

# Remove SwiftBar plugin
rm -f ~/swiftbar/warp.5s.sh
```

## FAQ

### Common Questions

**Q: Will this affect my existing WARP configuration?**
A: No, this tool only controls the WARP service state, not its configuration.

**Q: Can I use this with WARP for Teams?**
A: Yes, it works with both consumer and enterprise WARP deployments.

**Q: Does this work on Apple Silicon Macs?**
A: Yes, it's compatible with both Intel and Apple Silicon Macs.

**Q: Can I customize the menu bar appearance?**
A: Yes, you can modify the SwiftBar plugin file to change icons and text.

## Getting Help

- **Issues**: [GitHub Issues](https://github.com/leeguooooo/swiftbar-warp-control/issues)
- **Discussions**: [GitHub Discussions](https://github.com/leeguooooo/swiftbar-warp-control/discussions)
- **Documentation**: [GitHub Wiki](https://github.com/leeguooooo/swiftbar-warp-control/wiki)

## Related Documentation

- [Troubleshooting Guide](TROUBLESHOOTING.md)
- [Security Documentation](SECURITY.md)
- [Contributing Guidelines](../CONTRIBUTING.md)
- [SEO and Keywords](SEO.md)