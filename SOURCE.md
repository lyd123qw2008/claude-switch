# Claude Switch 源码文件

## 核心函数 (bashrc 版本)

```bash
# Claude Code 配置切换工具
claude-switch() {
    local config_name=$1
    
    # 显示帮助信息
    if [ "$config_name" = "help" ] || [ "$config_name" = "-h" ] || [ "$config_name" = "--help" ]; then
        echo "claude-switch - 切换 Claude Code 配置并启动"
        echo ""
        echo "用法:"
        echo "  claude-switch [配置名称|help]"
        echo ""
        echo "命令:"
        echo "  claude-switch          显示所有可用配置"
        echo "  claude-switch <名称>   切换到指定配置并启动 Claude Code"
        echo "  claude-switch help     显示此帮助信息"
        echo ""
        echo "示例:"
        echo "  claude-switch glm      切换到 GLM 配置"
        echo "  claude-switch qwen3    切换到 Qwen3 配置"
        echo ""
        echo "配置文件位置:"
        echo "  配置文件: ~/.claude/settings_<名称>.json"
        echo "  备份文件: ~/.claude/settings.json.backup"
        return 0
    fi
    
    # 显示可用配置列表
    if [ -z "$config_name" ]; then
        echo "可用配置:"
        ls -1 "$HOME/.claude/settings_"*.json 2>/dev/null | sed 's/.*settings_\(.*\)\.json/  - \1/'
        if [ $? -ne 0 ]; then
            echo "  (无可用配置)"
        fi
        return 0
    fi
    
    # 检查配置文件是否存在
    local config_file="$HOME/.claude/settings_${config_name}.json"
    if [ ! -f "$config_file" ]; then
        echo "错误: 配置文件不存在: $config_file"
        echo ""
        echo "可用配置:"
        ls -1 "$HOME/.claude/settings_"*.json 2>/dev/null | sed 's/.*settings_\(.*\)\.json/  - \1/' || echo "  (无可用配置)"
        return 1
    fi
    
    # 备份当前配置
    local backup_file="$HOME/.claude/settings.json.backup"
    if [ -f "$HOME/.claude/settings.json" ]; then
        cp "$HOME/.claude/settings.json" "$backup_file"
        echo "✓ 已备份当前配置到: $backup_file"
    fi
    
    # 切换配置
    cp "$config_file" "$HOME/.claude/settings.json"
    
    echo "✓ 已切换到配置: $config_name"
    echo "  配置文件来源: $config_file"
    echo "  配置已复制到: ~/.claude/settings.json"
    echo ""
    
    # 启动 Claude
    claude
}
```

## 独立脚本版本

```bash
#!/bin/bash
# Claude Switch 独立脚本版本
# 用法: ./claude-switch.sh <config_name>

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

CONFIG_NAME="$1"

# 显示帮助
if [ "$CONFIG_NAME" = "help" ] || [ "$CONFIG_NAME" = "-h" ] || [ "$CONFIG_NAME" = "--help" ] || [ -z "$CONFIG_NAME" ]; then
    echo "Claude Switch - 独立脚本版本"
    echo ""
    echo "用法: $0 <配置名称>"
    echo ""
    echo "可用配置:"
    ls -1 "$HOME/.claude/settings_"*.json 2>/dev/null | sed 's/.*settings_\(.*\)\.json/  - \1/'
    if [ $? -ne 0 ]; then
        echo "  (无可用配置)"
    fi
    exit 0
fi

# 检查配置文件
CONFIG_FILE="$HOME/.claude/settings_${CONFIG_NAME}.json"
if [ ! -f "$CONFIG_FILE" ]; then
    echo -e "${RED}错误: 配置文件不存在: $CONFIG_FILE${NC}"
    echo ""
    echo "可用配置:"
    ls -1 "$HOME/.claude/settings_"*.json 2>/dev/null | sed 's/.*settings_\(.*\)\.json/  - \1/' || echo "  (无可用配置)"
    exit 1
fi

# 备份当前配置
BACKUP_FILE="$HOME/.claude/settings.json.backup"
if [ -f "$HOME/.claude/settings.json" ]; then
    cp "$HOME/.claude/settings.json" "$BACKUP_FILE"
    echo -e "${GREEN}✓ 已备份当前配置到: $BACKUP_FILE${NC}"
fi

# 切换配置
cp "$CONFIG_FILE" "$HOME/.claude/settings.json"

echo -e "${GREEN}✓ 已切换到配置: $CONFIG_NAME${NC}"
echo "  配置文件来源: $CONFIG_FILE"
echo "  配置已复制到: ~/.claude/settings.json"
echo ""

# 启动 Claude
claude
```

## 配置文件模板

### 基础配置模板
```json
{
  "$schema": "https://json.schemastore.org/claude-code-settings.json",
  "env": {
    "ANTHROPIC_API_KEY": "your-api-key-here",
    "ANTHROPIC_BASE_URL": "https://api.anthropic.com",
    "ANTHROPIC_MODEL": "claude-3-5-sonnet-20241022",
    "ANTHROPIC_SMALL_FAST_MODEL": "claude-3-haiku-20240307"
  },
  "permissions": {
    "allow": [],
    "deny": []
  }
}
```

### GLM 模型配置模板
```json
{
  "$schema": "https://json.schemastore.org/claude-code-settings.json",
  "env": {
    "ANTHROPIC_API_KEY": "your-glm-api-key",
    "ANTHROPIC_BASE_URL": "https://api-inference.modelscope.cn",
    "ANTHROPIC_MODEL": "ZhipuAI/GLM-4.5",
    "ANTHROPIC_SMALL_FAST_MODEL": "ZhipuAI/GLM-4.5"
  },
  "permissions": {
    "allow": [],
    "deny": []
  }
}
```

### Qwen3 模型配置模板
```json
{
  "$schema": "https://json.schemastore.org/claude-code-settings.json",
  "env": {
    "ANTHROPIC_API_KEY": "your-qwen-api-key",
    "ANTHROPIC_BASE_URL": "https://dashscope.aliyuncs.com/compatible-mode/v1",
    "ANTHROPIC_MODEL": "Qwen/Qwen3-Coder-480B-A35B-Instruct",
    "ANTHROPIC_SMALL_FAST_MODEL": "Qwen/Qwen3-Coder-480B-A35B-Instruct"
  },
  "permissions": {
    "allow": [],
    "deny": []
  }
}
```

## 测试脚本

```bash
#!/bin/bash
# Claude Switch 测试脚本

set -e

echo "=== Claude Switch 测试套件 ==="

# 测试函数
test_function() {
    local test_name="$1"
    local test_command="$2"
    
    echo "测试: $test_name"
    if eval "$test_command"; then
        echo -e "${GREEN}✓ 通过${NC}"
    else
        echo -e "${RED}✗ 失败${NC}"
        return 1
    fi
}

# 检查函数是否已安装
test_function "函数已安装" "type claude-switch &> /dev/null"

# 检查配置目录
test_function "配置目录存在" "[ -d '$HOME/.claude' ]"

# 检查帮助功能
test_function "帮助功能" "claude-switch help > /dev/null"

# 检查列表功能
test_function "列表功能" "claude-switch > /dev/null"

echo ""
echo -e "${GREEN}所有测试通过！${NC}"
```