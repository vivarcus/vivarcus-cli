# Vivarcus CLI (`ov`)

面向 Agent 与自动化的 Vivarcus Vault 命令行工具：认证、对象 CRUD、组件/MDL、Inbound VPK 部署、Sandbox 等。

> 本仓库为**二进制分发与用户文档**公开镜像，不接受外部 PR。完整实现位于 Vivarcus 平台私有仓库。

## 安装

与目标 Vault **版本对齐**（Assembly tag，如 `v26R3.3-13304`）：

```bash
curl -fsSL https://raw.githubusercontent.com/vivarcus/vivarcus-cli/main/scripts/install-ov.sh | bash
```

指定版本：

```bash
VERSION=v26R3.3-13304 curl -fsSL https://raw.githubusercontent.com/vivarcus/vivarcus-cli/main/scripts/install-ov.sh | bash
```

或从 [GitHub Releases](https://github.com/vivarcus/vivarcus-cli/releases) 下载 `ov-linux-amd64`，放入 `PATH`（如 `~/.local/bin/ov`）。

## 快速开始

```bash
# 登录（OAuth Device Flow）
ov auth login --endpoint https://<your-vault>.vivarcus.com

# 或 Agent / CI：注入 PAT
export OV_TOKEN=ov_pat_...
export OV_ENDPOINT=https://<your-vault>.vivarcus.com
export OV_VAULT=<vault-uuid>

ov auth status --json
ov object list study__v --limit 5 --json
```

## 文档

| 文档 | 内容 |
|------|------|
| [docs/cli.md](docs/cli.md) | 命令参考与配置 |
| [docs/package-deploy.md](docs/package-deploy.md) | Inbound VPK 部署（配合 [vivarcus-sdk](https://github.com/vivarcus/vivarcus-sdk)） |

## 相关项目

| 仓库 | 用途 |
|------|------|
| [vivarcus/vivarcus-sdk](https://github.com/vivarcus/vivarcus-sdk) | Record Action 开发（`ov-sdk build` → wasm） |

## 许可

Apache License 2.0 — 见 [LICENSE](LICENSE)。
