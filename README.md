# macOS Better Display

macOS 外接显示器 HiDPI 开启工具。通过创建显示器配置文件，在非 Apple 显示器上启用 HiDPI（Retina 级别）缩放。

## 功能

- 自动检测显示器 VendorID 和 ProductID
- 支持多种分辨率预设（1920x1080、2560x1440、2560x1600 等）
- 支持手动输入自定义分辨率
- 可选择显示器图标（iMac、MacBook、Pro Display XDR 等）
- 支持 Apple Silicon (M1/M2/M3) 和 Intel Mac
- 新增：仅生成配置文件选项，方便手动安装

## 使用方法

```bash
# 运行主脚本（需要 sudo 权限）
sudo ./activate-HiDPI.bash

# 检查当前显示器分辨率
./check.sh
```

### 菜单选项

运行脚本后，会出现以下选项：

**Intel Mac:**
```
(1) 开启HIDPI
(2) 开启HIDPI(同时注入EDID)
(3) 关闭HIDPI
(4) 仅生成配置文件（手动安装）
```

**Apple Silicon:**
```
(1) 开启HIDPI
(2) 关闭HIDPI
(3) 仅生成配置文件（手动安装）
```

### 分辨率预设

| 选项 | 适用显示器 |
|------|-----------|
| (1) | 1920x1080 显示屏 |
| (2) | 1920x1080 显示屏（修复睡眠唤醒问题）|
| (3) | 1920x1200 显示屏 |
| (4) | 2560x1440 显示屏 |
| (5) | 2560x1600 显示屏 |
| (6) | 3000x2000 显示屏 |
| (7) | 3440x1440 显示屏 |
| (8) | 手动输入分辨率 |

## 仅生成配置文件

选择"仅生成配置文件"选项后：

1. 配置文件会生成在 `./hidpi-config/DisplayVendorID-xxxx/` 目录
2. 手动复制到系统目录：
   ```bash
   sudo cp -r ./hidpi-config/DisplayVendorID-xxxx "/Library/Displays/Contents/Resources/Overrides/"
   ```
3. 重启后生效

## 还原设置

脚本会在用户目录生成还原脚本：

```bash
# 运行还原脚本
~/.hidpi-disable
```

或手动删除：

```bash
# 删除单个显示器配置
sudo rm -rf /Library/Displays/Contents/Resources/Overrides/DisplayVendorID-xxxx

# 还原所有设置
sudo rm -rf /Library/Displays/Contents/Resources/Overrides/
```

## 调试命令

```bash
# 查看显示器硬件 ID
ioreg -l | grep -E "DisplayVendorID|DisplayProductID"

# 查看显示器信息
system_profiler SPDisplaysDataType

# 查看 EDID 数据
ioreg -lw0 | grep -i "IODisplayEDID"

# 列出已创建的配置文件
ls -la /Library/Displays/Contents/Resources/Overrides/
```

## 注意事项

1. 需要 `sudo` 权限写入 `/Library/Displays/` 目录
2. 配置生效需要重启或注销后重新登录
3. 首次重启时开机 Logo 可能会变大，之后会恢复正常
4. Apple Silicon Mac 使用不同的检测方法

## 系统要求

- macOS 10.13 或更高版本
- 支持 Intel Mac 和 Apple Silicon (M1/M2/M3)

## 许可证

MIT License