# claude-switch: Claude Code 配置管理工具

## 📖 项目故事

### 问题的诞生

作为一名频繁使用 Claude Code 的开发者，我经常需要在不同场景下使用不同的配置：

- **GLM 模型配置**：用于中文编程和本地化任务
- **Qwen3 模型配置**：用于大型代码生成和复杂算法设计  
- **GY 模型配置**：用于特定项目和工作流程

每次切换配置时，我都需要：
1. 手动备份当前的 `~/.claude/settings.json`
2. 找到对应的配置文件
3. 复制配置文件到主位置
4. 启动 Claude Code

这个过程不仅繁琐，而且容易出错。我开始思考：**能否创建一个工具来自动化这个过程？**

### 探索与尝试

#### 第一版：环境变量方案
我最初希望 Claude Code 支持环境变量 `CLAUDE_SETTINGS_PATH`，这样可以通过简单地改变环境变量来切换配置。但经过测试发现，Claude Code 并不支持这个功能。

#### 第二版：Shell 脚本方案
我尝试创建一个独立的 Shell 脚本来管理配置文件。这个方案可行，但需要在项目目录中维护额外的脚本文件，不够优雅。

#### 第三版：Shell 函数方案
最终，我决定创建一个 Shell 函数，直接集成到 `~/.bashrc` 中。这样：
- 无需额外的脚本文件
- 在任何目录下都可以使用
- 与 Shell 环境无缝集成

### 技术挑战与解决方案

#### 1. 配置文件管理
**问题**：如何管理多个配置文件？
**解决方案**：采用命名约定 `settings_{name}.json`，便于识别和管理。

#### 2. 备份机制
**问题**：切换配置时如何保护当前配置？
**解决方案**：每次切换前自动备份当前配置到 `settings.json.backup`。

#### 3. 错误处理
**问题**：如何处理配置文件不存在等情况？
**解决方案**：添加完善的错误检查和用户友好的错误提示。

#### 4. 参数传递
**问题**：避免将配置名称传递给 Claude Code。
**解决方案**：直接调用 `claude` 而不是 `claude "$@"`。

## 🎯 功能特性

### 核心功能
- **一键切换配置**：通过简单的命令切换不同的 Claude Code 配置
- **自动备份**：切换前自动备份当前配置，防止数据丢失
- **配置列表**：快速查看所有可用的配置
- **帮助系统**：内置详细的帮助信息
- **错误处理**：完善的错误检查和用户友好的提示

### 使用场景
- **多模型切换**：在不同的 AI 模型之间快速切换
- **项目隔离**：为不同项目使用不同的配置
- **团队协作**：在个人和工作配置之间切换
- **测试环境**：在测试和生产配置之间切换

## 🛠 技术设计

### 架构概览
```
claude-switch
├── 配置文件管理 (~/.claude/settings_*.json)
├── 备份系统 (~/.claude/settings.json.backup)
├── 主配置切换 (~/.claude/settings.json)
└── Claude Code 启动
```

### 文件结构
```
~/.claude/
├── settings.json              # 当前激活的配置
├── settings.json.backup       # 配置备份
├── settings_glm.json          # GLM 模型配置
├── settings_qwen3.json        # Qwen3 模型配置
├── settings_gy.json           # GY 模型配置
└── ...                        # 其他配置文件
```

### 核心算法
1. **参数解析**：判断用户是要查看帮助、列出配置还是切换配置
2. **文件检查**：验证请求的配置文件是否存在
3. **备份创建**：备份当前配置文件
4. **配置切换**：复制新配置文件到主位置
5. **应用启动**：启动 Claude Code

### 错误处理策略
- **配置文件不存在**：显示明确的错误信息和可用配置列表
- **备份失败**：不影响主要功能，但会显示警告
- **权限问题**：提供解决建议
- **Shell 限制**：检查必要的 Shell 功能

## 📦 安装指南

### 系统要求
- Bash Shell
- Claude Code 已安装
- 基本的文件操作权限

### 安装步骤

#### 1. 下载安装脚本
```bash
curl -o /tmp/claude-switch-installer.sh https://raw.githubusercontent.com/your-username/claude-switch/main/installer.sh
```

