#!/bin/bash

# SwiftBar WARP Control - Uninstaller
# This script removes all components installed by the WARP control tool

set -e

# Colors for better output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Emojis
CHECKMARK="✅"
CROSS="❌"
WARNING="⚠️"
TRASH="🗑️"

# File paths
WARP_CONTROL_SCRIPT="/usr/local/bin/warp-control.sh"
SUDOERS_FILE="/etc/sudoers.d/warp-toggle"
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
    echo -e "${BLUE}${1}${NC}"
}

# Function to confirm uninstallation
confirm_uninstall() {
    echo -e "${YELLOW}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                    ⚠️  确认卸载                               ║"
    echo "║                                                              ║"
    echo "║  此操作将删除以下组件:                                        ║"
    echo "║  • WARP 控制脚本                                             ║"
    echo "║  • sudo 无密码配置                                           ║"
    echo "║  • SwiftBar 插件                                             ║"
    echo "║                                                              ║"
    echo "║  注意: SwiftBar 应用本身不会被卸载                            ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo
    
    read -p "您确定要继续卸载吗? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_info "卸载已取消"
        exit 0
    fi
}

# Function to remove WARP control script
remove_warp_control() {
    print_step "${TRASH}" "删除 WARP 控制脚本..."
    
    if [[ -f "$WARP_CONTROL_SCRIPT" ]]; then
        if sudo rm -f "$WARP_CONTROL_SCRIPT"; then
            print_success "WARP 控制脚本已删除"
        else
            print_error "无法删除 WARP 控制脚本"
            return 1
        fi
    else
        print_warning "WARP 控制脚本不存在，跳过"
    fi
}

# Function to remove sudoers configuration
remove_sudoers_config() {
    print_step "${TRASH}" "删除 sudo 无密码配置..."
    
    if [[ -f "$SUDOERS_FILE" ]]; then
        if sudo rm -f "$SUDOERS_FILE"; then
            print_success "sudo 配置已删除"
        else
            print_error "无法删除 sudo 配置"
            return 1
        fi
    else
        print_warning "sudo 配置文件不存在，跳过"
    fi
}

# Function to remove SwiftBar plugin
remove_swiftbar_plugin() {
    print_step "${TRASH}" "删除 SwiftBar 插件..."
    
    if [[ -f "$WARP_PLUGIN_PATH" ]]; then
        if rm -f "$WARP_PLUGIN_PATH"; then
            print_success "SwiftBar 插件已删除"
        else
            print_error "无法删除 SwiftBar 插件"
            return 1
        fi
    else
        print_warning "SwiftBar 插件不存在，跳过"
    fi
}

# Function to refresh SwiftBar
refresh_swiftbar() {
    print_step "${BLUE}" "刷新 SwiftBar..."
    
    if pgrep -f SwiftBar >/dev/null; then
        # Send refresh signal to SwiftBar
        osascript -e 'tell application "SwiftBar" to refresh' 2>/dev/null || true
        print_success "SwiftBar 已刷新"
    else
        print_warning "SwiftBar 未运行，无需刷新"
    fi
}

# Function to verify uninstallation
verify_uninstall() {
    print_step "${BLUE}" "验证卸载结果..."
    
    local remaining_files=0
    
    # Check files
    if [[ -f "$WARP_CONTROL_SCRIPT" ]]; then
        print_error "WARP 控制脚本仍然存在"
        ((remaining_files++))
    fi
    
    if [[ -f "$SUDOERS_FILE" ]]; then
        print_error "sudo 配置文件仍然存在"
        ((remaining_files++))
    fi
    
    if [[ -f "$WARP_PLUGIN_PATH" ]]; then
        print_error "SwiftBar 插件仍然存在"
        ((remaining_files++))
    fi
    
    if [[ $remaining_files -eq 0 ]]; then
        print_success "所有组件已成功卸载"
        return 0
    else
        print_error "有 $remaining_files 个组件未能完全卸载"
        return 1
    fi
}

# Function to show post-uninstall information
show_post_uninstall_info() {
    echo
    echo -e "${GREEN}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                    🎉 卸载完成！                              ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo
    print_info "如果您想要完全移除相关应用程序，可以考虑:"
    echo
    print_info "卸载 SwiftBar (可选):"
    print_info "  brew uninstall --cask swiftbar"
    echo
    print_info "卸载 Cloudflare WARP (可选):"
    print_info "  从应用程序文件夹中删除，或使用 WARP 应用内的卸载选项"
    echo
    print_info "感谢使用 SwiftBar WARP Control!"
}

# Main uninstallation function
main() {
    clear
    echo -e "${PURPLE}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║             SwiftBar WARP Control Uninstaller                ║"
    echo "║                                                              ║"
    echo "║           Cloudflare WARP 控制工具卸载程序                    ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo
    
    # Check if running as root
    if [[ $EUID -eq 0 ]]; then
        print_error "请不要以 root 用户身份运行此脚本"
        print_info "正确的运行方式: bash uninstall.sh"
        exit 1
    fi
    
    # Confirm uninstallation
    confirm_uninstall
    
    echo
    print_info "开始卸载过程..."
    echo
    
    # Remove components
    local errors=0
    
    remove_swiftbar_plugin || ((errors++))
    echo
    
    print_info "以下步骤需要管理员权限来删除系统组件..."
    remove_warp_control || ((errors++))
    remove_sudoers_config || ((errors++))
    echo
    
    refresh_swiftbar
    echo
    
    # Verify uninstallation
    if verify_uninstall && [[ $errors -eq 0 ]]; then
        show_post_uninstall_info
    else
        print_error "卸载过程中遇到错误，可能需要手动清理"
        echo
        print_info "手动清理命令:"
        print_info "  sudo rm -f $WARP_CONTROL_SCRIPT"
        print_info "  sudo rm -f $SUDOERS_FILE"
        print_info "  rm -f $WARP_PLUGIN_PATH"
        exit 1
    fi
}

# Run main function
main "$@"