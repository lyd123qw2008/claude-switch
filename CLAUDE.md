# CLAUDE.md

此文件为 Claude Code (claude.ai/code) 在此代码仓库中工作时提供指导。

## 项目概述

这是 `claude-switch`，一个 Claude Code 配置管理工具，允许用户轻松切换不同的 Claude Code 配置。项目使用 Bash 编写，包含一个简单的 shell 函数，该函数会被安装到用户的 `~/.bashrc` 文件中。

## 架构

### 核心组件

1. **主函数**: `claude-switch()` 函数处理所有操作
2. **安装脚本**: `install.sh` 处理自动安装/卸载
3. **配置管理**: 使用 `~/.claude/settings_*.json` 文件管理不同配置
4. **备份系统**: 切换前自动创建 `~/.claude/settings.json.backup`

### 文件结构

```
~/.claude/
├── settings.json              # 当前激活的配置
├── settings.json.backup       # 当前配置的备份
├── settings_glm.json          # GLM 模型配置
├── settings_qwen3.json        # Qwen3 模型配置
├── settings_gy.json           # GY 模型配置
└── ...                        # 其他命名配置
```

## 开发命令

### 安装和测试
```bash
# 安装工具
./install.sh

# 测试安装
source ~/.bashrc
claude-switch help

# 卸载工具
./install.sh uninstall
```

### 手动测试
```bash
# 测试帮助功能
claude-switch help

# 测试配置列表
claude-switch

# 测试配置切换（需要现有配置）
claude-switch glm
```

## 关键实现细节

### 函数逻辑流程
1. **帮助显示**: 使用 `help`、`-h` 或 `--help` 调用时显示使用信息
2. **配置列表**: 无参数调用时列出所有可用配置
3. **配置切换**: 将指定配置复制到主位置并启动 Claude Code
4. **备份创建**: 切换前始终备份当前配置

### 错误处理
- 切换前验证配置文件是否存在
- 提供清晰的错误消息和可用配置列表
- 优雅处理文件权限问题
- 检查必需的系统依赖（Bash、Claude Code）

### 配置文件格式
配置文件遵循 Claude Code 设置模式：
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

## 开发注意事项

- 项目使用简单的 Bash 函数方法以获得最大兼容性
- 除了 Bash 和 Claude Code 外没有外部依赖
- 配置文件使用命名约定 `settings_<name>.json`
- 工具与用户的 shell 环境无缝集成
- 所有操作都是原子的，具有适当的错误处理

## 常见开发任务

修改工具时：
1. 同时更新 `install.sh` 脚本和 `SOURCE.md` 中的函数代码
2. 测试安装/卸载过程
3. 验证所有错误情况都得到正确处理
4. 确保与现有配置的向后兼容性

该项目故意保持简单轻量，专注于解决 Claude Code 配置管理的特定问题，避免不必要的复杂性。
- commit 使用中文