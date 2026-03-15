#!/bin/bash

echo "=== 显示器分辨率检查工具 ==="
echo ""

echo "1. 当前显示器信息:"
echo "-------------------"
system_profiler SPDisplaysDataType | grep -E "(Resolution|Display Type)" | head -10

echo ""
echo "2. 可用分辨率模式:"
echo "-------------------"
# 使用 displayplacer 查看可用分辨率（如果安装了的话）
if command -v displayplacer &> /dev/null; then
    echo "使用 displayplacer 查看:"
    displayplacer list
else
    echo "displayplacer 未安装，建议安装以获得更多分辨率选项"
    echo "安装命令: brew install jakehilborn/jakehilborn/displayplacer"
fi

echo ""
echo "3. 系统显示器设置路径:"
echo "-------------------"
echo "方法1: 系统设置 → 显示器 → 选择外接显示器 → 查找分辨率选项"
echo "方法2: 按住 Option 键点击苹果菜单 → 系统信息 → 图形/显示器"
echo "方法3: 使用第三方工具如 RDM 或 SwitchResX"

echo ""
echo "4. 如果配置了 HiDPI，重启后应该能在分辨率选项中看到:"
echo "   1440 × 900 (普通)"
echo "   1440 × 900 (HiDPI) ← 选择这个"