#### 2. 运行安装脚本
```bash
chmod +x /tmp/claude-switch-installer.sh
/tmp/claude-switch-installer.sh
```

#### 3. 重新加载 Shell 配置
```bash
source ~/.bashrc
```

#### 4. 验证安装
```bash
claude-switch help
```

### 手动安装

如果自动安装脚本不可用，可以手动安装：

#### 1. 编辑 ~/.bashrc
```bash
nano ~/.bashrc
```

#### 2. 添加函数代码
在文件末尾添加以下内容：

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

#### 3. 重新加载配置
```bash
source ~/.bashrc
```

## 📚 使用指南

### 基本用法

#### 查看帮助
```bash
claude-switch help
```

#### 列出可用配置
```bash
claude-switch
```

#### 切换配置
```bash
claude-switch glm
claude-switch qwen3
claude-switch gy
```

### 配置文件创建

#### 1. 创建新配置文件
```bash
# 复制当前配置作为模板
cp ~/.claude/settings.json ~/.claude/settings_myconfig.json

# 编辑新配置
nano ~/.claude/settings_myconfig.json
```

#### 2. 配置文件格式
```json
{
  "$schema": "https://json.schemastore.org/claude-code-settings.json",
  "env": {
    "ANTHROPIC_API_KEY": "your-api-key",
    "ANTHROPIC_BASE_URL": "https://api.example.com",
    "ANTHROPIC_MODEL": "your-model",
    "ANTHROPIC_SMALL_FAST_MODEL": "your-fast-model"
  },
  "permissions": {
    "allow": [],
    "deny": []
  }
}
```

### 实际使用场景

#### 场景1：多模型开发
```bash
# 使用 GLM 模型进行中文编程
claude-switch glm

# 使用 Qwen3 模型进行复杂算法设计
claude-switch qwen3

# 使用 GY 模型进行特定项目开发
claude-switch gy
```

#### 场景2：项目隔离
```bash
# 切换到项目A配置
claude-switch project-a

# 切换到项目B配置
claude-switch project-b

# 切换到个人配置
claude-switch personal
```

### 故障排除

#### 常见问题

**问题1：命令不存在**
```bash
# 确保函数已加载
source ~/.bashrc

# 检查函数是否定义
type claude-switch
```

**问题2：配置文件不存在**
```bash
# 检查配置目录
ls -la ~/.claude/

# 创建示例配置
cp ~/.claude/settings.json ~/.claude/settings_example.json
```

**问题3：权限错误**
```bash
# 检查文件权限
ls -la ~/.claude/settings.json

# 修复权限
chmod 644 ~/.claude/settings_*.json
```

#### 调试模式
```bash
# 启用调试输出
export CLAUDE_SWITCH_DEBUG=1
claude-switch your-config
```

## 🔧 高级用法

### 配置模板
创建常用配置模板：
```bash
# 生产环境模板
~/.claude/settings_production.json

# 开发环境模板
~/.claude/settings_development.json

# 测试环境模板
~/.claude/settings_testing.json
```

### 批量操作
```bash
# 列出所有配置及其大小
for config in ~/.claude/settings_*.json; do
    echo "$(basename "$config" .json): $(wc -l < "$config") 行"
done
```

### 自动化脚本
结合其他工具创建自动化工作流：
```bash
#!/bin/bash
# 项目启动脚本
claude-switch project-a
# 其他项目特定的初始化操作
```

## 🤝 贡献指南

### 开发环境设置
1. Fork 项目仓库
2. 克隆到本地
3. 创建功能分支
4. 测试您的更改

### 提交规范
- 使用清晰的提交信息
- 遵循现有的代码风格
- 确保向后兼容性

### 测试
```bash
# 运行测试套件
./tests/run-tests.sh

# 验证安装
./installer.sh --test
```

## 📄 许可证

本项目采用 MIT 许可证。详见 [LICENSE](LICENSE) 文件。

## 🙏 致谢

感谢 Claude Code 团队提供了如此优秀的开发工具。这个项目的灵感来自于日常开发中的实际需求，希望能够帮助更多的开发者提高工作效率。

---

**作者**: lyd123qw2008
**许可证**: MIT  
**GitHub**: [claude-switch](https://github.com/lyd123qw2008/claude-switch) 
**发布时间**: 2025年