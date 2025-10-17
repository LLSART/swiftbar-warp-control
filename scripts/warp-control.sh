#!/bin/bash

# WARP Control Helper Script
# This script handles WARP daemon operations with elevated privileges
# Usage: warp-control.sh {start|stop|status|toggle}

# Fix PATH for sudo context (SwiftBar invokes this via sudo)
# sudo resets PATH to /usr/bin:/bin:/usr/sbin:/sbin, so we need to add common locations
export PATH="/usr/local/bin:/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin"

DAEMON_PATH="/Library/LaunchDaemons/com.cloudflare.1dot1dot1dot1.macos.warp.daemon.plist"
WARP_APP="/Applications/Cloudflare WARP.app"
# Absolute path to warp-cli (fallback if not in PATH)
WARP_CLI_PATHS=(
    "/usr/local/bin/warp-cli"
    "/opt/homebrew/bin/warp-cli"
    "/Applications/Cloudflare WARP.app/Contents/Resources/warp-cli"
)

# Find warp-cli
find_warp_cli() {
    # First try PATH
    if command -v warp-cli >/dev/null 2>&1; then
        echo "warp-cli"
        return 0
    fi
    
    # Try known locations
    for path in "${WARP_CLI_PATHS[@]}"; do
        if [[ -x "$path" ]]; then
            echo "$path"
            return 0
        fi
    done
    
    return 1
}

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Function to print colored output
print_success() {
    echo -e "${GREEN}✅ ${1}${NC}"
}

print_error() {
    echo -e "${RED}❌ ${1}${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️ ${1}${NC}"
}

# Function to check if WARP is running
is_warp_running() {
    ps aux | grep "CloudflareWARP" | grep -v grep > /dev/null 2>&1
}

# Function to wait for WARP status change
wait_for_status_change() {
    local expected_status="$1"
    local timeout=10
    local count=0
    
    while [ $count -lt $timeout ]; do
        if [ "$expected_status" = "running" ]; then
            if is_warp_running; then
                return 0
            fi
        else
            if ! is_warp_running; then
                return 0
            fi
        fi
        sleep 1
        ((count++))
    done
    return 1
}

# Function to start WARP
start_warp() {
    local warp_cli
    warp_cli=$(find_warp_cli)
    local has_warp_cli=$?
    
    if is_warp_running; then
        print_warning "WARP 已经在运行中"
        # Even if daemon is running, ensure connection is established
        if [[ $has_warp_cli -eq 0 ]]; then
            echo "🔗 确保 WARP 连接已建立..."
            if "$warp_cli" connect 2>&1; then
                sleep 1
                print_success "WARP 连接已建立"
            else
                print_warning "尝试建立连接但可能失败，请检查 WARP 设置"
            fi
        fi
        return 0
    fi
    
    echo "🚀 启动 WARP..."
    
    # Load the daemon
    if launchctl load "$DAEMON_PATH" 2>/dev/null; then
        if wait_for_status_change "running"; then
            # After daemon starts, establish connection
            if [[ $has_warp_cli -eq 0 ]]; then
                echo "🔗 建立 WARP 连接..."
                # Wait a bit for daemon to be ready
                sleep 2
                
                # Capture both stdout and stderr, and check exit code
                local connect_output
                connect_output=$("$warp_cli" connect 2>&1)
                local connect_status=$?
                
                if [[ $connect_status -eq 0 ]]; then
                    sleep 1
                    print_success "WARP 已启动并连接"
                    return 0
                else
                    print_error "WARP daemon 已启动，但连接失败"
                    echo "错误详情: $connect_output"
                    print_warning "请检查设备是否已注册或许可证是否有效"
                    return 1
                fi
            else
                print_success "WARP daemon 已启动"
                print_error "未找到 warp-cli 命令，无法建立连接"
                print_warning "请确保 Cloudflare WARP 完整安装"
                return 1
            fi
        else
            print_warning "WARP 启动可能需要更多时间"
            return 0
        fi
    else
        print_error "无法启动 WARP daemon"
        return 1
    fi
}

# Function to stop WARP
stop_warp() {
    if ! is_warp_running; then
        print_warning "WARP 已经停止"
        return 0
    fi
    
    echo "🛑 停止 WARP..."
    
    # First, disconnect WARP connection gracefully
    local warp_cli
    warp_cli=$(find_warp_cli)
    local has_warp_cli=$?
    
    if [[ $has_warp_cli -eq 0 ]]; then
        echo "🔌 断开 WARP 连接..."
        
        # Capture output and check exit code
        local disconnect_output
        disconnect_output=$("$warp_cli" disconnect 2>&1)
        local disconnect_status=$?
        
        if [[ $disconnect_status -eq 0 ]]; then
            sleep 1
            print_success "WARP 连接已断开"
        else
            print_warning "断开连接时出现问题（继续停止 daemon）"
            echo "详情: $disconnect_output"
        fi
    else
        print_warning "未找到 warp-cli，跳过断开连接步骤"
    fi
    
    # Unload the daemon
    launchctl unload "$DAEMON_PATH" 2>/dev/null
    
    # Force kill any remaining processes
    pkill -9 CloudflareWARP 2>/dev/null || true
    
    if wait_for_status_change "stopped"; then
        print_success "WARP 已停止"
        return 0
    else
        print_warning "WARP 停止可能需要更多时间"
        return 0
    fi
}

