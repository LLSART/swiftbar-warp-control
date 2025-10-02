#!/bin/bash

# SwiftBar WARP Control - One-Click Installer
# GitHub: https://github.com/leeguooooo/swiftbar-warp-control
# Description: Automatically install SwiftBar and configure password-free WARP control

set -e

# Colors for better output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Emojis for better UX
CHECKMARK="✅"
CROSS="❌"
ROCKET="🚀"
GEAR="⚙️"
LOCK="🔐"
FOLDER="📁"
DOWNLOAD="⬇️"
WARNING="⚠️"

# Project paths
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WARP_CONTROL_SCRIPT="/usr/local/bin/warp-control.sh"
SUDOERS_FILE="/etc/sudoers.d/warp-toggle"

# SwiftBar paths
SWIFTBAR_PLUGINS_DIR="$HOME/swiftbar"
WARP_PLUGIN_PATH="$SWIFTBAR_PLUGINS_DIR/warp.5s.sh"

# Function to print colored output
print_step() {
    echo -e "${BLUE}${1}${NC} ${2}"
}

print_success() {
    echo -e "${GREEN}${CHECKMARK} ${1}${NC}"
}

print_error() {
    echo -e "${RED}${CROSS} ${1}${NC}"
}

print_warning() {
    echo -e "${YELLOW}${WARNING} ${1}${NC}"
}

