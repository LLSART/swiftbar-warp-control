#!/bin/bash

# Test script to verify WARP connection fix
# This script will test the updated warp-control.sh functionality

set -e

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║        WARP Connection Fix - Verification Test               ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Check PATH in sudo context
echo -e "${BLUE}[1/8]${NC} Checking PATH in sudo context..."
echo "Normal PATH: $PATH"
sudo_path=$(sudo bash -c 'echo $PATH')
echo "Sudo PATH: $sudo_path"
if echo "$sudo_path" | grep -q "/usr/local/bin"; then
    echo -e "${GREEN}✅ /usr/local/bin is in sudo PATH${NC}"
else
    echo -e "${YELLOW}⚠️  /usr/local/bin not in default sudo PATH (script should handle this)${NC}"
fi

echo ""

# Check if warp-cli is available
echo -e "${BLUE}[2/8]${NC} Checking warp-cli availability..."
if command -v warp-cli >/dev/null 2>&1; then
    echo -e "${GREEN}✅ warp-cli found at: $(which warp-cli)${NC}"
else
    echo -e "${RED}❌ warp-cli not found${NC}"
    echo "Please ensure Cloudflare WARP is installed"
    exit 1
fi

echo ""

# Check if control script exists
echo -e "${BLUE}[3/8]${NC} Checking control script..."
if [[ -f "/usr/local/bin/warp-control.sh" ]]; then
    echo -e "${GREEN}✅ Control script found${NC}"
else
    echo -e "${YELLOW}⚠️  Control script not installed at /usr/local/bin/warp-control.sh${NC}"
    echo "Please run: sudo cp scripts/warp-control.sh /usr/local/bin/warp-control.sh"
    exit 1
fi

echo ""

# Test stop
echo -e "${BLUE}[4/8]${NC} Testing WARP stop..."
echo "Running: sudo /usr/local/bin/warp-control.sh stop"
if sudo /usr/local/bin/warp-control.sh stop; then
    echo -e "${GREEN}✅ Stop command completed${NC}"
else
    echo -e "${YELLOW}⚠️  Stop command had issues (may be already stopped)${NC}"
fi

echo ""
sleep 2

# Verify disconnected
echo -e "${BLUE}[5/8]${NC} Verifying disconnection..."
warp_status=$(warp-cli status 2>/dev/null | grep -i "status" || echo "Disconnected")
echo "Status: $warp_status"
if echo "$warp_status" | grep -iq "disconnected\|unable"; then
    echo -e "${GREEN}✅ WARP is disconnected${NC}"
else
    echo -e "${YELLOW}⚠️  Status unclear: $warp_status${NC}"
fi

echo ""
sleep 2

# Test start (the key fix)
echo -e "${BLUE}[6/8]${NC} Testing WARP start with connection..."
echo "Running: sudo /usr/local/bin/warp-control.sh start"
if sudo /usr/local/bin/warp-control.sh start; then
    echo -e "${GREEN}✅ Start command completed${NC}"
else
    echo -e "${RED}❌ Start command failed${NC}"
    exit 1
fi

echo ""
sleep 3

# Verify connected
echo -e "${BLUE}[7/8]${NC} Verifying connection establishment..."
warp_status=$(warp-cli status 2>/dev/null || echo "Unknown")
echo "$warp_status"
echo ""

if echo "$warp_status" | grep -iq "connected"; then
    echo -e "${GREEN}✅ WARP is properly connected${NC}"
else
    echo -e "${RED}❌ WARP is not connected${NC}"
    echo -e "${YELLOW}Expected to see 'Connected' status${NC}"
    exit 1
fi

echo ""

# Check DNS configuration
echo -e "${BLUE}[8/8]${NC} Checking DNS configuration..."
dns_check=$(scutil --dns | grep -A4 'resolver #1' | grep 'nameserver\[0\]' || echo "No DNS info")
echo "$dns_check"

if echo "$dns_check" | grep -q "162.159\|1.1.1.1"; then
    echo -e "${GREEN}✅ Cloudflare DNS is configured${NC}"
else
    echo -e "${YELLOW}⚠️  DNS configuration unclear${NC}"
    echo "Manual check: scutil --dns | grep -A4 'resolver #1'"
fi

echo ""
echo -e "${GREEN}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║                  ✅ All tests passed!                         ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo "1. Open WARP app → Settings → Diagnostics"
echo "2. Run diagnostics"
echo "3. Verify 'DNS servers are not being set' is resolved"
echo "4. Keep connection running for 10 minutes"
echo "5. Re-run diagnostics to verify no 'Frequent Disconnections'"
echo ""
echo -e "${BLUE}To test SwiftBar plugin:${NC}"
echo "1. Restart SwiftBar: pkill -f SwiftBar && open -a SwiftBar"
echo "2. Click WARP icon in menu bar"
echo "3. Test Stop/Start/Restart functions"
echo ""

