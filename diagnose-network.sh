#!/bin/bash

# Network Conflict Diagnostic Tool for WARP
# 用于诊断可能与 WARP 冲突的本地网络配置

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_header() {
    echo -e "${BLUE}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║          WARP 网络冲突诊断工具                              ║${NC}"
    echo -e "${BLUE}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

print_success() {
    echo -e "${GREEN}✅ ${1}${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  ${1}${NC}"
}

print_error() {
    echo -e "${RED}❌ ${1}${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  ${1}${NC}"
}

# Check 1: Local network interfaces using enterprise ranges
check_local_networks() {
    echo "[1/6] 检查本地网络接口"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    local found_172=0
    local found_10=0
    
    # Check for 172.16-31.x.x (enterprise range)
    local networks_172=$(ifconfig 2>/dev/null | grep -o "inet 172\.[1-3][0-9]\.[0-9]*\.[0-9]*" | awk '{print $2}')
    
    if [[ -n "$networks_172" ]]; then
        print_warning "发现使用企业常用网段 (172.16-31.x.x)："
        echo "$networks_172" | while read ip; do
            local interface=$(ifconfig 2>/dev/null | grep -B 3 "$ip" | head -1 | awk '{print $1}' | tr -d ':')
            echo "  • $ip ($interface)"
        done
        echo ""
        print_info "这些网段常被企业内网使用，可能导致访问冲突"
        found_172=1
    fi
    
    # Check for 10.x.x.x
    local networks_10=$(ifconfig 2>/dev/null | grep -o "inet 10\.[0-9]*\.[0-9]*\.[0-9]*" | awk '{print $2}')
    
    if [[ -n "$networks_10" ]]; then
        echo "发现 10.x.x.x 网段："
        echo "$networks_10" | while read ip; do
            local interface=$(ifconfig 2>/dev/null | grep -B 3 "$ip" | head -1 | awk '{print $1}' | tr -d ':')
            echo "  • $ip ($interface)"
        done
        found_10=1
    fi
    
    if [[ $found_172 -eq 0 && $found_10 -eq 0 ]]; then
        print_success "本地网络配置正常，未使用常见企业网段"
    fi
    
    echo ""
}

# Check 2: Docker networks
check_docker_networks() {
    echo "[2/6] 检查 Docker 网络配置"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    if ! command -v docker >/dev/null 2>&1; then
        print_info "Docker 未安装或不可用"
        echo ""
        return
    fi
    
    local found_conflicts=0
    
    # Get all Docker networks
    local network_ids=$(docker network ls -q 2>/dev/null)
    
    if [[ -z "$network_ids" ]]; then
        print_info "没有 Docker 网络"
        echo ""
        return
    fi
    
    echo "Docker 网络列表："
    docker network ls --format "table {{.Name}}\t{{.Driver}}\t{{.Scope}}"
    echo ""
    
    # Check for 172.16-31.x.x ranges
    for net_id in $network_ids; do
        local net_info=$(docker network inspect "$net_id" 2>/dev/null)
        local net_name=$(echo "$net_info" | grep -o '"Name": "[^"]*"' | head -1 | cut -d'"' -f4)
        local subnet=$(echo "$net_info" | grep -o '"Subnet": "172\.[1-3][0-9]\.[0-9]*/[0-9]*"' | cut -d'"' -f4)
        
        if [[ -n "$subnet" ]]; then
            print_warning "网络 '$net_name' 使用企业网段: $subnet"
            found_conflicts=1
        fi
    done
    
    if [[ $found_conflicts -eq 1 ]]; then
        echo ""
        print_info "建议修改 docker-compose.yml 中的网络配置："
        echo "  networks:"
        echo "    your-network:"
        echo "      driver: bridge"
        echo "      ipam:"
        echo "        config:"
        echo "          - subnet: 10.20.0.0/16  # 修改为此"
    else
        print_success "Docker 网络配置正常"
    fi
    
    echo ""
}

# Check 3: Route table
check_routes() {
    echo "[3/6] 检查路由表"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    local routes_172=$(netstat -rn | grep -E "^172\.(1[6-9]|2[0-9]|3[0-1])\." | head -10)
    
    if [[ -n "$routes_172" ]]; then
        print_warning "发现企业网段路由："
        echo "$routes_172"
        echo ""
        print_info "如果这些路由指向本地接口，可能与公司内网冲突"
    else
        print_success "路由表未发现冲突"
    fi
    
    echo ""
}

# Check 4: WARP status
check_warp_status() {
    echo "[4/6] 检查 WARP 状态"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    if ! command -v warp-cli >/dev/null 2>&1; then
        print_error "warp-cli 未找到"
        echo ""
        return
    fi
    
    local status=$(warp-cli status 2>&1)
    
    if echo "$status" | grep -q "Connected"; then
        print_success "WARP 已连接"
        
        # Get WARP settings
        local settings=$(warp-cli settings 2>/dev/null)
        
        # Check split tunnel config
        if echo "$settings" | grep -q "Exclude mode"; then
            echo ""
            print_info "Split Tunnel 配置（排除模式）："
            echo "$settings" | grep -A 20 "Exclude mode" | grep -E "^\s+(172\.|10\.|192\.168\.)" | head -5
        fi
    else
        print_warning "WARP 未连接"
        echo "$status"
    fi
    
    echo ""
}

# Check 5: DNS configuration
check_dns() {
    echo "[5/6] 检查 DNS 配置"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    local dns_servers=$(scutil --dns | grep 'nameserver\[0\]' | head -3)
    
    if echo "$dns_servers" | grep -q "162.159\|1.1.1.1"; then
        print_success "DNS 配置正确（Cloudflare DNS）"
    else
        print_warning "DNS 未使用 Cloudflare"
    fi
    
    echo "$dns_servers"
    echo ""
}

# Check 6: Common network conflict scenarios
check_common_scenarios() {
    echo "[6/6] 检查常见冲突场景"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    local has_issues=0
    
    # Scenario 1: OrbStack/Docker Desktop
    if pgrep -f "OrbStack" >/dev/null || pgrep -f "Docker" >/dev/null; then
        echo "✓ 检测到虚拟化软件运行"
        
        # Check if bridge interfaces use 172.x
        if ifconfig 2>/dev/null | grep -q "bridge.*inet 172\."; then
            print_warning "虚拟机网络可能使用冲突网段"
            has_issues=1
        fi
    fi
    
    # Scenario 2: VPN conflicts
    if ifconfig 2>/dev/null | grep -qE "ppp|tun|tap" | grep -v utun; then
        echo "✓ 检测到其他 VPN 接口"
        print_info "如果有多个 VPN，可能导致路由冲突"
    fi
    
    # Scenario 3: Multiple network ranges
    local network_count=$(ifconfig 2>/dev/null | grep -c "inet 172\.[1-3][0-9]\.")
    if [[ $network_count -gt 2 ]]; then
        print_warning "发现多个企业网段接口（$network_count 个）"
        print_info "过多的网络接口可能导致路由混乱"
        has_issues=1
    fi
    
    if [[ $has_issues -eq 0 ]]; then
        print_success "未发现常见冲突场景"
    fi
    
    echo ""
}

# Generate report
generate_report() {
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                        诊断总结                              ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo ""
    
    # Check if there are conflicts
    local has_172=$(ifconfig 2>/dev/null | grep -c "inet 172\.[1-3][0-9]\." || echo 0)
    local has_docker_172=0
    
    if command -v docker >/dev/null 2>&1; then
        has_docker_172=$(docker network ls -q 2>/dev/null | xargs docker network inspect 2>/dev/null | grep -c '"Subnet": "172\.[1-3][0-9]\.' || echo 0)
    fi
    
    if [[ $has_172 -gt 0 || $has_docker_172 -gt 0 ]]; then
        print_warning "发现潜在的网络冲突"
        echo ""
        echo "📋 建议采取的措施："
        echo ""
        
        if [[ $has_docker_172 -gt 0 ]]; then
            echo "1️⃣  修改 Docker 网络配置"
            echo "   找到使用 172.16-31.x.x 的 docker-compose.yml"
            echo "   修改 subnet 为 10.20.0.0/16"
            echo "   执行: docker-compose down && docker-compose up -d"
            echo ""
        fi
        
        echo "2️⃣  检查虚拟机网络设置"
        echo "   OrbStack: Settings → Network"
        echo "   Docker Desktop: Settings → Resources → Network"
        echo ""
        
        echo "3️⃣  联系 IT 部门"
        echo "   请求修改 WARP Split Tunnel 配置"
        echo "   排除企业内网网段"
        echo ""
        
        echo "📚 详细文档："
        echo "   - NETWORK_CONFLICT_FIX.md"
        echo "   - FIX_ORBSTACK_NETWORK.md"
    else
        print_success "网络配置良好，未发现冲突"
        echo ""
        echo "如果仍有连接问题，请："
        echo "  1. 运行 'sudo /usr/local/bin/warp-control.sh status'"
        echo "  2. 检查 WARP 应用的诊断功能"
        echo "  3. 查看 SOLUTION_SUMMARY.md"
    fi
    
    echo ""
}

# Main
main() {
    print_header
    
    check_local_networks
    check_docker_networks
    check_routes
    check_warp_status
    check_dns
    check_common_scenarios
    
    generate_report
}

main "$@"

