#!/bin/bash

# WARP Control Helper Script
# This script handles WARP daemon operations with elevated privileges
# Usage: warp-control.sh {start|stop|status|toggle}

DAEMON_PATH="/Library/LaunchDaemons/com.cloudflare.1dot1dot1dot1.macos.warp.daemon.plist"
WARP_APP="/Applications/Cloudflare WARP.app"

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
    if is_warp_running; then
        print_warning "WARP 已经在运行中"
        return 0
    fi
    
    echo "🚀 启动 WARP..."
    
    # Load the daemon
    if launchctl load "$DAEMON_PATH" 2>/dev/null; then
        if wait_for_status_change "running"; then
            print_success "WARP 已启动"
            return 0
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

# Function to get WARP status
get_status() {
    if is_warp_running; then
        echo "WARP is running"
        return 0
    else
        echo "WARP is not running"
        return 1
    fi
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