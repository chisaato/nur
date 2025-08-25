# NUR仓库构建和测试指南

本文档介绍了如何测试和构建您的Nix User Repository (NUR)。

## 本地测试构建

### 构建单个包
使用 `nix-build -A 包名` 命令构建特定包：
```bash
nix-build -A garden-bin
```

### 使用flake构建
使用 `nix build .#包名` 命令：
```bash
nix build .#garden-bin
```

### 检查可构建的包
使用以下命令查看所有可构建的包及其元数据：
```bash
nix-env -f . -qa \* --meta --xml
```

### CI构建测试
使用以下命令模拟CI环境中的构建过程：
```bash
nix-build ci.nix -A cacheOutputs
```

## CI/CD测试

您的仓库已经配置了GitHub Actions，在 `.github/workflows/build.yml` 中定义了：
- 自动构建和缓存
- 多个NixOS版本的测试
- 每日定时构建

## 测试更新脚本

使用 `utils/update` 脚本来更新包版本：
```bash
python3 utils/update garden-bin
```

## 当前状态

- `garden-bin` 包可以成功构建
- `qwen-code` 包目前被注释掉，还在测试中
- CI构建系统工作正常

建议在推送代码之前运行这些本地测试命令来验证您的更改。