# Function to check for network conflicts
check_network_conflicts() {
    local has_conflicts=0
    
    echo ""
    echo "=== Network Conflict Check ==="
    
    # Check for common enterprise network ranges that might conflict
    # 172.16.0.0/12 (172.16-31.x.x) is commonly used by enterprises
    local local_172_networks=$(ifconfig 2>/dev/null | grep -o "inet 172\.[1-3][0-9]\.[0-9]*\.[0-9]*" | awk '{print $2}')
    
    if [[ -n "$local_172_networks" ]]; then
        print_warning "发现本地使用企业网段 (172.16-31.x.x)："
        echo "$local_172_networks"
        echo ""
        echo "💡 如果无法访问公司内网服务，可能是网络地址冲突"
        echo "   建议："
        echo "   1. 检查是否有 Docker/VM 使用相同网段"
        echo "   2. 修改本地网络配置避免冲突"
        echo "   3. 参考: NETWORK_CONFLICT_FIX.md"
        echo ""
        has_conflicts=1
    fi
    
    # Check Docker networks
    if command -v docker >/dev/null 2>&1; then
        local docker_172_networks=$(docker network ls -q 2>/dev/null | xargs docker network inspect 2>/dev/null | grep -o '"Subnet": "172\.[1-3][0-9]\.[0-9]*/[0-9]*"' | grep -o "172\.[1-3][0-9]\.[0-9]*/[0-9]*")
        
        if [[ -n "$docker_172_networks" ]]; then
            print_warning "发现 Docker 网络使用企业网段："
            echo "$docker_172_networks"
            echo ""
            echo "💡 建议修改 Docker 网络配置："
            echo "   - 编辑 docker-compose.yml"
            echo "   - 将 subnet 改为 10.x.x.x 网段"
            echo "   - 然后执行: docker-compose down && docker-compose up -d"
            echo ""
            has_conflicts=1
        fi
    fi
    
    if [[ $has_conflicts -eq 0 ]]; then
        print_success "未发现网络冲突"
    fi
    
    return $has_conflicts
}

# Function to get WARP status
get_status() {
    echo "=== WARP Daemon Status ==="
    if is_warp_running; then
        print_success "Daemon: Running"
    else
        print_error "Daemon: Not running"
        return 1
    fi
    
    echo ""
    echo "=== WARP Connection Status ==="
    
    local warp_cli
    warp_cli=$(find_warp_cli)
    local has_warp_cli=$?
    
    if [[ $has_warp_cli -eq 0 ]]; then
        echo "warp-cli path: $warp_cli"
        echo ""
        
        # Get connection status from warp-cli
        local warp_status
        warp_status=$("$warp_cli" status 2>&1)
        local status_exit=$?
        
        if [[ $status_exit -eq 0 ]]; then
            echo "$warp_status"
        else
            print_error "Failed to get WARP status"
            echo "$warp_status"
        fi
        
        # Get settings if available
        echo ""
        echo "=== WARP Settings ==="
        local warp_settings
        warp_settings=$("$warp_cli" settings 2>&1)
        local settings_exit=$?
        
        if [[ $settings_exit -eq 0 ]]; then
            echo "$warp_settings"
        else
            print_warning "Unable to retrieve settings"
            echo "$warp_settings"
        fi
    else
        print_error "warp-cli command not found in any known location"
        echo "Searched paths:"
        for path in "${WARP_CLI_PATHS[@]}"; do
            echo "  - $path"
        done
        echo "Please ensure Cloudflare WARP is properly installed"
    fi
    
    # Check for network conflicts
    check_network_conflicts
    
    return 0
}

# Function to toggle WARP status
toggle_warp() {
    if is_warp_running; then
        stop_warp
    else
        start_warp
    fi
}

# Function to show usage
show_usage() {
    echo "Usage: $0 {start|stop|status|toggle}"
    echo ""
    echo "Commands:"
    echo "  start   - Start Cloudflare WARP"
    echo "  stop    - Stop Cloudflare WARP"
    echo "  status  - Show WARP status"
    echo "  toggle  - Toggle WARP on/off"
    echo ""
    echo "Examples:"
    echo "  $0 start"
    echo "  $0 toggle"
}

# Function to check if WARP is installed
check_warp_installation() {
    if [[ ! -d "$WARP_APP" ]] || [[ ! -f "$DAEMON_PATH" ]]; then
        print_error "Cloudflare WARP 未安装或安装不完整"
        echo "请从以下位置下载并安装:"
        echo "• App Store: https://apps.apple.com/app/cloudflare-one-agent/id6443476142"
        echo "• 官网: https://1.1.1.1/"
        return 1
    fi
    return 0
}

# Main script logic
main() {
    # Check if WARP is installed
    if ! check_warp_installation; then
        exit 1
    fi
    
    case "$1" in
        start)
            start_warp
            ;;
        stop)
            stop_warp
            ;;
        status)
            get_status
            ;;
        toggle)
            toggle_warp
            ;;
        *)
            show_usage
            exit 1
            ;;
    esac
}

# Run main function with all arguments
main "$@"