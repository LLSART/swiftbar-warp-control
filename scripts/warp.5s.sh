#!/bin/bash

# <bitbar.title>WARP Toggle</bitbar.title>
# <bitbar.version>v2.0</bitbar.title>
# <bitbar.author>SwiftBar WARP Control</bitbar.author>
# <bitbar.author.github>yourusername</bitbar.author.github>
# <bitbar.desc>Control Cloudflare WARP without password prompts</bitbar.desc>
# <bitbar.dependencies>bash</bitbar.dependencies>

WARP_CONTROL="/usr/local/bin/warp-control.sh"

# Check if WARP is running
if ps aux | grep "CloudflareWARP" | grep -v grep > /dev/null 2>&1; then
    echo "🟢 WARP"
    echo "---"
    echo "状态: 已连接 | color=green"
    echo "---"
    echo "停止 WARP | bash='$0' param1=stop terminal=false refresh=true"
    echo "重启 WARP | bash='$0' param1=restart terminal=false refresh=true"
    echo "---"
    echo "查看状态 | bash='$0' param1=status terminal=true"
    echo "打开 WARP 应用 | bash='open' param1='-a' param2='Cloudflare WARP' terminal=false"
    echo "---"
    echo "关于 | href=https://github.com/yourusername/swiftbar-warp-control"
else
    echo "🔴 WARP"
    echo "---"
    echo "状态: 已断开 | color=red"
    echo "---"
    echo "启动 WARP | bash='$0' param1=start terminal=false refresh=true"
    echo "---"
    echo "查看状态 | bash='$0' param1=status terminal=true"
    echo "打开 WARP 应用 | bash='open' param1='-a' param2='Cloudflare WARP' terminal=false"
    echo "---"
    echo "关于 | href=https://github.com/yourusername/swiftbar-warp-control"
fi

# Handle menu actions
case "$1" in
    start)
        if [ -f "$WARP_CONTROL" ]; then
            sudo "$WARP_CONTROL" start
        else
            echo "错误: WARP 控制脚本未找到"
            echo "请重新运行安装程序"
        fi
        ;;
    stop)
        if [ -f "$WARP_CONTROL" ]; then
            sudo "$WARP_CONTROL" stop
        else
            echo "错误: WARP 控制脚本未找到"
            echo "请重新运行安装程序"
        fi
        ;;
    restart)
        if [ -f "$WARP_CONTROL" ]; then
            sudo "$WARP_CONTROL" stop
            sleep 2
            sudo "$WARP_CONTROL" start
        else
            echo "错误: WARP 控制脚本未找到"
            echo "请重新运行安装程序"
        fi
        ;;
    status)
        if [ -f "$WARP_CONTROL" ]; then
            echo "=== WARP 状态检查 ==="
            echo ""
            sudo "$WARP_CONTROL" status
            echo ""
            echo "按任意键继续..."
            read -n 1
        else
            echo "错误: WARP 控制脚本未找到"
            echo "请重新运行安装程序"
        fi
        ;;
esac