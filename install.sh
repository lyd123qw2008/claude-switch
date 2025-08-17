#!/bin/bash

# Claude Code 配置切换工具安装脚本
# 作者: Claude Switch Team
# 版本: 1.0.0

set -e  # 遇到错误立即退出

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 打印带颜色的消息
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查系统要求
check_requirements() {
    print_info "检查系统要求..."
    
    # 检查是否为 bash
    if [ -z "$BASH_VERSION" ]; then
        print_error "此脚本需要在 Bash 环境中运行"
        exit 1
    fi
    
    # 检查 Claude Code 是否安装
    if ! command -v claude &> /dev/null; then
        print_warning "Claude Code 未安装。请先安装 Claude Code"
        exit 1
    fi
    
    # 检查 ~/.claude 目录是否存在
    if [ ! -d "$HOME/.claude" ]; then
        print_info "创建 ~/.claude 目录..."
        mkdir -p "$HOME/.claude"
    fi
    
    print_success "系统要求检查完成"
}

# 备份现有的 bashrc
backup_bashrc() {
    if [ -f "$HOME/.bashrc" ]; then
        local backup_file="$HOME/.bashrc.backup.$(date +%Y%m%d_%H%M%S)"
        cp "$HOME/.bashrc" "$backup_file"
        print_info "已备份现有的 .bashrc 到: $backup_file"
    fi
}

# 检查是否已经安装了 claude-switch
is_installed() {
    grep -q "claude-switch()" "$HOME/.bashrc" 2>/dev/null
}

# 安装 claude-switch 函数
install_function() {
    print_info "安装 claude-switch 函数..."
    
    # 创建临时文件
    local temp_file=$(mktemp)
    
    # 写入函数代码
    cat > "$temp_file" << 'EOF'

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

EOF
    
    # 将函数添加到 .bashrc
    cat "$temp_file" >> "$HOME/.bashrc"
    
    # 清理临时文件
    rm -f "$temp_file"
    
    print_success "claude-switch 函数已安装到 ~/.bashrc"
}

# 创建示例配置文件
create_sample_config() {
    print_info "创建示例配置文件..."
    
    # 如果不存在 settings.json，创建一个示例
    if [ ! -f "$HOME/.claude/settings.json" ]; then
        cat > "$HOME/.claude/settings.json" << 'EOF'
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
EOF
        print_info "已创建示例配置文件: ~/.claude/settings.json"
    fi
}

# 显示安装完成信息
show_completion_info() {
    echo ""
    print_success "claude-switch 安装完成！"
    echo ""
    echo "下一步："
    echo "1. 重新加载 Shell 配置："
    echo "   source ~/.bashrc"
    echo ""
    echo "2. 或重新打开终端"
    echo ""
    echo "3. 验证安装："
    echo "   claude-switch help"
    echo ""
    echo "4. 查看可用配置："
    echo "   claude-switch"
    echo ""
    echo "更多信息请查看：$(pwd)/README.md"
}

# 卸载函数
uninstall() {
    print_info "卸载 claude-switch..."
    
    # 创建临时文件
    local temp_file=$(mktemp)
    local bashrc_file="$HOME/.bashrc"
    
    # 移除 claude-switch 函数
    awk '
    BEGIN { skip = 0 }
    /^# Claude Code 配置切换工具$/ { skip = 1; next }
    /^claude-switch\(\) {$/ { skip = 1; next }
    skip && /^}$/ { skip = 0; next }
    !skip { print }
    ' "$bashrc_file" > "$temp_file"
    
    # 替换原文件
    mv "$temp_file" "$bashrc_file"
    
    print_success "claude-switch 已从 ~/.bashrc 中移除"
    print_info "请运行 'source ~/.bashrc' 重新加载配置"
}

# 显示帮助
show_help() {
    echo "Claude Switch 安装脚本"
    echo ""
    echo "用法: $0 [选项]"
    echo ""
    echo "选项:"
    echo "  install    安装 claude-switch (默认)"
    echo "  uninstall  卸载 claude-switch"
    echo "  help       显示此帮助信息"
    echo ""
    echo "示例:"
    echo "  $0 install   # 安装"
    echo "  $0 uninstall # 卸载"
    echo "  $0 help      # 显示帮助"
}

# 主函数
main() {
    local action="${1:-install}"
    
    case "$action" in
        "install")
            print_info "开始安装 claude-switch..."
            
            if is_installed; then
                print_warning "claude-switch 已经安装"
                read -p "是否重新安装? (y/N): " -n 1 -r
                echo
                if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                    exit 0
                fi
            fi
            
            check_requirements
            backup_bashrc
            install_function
            create_sample_config
            show_completion_info
            ;;
        "uninstall")
            uninstall
            ;;
        "help"|"-h"|"--help")
            show_help
            ;;
        *)
            print_error "未知选项: $action"
            show_help
            exit 1
            ;;
    esac
}

# 运行主函数
main "$@"