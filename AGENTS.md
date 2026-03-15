# AGENTS.md - macOS Better Display

特别注意：所有的对话必须用中文

## Project Overview

macOS HiDPI activation tool for external displays. Enables HiDPI (Retina-like) scaling on non-Apple monitors by creating display override configuration files.

**Platform**: macOS only (uses `ioreg`, `system_profiler`, `/Library/Displays` system paths)

**Files**:
- `activate-HiDPI.bash` - Main interactive script
- `check.sh` - Display resolution checker utility

---

## Commands

### Run Main Script
```bash
# Enable/disable HiDPI (requires sudo)
sudo ./activate-HiDPI.bash

# Check current display status
./check.sh
```

### Debugging Commands
```bash
# Check display hardware IDs
ioreg -l | grep -E "DisplayVendorID|DisplayProductID"

# View current display info
system_profiler SPDisplaysDataType

# Check EDID data
ioreg -lw0 | grep -i "IODisplayEDID"

# List created override files
ls -la /Library/Displays/Contents/Resources/Overrides/
```

### Cleanup/Restore
```bash
# Remove HiDPI configurations (restore default)
sudo rm -rf /Library/Displays/Contents/Resources/Overrides/

# Or use the generated restore script
~/.hidpi-disable
```

---

## Code Style Guidelines

### Bash Scripts

**Shebang & Encoding**:
```bash
#!/bin/bash
# No encoding declaration needed for bash
```

**Function Naming**: Use `snake_case` with descriptive names
```bash
# Good
function get_edid() {
function create_res_1() {
function enable_hidpi_with_patch() {

# Avoid
function getEdid() {  # No camelCase
function GetEDID() {  # No PascalCase
```

**Variable Naming**: `snake_case` for locals, `UPPER_CASE` for globals
```bash
# Local variables
local index=0
local selection=0

# Global/configuration variables
gDisplayInf=()
gMonitor=""
EDID=""
VendorID=""
ProductID=""
```

**Heredocs for Multi-line Content**:
```bash
# Use heredocs for templates and long text
cat >"${dpiFile}" <<-\CCC
<?xml version="1.0" encoding="UTF-8"?>
...
CCC

# Use <<-\HEREDOC to allow indentation in source
# The - allows leading tabs to be stripped
```

**Error Handling**:
```bash
# Check for errors and exit with meaningful codes
if [[ -z "$gMonitor" || ${#gMonitor} -lt 32 ]]; then
    echo "无法获取有效的 EDID 信息"
    return 1
fi

# User input validation
case $selection in
[[:digit:]]*)
    if ((selection < 1 || selection > index)); then
        echo "${langEnterError}"
        exit 1
    fi
    ;;
*)
    echo "${langEnterError}"
    exit 1
    ;;
esac
```

**String Manipulation** (use bash built-ins):
```bash
# String slicing
${display:190:24}
${display:16:4}

# sed with -i for in-place edits (macOS requires "")
/usr/bin/sed -i "" "s/VID/$VendorID/g" ${dpiFile}

# printf for hex conversion
printf '%x\n' ${VendorID}
```

**Command Substitution**:
```bash
# Use $() not backticks
currentDir="$(cd $(dirname -- $0) && pwd)"  # Get script directory
```

**Platform Detection**:
```bash
# Apple Silicon check
is_applesilicon=$([[ "$(uname -m)" == "arm64" ]] && echo true || echo false)
```

---

## Project Patterns

### Display Override Structure
```
/Library/Displays/Contents/Resources/Overrides/
├── DisplayVendorID-{vendor_hex}/
│   ├── DisplayProductID-{product_hex}    # plist with scale-resolutions
│   └── DisplayProductID-{product_hex}.icns  # optional icon
└── Icons.plist  # optional icon configuration
```

### Resolution Encoding

Resolutions are encoded as base64-packed binary data:

```bash
# Generate HiDPI resolution data
hidpi=$(printf '%08x %08x' $((${width} * 2)) $((${height} * 2)) | xxd -r -p | base64)
```

**HiDPI 数据结构** (每个 `<data>` 条目):

每个条目是 base64 编码的二进制结构，包含 4 个 32 位字段：

```
| 宽度 (32bit) | 高度 (32bit) | Scale Flags | Display Mode Flags |
```

**后缀格式说明**:

| 后缀 | 解码后 Flags | 含义 |
|------|-------------|------|
| `A` | 无 | 基础分辨率，最小格式 |
| `AAAAB` | `00000001` | HiDPI 标志位 |
| `AAAABACAAAA==` | `00000001 00200000` | HiDPI + 镜像有效 (kDisplayModeValidForMirroringFlag) |
| `AAAAJAKAAAA==` | `00000001 00a00000` | HiDPI + 镜像 + 高分辨率有效 (kDisplayModeValidForHiResFlag) |

**Display Mode Flags** (关键标志位):

```c
kDisplayModeValidForMirroringFlag = 0x00200000  // 镜像有效
kDisplayModeValidForHiResFlag     = 0x00800000  // 高分辨率有效
kDisplayModeAlwaysShowFlag        = 0x00000008  // 始终显示
kDisplayModeNativeFlag            = 0x02000000  // 原生分辨率
```

**`create_res_*` 函数用途**:

- `create_res_1`: 基础分辨率列表，后缀 `A`
- `create_res_2`: HiDPI + 镜像支持，后缀 `AAAABACAAAA==`
- `create_res_3`: 简单 HiDPI 标志，后缀 `AAAAB`
- `create_res_4`: 完整 HiDPI 标志（推荐），后缀 `AAAAJAKAAAA==`
- `create_res`: 同时生成 `AAAAB` 和 `AAAABACAAAA==` 两种格式

### Multi-language Support
Use variable-based strings with language detection:
```bash
systemLanguage=($(locale | grep LANG | sed s/'LANG='// | tr -d '"' | cut -d "." -f 1))

# Default (English)
langDisplay="Display"
langChooseDis="Choose the display"

# Override for specific locales
if [[ "${systemLanguage}" == "zh_CN" ]]; then
    langDisplay="显示器"
    langChooseDis="选择显示器"
fi
```

### Sudo Requirements
Scripts modify `/Library/Displays/` which requires root access:
```bash
sudo mkdir -p "${targetDir}"
sudo cp -r ${currentDir}/tmp/* ${targetDir}/
sudo chown -R root:wheel ${currentDir}/tmp/
sudo chmod -R 0755 ${currentDir}/tmp/
```

---

## Important Notes

1. **No Build/Test Commands**: This is a utility script collection, not a buildable project.

2. **Sudo Required**: All main operations require `sudo` for writing to `/Library/Displays/`.

3. **Restart Required**: Changes take effect after system restart or logout/login.

4. **Apple Silicon**: Different detection method (no EDID), uses `ioreg -l | grep DisplayAttributes`.

5. **Safety**: Always creates backup restore script at `~/.hidpi-disable`.

6. **Dependencies**: 
   - Core: `bash`, `ioreg`, `system_profiler`, `xxd`, `base64`, `sed`, `curl`
   - Optional: `displayplacer` (for check.sh resolution listing)

7. **File Permissions**: Override files must be `root:wheel` with mode `0644`.