print_info() {
    echo -e "${CYAN}${1}${NC}"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check if app is installed via Homebrew
app_installed_via_brew() {
    brew list --cask "$1" >/dev/null 2>&1
}

# Function to check macOS version
check_macos_version() {
    local version
    version=$(sw_vers -productVersion)
    local major_version
    major_version=$(echo "$version" | cut -d. -f1)
    local minor_version
    minor_version=$(echo "$version" | cut -d. -f2)
    
    if [[ $major_version -ge 11 ]] || [[ $major_version -eq 10 && $minor_version -ge 15 ]]; then
        return 0
    else
        return 1
    fi
}

# Function to install Homebrew
install_homebrew() {
    if ! command_exists brew; then
        print_step "${DOWNLOAD}" "安装 Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        
        # Add Homebrew to PATH for Apple Silicon Macs
        if [[ $(uname -m) == "arm64" ]]; then
            echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
            eval "$(/opt/homebrew/bin/brew shellenv)"
        fi
        
        print_success "Homebrew 安装完成"
    else
        print_success "Homebrew 已安装"
    fi
}

# Function to install SwiftBar
install_swiftbar() {
    if ! app_installed_via_brew swiftbar; then
        print_step "${DOWNLOAD}" "安装 SwiftBar..."
        brew install --cask swiftbar
        print_success "SwiftBar 安装完成"
    else
        print_success "SwiftBar 已安装"
    fi
}

# Function to create SwiftBar plugins directory
create_swiftbar_directory() {
    if [[ ! -d "$SWIFTBAR_PLUGINS_DIR" ]]; then
        print_step "${FOLDER}" "创建 SwiftBar 插件目录..."
        mkdir -p "$SWIFTBAR_PLUGINS_DIR"
        print_success "SwiftBar 插件目录已创建: $SWIFTBAR_PLUGINS_DIR"
    else
        print_success "SwiftBar 插件目录已存在"
    fi
}

# Function to check if Cloudflare WARP is installed
check_warp_installation() {
    local warp_app="/Applications/Cloudflare WARP.app"
    local daemon_path="/Library/LaunchDaemons/com.cloudflare.1dot1dot1dot1.macos.warp.daemon.plist"
    
    if [[ -d "$warp_app" ]] && [[ -f "$daemon_path" ]]; then
        print_success "Cloudflare WARP 已安装"
        return 0
    else
        print_warning "Cloudflare WARP 未安装"
        print_info "请从 App Store 或官网下载安装 Cloudflare WARP"
        print_info "下载地址: https://1.1.1.1/"
        return 1
    fi
}

# Function to install WARP control script
install_warp_control() {
    print_step "${GEAR}" "安装 WARP 控制脚本..."
    
    if [[ ! -f "$PROJECT_DIR/scripts/warp-control.sh" ]]; then
        print_error "找不到 WARP 控制脚本: $PROJECT_DIR/scripts/warp-control.sh"
        exit 1
    fi
    
    sudo cp "$PROJECT_DIR/scripts/warp-control.sh" "$WARP_CONTROL_SCRIPT"
    sudo chmod 755 "$WARP_CONTROL_SCRIPT"
    print_success "WARP 控制脚本已安装到: $WARP_CONTROL_SCRIPT"
}

# Function to configure sudoers
configure_sudoers() {
    print_step "${LOCK}" "配置 sudo 无密码权限..."
    
    if [[ ! -f "$PROJECT_DIR/config/warp-toggle-sudoers" ]]; then
        print_error "找不到 sudoers 配置文件: $PROJECT_DIR/config/warp-toggle-sudoers"
        exit 1
    fi
    
    # Replace placeholder with actual username
    local username
    username=$(whoami)
    sed "s/leo/$username/g" "$PROJECT_DIR/config/warp-toggle-sudoers" | sudo tee "$SUDOERS_FILE" > /dev/null
    sudo chmod 440 "$SUDOERS_FILE"
    
    # Validate sudoers syntax
    if sudo visudo -c -f "$SUDOERS_FILE"; then
        print_success "sudoers 配置已安装: $SUDOERS_FILE"
    else
        print_error "sudoers 配置语法错误，正在回滚..."
        sudo rm -f "$SUDOERS_FILE"
        exit 1
    fi
}

# Function to install SwiftBar plugin
install_swiftbar_plugin() {
    print_step "${GEAR}" "安装 SwiftBar WARP 插件..."
    
    if [[ ! -f "$PROJECT_DIR/scripts/warp.5s.sh" ]]; then
        print_error "找不到 SwiftBar 插件脚本: $PROJECT_DIR/scripts/warp.5s.sh"
        exit 1
    fi
    
    cp "$PROJECT_DIR/scripts/warp.5s.sh" "$WARP_PLUGIN_PATH"
    chmod +x "$WARP_PLUGIN_PATH"
    print_success "SwiftBar WARP 插件已安装: $WARP_PLUGIN_PATH"
}

# Function to configure SwiftBar preferences
configure_swiftbar_preferences() {
    print_step "${GEAR}" "配置 SwiftBar 偏好设置..."
    
    # Set plugin directory
    defaults write com.ameba.SwiftBar PluginDirectory "$SWIFTBAR_PLUGINS_DIR"
    
    # Enable auto make plugin executable
    defaults write com.ameba.SwiftBar MakePluginExecutable -bool true
    
    print_success "SwiftBar 插件目录已自动配置: $SWIFTBAR_PLUGINS_DIR"
}

# Function to start SwiftBar
start_swiftbar() {
    print_step "${ROCKET}" "启动 SwiftBar..."
    
    # Kill existing SwiftBar processes
    pkill -f SwiftBar || true
    
    # Start SwiftBar
    open -a SwiftBar
    
    # Wait a bit for SwiftBar to start
    sleep 2
    
    if pgrep -f SwiftBar >/dev/null; then
        print_success "SwiftBar 已启动"
    else
        print_warning "SwiftBar 可能未正确启动，请手动启动"
    fi
}

# Function to verify installation
verify_installation() {
    print_step "${GEAR}" "验证安装..."
    
    local errors=0
    
    # Check WARP control script
    if [[ -x "$WARP_CONTROL_SCRIPT" ]]; then
        print_success "WARP 控制脚本: 已安装"
    else
        print_error "WARP 控制脚本: 未找到或无执行权限"
        ((errors++))
    fi
    
    # Check sudoers configuration
    if [[ -f "$SUDOERS_FILE" ]]; then
        print_success "sudoers 配置: 已安装"
    else
        print_error "sudoers 配置: 未找到"
        ((errors++))
    fi
    
    # Check SwiftBar plugin
    if [[ -x "$WARP_PLUGIN_PATH" ]]; then
        print_success "SwiftBar 插件: 已安装"
    else
        print_error "SwiftBar 插件: 未找到或无执行权限"
        ((errors++))
    fi
    
    # Check SwiftBar configuration
    local configured_dir
    configured_dir=$(defaults read com.ameba.SwiftBar PluginDirectory 2>/dev/null)
    if [[ "$configured_dir" == "$SWIFTBAR_PLUGINS_DIR" ]]; then
        print_success "SwiftBar 插件目录配置: 正确"
    else
        print_warning "SwiftBar 插件目录配置: 需要手动设置"
    fi
    
    # Test sudo permission
    if sudo -n "$WARP_CONTROL_SCRIPT" status >/dev/null 2>&1; then
        print_success "sudo 无密码权限: 配置正确"
    else
        print_warning "sudo 无密码权限: 可能需要重新登录终端"
    fi
    
    return $errors
}

# Main installation function
main() {
    clear
    echo -e "${PURPLE}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║              SwiftBar WARP Control Installer                 ║"
    echo "║                                                              ║"
    echo "║         Cloudflare WARP 一键无密码控制工具安装器              ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo
    
    # Check macOS version
    print_step "${GEAR}" "检查系统要求..."
    if check_macos_version; then
        print_success "macOS 版本检查通过"
    else
        print_error "需要 macOS 10.15 或更高版本"
        exit 1
    fi
    
    # Check if running as root
    if [[ $EUID -eq 0 ]]; then
        print_error "请不要以 root 用户身份运行此脚本"
        print_info "正确的运行方式: bash install.sh"
        exit 1
    fi
    
    echo
    print_info "开始安装过程..."
    echo
    
    # Install dependencies
    install_homebrew
    install_swiftbar
    
    echo
    
    # Check WARP installation
    check_warp_installation
    
    echo
    
    # Create directories
    create_swiftbar_directory
    
    echo
    
    # Install components (requires sudo)
    print_info "以下步骤需要管理员权限来安装系统组件..."
    install_warp_control
    configure_sudoers
    
    echo
    
    # Install SwiftBar plugin
    install_swiftbar_plugin
    
    echo
    
    # Configure SwiftBar preferences
    configure_swiftbar_preferences
    
    echo
    
    # Start SwiftBar
    start_swiftbar
    
    echo
    
    # Verify installation
    if verify_installation; then
        echo
        echo -e "${GREEN}"
        echo "╔══════════════════════════════════════════════════════════════╗"
        echo "║                    🎉 安装成功完成！                          ║"
        echo "╚══════════════════════════════════════════════════════════════╝"
        echo -e "${NC}"
        echo
        print_success "现在您可以在菜单栏中看到 WARP 控制按钮"
        print_success "点击即可无密码开关 Cloudflare WARP"
        print_success "SwiftBar 插件目录已自动配置，无需手动设置"
        echo
        print_info "如果看不到菜单栏图标，请:"
        print_info "1. 确保 SwiftBar 正在运行"
        print_info "2. 重启 SwiftBar 应用"
        print_info "3. 检查菜单栏中的 WARP 图标（🟢/🔴）"
        echo
        print_info "如需卸载，请运行: bash uninstall.sh"
    else
        print_error "安装过程中发现错误，请检查上述输出"
        exit 1
    fi
}

# Run main function
main "$@"