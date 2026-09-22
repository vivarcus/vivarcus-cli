# Vivarcus CLI (`vivarcus`)

给 Agent 与开发者操作 Vivarcus Vault：对象 CRUD、组件 / MDL、Inbound VPK、Sandbox 等。

> 问题与功能请求请通过 Vivarcus 客户支持渠道联系，不要在本仓库提交 PR。

## 安装

下载与目标 Vault **版本对齐**的 Assembly tag（如 `v26R3.3-13304`）：

```bash
curl -fsSL https://raw.githubusercontent.com/vivarcus/vivarcus-cli/main/scripts/install-vivarcus.sh | bash
```

钉死版本：

```bash
VERSION=v26R3.3-13304 curl -fsSL https://raw.githubusercontent.com/vivarcus/vivarcus-cli/main/scripts/install-vivarcus.sh | bash
```

或从 [GitHub Releases](https://github.com/vivarcus/vivarcus-cli/releases) 下载 `vivarcus-linux-amd64`，放到 `PATH`（例如 `~/.local/bin/vivarcus`）。

## 登录

```bash
# 人工首次登录（OAuth Device Flow）
vivarcus auth login --endpoint https://<your-vault>.vivarcus.com

# Agent / CI: inject token once; do not password-login before every command (10/min/IP+user)
export VIVARCUS_TOKEN=<session-token>
export VIVARCUS_ENDPOINT=https://<your-vault>.vivarcus.com
export VIVARCUS_VAULT=<vault-uuid>

vivarcus auth status --json
vivarcus object list study__v --limit 5 --json
```

## 文档

| 文档 | 说明 |
|------|------|
| [docs/cli.md](docs/cli.md) | 命令参考（含 `sdk put` / `logs` 等） |
| [docs/package-deploy.md](docs/package-deploy.md) | Inbound VPK 部署（配合 [Go SDK](https://github.com/vivarcus/vivarcus-sdk)） |

## 相关仓库

| 仓库 | 说明 |
|------|------|
| [vivarcus/vivarcus-sdk](https://github.com/vivarcus/vivarcus-sdk) | Record Action 等 Go API；`vivarcus package` 部署，Vault 编译 |

## License

Apache License 2.0 — 见 [LICENSE](LICENSE)。
