#!/bin/bash

# Update Script - Apply v1.1.2 to system
# 更新脚本 - 应用 v1.1.2 到系统

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║          应用 WARP Control v1.1.2 更新                      ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Check if running from correct directory
if [[ ! -f "scripts/warp-control.sh" ]]; then
    echo -e "${YELLOW}错误: 请从项目根目录运行此脚本${NC}"
    echo "cd /Users/leo/github.com/swiftbar-warp-control && bash update.sh"
    exit 1
fi

echo "[1/4] 检查文件..."
if [[ -f "scripts/warp-control.sh" ]]; then
    echo -e "${GREEN}✅ 源文件存在${NC}"
else
    echo -e "${YELLOW}❌ 找不到源文件${NC}"
    exit 1
fi

echo ""
echo "[2/4] 验证脚本语法..."
if bash -n scripts/warp-control.sh; then
    echo -e "${GREEN}✅ 语法检查通过${NC}"
else
    echo -e "${YELLOW}❌ 脚本有语法错误${NC}"
    exit 1
fi

echo ""
echo "[3/4] 更新系统脚本..."
echo "复制 scripts/warp-control.sh → /usr/local/bin/warp-control.sh"
sudo cp scripts/warp-control.sh /usr/local/bin/warp-control.sh
sudo chmod 755 /usr/local/bin/warp-control.sh
echo -e "${GREEN}✅ 系统脚本已更新${NC}"

echo ""
echo "[4/4] 验证更新..."
if grep -q "check_network_conflicts" /usr/local/bin/warp-control.sh; then
    echo -e "${GREEN}✅ v1.1.2 功能已安装（包含网络冲突检测）${NC}"
else
    echo -e "${YELLOW}⚠️  警告: 未检测到新功能${NC}"
fi

echo ""
echo -e "${GREEN}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║                  ✅ 更新完成！                               ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""

echo -e "${BLUE}现在可以使用新功能：${NC}"
echo ""
echo "  1. 查看状态（含网络冲突检测）:"
echo "     sudo /usr/local/bin/warp-control.sh status"
echo ""
echo "  2. 运行完整诊断:"
echo "     bash diagnose-network.sh"
echo ""
echo "  3. 通过 SwiftBar 控制:"
echo "     点击菜单栏 WARP 图标"
echo ""

echo -e "${BLUE}📚 查看文档：${NC}"
echo "  - QUICK_START_NEW_FEATURES.md  (新功能快速开始)"
echo "  - NETWORK_DIAGNOSTICS.md       (诊断功能详解)"
echo "  - FINAL_SUMMARY.md             (完整总结)"
echo ""

# Optional: Restart SwiftBar
read -p "是否重启 SwiftBar? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "重启 SwiftBar..."
    pkill -f SwiftBar 2>/dev/null || true
    sleep 1
    open -a SwiftBar
    echo -e "${GREEN}✅ SwiftBar 已重启${NC}"
fi

echo ""
echo "🎉 完成！"

